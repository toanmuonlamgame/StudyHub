import 'package:flutter/widgets.dart';

import 'auth_controller.dart';

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'AuthScope is missing.');
    return controller!;
  }

  static AuthController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    return scope?.notifier;
  }
}
