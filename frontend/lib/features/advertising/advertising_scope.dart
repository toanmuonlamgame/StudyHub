import 'package:flutter/widgets.dart';

import 'advertising_service.dart';

class AdvertisingScope extends InheritedNotifier<AdvertisingService> {
  const AdvertisingScope({
    super.key,
    required AdvertisingService service,
    required super.child,
  }) : super(notifier: service);

  static AdvertisingService of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AdvertisingScope>();
    assert(scope != null, 'AdvertisingScope was not found in the widget tree.');
    return scope!.notifier!;
  }

  static AdvertisingService? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdvertisingScope>()?.notifier;
}
