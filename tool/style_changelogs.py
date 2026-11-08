"""Rewrite both changelogs into the guide section 8 shape.

    ## vX.Y.Z
    <one sentence summary>
    ### New features / Improvements / Bug fixes
    ...

No title decoration, no Install / Update section (the release notes carry
it instead). Summaries below are one sentence each per version, written
from each entry's existing bullets. Bullets are copied verbatim.
"""

import argparse
import pathlib

SUMMARIES_EN = {
    "v1.0.0": "Lekas ships its first public release with Quick Add, offline reminders, Today, widgets and bilingual support.",
    "v1.0.1": "Lekas starts on the home screen, keeps the Today list light, and fixes a batch of update time crashes.",
    "v1.1.0": "Lekas adds task dependencies and smarter Quick Add and pulls finished screens into the menus.",
    "v1.2.0": "Lekas shares one smooth motion across the interface and makes long lists lighter to draw.",
    "v1.3.0": "Lekas adds accent colors, four font sizes and bundled Inter typography.",
    "v1.4.0": "Lekas adds one tap theme presets and hero transitions into task detail.",
    "v1.4.1": "Lekas fixes the release crash caused by the shrinker stripping WorkManager classes.",
    "v1.4.2": "Lekas fixes the black screen after setup and makes the language choice respond.",
    "v1.5.0": "Lekas ships a new logo, a refined theme and smoother, lighter lists.",
    "v1.5.1": "Lekas refreshes the app icon from a bolt to a bold check.",
    "v1.6.0": "Lekas adds bulk selection everywhere, drag to reorder, a level switch, and a refreshed interface.",
    "v1.7.0": "Lekas adds a PIN app lock and tap to manage calendar days.",
}

SUMMARIES_ID = {
    "v1.0.0": "Lekas merilis versi publik pertamanya dengan Quick Add, pengingat offline, Today, widget, dan dukungan dua bahasa.",
    "v1.0.1": "Lekas langsung membuka layar utama, meringankan daftar Today, dan memperbaiki sejumlah crash pasca update.",
    "v1.1.0": "Lekas menambahkan dependensi tugas dan Quick Add yang lebih pintar, plus menyerahkan layar jadi ke menu.",
    "v1.2.0": "Lekas menyatukan gerakan di antarmuka dan membuat daftar panjang lebih ringan digambar.",
    "v1.3.0": "Lekas menambahkan warna aksen, empat ukuran font, dan tipografi Inter bawaan.",
    "v1.4.0": "Lekas menambahkan preset tema sekali ketuk dan transisi hero ke detail tugas.",
    "v1.4.1": "Lekas memperbaiki crash saat dibuka yang disebabkan penyusut memotong kelas WorkManager.",
    "v1.4.2": "Lekas memperbaiki layar hitam setelah setup dan membuat pilihan bahasa bereaksi.",
    "v1.5.0": "Lekas membawa logo baru, tema yang lebih rapi, dan daftar yang lebih halus dan ringan.",
    "v1.5.1": "Lekas menyegarkan ikon aplikasi dari petir ke centang tebal.",
    "v1.6.0": "Lekas menambahkan pilih massal di semua daftar, seret susun, saklar jenjang, dan tampilan baru.",
    "v1.7.0": "Lekas menambahkan kunci aplikasi PIN dan ketuk kalender untuk mengelola tugas harian.",
}

RENAME_EN = {
    "optimizations": "Improvements",
}
RENAME_ID = {
    "optimisasi": "Peningkatan",
}


def parse(path):
    text = pathlib.Path(path).read_text(encoding="utf-8")
    header, _, rest = text.partition("## v")
    # first lines: '# Changelog', blank, intro, blank, then first entry
    out_head = header
    entries = []
    parts = text.split("\n## v")
    for part in parts[1:]:
        # part starts with "1.5.1 - ..." so the tag is that token
        version = part.split(" ", 1)[0].strip()
        tag = f"v{version}"
        full = "## v" + part
        lines = full.splitlines()
        heading = lines[0]
        sections = []
        current = None
        for line in lines[1:]:
            if line.startswith("### "):
                if current is not None:
                    sections.append(current)
                current = (line.removeprefix("### ").strip(), [])
            elif current is not None and line.strip():
                current[1].append(line)
        if current is not None:
            sections.append(current)
        entries.append((tag, heading, sections))
    return out_head, entries


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--only", nargs="*", default=None,
                        help="file to process")
    args = parser.parse_args()

    for path, summaries, rename in [
        ("CHANGELOG.md", SUMMARIES_EN, RENAME_EN),
        ("CHANGELOG.id.md", SUMMARIES_ID, RENAME_ID),
    ]:
        if args.only and path not in args.only:
            continue
        out_head, entries = parse(path)
        missing = [t for t, _, _ in entries if t not in summaries]
        assert not missing, f"{path} has entries without summary: {missing}"
        out = [out_head.rstrip()]
        for tag, _hd, sections in entries:
            out.append("")
            out.append(f"## {tag}")
            out.append("")
            out.append(summaries[tag])
            for head_name, lines in sections:
                low = head_name.lower()
                if low.startswith("install") or low.startswith("instalasi"):
                    continue
                new_name = rename.get(low, head_name)
                out.append("")
                out.append(f"### {new_name}")
                out.append("")
                out.extend(lines)
        new = "\n".join(out) + "\n"
        if args.dry_run:
            print(f"##### {path} (first 40 lines) #####")
            print("\n".join(new.splitlines()[:40]))
            continue
        pathlib.Path(path).write_text(new, encoding="utf-8")
        print(f"{path} rewritten ({len(entries)} versions)")
    print("done")


if __name__ == "__main__":
    main()
