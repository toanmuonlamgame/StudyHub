import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../bookmark_scope.dart';

class SavedQuestionSetsScreen extends StatefulWidget {
  const SavedQuestionSetsScreen({super.key});

  @override
  State<SavedQuestionSetsScreen> createState() =>
      _SavedQuestionSetsScreenState();
}

class _SavedQuestionSetsScreenState extends State<SavedQuestionSetsScreen> {
  late Future _items;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _items = BookmarkScope.of(context).listBookmarks();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.savedQuestionSets)),
    body: FutureBuilder(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton.icon(
              onPressed: () => setState(
                () => _items = BookmarkScope.of(context).listBookmarks(),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.tryAgain),
            ),
          );
        }
        final items = snapshot.data! as List;
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bookmark_border_rounded, size: 54),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.savedEmpty,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.savedEmptyBody,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.bookmark_rounded),
                title: Text(item.title as String),
                subtitle: Text(
                  context.l10n.questionCount(item.questionCount as int),
                ),
                trailing: IconButton(
                  tooltip: context.l10n.removeFromSaved,
                  onPressed: () async {
                    await BookmarkScope.of(context).remove(item.id as String);
                    if (mounted) {
                      setState(
                        () =>
                            _items = BookmarkScope.of(context).listBookmarks(),
                      );
                    }
                  },
                  icon: const Icon(Icons.bookmark_remove_outlined),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
