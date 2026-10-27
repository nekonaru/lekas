<div align="center">

# 📝 Lekas: Task & Deadline Tracker for Students

**Capture tasks from chat in 5 seconds, auto-organized per course, reminded on time.**

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?style=flat-square&logo=flutter&logoColor=white)
![Release](https://img.shields.io/github/v/release/nekonaru/lekas?style=flat-square&color=blue)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)
![CI](https://github.com/nekonaru/lekas/actions/workflows/build-apk.yml/badge.svg)

</div>

**English** | [Bahasa Indonesia](README.id.md)

## 📖 About

**Lekas** is an offline-first Android app for university students to capture tasks and deadlines, organized per course, with reliable local reminders. No account, no cloud, no collaboration: everything stays on your phone.

Type one line and the parser reads the deadline, the course and the priority. Swipe a card and it is done, with an undo waiting. The app works with the radio off.

## ✨ Features

| Feature | Description |
| --- | --- |
| 📚 Spaces | Courses and other containers with color, code, aliases for the parser, and notes for lecturer, room and link |
| ✅ Tasks | Type, deadline, priority, status, weight, estimate, individual or group, with subtasks and tags |
| ⚡ Quick Add | One field, Indonesian or English text, live chips for every value the parser guessed (design 6.1 and 7.15) |
| 🎙️ Voice Quick Add | Microphone in Quick Add and on its own screen, spoken numbers such as "jam tujuh" become a deadline |
| 🔔 Local reminders | H-3, H-1, 3 hours, 30 minutes, quiet hours from 22.00 to 06.00, plus morning, night and weekly summaries |
| 📅 Today screen | Urgency score with overdue, today and this week sections, plus an undo snackbar |
| 📲 Share intake | Text shared from WhatsApp or any app is split into candidates and parsed before saving |
| 🗓️ Calendar | Month and week views, class schedule, attendance with the campus passing grade (5.19) |
| 🎯 Focus mode | At most three tasks a day, focus timer, carry over what did not fit (5.24) |
| 🏠 Home widgets | Four Android widgets fed through `home_widget`, refreshed by a 400 ms debounce |
| 💾 Backup | JSON export and import, everything stored locally with Drift (SQLite) |
| 🌙 Display | Dark mode and two languages, Indonesian by default, English as an option |

## 🛠️ Requirements

- Android 7.0 (API 24) or newer to install the APK.
- Flutter 3.47.0 with Dart 3.13 to build from source.
- JDK 17 and Android SDK platform 37 for the Gradle build.
- About 100 MB on the phone for the app plus its database and attachments.

## 📥 Installation

### Option A: APK

Download the APK matching your device from the [Releases page](https://github.com/nekonaru/lekas/releases) (`app-arm64-v8a-release.apk` for most modern phones, `app-armeabi-v7a-release.apk` for older 32-bit ones). Open it on your phone and allow installs from unknown sources if asked.

### Option B: Build from source

```bash
git clone https://github.com/nekonaru/lekas.git
cd lekas
flutter pub get
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

The two APKs land in `build/app/outputs/flutter-apk/`.

## 🚀 Usage

1. **Quick Add**: open the drawer, tap *Quick Add Suara* for the microphone or *Tambah Tugas Cepat* for the keyboard.
2. **Type naturally**: `laprak basdat besok jam tujuh malam #kelompok` becomes a deadline, a course and a tag with chips you can remove.
3. **Share from chat**: share a WhatsApp message to Lekas, review the candidates, save them as tasks.
4. **Work from Today**: the top of the list is what burns now; swipe right to finish, swipe left to postpone, long press for multi select.
5. **Check the calendar**: month view, class schedule and attendance live one drawer tap away.

## 🌐 Display Language

Indonesian is the default. Open *Pengaturan* (Settings), tap *Bahasa*, and choose `Indonesia` or `English`. The choice is stored in the `settings` table under the key `language` and rebuilds the whole app through `localeProvider`; reminders, notifications and the parser follow it, so the parser reads English text when English is selected (design section 8.5).

## 📂 Project Structure

```text
lib/
  core/          theme, date helpers, scoring constants, shared components
  data/          Drift database, repositories, Riverpod providers, backup
  domain/        urgency score and focus rules
  features/      one folder per screen (home, today, quick_add, share_intake, ...)
  l10n/          app_id.arb, app_en.arb and the generated localizations
  parser/        normalizer, time extractor, matcher, dictionaries per language
  reminders/     reminder service, notification policy, digest summaries
  voice/         speech wrapper behind Voice Quick Add
test/            unit and widget tests, one *_test.dart per area
```

## 🧪 Testing

```bash
flutter analyze   # 0 issues
flutter test      # 325 tests
```

CI runs both on every push to `main` and builds the split APKs, so a green badge on the [Actions page](https://github.com/nekonaru/lekas/actions) means the release artifacts build.

## ❓ FAQ

**Does Lekas need internet?** No. Every screen, reminder and widget reads a local SQLite database. Internet is only used if you share text into the app from another app.

**Where is my data?** In the app database on the phone, plus whatever JSON file you export to *Cadangan* (Backup).

**Why did my reminder not fire?** Battery optimization or a killed background process is the usual cause. Open *Cek Pengingat* in the drawer, it runs the same checks the reminder service does.

**Can I type English?** Yes. The Quick Add parser merges both dictionaries and the active language wins conflicts, so `lab report db friday 11:59pm` and `laprak basdat jumat 23.59` land on the same fields.

## ✍️ Author

**Nicolas Dwi Dharma** ([@nekonaru](https://github.com/nekonaru))

## 📄 License

MIT. See [LICENSE](LICENSE).
