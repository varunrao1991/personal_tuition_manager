class AppPaddings {
  static const double tinyPadding = 4.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
}

class AppSizes {
  static const double buttonHeight = 48.0;
  static const double cardHeight = 100.0;
  static const double textFieldHeight = 56.0;

  static const double smallSize = 8.0;
  static const double mediumSize = 16.0;
  static const double largeSize = 24.0;
}

class AppMargins {
  static const double tinyMargin = 8.0;
  static const double smallMargin = 8.0;
  static const double mediumMargin = 16.0;
  static const double largeMargin = 24.0;
}

class AppElevations {
  static const double low = 2.0;
  static const double medium = 4.0;
  static const double high = 8.0;
}

class ButtonSizes {
  static const double smallPadding = 10.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 20.0;
}

class RegularExpressions {
  static final passwordRegex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  static final mobileRegex = RegExp(r'^\d{10}$');
  static final otpRegex = RegExp(r'^\d{4}$');
  static final nameRegex = RegExp(r'^[a-zA-Z\s]{3,}$');
}
