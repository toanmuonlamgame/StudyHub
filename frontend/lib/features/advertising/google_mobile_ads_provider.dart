import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'advertising_provider.dart';

class GoogleMobileAdsProvider implements AdvertisingProvider {
  var _initialized = false;

  // Android is the configured mobile target for this milestone. iOS stays
  // unavailable until its provider app ID is added outside source control.
  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> initialize({required bool nonPersonalizedAds}) async {
    if (_initialized) return;
    if (!_supported) {
      throw const AdvertisingUnavailableException(
        'Google Mobile Ads is unavailable on this platform.',
      );
    }
    await MobileAds.instance.initialize().timeout(const Duration(seconds: 8));
    _initialized = true;
  }

  AdRequest _request(bool nonPersonalizedAds) =>
      AdRequest(nonPersonalizedAds: nonPersonalizedAds);

  @override
  Future<BannerAdHandle> loadBanner({
    required String adUnitId,
    required double availableWidth,
    required bool nonPersonalizedAds,
  }) async {
    final completer = Completer<BannerAdHandle>();
    late final BannerAd ad;
    ad = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: _request(nonPersonalizedAds),
      listener: BannerAdListener(
        onAdLoaded: (_) => completer.complete(_GoogleBannerAdHandle(ad)),
        onAdFailedToLoad: (_, error) {
          unawaited(ad.dispose());
          completer.completeError(
            AdvertisingUnavailableException(error.message),
          );
        },
      ),
    );
    await ad.load();
    return completer.future.timeout(const Duration(seconds: 10));
  }

  @override
  Future<InterstitialAdHandle> loadInterstitial({
    required String adUnitId,
    required bool nonPersonalizedAds,
  }) async {
    final completer = Completer<InterstitialAdHandle>();
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: _request(nonPersonalizedAds),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(_GoogleInterstitialAdHandle(ad)),
        onAdFailedToLoad: (error) => completer.completeError(
          AdvertisingUnavailableException(error.message),
        ),
      ),
    );
    return completer.future.timeout(const Duration(seconds: 10));
  }

  @override
  Future<RewardedAdHandle> loadRewarded({
    required String adUnitId,
    required bool nonPersonalizedAds,
  }) async {
    final completer = Completer<RewardedAdHandle>();
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: _request(nonPersonalizedAds),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(_GoogleRewardedAdHandle(ad)),
        onAdFailedToLoad: (error) => completer.completeError(
          AdvertisingUnavailableException(error.message),
        ),
      ),
    );
    return completer.future.timeout(const Duration(seconds: 10));
  }
}

class _GoogleBannerAdHandle implements BannerAdHandle {
  _GoogleBannerAdHandle(this._ad);

  final BannerAd _ad;

  @override
  Size get size => Size(_ad.size.width.toDouble(), _ad.size.height.toDouble());

  @override
  Widget buildView() => AdWidget(ad: _ad);

  @override
  Future<void> dispose() => _ad.dispose();
}

class _GoogleInterstitialAdHandle implements InterstitialAdHandle {
  _GoogleInterstitialAdHandle(this._ad);

  final InterstitialAd _ad;

  @override
  Future<bool> show() async {
    final completer = Completer<bool>();
    _ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {},
      onAdDismissedFullScreenContent: (ad) {
        unawaited(ad.dispose());
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        unawaited(ad.dispose());
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    try {
      await _ad.show();
    } catch (_) {
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future;
  }

  @override
  Future<void> dispose() => _ad.dispose();
}

class _GoogleRewardedAdHandle implements RewardedAdHandle {
  _GoogleRewardedAdHandle(this._ad);

  final RewardedAd _ad;

  @override
  Future<bool> show() async {
    final completer = Completer<bool>();
    var rewardEarned = false;
    _ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        unawaited(ad.dispose());
        if (!completer.isCompleted) completer.complete(rewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        unawaited(ad.dispose());
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    try {
      await _ad.show(onUserEarnedReward: (_, _) => rewardEarned = true);
    } catch (_) {
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future;
  }

  @override
  Future<void> dispose() => _ad.dispose();
}
