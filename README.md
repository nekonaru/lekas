<div align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="Lekas logo" width="120" />
  <h1>Lekas: Task & Deadline Tracker for Students</h1>
  <p><b>Track student tasks and deadlines offline-first,<br/>
  capture them from chat in 5 seconds, fully offline.</b></p>

  <a href="https://github.com/nekonaru/lekas/releases"><img src="https://img.shields.io/github/v/release/nekonaru/lekas?style=flat-square&color=blue" alt="Release" /></a>
  <a href="https://github.com/nekonaru/lekas/actions/workflows/build-apk.yml"><img src="https://github.com/nekonaru/lekas/actions/workflows/build-apk.yml/badge.svg" alt="CI" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.47-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square" alt="Status" />
</div>

<br />

**English** | [Bahasa Indonesia](README.id.md)

> [!NOTE]
> Lekas runs entirely on your phone. There is no account and no cloud: every screen, reminder and widget reads a local SQLite database, so the app keeps working with the radio off.

---

## Table of Contents

- [About](#about)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Display Language](#display-language)
- [Project Structure](#project-structure)
- [Development](#development)
- [Testing](#testing)
- [Security](#security)
- [Continuous Integration](#continuous-integration)
- [FAQ](#faq)
- [Author](#author)
- [Disclaimer](#disclaimer)
- [License](#license)

---

## About

**Lekas** is an offline-first Android app for university students to capture tasks and deadlines, organized per course, with reliable local reminders. No account, no cloud, no collaboration: everything stays on your phone.

Type one line and the parser reads the deadline, the course and the priority. Swipe a card and it is done, with an undo waiting. Share a message from a chat app and it becomes a list of candidate tasks before anything is saved.

> _"Your deadlines, captured in five seconds, even without internet."_

---

## Features

### Capture

| Feature | Description |
|---------|-------------|
| **Quick Add** | One field, Indonesian or English text, live chips for every value the parser guessed (design 6.1 and 7.15) |
| **Voice Quick Add** | Microphone in Quick Add and on its own screen; spoken numbers such as "jam tujuh" become a deadline |
| **Share intake** | Text shared from WhatsApp or any app is split into candidates and parsed before saving, nothing is stored automatically |

### Tasks and Spaces

| Feature | Description |
|---------|-------------|
| **Spaces** | Courses and other containers with color, code, aliases for the parser, and notes for lecturer, room and link |
| **Tasks** | Type, deadline, priority, status, weight, estimate, individual or group, with subtasks, tags and attachments |
| **Task dependencies** | Prerequisites per task; blocked tasks wait in their own section, a finished prerequisite sends one soft "ready to start" notice, and a save that would close a loop is refused |
| **Personal target and grade prediction** | A target date before the deadline, plus grade prediction inside a space |
| **Inbox and trash** | Quick capture without a course, and a trash that keeps deleted tasks restorable |

### Today and Focus

| Feature | Description |
|---------|-------------|
| **Today screen** | Urgency score with overdue, today, waiting and someday sections, plus an undo snackbar |
| **Smart actions** | Long press for multi select and bulk actions, swipe right to finish, swipe left to postpone |
| **Focus mode** | At most three tasks a day, a 25/5 focus timer, and what did not fit carries over (5.24) |

### Calendar and Classes

| Feature | Description |
|---------|-------------|
| **Calendar** | Month and week views, class schedule, attendance with the campus passing grade (5.19) |
| **Semester statistics** | Per-course statistics and a semester recap behind the drawer |

### Reminders

| Feature | Description |
|---------|-------------|
| **Local reminders** | H-3, H-1, 3 hours, 30 minutes, quiet hours from 22.00 to 06.00, plus morning, night and weekly summaries |
| **Overdue digest** | One notification a day at 09:00 listing every task that passed its deadline |
| **Reminder checker** | The Cek Pengingat screen runs the same checks as the reminder service when a notification seems missing |

### Widgets

| Feature | Description |
|---------|-------------|
| **Four home widgets** | Task list with checkboxes, today's classes, exam countdown, today's focus, fed through `home_widget` and refreshed by a 400 ms debounce |

### Data and Backup

| Feature | Description |
|---------|-------------|
| **Backup and restore** | JSON export and import, everything stored locally with Drift (SQLite) |
| **Import and merge** | Merge a backup into the current database without losing what is already there |

### Appearance and Language

| Feature | Description |
|---------|-------------|
| **English and Indonesian UI** | Indonesian by default; switch to English in Settings |
| **Themes** | Light, dark, or follow system |

---

## Requirements

| Dependency | Minimum Version | Notes |
|------------|-----------------|-------|
| **Flutter** | 3.47 | Stable channel, required only to build from source |
| **JDK** | 17 | Required only to build from source |
| **Android SDK** | API 37 | Required only to build from source |
| **Android device or emulator** | Android 7.0 (API 24) | Required to run the app |

> [!TIP]
> If you only want to use the app, you do not need Flutter, JDK, or the Android SDK. Download the APK from the [Releases](https://github.com/nekonaru/lekas/releases) page instead.

### Never used a terminal? Start here

<details>
<summary><b>How to open a terminal on Windows</b></summary>

1. Press the **Windows** key, type `PowerShell`, then press **Enter**
2. A blue window opens. That is where you type commands
3. Every `flutter ...` or `git ...` command in this guide is typed in that window, followed by **Enter**

</details>

---

## Installation

### Option A: Download the APK (easiest)

1. Open the [Releases](https://github.com/nekonaru/lekas/releases) page
2. Download the APK matching your device (`app-arm64-v8a-release.apk` for most modern phones, `app-armeabi-v7a-release.apk` for older 32-bit ones)
3. Open it on your phone, allow installs from unknown sources if asked

> [!IMPORTANT]
> Grant notification permission when the app first asks, otherwise reminders, summaries and the overdue digest cannot appear. Battery optimization should also be left unrestricted for Lekas.

### Option B: Build from source (for development / to read or change the code)

#### 1. Get the project code

<details>
<summary><b>I have Git installed</b></summary>

```bash
git clone https://github.com/nekonaru/lekas.git
cd lekas
```

</details>

<details>
<summary><b>I don't have Git</b></summary>

1. Open the repository page on GitHub
2. Click the green **`Code`** button, choose **`Download ZIP`**
3. Extract the ZIP to a folder of your choice
4. In the terminal, go into the extracted folder, for example:

```bash
cd Downloads/lekas-main
```

</details>

#### 2. Install dependencies and verify

```bash
flutter pub get
flutter analyze
```

> [!IMPORTANT]
> `flutter analyze` must report **No issues found**.

#### 3. Build the APKs

```bash
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

The two APKs land in `build/app/outputs/flutter-apk/`.

---

## Usage

### First launch

1. Allow notification permission when asked
2. Create a space for each course (color, code, alias for the parser), or skip and do it later
3. Type your first task in Quick Add

### Everyday use

- Type naturally: `laprak basdat besok jam tujuh malam #kelompok` becomes a deadline, a course and a tag with chips you can remove
- Share a message from a chat app to Lekas, review the candidates, save them as tasks
- Work from **Today**: the top of the list is what burns now; swipe right to finish, swipe left to postpone, long press for multi select
- Finish a prerequisite and the task waiting on it gets one soft notification that it can start
- Check the **Calendar**: month view, class schedule and attendance live one drawer tap away

---

## Display Language

The app UI (menus, buttons, messages, and settings) is available in **Bahasa Indonesia** (default) and **English**.

1. Open **Pengaturan** (Settings)
2. Under **Bahasa**, pick **Indonesia** or **English**
3. The choice is stored in the `settings` table under the key `language` and rebuilds the whole app through `localeProvider`; reminders, notifications and the parser follow it, so the parser reads English text when English is selected (design section 8.5)

---

## Project Structure

```
lekas/
├── lib/
│   ├── main.dart                 # entry point, providers, MaterialApp
│   ├── core/                     # theme, date helpers, scoring constants, shared components
│   ├── data/                     # Drift database, repositories, Riverpod providers, backup
│   ├── domain/                   # urgency score and focus rules
│   ├── features/                 # one folder per screen (home, today, quick_add, share_intake, ...)
│   ├── l10n/                     # app_id.arb, app_en.arb and the generated localizations
│   ├── lock/                     # app lock: PIN hash, service, unlock screen
│   ├── parser/                   # normalizer, time extractor, matcher, dictionaries per language
│   ├── reminders/                # reminder service, notification policy, digest summaries
│   └── voice/                    # speech wrapper behind Voice Quick Add
├── test/                         # unit and widget tests, one *_test.dart per area
├── tool/                         # logo generator, font subsetter, glyph auditor
├── l10n.yaml                     # localization config
├── .github/
│   └── workflows/
│       ├── build-apk.yml         # CI: build the split APKs on every push to main
│       └── release.yml           # CI: analyze, test, build and publish a release
├── ARCHITECTURE.md               # structure and conventions
├── CHANGELOG.md                  # release notes in English
├── CHANGELOG.id.md               # release notes in Bahasa Indonesia
├── pubspec.yaml
├── LICENSE
├── README.md                     # main documentation (English)
└── README.id.md                  # documentation (Bahasa Indonesia)
```

---

## Development

### Adding a new user-facing string

1. Add the key to `lib/l10n/app_id.arb` (Indonesian, the template) and `lib/l10n/app_en.arb` (English)
2. Run `flutter gen-l10n`
3. Use it via `AppLocalizations.of(context)!.yourKey`

> [!WARNING]
> The files `lib/l10n/app_localizations*.dart` are generated. Do not edit them by hand, change the `.arb` files and run `flutter gen-l10n` instead.

---

## Testing

Verification before every push, both must be clean:

```bash
flutter analyze
flutter test
```

| Check | Requirement |
|-------|-------------|
| `flutter analyze` | Must report **No issues found** (zero errors, zero warnings) |
| `flutter test` | Must pass the full suite (455 tests) |

Lints are enforced through `analysis_options.yaml` (flutter_lints plus `prefer_single_quotes`).

---

## Security

Lekas stores your data locally: tasks, spaces, settings and attachments live in a SQLite database through Drift, and the backup file you export is either plain JSON or AES-GCM encrypted with your password. The app makes no network calls of its own, ships no analytics, ads or crash reporting SDKs, and only requests notification, exact alarm, vibration, microphone and speech permission. An optional app lock keeps a salted SHA-256 hash of your PIN instead of the PIN itself.

> [!NOTE]
> Found a security issue? Report it through the private route in [`SECURITY.md`](SECURITY.md) so it can be fixed before it is published.

---

## Continuous Integration

| Workflow | Purpose |
|----------|---------|
| `build-apk.yml` | Build the split APKs on every push to main |
| `release.yml` | On a `v*` tag: check the tag against the pubspec version, analyze, test, build the split APKs, then publish the GitHub release with bilingual notes taken from `CHANGELOG.md` |

---

## FAQ

<details>
<summary><b>Does Lekas need internet?</b></summary>

No. Every screen, reminder and widget reads a local SQLite database. Internet is only used if you share text into the app from another app, or by the speech recognizer when you use Voice Quick Add.

</details>

<details>
<summary><b>Where is my data?</b></summary>

In the app database on the phone, plus whatever JSON file you export to *Cadangan* (Backup).

</details>

<details>
<summary><b>Why did my reminder not fire?</b></summary>

Battery optimization or a killed background process is the usual cause. Open *Cek Pengingat* in the drawer, it runs the same checks the reminder service does.

</details>

<details>
<summary><b>Can I type English?</b></summary>

Yes. The Quick Add parser merges both dictionaries and the active language wins conflicts, so `lab report db friday 11:59pm` and `laprak basdat jumat 23.59` land on the same fields.

</details>

---

## Author

<div align="center">

| [![Nicolas Dwi Dharma](https://github.com/nekonaru.png?size=100)](https://github.com/nekonaru) |
|:---:|
| **Nicolas Dwi Dharma** |
| [github.com/nekonaru](https://github.com/nekonaru) |

</div>

---

## Disclaimer

Lekas is an independent open-source project and is not affiliated with or endorsed by Google, WhatsApp, or Meta. Reminders, summaries and widgets depend on Android background policies, so battery optimization or a killed process can delay them; the *Cek Pengingat* screen exists to help you find the cause.

---

## License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.
