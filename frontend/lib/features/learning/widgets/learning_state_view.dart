import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';

class LearningLoadingState extends StatelessWidget {
  const LearningLoadingState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _LearningStateLayout(
      icon: Icons.auto_stories_outlined,
      title: message,
      child: const Padding(
        padding: EdgeInsets.only(top: 18),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LearningErrorState extends StatelessWidget {
  const LearningErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _LearningStateLayout(
      icon: Icons.cloud_off_outlined,
      title: title,
      message: message,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.tryAgain),
        ),
      ),
    );
  }
}

class LearningEmptyState extends StatelessWidget {
  const LearningEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _LearningStateLayout(
      icon: icon,
      title: title,
      message: message,
      child: actionLabel == null || onAction == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 20),
              child: OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
    );
  }
}

class _LearningStateLayout extends StatelessWidget {
  const _LearningStateLayout({
    required this.icon,
    required this.title,
    this.message,
    this.child,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 30),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                ?child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
