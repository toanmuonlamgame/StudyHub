import 'package:flutter/material.dart';

import '../features/home_placeholder.dart';
import '../features/learning/repositories/learning_repository.dart';
import '../features/learning/screens/subject_list_screen.dart';
import '../features/progress/progress_placeholder_screen.dart';
import '../features/settings/settings_placeholder_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.learningRepository});

  final LearningRepository learningRepository;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final Map<int, Widget> _builtTabs = {};

  @override
  void initState() {
    super.initState();
    _builtTabs[0] = HomePlaceholder(onStartLearning: () => _selectTab(1));
  }

  @override
  Widget build(BuildContext context) {
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _builtTabs[index] ??= _buildTab(index);
      _selectedIndex = index;
    });
  }

  Widget _buildTab(int index) {
    return switch (index) {
      0 => HomePlaceholder(onStartLearning: () => _selectTab(1)),
      1 => SubjectListScreen(learningRepository: widget.learningRepository),
      2 => ProgressPlaceholderScreen(onStartLearning: () => _selectTab(1)),
      3 => const SettingsPlaceholderScreen(),
      _ => throw RangeError.index(index, const [0, 1, 2, 3]),
    };
  }
}
