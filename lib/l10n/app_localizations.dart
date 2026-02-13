import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

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
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'TasksSphere'**
  String get appTitle;

  /// No description provided for @loginWelcome.
  ///
  /// In de, this message translates to:
  /// **'Willkommen zurück'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Melden Sie sich an, um fortzufahren.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In de, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In de, this message translates to:
  /// **'LOG IN'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get forgotPassword;

  /// No description provided for @register.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get register;

  /// No description provided for @noAccount.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Konto? Hier registrieren'**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In de, this message translates to:
  /// **'Bereits ein Konto? Hier anmelden'**
  String get alreadyHaveAccount;

  /// No description provided for @passwordConfirmation.
  ///
  /// In de, this message translates to:
  /// **'Passwort bestätigen'**
  String get passwordConfirmation;

  /// No description provided for @registerButton.
  ///
  /// In de, this message translates to:
  /// **'REGISTRIEREN'**
  String get registerButton;

  /// No description provided for @registrationFailed.
  ///
  /// In de, this message translates to:
  /// **'Registrierung fehlgeschlagen. Bitte überprüfe deine Eingaben.'**
  String get registrationFailed;

  /// No description provided for @sendResetLink.
  ///
  /// In de, this message translates to:
  /// **'RESET-LINK SENDEN'**
  String get sendResetLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In de, this message translates to:
  /// **'Passwort zurücksetzen'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Gib deine E-Mail-Adresse ein und wir senden dir einen Link zum Zurücksetzen deines Passworts.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @resetLinkSent.
  ///
  /// In de, this message translates to:
  /// **'Reset-Link wurde gesendet, falls die E-Mail-Adresse existiert.'**
  String get resetLinkSent;

  /// No description provided for @backToLogin.
  ///
  /// In de, this message translates to:
  /// **'Zurück zum Login'**
  String get backToLogin;

  /// No description provided for @loginFailed.
  ///
  /// In de, this message translates to:
  /// **'Login fehlgeschlagen. Bitte prüfen Sie Ihre Daten.'**
  String get loginFailed;

  /// No description provided for @taskOverview.
  ///
  /// In de, this message translates to:
  /// **'Aufgabenübersicht'**
  String get taskOverview;

  /// No description provided for @tasksToday.
  ///
  /// In de, this message translates to:
  /// **'Du hast heute {count} offene Aufgaben.'**
  String tasksToday(int count);

  /// No description provided for @noTasksTitle.
  ///
  /// In de, this message translates to:
  /// **'Alles erledigt!'**
  String get noTasksTitle;

  /// No description provided for @noTasksSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Zeit zum Entspannen.'**
  String get noTasksSubtitle;

  /// No description provided for @overdue.
  ///
  /// In de, this message translates to:
  /// **'Überfällig'**
  String get overdue;

  /// No description provided for @today.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In de, this message translates to:
  /// **'Morgen'**
  String get tomorrow;

  /// No description provided for @later.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get later;

  /// No description provided for @noDate.
  ///
  /// In de, this message translates to:
  /// **'Ohne Datum'**
  String get noDate;

  /// No description provided for @completedRecently.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt erledigt'**
  String get completedRecently;

  /// No description provided for @completedAtMinutes.
  ///
  /// In de, this message translates to:
  /// **'Erledigt vor {minutes} Min.'**
  String completedAtMinutes(int minutes);

  /// No description provided for @add.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In de, this message translates to:
  /// **'Erstellen'**
  String get create;

  /// No description provided for @newTask.
  ///
  /// In de, this message translates to:
  /// **'Neuer Task'**
  String get newTask;

  /// No description provided for @whatToDo.
  ///
  /// In de, this message translates to:
  /// **'Was ist zu tun?'**
  String get whatToDo;

  /// No description provided for @detailsOptional.
  ///
  /// In de, this message translates to:
  /// **'Details (optional)'**
  String get detailsOptional;

  /// No description provided for @tasks.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben'**
  String get tasks;

  /// No description provided for @editProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil bearbeiten'**
  String get editProfile;

  /// No description provided for @logout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get logout;

  /// No description provided for @firstName.
  ///
  /// In de, this message translates to:
  /// **'Vorname'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In de, this message translates to:
  /// **'Nachname'**
  String get lastName;

  /// No description provided for @newPasswordOptional.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort (optional)'**
  String get newPasswordOptional;

  /// No description provided for @confirmPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort bestätigen'**
  String get confirmPassword;

  /// No description provided for @saveChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In de, this message translates to:
  /// **'Profil erfolgreich aktualisiert.'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Aktualisieren des Profils.'**
  String get profileUpdateFailed;

  /// No description provided for @uhr.
  ///
  /// In de, this message translates to:
  /// **'UHR'**
  String get uhr;

  /// No description provided for @personalInfo.
  ///
  /// In de, this message translates to:
  /// **'Persönliche Informationen'**
  String get personalInfo;

  /// No description provided for @changePassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort ändern'**
  String get changePassword;

  /// No description provided for @leaveBlank.
  ///
  /// In de, this message translates to:
  /// **'Leer lassen, wenn Sie es nicht ändern möchten.'**
  String get leaveBlank;

  /// No description provided for @enterFirstName.
  ///
  /// In de, this message translates to:
  /// **'Bitte Vorname eingeben'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In de, this message translates to:
  /// **'Bitte Nachname eingeben'**
  String get enterLastName;

  /// No description provided for @invalidEmail.
  ///
  /// In de, this message translates to:
  /// **'Ungültige E-Mail'**
  String get invalidEmail;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In de, this message translates to:
  /// **'Passwörter stimmen nicht überein'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In de, this message translates to:
  /// **'Passwort muss mindestens 8 Zeichen lang sein'**
  String get passwordTooShort;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// No description provided for @german.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @english.
  ///
  /// In de, this message translates to:
  /// **'Englisch'**
  String get english;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
