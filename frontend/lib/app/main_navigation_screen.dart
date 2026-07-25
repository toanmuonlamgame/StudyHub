import 'package:flutter/material.dart';

import '../core/app_locale.dart';
import '../features/home/screens/home_screen.dart';
import '../features/contribution/repositories/contribution_repository.dart';
import '../features/contribution/screens/contribution_intro_screen.dart';
import '../features/learning/repositories/learning_repository.dart';
import '../features/learning/screens/subject_list_screen.dart';
import '../features/materials/screens/study_material_list_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/my_exams/my_exams_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/saved/screens/saved_question_sets_screen.dart';
import '../l10n/app_localizations_x.dart';
import 'app_navigation.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    required this.learningRepository,
    required this.navigationController,
    required this.contributionRepository,
    required this.localeSelection,
    required this.onLocaleSelected,
  });

  final LearningRepository learningRepository;
  final AppNavigationController navigationController;
  final ContributionRepository contributionRepository;
  final AppLocaleSelection localeSelection;
  final ValueChanged<AppLocaleSelection> onLocaleSelected;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final Map<int, Widget> _builtTabs = {};

  @override
  void initState() {
    super.initState();
    widget.navigationController.addListener(_handleNavigationChanged);
    _builtTabs[0] = _buildHome();
  }

  @override
  void didUpdateWidget(covariant MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(
      oldWidget.navigationController,
      widget.navigationController,
    )) {
      oldWidget.navigationController.removeListener(_handleNavigationChanged);
      widget.navigationController.addListener(_handleNavigationChanged);
    }
    if (oldWidget.localeSelection != widget.localeSelection &&
        _builtTabs.containsKey(3)) {
      _builtTabs[3] = _buildTab(3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedIndex = widget.navigationController.selectedTab;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: List.generate(
          4,
          (index) => _builtTabs[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: _selectTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.homeTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book_rounded),
              label: l10n.exploreTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.folder_copy_outlined),
              selectedIcon: const Icon(Icons.folder_copy_rounded),
              label: l10n.myExams,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    widget.navigationController.selectTab(index);
  }

  void _handleNavigationChanged() {
    if (!mounted) return;
    final selectedIndex = widget.navigationController.selectedTab;
    setState(() => _builtTabs[selectedIndex] ??= _buildTab(selectedIndex));
  }

  @override
  void dispose() {
    widget.navigationController.removeListener(_handleNavigationChanged);
    super.dispose();
  }

  Widget _buildTab(int index) {
    return switch (index) {
      0 => _buildHome(),
      1 => SubjectListScreen(learningRepository: widget.learningRepository),
      2 => MyExamsScreen(
        learningRepository: widget.learningRepository,
        contributionRepository: widget.contributionRepository,
      ),
      3 => ProfileScreen(
        learningRepository: widget.learningRepository,
        contributionRepository: widget.contributionRepository,
        localeSelection: widget.localeSelection,
        onLocaleSelected: widget.onLocaleSelected,
      ),
      _ => throw RangeError.index(index, const [0, 1, 2, 3]),
    };
  }

  Widget _buildHome() {
    return HomeScreen(
      onStartLearning: () => _selectTab(1),
      onOpenProgress: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (progressContext) => ProgressScreen(
            onStartLearning: () {
              _selectTab(1);
              Navigator.of(progressContext).pop();
            },
          ),
        ),
      ),
      onOpenStudyMaterials: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StudyMaterialListScreen(
            learningRepository: widget.learningRepository,
          ),
        ),
      ),
      onOpenContribution: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ContributionIntroScreen(
            learningRepository: widget.learningRepository,
            contributionRepository: widget.contributionRepository,
          ),
        ),
      ),
      onOpenSaved: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SavedQuestionSetsScreen(
            learningRepository: widget.learningRepository,
          ),
        ),
      ),
    );
  }
}
