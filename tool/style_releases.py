"""Style every GitHub release to guide section 7 from the changelogs.

The changelogs are the canonical source (one sentence summary, then the
content sections). The release title is the project name and version only,
with no dash; the body is bilingual with one summary sentence per language,
bullets under New features / Improvements / Bug fixes, then the Install
section, separated by exactly <br>, blank line, ---, blank line, <br>.

Usage:
    python tool/style_releases.py --dry-run    # print what would change
    python tool/style_releases.py              # apply on GitHub
"""

import argparse
import json
import pathlib
import subprocess
import tempfile

INSTALL_EN = (
    "Download the APK matching your device (`app-arm64-v8a-release.apk` "
    "for most modern phones, `app-armeabi-v7a-release.apk` for older 32-bit ones). "
    "Open it on your phone and allow installs from unknown sources if asked. "
    "Grant notification permission when the app first asks, and leave battery "
    "optimization unrestricted for Lekas. Requires Android 7.0 (API 24)."
)
INSTALL_ID = (
    "Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, "
    "`app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan "
    "instalasi dari sumber tidak dikenal bila diminta. Berikan izin notifikasi "
    "saat aplikasi pertama kali meminta, dan biarkan optimalisasi baterai tanpa "
    "batasan untuk Lekas. Membutuhkan Android 7.0 (API 24)."
)


def parse_entry(path, tag):
    """Returns (summary, [(heading, [lines])]) from one changelog entry."""
    text = pathlib.Path(path).read_text(encoding="utf-8")
    start = text.index(f"## {tag}")
    tail = text[start:]
    nxt = tail.find("\n## v", 1)
    body = tail[:nxt] if nxt >= 0 else tail
    lines = body.splitlines()
    summary = ""
    for line in lines[1:]:
        if line.strip() and not line.startswith("###"):
            summary = line.strip()
            break
    sections = []
    current = None
    for line in lines[1:]:
        if line.startswith("### "):
            current = (line.removeprefix("### ").strip(), [])
            sections.append(current)
        elif current is not None and line.strip():
            current[1].append(line)
    return summary, sections


def notes_block(summary, sections, install_head, install_body, lead_key):
    out = [f"# {lead_key}", "", summary, ""]
    for head, body_lines in sections:
        out.append(f"## {head}")
        out.append("")
        out.extend(body_lines)
        out.append("")
    out.append(f"## {install_head}")
    out.append("")
    out.append(install_body)
    return "\n".join(out) + "\n"


def gh(args):
    result = subprocess.run(["gh.exe", *args], capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"gh {' '.join(args)} failed: {result.stderr.strip()}")
    return result.stdout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    tags = ["v1.0.0", "v1.0.1", "v1.1.0", "v1.2.0", "v1.3.0", "v1.4.0",
            "v1.4.1", "v1.4.2", "v1.5.0", "v1.5.1", "v1.6.0", "v1.7.0"]

    for tag in tags:
        summary_en, sec_en = parse_entry("CHANGELOG.md", tag)
        summary_id, sec_id = parse_entry("CHANGELOG.id.md", tag)
        en = notes_block(summary_en, sec_en, "Install / Update", INSTALL_EN, "English")
        id_body = notes_block(summary_id, sec_id, "Instalasi / Update", INSTALL_ID, "Bahasa Indonesia")
        notes = en + "\n\n<br>\n\n---\n\n<br>\n\n" + id_body

        title = f"Lekas {tag}"
        info = json.loads(gh(["release", "view", tag, "--json", "name,body", "--jq",
                              "{name, body}"]))
        changed = []
        if info["name"] != title:
            changed.append("title")
        if info["body"] != notes:
            changed.append("body")
        if not changed:
            print(f"{tag}: same")
            continue
        if args.dry_run:
            print(f"{tag}: would update {','.join(changed)}")
            continue
        with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as f:
            f.write(notes)
            notes_file = f.name
        gh(["release", "edit", tag, "-t", title, "--notes-file", notes_file])
        print(f"{tag}: updated {','.join(changed)}")
    print("done")


if __name__ == "__main__":
    main()
