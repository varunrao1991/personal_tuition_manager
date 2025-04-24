class AppPaddings {
  static const double tinyPadding = 2.0;
  static const double smallPadding = 4.0;
  static const double mediumPadding = 8.0;
  static const double largePadding = 12.0;
}

class AppSizes {
  static const double buttonHeight = 40.0;
  static const double cardHeight = 80.0;
  static const double textFieldHeight = 44.0;

  static const double smallSize = 4.0;
  static const double mediumSize = 8.0;
  static const double largeSize = 12.0;
}

class AppMargins {
  static const double tinyMargin = 4.0;
  static const double smallMargin = 4.0;
  static const double mediumMargin = 8.0;
  static const double largeMargin = 12.0;
}

class AppElevations {
  static const double low = 1.0;
  static const double medium = 2.0;
  static const double high = 4.0;
}

class ButtonSizes {
  static const double smallPadding = 6.0;
  static const double mediumPadding = 10.0;
  static const double largePadding = 14.0;
}

class AppBorderRadius {
  static const double smallRadius = 2.0;
  static const double mediumRadius = 4.0;
  static const double largeRadius = 6.0;
}

class RegularExpressions {
  static final passwordRegex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  static final mobileRegex = RegExp(r'^\d{10}$');
  static final otpRegex = RegExp(r'^\d{4}$');
  static final nameRegex = RegExp(r'^[a-zA-Z\s]{3,}$');
}