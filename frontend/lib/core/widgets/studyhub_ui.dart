import 'package:flutter/material.dart';

import '../app_design_tokens.dart';

class StudyHubSectionHeader extends StatelessWidget {
  const StudyHubSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class StudyHubIconSurface extends StatelessWidget {
  const StudyHubIconSurface({
    super.key,
    required this.icon,
    this.foregroundColor,
    this.backgroundColor,
    this.size = 44,
  });

  final IconData icon;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: foregroundColor ?? colors.primary,
      ),
    );
  }
}

class StudyHubPageHeader extends StatelessWidget {
  const StudyHubPageHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.eyebrow,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudyHubIconSurface(icon: icon, size: 48),
          const SizedBox(height: AppSpacing.lg),
          if (eyebrow != null) ...[
            Text(
              eyebrow!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class StudyHubStateView extends StatelessWidget {
  const StudyHubStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.tone = StudyHubStateTone.neutral,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final StudyHubStateTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (foreground, background) = switch (tone) {
      StudyHubStateTone.neutral => (
        theme.colorScheme.primary,
        theme.colorScheme.primaryContainer,
      ),
      StudyHubStateTone.success => (
        AppColors.success,
        theme.colorScheme.secondaryContainer,
      ),
      StudyHubStateTone.error => (
        theme.colorScheme.error,
        theme.colorScheme.errorContainer,
      ),
    };

    return Semantics(
      liveRegion: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(AppRadii.feature),
                  ),
                  child: Icon(
                    icon,
                    color: foreground,
                    size: AppIconSizes.state,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(width: double.infinity, child: action),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum StudyHubStateTone { neutral, success, error }

class ComingSoonBadge extends StatelessWidget {
  const ComingSoonBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class EmptyMetricCard extends StatelessWidget {
  const EmptyMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.emptyLabel,
    required this.comingSoonLabel,
  });

  final IconData icon;
  final String label;
  final String emptyLabel;
  final String comingSoonLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      enabled: false,
      label: '$label, $emptyLabel, $comingSoonLabel',
      child: Card(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const Spacer(),
                  Text(
                    '-',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(label, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                emptyLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              ComingSoonBadge(label: comingSoonLabel),
            ],
          ),
        ),
      ),
    );
  }
}
