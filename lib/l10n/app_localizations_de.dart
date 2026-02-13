// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'TasksSphere';

  @override
  String get loginWelcome => 'Willkommen zurück';

  @override
  String get loginSubtitle => 'Melden Sie sich an, um fortzufahren.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Passwort';

  @override
  String get loginButton => 'LOG IN';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get register => 'Registrieren';

  @override
  String get noAccount => 'Noch kein Konto? Hier registrieren';

  @override
  String get alreadyHaveAccount => 'Bereits ein Konto? Hier anmelden';

  @override
  String get passwordConfirmation => 'Passwort bestätigen';

  @override
  String get registerButton => 'REGISTRIEREN';

  @override
  String get registrationFailed =>
      'Registrierung fehlgeschlagen. Bitte überprüfe deine Eingaben.';

  @override
  String get sendResetLink => 'RESET-LINK SENDEN';

  @override
  String get forgotPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get forgotPasswordSubtitle =>
      'Gib deine E-Mail-Adresse ein und wir senden dir einen Link zum Zurücksetzen deines Passworts.';

  @override
  String get resetLinkSent =>
      'Reset-Link wurde gesendet, falls die E-Mail-Adresse existiert.';

  @override
  String get backToLogin => 'Zurück zum Login';

  @override
  String get loginFailed =>
      'Login fehlgeschlagen. Bitte prüfen Sie Ihre Daten.';

  @override
  String get taskOverview => 'Aufgabenübersicht';

  @override
  String tasksToday(int count) {
    return 'Du hast heute $count offene Aufgaben.';
  }

  @override
  String get noTasksTitle => 'Alles erledigt!';

  @override
  String get noTasksSubtitle => 'Zeit zum Entspannen.';

  @override
  String get overdue => 'Überfällig';

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get later => 'Später';

  @override
  String get noDate => 'Ohne Datum';

  @override
  String get completedRecently => 'Zuletzt erledigt';

  @override
  String completedAtMinutes(int minutes) {
    return 'Erledigt vor $minutes Min.';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get create => 'Erstellen';

  @override
  String get newTask => 'Neuer Task';

  @override
  String get whatToDo => 'Was ist zu tun?';

  @override
  String get detailsOptional => 'Details (optional)';

  @override
  String get tasks => 'Aufgaben';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get logout => 'Abmelden';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get newPasswordOptional => 'Neues Passwort (optional)';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get profileUpdated => 'Profil erfolgreich aktualisiert.';

  @override
  String get profileUpdateFailed => 'Fehler beim Aktualisieren des Profils.';

  @override
  String get uhr => 'UHR';

  @override
  String get personalInfo => 'Persönliche Informationen';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get leaveBlank => 'Leer lassen, wenn Sie es nicht ändern möchten.';

  @override
  String get enterFirstName => 'Bitte Vorname eingeben';

  @override
  String get enterLastName => 'Bitte Nachname eingeben';

  @override
  String get invalidEmail => 'Ungültige E-Mail';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordTooShort => 'Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get language => 'Sprache';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'Englisch';
}
