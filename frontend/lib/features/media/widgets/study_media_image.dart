import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../learning/models/media_asset.dart';

class StudyMediaImage extends StatelessWidget {
  const StudyMediaImage({super.key, required this.media, this.maxHeight = 260});

  final MediaAsset media;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final image = _image(context, fit: BoxFit.contain);
    return Semantics(
      image: true,
      label: media.altText,
      button: true,
      child: InkWell(
        onTap: () => _preview(context),
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: AspectRatio(
            aspectRatio: _aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: image,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double get _aspectRatio {
    final width = media.width;
    final height = media.height;
    if (width == null || height == null || height <= 0) return 16 / 9;
    return (width / height).clamp(0.75, 2.0);
  }

  Widget _image(BuildContext context, {required BoxFit fit}) {
    final preview = media.previewBytes;
    if (preview != null) {
      return Image.memory(preview, fit: fit, gaplessPlayback: true);
    }
    return Image.network(
      media.thumbnailUrl ?? media.mediaUrl,
      fit: fit,
      cacheWidth: 1280,
      frameBuilder: (context, child, frame, synchronous) =>
          frame != null || synchronous
          ? child
          : const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image_outlined),
              const SizedBox(height: 6),
              Text(context.l10n.imageUnavailable, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _preview(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            media.altText?.trim().isNotEmpty == true
                ? media.altText!
                : context.l10n.imagePreview,
          ),
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ),
        body: SafeArea(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Center(child: _image(context, fit: BoxFit.contain)),
          ),
        ),
      ),
    ),
  );
}
