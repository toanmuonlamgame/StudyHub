import '../../../l10n/app_localizations.dart';

const examLanguageCodes = ['vi', 'en', 'zh', 'other'];

String examLanguageLabel(AppLocalizations l10n, String? code) => switch (code) {
  'vi' => l10n.vietnamese,
  'en' => l10n.english,
  'zh' => l10n.chinese,
  'other' => l10n.otherExamLanguage,
  _ => l10n.examLanguageUnknown,
};
