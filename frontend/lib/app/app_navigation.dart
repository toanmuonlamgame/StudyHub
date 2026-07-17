import 'package:flutter/material.dart';

class AppNavigationController extends ChangeNotifier {
  int _selectedTab = 0;

  int get selectedTab => _selectedTab;

  void selectTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
  }
}

class AppNavigationScope extends InheritedNotifier<AppNavigationController> {
  const AppNavigationScope({
    super.key,
    required AppNavigationController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppNavigationController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppNavigationScope>()
        ?.notifier;
  }
}

void returnToStudyHubHome(BuildContext context) {
  AppNavigationScope.maybeOf(context)?.selectTab(0);
  Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
}
