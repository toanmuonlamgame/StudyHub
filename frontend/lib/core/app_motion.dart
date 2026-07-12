import 'package:flutter/widgets.dart';

class AppMotion {
  const AppMotion._();

  static Duration duration(BuildContext context, Duration preferred) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : preferred;
  }
}
