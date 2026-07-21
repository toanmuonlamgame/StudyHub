import 'package:flutter/material.dart';

import '../../l10n/app_localizations_x.dart';
import '../attempts/attempt_repository_scope.dart';
import '../auth/auth_scope.dart';
import '../contribution/repositories/contribution_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.contributionRepository});
  final ContributionRepository contributionRepository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<({int attempts, int submissions})> _stats;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stats = _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).user!;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profile)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 34,
            child: Text(
              user.displayName.isEmpty
                  ? '?'
                  : user.displayName.characters.first.toUpperCase(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(user.email, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _editDisplayName,
            icon: const Icon(Icons.edit_outlined),
            label: Text(context.l10n.editDisplayName),
          ),
          const SizedBox(height: 20),
          FutureBuilder<({int attempts, int submissions})>(
            future: _stats,
            builder: (context, snapshot) {
              final stats = snapshot.data;
              return Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: context.l10n.completedAttempts,
                      value: stats?.attempts.toString() ?? '-',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Metric(
                      label: context.l10n.submittedQuestionSets,
                      value: stats?.submissions.toString() ?? '-',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<({int attempts, int submissions})> _loadStats() async {
    final attempts = await AttemptRepositoryScope.of(
      context,
    ).listExamAttempts();
    final submissions = await widget.contributionRepository.listSubmissions();
    return (attempts: attempts.length, submissions: submissions.length);
  }

  Future<void> _editDisplayName() async {
    final controller = TextEditingController(
      text: AuthScope.of(context).user!.displayName,
    );
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.editDisplayName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: context.l10n.displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.progressCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(context.l10n.saveChanges),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && value.trim().isNotEmpty && mounted) {
      await AuthScope.of(context).updateDisplayName(value);
      if (mounted) setState(() {});
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
