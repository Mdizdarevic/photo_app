import '../../presentation/core/app_constants.dart';
import 'user_entity.dart';

class PackageConfig {
  final PackageTier tier;
  final int dailyUploadLimit;
  final double maxFileSizeMB;
  final List<String> allowedFormats;
  final List<String> allowedFilters;

  PackageConfig({
    required this.tier,
    required this.dailyUploadLimit,
    required this.maxFileSizeMB,
    required this.allowedFormats,
    required this.allowedFilters,
  });

  factory PackageConfig.fromTier(PackageTier tier) {
    switch (tier) {
      case PackageTier.pro:
        return PackageConfig(
          tier: PackageTier.pro,
          dailyUploadLimit: AppConstants.proDailyLimit,
          maxFileSizeMB: AppConstants.proMaxSizeMB,
          allowedFormats: ['PNG', 'JPG'],
          allowedFilters: ['Resize', 'Sepia'],
        );
      case PackageTier.gold:
        return PackageConfig(
          tier: PackageTier.gold,
          dailyUploadLimit: AppConstants.goldDailyLimit,
          maxFileSizeMB: AppConstants.goldMaxSizeMB,
          allowedFormats: AppConstants.supportedFormats,
          allowedFilters: AppConstants.availableFilters,
        );
      case PackageTier.free:
      default:
        return PackageConfig(
          tier: PackageTier.free,
          dailyUploadLimit: AppConstants.freeDailyLimit,
          maxFileSizeMB: AppConstants.freeMaxSizeMB,
          allowedFormats: ['JPG'],
          allowedFilters: ['Resize'],
        );
    }
  }
}