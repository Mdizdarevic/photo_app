class AppConstants {
  static const String appName = "Pothole";

  static const String packageFree = "FREE";
  static const String packagePro = "PRO";
  static const String packageGold = "GOLD";

  static const int freeDailyLimit = 5;
  static const int proDailyLimit = 50;
  static const int goldDailyLimit = 999;

  static const double freeMaxSizeMB = 2.0;
  static const double proMaxSizeMB = 10.0;
  static const double goldMaxSizeMB = 100.0;
  static const bool useCloudStorage = false;

  static const int defaultThumbnailCount = 10;

  static const List<String> supportedFormats = ['PNG', 'JPG', 'BMP'];
  static const List<String> availableFilters = ['Resize', 'Sepia', 'Blur'];
}