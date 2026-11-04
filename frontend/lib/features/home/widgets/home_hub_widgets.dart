import 'package:flutter/material.dart';

import '../../../core/widgets/studyhub_ui.dart';
import '../../../l10n/app_localizations_x.dart';

class HomeQuickAction {
  const HomeQuickAction({
    required this.id,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String id;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class HomeQuickActionGrid extends StatelessWidget {
  const HomeQuickActionGrid({super.key, required this.actions});

  final List<HomeQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final singleColumn =
            constraints.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(14) > 24;
        final tileWidth = singleColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;

        return Wrap(
          key: const ValueKey('home-quick-action-grid'),
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final action in actions)
              SizedBox(
                width: tileWidth,
                child: _HomeQuickActionTile(action: action),
              ),
          ],
        );
      },
    );
  }
}

class _HomeQuickActionTile extends StatelessWidget {
  const _HomeQuickActionTile({required this.action});

  final HomeQuickAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (foreground, background) = switch (action.id) {
      'materials' => (colors.onSecondaryContainer, colors.secondaryContainer),
      'saved' => (colors.onTertiaryContainer, colors.tertiaryContainer),
      _ => (colors.onPrimaryContainer, colors.primaryContainer),
    };

    return Semantics(
      key: ValueKey('home-quick-${action.id}'),
      button: true,
      label: action.label,
      onTap: action.onTap,
      excludeSemantics: true,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: action.onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                StudyHubIconSurface(
                  icon: action.icon,
                  foregroundColor: foreground,
                  backgroundColor: background,
                  size: 36,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(action.label, style: theme.textTheme.titleSmall),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryLearningCard extends StatelessWidget {
  const PrimaryLearningCard({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    const panel = Color(0xFF153B3A);
    const accent = Color(0xFFBAF0D8);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StudyHubIconSurface(
                icon: Icons.play_arrow_rounded,
                foregroundColor: panel,
                backgroundColor: accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.continueLearningSection,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.continueLearningBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFD9EAE5),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('home-primary-start-learning'),
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: panel,
            ),
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.startLearning),
          ),
        ],
      ),
    );
  }
}

class LearningModeShortcutCard extends StatelessWidget {
  const LearningModeShortcutCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: title,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                StudyHubIconSurface(icon: icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 3),
                      Text(
                        body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeaturePreviewTile extends StatelessWidget {
  const FeaturePreviewTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final enabled = onTap != null;
    return Semantics(
      button: enabled,
      enabled: enabled,
      excludeSemantics: true,
      label: enabled ? title : l10n.upcomingFeatureSemantics(title),
      child: Card(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StudyHubIconSurface(
                  icon: icon,
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 12),
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                if (!enabled)
                  ComingSoonBadge(label: l10n.comingSoon)
                else
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
