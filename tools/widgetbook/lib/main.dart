import 'package:flutter/material.dart';
import 'package:frontend/core/app_theme.dart';
import 'package:frontend/features/home/widgets/home_hub_widgets.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/l10n/app_localizations_x.dart';
import 'package:widgetbook/widgetbook.dart';

void main() => runApp(
  Widgetbook.material(
    directories: [
      WidgetbookComponent(
        name: 'Home learning card',
        useCases: [
          WidgetbookUseCase(
            name: 'English',
            builder: (_) => const _Preview(locale: Locale('en')),
          ),
          WidgetbookUseCase(
            name: 'Vietnamese / large text',
            builder: (_) => const _Preview(locale: Locale('vi'), scale: 1.5),
          ),
        ],
      ),
    ],
  ),
);

class _Preview extends StatelessWidget {
  const _Preview({required this.locale, this.scale = 1});

  final Locale locale;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: locale,
      delegates: AppLocalizations.localizationsDelegates,
      child: Theme(
        data: AppTheme.light,
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: PrimaryLearningCard(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l10n.startLearning)),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
