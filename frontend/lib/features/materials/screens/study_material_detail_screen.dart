import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../learning/repositories/learning_repository.dart';
import '../../learning/widgets/learning_state_view.dart';
import '../models/study_material.dart';

class StudyMaterialDetailScreen extends StatefulWidget {
  const StudyMaterialDetailScreen({
    super.key,
    required this.materialId,
    required this.learningRepository,
    this.subjectName,
  });

  final String materialId;
  final LearningRepository learningRepository;
  final String? subjectName;

  @override
  State<StudyMaterialDetailScreen> createState() =>
      _StudyMaterialDetailScreenState();
}

class _StudyMaterialDetailScreenState extends State<StudyMaterialDetailScreen> {
  late Future<StudyMaterial?> _materialFuture;

  @override
  void initState() {
    super.initState();
    _materialFuture = widget.learningRepository.getStudyMaterialById(
      widget.materialId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.materialDetailTitle)),
      body: FutureBuilder<StudyMaterial?>(
        future: _materialFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return LearningLoadingState(message: l10n.loadingMaterials);
          }
          if (snapshot.hasError || snapshot.data == null) {
            return LearningErrorState(
              title: l10n.materialsLoadErrorTitle,
              message: l10n.connectionRetryMessage,
              onRetry: () => setState(() {
                _materialFuture = widget.learningRepository
                    .getStudyMaterialById(widget.materialId);
              }),
            );
          }
          return _MaterialDetailContent(
            material: snapshot.data!,
            subjectName: widget.subjectName,
          );
        },
      ),
    );
  }
}

class _MaterialDetailContent extends StatelessWidget {
  const _MaterialDetailContent({
    required this.material,
    required this.subjectName,
  });

  final StudyMaterial material;
  final String? subjectName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Text(material.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(material.materialType.name.toUpperCase())),
                  if (subjectName != null) Chip(label: Text(subjectName!)),
                  if (material.language != null)
                    Chip(label: Text(material.language!.toUpperCase())),
                ],
              ),
              const SizedBox(height: 20),
              Text(material.description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 24),
              Text(l10n.materialSource, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child:
                      material.sourceType ==
                          StudyMaterialSourceType.externalLink
                      ? _ExternalSource(material: material)
                      : _UploadedFileSource(material: material),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExternalSource extends StatelessWidget {
  const _ExternalSource({required this.material});

  final StudyMaterial material;

  @override
  Widget build(BuildContext context) {
    final url = material.sourceUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.open_in_new),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.externalResource,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
        if (url != null) ...[const SizedBox(height: 12), SelectableText(url)],
      ],
    );
  }
}

class _UploadedFileSource extends StatelessWidget {
  const _UploadedFileSource({required this.material});

  final StudyMaterial material;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.file_present_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.uploadedFile,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
        if (material.fileName != null) ...[
          const SizedBox(height: 12),
          Text(l10n.fileNameLabel(material.fileName!)),
        ],
        if (material.fileSizeBytes != null)
          Text(l10n.fileSizeLabel(_formatBytes(material.fileSizeBytes!))),
        const SizedBox(height: 10),
        Text(l10n.fileUnavailable),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
}
