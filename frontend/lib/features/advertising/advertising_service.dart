import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'advertising_config.dart';
import 'advertising_provider.dart';

enum AdvertisingState { disabled, loading, ready, failed, unavailable }

enum BannerPlacement { home, history, saved }

typedef AdvertisingEventSink = void Function(String event);

abstract interface class AdvertisingFrequencyStore {
  Future<int> readDailyInterstitialCount(String dateKey);
  Future<void> writeDailyInterstitialCount(String dateKey, int value);
}

class SharedPreferencesAdvertisingFrequencyStore
    implements AdvertisingFrequencyStore {
  const SharedPreferencesAdvertisingFrequencyStore();

  static const _prefix = 'studyhub.ad.interstitial.';

  @override
  Future<int> readDailyInterstitialCount(String dateKey) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt('$_prefix$dateKey') ?? 0;
  }

  @override
  Future<void> writeDailyInterstitialCount(String dateKey, int value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('$_prefix$dateKey', value);
  }
}

class AdvertisingService extends ChangeNotifier {
  AdvertisingService({
    required this.config,
    required this.provider,
    this.consentStatus = AdvertisingConsentStatus.unknown,
    this.frequencyStore = const SharedPreferencesAdvertisingFrequencyStore(),
    DateTime Function()? now,
    AdvertisingEventSink? eventSink,
  }) : _now = now ?? DateTime.now,
       _eventSink = eventSink ?? _defaultEventSink,
       _state = config.enabled
           ? AdvertisingState.unavailable
           : AdvertisingState.disabled;

  static const minCompletedActions = 3;
  static const interstitialCooldown = Duration(minutes: 10);
  static const maxInterstitialsPerSession = 2;
  static const maxInterstitialsPerDay = 3;

  final AdvertisingConfig config;
  final AdvertisingProvider provider;
  final AdvertisingFrequencyStore frequencyStore;
  final DateTime Function() _now;
  final AdvertisingEventSink _eventSink;
  final AdvertisingConsentStatus consentStatus;

  AdvertisingState _state;
  bool _sessionAdFree = false;
  bool _disposed = false;
  Future<void>? _initialization;
  Future<InterstitialAdHandle>? _interstitialLoad;
  Future<RewardedAdHandle>? _rewardedLoad;
  final Map<BannerPlacement, Future<BannerAdHandle>> _bannerLoads = {};
  final Map<BannerPlacement, BannerAdHandle> _banners = {};
  var _completedActions = 0;
  var _sessionInterstitialCount = 0;
  DateTime? _lastInterstitialAt;

  AdvertisingState get state => _state;
  bool get adsEnabled => config.enabled;
  bool get isTestMode => config.isTestMode;
  bool get sessionAdFree => _sessionAdFree;
  bool get canRequestAds =>
      config.isTestMode ||
      consentStatus == AdvertisingConsentStatus.granted ||
      consentStatus == AdvertisingConsentStatus.notRequired;
  bool get shouldShowAds => adsEnabled && canRequestAds && !_sessionAdFree;

  Future<void> initialize() {
    if (!adsEnabled || !canRequestAds || _disposed) {
      _setState(
        adsEnabled ? AdvertisingState.unavailable : AdvertisingState.disabled,
      );
      return Future.value();
    }
    return _initialization ??= _initializeOnce();
  }

  Future<BannerAdHandle?> loadBanner(
    BannerPlacement placement, {
    required double availableWidth,
  }) async {
    if (!shouldShowAds || _disposed) return null;
    await initialize();
    if (_state != AdvertisingState.ready || !shouldShowAds) return null;
    if (_banners[placement] case final existing?) return existing;

    final future = _bannerLoads.putIfAbsent(
      placement,
      () => provider.loadBanner(
        adUnitId: config.bannerAdUnitId!,
        availableWidth: availableWidth,
        nonPersonalizedAds: config.nonPersonalizedAds,
      ),
    );
    try {
      final banner = await future;
      if (_disposed || !shouldShowAds) {
        await banner.dispose();
        return null;
      }
      _banners[placement] = banner;
      _eventSink('banner_loaded');
      return banner;
    } catch (_) {
      _eventSink('ad_failed');
      return null;
    } finally {
      _bannerLoads.remove(placement);
    }
  }

  Future<void> releaseBanner(
    BannerPlacement placement,
    BannerAdHandle handle,
  ) async {
    if (!identical(_banners[placement], handle)) return;
    _banners.remove(placement);
    await handle.dispose();
  }

  Future<void> onCompletedLearningReturnedHome() async {
    _completedActions++;
    if (!shouldShowAds || _disposed) return;
    if (_completedActions < minCompletedActions ||
        _sessionInterstitialCount >= maxInterstitialsPerSession) {
      return;
    }
    final now = _now();
    if (_lastInterstitialAt != null &&
        now.difference(_lastInterstitialAt!) < interstitialCooldown) {
      return;
    }
    try {
      final dateKey = _dateKey(now);
      final dailyCount = await frequencyStore.readDailyInterstitialCount(
        dateKey,
      );
      if (dailyCount >= maxInterstitialsPerDay || !shouldShowAds) return;
      final ad = await _loadInterstitial();
      if (!shouldShowAds || _disposed) {
        await ad.dispose();
        return;
      }
      _interstitialLoad = null;
      final shown = await ad.show();
      if (!shown) {
        _eventSink('ad_failed');
        return;
      }
      _lastInterstitialAt = now;
      _sessionInterstitialCount++;
      await frequencyStore.writeDailyInterstitialCount(dateKey, dailyCount + 1);
      _eventSink('interstitial_shown');
    } catch (_) {
      _interstitialLoad = null;
      _eventSink('ad_failed');
    }
  }

  Future<bool> earnSessionAdFreeReward() async {
    if (!shouldShowAds || _disposed) return false;
    try {
      await initialize();
      if (_state != AdvertisingState.ready) return false;
      final ad = await (_rewardedLoad ??= provider.loadRewarded(
        adUnitId: config.rewardedAdUnitId!,
        nonPersonalizedAds: config.nonPersonalizedAds,
      ));
      _rewardedLoad = null;
      final completed = await ad.show();
      if (!completed || _disposed) return false;
      _sessionAdFree = true;
      await _disposeBanners();
      _eventSink('rewarded_completed');
      _eventSink('reward_granted');
      notifyListeners();
      return true;
    } catch (_) {
      _rewardedLoad = null;
      _eventSink('ad_failed');
      return false;
    }
  }

  Future<void> _initializeOnce() async {
    _setState(AdvertisingState.loading);
    try {
      await provider.initialize(nonPersonalizedAds: config.nonPersonalizedAds);
      if (!_disposed) _setState(AdvertisingState.ready);
    } catch (_) {
      if (!_disposed) _setState(AdvertisingState.failed);
      _eventSink('ad_failed');
    }
  }

  Future<InterstitialAdHandle> _loadInterstitial() async {
    await initialize();
    if (_state != AdvertisingState.ready) {
      throw const AdvertisingUnavailableException(
        'Advertising SDK is not ready.',
      );
    }
    return _interstitialLoad ??= provider.loadInterstitial(
      adUnitId: config.interstitialAdUnitId!,
      nonPersonalizedAds: config.nonPersonalizedAds,
    );
  }

  void _setState(AdvertisingState value) {
    if (_state == value || _disposed) return;
    _state = value;
    notifyListeners();
  }

  Future<void> _disposeBanners() async {
    final banners = _banners.values.toList();
    _banners.clear();
    for (final banner in banners) {
      await banner.dispose();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_disposeBanners());
    super.dispose();
  }

  static String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static void _defaultEventSink(String event) {
    if (kDebugMode) debugPrint('StudyHub advertising event: $event');
  }
}
