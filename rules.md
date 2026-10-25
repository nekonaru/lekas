# Style Guide

This file is the single source of truth for how the `boredom` project (and any
follow-up project that wants to match it) is written, described, and released.
Keep it short, keep it consistent, and never break the rules below.

## 1. Punctuation (hard rule)

- **No em dash (U+2014) and no en dash (U+2013) anywhere.** Not in code,
  comments, docs, README, changelog, release notes, commit messages, or UI
  strings.
- Use a plain hyphen `-` for ranges and compound words, or rewrite with a
  comma or period.
- Examples:
  - Bad: `XP / Active Day - last 7 days`
  - Good: `XP / Active Day, last 7 days`
  - Bad: `v3.2.0 - Freeze tokens`
  - Good: `v3.2.0 - Freeze tokens`

## 2. Repository description

Short, one sentence, English, action-oriented, mentions the platform and the
offline-first nature.

Current canonical description:

> Turn boredom into real-world missions (Flutter) with XP, levels, streaks,
> quest chains, and achievements. Fully offline.

Rules:
- Start with a verb ("Turn", "Build", "Ship").
- Mention the stack in parentheses when relevant: `(Flutter)`.
- End with a concrete benefit: `Fully offline.`
- No em/en dash. No trailing period beyond the final one.

## 3. Repository topics

Canonical topic set (keep sorted alphabetically, lowercase, hyphenated):

```
android, dart, flutter, gamification, indonesia, missions, offline, offline-first
```

Add a topic only when the project genuinely covers it. Remove stale ones on
major pivots.

## 4. Bilingual README

Two files, always kept in sync:

- `README.md` - English (source of truth, default language).
- `README.id.md` - Bahasa Indonesia.

### 4.1 Language switcher

First content line after the centered header block:

```markdown
**English** | [Bahasa Indonesia](README.id.md)
```

In `README.id.md` the same line reversed:

```markdown
[English](README.md) | **Bahasa Indonesia**
```

### 4.2 Structure parity

Both files must have the same section order and the same headings (translated).
Canonical sections:

1. About
2. Features (table: Feature | Description)
3. Requirements
4. Installation (Option A: APK, Option B: build from source)
5. Usage
6. Display Language
7. Project Structure
8. Testing
9. FAQ
10. Author
11. License

### 4.3 Content rules

- English is the source of truth; Indonesian is a translation, never the
  other way around.
- Keep numbers, versions, commands, file paths, and code blocks identical
  across both languages.
- Translate prose only. Keep emoji, badges, and code fences as-is.
- No em/en dash in either language.
- Code identifiers stay in English even in the Indonesian file.

## 5. Release notes (Swara style)

Every GitHub Release uses this exact shape:

Title: `Boredom vX.Y.Z - Short description`

Body (bilingual, English first, then Indonesian):

```markdown
# English

**Boredom vX.Y.Z - Short description (EN)**

## New features

- **Bold lead-in.** One sentence explaining the feature.

## Optimizations

- **Bold lead-in.** One sentence.

## Bug fixes

- **Bold lead-in.** One sentence.

## Install / Update

Download the APK matching your device below (`app-arm64-v8a-release.apk` for
most modern phones, `app-armeabi-v7a-release.apk` for older 32-bit ones).
Open it on your phone and allow installs from unknown sources if asked.
Minimum Android 8.0 (API 26).

<br>

---

<br>

# Bahasa Indonesia

**Boredom vX.Y.Z - Short description (ID)**

## Fitur baru

- **Bold lead-in.** Satu kalimat.

## Optimisasi

- **Bold lead-in.** Satu kalimat.

## Perbaikan bug

- **Bold lead-in.** Satu kalimat.

## Instalasi / Update

Download APK sesuai HP di bawah (`app-arm64-v8a-release.apk` untuk kebanyakan
HP modern, `app-armeabi-v7a-release.apk` untuk yang 32-bit lama). Buka di HP
dan izinkan instalasi dari sumber tidak dikenal bila diminta. Minimum
Android 8.0 (API 26).
```

Rules:
- Sections are per-point bullet lists, never paragraphs.
- Omit a section entirely if it has no items.
- Always include `## Install / Update` (or `## Instalasi / Update`).
- Separator between languages is exactly `<br>\n\n---\n\n<br>`.
- No em/en dash. Use `-` in the title.

## 6. Changelog files

- `CHANGELOG.md` (English) and `CHANGELOG.id.md` (Bahasa Indonesia).
- Each version starts with `## vX.Y.Z` followed by the same four sections.
- Newest version on top.
- Keep in sync with release notes.

## 7. Commit messages

- Format: `type: short description` (e.g. `feat: v4.1.0 preferred defaults`).
- Types:
  - `feat` - new feature or capability
  - `fix` - bug fix
  - `docs` - documentation only
  - `chore` - tooling, config, dependencies
  - `refactor` - code change that neither fixes a bug nor adds a feature
  - `test` - adding or fixing tests
  - `perf` - performance improvement
  - `style` - formatting only, no logic change
  - `revert` - revert a previous commit
- Scope is optional: `feat(profile): add defaults section`.
- English only. No em/en dash.
- One logical change per commit. Keep the subject under 72 characters.
- Body (optional) explains the "why", wrapped at 72 columns.

## 7.1 Push rules (mandatory)

- **Every change must be committed AND pushed to the remote repo.** No local-only
  work is considered done.
- Push after every commit, not at the end of the day. Each commit triggers CI.
- Never leave uncommitted changes sitting in the working tree when a task is
  finished.
- Push both the branch and any new tags: `git push origin <branch>` and
  `git push origin <tag>`.
- If a push fails, fix the cause (rebase, resolve conflicts) and push again.
  Do not move on to the next task with a failed push.
- Verify the remote received the commit with `git log origin/<branch> --oneline -1`.

## 8. Code and comments

- English is the default for all code, comments, and identifiers.
- Indonesian is the in-app UI option only (via `app_strings.dart`).
- Add EN/ID pairs to `lib/l10n/app_strings.dart` (English first) for every
  new user-facing string.
- Catalog content (missions, achievements, challenges, chain steps) uses
  `titleId`/`descriptionId` fields next to the English ones.
- No codegen (`flutter gen-l10n` is intentionally not used).

## 9. Versioning

- Format: `MAJOR.MINOR.PATCH+BUILD` in `pubspec.yaml` (app projects).
- For non-app (CLI/code/library) projects use `MAJOR.MINOR.PATCH` only (no build
  number, no pubspec).
- `kAppVersion` in `lib/utils/app_theme.dart` mirrors `MAJOR.MINOR.PATCH` (app only).
- Tag: `vX.Y.Z`. Release title: `Boredom vX.Y.Z - Description`.

## 9.1 App projects vs non-app (CLI/code) projects

### App projects (has a UI / APK / binary artifact)

- Release notes include the `## Install / Update` (or `## Instalasi / Update`)
  section with download links and minimum OS.
- Attach built artifacts (APK, IPA, exe) to the GitHub Release.
- Mention platform requirements (Android 8.0 / API 26, etc.).
- README has Installation with "Download the APK" + "Build from source".
- Topics include platform tags (`android`, `ios`, `desktop`).

### Non-app projects (CLI tools, libraries, SDKs, pure code)

- No `Install / Update` section. Replace with `## Usage` or `## API` showing
  how to run or call it.
- No APK/binary attachments unless a binary is published. Prefer package
  registry links (pub.dev, npm, PyPI, crates.io) or `go install` / `pip install`.
- README has Installation via package manager or `git clone` + build, no
  "Download the APK".
- Release notes sections become: `New features`, `Optimizations`, `Bug fixes`,
  then `Usage` / `Breaking changes` (if any) instead of Install.
- Add a `## Breaking changes` section when a release removes or renames a
  public API. List the old name, the new name, and a migration snippet.
- Topics are language/ecosystem tags only (`dart`, `cli`, `library`), no
  platform tags unless the tool is platform-specific.
- Versioning follows SemVer strictly: breaking change = major bump.

## 10. Code style (Dart/Flutter)

- Lints: `package:flutter_lints/flutter.yaml` plus project overrides.
- `prefer_single_quotes: true` - always single quotes for strings.
- `sort_child_properties_last: true` - `child`/`children` last in widget calls.
- File names: `snake_case.dart`. Classes: `PascalCase`. Variables/functions: `camelCase`.
- Private members prefixed with `_`.
- One public class per file when practical; file name matches the class.
- No unused imports or dead code (analyze must report zero issues).
- Comments in English. Indonesian only inside `app_strings.dart` pairs.
- Avoid new plugins/permissions; keep the app lightweight.

## 11. Testing conventions

- Tests live in `test/`. File name `*_test.dart`.
- Every test that touches storage calls `SharedPreferences.setMockInitialValues({})`
  and `StorageService.instance.clearCache()`.
- Run `flutter analyze` (zero issues) and `flutter test` before pushing.
- CI is the only verification (no local Flutter SDK assumed).

## 12. Workflow / CI

- CI runs on push to `main`/`master` and on `v*` tags.
- Tag a release only after CI green on the branch commit.
- Releases attach two split APKs: `app-arm64-v8a-release.apk` and
  `app-armeabi-v7a-release.apk`.
- Parse changelog sections by header in `release.yml`.

## 13. Local-only files (never commit)

- `rules.md` and `rancangan.md` are local notes. They must NOT be pushed to
  the repository. Listed in `.gitignore`.
- Do not reference them from code, README, or release notes.

## 14. General writing rules

- Short sentences. Active voice. No jargon where a plain word works.
- Bold the lead-in of each bullet so the list scans fast.
- Prefer concrete numbers over vague words ("55-mission catalog", not "many missions").
- Keep the app lightweight: avoid new plugins or permissions when possible.
- Verify plugin APIs before use; CI is the only verification (no local Flutter SDK).