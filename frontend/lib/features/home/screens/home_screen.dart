import 'package:flutter/material.dart';

import '../../../core/widgets/studyhub_ui.dart';
import '../../../l10n/app_localizations_x.dart';
import '../models/home_banner_item.dart';
import '../widgets/home_banner_carousel.dart';
import '../widgets/home_hub_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onStartLearning,
    required this.onOpenProgress,
    required this.onOpenSettings,
    required this.onOpenStudyMaterials,
    required this.onOpenContribution,
  });

  final VoidCallback onStartLearning;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenStudyMaterials;
  final VoidCallback onOpenContribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final banners = [
      HomeBannerItem(
        icon: Icons.compare_arrows_rounded,
        title: l10n.featuredModesTitle,
        body: l10n.featuredModesBody,
        actionLabel: l10n.featuredModesAction,
        onPressed: onStartLearning,
        tone: HomeBannerTone.primary,
      ),
      HomeBannerItem(
        icon: Icons.search_rounded,
        title: l10n.featuredSetsTitle,
        body: l10n.featuredSetsBody,
        actionLabel: l10n.featuredSetsAction,
        onPressed: onStartLearning,
        tone: HomeBannerTone.success,
      ),
      HomeBannerItem(
        icon: Icons.insights_outlined,
        title: l10n.featuredProgressTitle,
        body: l10n.featuredProgressBody,
        actionLabel: l10n.featuredProgressAction,
        onPressed: onOpenProgress,
        tone: HomeBannerTone.neutral,
      ),
    ];
    final quickActions = [
      HomeQuickAction(
        id: 'start-learning',
        icon: Icons.play_arrow_rounded,
        label: l10n.startLearning,
        onTap: onStartLearning,
      ),
      HomeQuickAction(
        id: 'browse-subjects',
        icon: Icons.menu_book_outlined,
        label: l10n.browseSubjects,
        onTap: onStartLearning,
      ),
      HomeQuickAction(
        id: 'exam-mode',
        icon: Icons.assignment_outlined,
        label: l10n.examMode,
        onTap: onStartLearning,
      ),
      HomeQuickAction(
        id: 'practice-mode',
        icon: Icons.school_outlined,
        label: l10n.practiceMode,
        onTap: onStartLearning,
      ),
      HomeQuickAction(
        id: 'progress',
        icon: Icons.insights_outlined,
        label: l10n.progressTab,
        onTap: onOpenProgress,
      ),
      HomeQuickAction(
        id: 'settings',
        icon: Icons.settings_outlined,
        label: l10n.settingsTab,
        onTap: onOpenSettings,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              key: const ValueKey('home-hub-list'),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              children: [
                _HomeHeader(
                  title: l10n.appTitle,
                  greeting: l10n.homeGreeting,
                  supportingLine: l10n.homeSupportingLine,
                ),
                const SizedBox(height: 24),
                StudyHubSectionHeader(title: l10n.featuredSection),
                const SizedBox(height: 12),
                HomeBannerCarousel(items: banners),
                const SizedBox(height: 28),
                StudyHubSectionHeader(title: l10n.quickActionsSection),
                const SizedBox(height: 12),
                HomeQuickActionGrid(actions: quickActions),
                const SizedBox(height: 28),
                PrimaryLearningCard(onPressed: onStartLearning),
                const SizedBox(height: 28),
                StudyHubSectionHeader(
                  title: l10n.learningModes,
                  subtitle: l10n.learningModesCompactSubtitle,
                ),
                const SizedBox(height: 12),
                LearningModeShortcutCard(
                  icon: Icons.assignment_outlined,
                  title: l10n.examMode,
                  body: l10n.examModeCompactBody,
                  onTap: onStartLearning,
                ),
                const SizedBox(height: 10),
                LearningModeShortcutCard(
                  icon: Icons.school_outlined,
                  title: l10n.practiceMode,
                  body: l10n.practiceModeCompactBody,
                  onTap: onStartLearning,
                ),
                const SizedBox(height: 28),
                StudyHubSectionHeader(title: l10n.exploreSection),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 10.0;
                    final width = (constraints.maxWidth - spacing) / 2;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        SizedBox(
                          width: width,
                          child: FeaturePreviewTile(
                            icon: Icons.description_outlined,
                            title: l10n.studyMaterials,
                            onTap: onOpenStudyMaterials,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: FeaturePreviewTile(
                            key: const ValueKey('contribution-home-tile'),
                            icon: Icons.post_add_outlined,
                            title: l10n.contributionTitle,
                            onTap: onOpenContribution,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: FeaturePreviewTile(
                            icon: Icons.event_note_outlined,
                            title: l10n.learningPlans,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.answersHiddenNote,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.title,
    required this.greeting,
    required this.supportingLine,
  });

  final String title;
  final String greeting;
  final String supportingLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudyHubIconSurface(
          icon: Icons.auto_stories_outlined,
          foregroundColor: theme.colorScheme.onPrimary,
          backgroundColor: theme.colorScheme.primary,
          size: 46,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(greeting, style: theme.textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(
                supportingLine,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
