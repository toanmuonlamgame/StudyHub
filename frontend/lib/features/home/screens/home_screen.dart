import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../core/widgets/studyhub_ui.dart';
import '../../auth/auth_scope.dart';
import '../../../l10n/app_localizations_x.dart';
import '../widgets/home_hub_widgets.dart';
import '../../advertising/advertising_service.dart';
import '../../advertising/widgets/studyhub_banner_ad.dart';
import '../../word_games/word_games_screen.dart';

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
        icon: Icons.auto_stories_rounded,
        label: l10n.studyMaterials,
        onTap: onOpenStudyMaterials,
      ),
      HomeQuickAction(
        id: 'progress',
        icon: Icons.insights_rounded,
        label: l10n.progressTab,
        onTap: onOpenProgress,
      ),
      HomeQuickAction(
        id: 'contribution',
        icon: Icons.post_add_rounded,
        label: l10n.contributionTitle,
        onTap: onOpenContribution,
      ),
      HomeQuickAction(
        id: 'saved',
        icon: Icons.bookmarks_rounded,
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                _HomeHeader(
                  title: l10n.appTitle,
                  greeting: displayName == null || displayName.isEmpty
                      ? l10n.homeGreeting
                      : l10n.homeGreetingName(displayName),
                ),
                const SizedBox(height: 20),
                PrimaryLearningCard(onPressed: onStartLearning),
                const SizedBox(height: 12),
                Card(
                  color: theme.colorScheme.secondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: StudyHubIconSurface(
                      icon: Icons.sports_esports_rounded,
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.secondary,
                    ),
                    title: Text(
                      l10n.playAndLearn,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(l10n.englishGames),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const WordGamesScreen(),
                      ),
                    ),
                  ),
                ),
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
                      borderRadius: BorderRadius.circular(AppRadii.card),
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
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: .6,
                ),
              ),
              const SizedBox(height: 2),
              Text(greeting, style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
      ],
    );
  }
}
