class Validator {
  // Validate Full Name
  String? validateName(String fullName) {
    if (fullName.isEmpty) return "Please enter your name";
    if (fullName.length < 3) return "Name must be at least 3 characters";
    return null;
  }

  // Validate Email
  String? validateEmail(String email) {
    if (email.isEmpty) return "Please enter your email address";

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return "Please enter a valid email";

    return null;
  }

  //  Validate Password
  String? validatePassword(String password) {
    if (password.isEmpty) return "Please enter your password";
    if (password.length < 6) return "Password must be at least 6 characters";

    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      return "Password must contain at least one uppercase letter and one number";
    }

    return null;
  }

  //  Validate confirm Password
  String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) return "Please confirm your password";
    if (password != confirmPassword) return "Passwords do not match";
    return null;
  }
}
