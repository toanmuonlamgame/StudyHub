import 'package:flutter/material.dart';

import '../core/app_locale.dart';
import '../features/home/screens/home_screen.dart';
import '../features/learning/repositories/learning_repository.dart';
import '../features/learning/screens/subject_list_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/settings/settings_placeholder_screen.dart';
import '../l10n/app_localizations_x.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    required this.learningRepository,
    required this.localeSelection,
    required this.onLocaleSelected,
  });

  final LearningRepository learningRepository;
  final AppLocaleSelection localeSelection;
  final ValueChanged<AppLocaleSelection> onLocaleSelected;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final Map<int, Widget> _builtTabs = {};

  @override
  void initState() {
    super.initState();
    _builtTabs[0] = _buildHome();
  }

  @override
  void didUpdateWidget(covariant MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localeSelection != widget.localeSelection &&
        _builtTabs.containsKey(3)) {
      _builtTabs[3] = _buildTab(3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
          4,
          (index) => _builtTabs[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.homeTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.learnTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.progressTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settingsTab,
          ),
        ],
      ),
    );
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() {
      _builtTabs[index] ??= _buildTab(index);
      _selectedIndex = index;
    });
  }

  Widget _buildTab(int index) {
    return switch (index) {
      0 => _buildHome(),
      1 => SubjectListScreen(learningRepository: widget.learningRepository),
      2 => ProgressScreen(onStartLearning: () => _selectTab(1)),
      3 => SettingsPlaceholderScreen(
        localeSelection: widget.localeSelection,
        onLocaleSelected: widget.onLocaleSelected,
      ),
      _ => throw RangeError.index(index, const [0, 1, 2, 3]),
    };
  }

  Widget _buildHome() {
    return HomeScreen(
      onStartLearning: () => _selectTab(1),
      onOpenProgress: () => _selectTab(2),
      onOpenSettings: () => _selectTab(3),
    );
  }
}
