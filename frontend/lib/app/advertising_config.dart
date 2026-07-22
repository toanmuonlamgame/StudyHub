import '../features/advertising/advertising_config.dart';
import '../features/advertising/advertising_service.dart';
import '../features/advertising/google_mobile_ads_provider.dart';

AdvertisingService createAdvertisingServiceFromEnvironment() {
  return AdvertisingService(
    config: AdvertisingConfig.fromEnvironment(),
    provider: GoogleMobileAdsProvider(),
    // Production consent must be supplied by a real provider consent flow.
    // Test mode is allowed to use Google's sample, non-personalized requests.
    consentStatus: AdvertisingConsentStatus.unknown,
  );
}
