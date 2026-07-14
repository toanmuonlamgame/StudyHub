import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../learning/models/subject.dart';
import '../../learning/repositories/learning_repository.dart';
import '../../learning/widgets/learning_state_view.dart';
import '../models/study_material.dart';
import 'study_material_detail_screen.dart';

class StudyMaterialListScreen extends StatefulWidget {
  const StudyMaterialListScreen({super.key, required this.learningRepository});

  final LearningRepository learningRepository;

  @override
  State<StudyMaterialListScreen> createState() =>
      _StudyMaterialListScreenState();
}

class _StudyMaterialListScreenState extends State<StudyMaterialListScreen> {
  static const _pageSize = 20;
  static const _searchDebounce = Duration(milliseconds: 400);

  final _searchController = TextEditingController();
  final List<StudyMaterial> _materials = [];
  Timer? _searchTimer;
  List<Subject> _subjects = const [];
  String _query = '';
  String? _subjectId;
  StudyMaterialType? _materialType;
  String? _language;
  String? _nextCursor;
  bool _hasMore = false;
  bool _loading = true;
  bool _loadFailed = false;
  bool _loadingMore = false;
  bool _loadMoreFailed = false;
  int _requestGeneration = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSubjects());
    unawaited(_loadFirstPage());
  }

  @override
  void dispose() {
    _requestGeneration++;
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.studyMaterialsTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.studyMaterialsSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: TextField(
                key: const ValueKey('material-search-field'),
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: _applySearch,
                decoration: InputDecoration(
                  hintText: l10n.searchMaterialsHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.clearSearchTooltip,
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                children: [
                  _FilterMenu<String>(
                    key: const ValueKey('material-subject-filter'),
                    value: _subjectId,
                    allLabel: l10n.allSubjects,
                    entries: _subjects
                        .map(
                          (subject) => DropdownMenuItem(
                            value: subject.id,
                            child: Text(subject.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      _subjectId = value;
                      unawaited(_loadFirstPage());
                    },
                  ),
                  const SizedBox(width: 10),
                  _FilterMenu<StudyMaterialType>(
                    key: const ValueKey('material-type-filter'),
                    value: _materialType,
                    allLabel: l10n.allMaterialTypes,
                    entries: StudyMaterialType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(_materialTypeLabel(context, type)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      _materialType = value;
                      unawaited(_loadFirstPage());
                    },
                  ),
                  const SizedBox(width: 10),
                  _FilterMenu<String>(
                    key: const ValueKey('material-language-filter'),
                    value: _language,
                    allLabel: l10n.allLanguages,
                    entries: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                    ],
                    onChanged: (value) {
                      _language = value;
                      unawaited(_loadFirstPage());
                    },
                  ),
                ],
              ),
            ),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return LearningLoadingState(
        message: _query.isEmpty
            ? l10n.loadingMaterials
            : l10n.searchingMaterials,
      );
    }
    if (_loadFailed) {
      return LearningErrorState(
        title: l10n.materialsLoadErrorTitle,
        message: l10n.connectionRetryMessage,
        onRetry: _loadFirstPage,
      );
    }
    if (_materials.isEmpty) {
      return LearningEmptyState(
        icon: Icons.description_outlined,
        title: l10n.noMaterialsTitle,
        message: l10n.noMaterialsMessage,
        actionLabel: _query.isEmpty ? null : l10n.clearSearch,
        onAction: _query.isEmpty ? null : _clearSearch,
      );
    }
    return ListView.separated(
      key: const ValueKey('material-list'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      itemCount: _materials.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == _materials.length) {
          return _buildLoadMore(context);
        }
        final material = _materials[index];
        return _StudyMaterialCard(
          material: material,
          subjectName: _subjectName(material.subjectId),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StudyMaterialDetailScreen(
                materialId: material.id,
                subjectName: _subjectName(material.subjectId),
                learningRepository: widget.learningRepository,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadMore(BuildContext context) {
    final l10n = context.l10n;
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadMoreFailed) {
      return OutlinedButton.icon(
        onPressed: _loadMore,
        icon: const Icon(Icons.refresh),
        label: Text(l10n.retryLoadMore),
      );
    }
    if (!_hasMore) {
      return const SizedBox.shrink();
    }
    return OutlinedButton.icon(
      onPressed: _loadMore,
      icon: const Icon(Icons.expand_more),
      label: Text(l10n.loadMore),
    );
  }

  Future<void> _loadSubjects() async {
    try {
      final subjects = await widget.learningRepository.getSubjects();
      if (mounted) {
        setState(() => _subjects = subjects);
      }
    } catch (_) {
      // Subject labels are helpful, but materials remain browsable without them.
    }
  }

  Future<void> _loadFirstPage() async {
    final generation = ++_requestGeneration;
    setState(() {
      _loading = true;
      _loadFailed = false;
      _loadingMore = false;
      _loadMoreFailed = false;
      _materials.clear();
      _nextCursor = null;
      _hasMore = false;
    });
    try {
      final page = await widget.learningRepository.listStudyMaterials(
        subjectId: _subjectId,
        q: _query.isEmpty ? null : _query,
        materialType: _materialType,
        language: _language,
        limit: _pageSize,
      );
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _materials.addAll(_deduplicate(page.items));
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore && page.nextCursor != null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _nextCursor == null) return;
    final generation = _requestGeneration;
    setState(() {
      _loadingMore = true;
      _loadMoreFailed = false;
    });
    try {
      final page = await widget.learningRepository.listStudyMaterials(
        subjectId: _subjectId,
        q: _query.isEmpty ? null : _query,
        materialType: _materialType,
        language: _language,
        limit: _pageSize,
        cursor: _nextCursor,
      );
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        final ids = _materials.map((material) => material.id).toSet();
        _materials.addAll(page.items.where((material) => ids.add(material.id)));
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore && page.nextCursor != null;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _loadingMore = false;
        _loadMoreFailed = true;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDebounce, () => _applySearch(value));
  }

  void _applySearch(String value) {
    _searchTimer?.cancel();
    final normalized = value.trim();
    if (normalized == _query) return;
    _query = normalized;
    unawaited(_loadFirstPage());
  }

  void _clearSearch() {
    _searchController.clear();
    _applySearch('');
    setState(() {});
  }

  List<StudyMaterial> _deduplicate(List<StudyMaterial> items) {
    final ids = <String>{};
    return items.where((item) => ids.add(item.id)).toList(growable: false);
  }

  String? _subjectName(String id) {
    for (final subject in _subjects) {
      if (subject.id == id) return subject.name;
    }
    return null;
  }
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({
    super.key,
    required this.value,
    required this.allLabel,
    required this.entries,
    required this.onChanged,
  });

  final T? value;
  final String allLabel;
  final List<DropdownMenuItem<T>> entries;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(allLabel),
          items: [
            DropdownMenuItem<T>(value: null, child: Text(allLabel)),
            ...entries,
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StudyMaterialCard extends StatelessWidget {
  const _StudyMaterialCard({
    required this.material,
    required this.subjectName,
    required this.onTap,
  });

  final StudyMaterial material;
  final String? subjectName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: context.l10n.openMaterialSemantics(material.title),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_materialIcon(material.materialType)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        material.title,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  material.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        _materialTypeLabel(context, material.materialType),
                      ),
                    ),
                    if (subjectName != null) Chip(label: Text(subjectName!)),
                    if (material.language != null)
                      Chip(label: Text(material.language!.toUpperCase())),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _materialTypeLabel(BuildContext context, StudyMaterialType type) {
  final l10n = context.l10n;
  return switch (type) {
    StudyMaterialType.pdf => l10n.materialTypePdf,
    StudyMaterialType.slides => l10n.materialTypeSlides,
    StudyMaterialType.notes => l10n.materialTypeNotes,
    StudyMaterialType.document => l10n.materialTypeDocument,
    StudyMaterialType.link => l10n.materialTypeLink,
    StudyMaterialType.other => l10n.materialTypeOther,
  };
}

IconData _materialIcon(StudyMaterialType type) {
  return switch (type) {
    StudyMaterialType.pdf => Icons.picture_as_pdf_outlined,
    StudyMaterialType.slides => Icons.slideshow_outlined,
    StudyMaterialType.notes => Icons.sticky_note_2_outlined,
    StudyMaterialType.document => Icons.description_outlined,
    StudyMaterialType.link => Icons.link,
    StudyMaterialType.other => Icons.insert_drive_file_outlined,
  };
}
