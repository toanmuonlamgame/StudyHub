import 'package:flutter/material.dart';

import '../app_design_tokens.dart';

enum StudyArtwork { books, compass, trophy }

class StudyIllustration extends StatelessWidget {
  const StudyIllustration(this.artwork, {super.key});

  final StudyArtwork artwork;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/illustrations/${artwork.name}.webp',
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}

class IllustratedStudyPanel extends StatelessWidget {
  const IllustratedStudyPanel({
    super.key,
    required this.artwork,
    required this.child,
    this.featured = false,
  });

  final StudyArtwork artwork;
  final Widget child;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.feature + 4);
    final palette = featured
        ? const [Color(0xFF5431A7), Color(0xFF704BD1)]
        : [colors.primaryContainer, colors.surface];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
        borderRadius: radius,
        border: featured ? null : Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 270 ||
                MediaQuery.textScalerOf(context).scale(16) > 21;
            final artworkWidth = (constraints.maxWidth * .34).clamp(
              90.0,
              146.0,
            );
            final illustration = SizedBox(
              width: compact ? 90 : artworkWidth,
              height: compact ? 76 : artworkWidth,
              child: StudyIllustration(artwork),
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: illustration,
                  ),
                  child,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: child),
                const SizedBox(width: AppSpacing.sm),
                illustration,
              ],
            );
          },
        ),
      ),
    );
  }
}
