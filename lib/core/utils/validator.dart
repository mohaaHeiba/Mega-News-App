import 'package:mega_news_app/core/utils/app_context_helper.dart';

class Validator {
  final AppContextHelper app;

  Validator(this.app);

  // Validate Full Name
  String? validateName(String fullName) {
    final s = app.s;
    if (fullName.isEmpty) return s.enterName;
    if (fullName.length < 3) return s.nameMinChars;
    return null;
  }

  // Validate Email
  String? validateEmail(String email) {
    final s = app.s;
    if (email.isEmpty) return s.enterEmail;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return s.invalidEmail;

    return null;
  }

  // Validate Password
  String? validatePassword(String password) {
    final s = app.s;
    if (password.isEmpty) return s.enterPassword;
    if (password.length < 6) return s.passwordMinChars;

    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      return s.passwordUpperNumber;
    }

    return null;
  }

  // Validate Confirm Password
  String? validateConfirmPassword(String password, String confirmPassword) {
    final s = app.s;
    if (confirmPassword.isEmpty) return s.confirmPassword;
    if (password != confirmPassword) return s.passwordsNotMatch;
    return null;
  }
}
