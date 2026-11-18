import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../core/widgets/studyhub_ui.dart';
import '../../../core/widgets/study_illustration.dart';
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
    required this.onBrowseAll,
    required this.onSchoolReview,
  });

  final VoidCallback onStartLearning;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenStudyMaterials;
  final VoidCallback onOpenContribution;
  final VoidCallback onOpenSaved;
  final VoidCallback onBrowseAll;
  final VoidCallback onSchoolReview;

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
                OutlinedButton.icon(
                  onPressed: onBrowseAll,
                  icon: const Icon(Icons.search_rounded),
                  label: Text(l10n.searchQuestionSetsHint),
                ),
                const SizedBox(height: AppSpacing.xxl),
                StudyHubSectionHeader(title: l10n.studySpaces),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final colors = theme.colorScheme;
                    final review = _StudySpace(
                      artwork: StudyArtwork.math,
                      title: l10n.schoolReviewTitle,
                      subtitle: l10n.schoolReviewSubtitle,
                      color: colors.secondaryContainer,
                      foreground: colors.onSecondaryContainer,
                      onTap: onSchoolReview,
                    );
                    final games = _StudySpace(
                      artwork: StudyArtwork.english,
                      title: l10n.playAndLearn,
                      subtitle: l10n.englishGames,
                      color: colors.tertiaryContainer,
                      foreground: colors.onTertiaryContainer,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WordGamesScreen(),
                        ),
                      ),
                    );
                    if (constraints.maxWidth < 300 ||
                        MediaQuery.textScalerOf(context).scale(16) > 21) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [review, const SizedBox(height: 12), games],
                      );
                    }
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: review),
                          const SizedBox(width: 12),
                          Expanded(child: games),
                        ],
                      ),
                    );
                  },
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

class _StudySpace extends StatelessWidget {
  const _StudySpace({
    required this.artwork,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.foreground,
    required this.onTap,
  });

  final StudyArtwork artwork;
  final String title;
  final String subtitle;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.feature),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox.square(
                    dimension: 64,
                    child: StudyIllustration(artwork),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: foreground,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: text.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: text.bodySmall?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
