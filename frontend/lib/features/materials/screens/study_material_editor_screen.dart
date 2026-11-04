import 'package:flutter/material.dart';

import '../../../core/app_design_tokens.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../contribution/repositories/contribution_repository.dart';
import '../../learning/models/subject.dart';
import '../../learning/models/topic.dart';
import '../../learning/repositories/learning_repository.dart';
import '../models/study_material.dart';
import '../models/study_material_submission.dart';

class StudyMaterialEditorScreen extends StatefulWidget {
  const StudyMaterialEditorScreen({
    super.key,
    required this.learningRepository,
    required this.contributionRepository,
    this.initialSubmission,
  });

  final LearningRepository learningRepository;
  final ContributionRepository contributionRepository;
  final StudyMaterialSubmission? initialSubmission;

  @override
  State<StudyMaterialEditorScreen> createState() =>
      _StudyMaterialEditorScreenState();
}

class _StudyMaterialEditorScreenState extends State<StudyMaterialEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _urlController;
  late final TextEditingController _languageController;
  List<Subject> _subjects = const [];
  List<Topic> _topics = const [];
  String? _subjectId;
  String? _topicId;
  late StudyMaterialType _materialType;
  StudyMaterialSubmission? _workingSubmission;
  late final String _clientSubmissionId;
  bool _loading = true;
  bool _saving = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialSubmission?.draft;
    _workingSubmission = widget.initialSubmission;
    _clientSubmissionId =
        'material-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
    _titleController = TextEditingController(text: draft?.title);
    _descriptionController = TextEditingController(text: draft?.description);
    _urlController = TextEditingController(text: draft?.sourceUrl);
    _languageController = TextEditingController(text: draft?.language);
    _subjectId = draft?.subjectId;
    _topicId = draft?.topicId;
    _materialType = draft?.materialType ?? StudyMaterialType.document;
    _loadTaxonomy();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.materialEditorTitle)),
    body: SafeArea(child: _buildBody()),
  );

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_loadError != null) {
      return Center(
        child: FilledButton.icon(
          onPressed: _loadTaxonomy,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(context.l10n.tryAgain),
        ),
      );
    }
    return Form(
      key: _formKey,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            context.l10n.materialEditorIntro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          DropdownButtonFormField<String>(
            initialValue: _subjectId,
            decoration: InputDecoration(
              labelText: context.l10n.contributionSubject,
            ),
            items: [
              for (final subject in _subjects)
                DropdownMenuItem(value: subject.id, child: Text(subject.name)),
            ],
            onChanged: _saving ? null : _selectSubject,
            validator: (value) =>
                value == null ? context.l10n.materialSubjectRequired : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String?>(
            initialValue: _topicId,
            decoration: InputDecoration(
              labelText: context.l10n.contributionTopicOptional,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(context.l10n.allTopics),
              ),
              for (final topic in _topics)
                DropdownMenuItem<String?>(
                  value: topic.id,
                  child: Text(topic.name),
                ),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _topicId = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _titleController,
            maxLength: 120,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.l10n.contributionSetTitle,
            ),
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _descriptionController,
            maxLength: 1000,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: context.l10n.contributionDescription,
            ),
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<StudyMaterialType>(
            initialValue: _materialType,
            decoration: InputDecoration(labelText: context.l10n.materialType),
            items: [
              for (final type in StudyMaterialType.values)
                DropdownMenuItem(value: type, child: Text(_typeLabel(type))),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _materialType = value!),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.l10n.materialSourceUrl,
              prefixIcon: const Icon(Icons.link_rounded),
            ),
            validator: _validateUrl,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _languageController,
            maxLength: 12,
            decoration: InputDecoration(
              labelText: context.l10n.materialLanguageOptional,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _saving ? null : () => _save(submit: true),
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(context.l10n.contributionSubmitForReview),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: _saving ? null : () => _save(submit: false),
            icon: const Icon(Icons.save_outlined),
            label: Text(context.l10n.contributionSaveDraft),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTaxonomy() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final subjects = await widget.learningRepository.getSubjects();
      final selected =
          _subjectId ?? (subjects.isEmpty ? null : subjects.first.id);
      final topics = selected == null
          ? const <Topic>[]
          : await widget.learningRepository.getTopicsBySubjectId(selected);
      if (!mounted) return;
      setState(() {
        _subjects = subjects;
        _subjectId = selected;
        _topics = topics;
        if (!_topics.any((topic) => topic.id == _topicId)) {
          _topicId = null;
        }
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadError = error;
          _loading = false;
        });
      }
    }
  }

  Future<void> _selectSubject(String? value) async {
    setState(() {
      _subjectId = value;
      _topicId = null;
      _topics = const [];
    });
    if (value == null) return;
    try {
      final topics = await widget.learningRepository.getTopicsBySubjectId(
        value,
      );
      if (mounted && _subjectId == value) {
        setState(() => _topics = topics);
      }
    } catch (_) {
      if (mounted) _showMessage(context.l10n.materialTaxonomyError);
    }
  }

  Future<void> _save({required bool submit}) async {
    if (!_formKey.currentState!.validate() || _subjectId == null) return;
    setState(() => _saving = true);
    final draft = StudyMaterialDraft(
      subjectId: _subjectId!,
      topicId: _topicId,
      title: _titleController.text,
      description: _descriptionController.text,
      materialType: _materialType,
      sourceUrl: _urlController.text,
      language: _languageController.text,
    );
    try {
      final current = _workingSubmission;
      final saved = current == null
          ? await widget.contributionRepository.createMaterialDraft(
              draft,
              submissionId: _clientSubmissionId,
            )
          : await widget.contributionRepository.updateMaterialDraft(
              current.id,
              draft,
            );
      _workingSubmission = saved;
      if (submit) {
        await widget.contributionRepository.submitMaterialDraftForReview(
          saved.id,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) _showMessage(context.l10n.materialSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? context.l10n.contributionValidationRequired
      : null;

  String? _validateUrl(String? value) {
    final uri = Uri.tryParse(value?.trim() ?? '');
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return context.l10n.materialUrlInvalid;
    }
    return null;
  }

  String _typeLabel(StudyMaterialType type) => switch (type) {
    StudyMaterialType.pdf => context.l10n.materialTypePdf,
    StudyMaterialType.slides => context.l10n.materialTypeSlides,
    StudyMaterialType.notes => context.l10n.materialTypeNotes,
    StudyMaterialType.document => context.l10n.materialTypeDocument,
    StudyMaterialType.link => context.l10n.materialTypeLink,
    StudyMaterialType.other => context.l10n.materialTypeOther,
  };

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _languageController.dispose();
    super.dispose();
  }
}
