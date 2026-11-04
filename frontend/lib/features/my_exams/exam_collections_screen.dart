import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations_x.dart';
import '../learning/models/question_set.dart';
import '../learning/repositories/learning_repository.dart';
import '../saved/bookmark_scope.dart';
import '../saved/screens/saved_question_sets_screen.dart';

typedef ExamCollection = ({String name, List<String> ids});

class ExamCollectionStore {
  ExamCollectionStore({required this.accountKey, required this.session});

  final String? accountKey;
  final Object session;
  static final _guest = Expando<List<ExamCollection>>();
  static const maxCollections = 12;
  static const maxExams = 50;
  String get _key => 'studyhub.exam_collections.$accountKey';

  Future<List<ExamCollection>> load() async {
    if (accountKey == null) return [...?_guest[session]];
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    try {
      final decoded = jsonDecode(raw ?? '[]');
      if (decoded is! List) return [];
      return [
        for (final item in decoded.take(maxCollections))
          if (item is Map && item['name'] is String && item['ids'] is List)
            (
              name: (item['name'] as String).characters.take(50).toString(),
              ids: (item['ids'] as List)
                  .whereType<String>()
                  .where((id) => id.isNotEmpty && id.length <= 128)
                  .toSet()
                  .take(maxExams)
                  .toList(),
            ),
      ];
    } on FormatException {
      return [];
    }
  }

  Future<void> save(List<ExamCollection> collections) async {
    final bounded = collections
        .take(maxCollections)
        .map(
          (item) => (
            name: item.name.trim().characters.take(50).toString(),
            ids: item.ids
                .where((id) => id.isNotEmpty && id.length <= 128)
                .toSet()
                .take(maxExams)
                .toList(),
          ),
        )
        .toList();
    if (accountKey == null) {
      _guest[session] = bounded;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(
      _key,
      jsonEncode([
        for (final item in bounded) {'name': item.name, 'ids': item.ids},
      ]),
    );
    if (!saved) throw StateError('Could not save collections.');
  }
}

class ExamCollectionsScreen extends StatefulWidget {
  const ExamCollectionsScreen({
    super.key,
    required this.repository,
    required this.store,
  });

  final LearningRepository repository;
  final ExamCollectionStore store;

  @override
  State<ExamCollectionsScreen> createState() => _ExamCollectionsScreenState();
}

class _ExamCollectionsScreenState extends State<ExamCollectionsScreen> {
  late Future<List<ExamCollection>> _items = widget.store.load();
  bool _busy = false;

  Future<void> _edit(List<ExamCollection> items, [int? index]) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final saved = await BookmarkScope.of(context).listBookmarks();
      if (!mounted) return;
      final result = await showDialog<ExamCollection>(
        context: context,
        builder: (_) => _CollectionEditor(
          items: saved,
          initial: index == null ? null : items[index],
        ),
      );
      if (!mounted || result == null) return;
      final next = [...items];
      if (index == null) {
        next.add(result);
      } else {
        next[index] = result;
      }
      await _save(next);
    } catch (_) {
      _showError();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(List<ExamCollection> items, int index) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.deleteExamCollection),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.progressCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.contributionRemove),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        await _save([...items]..removeAt(index));
      }
    } catch (_) {
      _showError();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(List<ExamCollection> items) async {
    await widget.store.save(items);
    if (mounted) setState(() => _items = Future.value(items));
  }

  void _showError() {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.savedActionError)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.examCollections)),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<ExamCollection>>(
          future: _items,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: OutlinedButton(
                  onPressed: () => setState(() => _items = widget.store.load()),
                  child: Text(l10n.tryAgain),
                ),
              );
            }
            final items = snapshot.data ?? [];
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(l10n.collectionLocal),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed:
                          _busy ||
                              items.length >= ExamCollectionStore.maxCollections
                          ? null
                          : () => _edit(items),
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: Text(l10n.newExamCollection),
                    ),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(l10n.collectionEmpty),
                      ),
                    for (final (index, item) in items.indexed)
                      ListTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(item.name),
                        onTap: _busy
                            ? null
                            : () => Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => SavedQuestionSetsScreen(
                                    learningRepository: widget.repository,
                                    collectionIds: item.ids.toSet(),
                                    collectionTitle: item.name,
                                  ),
                                ),
                              ),
                        trailing: PopupMenuButton<bool>(
                          enabled: !_busy,
                          onSelected: (edit) => edit
                              ? _edit(items, index)
                              : _delete(items, index),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: true,
                              child: Text(l10n.editCollection),
                            ),
                            PopupMenuItem(
                              value: false,
                              child: Text(l10n.contributionRemove),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CollectionEditor extends StatefulWidget {
  const _CollectionEditor({required this.items, required this.initial});
  final List<QuestionSet> items;
  final ExamCollection? initial;

  @override
  State<_CollectionEditor> createState() => _CollectionEditorState();
}

class _CollectionEditorState extends State<_CollectionEditor> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _ids = (widget.initial?.ids ?? []).toSet()
    ..retainAll(widget.items.map((item) => item.id));

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.examCollections),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              maxLength: 50,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.collectionName),
            ),
            Text(l10n.collectionChooseSaved),
            if (widget.items.isEmpty) Text(l10n.savedEmpty),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (_, index) {
                  final item = widget.items[index];
                  final checked = _ids.contains(item.id);
                  return CheckboxListTile(
                    value: checked,
                    title: Text(item.title),
                    onChanged:
                        !checked && _ids.length >= ExamCollectionStore.maxExams
                        ? null
                        : (selected) => setState(() {
                            if (selected == true) {
                              _ids.add(item.id);
                            } else {
                              _ids.remove(item.id);
                            }
                          }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.progressCancel),
        ),
        FilledButton(
          onPressed: _name.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, (
                  name: _name.text.trim(),
                  ids: _ids.toList(),
                )),
          child: Text(l10n.saveChanges),
        ),
      ],
    );
  }
}
