import 'package:flutter/widgets.dart';

abstract interface class AdvertisingProvider {
  Future<void> initialize({required bool nonPersonalizedAds});

  Future<BannerAdHandle> loadBanner({
    required String adUnitId,
    required double availableWidth,
    required bool nonPersonalizedAds,
  });

  Future<InterstitialAdHandle> loadInterstitial({
    required String adUnitId,
    required bool nonPersonalizedAds,
  });

  Future<RewardedAdHandle> loadRewarded({
    required String adUnitId,
    required bool nonPersonalizedAds,
  });
}

abstract interface class BannerAdHandle {
  Size get size;
  Widget buildView();
  Future<void> dispose();
}

abstract interface class InterstitialAdHandle {
  Future<bool> show();
  Future<void> dispose();
}

abstract interface class RewardedAdHandle {
  Future<bool> show();
  Future<void> dispose();
}

class AdvertisingUnavailableException implements Exception {
  const AdvertisingUnavailableException(this.message);

  final String message;

  @override
  String toString() => 'AdvertisingUnavailableException: $message';
}

class UnavailableAdvertisingProvider implements AdvertisingProvider {
  const UnavailableAdvertisingProvider();

  AdvertisingUnavailableException get _error =>
      const AdvertisingUnavailableException('Advertising is disabled.');

  @override
  Future<void> initialize({required bool nonPersonalizedAds}) =>
      Future.error(_error);

  @override
  Future<BannerAdHandle> loadBanner({
    required String adUnitId,
    required double availableWidth,
    required bool nonPersonalizedAds,
  }) => Future.error(_error);

  @override
  Future<InterstitialAdHandle> loadInterstitial({
    required String adUnitId,
    required bool nonPersonalizedAds,
  }) => Future.error(_error);

  @override
  Future<RewardedAdHandle> loadRewarded({
    required String adUnitId,
    required bool nonPersonalizedAds,
  }) => Future.error(_error);
}
