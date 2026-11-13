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
  /// **'Kategori'**
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

  /// No description provided for @pasteAction.
  ///
  /// In id, this message translates to:
  /// **'Tempel'**
  String get pasteAction;

  /// No description provided for @clipboardEmpty.
  ///
  /// In id, this message translates to:
  /// **'Papan klip kosong. Salin teks dulu.'**
  String get clipboardEmpty;

  /// No description provided for @repeatLastTask.
  ///
  /// In id, this message translates to:
  /// **'Ulangi tugas terakhir'**
  String get repeatLastTask;

  /// No description provided for @historySuggestion.
  ///
  /// In id, this message translates to:
  /// **'Mirip: {title}'**
  String historySuggestion(String title);

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
  /// **'Tambah Kategori'**
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
  /// **'Nama kategori'**
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
  /// **'Kategori'**
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
  /// **'Tambah Kategori Pertama'**
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
  /// **'Nama Kategori'**
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

  /// No description provided for @exportFailed.
  ///
  /// In id, this message translates to:
  /// **'Ekspor gagal. Coba lagi.'**
  String get exportFailed;

  /// No description provided for @importFailed.
  ///
  /// In id, this message translates to:
  /// **'Impor gagal. Data yang ada tidak diubah.'**
  String get importFailed;

  /// No description provided for @recordNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan.'**
  String get recordNotFound;

  /// No description provided for @attachmentTooBig.
  ///
  /// In id, this message translates to:
  /// **'File terlalu besar. Maksimal {limit} MB.'**
  String attachmentTooBig(int limit);

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

  /// No description provided for @noDependenciesYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada prasyarat.'**
  String get noDependenciesYet;

  /// No description provided for @addPrerequisiteLabel.
  ///
  /// In id, this message translates to:
  /// **'Tambah prasyarat'**
  String get addPrerequisiteLabel;

  /// No description provided for @searchTaskLabel.
  ///
  /// In id, this message translates to:
  /// **'Cari tugas'**
  String get searchTaskLabel;

  /// No description provided for @noOtherTasks.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tugas lain.'**
  String get noOtherTasks;

  /// No description provided for @dependencyCycleError.
  ///
  /// In id, this message translates to:
  /// **'Itu akan membuat lingkaran. Pilih tugas lain.'**
  String get dependencyCycleError;

  /// No description provided for @taskUnblockedTitle.
  ///
  /// In id, this message translates to:
  /// **'Sekarang bisa mulai'**
  String get taskUnblockedTitle;

  /// No description provided for @importScheduleOcrTitle.
  ///
  /// In id, this message translates to:
  /// **'Impor Jadwal dari Tangkapan Layar'**
  String get importScheduleOcrTitle;

  /// No description provided for @weeklyLoadMapTitle.
  ///
  /// In id, this message translates to:
  /// **'Peta Beban Mingguan'**
  String get weeklyLoadMapTitle;

  /// No description provided for @projectMilestoneTitle.
  ///
  /// In id, this message translates to:
  /// **'Proyek dan Milestone'**
  String get projectMilestoneTitle;

  /// No description provided for @freeTimeSuggestionTitle.
  ///
  /// In id, this message translates to:
  /// **'Saran Waktu Kosong'**
  String get freeTimeSuggestionTitle;

  /// No description provided for @gradeSimulatorTitle.
  ///
  /// In id, this message translates to:
  /// **'Simulator Nilai'**
  String get gradeSimulatorTitle;

  /// No description provided for @examStudyPlanTitle.
  ///
  /// In id, this message translates to:
  /// **'Rencana Belajar Ujian'**
  String get examStudyPlanTitle;

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

  /// No description provided for @appLockTitle.
  ///
  /// In id, this message translates to:
  /// **'Kunci Aplikasi'**
  String get appLockTitle;

  /// No description provided for @appLockOn.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get appLockOn;

  /// No description provided for @appLockOff.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get appLockOff;

  /// No description provided for @changePinLabel.
  ///
  /// In id, this message translates to:
  /// **'Ubah PIN'**
  String get changePinLabel;

  /// No description provided for @pinLabel.
  ///
  /// In id, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @pinConfirmLabel.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi PIN'**
  String get pinConfirmLabel;

  /// No description provided for @pinMismatch.
  ///
  /// In id, this message translates to:
  /// **'PIN tidak sama'**
  String get pinMismatch;

  /// No description provided for @pinTooShort.
  ///
  /// In id, this message translates to:
  /// **'Pakai 4 sampai 6 digit'**
  String get pinTooShort;

  /// No description provided for @wrongPin.
  ///
  /// In id, this message translates to:
  /// **'PIN salah'**
  String get wrongPin;

  /// No description provided for @unlockLabel.
  ///
  /// In id, this message translates to:
  /// **'Buka'**
  String get unlockLabel;

  /// No description provided for @unlockTitle.
  ///
  /// In id, this message translates to:
  /// **'Buka Lekas'**
  String get unlockTitle;

  /// No description provided for @levelLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenjang'**
  String get levelLabel;

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

  /// No description provided for @trashTitle.
  ///
  /// In id, this message translates to:
  /// **'Sampah'**
  String get trashTitle;

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

  /// No description provided for @restoreLabel.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan'**
  String get restoreLabel;

  /// No description provided for @deletePermanentlyLabel.
  ///
  /// In id, this message translates to:
  /// **'Hapus permanen'**
  String get deletePermanentlyLabel;

  /// No description provided for @deletePermanentlyBody.
  ///
  /// In id, this message translates to:
  /// **'Tugas ini hilang selamanya dan tidak bisa dibatalkan.'**
  String get deletePermanentlyBody;

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
  /// **'Kategori, status, urutan'**
  String get filterSubtitle;

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
  /// **'Belum ada kategori.'**
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
  /// **'Lekas membantumu mencatat tugas dan deadline kuliah.'**
  String get welcomeSubtitle;

  /// No description provided for @enterFirstCourseSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama kategori pertama kamu.'**
  String get enterFirstCourseSubtitle;

  /// No description provided for @firstCourseFallback.
  ///
  /// In id, this message translates to:
  /// **'Kategori Pertama'**
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
  /// **'Kategori dibuat: {name}'**
  String spaceCreated(String name);

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

  /// No description provided for @sectionOverdue.
  ///
  /// In id, this message translates to:
  /// **'Terlambat'**
  String get sectionOverdue;

  /// No description provided for @sectionDoing.
  ///
  /// In id, this message translates to:
  /// **'Sedang Dikerjakan'**
  String get sectionDoing;

  /// No description provided for @sectionToday.
  ///
  /// In id, this message translates to:
  /// **'Hari Ini dan Besok'**
  String get sectionToday;

  /// No description provided for @sectionThisWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu Ini'**
  String get sectionThisWeek;

  /// No description provided for @sectionUpcoming.
  ///
  /// In id, this message translates to:
  /// **'Mendatang'**
  String get sectionUpcoming;

  /// No description provided for @sectionWaiting.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get sectionWaiting;

  /// No description provided for @sectionSomeday.
  ///
  /// In id, this message translates to:
  /// **'Kapan-kapan'**
  String get sectionSomeday;

  /// No description provided for @reasonOverdue.
  ///
  /// In id, this message translates to:
  /// **'Lewat deadline'**
  String get reasonOverdue;

  /// No description provided for @reasonDueInHours.
  ///
  /// In id, this message translates to:
  /// **'{hours} jam lagi'**
  String reasonDueInHours(int hours);

  /// No description provided for @reasonHighPriority.
  ///
  /// In id, this message translates to:
  /// **'Prioritas tinggi'**
  String get reasonHighPriority;

  /// No description provided for @reasonTightEstimate.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan waktu mepet'**
  String get reasonTightEstimate;

  /// No description provided for @reasonTimeLeft.
  ///
  /// In id, this message translates to:
  /// **'Sisa {hours} jam'**
  String reasonTimeLeft(int hours);

  /// No description provided for @reasonNoDeadline.
  ///
  /// In id, this message translates to:
  /// **'Tanpa deadline'**
  String get reasonNoDeadline;

  /// No description provided for @reasonWeight.
  ///
  /// In id, this message translates to:
  /// **'bobot {percent}%'**
  String reasonWeight(String percent);

  /// No description provided for @warningTitle.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get warningTitle;

  /// No description provided for @warningPermissionRevoked.
  ///
  /// In id, this message translates to:
  /// **'Izin pengingat dicabut. Ketuk untuk membuka pengaturan.'**
  String get warningPermissionRevoked;

  /// No description provided for @warningInboxPile.
  ///
  /// In id, this message translates to:
  /// **'Inbox menumpuk: {count} tugas tanpa kategori. Ketuk untuk membereskan.'**
  String warningInboxPile(int count);

  /// No description provided for @warningBusyWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu padat: {count} tugas jatuh tempo. Ketuk untuk melihat.'**
  String warningBusyWeek(int count);

  /// No description provided for @closeLabel.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get closeLabel;

  /// No description provided for @selectedCount.
  ///
  /// In id, this message translates to:
  /// **'{count} dipilih'**
  String selectedCount(int count);

  /// No description provided for @selectAllLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih semua'**
  String get selectAllLabel;

  /// No description provided for @reorderLabel.
  ///
  /// In id, this message translates to:
  /// **'Ubah urutan'**
  String get reorderLabel;

  /// No description provided for @archiveLabel.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan'**
  String get archiveLabel;

  /// No description provided for @archiveActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get archiveActive;

  /// No description provided for @archiveArchive.
  ///
  /// In id, this message translates to:
  /// **'Arsip'**
  String get archiveArchive;

  /// No description provided for @archiveEmptyText.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kategori yang diarsipkan di sini. Saat kamu mengarsip sebuah kategori, kategori itu menunggu di sini, dan bisa kamu pulihkan atau hapus permanen.'**
  String get archiveEmptyText;

  /// No description provided for @deleteSpaceTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus kategori'**
  String get deleteSpaceTitle;

  /// No description provided for @deleteSpaceBody.
  ///
  /// In id, this message translates to:
  /// **'Ini menghapus kategori beserta jadwal, presensi, catatan, komponen nilai, dan checklist. Tugasnya pindah ke Inbox. Tindakan ini tidak bisa dibatalkan.'**
  String get deleteSpaceBody;

  /// No description provided for @spaceRestored.
  ///
  /// In id, this message translates to:
  /// **'Kategori dipulihkan'**
  String get spaceRestored;

  /// No description provided for @drawerSectionTasks.
  ///
  /// In id, this message translates to:
  /// **'Tugas'**
  String get drawerSectionTasks;

  /// No description provided for @drawerSectionData.
  ///
  /// In id, this message translates to:
  /// **'Data'**
  String get drawerSectionData;

  /// No description provided for @drawerSectionSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get drawerSectionSystem;

  /// No description provided for @editSpaceTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah kategori'**
  String get editSpaceTitle;

  /// No description provided for @taskDeletedUndo.
  ///
  /// In id, this message translates to:
  /// **'Tugas dihapus'**
  String get taskDeletedUndo;

  /// No description provided for @tasksRestored.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas dipulihkan'**
  String tasksRestored(int count);

  /// No description provided for @spacesArchivedUndo.
  ///
  /// In id, this message translates to:
  /// **'{count} kategori diarsipkan'**
  String spacesArchivedUndo(int count);

  /// No description provided for @taskCompletedUndo.
  ///
  /// In id, this message translates to:
  /// **'Tugas diselesaikan'**
  String get taskCompletedUndo;

  /// No description provided for @tasksDeletedUndo.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas dihapus'**
  String tasksDeletedUndo(int count);

  /// No description provided for @bulkUpdated.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas diperbarui'**
  String bulkUpdated(int count);

  /// No description provided for @snoozeSet.
  ///
  /// In id, this message translates to:
  /// **'Pengingat ditunda ke {time}'**
  String snoozeSet(String time);

  /// No description provided for @reminderIn6Hours.
  ///
  /// In id, this message translates to:
  /// **'Deadline 6 jam lagi'**
  String get reminderIn6Hours;

  /// No description provided for @reminderIn12Hours.
  ///
  /// In id, this message translates to:
  /// **'Deadline 12 jam lagi'**
  String get reminderIn12Hours;

  /// No description provided for @reminderIn18Hours.
  ///
  /// In id, this message translates to:
  /// **'Deadline 18 jam lagi'**
  String get reminderIn18Hours;

  /// No description provided for @groupedReminderTitle.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas mendekati deadline'**
  String groupedReminderTitle(int count);

  /// No description provided for @summaryReminderTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan pengingat'**
  String get summaryReminderTitle;

  /// No description provided for @summaryReminderBody.
  ///
  /// In id, this message translates to:
  /// **'{count} pengingat digabung ke ringkasan ini'**
  String summaryReminderBody(int count);

  /// No description provided for @reminderIntensity.
  ///
  /// In id, this message translates to:
  /// **'Intensitas pengingat'**
  String get reminderIntensity;

  /// No description provided for @intensityCalm.
  ///
  /// In id, this message translates to:
  /// **'Tenang: H-1 dan 3 jam'**
  String get intensityCalm;

  /// No description provided for @intensityNormal.
  ///
  /// In id, this message translates to:
  /// **'Normal: H-3, H-1, 3 jam, 30 menit'**
  String get intensityNormal;

  /// No description provided for @intensityEager.
  ///
  /// In id, this message translates to:
  /// **'Gencar: ditambah tiap 6 jam di hari deadline'**
  String get intensityEager;

  /// No description provided for @notificationBudget.
  ///
  /// In id, this message translates to:
  /// **'Anggaran notifikasi harian'**
  String get notificationBudget;

  /// No description provided for @budgetPerDay.
  ///
  /// In id, this message translates to:
  /// **'{count} notifikasi per hari'**
  String budgetPerDay(int count);

  /// No description provided for @overdueDigestBody.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas melewati deadline. Ketuk untuk melihat daftarnya.'**
  String overdueDigestBody(int count);

  /// No description provided for @overdueReminderToggle.
  ///
  /// In id, this message translates to:
  /// **'Satu notifikasi per hari pukul 09.00'**
  String get overdueReminderToggle;

  /// No description provided for @morningSummaryNotificationTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan pagi'**
  String get morningSummaryNotificationTitle;

  /// No description provided for @morningSummaryMostUrgent.
  ///
  /// In id, this message translates to:
  /// **'Paling mendesak: {title} (deadline {time})'**
  String morningSummaryMostUrgent(String title, String time);

  /// No description provided for @summaryMorningToggle.
  ///
  /// In id, this message translates to:
  /// **'Dikirim pukul 07.00'**
  String get summaryMorningToggle;

  /// No description provided for @eveningSummaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Penutup malam'**
  String get eveningSummaryTitle;

  /// No description provided for @eveningSummaryBody.
  ///
  /// In id, this message translates to:
  /// **'Ada {count} tugas besok. Mau cek sekarang?'**
  String eveningSummaryBody(int count);

  /// No description provided for @summaryEveningToggle.
  ///
  /// In id, this message translates to:
  /// **'Dikirim pukul 20.30 bila ada tugas besok'**
  String get summaryEveningToggle;

  /// No description provided for @weeklySummaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan minggu'**
  String get weeklySummaryTitle;

  /// No description provided for @weeklySummaryOnTime.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas selesai tepat waktu minggu ini.'**
  String weeklySummaryOnTime(int count);

  /// No description provided for @weeklySummaryBusiest.
  ///
  /// In id, this message translates to:
  /// **'Matkul terpadat minggu depan: {name} ({count} tugas).'**
  String weeklySummaryBusiest(String name, int count);

  /// No description provided for @weeklySummaryBackup.
  ///
  /// In id, this message translates to:
  /// **'Cadangan terakhir {days} hari lalu.'**
  String weeklySummaryBackup(int days);

  /// No description provided for @summaryWeeklyToggle.
  ///
  /// In id, this message translates to:
  /// **'Minggu malam pukul 20.30'**
  String get summaryWeeklyToggle;

  /// No description provided for @tagsLabel.
  ///
  /// In id, this message translates to:
  /// **'Tag'**
  String get tagsLabel;

  /// No description provided for @tagsHint.
  ///
  /// In id, this message translates to:
  /// **'Pisahkan dengan koma, misalnya revisi, kelompok'**
  String get tagsHint;

  /// No description provided for @editTagsTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah tag'**
  String get editTagsTitle;

  /// No description provided for @sectionPinned.
  ///
  /// In id, this message translates to:
  /// **'Disematkan'**
  String get sectionPinned;

  /// No description provided for @pinTaskLabel.
  ///
  /// In id, this message translates to:
  /// **'Sematkan di atas layar Hari Ini'**
  String get pinTaskLabel;

  /// No description provided for @duplicateTask.
  ///
  /// In id, this message translates to:
  /// **'Duplikat tugas'**
  String get duplicateTask;

  /// No description provided for @duplicatedToast.
  ///
  /// In id, this message translates to:
  /// **'Salinan tugas dibuat'**
  String get duplicatedToast;

  /// No description provided for @taskTemplatesTitle.
  ///
  /// In id, this message translates to:
  /// **'Templat Tugas'**
  String get taskTemplatesTitle;

  /// No description provided for @emptyTemplates.
  ///
  /// In id, this message translates to:
  /// **'Belum ada templat. Buka detail tugas lalu pilih Simpan sebagai templat.'**
  String get emptyTemplates;

  /// No description provided for @templateSummary.
  ///
  /// In id, this message translates to:
  /// **'{subtasks} subtugas, estimasi {minutes} menit'**
  String templateSummary(int subtasks, int minutes);

  /// No description provided for @templateSubtaskCount.
  ///
  /// In id, this message translates to:
  /// **'{count} subtugas'**
  String templateSubtaskCount(int count);

  /// No description provided for @saveAsTemplate.
  ///
  /// In id, this message translates to:
  /// **'Simpan sebagai templat'**
  String get saveAsTemplate;

  /// No description provided for @templateNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama templat'**
  String get templateNameLabel;

  /// No description provided for @templateUsedToast.
  ///
  /// In id, this message translates to:
  /// **'Tugas baru dibuat dari templat'**
  String get templateUsedToast;

  /// No description provided for @templateSavedToast.
  ///
  /// In id, this message translates to:
  /// **'Templat disimpan'**
  String get templateSavedToast;

  /// No description provided for @attendanceProgress.
  ///
  /// In id, this message translates to:
  /// **'Hadir {attended} dari {planned} pertemuan'**
  String attendanceProgress(int attended, int planned);

  /// No description provided for @attendanceLimitNote.
  ///
  /// In id, this message translates to:
  /// **'Batas absen {percent} persen, jatah terpakai {limit}'**
  String attendanceLimitNote(int percent, int limit);

  /// No description provided for @attendanceRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa jatah absen {count}'**
  String attendanceRemaining(int count);

  /// No description provided for @attendanceLastOne.
  ///
  /// In id, this message translates to:
  /// **'Sisa jatah absen tinggal satu. Hati-hati.'**
  String get attendanceLastOne;

  /// No description provided for @attendanceExhausted.
  ///
  /// In id, this message translates to:
  /// **'Jatah absen habis, kehadiranmu sudah di batas kampus.'**
  String get attendanceExhausted;

  /// No description provided for @totalMeetingsLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah pertemuan rencana'**
  String get totalMeetingsLabel;

  /// No description provided for @absentLimitLabel.
  ///
  /// In id, this message translates to:
  /// **'Batas absen maksimal (persen)'**
  String get absentLimitLabel;

  /// No description provided for @excusedCountsLabel.
  ///
  /// In id, this message translates to:
  /// **'Izin dan sakit dihitung absen'**
  String get excusedCountsLabel;

  /// No description provided for @morningSummaryQuotaLast.
  ///
  /// In id, this message translates to:
  /// **'Jatah absen {name} tinggal 1, hati-hati hari ini.'**
  String morningSummaryQuotaLast(String name);

  /// No description provided for @morningSummaryQuotaOut.
  ///
  /// In id, this message translates to:
  /// **'Jatah absen {name} sudah habis.'**
  String morningSummaryQuotaOut(String name);

  /// No description provided for @chooseFocusAction.
  ///
  /// In id, this message translates to:
  /// **'Pilih fokus hari ini'**
  String get chooseFocusAction;

  /// No description provided for @pickFocusLabel.
  ///
  /// In id, this message translates to:
  /// **'Pilih tugas'**
  String get pickFocusLabel;

  /// No description provided for @focusLimitToast.
  ///
  /// In id, this message translates to:
  /// **'Fokus hari ini sudah penuh, maksimal 3 tugas'**
  String get focusLimitToast;

  /// No description provided for @focusAllDoneMsg.
  ///
  /// In id, this message translates to:
  /// **'Semua tugas fokus hari ini selesai.'**
  String get focusAllDoneMsg;

  /// No description provided for @focusEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada fokus hari ini. Pilih sampai 3 tugas.'**
  String get focusEmpty;

  /// No description provided for @focusRemoveTooltip.
  ///
  /// In id, this message translates to:
  /// **'Keluarkan dari fokus'**
  String get focusRemoveTooltip;

  /// No description provided for @attendPromptTitle.
  ///
  /// In id, this message translates to:
  /// **'Isi kehadiran'**
  String get attendPromptTitle;

  /// No description provided for @attendPromptBody.
  ///
  /// In id, this message translates to:
  /// **'Kelas {name} selesai 10 menit lalu.'**
  String attendPromptBody(String name);

  /// No description provided for @attendPromptAction.
  ///
  /// In id, this message translates to:
  /// **'Isi sekarang'**
  String get attendPromptAction;

  /// No description provided for @attendPromptToggle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi Isi kehadiran'**
  String get attendPromptToggle;

  /// No description provided for @attendPromptToggleHint.
  ///
  /// In id, this message translates to:
  /// **'Muncul 10 menit setelah kelas selesai'**
  String get attendPromptToggleHint;

  /// No description provided for @continueFocusQuestion.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan {count} tugas fokus kemarin?'**
  String continueFocusQuestion(int count);

  /// No description provided for @continueFocusAction.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get continueFocusAction;

  /// No description provided for @eveningBringLine.
  ///
  /// In id, this message translates to:
  /// **'Besok bawa: {items}'**
  String eveningBringLine(String items);

  /// No description provided for @eveningBringMore.
  ///
  /// In id, this message translates to:
  /// **'(+{count} lagi)'**
  String eveningBringMore(Object count);

  /// No description provided for @chipEstimateHours.
  ///
  /// In id, this message translates to:
  /// **'Estimasi: {hours} jam'**
  String chipEstimateHours(int hours);

  /// No description provided for @chipSubmitLms.
  ///
  /// In id, this message translates to:
  /// **'Kumpul lewat LMS'**
  String get chipSubmitLms;

  /// No description provided for @chipSubmitEmail.
  ///
  /// In id, this message translates to:
  /// **'Kumpul lewat email'**
  String get chipSubmitEmail;

  /// No description provided for @chipSubmitPaper.
  ///
  /// In id, this message translates to:
  /// **'Kumpul dicetak'**
  String get chipSubmitPaper;

  /// No description provided for @chipFilename.
  ///
  /// In id, this message translates to:
  /// **'Cek pola: {pattern}'**
  String chipFilename(String pattern);

  /// No description provided for @chipSubtasks.
  ///
  /// In id, this message translates to:
  /// **'{count} subtugas'**
  String chipSubtasks(int count);

  /// No description provided for @chipLinks.
  ///
  /// In id, this message translates to:
  /// **'{count} tautan'**
  String chipLinks(int count);

  /// No description provided for @chipNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan: {note}'**
  String chipNote(String note);

  /// No description provided for @chipPriorityConflict.
  ///
  /// In id, this message translates to:
  /// **'Prioritas campur'**
  String get chipPriorityConflict;

  /// No description provided for @micUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Pengenalan suara tidak tersedia di perangkat ini.'**
  String get micUnavailable;

  /// No description provided for @micPermissionDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin mikrofon diperlukan untuk Quick Add suara.'**
  String get micPermissionDenied;

  /// No description provided for @voiceListening.
  ///
  /// In id, this message translates to:
  /// **'Mendengarkan...'**
  String get voiceListening;

  /// No description provided for @appVersionLabel.
  ///
  /// In id, this message translates to:
  /// **'Versi aplikasi'**
  String get appVersionLabel;

  /// No description provided for @accentColor.
  ///
  /// In id, this message translates to:
  /// **'Warna aksen'**
  String get accentColor;

  /// No description provided for @fontSize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran font'**
  String get fontSize;

  /// No description provided for @fontSmall.
  ///
  /// In id, this message translates to:
  /// **'Kecil'**
  String get fontSmall;

  /// No description provided for @fontNormal.
  ///
  /// In id, this message translates to:
  /// **'Normal'**
  String get fontNormal;

  /// No description provided for @fontLarge.
  ///
  /// In id, this message translates to:
  /// **'Besar'**
  String get fontLarge;

  /// No description provided for @fontXlarge.
  ///
  /// In id, this message translates to:
  /// **'Sangat besar'**
  String get fontXlarge;

  /// No description provided for @colorDefault.
  ///
  /// In id, this message translates to:
  /// **'Bawaan'**
  String get colorDefault;

  /// No description provided for @previewLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get previewLight;

  /// No description provided for @previewDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get previewDark;

  /// No description provided for @presetMidnight.
  ///
  /// In id, this message translates to:
  /// **'Tengah malam'**
  String get presetMidnight;

  /// No description provided for @presetSunset.
  ///
  /// In id, this message translates to:
  /// **'Senja'**
  String get presetSunset;

  /// No description provided for @presetForest.
  ///
  /// In id, this message translates to:
  /// **'Hutan'**
  String get presetForest;

  /// No description provided for @semesterTitle.
  ///
  /// In id, this message translates to:
  /// **'Semester'**
  String get semesterTitle;

  /// No description provided for @semesterActiveLabel.
  ///
  /// In id, this message translates to:
  /// **'Semester Aktif'**
  String get semesterActiveLabel;

  /// No description provided for @semesterOtherLabel.
  ///
  /// In id, this message translates to:
  /// **'Semester Lain'**
  String get semesterOtherLabel;

  /// No description provided for @courseCount.
  ///
  /// In id, this message translates to:
  /// **'{count} mata kuliah'**
  String courseCount(int count);

  /// No description provided for @openTasksCount.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas'**
  String openTasksCount(int count);

  /// No description provided for @tasksDoneOf.
  ///
  /// In id, this message translates to:
  /// **'{done} dari {total} tugas selesai'**
  String tasksDoneOf(int done, int total);

  /// No description provided for @semesterOverdue.
  ///
  /// In id, this message translates to:
  /// **'{count} terlambat'**
  String semesterOverdue(int count);

  /// No description provided for @manageCoursesLabel.
  ///
  /// In id, this message translates to:
  /// **'Kelola Mata Kuliah'**
  String get manageCoursesLabel;

  /// No description provided for @courseListTitle.
  ///
  /// In id, this message translates to:
  /// **'Mata Kuliah Semester Ini'**
  String get courseListTitle;

  /// No description provided for @makeActiveLabel.
  ///
  /// In id, this message translates to:
  /// **'Jadikan Aktif'**
  String get makeActiveLabel;

  /// No description provided for @noSemesterTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada semester'**
  String get noSemesterTitle;

  /// No description provided for @noSemesterBody.
  ///
  /// In id, this message translates to:
  /// **'Buat semester pertamamu untuk mengelompokkan mata kuliah.'**
  String get noSemesterBody;

  /// No description provided for @semesterCreated.
  ///
  /// In id, this message translates to:
  /// **'Semester dibuat'**
  String get semesterCreated;

  /// No description provided for @semesterDeleted.
  ///
  /// In id, this message translates to:
  /// **'Semester dihapus'**
  String get semesterDeleted;

  /// No description provided for @semesterDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semester?'**
  String get semesterDeleteTitle;

  /// No description provided for @semesterDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Semua kategori di semester ini dihapus beserta jadwal, catatan, nilai dan absensinya. Tugasnya pindah ke Kotak Masuk. Tindakan ini tidak bisa dibatalkan.'**
  String get semesterDeleteBody;

  /// No description provided for @editSemesterLabel.
  ///
  /// In id, this message translates to:
  /// **'Ubah nama semester'**
  String get editSemesterLabel;

  /// No description provided for @clearDeadline.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get clearDeadline;

  /// No description provided for @resetLabel.
  ///
  /// In id, this message translates to:
  /// **'Atur Ulang'**
  String get resetLabel;

  /// No description provided for @statusLabel.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @pendingLabel.
  ///
  /// In id, this message translates to:
  /// **'Belum Selesai'**
  String get pendingLabel;

  /// No description provided for @doneLabel.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get doneLabel;

  /// No description provided for @sortLabel.
  ///
  /// In id, this message translates to:
  /// **'Urutkan'**
  String get sortLabel;

  /// No description provided for @sortDeadlineAsc.
  ///
  /// In id, this message translates to:
  /// **'Deadline terdekat dulu'**
  String get sortDeadlineAsc;

  /// No description provided for @sortDeadlineDesc.
  ///
  /// In id, this message translates to:
  /// **'Deadline terjauh dulu'**
  String get sortDeadlineDesc;

  /// No description provided for @sortCreatedDesc.
  ///
  /// In id, this message translates to:
  /// **'Terbaru dibuat dulu'**
  String get sortCreatedDesc;

  /// No description provided for @sortPriorityHighFirst.
  ///
  /// In id, this message translates to:
  /// **'Prioritas tertinggi dulu'**
  String get sortPriorityHighFirst;

  /// No description provided for @groupByCategory.
  ///
  /// In id, this message translates to:
  /// **'Kelompokkan per kategori'**
  String get groupByCategory;

  /// No description provided for @listViewLabel.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get listViewLabel;

  /// No description provided for @noFilterMatch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tugas yang cocok dengan filter ini.'**
  String get noFilterMatch;

  /// No description provided for @noCategoryFallback.
  ///
  /// In id, this message translates to:
  /// **'Tanpa kategori'**
  String get noCategoryFallback;

  /// No description provided for @tapToCheckUpdates.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk memeriksa versi terbaru'**
  String get tapToCheckUpdates;

  /// No description provided for @autoUpdateCheckTitle.
  ///
  /// In id, this message translates to:
  /// **'Periksa pembaruan otomatis'**
  String get autoUpdateCheckTitle;

  /// No description provided for @autoUpdateCheckSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Sekali sehari saat membuka aplikasi; tidak mengirim data'**
  String get autoUpdateCheckSubtitle;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembaruan tersedia'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In id, this message translates to:
  /// **'Lekas {version} sudah ada. Unduh dan pasang APK terbaru agar aplikasi selalu paling baru.'**
  String updateAvailableBody(String version);

  /// No description provided for @updateAvailableShort.
  ///
  /// In id, this message translates to:
  /// **'Pembaruan tersedia: {version}'**
  String updateAvailableShort(String version);

  /// No description provided for @updateDownload.
  ///
  /// In id, this message translates to:
  /// **'Unduh'**
  String get updateDownload;

  /// No description provided for @updateLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti'**
  String get updateLater;

  /// No description provided for @appUpToDate.
  ///
  /// In id, this message translates to:
  /// **'Kamu memakai versi terbaru ({version})'**
  String appUpToDate(String version);

  /// No description provided for @updateCheckFailed.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa memeriksa pembaruan. Periksa koneksi internet.'**
  String get updateCheckFailed;

  /// No description provided for @kategoriTitle.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get kategoriTitle;

  /// No description provided for @addCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori Baru'**
  String get addCategory;

  /// No description provided for @categoryNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori'**
  String get categoryNameLabel;

  /// No description provided for @kategoriEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori. Buat untuk organisasi, kepanitiaan, komunitas, atau apa pun.'**
  String get kategoriEmpty;

  /// No description provided for @uncategorizedInfo.
  ///
  /// In id, this message translates to:
  /// **'Tugas tanpa kategori tersimpan di sini'**
  String get uncategorizedInfo;

  /// No description provided for @mataKuliahTitle.
  ///
  /// In id, this message translates to:
  /// **'Mata Kuliah'**
  String get mataKuliahTitle;

  /// No description provided for @addCourse.
  ///
  /// In id, this message translates to:
  /// **'Mata Kuliah Baru'**
  String get addCourse;

  /// No description provided for @bringItemLabel.
  ///
  /// In id, this message translates to:
  /// **'Bawaan'**
  String get bringItemLabel;

  /// No description provided for @addBringItem.
  ///
  /// In id, this message translates to:
  /// **'Tambah bawaan'**
  String get addBringItem;

  /// No description provided for @editBringItem.
  ///
  /// In id, this message translates to:
  /// **'Ubah bawaan'**
  String get editBringItem;

  /// No description provided for @bringItemDeleted.
  ///
  /// In id, this message translates to:
  /// **'Bawaan dihapus'**
  String get bringItemDeleted;

  /// No description provided for @emptyBringList.
  ///
  /// In id, this message translates to:
  /// **'Belum ada bawaan untuk {name}.'**
  String emptyBringList(String name);

  /// No description provided for @broughtLabel.
  ///
  /// In id, this message translates to:
  /// **'Sudah dibawa'**
  String get broughtLabel;

  /// No description provided for @attendanceHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get attendanceHistory;

  /// No description provided for @attendanceHistoryEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan kehadiran.'**
  String get attendanceHistoryEmpty;

  /// No description provided for @editAttendanceRecord.
  ///
  /// In id, this message translates to:
  /// **'Ubah catatan'**
  String get editAttendanceRecord;

  /// No description provided for @deleteAttendanceRecord.
  ///
  /// In id, this message translates to:
  /// **'Hapus catatan?'**
  String get deleteAttendanceRecord;

  /// No description provided for @deleteAttendanceRecordBody.
  ///
  /// In id, this message translates to:
  /// **'Catatan kehadiran ini akan dihapus.'**
  String get deleteAttendanceRecordBody;

  /// No description provided for @attendanceRecordDeleted.
  ///
  /// In id, this message translates to:
  /// **'Catatan dihapus'**
  String get attendanceRecordDeleted;

  /// No description provided for @attendanceNoteLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get attendanceNoteLabel;

  /// No description provided for @dateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get dateLabel;

  /// No description provided for @editLabel.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get editLabel;

  /// No description provided for @weekdayLabel.
  ///
  /// In id, this message translates to:
  /// **'Hari'**
  String get weekdayLabel;

  /// No description provided for @classKindLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get classKindLabel;

  /// No description provided for @kindLecture.
  ///
  /// In id, this message translates to:
  /// **'Kuliah'**
  String get kindLecture;

  /// No description provided for @kindLab.
  ///
  /// In id, this message translates to:
  /// **'Praktikum'**
  String get kindLab;

  /// No description provided for @classScheduleHint.
  ///
  /// In id, this message translates to:
  /// **'Kuliah dan praktikum beserta jam dan ruangnya'**
  String get classScheduleHint;

  /// No description provided for @addClassSlot.
  ///
  /// In id, this message translates to:
  /// **'Tambah Jadwal'**
  String get addClassSlot;

  /// No description provided for @editClassSlot.
  ///
  /// In id, this message translates to:
  /// **'Ubah Jadwal'**
  String get editClassSlot;

  /// No description provided for @deleteClassSlot.
  ///
  /// In id, this message translates to:
  /// **'Hapus Jadwal?'**
  String get deleteClassSlot;

  /// No description provided for @deleteClassSlotBody.
  ///
  /// In id, this message translates to:
  /// **'Jadwal ini akan dihapus.'**
  String get deleteClassSlotBody;

  /// No description provided for @classTimeOrderError.
  ///
  /// In id, this message translates to:
  /// **'Jam selesai harus setelah jam mulai.'**
  String get classTimeOrderError;

  /// No description provided for @monShort.
  ///
  /// In id, this message translates to:
  /// **'Sen'**
  String get monShort;

  /// No description provided for @tueShort.
  ///
  /// In id, this message translates to:
  /// **'Sel'**
  String get tueShort;

  /// No description provided for @wedShort.
  ///
  /// In id, this message translates to:
  /// **'Rab'**
  String get wedShort;

  /// No description provided for @thuShort.
  ///
  /// In id, this message translates to:
  /// **'Kam'**
  String get thuShort;

  /// No description provided for @friShort.
  ///
  /// In id, this message translates to:
  /// **'Jum'**
  String get friShort;

  /// No description provided for @satShort.
  ///
  /// In id, this message translates to:
  /// **'Sab'**
  String get satShort;

  /// No description provided for @sunShort.
  ///
  /// In id, this message translates to:
  /// **'Min'**
  String get sunShort;

  /// No description provided for @agendaTitle.
  ///
  /// In id, this message translates to:
  /// **'Agenda'**
  String get agendaTitle;

  /// No description provided for @agendaEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kelas atau tugas pada hari ini.'**
  String get agendaEmpty;

  /// No description provided for @seeAllTasks.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get seeAllTasks;

  /// No description provided for @filesLabel.
  ///
  /// In id, this message translates to:
  /// **'Berkas'**
  String get filesLabel;

  /// No description provided for @filesSetupTitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan berkas di penyimpanan HP'**
  String get filesSetupTitle;

  /// No description provided for @filesSetupBody.
  ///
  /// In id, this message translates to:
  /// **'Lekas menyimpan modul, catatan, soal, dan arsip di folder pada penyimpanan HP kamu, bukan di dalam aplikasi. Pilih folder untuk menyimpannya.'**
  String get filesSetupBody;

  /// No description provided for @pickFilesFolder.
  ///
  /// In id, this message translates to:
  /// **'Pilih folder'**
  String get pickFilesFolder;

  /// No description provided for @filesImportFailed.
  ///
  /// In id, this message translates to:
  /// **'Berkas tidak bisa diimpor. Pilih folder lagi atau coba berkas lain.'**
  String get filesImportFailed;

  /// No description provided for @newFolderLabel.
  ///
  /// In id, this message translates to:
  /// **'Folder baru'**
  String get newFolderLabel;

  /// No description provided for @folderNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama folder'**
  String get folderNameLabel;

  /// No description provided for @folderAlreadyExists.
  ///
  /// In id, this message translates to:
  /// **'Folder dengan nama itu sudah ada.'**
  String get folderAlreadyExists;

  /// No description provided for @deleteFolder.
  ///
  /// In id, this message translates to:
  /// **'Hapus folder?'**
  String get deleteFolder;

  /// No description provided for @deleteFile.
  ///
  /// In id, this message translates to:
  /// **'Hapus berkas?'**
  String get deleteFile;

  /// No description provided for @deleteFolderBody.
  ///
  /// In id, this message translates to:
  /// **'Semua isi folder akan dihapus.'**
  String get deleteFolderBody;

  /// No description provided for @filesOpenFailed.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada aplikasi di HP ini yang bisa membuka berkas ini.'**
  String get filesOpenFailed;

  /// No description provided for @renameFolder.
  ///
  /// In id, this message translates to:
  /// **'Ubah nama folder'**
  String get renameFolder;

  /// No description provided for @renameFile.
  ///
  /// In id, this message translates to:
  /// **'Ubah nama berkas'**
  String get renameFile;

  /// No description provided for @importFileLabel.
  ///
  /// In id, this message translates to:
  /// **'Impor berkas'**
  String get importFileLabel;

  /// No description provided for @filesOpenInFileManager.
  ///
  /// In id, this message translates to:
  /// **'Berkas tersimpan di penyimpanan HP; kelola bebas dengan file manager apa pun.'**
  String get filesOpenInFileManager;

  /// No description provided for @folderEmpty.
  ///
  /// In id, this message translates to:
  /// **'Folder ini kosong.'**
  String get folderEmpty;

  /// No description provided for @folderLabel.
  ///
  /// In id, this message translates to:
  /// **'Folder'**
  String get folderLabel;

  /// No description provided for @fileImported.
  ///
  /// In id, this message translates to:
  /// **'Berkas diimpor'**
  String get fileImported;

  /// No description provided for @filesSurviveDeletion.
  ///
  /// In id, this message translates to:
  /// **'Berkas tertinggal di penyimpanan HP dan tidak terhapus saat mata kuliah dihapus.'**
  String get filesSurviveDeletion;

  /// No description provided for @unableToCreateFolder.
  ///
  /// In id, this message translates to:
  /// **'Folder tidak bisa dibuat'**
  String get unableToCreateFolder;

  /// No description provided for @permissionLostFolder.
  ///
  /// In id, this message translates to:
  /// **'Akses ke folder yang dipilih hilang; pilih ulang'**
  String get permissionLostFolder;

  /// No description provided for @filesOpFailed.
  ///
  /// In id, this message translates to:
  /// **'Itu tidak berhasil'**
  String get filesOpFailed;
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
