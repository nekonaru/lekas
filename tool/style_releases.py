"""Regenerate every GitHub release's body and title per guide section 7.

The changelogs are the canonical source: this script reads each version's
entry from CHANGELOG.md (English) and CHANGELOG.id.md (Indonesian) and
rewrites the release on GitHub in the exact template shape: bilingual
headers, bold lead-ins on bullets, the separator, and the Install section.

Titles are normalized to `Lekas <tag> - <short description>` taken from the
changelog heading.

Usage:
    python tool/style_releases.py --dry-run   # print what would change
    python tool/style_releases.py             # apply on GitHub
"""

import argparse
import pathlib
import re
import subprocess
import tempfile

INSTALL_EN = (
    "Download the APK matching your device below (`app-arm64-v8a-release.apk` "
    "for most modern phones, `app-armeabi-v7a-release.apk` for older 32-bit ones). "
    "Open it on your phone and allow installs from unknown sources if asked. "
    "Minimum Android 7.0 (API 24)."
)
INSTALL_ID = (
    "Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan HP modern, "
    "`app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP dan izinkan "
    "instalasi dari sumber tidak dikenal bila diminta. Minimum Android 7.0 (API 24)."
)


def parse_entry(path, tag):
    text = pathlib.Path(path).read_text(encoding="utf-8")
    start = text.index(f"## {tag} ")
    tail = text[start:]
    nxt = tail.find("\n## v", 1)
    body = tail[:nxt] if nxt >= 0 else tail
    lines = body.splitlines()
    short = (lines[0]
             .removeprefix(f"## {tag} - ")
             .removeprefix(f"## {tag} ")
             .strip())
    sections = []  # (heading, [lines])
    current = None
    for line in lines[1:]:
        if line.startswith("### "):
            current = (line.removeprefix("### ").strip(), [])
            sections.append(current)
        elif current is not None:
            current[1].append(line)
    # The template Install section supersedes the changelog's own copy:
    # strip any existing Install heading so it is never duplicated.
    cleaned = []
    for head, body_lines in sections:
        if head.lower().startswith("install") or head.lower().startswith("instalasi"):
            continue
        kept = []
        for raw in body_lines:
            if raw.strip():
                kept.append(raw)
        if kept:
            cleaned.append((head, kept))
    return short, cleaned


def notes_block(tag, short, sections, install_head, install_body, bold_suffix, lead_key):
    out = [f"# {lead_key}", "", f"**Lekas {tag} - {short} ({bold_suffix})**", ""]
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
    parser.add_argument("--only", nargs="*", default=None,
                          help="tags to style, default all")
    args = parser.parse_args()

    tags = args.only or ["v1.0.0", "v1.0.1", "v1.1.0", "v1.2.0", "v1.3.0", "v1.4.0",
                         "v1.4.1", "v1.4.2", "v1.5.0", "v1.5.1", "v1.6.0", "v1.7.0"]

    for tag in tags:
        title_en, sec_en = parse_entry("CHANGELOG.md", tag)
        title_id, sec_id = parse_entry("CHANGELOG.id.md", tag)
        en = notes_block(tag, title_en, sec_en, "Install / Update", INSTALL_EN, "EN", "English")
        id_body = notes_block(tag, title_id, sec_id, "Instalasi / Update", INSTALL_ID, "ID", "Bahasa Indonesia")
        notes = en + "\n\n<br>\n\n---\n\n<br>\n\n" + id_body

        Title = f"Lekas {tag} - {title_en}"
        current = gh(["release", "view", tag, "--json", "name,body", "--jq",
                      "{name, body}"])
        info = __import__("json").loads(current)
        changed = []
        if info["name"] != Title:
            changed.append("title")
        if info["body"] != notes:
            changed.append("body")
        status = "would update " + ",".join(changed) if args.dry_run else "updated" if changed else "same"
        print(f"{tag}: {status}")
        if args.dry_run:
            if changed:
                print("  --- BEGIN NOTES ---")
                print(notes)
                print("  --- END NOTES ---")
            continue
        with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as f:
            f.write(notes)
            notes_file = f.name
        gh(["release", "edit", tag, "-t", Title, "--notes-file", notes_file])
    print("done")


if __name__ == "__main__":
    main()
