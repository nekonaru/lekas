import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @todayTitle.
  ///
  /// In id, this message translates to:
  /// **'Hari Ini'**
  String get todayTitle;

  /// No description provided for @tasksCount.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas'**
  String tasksCount(int count);

  /// No description provided for @inboxTitle.
  ///
  /// In id, this message translates to:
  /// **'Inbox'**
  String get inboxTitle;

  /// No description provided for @spacesTitle.
  ///
  /// In id, this message translates to:
  /// **'Wadah'**
  String get spacesTitle;

  /// No description provided for @calendarTitle.
  ///
  /// In id, this message translates to:
  /// **'Kalender'**
  String get calendarTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @quickAddHint.
  ///
  /// In id, this message translates to:
  /// **'Tambah tugas cepat...'**
  String get quickAddHint;

  /// No description provided for @emptyToday.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tugas hari ini. Nikmati waktumu, atau rencanakan besok?'**
  String get emptyToday;

  /// No description provided for @undo.
  ///
  /// In id, this message translates to:
  /// **'Urungkan'**
  String get undo;

  /// No description provided for @done.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get done;

  /// No description provided for @snooze1h.
  ///
  /// In id, this message translates to:
  /// **'Tunda 1 jam'**
  String get snooze1h;

  /// No description provided for @morningSummary.
  ///
  /// In id, this message translates to:
  /// **'Hari ini: {classes} kelas, {tasks} tugas.'**
  String morningSummary(int classes, int tasks);

  /// No description provided for @addSpace.
  ///
  /// In id, this message translates to:
  /// **'Tambah Wadah'**
  String get addSpace;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @spaceName.
  ///
  /// In id, this message translates to:
  /// **'Nama wadah'**
  String get spaceName;

  /// No description provided for @spaceCode.
  ///
  /// In id, this message translates to:
  /// **'Kode (opsional)'**
  String get spaceCode;

  /// No description provided for @taskTitle.
  ///
  /// In id, this message translates to:
  /// **'Judul Tugas'**
  String get taskTitle;

  /// No description provided for @taskNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get taskNotes;

  /// No description provided for @taskContainer.
  ///
  /// In id, this message translates to:
  /// **'Wadah'**
  String get taskContainer;

  /// No description provided for @taskDeadline.
  ///
  /// In id, this message translates to:
  /// **'Deadline'**
  String get taskDeadline;

  /// No description provided for @taskPriority.
  ///
  /// In id, this message translates to:
  /// **'Prioritas'**
  String get taskPriority;

  /// No description provided for @priorityLow.
  ///
  /// In id, this message translates to:
  /// **'Rendah'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In id, this message translates to:
  /// **'Tinggi'**
  String get priorityHigh;

  /// No description provided for @pickDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get pickDate;

  /// No description provided for @addTask.
  ///
  /// In id, this message translates to:
  /// **'Tambah Tugas'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In id, this message translates to:
  /// **'Edit Tugas'**
  String get editTask;

  /// No description provided for @taskDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Tugas'**
  String get taskDetail;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get darkMode;

  /// No description provided for @exportBackup.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Cadangan JSON'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In id, this message translates to:
  /// **'Impor Cadangan JSON'**
  String get importBackup;

  /// No description provided for @checkReminder.
  ///
  /// In id, this message translates to:
  /// **'Cek Pengingat'**
  String get checkReminder;

  /// No description provided for @welcome.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang'**
  String get welcome;

  /// No description provided for @addFirstSpace.
  ///
  /// In id, this message translates to:
  /// **'Tambah Matkul Pertama'**
  String get addFirstSpace;

  /// No description provided for @start.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get start;

  /// No description provided for @back.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;

  /// No description provided for @saveContinue.
  ///
  /// In id, this message translates to:
  /// **'Simpan & Lanjut'**
  String get saveContinue;

  /// No description provided for @finish.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get finish;

  /// No description provided for @chooseLanguage.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa'**
  String get chooseLanguage;

  /// No description provided for @indonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;

  /// No description provided for @english.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chooseLevel.
  ///
  /// In id, this message translates to:
  /// **'Pilih Jenjang'**
  String get chooseLevel;

  /// No description provided for @college.
  ///
  /// In id, this message translates to:
  /// **'Kuliah'**
  String get college;

  /// No description provided for @school.
  ///
  /// In id, this message translates to:
  /// **'SMA'**
  String get school;

  /// No description provided for @spaceNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Matkul'**
  String get spaceNameLabel;

  /// No description provided for @inboxCount.
  ///
  /// In id, this message translates to:
  /// **'{count} catatan belum dirapikan.'**
  String inboxCount(int count);

  /// No description provided for @reminderIn7Days.
  ///
  /// In id, this message translates to:
  /// **'Deadline 7 hari lagi'**
  String get reminderIn7Days;

  /// No description provided for @reminderIn3Days.
  ///
  /// In id, this message translates to:
  /// **'Deadline 3 hari lagi'**
  String get reminderIn3Days;

  /// No description provided for @reminderIn1Day.
  ///
  /// In id, this message translates to:
  /// **'Deadline besok'**
  String get reminderIn1Day;

  /// No description provided for @reminderIn3Hours.
  ///
  /// In id, this message translates to:
  /// **'Deadline 3 jam lagi'**
  String get reminderIn3Hours;

  /// No description provided for @reminderIn30Minutes.
  ///
  /// In id, this message translates to:
  /// **'Deadline 30 menit lagi'**
  String get reminderIn30Minutes;

  /// No description provided for @reminderSnoozed.
  ///
  /// In id, this message translates to:
  /// **'Pengingat ditunda 1 jam'**
  String get reminderSnoozed;

  /// No description provided for @testNotificationTitle.
  ///
  /// In id, this message translates to:
  /// **'Tes pengingat'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In id, this message translates to:
  /// **'Bila kamu membaca ini, pengingat berfungsi.'**
  String get testNotificationBody;

  /// No description provided for @testNotification.
  ///
  /// In id, this message translates to:
  /// **'Tes notifikasi 1 menit'**
  String get testNotification;

  /// No description provided for @notifPermission.
  ///
  /// In id, this message translates to:
  /// **'Izin notifikasi'**
  String get notifPermission;

  /// No description provided for @exactAlarmPermission.
  ///
  /// In id, this message translates to:
  /// **'Izin alarm presisi'**
  String get exactAlarmPermission;

  /// No description provided for @batteryOptimization.
  ///
  /// In id, this message translates to:
  /// **'Penghemat baterai'**
  String get batteryOptimization;

  /// No description provided for @statusGranted.
  ///
  /// In id, this message translates to:
  /// **'Diizinkan'**
  String get statusGranted;

  /// No description provided for @statusDenied.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get statusDenied;

  /// No description provided for @statusUnknown.
  ///
  /// In id, this message translates to:
  /// **'Tidak diketahui'**
  String get statusUnknown;

  /// No description provided for @openSystemSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan sistem'**
  String get openSystemSettings;

  /// No description provided for @testHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat tes'**
  String get testHistory;

  /// No description provided for @batteryGuide.
  ///
  /// In id, this message translates to:
  /// **'Beberapa merek seperti Xiaomi, Oppo, Realme, dan Samsung menahan notifikasi aplikasi di latar belakang. Matikan penghemat baterai untuk Lekas supaya pengingat selalu sampai.'**
  String get batteryGuide;

  /// No description provided for @reminderCheckHint.
  ///
  /// In id, this message translates to:
  /// **'Jalankan tes di bawah, lalu lihat apakah notifikasi masuk dalam satu menit.'**
  String get reminderCheckHint;

  /// No description provided for @permissionExplain.
  ///
  /// In id, this message translates to:
  /// **'Lekas butuh izin notifikasi supaya pengingat deadline sampai ke HP-mu.'**
  String get permissionExplain;

  /// No description provided for @allow.
  ///
  /// In id, this message translates to:
  /// **'Izinkan'**
  String get allow;

  /// No description provided for @notNow.
  ///
  /// In id, this message translates to:
  /// **'Nanti'**
  String get notNow;

  /// No description provided for @backupTitle.
  ///
  /// In id, this message translates to:
  /// **'Cadangan Data'**
  String get backupTitle;

  /// No description provided for @exportedTo.
  ///
  /// In id, this message translates to:
  /// **'Diekspor ke: {path}'**
  String exportedTo(String path);

  /// No description provided for @importedTasks.
  ///
  /// In id, this message translates to:
  /// **'Diimpor: {count} tugas'**
  String importedTasks(int count);

  /// No description provided for @autoBackupFolder.
  ///
  /// In id, this message translates to:
  /// **'Pilih Folder Cadangan Otomatis'**
  String get autoBackupFolder;

  /// No description provided for @autoBackupFolderHint.
  ///
  /// In id, this message translates to:
  /// **'Untuk cadangan mingguan otomatis'**
  String get autoBackupFolderHint;

  /// No description provided for @folderPicked.
  ///
  /// In id, this message translates to:
  /// **'Folder: {path}'**
  String folderPicked(String path);

  /// No description provided for @shareAsTextTitle.
  ///
  /// In id, this message translates to:
  /// **'Bagikan sebagai Teks'**
  String get shareAsTextTitle;

  /// No description provided for @shareAsTextBody.
  ///
  /// In id, this message translates to:
  /// **'Bagikan tugas atau daftar mingguan ke WhatsApp.'**
  String get shareAsTextBody;

  /// No description provided for @taskDependenciesTitle.
  ///
  /// In id, this message translates to:
  /// **'Dependensi Tugas'**
  String get taskDependenciesTitle;

  /// No description provided for @taskDependenciesBody.
  ///
  /// In id, this message translates to:
  /// **'Tugas yang menunggu tugas lain selesai.'**
  String get taskDependenciesBody;

  /// No description provided for @importScheduleOcrTitle.
  ///
  /// In id, this message translates to:
  /// **'Impor Jadwal dari Tangkapan Layar'**
  String get importScheduleOcrTitle;

  /// No description provided for @importScheduleOcrBody.
  ///
  /// In id, this message translates to:
  /// **'Impor jadwal KRS dari tangkapan layar atau teks portal.'**
  String get importScheduleOcrBody;

  /// No description provided for @weeklyLoadMapTitle.
  ///
  /// In id, this message translates to:
  /// **'Peta Beban Mingguan'**
  String get weeklyLoadMapTitle;

  /// No description provided for @weeklyLoadMapBody.
  ///
  /// In id, this message translates to:
  /// **'Peta beban mingguan dan jam efektif tersedia.'**
  String get weeklyLoadMapBody;

  /// No description provided for @projectMilestoneTitle.
  ///
  /// In id, this message translates to:
  /// **'Proyek dan Milestone'**
  String get projectMilestoneTitle;

  /// No description provided for @projectMilestoneBody.
  ///
  /// In id, this message translates to:
  /// **'Manajemen proyek dengan milestone dan rencana mundur.'**
  String get projectMilestoneBody;

  /// No description provided for @freeTimeSuggestionTitle.
  ///
  /// In id, this message translates to:
  /// **'Saran Waktu Kosong'**
  String get freeTimeSuggestionTitle;

  /// No description provided for @freeTimeSuggestionBody.
  ///
  /// In id, this message translates to:
  /// **'Saran celah waktu untuk fokus belajar.'**
  String get freeTimeSuggestionBody;

  /// No description provided for @gradeSimulatorTitle.
  ///
  /// In id, this message translates to:
  /// **'Simulator Nilai'**
  String get gradeSimulatorTitle;

  /// No description provided for @gradeSimulatorBody.
  ///
  /// In id, this message translates to:
  /// **'Simulator nilai \"bagaimana jika\".'**
  String get gradeSimulatorBody;

  /// No description provided for @examStudyPlanTitle.
  ///
  /// In id, this message translates to:
  /// **'Rencana Belajar Ujian'**
  String get examStudyPlanTitle;

  /// No description provided for @examStudyPlanBody.
  ///
  /// In id, this message translates to:
  /// **'Rencana belajar otomatis untuk ujian.'**
  String get examStudyPlanBody;

  /// No description provided for @taskListTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar Tugas'**
  String get taskListTitle;

  /// No description provided for @taskListBody.
  ///
  /// In id, this message translates to:
  /// **'Daftar tugas.'**
  String get taskListBody;

  /// No description provided for @timerFocusTitle.
  ///
  /// In id, this message translates to:
  /// **'Timer Fokus'**
  String get timerFocusTitle;

  /// No description provided for @timerFocusBody.
  ///
  /// In id, this message translates to:
  /// **'Timer fokus 25/5 menit (Pomodoro).'**
  String get timerFocusBody;

  /// No description provided for @encryptedBackupTitle.
  ///
  /// In id, this message translates to:
  /// **'Cadangan Terenkripsi'**
  String get encryptedBackupTitle;

  /// No description provided for @enableBackupEncryption.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Enkripsi Cadangan'**
  String get enableBackupEncryption;

  /// No description provided for @backupEncryptionMethod.
  ///
  /// In id, this message translates to:
  /// **'AES-GCM dengan kata sandi'**
  String get backupEncryptionMethod;

  /// No description provided for @passwordWarning.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get passwordWarning;

  /// No description provided for @passwordLostWarning.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi yang hilang berarti cadangan tidak bisa dibuka.'**
  String get passwordLostWarning;

  /// No description provided for @voiceQuickAddTitle.
  ///
  /// In id, this message translates to:
  /// **'Quick Add Suara'**
  String get voiceQuickAddTitle;

  /// No description provided for @voiceQuickAddHint.
  ///
  /// In id, this message translates to:
  /// **'Tekan mikrofon untuk berbicara tugas'**
  String get voiceQuickAddHint;

  /// No description provided for @startRecording.
  ///
  /// In id, this message translates to:
  /// **'Mulai Rekaman'**
  String get startRecording;

  /// No description provided for @defaultChecklistTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar Bawaan per Matkul'**
  String get defaultChecklistTitle;

  /// No description provided for @checklistLaptop.
  ///
  /// In id, this message translates to:
  /// **'Laptop'**
  String get checklistLaptop;

  /// No description provided for @checklistLanCable.
  ///
  /// In id, this message translates to:
  /// **'Kabel LAN'**
  String get checklistLanCable;

  /// No description provided for @checklistPrintReport.
  ///
  /// In id, this message translates to:
  /// **'Laprak Cetak'**
  String get checklistPrintReport;

  /// No description provided for @demoModeTitle.
  ///
  /// In id, this message translates to:
  /// **'Mode Demo'**
  String get demoModeTitle;

  /// No description provided for @trySampleData.
  ///
  /// In id, this message translates to:
  /// **'Coba dengan Data Contoh'**
  String get trySampleData;

  /// No description provided for @trySampleDataSubtitle.
  ///
  /// In id, this message translates to:
  /// **'3 matkul, 8 tugas, jadwal contoh'**
  String get trySampleDataSubtitle;

  /// No description provided for @deleteSampleData.
  ///
  /// In id, this message translates to:
  /// **'Hapus Data Contoh'**
  String get deleteSampleData;

  /// No description provided for @deleteSampleDataSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus semua data contoh'**
  String get deleteSampleDataSubtitle;

  /// No description provided for @fullCalendarTitle.
  ///
  /// In id, this message translates to:
  /// **'Kalender Lengkap'**
  String get fullCalendarTitle;

  /// No description provided for @tabMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan'**
  String get tabMonth;

  /// No description provided for @tabWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get tabWeek;

  /// No description provided for @tabAgenda.
  ///
  /// In id, this message translates to:
  /// **'Agenda'**
  String get tabAgenda;

  /// No description provided for @monthView.
  ///
  /// In id, this message translates to:
  /// **'Tampilan bulan'**
  String get monthView;

  /// No description provided for @weekView.
  ///
  /// In id, this message translates to:
  /// **'Tampilan minggu'**
  String get weekView;

  /// No description provided for @agendaView.
  ///
  /// In id, this message translates to:
  /// **'Agenda kronologis'**
  String get agendaView;

  /// No description provided for @appLockTitle.
  ///
  /// In id, this message translates to:
  /// **'Kunci Aplikasi'**
  String get appLockTitle;

  /// No description provided for @enableAppLock.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Kunci Aplikasi'**
  String get enableAppLock;

  /// No description provided for @appLockMethod.
  ///
  /// In id, this message translates to:
  /// **'Sidik jari atau PIN'**
  String get appLockMethod;

  /// No description provided for @schoolModeTheme.
  ///
  /// In id, this message translates to:
  /// **'Tema Mode SMA'**
  String get schoolModeTheme;

  /// No description provided for @schoolModeThemeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah terminologi ke SMA'**
  String get schoolModeThemeSubtitle;

  /// No description provided for @iconShortcutsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pintasan Ikon dan Quick Settings'**
  String get iconShortcutsTitle;

  /// No description provided for @appIconShortcut.
  ///
  /// In id, this message translates to:
  /// **'Pintasan Ikon Aplikasi'**
  String get appIconShortcut;

  /// No description provided for @appIconShortcutSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tekan lama ikon peluncur: Tambah Tugas, Hari Ini, Inbox'**
  String get appIconShortcutSubtitle;

  /// No description provided for @quickSettingsTile.
  ///
  /// In id, this message translates to:
  /// **'Tile Quick Settings'**
  String get quickSettingsTile;

  /// No description provided for @quickSettingsTileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Satu ketukan dari bilah notifikasi membuka Quick Add'**
  String get quickSettingsTileSubtitle;

  /// No description provided for @optionalPersistentNotification.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi Tetap Opsional'**
  String get optionalPersistentNotification;

  /// No description provided for @optionalPersistentNotificationSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kolom ketik cepat (dimatikan bawaan)'**
  String get optionalPersistentNotificationSubtitle;

  /// No description provided for @globalQuickLinksTitle.
  ///
  /// In id, this message translates to:
  /// **'Tautan Cepat Global'**
  String get globalQuickLinksTitle;

  /// No description provided for @quickLinkSiakad.
  ///
  /// In id, this message translates to:
  /// **'SIAKAD'**
  String get quickLinkSiakad;

  /// No description provided for @quickLinkELearning.
  ///
  /// In id, this message translates to:
  /// **'E-Learning Kampus'**
  String get quickLinkELearning;

  /// No description provided for @quickLinkLibrary.
  ///
  /// In id, this message translates to:
  /// **'Perpustakaan'**
  String get quickLinkLibrary;

  /// No description provided for @simpleRecurringTasksTitle.
  ///
  /// In id, this message translates to:
  /// **'Tugas Berulang Sederhana'**
  String get simpleRecurringTasksTitle;

  /// No description provided for @repeatDaily.
  ///
  /// In id, this message translates to:
  /// **'Harian'**
  String get repeatDaily;

  /// No description provided for @repeatDailySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Setiap hari'**
  String get repeatDailySubtitle;

  /// No description provided for @repeatWeekly.
  ///
  /// In id, this message translates to:
  /// **'Mingguan'**
  String get repeatWeekly;

  /// No description provided for @repeatWeeklySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Hari tertentu setiap minggu'**
  String get repeatWeeklySubtitle;

  /// No description provided for @repeatMonthly.
  ///
  /// In id, this message translates to:
  /// **'Bulanan'**
  String get repeatMonthly;

  /// No description provided for @repeatMonthlySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tanggal tertentu setiap bulan'**
  String get repeatMonthlySubtitle;

  /// No description provided for @duplicateDetectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Deteksi Duplikat'**
  String get duplicateDetectionTitle;

  /// No description provided for @duplicateDetectionItemSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Deteksi duplikat untuk tugas ini'**
  String get duplicateDetectionItemSubtitle;

  /// No description provided for @semesterStatsTitle.
  ///
  /// In id, this message translates to:
  /// **'Statistik dan Rekap Semester'**
  String get semesterStatsTitle;

  /// No description provided for @onTimePercentage.
  ///
  /// In id, this message translates to:
  /// **'Persentase Tepat Waktu'**
  String get onTimePercentage;

  /// No description provided for @busiestCourse.
  ///
  /// In id, this message translates to:
  /// **'Matkul Terpadat'**
  String get busiestCourse;

  /// No description provided for @attendanceRecap.
  ///
  /// In id, this message translates to:
  /// **'Rekap Kehadiran'**
  String get attendanceRecap;

  /// No description provided for @weeklyTrend.
  ///
  /// In id, this message translates to:
  /// **'Tren Per Minggu'**
  String get weeklyTrend;

  /// No description provided for @exportImagePdfTitle.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Gambar dan PDF'**
  String get exportImagePdfTitle;

  /// No description provided for @exportWeekSchedule.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Jadwal Minggu'**
  String get exportWeekSchedule;

  /// No description provided for @exportWeekScheduleSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Gambar jadwal minggu ini'**
  String get exportWeekScheduleSubtitle;

  /// No description provided for @exportTaskList.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Daftar Tugas'**
  String get exportTaskList;

  /// No description provided for @exportTaskListSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Gambar daftar tugas minggu ini'**
  String get exportTaskListSubtitle;

  /// No description provided for @exportGradeRecap.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Rekap Nilai'**
  String get exportGradeRecap;

  /// No description provided for @exportGradeRecapSubtitle.
  ///
  /// In id, this message translates to:
  /// **'PDF rekap nilai per matkul'**
  String get exportGradeRecapSubtitle;

  /// No description provided for @exportDeadlineHistory.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Riwayat Deadline'**
  String get exportDeadlineHistory;

  /// No description provided for @exportDeadlineHistorySubtitle.
  ///
  /// In id, this message translates to:
  /// **'PDF bukti perubahan deadline'**
  String get exportDeadlineHistorySubtitle;

  /// No description provided for @nonCourseSpaceTitle.
  ///
  /// In id, this message translates to:
  /// **'Wadah Non-Matkul'**
  String get nonCourseSpaceTitle;

  /// No description provided for @orgSpace.
  ///
  /// In id, this message translates to:
  /// **'Organisasi'**
  String get orgSpace;

  /// No description provided for @orgSpaceSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Organisasi kampus'**
  String get orgSpaceSubtitle;

  /// No description provided for @projectSpace.
  ///
  /// In id, this message translates to:
  /// **'Proyek'**
  String get projectSpace;

  /// No description provided for @projectSpaceSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Proyek kampus'**
  String get projectSpaceSubtitle;

  /// No description provided for @personalSpace.
  ///
  /// In id, this message translates to:
  /// **'Pribadi'**
  String get personalSpace;

  /// No description provided for @personalSpaceSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kegiatan pribadi'**
  String get personalSpaceSubtitle;

  /// No description provided for @otherSpace.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get otherSpace;

  /// No description provided for @otherSpaceSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Wadah lainnya'**
  String get otherSpaceSubtitle;

  /// No description provided for @advancedWidgetsTitle.
  ///
  /// In id, this message translates to:
  /// **'Widget Lanjutan'**
  String get advancedWidgetsTitle;

  /// No description provided for @widgetTaskListSubtitle.
  ///
  /// In id, this message translates to:
  /// **'3-6 baris dengan kotak centang'**
  String get widgetTaskListSubtitle;

  /// No description provided for @widgetTodayClasses.
  ///
  /// In id, this message translates to:
  /// **'Kelas Hari Ini'**
  String get widgetTodayClasses;

  /// No description provided for @widgetTodayClassesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Jadwal singkat'**
  String get widgetTodayClassesSubtitle;

  /// No description provided for @widgetExamCountdown.
  ///
  /// In id, this message translates to:
  /// **'Hitung Mundur Ujian'**
  String get widgetExamCountdown;

  /// No description provided for @widgetExamCountdownSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Countdown ke ujian berikutnya'**
  String get widgetExamCountdownSubtitle;

  /// No description provided for @widgetTodayFocus.
  ///
  /// In id, this message translates to:
  /// **'Fokus Hari Ini'**
  String get widgetTodayFocus;

  /// No description provided for @widgetTodayFocusSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tiga tugas fokus dengan kotak centang'**
  String get widgetTodayFocusSubtitle;

  /// No description provided for @todayFocusTitle.
  ///
  /// In id, this message translates to:
  /// **'Fokus Hari Ini'**
  String get todayFocusTitle;

  /// No description provided for @ocrScreenshotTitle.
  ///
  /// In id, this message translates to:
  /// **'OCR Tangkapan Layar'**
  String get ocrScreenshotTitle;

  /// No description provided for @chooseScreenshot.
  ///
  /// In id, this message translates to:
  /// **'Pilih Tangkapan Layar'**
  String get chooseScreenshot;

  /// No description provided for @chooseScreenshotSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih gambar untuk diekstrak teksnya'**
  String get chooseScreenshotSubtitle;

  /// No description provided for @extractedFile.
  ///
  /// In id, this message translates to:
  /// **'Diekstrak: {path}'**
  String extractedFile(String path);

  /// No description provided for @ocrLimitations.
  ///
  /// In id, this message translates to:
  /// **'Batasan OCR'**
  String get ocrLimitations;

  /// No description provided for @ocrLimitationsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Hasil OCR pada tulisan tangan atau foto miring akan buruk.'**
  String get ocrLimitationsSubtitle;

  /// No description provided for @gradePredictionTitle.
  ///
  /// In id, this message translates to:
  /// **'Prediksi Nilai'**
  String get gradePredictionTitle;

  /// No description provided for @noGradeComponents.
  ///
  /// In id, this message translates to:
  /// **'Belum ada komponen penilaian.'**
  String get noGradeComponents;

  /// No description provided for @weightPercentLabel.
  ///
  /// In id, this message translates to:
  /// **'Bobot: {percent}%'**
  String weightPercentLabel(String percent);

  /// No description provided for @autoBackupTitle.
  ///
  /// In id, this message translates to:
  /// **'Cadangan Otomatis'**
  String get autoBackupTitle;

  /// No description provided for @weeklyBackup.
  ///
  /// In id, this message translates to:
  /// **'Cadangan Mingguan'**
  String get weeklyBackup;

  /// No description provided for @weeklyBackupSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Cadangan otomatis ke folder yang dipilih'**
  String get weeklyBackupSubtitle;

  /// No description provided for @backupFolderPicked.
  ///
  /// In id, this message translates to:
  /// **'Folder cadangan: {path}'**
  String backupFolderPicked(String path);

  /// No description provided for @keepLast4Backups.
  ///
  /// In id, this message translates to:
  /// **'Simpan 4 Cadangan Terakhir'**
  String get keepLast4Backups;

  /// No description provided for @keepLast4BackupsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Cadangan lebih lama akan dihapus otomatis'**
  String get keepLast4BackupsSubtitle;

  /// No description provided for @warnOlderThan14Days.
  ///
  /// In id, this message translates to:
  /// **'Peringatan Bila > 14 Hari'**
  String get warnOlderThan14Days;

  /// No description provided for @warnOlderThan14DaysSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Peringatkan bila cadangan terakhir lebih dari 14 hari'**
  String get warnOlderThan14DaysSubtitle;

  /// No description provided for @deadlineHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Deadline'**
  String get deadlineHistoryTitle;

  /// No description provided for @emptyDeadlineHistory.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat perubahan deadline.'**
  String get emptyDeadlineHistory;

  /// No description provided for @deadlineChangeLabel.
  ///
  /// In id, this message translates to:
  /// **'{oldValue} → {newValue}'**
  String deadlineChangeLabel(String oldValue, String newValue);

  /// No description provided for @mergeImportTitle.
  ///
  /// In id, this message translates to:
  /// **'Impor Gabung'**
  String get mergeImportTitle;

  /// No description provided for @importAndMergeBackup.
  ///
  /// In id, this message translates to:
  /// **'Impor dan Gabung Cadangan'**
  String get importAndMergeBackup;

  /// No description provided for @importAndMergeBackupSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Gabungkan data dari cadangan dengan data saat ini'**
  String get importAndMergeBackupSubtitle;

  /// No description provided for @mergedTasks.
  ///
  /// In id, this message translates to:
  /// **'Digabung: {count} tugas'**
  String mergedTasks(int count);

  /// No description provided for @actionFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal: {error}'**
  String actionFailed(String error);

  /// No description provided for @multiLineQuickAddTitle.
  ///
  /// In id, this message translates to:
  /// **'Quick Add Banyak Baris'**
  String get multiLineQuickAddTitle;

  /// No description provided for @pasteMultipleLinesLabel.
  ///
  /// In id, this message translates to:
  /// **'Tempel beberapa baris (satu baris = satu tugas)'**
  String get pasteMultipleLinesLabel;

  /// No description provided for @tasksWillBeCreated.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas akan dibuat'**
  String tasksWillBeCreated(int count);

  /// No description provided for @createTasks.
  ///
  /// In id, this message translates to:
  /// **'Buat Tugas'**
  String get createTasks;

  /// No description provided for @emptyTrash.
  ///
  /// In id, this message translates to:
  /// **'Sampah kosong.'**
  String get emptyTrash;

  /// No description provided for @deletedAtLabel.
  ///
  /// In id, this message translates to:
  /// **'Dihapus: {date}'**
  String deletedAtLabel(String date);

  /// No description provided for @attachmentsTitle.
  ///
  /// In id, this message translates to:
  /// **'Lampiran'**
  String get attachmentsTitle;

  /// No description provided for @classContactsLinksTitle.
  ///
  /// In id, this message translates to:
  /// **'Kontak dan Tautan Kelas'**
  String get classContactsLinksTitle;

  /// No description provided for @lecturerLabel.
  ///
  /// In id, this message translates to:
  /// **'Dosen / Pengajar'**
  String get lecturerLabel;

  /// No description provided for @roomLabel.
  ///
  /// In id, this message translates to:
  /// **'Ruangan'**
  String get roomLabel;

  /// No description provided for @classLinkLabel.
  ///
  /// In id, this message translates to:
  /// **'Tautan Kelas'**
  String get classLinkLabel;

  /// No description provided for @openLecturerWhatsApp.
  ///
  /// In id, this message translates to:
  /// **'Buka WhatsApp Dosen'**
  String get openLecturerWhatsApp;

  /// No description provided for @copyRoomNumber.
  ///
  /// In id, this message translates to:
  /// **'Salin Nomor Ruangan'**
  String get copyRoomNumber;

  /// No description provided for @examStudyMaterialsTitle.
  ///
  /// In id, this message translates to:
  /// **'Ujian dan Materi Belajar'**
  String get examStudyMaterialsTitle;

  /// No description provided for @noExamsYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada ujian.'**
  String get noExamsYet;

  /// No description provided for @daysRemaining.
  ///
  /// In id, this message translates to:
  /// **'{days} hari lagi'**
  String daysRemaining(int days);

  /// No description provided for @examNoDeadline.
  ///
  /// In id, this message translates to:
  /// **'Kapan-kapan'**
  String get examNoDeadline;

  /// No description provided for @quizLabel.
  ///
  /// In id, this message translates to:
  /// **'Kuis'**
  String get quizLabel;

  /// No description provided for @midtermLabel.
  ///
  /// In id, this message translates to:
  /// **'UTS'**
  String get midtermLabel;

  /// No description provided for @finalExamLabel.
  ///
  /// In id, this message translates to:
  /// **'UAS'**
  String get finalExamLabel;

  /// No description provided for @morningNightSummaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Pagi dan Malam'**
  String get morningNightSummaryTitle;

  /// No description provided for @todaySummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Hari Ini'**
  String get todaySummary;

  /// No description provided for @todayTasksLabel.
  ///
  /// In id, this message translates to:
  /// **'Tugas hari ini'**
  String get todayTasksLabel;

  /// No description provided for @tomorrowTasksLabel.
  ///
  /// In id, this message translates to:
  /// **'Tugas besok'**
  String get tomorrowTasksLabel;

  /// No description provided for @overdueTasksLabel.
  ///
  /// In id, this message translates to:
  /// **'Tugas terlambat'**
  String get overdueTasksLabel;

  /// No description provided for @summaryScheduleNote.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan pagi dikirim pukul 07.00\nPenutup malam dikirim pukul 20.30'**
  String get summaryScheduleNote;

  /// No description provided for @searchFilterTitle.
  ///
  /// In id, this message translates to:
  /// **'Pencarian dan Penyaring'**
  String get searchFilterTitle;

  /// No description provided for @searchTitleOrNotesLabel.
  ///
  /// In id, this message translates to:
  /// **'Cari judul atau catatan'**
  String get searchTitleOrNotesLabel;

  /// No description provided for @filterLabel.
  ///
  /// In id, this message translates to:
  /// **'Penyaring'**
  String get filterLabel;

  /// No description provided for @filterSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Wadah, jenis, status'**
  String get filterSubtitle;

  /// No description provided for @changeSemesterTitle.
  ///
  /// In id, this message translates to:
  /// **'Ganti Semester'**
  String get changeSemesterTitle;

  /// No description provided for @newSemester.
  ///
  /// In id, this message translates to:
  /// **'Semester Baru'**
  String get newSemester;

  /// No description provided for @semesterPeriodExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Ganjil 2026/2027'**
  String get semesterPeriodExample;

  /// No description provided for @unfinishedTasksOptionsLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih opsi untuk tugas belum selesai:'**
  String get unfinishedTasksOptionsLabel;

  /// No description provided for @keepInArchive.
  ///
  /// In id, this message translates to:
  /// **'Biarkan di arsip'**
  String get keepInArchive;

  /// No description provided for @moveToNewSpace.
  ///
  /// In id, this message translates to:
  /// **'Pindahkan ke wadah baru'**
  String get moveToNewSpace;

  /// No description provided for @deleteLabel.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get deleteLabel;

  /// No description provided for @createNewSemester.
  ///
  /// In id, this message translates to:
  /// **'Buat Semester Baru'**
  String get createNewSemester;

  /// No description provided for @snoozeReminderTitle.
  ///
  /// In id, this message translates to:
  /// **'Tunda Pengingat'**
  String get snoozeReminderTitle;

  /// No description provided for @pickSnoozeTimeLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih waktu tunda:'**
  String get pickSnoozeTimeLabel;

  /// No description provided for @oneHourLabel.
  ///
  /// In id, this message translates to:
  /// **'1 jam'**
  String get oneHourLabel;

  /// No description provided for @tonight7pmLabel.
  ///
  /// In id, this message translates to:
  /// **'Nanti malam 19.00'**
  String get tonight7pmLabel;

  /// No description provided for @tomorrow7amLabel.
  ///
  /// In id, this message translates to:
  /// **'Besok pagi 07.00'**
  String get tomorrow7amLabel;

  /// No description provided for @weekendLabel.
  ///
  /// In id, this message translates to:
  /// **'Akhir pekan'**
  String get weekendLabel;

  /// No description provided for @pickTimeLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih waktu'**
  String get pickTimeLabel;

  /// No description provided for @meetingNotesTitle.
  ///
  /// In id, this message translates to:
  /// **'Catatan Pertemuan'**
  String get meetingNotesTitle;

  /// No description provided for @noteTitleLabel.
  ///
  /// In id, this message translates to:
  /// **'Judul catatan'**
  String get noteTitleLabel;

  /// No description provided for @noteBodyLabel.
  ///
  /// In id, this message translates to:
  /// **'Isi catatan'**
  String get noteBodyLabel;

  /// No description provided for @noMeetingNotesYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan pertemuan.'**
  String get noMeetingNotesYet;

  /// No description provided for @untitledNote.
  ///
  /// In id, this message translates to:
  /// **'Tanpa judul'**
  String get untitledNote;

  /// No description provided for @submissionMethodTitle.
  ///
  /// In id, this message translates to:
  /// **'Cara Kumpul'**
  String get submissionMethodTitle;

  /// No description provided for @submissionMethodLabel.
  ///
  /// In id, this message translates to:
  /// **'Cara Kumpul'**
  String get submissionMethodLabel;

  /// No description provided for @submitMethodPaper.
  ///
  /// In id, this message translates to:
  /// **'Kertas / Hard Copy'**
  String get submitMethodPaper;

  /// No description provided for @othersLabel.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get othersLabel;

  /// No description provided for @submitTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'Tujuan (email, kelas LMS, ruangan)'**
  String get submitTargetLabel;

  /// No description provided for @filenamePatternLabel.
  ///
  /// In id, this message translates to:
  /// **'Pola Nama Berkas'**
  String get filenamePatternLabel;

  /// No description provided for @componentWeightTitle.
  ///
  /// In id, this message translates to:
  /// **'Bobot Komponen - {spaceName}'**
  String componentWeightTitle(String spaceName);

  /// No description provided for @weightPercentFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Bobot (%)'**
  String get weightPercentFieldLabel;

  /// No description provided for @weightTotalMustBe100.
  ///
  /// In id, this message translates to:
  /// **'Total bobot: {total}%, harus 100%'**
  String weightTotalMustBe100(String total);

  /// No description provided for @assignmentLabel.
  ///
  /// In id, this message translates to:
  /// **'Tugas'**
  String get assignmentLabel;

  /// No description provided for @attendanceLabel.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran'**
  String get attendanceLabel;

  /// No description provided for @subtasksTitle.
  ///
  /// In id, this message translates to:
  /// **'Subtugas'**
  String get subtasksTitle;

  /// No description provided for @noSubtasksYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada subtugas.'**
  String get noSubtasksYet;

  /// No description provided for @editSubtaskTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit Subtugas'**
  String get editSubtaskTitle;

  /// No description provided for @personalTargetTitle.
  ///
  /// In id, this message translates to:
  /// **'Target Pribadi'**
  String get personalTargetTitle;

  /// No description provided for @targetCompletionDate.
  ///
  /// In id, this message translates to:
  /// **'Target Selesai'**
  String get targetCompletionDate;

  /// No description provided for @notSetYet.
  ///
  /// In id, this message translates to:
  /// **'Belum diatur'**
  String get notSetYet;

  /// No description provided for @attendanceTitle.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran'**
  String get attendanceTitle;

  /// No description provided for @presentLabel.
  ///
  /// In id, this message translates to:
  /// **'Hadir'**
  String get presentLabel;

  /// No description provided for @remainingAbsenceQuota.
  ///
  /// In id, this message translates to:
  /// **'Sisa Jatah Absen'**
  String get remainingAbsenceQuota;

  /// No description provided for @markLabel.
  ///
  /// In id, this message translates to:
  /// **'Tandai'**
  String get markLabel;

  /// No description provided for @absentLabel.
  ///
  /// In id, this message translates to:
  /// **'Absen'**
  String get absentLabel;

  /// No description provided for @excusedLabel.
  ///
  /// In id, this message translates to:
  /// **'Izin'**
  String get excusedLabel;

  /// No description provided for @sickLabel.
  ///
  /// In id, this message translates to:
  /// **'Sakit'**
  String get sickLabel;

  /// No description provided for @shareIntakeTitle.
  ///
  /// In id, this message translates to:
  /// **'Tugas dari Bagikan'**
  String get shareIntakeTitle;

  /// No description provided for @shareIntakeHint.
  ///
  /// In id, this message translates to:
  /// **'Centang kalimat yang mau dibuat tugas, lalu koreksi lewat chip.'**
  String get shareIntakeHint;

  /// No description provided for @shareNoCandidates.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kalimat yang cocok. Simpan sebagai satu tugas.'**
  String get shareNoCandidates;

  /// No description provided for @saveSelected.
  ///
  /// In id, this message translates to:
  /// **'Simpan yang Dicentang'**
  String get saveSelected;

  /// No description provided for @savedTasksCount.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan: {count} tugas'**
  String savedTasksCount(int count);

  /// No description provided for @savedViewsTitle.
  ///
  /// In id, this message translates to:
  /// **'Tampilan Tersimpan'**
  String get savedViewsTitle;

  /// No description provided for @saveViewTitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan Tampilan'**
  String get saveViewTitle;

  /// No description provided for @viewNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama tampilan'**
  String get viewNameLabel;

  /// No description provided for @overdueTaskReminderTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Tugas Terlambat'**
  String get overdueTaskReminderTitle;

  /// No description provided for @noOverdueTasks.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tugas terlambat.'**
  String get noOverdueTasks;

  /// No description provided for @overdueDaysLabel.
  ///
  /// In id, this message translates to:
  /// **'Terlambat {days} hari. Deadline: {deadline}'**
  String overdueDaysLabel(int days, String deadline);

  /// No description provided for @resetDeadlineLabel.
  ///
  /// In id, this message translates to:
  /// **'Atur ulang'**
  String get resetDeadlineLabel;

  /// No description provided for @priorityBadgeLabel.
  ///
  /// In id, this message translates to:
  /// **'Prioritas {value}'**
  String priorityBadgeLabel(String value);

  /// No description provided for @deadlineAtLabel.
  ///
  /// In id, this message translates to:
  /// **'Deadline: {value}'**
  String deadlineAtLabel(String value);

  /// No description provided for @estimateMinutesLabel.
  ///
  /// In id, this message translates to:
  /// **'Estimasi: {minutes} menit'**
  String estimateMinutesLabel(int minutes);

  /// No description provided for @subtaskProgressLabel.
  ///
  /// In id, this message translates to:
  /// **'Subtugas ({done}/{total})'**
  String subtaskProgressLabel(int done, int total);

  /// No description provided for @addLabel.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get addLabel;

  /// No description provided for @reopenTooltip.
  ///
  /// In id, this message translates to:
  /// **'Buka kembali'**
  String get reopenTooltip;

  /// No description provided for @markDoneTooltip.
  ///
  /// In id, this message translates to:
  /// **'Tandai selesai'**
  String get markDoneTooltip;

  /// No description provided for @addSubtaskTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Subtugas'**
  String get addSubtaskTitle;

  /// No description provided for @subtaskTitleHint.
  ///
  /// In id, this message translates to:
  /// **'Judul subtugas'**
  String get subtaskTitleHint;

  /// No description provided for @statusTodo.
  ///
  /// In id, this message translates to:
  /// **'Belum'**
  String get statusTodo;

  /// No description provided for @statusDoing.
  ///
  /// In id, this message translates to:
  /// **'Dikerjakan'**
  String get statusDoing;

  /// No description provided for @statusRevision.
  ///
  /// In id, this message translates to:
  /// **'Revisi'**
  String get statusRevision;

  /// No description provided for @taskModeGroup.
  ///
  /// In id, this message translates to:
  /// **'Kelompok'**
  String get taskModeGroup;

  /// No description provided for @emptyInboxNote.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan.'**
  String get emptyInboxNote;

  /// No description provided for @noNotesLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanpa catatan'**
  String get noNotesLabel;

  /// No description provided for @previousMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan sebelumnya'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan berikutnya'**
  String get nextMonth;

  /// No description provided for @quickAddMenuLabel.
  ///
  /// In id, this message translates to:
  /// **'Tambah Tugas Cepat'**
  String get quickAddMenuLabel;

  /// No description provided for @smartSnoozeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tunda Cerdas'**
  String get smartSnoozeLabel;

  /// No description provided for @morningNightSummaryShort.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan Pagi/Malam'**
  String get morningNightSummaryShort;

  /// No description provided for @overdueTasksMenuLabel.
  ///
  /// In id, this message translates to:
  /// **'Tugas Terlambat'**
  String get overdueTasksMenuLabel;

  /// No description provided for @exportBackupShort.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Cadangan'**
  String get exportBackupShort;

  /// No description provided for @importBackupShort.
  ///
  /// In id, this message translates to:
  /// **'Impor Cadangan'**
  String get importBackupShort;

  /// No description provided for @emptySpaces.
  ///
  /// In id, this message translates to:
  /// **'Belum ada wadah (matkul).'**
  String get emptySpaces;

  /// No description provided for @spaceCodeValue.
  ///
  /// In id, this message translates to:
  /// **'Kode: {value}'**
  String spaceCodeValue(String value);

  /// No description provided for @spaceLevelValue.
  ///
  /// In id, this message translates to:
  /// **'Jenjang: {value}'**
  String spaceLevelValue(String value);

  /// No description provided for @spacePeriodValue.
  ///
  /// In id, this message translates to:
  /// **'Semester: {value}'**
  String spacePeriodValue(String value);

  /// No description provided for @spaceSksValue.
  ///
  /// In id, this message translates to:
  /// **'SKS: {value}'**
  String spaceSksValue(String value);

  /// No description provided for @spaceTargetGradeValue.
  ///
  /// In id, this message translates to:
  /// **'Target Nilai: {value}'**
  String spaceTargetGradeValue(String value);

  /// No description provided for @classScheduleTitle.
  ///
  /// In id, this message translates to:
  /// **'Jadwal Kelas'**
  String get classScheduleTitle;

  /// No description provided for @tasksMenuLabel.
  ///
  /// In id, this message translates to:
  /// **'Tugas'**
  String get tasksMenuLabel;

  /// No description provided for @componentWeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Bobot Komponen'**
  String get componentWeightLabel;

  /// No description provided for @defaultChecklistShort.
  ///
  /// In id, this message translates to:
  /// **'Daftar Bawaan'**
  String get defaultChecklistShort;

  /// No description provided for @startTimeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jam Mulai (HH:MM)'**
  String get startTimeLabel;

  /// No description provided for @endTimeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jam Selesai (HH:MM)'**
  String get endTimeLabel;

  /// No description provided for @emptyClassSchedule.
  ///
  /// In id, this message translates to:
  /// **'Belum ada jadwal kelas.'**
  String get emptyClassSchedule;

  /// No description provided for @monday.
  ///
  /// In id, this message translates to:
  /// **'Senin'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In id, this message translates to:
  /// **'Selasa'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In id, this message translates to:
  /// **'Rabu'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In id, this message translates to:
  /// **'Kamis'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In id, this message translates to:
  /// **'Jumat'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In id, this message translates to:
  /// **'Sabtu'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get sunday;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Lekas membantu kamu mencatat tugas dan deadline kuliah.'**
  String get welcomeSubtitle;

  /// No description provided for @enterFirstCourseSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama matkul pertama kamu.'**
  String get enterFirstCourseSubtitle;

  /// No description provided for @firstCourseFallback.
  ///
  /// In id, this message translates to:
  /// **'Matkul Pertama'**
  String get firstCourseFallback;

  /// No description provided for @allLabel.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get allLabel;

  /// No description provided for @typeLabReport.
  ///
  /// In id, this message translates to:
  /// **'Laprak'**
  String get typeLabReport;

  /// No description provided for @typePaper.
  ///
  /// In id, this message translates to:
  /// **'Makalah'**
  String get typePaper;

  /// No description provided for @typePresentation.
  ///
  /// In id, this message translates to:
  /// **'Presentasi'**
  String get typePresentation;

  /// No description provided for @emptyTaskList.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tugas.'**
  String get emptyTaskList;

  /// No description provided for @typeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get typeLabel;

  /// No description provided for @attachmentFileMissing.
  ///
  /// In id, this message translates to:
  /// **'File tidak ada di perangkat ini.'**
  String get attachmentFileMissing;

  /// No description provided for @openLabel.
  ///
  /// In id, this message translates to:
  /// **'Buka'**
  String get openLabel;

  /// No description provided for @noDuplicateFound.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada duplikat untuk tugas ini.'**
  String get noDuplicateFound;

  /// No description provided for @saved.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan'**
  String get saved;

  /// No description provided for @copiedToClipboard.
  ///
  /// In id, this message translates to:
  /// **'Disalin ke papan klip'**
  String get copiedToClipboard;

  /// No description provided for @noStatsDataYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data untuk statistik ini.'**
  String get noStatsDataYet;

  /// No description provided for @attendanceSavedToday.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran hari ini: {status}'**
  String attendanceSavedToday(String status);

  /// No description provided for @featureNotAvailable.
  ///
  /// In id, this message translates to:
  /// **'Fitur ini belum tersedia.'**
  String get featureNotAvailable;

  /// No description provided for @enabledLabel.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get enabledLabel;

  /// No description provided for @disabledLabel.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get disabledLabel;

  /// No description provided for @spaceCreated.
  ///
  /// In id, this message translates to:
  /// **'Wadah dibuat: {name}'**
  String spaceCreated(String name);

  /// No description provided for @tasksProcessed.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas diproses'**
  String tasksProcessed(int count);

  /// No description provided for @deleted.
  ///
  /// In id, this message translates to:
  /// **'Dihapus'**
  String get deleted;

  /// No description provided for @sampleDataRemoved.
  ///
  /// In id, this message translates to:
  /// **'Data contoh dihapus'**
  String get sampleDataRemoved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
