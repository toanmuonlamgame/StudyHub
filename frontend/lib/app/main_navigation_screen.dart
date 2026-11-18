import 'package:flutter/material.dart';

import '../core/app_locale.dart';
import '../features/home/screens/home_screen.dart';
import '../features/contribution/repositories/contribution_repository.dart';
import '../features/contribution/screens/contribution_intro_screen.dart';
import '../features/learning/repositories/learning_repository.dart';
import '../features/learning/data/school_review_data.dart'
    show schoolReviewSubject;
import '../features/learning/screens/question_set_list_screen.dart';
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
    final colors = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= 1040;
    final destinations = [
      (Icons.home_outlined, Icons.home_rounded, l10n.homeTab),
      (Icons.explore_outlined, Icons.explore_rounded, l10n.exploreTab),
      (Icons.folder_copy_outlined, Icons.folder_copy_rounded, l10n.myExams),
      (Icons.person_outline_rounded, Icons.person_rounded, l10n.profile),
    ];

    return Scaffold(
      body: Row(
        children: [
          if (wide) ...[
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _selectTab,
              extended: true,
              minExtendedWidth: 206,
              backgroundColor: colors.surface,
              leading: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 12,
                ),
                child: Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              destinations: [
                for (final (icon, selectedIcon, label) in destinations)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selectedIcon),
                    label: Text(label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
          ],
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: IndexedStack(
                  index: selectedIndex,
                  children: List.generate(
                    destinations.length,
                    (index) => _builtTabs[index] ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : DecoratedBox(
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
                  for (final (icon, selectedIcon, label) in destinations)
                    NavigationDestination(
                      icon: Icon(icon),
                      selectedIcon: Icon(selectedIcon),
                      label: label,
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
      1 => SubjectListScreen(
        learningRepository: widget.learningRepository,
        onBrowseAll: _openQuestionBank,
      ),
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
      onBrowseAll: _openQuestionBank,
      onSchoolReview: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => QuestionSetListScreen(
            subject: schoolReviewSubject,
            learningRepository: widget.learningRepository,
          ),
        ),
      ),
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

  void _openQuestionBank() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuestionSetListScreen(
          learningRepository: widget.learningRepository,
        ),
      ),
    );
  }
}
