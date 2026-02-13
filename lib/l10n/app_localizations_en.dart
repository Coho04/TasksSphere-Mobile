// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TasksSphere';

  @override
  String get loginWelcome => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in to continue.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'LOG IN';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get register => 'Register';

  @override
  String get noAccount => 'Don\'t have an account? Register here';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login here';

  @override
  String get passwordConfirmation => 'Confirm Password';

  @override
  String get registerButton => 'REGISTER';

  @override
  String get registrationFailed =>
      'Registration failed. Please check your input.';

  @override
  String get sendResetLink => 'SEND RESET LINK';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address and we will send you a link to reset your password.';

  @override
  String get resetLinkSent => 'Reset link sent if the email address exists.';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get loginFailed => 'Login failed. Please check your data.';

  @override
  String get taskOverview => 'Task Overview';

  @override
  String tasksToday(int count) {
    return 'You have $count open tasks today.';
  }

  @override
  String get noTasksTitle => 'All done!';

  @override
  String get noTasksSubtitle => 'Time to relax.';

  @override
  String get overdue => 'Overdue';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get later => 'Later';

  @override
  String get noDate => 'No Date';

  @override
  String get completedRecently => 'Recently completed';

  @override
  String completedAtMinutes(int minutes) {
    return 'Completed $minutes min. ago';
  }

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get newTask => 'New Task';

  @override
  String get whatToDo => 'What\'s to do?';

  @override
  String get detailsOptional => 'Details (optional)';

  @override
  String get tasks => 'Tasks';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get logout => 'Logout';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get newPasswordOptional => 'New password (optional)';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get profileUpdated => 'Profile successfully updated.';

  @override
  String get profileUpdateFailed => 'Error updating profile.';

  @override
  String get uhr => 'O\'CLOCK';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get changePassword => 'Change Password';

  @override
  String get leaveBlank => 'Leave blank if you do not want to change it.';

  @override
  String get enterFirstName => 'Please enter first name';

  @override
  String get enterLastName => 'Please enter last name';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters long';

  @override
  String get language => 'Language';

  @override
  String get german => 'German';

  @override
  String get english => 'English';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get repetition => 'Repetition';

  @override
  String get once => 'Once';

  @override
  String get hourly => 'Hourly';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get weekdays => 'Weekdays';

  @override
  String get addTime => 'Add time';

  @override
  String get timesForInterval => 'Set times per interval:';

  @override
  String get timezone => 'Timezone';

  @override
  String get startAtOptional => 'Starts at (optional)';

  @override
  String get defaultToday => 'Default is today.';
}
