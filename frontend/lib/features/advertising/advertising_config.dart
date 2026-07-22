import 'package:flutter/foundation.dart';

enum AdvertisingMode { disabled, test, production }

enum AdvertisingConsentStatus { unknown, notRequired, granted, denied }

class AdvertisingConfig {
  const AdvertisingConfig({
    required this.mode,
    this.bannerAdUnitId,
    this.interstitialAdUnitId,
    this.rewardedAdUnitId,
    this.nonPersonalizedAds = true,
  });

  static const _modeValue = String.fromEnvironment(
    'STUDYHUB_AD_MODE',
    defaultValue: 'disabled',
  );
  static const _bannerId = String.fromEnvironment('STUDYHUB_AD_BANNER_ID');
  static const _interstitialId = String.fromEnvironment(
    'STUDYHUB_AD_INTERSTITIAL_ID',
  );
  static const _rewardedId = String.fromEnvironment('STUDYHUB_AD_REWARDED_ID');

  static AdvertisingConfig fromEnvironment({
    String mode = _modeValue,
    String bannerAdUnitId = _bannerId,
    String interstitialAdUnitId = _interstitialId,
    String rewardedAdUnitId = _rewardedId,
  }) {
    final resolvedMode = switch (mode.trim().toLowerCase()) {
      'disabled' || '' => AdvertisingMode.disabled,
      'test' => AdvertisingMode.test,
      'production' => AdvertisingMode.production,
      _ => throw StateError('Unsupported STUDYHUB_AD_MODE: $mode'),
    };

    if (resolvedMode == AdvertisingMode.production) {
      final ids = [bannerAdUnitId, interstitialAdUnitId, rewardedAdUnitId];
      if (ids.any((id) => id.trim().isEmpty)) {
        throw StateError(
          'Production advertising requires banner, interstitial, and rewarded ad unit IDs.',
        );
      }
    }

    return AdvertisingConfig(
      mode: resolvedMode,
      bannerAdUnitId: resolvedMode == AdvertisingMode.test
          ? _testBannerId
          : bannerAdUnitId.trim(),
      interstitialAdUnitId: resolvedMode == AdvertisingMode.test
          ? _testInterstitialId
          : interstitialAdUnitId.trim(),
      rewardedAdUnitId: resolvedMode == AdvertisingMode.test
          ? _testRewardedId
          : rewardedAdUnitId.trim(),
    );
  }

  final AdvertisingMode mode;
  final String? bannerAdUnitId;
  final String? interstitialAdUnitId;
  final String? rewardedAdUnitId;
  final bool nonPersonalizedAds;

  bool get enabled => mode != AdvertisingMode.disabled;
  bool get isTestMode => mode == AdvertisingMode.test;

  static String get _testBannerId => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'ca-app-pub-3940256099942544/2934735716',
    _ => 'ca-app-pub-3940256099942544/6300978111',
  };

  static String get _testInterstitialId => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'ca-app-pub-3940256099942544/4411468910',
    _ => 'ca-app-pub-3940256099942544/1033173712',
  };

  static String get _testRewardedId => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'ca-app-pub-3940256099942544/1712485313',
    _ => 'ca-app-pub-3940256099942544/5224354917',
  };
}
