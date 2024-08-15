import 'dart:developer';

class FormValidation {
  // Common Validation Function
  String? commonValidation({
    required String? input,
    required bool isMandorty,
    required String formName,
    required bool isOnlyCharter,
  }) {
    if (input == null) {
      if (isMandorty) {
        return "$formName is Must";
      }
    } else {
      input = input.trim();
      if (isMandorty || input.isNotEmpty) {
        if (input.isEmpty) {
          return "$formName is Must";
        } else if (isOnlyCharter) {
          if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(input)) {
            return "$formName is characters only allowed";
          } else {
            log("False");
          }
        }
      }
    }
    return null;
  }

  String? emailValidation(
      {required String input, required lableName, required bool isMandorty}) {
    input = input.trim();
    String? error;
    if (isMandorty || input.isNotEmpty) {
      RegExp emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
      if (!emailRegex.hasMatch(input)) {
        error = 'Please enter a valid email address';
      }
    }
    return error;
  }

  String? passwordValidation(
      {required String input, required int minLength, required int maxLength}) {
    input = input.trim();
    if (input.isEmpty) {
      return "Password is Must";
    } else if (input.length < minLength) {
      return "Password at least $minLength characters long";
    } else if (!RegExp(r'[A-Z]').hasMatch(input)) {
      return PasswordError.upperCase.message;
    } else if (!RegExp(r'[a-z]').hasMatch(input)) {
      return PasswordError.lowerCase.message;
    } else if (!RegExp(r'[0-9]').hasMatch(input)) {
      return PasswordError.digit.message;
    } else if (!RegExp(r'[!@#\$&*~]').hasMatch(input)) {
      return PasswordError.specialCharacter.message;
    } else if (!RegExp(r'.{8,}').hasMatch(input)) {
      return PasswordError.eigthCharacter.message;
    } else {
      return null;
    }
  }

  String? aadhaarValidation(String input, bool isMandorty) {
    input = input.trim();
    input = input.replaceAll(RegExp(r"\s+"), "");
    if (isMandorty || input.isNotEmpty) {
      if (input.isEmpty) {
        return "Aadhaar is Must";
      } else if (!RegExp(r'^[2-9]{1}[0-9]{3}[0-9]{4}[0-9]{4}$')
          .hasMatch(input)) {
        return "Aadhaar is Not Valid";
      }
    }
    return null;
  }

  String? phoneValidation({
    required String input,
    required bool isMandorty,
    required String lableName,
  }) {
    input.trim();
    input = input.replaceAll(RegExp(r"\s+"), "");
    if (isMandorty || input.isNotEmpty) {
      if (!RegExp(r'^(?:[+0]9)?[0-9]{10}$').hasMatch(input)) {
        return "$lableName is Not Match";
      }
    }
    return null;
  }

  String? pincodeValidation({required String input, required bool isMandorty}) {
    if (isMandorty || input.isNotEmpty) {
      if (input.length != 6) {
        return "Pincode Not Valid";
      } else if (!RegExp(r"^[0-9]+$").hasMatch(input)) {
        return "Pincode Not Valid";
      }
    }
    return null;
  }

  String? dateValidation({required String input, required String lableName}) {
    if (input.isEmpty) {
      return "$lableName is Must";
    }
    return null;
  }
}

enum PasswordError {
  upperCase('Must contain at least one uppercase'),
  lowerCase('Must contain at least one lowercase'),
  digit('Must contain at least one digit'),
  eigthCharacter('Must be at least 8 characters in length'),
  specialCharacter('Contain at least one special character: !@#\\\$&*~');

  final String message;

  const PasswordError(this.message);
}
