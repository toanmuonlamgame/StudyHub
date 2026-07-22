import 'package:flutter/material.dart';

import '../../../core/widgets/studyhub_ui.dart';
import '../../auth/auth_scope.dart';
import '../../../l10n/app_localizations_x.dart';
import '../widgets/home_hub_widgets.dart';
import '../../advertising/advertising_service.dart';
import '../../advertising/widgets/studyhub_banner_ad.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onStartLearning,
    required this.onOpenProgress,
    required this.onOpenStudyMaterials,
    required this.onOpenContribution,
    required this.onOpenSaved,
  });

  final VoidCallback onStartLearning;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenStudyMaterials;
  final VoidCallback onOpenContribution;
  final VoidCallback onOpenSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final user = AuthScope.maybeOf(context)?.user;
    final displayName = user?.displayName.trim();
    final quickActions = [
      HomeQuickAction(
        id: 'browse-subjects',
        icon: Icons.menu_book_outlined,
        label: l10n.browseSubjects,
        onTap: onStartLearning,
      ),
      HomeQuickAction(
        id: 'progress',
        icon: Icons.insights_outlined,
        label: l10n.progressTab,
        onTap: onOpenProgress,
      ),
      HomeQuickAction(
        id: 'contribution',
        icon: Icons.post_add_outlined,
        label: l10n.contributionTitle,
        onTap: onOpenContribution,
      ),
      HomeQuickAction(
        id: 'saved',
        icon: Icons.bookmarks_outlined,
        label: l10n.savedQuestionSets,
        onTap: onOpenSaved,
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
                  greeting: displayName == null || displayName.isEmpty
                      ? l10n.homeGreeting
                      : l10n.homeGreetingName(displayName),
                  supportingLine: l10n.homeSupportingLine,
                ),
                const SizedBox(height: 24),
                PrimaryLearningCard(onPressed: onStartLearning),
                const SizedBox(height: 28),
                StudyHubSectionHeader(
                  title: l10n.quickActionsSection,
                  subtitle: l10n.homeSupportingLine,
                ),
                const SizedBox(height: 12),
                HomeQuickActionGrid(actions: quickActions),
                const SizedBox(height: 28),
                StudyHubSectionHeader(title: l10n.exploreSection),
                const SizedBox(height: 12),
                FeaturePreviewTile(
                  icon: Icons.description_outlined,
                  title: l10n.studyMaterials,
                  onTap: onOpenStudyMaterials,
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
                const SizedBox(height: 20),
                const StudyHubBannerAd(placement: BannerPlacement.home),
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
