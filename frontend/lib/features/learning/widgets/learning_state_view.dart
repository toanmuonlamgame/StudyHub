import 'package:flutter/material.dart';

import '../../../core/widgets/studyhub_ui.dart';
import '../../../l10n/app_localizations_x.dart';

class LearningLoadingState extends StatelessWidget {
  const LearningLoadingState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return StudyHubStateView(
      icon: Icons.auto_stories_outlined,
      title: message,
      action: const Center(child: CircularProgressIndicator()),
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
    return StudyHubStateView(
      icon: Icons.cloud_off_outlined,
      title: title,
      message: message,
      tone: StudyHubStateTone.error,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(context.l10n.tryAgain),
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
    return StudyHubStateView(
      icon: icon,
      title: title,
      message: message,
      action: actionLabel == null || onAction == null
          ? null
          : OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward),
              label: Text(actionLabel!),
            ),
    );
  }
}
