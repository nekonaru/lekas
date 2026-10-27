# Changelog

All notable changes to Lekas. Newest version on top.

## v1.0.0 - First public release

### New features

- **Quick Add parser.** One line of Indonesian or English becomes a deadline, course, priority, tag, subtasks, estimate and links, each shown as a chip you can keep or throw away (design 6.1 and 7.15).
- **Voice Quick Add.** A microphone sits in Quick Add and on its own screen, and spoken numbers such as "jam tujuh malam" turn into a deadline (design 7.1).
- **Local reminders.** H-3, H-1, 3 hours and 30 minutes before a deadline, quiet hours from 22.00 to 06.00, plus morning, night and weekly summaries (design 5.4 and 5.22).
- **Today screen.** Urgency score with overdue, today and this week sections, swipe right to finish with undo, swipe left to postpone, long press for multi select (design 5.2 and 5.6).
- **Share intake.** Text shared from WhatsApp or any other app is split into candidates and parsed before it becomes tasks (design 6.2).
- **Four home screen widgets.** Exam countdown, today list, quick add button and next class, all fed through `home_widget` (design 7.8).
- **Attendance and focus.** Class attendance with the campus passing grade, absence quota warnings, and a focus mode capped at three tasks a day (design 5.19 and 5.24).
- **Two languages and dark mode.** Indonesian by default, English as an option, both in the interface and in the parser (design section 8).

### Optimizations

- **Digest rebuilt on sync.** Morning, night and weekly summaries refresh when the app opens, the phone boots or a task changes, instead of waiting for a timer.
- **Widget refresh debounced.** A 400 ms debounce plus a 30 minute period keeps the launcher cheap while the data stays current.
- **Reminder budget.** A daily notification budget and quiet hours keep the phone from buzzing through the night.

### Bug fixes

- **Holidays clear the whole day.** A public holiday now skips every class of that day, not only the first slot.
- **Month names keep their day.** "25 oktober" and "october 25" land on the 25th instead of falling back to the end of the month.

### Install / Update

Download the APK matching your device below (`app-arm64-v8a-release.apk` for most modern phones, `app-armeabi-v7a-release.apk` for older 32-bit ones). Open it on your phone and allow installs from unknown sources if asked. Minimum Android 7.0 (API 24).
