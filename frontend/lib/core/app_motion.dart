import 'package:flutter/widgets.dart';

class AppMotion {
  const AppMotion._();

  static const quick = Duration(milliseconds: 140);
  static const standard = Duration(milliseconds: 220);
  static const reveal = Duration(milliseconds: 320);
  static const success = Duration(milliseconds: 360);
  static const standardCurve = Curves.easeOutCubic;
  static const emphasizedCurve = Curves.easeInOutCubic;

  static Duration duration(BuildContext context, Duration preferred) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : preferred;
  }
}
