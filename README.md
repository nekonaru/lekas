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
| **Natural date phrases** | Understands bulan depan, akhir bulan, tahun depan and their English twins, with clamping at month and leap-year boundaries |
| **Share intake** | Text shared from WhatsApp or any app is split into candidates and parsed before saving, nothing is stored automatically |

### Tasks, Categories and Semesters

| Feature | Description |
|---------|-------------|
| **Categories** | Free-form containers you name anything (organization, committee, community); they keep color, tasks and their own manage actions, and an uncategorized row holds tasks without one |
| **Courses** | Spaces bound to a semester with attendance, an editable class schedule, a per course bring list, grade prediction and their own folder for files |
| **School (SMA) mode** | Level switch to School turns courses into subjects with a Kelas (10, 11 or 12) picked in the space form, shows it on the subject page, speaks subject wording everywhere (Manage Subjects, Subjects This Semester); demo data seeds a Matematika sample with scores |
| **Grade Book (SMA)** | Per-subject score log with live average (uses component weights when present), a green or red KKM verdict, and an editable KKM setting |
| **Report Card (SMA)** | Rapor screen on the Semester tab: every subject of the active semester with its average, KKM verdict and attendance count, the semester average up top, and one tap to share the report as text |
| **Semester** | Active-semester tab: hero with course count, task progress and overdue badge, the course list, other semesters one tap away; create, rename, activate and delete semesters (courses cascade, their tasks move to the Inbox) |
| **Tasks** | Type, deadline, priority, status, weight, estimate, individual or group, with subtasks, tags and attachments |
| **Task filters and grouping** | Category, status (not done or done) and sort (nearest or farthest deadline, recently created, highest priority) on one shared filter sheet; optionally grouped by category with per-group counts |
| **Global search** | One drawer entry searches tasks, flashcards, habits and subjects, with grouped results and one tap to the owning screen |
| **Daily review** | A shareable end-of-day recap of finished tasks, overdue work, focus minutes and habits |
| **Estimate accuracy** | Study Stats compares planned minutes with focus minutes actually recorded for those tasks |
| **Study streak** | A day counts when you finish a task, run a focus session or check a habit |
| **Break after focus** | A five minute break starts automatically after a focus session, with a skip button |
| **Files per course** | Modules, notes, papers and archives under a real folder tree stored directly in phone storage; each course gets its own subfolder, visible to any file manager |
| **Attendance per course** | Mark present, absent, excused or sick per meeting; every past record can be edited or deleted |
| **Bring list per course** | Editable, reorderable and checkable per course |
| **Task dependencies** | Prerequisites per task; blocked tasks wait in their own section, a finished prerequisite sends one soft "ready to start" notice, and a save that would close a loop is refused |
| **Personal target and grade prediction** | A target date before the deadline, plus grade prediction inside a space |
| **Inbox and trash** | Quick capture without a course (the Uncategorized row on the Categories tab), and a trash that keeps deleted tasks restorable |
| **Recurring tasks** | Daily, weekly, monthly or named weekdays; completing one in Today creates the next with the same rhythm |
| **Saved search views** | Save the current query, category, type, status and sort as a view and reopen it in one tap from Saved Views |
| **Quick links** | Your own drawer links to the sites you open every day (portal, e-learning, library), stored and opened through the platform channel |
| **Study plans** | One tap on an exam creates review tasks seven, three and one days before the deadline |
| **GPA projection** | College courses carry a numeric final grade and contribute to a semester GPA projection alongside the SMA report card |

### Today and Focus

| Feature | Description |
|---------|-------------|
| **Today screen** | Urgency score with overdue, today, waiting and someday sections, plus an undo snackbar; every card shows its category or course |
| **Smart actions** | Long press for multi select and bulk actions, swipe right to finish, swipe left to postpone |
| **Focus mode** | At most three tasks a day, an adjustable focus/break timer with an automatic break, and what did not fit carries over (5.24) |
| **Habit tracker** | Kebiasaan: check-off habits with a 7-day grid, long-press rest days that protect the streak, a 90-day check-in heatmap, an optional daily reminder with a chosen time and the weekly total in the drawer's Study section |
| **Flashcards on Today** | A dismissible banner on Today opens the deck whenever cards are due |

### Study

| Feature | Description |
|---------|-------------|
| **Flashcards** | A general deck plus one deck per subject with spaced repetition (SM-2); tap to flip, grade Again, Hard or Easy, due counts visible per deck, per-deck CSV share and import, an optional daily review reminder, and question-answer, cloze and multiple-choice cards |
| **Focus timer** | An adjustable work and break timer inside Focus mode that records every session, with a day-grouped session log and total minutes |
| **Study Stats** | Focus minutes today and this week, the day streak of completed tasks, a 14-day bar chart, a 90-day activity heatmap, focus per subject and flashcard totals |
| **CSV grade export** | Share a subject's score log as a CSV file for spreadsheets |
| **Week-over-week scorecard** | Study Stats compares this week with last week with colored deltas for focus minutes and tasks completed |
| **Weekly study goals** | Editable targets for tasks completed and focus minutes, with progress bars measured from your own data |

### Calendar and Classes

| Feature | Description |
|---------|-------------|
| **Calendar** | Month view with class and task markers; tap any day to see its agenda below: classes with times and rooms, tasks due, one tap to the full list or a task |
| **Class schedule** | Weekday grouped schedule with editable entries, rooms and kinds (lecture or lab), synced to the calendar markers |
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
| **Calendar export (.ics)** | Every open task becomes an all-day event and every weekly class becomes a recurring event; the file loads into Google Calendar, Apple Calendar, Outlook or any app that reads .ics |
| **Calendar import (.ics)** | A .ics file turns into inbox tasks, previewed before importing, capped at 500 events |
| **Spreadsheet export (.csv)** | Every task as a spreadsheet row with title, deadline, priority, status, space, weight and tags |
| **Spreadsheet import (.csv)** | Import a CSV with a title column; tags split by semicolons are created on the fly, capped at 1000 rows |
| **Backup and restore** | JSON export and import, everything stored locally with Drift (SQLite) |
| **Import and merge** | Merge a backup into the current database without losing what is already there |
| **Update check** | Settings shows the installed version; tap to check the latest GitHub release. A quiet once-a-day check runs on launch (disableable in Settings) and only speaks up when a newer version exists |
| **Support Lekas** | Sponsor links under Settings: GitHub Sponsors, Saweria, SociaBuzz and BagiBagi, all https, all opening via the platform channel |

### Appearance and Language

| Feature | Description |
|---------|-------------|
| **English and Indonesian UI** | Indonesian by default; switch to English in Settings |
| **Grouped Settings** | Settings opens with a brand header (mark, tagline, version chip) and grouped rounded cards with tinted icons: Appearance, Reminders, Backup, Tools, Shortcuts, School, Sponsors and About |
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
| `flutter test` | Must pass the full suite (602 tests) |

Lints are enforced through `analysis_options.yaml` (flutter_lints plus `prefer_single_quotes`).

---

## Security

Lekas stores your data locally: tasks, spaces, settings and attachments live in a SQLite database through Drift, and the backup file you export is plain JSON. The only network call the app makes is the optional update check against the public GitHub API, on your tap or once a day on launch (disableable in Settings), which sends nothing but the request itself. The app ships no analytics, ads or crash reporting SDKs, and only requests notification, exact alarm, vibration, microphone and speech permission. An optional app lock keeps a salted SHA-256 hash of your PIN instead of the PIN itself.

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
