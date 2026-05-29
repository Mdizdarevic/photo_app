import '../../presentation/core/app_constants.dart';
import 'user_entity.dart';

// This is the OPEN/CLOSE PRINCIPLE (OCP) base layer
// This class is now CLOSED for modification.

// LISKOV SUBSTITUTION PRINCIPLE
abstract class PackageStrategy {
  PackageTier get tier;
  int get dailyUploadLimit;
  double get maxFileSizeMB;
  List<String> get allowedFormats;
  List<String> get allowedFilters;
}

// OCP EXTENSION 1: Free Strategy
class FreePackageStrategy extends PackageStrategy {
  @override
  PackageTier get tier => PackageTier.free;
  @override
  int get dailyUploadLimit => AppConstants.freeDailyLimit;
  @override
  double get maxFileSizeMB => AppConstants.freeMaxSizeMB;
  @override
  List<String> get allowedFormats => ['JPG'];
  @override
  List<String> get allowedFilters => ['Resize'];
}

// OCP EXTENSION 2: Pro Strategy
class ProPackageStrategy extends PackageStrategy {
  @override
  PackageTier get tier => PackageTier.pro;
  @override
  int get dailyUploadLimit => AppConstants.proDailyLimit;
  @override
  double get maxFileSizeMB => AppConstants.proMaxSizeMB;
  @override
  List<String> get allowedFormats => ['PNG', 'JPG'];
  @override
  List<String> get allowedFilters => ['Resize', 'Sepia'];
}

// OCP EXTENSION 3: Gold Strategy
class GoldPackageStrategy extends PackageStrategy {
  @override
  PackageTier get tier => PackageTier.gold;
  @override
  int get dailyUploadLimit => AppConstants.goldDailyLimit;
  @override
  double get maxFileSizeMB => AppConstants.goldMaxSizeMB;
  @override
  List<String> get allowedFormats => AppConstants.supportedFormats;
  @override
  List<String> get allowedFilters => AppConstants.availableFilters;
}

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

  // Refactoring the switch cases from below (seen below) with strategies
  factory PackageConfig.fromStrategy(PackageStrategy strategy) {
    return PackageConfig(
      tier: strategy.tier,
      dailyUploadLimit: strategy.dailyUploadLimit,
      maxFileSizeMB: strategy.maxFileSizeMB,
      allowedFormats: strategy.allowedFormats,
      allowedFilters: strategy.allowedFilters,
    );
  }

  // factory PackageConfig.fromTier(PackageTier tier) {
  //   switch (tier) {
  //     case PackageTier.pro:
  //       return PackageConfig(
  //         tier: PackageTier.pro,
  //         dailyUploadLimit: AppConstants.proDailyLimit,
  //         maxFileSizeMB: AppConstants.proMaxSizeMB,
  //         allowedFormats: ['PNG', 'JPG'],
  //         allowedFilters: ['Resize', 'Sepia'],
  //       );
  //     case PackageTier.gold:
  //       return PackageConfig(
  //         tier: PackageTier.gold,
  //         dailyUploadLimit: AppConstants.goldDailyLimit,
  //         maxFileSizeMB: AppConstants.goldMaxSizeMB,
  //         allowedFormats: AppConstants.supportedFormats,
  //         allowedFilters: AppConstants.availableFilters,
  //       );
  //     case PackageTier.free:
  //     default:
  //       return PackageConfig(
  //         tier: PackageTier.free,
  //         dailyUploadLimit: AppConstants.freeDailyLimit,
  //         maxFileSizeMB: AppConstants.freeMaxSizeMB,
  //         allowedFormats: ['JPG'],
  //         allowedFilters: ['Resize'],
  //       );
  //   }
  // }
}