import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/studyhub_app.dart';
import 'package:frontend/core/app_locale.dart';
import 'package:frontend/features/advertising/advertising_config.dart';
import 'package:frontend/features/advertising/advertising_provider.dart';
import 'package:frontend/features/advertising/advertising_service.dart';

void main() {
  test('disabled advertising never initializes the provider', () async {
    final provider = _FakeAdvertisingProvider();
    final service = AdvertisingService(
      config: const AdvertisingConfig(mode: AdvertisingMode.disabled),
      provider: provider,
      frequencyStore: _MemoryFrequencyStore(),
    );

    await service.initialize();

    expect(service.state, AdvertisingState.disabled);
    expect(provider.initializeCalls, 0);
  });

  test('production ads remain blocked while consent is unresolved', () async {
    final provider = _FakeAdvertisingProvider();
    final service = AdvertisingService(
      config: const AdvertisingConfig(
        mode: AdvertisingMode.production,
        bannerAdUnitId: 'banner',
        interstitialAdUnitId: 'interstitial',
        rewardedAdUnitId: 'rewarded',
      ),
      provider: provider,
      frequencyStore: _MemoryFrequencyStore(),
    );

    await service.initialize();

    expect(service.canRequestAds, isFalse);
    expect(service.state, AdvertisingState.unavailable);
    expect(provider.initializeCalls, 0);
  });

  test('banner requests are deduplicated per placement', () async {
    final provider = _FakeAdvertisingProvider();
    final service = _testService(provider: provider);

    final handles = await Future.wait([
      service.loadBanner(BannerPlacement.home, availableWidth: 360),
      service.loadBanner(BannerPlacement.home, availableWidth: 360),
    ]);

    expect(handles[0], same(handles[1]));
    expect(provider.initializeCalls, 1);
    expect(provider.bannerLoadCalls, 1);
  });

  test(
    'interstitial waits for three completions and respects cooldown',
    () async {
      final provider = _FakeAdvertisingProvider();
      final store = _MemoryFrequencyStore();
      var now = DateTime(2026, 7, 22, 9);
      final service = _testService(
        provider: provider,
        frequencyStore: store,
        now: () => now,
      );

      await service.onCompletedLearningReturnedHome();
      await service.onCompletedLearningReturnedHome();
      expect(provider.interstitialLoadCalls, 0);

      await service.onCompletedLearningReturnedHome();
      expect(provider.interstitialShowCalls, 1);

      await service.onCompletedLearningReturnedHome();
      expect(provider.interstitialShowCalls, 1);

      now = now.add(AdvertisingService.interstitialCooldown);
      await service.onCompletedLearningReturnedHome();
      expect(provider.interstitialShowCalls, 2);

      now = now.add(AdvertisingService.interstitialCooldown);
      await service.onCompletedLearningReturnedHome();
      expect(provider.interstitialShowCalls, 2);
    },
  );

  test(
    'reward is granted only after confirmed completion and only once',
    () async {
      final provider = _FakeAdvertisingProvider(rewardCompleted: false);
      final service = _testService(provider: provider);

      expect(await service.earnSessionAdFreeReward(), isFalse);
      expect(service.sessionAdFree, isFalse);

      provider.rewardCompleted = true;
      expect(await service.earnSessionAdFreeReward(), isTrue);
      expect(service.sessionAdFree, isTrue);
      expect(await service.earnSessionAdFreeReward(), isFalse);
      expect(provider.rewardedShowCalls, 2);
    },
  );

  test('production configuration requires every ad unit id', () {
    expect(
      () => AdvertisingConfig.fromEnvironment(mode: 'production'),
      throwsStateError,
    );
  });

  testWidgets('Settings honestly reports disabled advertising', (tester) async {
    await tester.pumpWidget(
      const StudyHubApp(initialLocaleSelection: AppLocaleSelection.english),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.fling(find.byType(ListView), const Offset(0, -1600), 1200);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Advertising'), findsOneWidget);
    expect(find.text('Ads disabled'), findsOneWidget);
    expect(find.text('Watch ad'), findsNothing);
  });
}

AdvertisingService _testService({
  required _FakeAdvertisingProvider provider,
  AdvertisingFrequencyStore? frequencyStore,
  DateTime Function()? now,
}) {
  return AdvertisingService(
    config: const AdvertisingConfig(
      mode: AdvertisingMode.test,
      bannerAdUnitId: 'test-banner',
      interstitialAdUnitId: 'test-interstitial',
      rewardedAdUnitId: 'test-rewarded',
    ),
    provider: provider,
    consentStatus: AdvertisingConsentStatus.unknown,
    frequencyStore: frequencyStore ?? _MemoryFrequencyStore(),
    now: now,
    eventSink: (_) {},
  );
}

class _FakeAdvertisingProvider implements AdvertisingProvider {
  _FakeAdvertisingProvider({this.rewardCompleted = true});

  int initializeCalls = 0;
  int bannerLoadCalls = 0;
  int interstitialLoadCalls = 0;
  int interstitialShowCalls = 0;
  int rewardedShowCalls = 0;
  bool rewardCompleted;

  @override
  Future<void> initialize({required bool nonPersonalizedAds}) async {
    initializeCalls++;
  }

  @override
  Future<BannerAdHandle> loadBanner({
    required String adUnitId,
    required double availableWidth,
    required bool nonPersonalizedAds,
  }) async {
    bannerLoadCalls++;
    return _FakeBannerAdHandle();
  }

  @override
  Future<InterstitialAdHandle> loadInterstitial({
    required String adUnitId,
    required bool nonPersonalizedAds,
  }) async {
    interstitialLoadCalls++;
    return _FakeInterstitialAdHandle(() => interstitialShowCalls++);
  }

  @override
  Future<RewardedAdHandle> loadRewarded({
    required String adUnitId,
    required bool nonPersonalizedAds,
  }) async {
    return _FakeRewardedAdHandle(() {
      rewardedShowCalls++;
      return rewardCompleted;
    });
  }
}

class _FakeBannerAdHandle implements BannerAdHandle {
  @override
  Size get size => const Size(320, 50);

  @override
  Widget buildView() => const SizedBox(width: 320, height: 50);

  @override
  Future<void> dispose() async {}
}

class _FakeInterstitialAdHandle implements InterstitialAdHandle {
  _FakeInterstitialAdHandle(this._onShow);

  final VoidCallback _onShow;

  @override
  Future<bool> show() async {
    _onShow();
    return true;
  }

  @override
  Future<void> dispose() async {}
}

class _FakeRewardedAdHandle implements RewardedAdHandle {
  _FakeRewardedAdHandle(this._onShow);

  final bool Function() _onShow;

  @override
  Future<bool> show() async => _onShow();

  @override
  Future<void> dispose() async {}
}

class _MemoryFrequencyStore implements AdvertisingFrequencyStore {
  final Map<String, int> values = {};

  @override
  Future<int> readDailyInterstitialCount(String dateKey) async =>
      values[dateKey] ?? 0;

  @override
  Future<void> writeDailyInterstitialCount(String dateKey, int value) async {
    values[dateKey] = value;
  }
}
