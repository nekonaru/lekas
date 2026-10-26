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
