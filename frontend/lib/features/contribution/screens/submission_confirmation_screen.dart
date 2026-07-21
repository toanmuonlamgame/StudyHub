import 'package:flutter/material.dart';

import '../../../app/app_navigation.dart';
import '../../../l10n/app_localizations_x.dart';
import '../models/submission_confirmation.dart';

class SubmissionConfirmationScreen extends StatelessWidget {
  const SubmissionConfirmationScreen({super.key, required this.confirmation});
  final SubmissionConfirmation confirmation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.contributionSubmissionSuccessful),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 520,
                minHeight: constraints.maxHeight - 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule_send_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.contributionPendingReview,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    confirmation.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.contributionPendingBody,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    key: const ValueKey('submission-back-to-home'),
                    onPressed: () => returnToStudyHubHome(context),
                    icon: const Icon(Icons.home_outlined),
                    label: Text(l10n.backToHome),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
