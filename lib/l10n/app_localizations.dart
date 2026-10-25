import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('id'),
    Locale('en'),
  ];

  String get todayTitle;
  String tasksCount(int count);
  String get inboxTitle;
  String get spacesTitle;
  String get calendarTitle;
  String get settingsTitle;
  String get quickAddHint;
  String get emptyToday;
  String get undo;
  String get done;
  String get snooze1h;
  String morningSummary(int classes, int tasks);
  String get addSpace;
  String get cancel;
  String get save;
  String get spaceName;
  String get spaceCode;
  String get taskTitle;
  String get taskNotes;
  String get taskContainer;
  String get taskDeadline;
  String get taskPriority;
  String get priorityLow;
  String get priorityMedium;
  String get priorityHigh;
  String get pickDate;
  String get addTask;
  String get editTask;
  String get taskDetail;
  String get language;
  String get darkMode;
  String get exportBackup;
  String get importBackup;
  String get checkReminder;
  String get welcome;
  String get addFirstSpace;
  String get start;
  String get back;
  String get saveContinue;
  String get finish;
  String get chooseLanguage;
  String get indonesian;
  String get english;
  String get chooseLevel;
  String get college;
  String get school;
  String get spaceNameLabel;
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
      <String>['id', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'id':
      return AppLocalizationsId();
    case 'en':
      return AppLocalizationsEn();
  }
  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale".',
  );
}
