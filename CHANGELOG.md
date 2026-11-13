# Changelog

All notable changes to Lekas. Newest version on top.

## v1.12.0

Lekas swaps the Inbox tab for a Categories tab, makes the calendar a working agenda, stores course files on your phone, and manages attendance and the bring list per course.

### New features

- **Categories tab.** The Inbox tab is gone; in its place sits Kategori, free-form containers named however you want (organizations, committees, communities), plus an uncategorized row at the top of the list for tasks without a category.
- **Files per course.** Each course keeps modules, notes, papers, archives and folders inside a real tree on your phone storage. Pick the folder once; every course gets a Lekas folder with its own subfolders; no file ever leaves the phone.
- **Semester tab carries Mata Kuliah.** Manage the courses of the active semester from the Semester tab; free containers live under Kategori.
- **The calendar is a real agenda.** Class times and tasks for the selected day are listed under the month grid; tap any entry or any day cell, see all tasks of a busy day, check tasks off, or dive into a course.
- **Fuller attendance.** Mark present, absent, excused or sick per meeting; every past record can be edited or deleted from the course's attendance screen.
- **Bring list per course.** The bring list is per course, editable, reorderable and checkable item by item.

### Improvements

- **Today shows the owner.** Every card in the Today list carries its category or course name in the subtitle.
- **Class schedule meets the calendar.** Class days glow in the month grid, and the schedule screen is rebuilt around grouped weekday cards with inline edit and delete.
- **One roof per course.** Attendance, the bring list, the class schedule, files and grade prediction all live inside a course's detail screen.
- **Selection bars stay below.** Bulk action bars dock to the bottom, consistent across Today, Inbox, Categories and Tasks.

### Bug fixes

- **No more controller crashes on dialog close.** Text field controllers are disposed after the closing animation instead of cutting it off.
- **Dead screens removed.** Nine placeholder screens and the old categories helper were never wired to anything and are gone for good.

## v1.11.0

Lekas can now check for a newer release on its own: Settings shows the installed version, asks GitHub on tap, and a quiet once a day check speaks up only when a newer APK exists.

### New features

- **Update check.** The Settings version tile checks the latest GitHub release on tap; when a newer one exists it offers the direct arm64 APK download or the release page. A quiet once a day check runs on launch with a single snackbar and a Download action, disableable in Settings.
- **One request, nothing more.** The check is a read-only GET against the public GitHub releases API; no data is sent, there is no account, analytics or telemetry, and turning it off leaves the app fully offline as before.

### Improvements

- **Shared filter building blocks.** The filter sheet and the search screen now share the status chips and the sort order list, so the two cannot drift apart again.

## v1.10.0

Lekas replaces the Categories tab with a Semester tab, puts a filter system and category grouping on the task lists, and fixes the layout bugs in the task sheet and the tab screens.

### New features

- **Semester tab.** The category tab is now Semester: an active-semester hero with course count, task progress and an overdue badge, the course list below it, and every other semester one tap away. Creating, renaming, activating and deleting a semester all live there; existing spaces keep their period, which becomes their semester on upgrade.
- **Task category filters.** Task lists can filter by category, status (not done or done) and sort order (nearest deadline, farthest deadline, recently created, highest priority) through one shared sheet; Search & Filter gained the same status and sort controls.
- **Group by category.** The task list switches between a flat list and groups by category, with per-group counts, so one course's tasks sit together.
- **Inbox searchable.** Global search now includes Inbox tasks; a task captured there is visible to every search.

### Improvements

- **One app bar per tab.** The duplicate header on every tab is gone; the shell owns the single bar, selection mode moved to a bottom action bar, and the calendar's month navigation and weekday labels live in the body.
- **Task sheet fits the screen.** The add-task sheet scrolls, clears the keyboard, and the priority control is a full width segmented button; the deadline row lost the floating clear icon for a labeled button.
- **Flat calmer design.** The notification permission banner sits on a soft surface tint instead of the dark red card; deadline and priority labels use the section style.

### Bug fixes

- **Add task sheet no longer overflows** with long labels or a small screen; the priority row no longer runs off the edge.
- **Double add button.** Today and the shell each carried an add action; the shell's is gone and the floating button stays.
- **Semester-safe backups.** A backup written before this release is repaired on import: an empty or active-less semester table gets a default active semester, so the Semester tab never opens empty.

## v1.9.0

Lekas renames spaces to categories, adds deadlines with time, asks for notification permissions, and polishes the flat brand theme.

### New features

- **Categories everywhere.** The whole app now calls courses and containers categories in EN and Kategori in ID, in text, tests and docs.
- **Deadlines with time.** Tasks can carry a deadline with time, picked with chips right on the deadline row, so reminders fire at the exact minute.
- **Notification permissions asked once.** After setup, Lekas asks for notifications and exact alarms the first time it runs, so reminders can actually fire; the flag lives in settings and the system dialog never appears on every launch.

### Improvements

- **Flat brand theme.** Cards, chips, buttons and snackbars follow one radius and palette: indigo primaries, soft containers, no card border, tighter typography scale.

## v1.8.0

Lekas adds an archived spaces list, permanent space delete, grouped drawer sections and a tidier spacing scale.

### New features

- **Archived spaces list.** The Wadah tab switches between Active and Archive with a segmented control. Archived rows wait there with one tap restore or permanent delete, and an empty state explains what the list is for.
- **Delete spaces for good.** A three-dot menu on each space, the archive list and the detail screen now offer delete with a confirm dialog: its schedule, attendance, notes, grade components and checklist are removed with it, and its tasks move to the Inbox instead of disappearing.
- **Grouped drawer.** The flat drawer is grouped into labeled sections: tasks first, then data tools (backups and the reminder checker), then housekeeping.

### Improvements

- **One spacing scale.** Padding and margins follow multiples of four through the theme, cards use one radius, and the typography scale is explicit in both modes.

## v1.7.0

Lekas adds a PIN app lock and tap to manage calendar days.

### New features

- **App lock.** A four to six digit PIN (set in Settings, App Lock) gates the app whenever it comes back to the foreground. Only a salted hash is stored, so no PIN ever sits in the database. Changing and disabling always ask for the current PIN first.
- **Calendar day actions.** Tapping any day opens its due tasks, which can be ticked off and managed in bulk like every other list. Today is highlighted with the dot that marks days with tasks.

## v1.6.0

Lekas adds bulk selection everywhere, drag to reorder, a level switch, and a refreshed interface.

### New features

- **Bulk select everywhere.** Long press any task row in Inbox, Tasks, Search, Trash or Spaces to select it and run the same actions as Today (complete, priority, move, delete) plus select all. Trash adds bulk restore, Spaces adds bulk archive.
- **Edit spaces, delete tasks.** Spaces can be renamed and edited from the list or the detail screen, tasks can be deleted from the detail screen, all with undo. Spaces and subtasks also drag into your own order, saved between launches.
- **Level switch without reinstall.** Settings has a Level row (College/School) that applies to every space at once. The level chosen at setup is remembered, and space detail shows it as a readable label.
- **Refreshed interface.** Brand gradient bands carry the logo in the drawer and setup, add buttons are extended, empty lists use one illustrated state, and the tab title crossfades between destinations.

### Bug fixes

- **Undo banner clears on time.** The banner now shows once for five seconds, and a new one replaces the old instead of queueing behind it.
- **Task edit keeps its state.** Editing no longer reopens done tasks or unpins pinned ones, the container list loads the spaces, and a past deadline stays pickable.
- **Old backups import.** Space rows from pre-v1.6.0 backups without a drag order import with the default order.
- **Old databases upgrade to schema 4.** The spaces drag order column migrates cleanly: existing data and indexes are preserved.

## v1.5.1

Lekas refreshes the app icon from a bolt to a bold check.

### New features

- **Refreshed app icon.** The bolt is replaced with a bold white check on the same indigo to violet gradient, including the launcher icon, the rounded and adaptive variants, and the in app logo. The check stays clear at small sizes.

## v1.5.0

Lekas ships a new logo, a refined theme and smoother, lighter lists.

### New features

- **New app logo.** A white bolt on an indigo to violet gradient now marks the launcher icon, the onboarding screen and the navigation drawer, with round and adaptive variants for older and newer Android versions.
- **Polished interface.** Bars, cards, the bottom bar and task rows share one refined theme: flatter app bars, outlined cards, filled icons on the open tab, and a ringed priority dot on every task row.
- **Smooth list animations.** Cards on Today and Inbox fade and slide in with a short stagger, and the setup screen shows a stretching step indicator. All animations finish quickly and leave no layer behind, so scrolling stays light.

### Improvements

- **Smaller download.** The unused Cupertino icon font is removed and the bundled Inter fonts are subset to the glyphs the app uses, which cuts the bundled font data by over 1 MB.
- **Lighter lists.** Settled rows return their child without an extra opacity layer, so long lists stay cheap to draw.

## v1.4.2

Lekas fixes the black screen after setup and makes the language choice respond.

### Bug fixes

- **No more black screen after setup.** Finishing the first run popped the root route, which emptied the navigator and left the screen black on real devices. The setup now hands over to the home screen in place, with no empty frame in between.
- **The setup language choice responds.** The language and level buttons now show which option is picked (filled with a check) and crossfade between states, and the picked language applies immediately instead of only at the last step.

## v1.4.1

Lekas fixes the release crash caused by the shrinker stripping WorkManager classes.

### Bug fixes

- **No more force close on launch.** The release shrinker stripped the WorkManager database classes that Android initializes before the first frame, so the release APK died the moment it opened on real devices while debug builds kept working. The classes are now preserved, and the app opens normally.

## v1.4.0

Lekas adds one tap theme presets and hero transitions into task detail.

### New features

- **Theme presets.** One tap applies a whole look: Midnight switches to a dark deep indigo, Sunset warms the app orange, Forest cools it emerald, and Default returns everything to the built in style.
- **Light and dark preview.** The accent picker shows what each seed produces in both brightnesses before you commit to it, with swatches drawn from the real generated palette.

### Improvements

- **Hero transitions.** Opening a task from Today carries its title into the detail screen and back as one continuous motion.
- **Safer transitions.** Only the Today list opts into hero flights, so screens that stack over each other can never collide on a shared tag.

## v1.3.0

Lekas adds accent colors, four font sizes and bundled Inter typography.

### New features

- **Accent color.** Pick the color of the whole app in Settings: twelve curated seeds plus the built in indigo, applied to every screen and control at once.
- **Font size.** Four text sizes that multiply the phone's own accessibility scale, so the system setting keeps working underneath.
- **Inter typography.** The app ships the Inter typeface in four weights, giving headings, cards and chips a distinct tidy voice.

### Improvements

- **Scroll aware add button.** The add button slides away while scrolling down and returns on the first upward scroll.
- **Section counts.** Every Today section header shows how many tasks sit in it as a quiet pill.
- **Gentle entrances.** The empty Today screen fades and scales in once instead of popping.
- **Leaner rebuilds.** Cards receive their urgency score precomputed, and lists skip automatic keep alives.

## v1.2.0

Lekas shares one smooth motion across the interface and makes long lists lighter to draw.

### Improvements

- **Shared motion.** Tab switches, page pushes and card actions now use one easing curve and timing, so every movement reads as the same calm motion.
- **Selection animation.** Marking a task in multi select crossfades the check over the priority dot instead of swapping it instantly.
- **Modern surfaces.** Cards, snackbars, dialogs, sheets and form fields follow one Material 3 shape language, and every modal sheet gains a drag handle.
- **Calmer drawer.** The drawer opens with a compact branded header instead of a full grey block.
- **Friendlier empty state.** An empty Today screen shows a tinted check icon and a centered title instead of a grey glyph.
- **Lighter lists.** The urgency score sits in a quiet pill, the swipe reveal is rounded like the cards, and the last task scrolls clear of the action button.

## v1.1.0

Lekas adds task dependencies and smarter Quick Add and pulls finished screens into the menus.

### New features

- **Task dependencies.** A task can require other tasks to be finished first: blocked tasks wait in their own section, a finished prerequisite sends one "ready to start" notice, and a save that would close a loop is refused.
- **Finished screens in the menus.** Spaces, calendar, statistics, backup, trash and the reminder checker are reachable from the drawer and settings.
- **Clipboard paste in share intake.** Several clipboard lines become one candidate per line, added only when tapped.
- **Repeat chip in Quick Add.** One tap copies the space, type and deadline time from the last task.
- **Similar task suggestions.** A title close to an older task offers that task's subtasks and estimate as chips.

### Bug fixes

- **Reopen from the detail screen.** Reopening a finished task from its detail page works again.
- **Drawer closes before navigation.** Opening a screen from the home drawer no longer leaves the drawer behind it.
- **Trash back button.** The trash screen can be closed with a back arrow like every other screen.

## v1.0.1

Lekas starts on the home screen, keeps the Today list light, and fixes a batch of update time crashes.

### Improvements

- **Home screen first.** The app now draws the home screen immediately and fills the reminder schedule behind it, instead of opening on a spinner every time.
- **Only visible cards built.** The Today list lays out one card at a time, so a long list stays smooth and every tap no longer rebuilds the whole screen.
- **One stream per query.** Every watch call reuses a single query stream, so the refresh spinner stops flickering and the database stops re-querying on each rebuild.

### Bug fixes

- **No crash after an update.** The reboot and app update receiver now logs a failed reminder reschedule instead of taking the whole app down with it.
- **Deleted space cannot crash the filter.** Searching while the filtered space is deleted keeps the list open instead of throwing.
- **Permanent delete cleans up.** Deleting a task for good also removes its subtasks, tags, attachments, reminders and other child rows.
- **Readable dates in the task list.** The subtitle shows a formatted date instead of a raw timestamp down to the milliseconds.
- **Task detail scrolls.** The detail screen scrolls on short screens and in landscape, and long badges wrap instead of running off the edge.
- **Late counts whole days.** A task due yesterday reads "1 day late" instead of "0".
- **Start up survives a bad stored route.** A route that cannot be read at launch falls back to the home screen instead of crashing.
- **Late writes cannot touch a closed screen.** Three pickers in settings and Quick Add now stop when the screen is already gone.

## v1.0.0

Lekas ships its first public release with Quick Add, offline reminders, Today, widgets and bilingual support.

### New features

- **Quick Add parser.** One line of Indonesian or English becomes a deadline, course, priority, tag, subtasks, estimate and links, each shown as a chip you can keep or throw away (design 6.1 and 7.15).
- **Voice Quick Add.** A microphone sits in Quick Add and on its own screen, and spoken numbers such as "jam tujuh malam" turn into a deadline (design 7.1).
- **Local reminders.** H-3, H-1, 3 hours and 30 minutes before a deadline, quiet hours from 22.00 to 06.00, plus morning, night and weekly summaries (design 5.4 and 5.22).
- **Today screen.** Urgency score with overdue, today and this week sections, swipe right to finish with undo, swipe left to postpone, long press for multi select (design 5.2 and 5.6).
- **Share intake.** Text shared from WhatsApp or any other app is split into candidates and parsed before it becomes tasks (design 6.2).
- **Four home screen widgets.** Exam countdown, today list, quick add button and next class, all fed through `home_widget` (design 7.8).
- **Attendance and focus.** Class attendance with the campus passing grade, absence quota warnings, and a focus mode capped at three tasks a day (design 5.19 and 5.24).
- **Two languages and dark mode.** Indonesian by default, English as an option, both in the interface and in the parser (design section 8).

### Improvements

- **Digest rebuilt on sync.** Morning, night and weekly summaries refresh when the app opens, the phone boots or a task changes, instead of waiting for a timer.
- **Widget refresh debounced.** A 400 ms debounce plus a 30 minute period keeps the launcher cheap while the data stays current.
- **Reminder budget.** A daily notification budget and quiet hours keep the phone from buzzing through the night.

### Bug fixes

- **Holidays clear the whole day.** A public holiday now skips every class of that day, not only the first slot.
- **Month names keep their day.** "25 oktober" and "october 25" land on the 25th instead of falling back to the end of the month.
