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
        id: 'materials',
        icon: Icons.description_outlined,
        label: l10n.studyMaterials,
        onTap: onOpenStudyMaterials,
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
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              children: [
                _HomeHeader(
                  title: l10n.appTitle,
                  greeting: displayName == null || displayName.isEmpty
                      ? l10n.homeGreeting
                      : l10n.homeGreetingName(displayName),
                ),
                const SizedBox(height: 20),
                PrimaryLearningCard(onPressed: onStartLearning),
                const SizedBox(height: 28),
                StudyHubSectionHeader(title: l10n.quickActionsSection),
                const SizedBox(height: 12),
                HomeQuickActionGrid(actions: quickActions),
                const SizedBox(height: 24),
                StudyHubBannerAd(
                  placement: BannerPlacement.home,
                  fallback: Card(
                    key: const ValueKey('home-materials-promotion'),
                    color: theme.colorScheme.tertiaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: const Icon(Icons.collections_bookmark_outlined),
                      title: Text(l10n.exploreSection),
                      subtitle: Text(l10n.studyMaterialsSubtitle),
                      trailing: const Icon(Icons.arrow_forward_rounded),
                      onTap: onOpenStudyMaterials,
                    ),
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
  const _HomeHeader({required this.title, required this.greeting});

  final String title;
  final String greeting;

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
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(greeting, style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
      ],
    );
  }
}
