import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @progressCompletedSessions.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions'**
  String get progressCompletedSessions;

  /// No description provided for @progressAverageAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Average accuracy'**
  String get progressAverageAccuracy;

  /// No description provided for @progressCompletedQuestionSets.
  ///
  /// In en, this message translates to:
  /// **'Completed sets'**
  String get progressCompletedQuestionSets;

  /// No description provided for @progressLatestActivity.
  ///
  /// In en, this message translates to:
  /// **'Latest activity'**
  String get progressLatestActivity;

  /// No description provided for @progressRecentResults.
  ///
  /// In en, this message translates to:
  /// **'Recent results'**
  String get progressRecentResults;

  /// No description provided for @progressNoHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No progress yet'**
  String get progressNoHistoryTitle;

  /// No description provided for @progressNoHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Complete an Exam or Practice session to build your local learning history.'**
  String get progressNoHistoryBody;

  /// No description provided for @progressExamSession.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get progressExamSession;

  /// No description provided for @progressPracticeSession.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get progressPracticeSession;

  /// No description provided for @progressScoreSummary.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String progressScoreSummary(Object correct, Object total);

  /// No description provided for @progressClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get progressClearHistory;

  /// No description provided for @progressClearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear local history?'**
  String get progressClearHistoryTitle;

  /// No description provided for @progressClearHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'This removes completed sessions stored on this device. It cannot be undone.'**
  String get progressClearHistoryBody;

  /// No description provided for @progressCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get progressCancel;

  /// No description provided for @progressConfirmClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get progressConfirmClear;

  /// No description provided for @progressHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'Progress history cleared.'**
  String get progressHistoryCleared;

  /// No description provided for @progressHistoryClearError.
  ///
  /// In en, this message translates to:
  /// **'Progress history could not be cleared.'**
  String get progressHistoryClearError;

  /// No description provided for @progressLoadError.
  ///
  /// In en, this message translates to:
  /// **'Progress could not be loaded.'**
  String get progressLoadError;

  /// No description provided for @progressSaveError.
  ///
  /// In en, this message translates to:
  /// **'Your result is safe, but local progress could not be saved.'**
  String get progressSaveError;

  /// No description provided for @progressLocalOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device only'**
  String get progressLocalOnlyNote;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'StudyHub'**
  String get appTitle;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @learnTab.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnTab;

  /// No description provided for @progressTab.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get startLearning;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Learn with focus. Review with confidence.'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a subject, practise with trusted feedback, or test yourself in Exam Mode.'**
  String get homeSubtitle;

  /// No description provided for @answersHiddenNote.
  ///
  /// In en, this message translates to:
  /// **'Answers stay hidden until you submit or check.'**
  String get answersHiddenNote;

  /// No description provided for @learningModes.
  ///
  /// In en, this message translates to:
  /// **'Learning modes'**
  String get learningModes;

  /// No description provided for @learningModesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the right mode for each study session.'**
  String get learningModesSubtitle;

  /// No description provided for @examMode.
  ///
  /// In en, this message translates to:
  /// **'Exam Mode'**
  String get examMode;

  /// No description provided for @practiceMode.
  ///
  /// In en, this message translates to:
  /// **'Practice Mode'**
  String get practiceMode;

  /// No description provided for @safeReview.
  ///
  /// In en, this message translates to:
  /// **'Safe Review'**
  String get safeReview;

  /// No description provided for @examModePreview.
  ///
  /// In en, this message translates to:
  /// **'Answer the full set, then submit for your score and review.'**
  String get examModePreview;

  /// No description provided for @practiceModePreview.
  ///
  /// In en, this message translates to:
  /// **'Check each answer and learn from immediate trusted feedback.'**
  String get practiceModePreview;

  /// No description provided for @safeReviewPreview.
  ///
  /// In en, this message translates to:
  /// **'Correct answers appear only after submit or check answer.'**
  String get safeReviewPreview;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @howItWorksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move from a subject to a focused result review.'**
  String get howItWorksSubtitle;

  /// No description provided for @pickSubjectStep.
  ///
  /// In en, this message translates to:
  /// **'Pick a subject'**
  String get pickSubjectStep;

  /// No description provided for @chooseQuestionSetStep.
  ///
  /// In en, this message translates to:
  /// **'Choose a question set'**
  String get chooseQuestionSetStep;

  /// No description provided for @learnOrExamStep.
  ///
  /// In en, this message translates to:
  /// **'Practise or take an exam'**
  String get learnOrExamStep;

  /// No description provided for @reviewResultsStep.
  ///
  /// In en, this message translates to:
  /// **'Review your results'**
  String get reviewResultsStep;

  /// No description provided for @browseSubjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse subjects'**
  String get browseSubjectsTitle;

  /// No description provided for @chooseSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a subject'**
  String get chooseSubjectTitle;

  /// No description provided for @chooseSubjectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a subject to find question sets for your next study session.'**
  String get chooseSubjectSubtitle;

  /// No description provided for @loadingSubjects.
  ///
  /// In en, this message translates to:
  /// **'Loading subjects'**
  String get loadingSubjects;

  /// No description provided for @subjectsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Subjects could not be loaded'**
  String get subjectsLoadErrorTitle;

  /// No description provided for @connectionRetryMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get connectionRetryMessage;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noSubjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No subjects yet'**
  String get noSubjectsTitle;

  /// No description provided for @noSubjectsMessage.
  ///
  /// In en, this message translates to:
  /// **'Subjects will appear here when learning content is available.'**
  String get noSubjectsMessage;

  /// No description provided for @openSubjectSemantics.
  ///
  /// In en, this message translates to:
  /// **'Open {subjectName}'**
  String openSubjectSemantics(Object subjectName);

  /// No description provided for @schoolMetadata.
  ///
  /// In en, this message translates to:
  /// **'School: {value}'**
  String schoolMetadata(Object value);

  /// No description provided for @programMetadata.
  ///
  /// In en, this message translates to:
  /// **'Program: {value}'**
  String programMetadata(Object value);

  /// No description provided for @majorMetadata.
  ///
  /// In en, this message translates to:
  /// **'Major: {value}'**
  String majorMetadata(Object value);

  /// No description provided for @questionSetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Question sets'**
  String get questionSetsTitle;

  /// No description provided for @chooseQuestionSetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a question set to review its details.'**
  String get chooseQuestionSetSubtitle;

  /// No description provided for @searchQuestionSetsHint.
  ///
  /// In en, this message translates to:
  /// **'Search question-set titles'**
  String get searchQuestionSetsHint;

  /// No description provided for @clearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchTooltip;

  /// No description provided for @allTopics.
  ///
  /// In en, this message translates to:
  /// **'All topics'**
  String get allTopics;

  /// No description provided for @topicsLabel.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topicsLabel;

  /// No description provided for @loadingQuestionSets.
  ///
  /// In en, this message translates to:
  /// **'Loading question sets'**
  String get loadingQuestionSets;

  /// No description provided for @searchingQuestionSets.
  ///
  /// In en, this message translates to:
  /// **'Searching question sets'**
  String get searchingQuestionSets;

  /// No description provided for @questionSetsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Question sets could not be loaded'**
  String get questionSetsLoadErrorTitle;

  /// No description provided for @searchLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Search could not be completed'**
  String get searchLoadErrorTitle;

  /// No description provided for @noQuestionSetsTitle.
  ///
  /// In en, this message translates to:
  /// **'No question sets yet'**
  String get noQuestionSetsTitle;

  /// No description provided for @noQuestionSetsMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no question sets for {subjectName} yet.'**
  String noQuestionSetsMessage(Object subjectName);

  /// No description provided for @noSearchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching question sets'**
  String get noSearchResultsTitle;

  /// No description provided for @noSearchResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter title or clear the search.'**
  String get noSearchResultsMessage;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @loadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get loadingMore;

  /// No description provided for @loadMoreError.
  ///
  /// In en, this message translates to:
  /// **'More question sets could not be loaded.'**
  String get loadMoreError;

  /// No description provided for @retryLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLoadMore;

  /// No description provided for @questionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questionCount(Object count);

  /// No description provided for @minuteCount.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minuteCount(Object count);

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @openQuestionSetSemantics.
  ///
  /// In en, this message translates to:
  /// **'Open {title}'**
  String openQuestionSetSemantics(Object title);

  /// No description provided for @questionSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Question set'**
  String get questionSetTitle;

  /// No description provided for @aboutQuestionSet.
  ///
  /// In en, this message translates to:
  /// **'About this question set'**
  String get aboutQuestionSet;

  /// No description provided for @answersHiddenDetail.
  ///
  /// In en, this message translates to:
  /// **'Correct answers stay hidden until you submit or check an answer.'**
  String get answersHiddenDetail;

  /// No description provided for @chooseLearningMode.
  ///
  /// In en, this message translates to:
  /// **'Choose learning mode'**
  String get chooseLearningMode;

  /// No description provided for @modeSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning mode'**
  String get modeSelectionTitle;

  /// No description provided for @modeSelectionHeading.
  ///
  /// In en, this message translates to:
  /// **'How do you want to learn?'**
  String get modeSelectionHeading;

  /// No description provided for @modeSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the experience that fits this study session.'**
  String get modeSelectionSubtitle;

  /// No description provided for @examModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Answer every question without feedback, then submit and review at the end.'**
  String get examModeDescription;

  /// No description provided for @practiceModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Check each answer immediately, learn from feedback, and finish with a summary.'**
  String get practiceModeDescription;

  /// No description provided for @startExamMode.
  ///
  /// In en, this message translates to:
  /// **'Start Exam Mode'**
  String get startExamMode;

  /// No description provided for @startPracticeMode.
  ///
  /// In en, this message translates to:
  /// **'Start Practice Mode'**
  String get startPracticeMode;

  /// No description provided for @loadingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Loading questions'**
  String get loadingQuestions;

  /// No description provided for @questionsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions could not be loaded'**
  String get questionsLoadErrorTitle;

  /// No description provided for @noQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No questions yet'**
  String get noQuestionsTitle;

  /// No description provided for @noQuestionsMessage.
  ///
  /// In en, this message translates to:
  /// **'This question set is not ready for a quiz session.'**
  String get noQuestionsMessage;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionProgress(Object current, Object total);

  /// No description provided for @answeredCount.
  ///
  /// In en, this message translates to:
  /// **'{count} answered'**
  String answeredCount(Object count);

  /// No description provided for @instantFeedback.
  ///
  /// In en, this message translates to:
  /// **'Instant feedback'**
  String get instantFeedback;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// No description provided for @submitQuiz.
  ///
  /// In en, this message translates to:
  /// **'Submit Quiz'**
  String get submitQuiz;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @finishPractice.
  ///
  /// In en, this message translates to:
  /// **'Finish Practice'**
  String get finishPractice;

  /// No description provided for @checkingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Checking answer...'**
  String get checkingAnswer;

  /// No description provided for @answerCheckError.
  ///
  /// In en, this message translates to:
  /// **'Answer could not be checked.'**
  String get answerCheckError;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {answer}'**
  String yourAnswer(Object answer);

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String correctAnswer(Object answer);

  /// No description provided for @chooseOneAnswer.
  ///
  /// In en, this message translates to:
  /// **'Choose one answer.'**
  String get chooseOneAnswer;

  /// No description provided for @answerEveryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Answer every question before submitting.'**
  String get answerEveryQuestion;

  /// No description provided for @quizSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Quiz could not be submitted.'**
  String get quizSubmitError;

  /// No description provided for @examResult.
  ///
  /// In en, this message translates to:
  /// **'Exam Result'**
  String get examResult;

  /// No description provided for @practiceResult.
  ///
  /// In en, this message translates to:
  /// **'Practice Result'**
  String get practiceResult;

  /// No description provided for @strongResultMessage.
  ///
  /// In en, this message translates to:
  /// **'Strong result. Keep the momentum going.'**
  String get strongResultMessage;

  /// No description provided for @goodResultMessage.
  ///
  /// In en, this message translates to:
  /// **'Good progress. Review the missed answers below.'**
  String get goodResultMessage;

  /// No description provided for @learningResultMessage.
  ///
  /// In en, this message translates to:
  /// **'Every review builds understanding. Try the set again when ready.'**
  String get learningResultMessage;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct answers'**
  String get correctAnswers;

  /// No description provided for @wrongAnswers.
  ///
  /// In en, this message translates to:
  /// **'Wrong answers'**
  String get wrongAnswers;

  /// No description provided for @totalQuestions.
  ///
  /// In en, this message translates to:
  /// **'Total questions'**
  String get totalQuestions;

  /// No description provided for @answerReview.
  ///
  /// In en, this message translates to:
  /// **'Answer review'**
  String get answerReview;

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionNumber(Object number);

  /// No description provided for @notAnswered.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get notAnswered;

  /// No description provided for @backToQuestionSet.
  ///
  /// In en, this message translates to:
  /// **'Back to Question Set'**
  String get backToQuestionSet;

  /// No description provided for @progressPlannedTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress tracking is planned'**
  String get progressPlannedTitle;

  /// No description provided for @progressPlannedMessage.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions and learning history will appear here after secure progress storage is implemented.'**
  String get progressPlannedMessage;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @selectedLanguageSemantics.
  ///
  /// In en, this message translates to:
  /// **'Selected language: {language}'**
  String selectedLanguageSemantics(Object language);

  /// No description provided for @aboutStudyHub.
  ///
  /// In en, this message translates to:
  /// **'About StudyHub'**
  String get aboutStudyHub;

  /// No description provided for @settingsIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose your interface language. More preferences will appear only when they are functional.'**
  String get settingsIntro;

  /// No description provided for @mobileLearningPlatform.
  ///
  /// In en, this message translates to:
  /// **'Mobile learning platform'**
  String get mobileLearningPlatform;

  /// No description provided for @mobileLearningPlatformDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse question sets, practise, take exams, and review results.'**
  String get mobileLearningPlatformDescription;

  /// No description provided for @learningSafety.
  ///
  /// In en, this message translates to:
  /// **'Learning safety'**
  String get learningSafety;

  /// No description provided for @learningSafetyDescription.
  ///
  /// In en, this message translates to:
  /// **'Correct answers stay hidden until submit or check answer.'**
  String get learningSafetyDescription;

  /// No description provided for @dataSafety.
  ///
  /// In en, this message translates to:
  /// **'App data safety'**
  String get dataSafety;

  /// No description provided for @dataSafetyDescription.
  ///
  /// In en, this message translates to:
  /// **'Secrets and private keys do not belong in the app.'**
  String get dataSafetyDescription;

  /// No description provided for @activeDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Active development'**
  String get activeDevelopment;

  /// No description provided for @activeDevelopmentDescription.
  ///
  /// In en, this message translates to:
  /// **'StudyHub is growing through small, tested learning milestones.'**
  String get activeDevelopmentDescription;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Ready to learn?'**
  String get homeGreeting;

  /// No description provided for @homeSupportingLine.
  ///
  /// In en, this message translates to:
  /// **'Choose a destination and make this session count.'**
  String get homeSupportingLine;

  /// No description provided for @featuredSection.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featuredSection;

  /// No description provided for @featuredModesTitle.
  ///
  /// In en, this message translates to:
  /// **'Two ways to learn'**
  String get featuredModesTitle;

  /// No description provided for @featuredModesBody.
  ///
  /// In en, this message translates to:
  /// **'Use Exam Mode to test yourself or Practice Mode for instant feedback.'**
  String get featuredModesBody;

  /// No description provided for @featuredModesAction.
  ///
  /// In en, this message translates to:
  /// **'Explore modes'**
  String get featuredModesAction;

  /// No description provided for @featuredSetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your next question set'**
  String get featuredSetsTitle;

  /// No description provided for @featuredSetsBody.
  ///
  /// In en, this message translates to:
  /// **'Browse by subject, search titles, and filter by topic.'**
  String get featuredSetsBody;

  /// No description provided for @featuredSetsAction.
  ///
  /// In en, this message translates to:
  /// **'Browse sets'**
  String get featuredSetsAction;

  /// No description provided for @featuredProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your progress'**
  String get featuredProgressTitle;

  /// No description provided for @featuredProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Completed Exam and Practice sessions are saved on this device.'**
  String get featuredProgressBody;

  /// No description provided for @featuredProgressAction.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get featuredProgressAction;

  /// No description provided for @bannerPageSemantics.
  ///
  /// In en, this message translates to:
  /// **'Featured item {current} of {total}'**
  String bannerPageSemantics(Object current, Object total);

  /// No description provided for @quickActionsSection.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActionsSection;

  /// No description provided for @browseSubjects.
  ///
  /// In en, this message translates to:
  /// **'Browse subjects'**
  String get browseSubjects;

  /// No description provided for @continueLearningSection.
  ///
  /// In en, this message translates to:
  /// **'Start a learning session'**
  String get continueLearningSection;

  /// No description provided for @continueLearningBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a subject and continue to a focused question set.'**
  String get continueLearningBody;

  /// No description provided for @learningModesCompactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the mode after opening a question set.'**
  String get learningModesCompactSubtitle;

  /// No description provided for @examModeCompactBody.
  ///
  /// In en, this message translates to:
  /// **'Submit at the end, then review.'**
  String get examModeCompactBody;

  /// No description provided for @practiceModeCompactBody.
  ///
  /// In en, this message translates to:
  /// **'Check answers now, then see a summary.'**
  String get practiceModeCompactBody;

  /// No description provided for @exploreSection.
  ///
  /// In en, this message translates to:
  /// **'Explore more'**
  String get exploreSection;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @studyMaterials.
  ///
  /// In en, this message translates to:
  /// **'Study Materials'**
  String get studyMaterials;

  /// No description provided for @savedContent.
  ///
  /// In en, this message translates to:
  /// **'Saved Content'**
  String get savedContent;

  /// No description provided for @learningPlans.
  ///
  /// In en, this message translates to:
  /// **'Learning Plans'**
  String get learningPlans;

  /// No description provided for @upcomingFeatureSemantics.
  ///
  /// In en, this message translates to:
  /// **'{feature}, coming soon'**
  String upcomingFeatureSemantics(Object feature);

  /// No description provided for @progressOverview.
  ///
  /// In en, this message translates to:
  /// **'Your learning overview'**
  String get progressOverview;

  /// No description provided for @progressOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real attempt data will appear here when progress storage is ready.'**
  String get progressOverviewSubtitle;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @recentResults.
  ///
  /// In en, this message translates to:
  /// **'Recent Results'**
  String get recentResults;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @completedSets.
  ///
  /// In en, this message translates to:
  /// **'Completed Sets'**
  String get completedSets;

  /// No description provided for @learningActivity.
  ///
  /// In en, this message translates to:
  /// **'Learning Activity'**
  String get learningActivity;

  /// No description provided for @progressStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your first learning record'**
  String get progressStartTitle;

  /// No description provided for @progressStartBody.
  ///
  /// In en, this message translates to:
  /// **'Learning works now; saved history will follow in a later milestone.'**
  String get progressStartBody;

  /// No description provided for @futurePreferences.
  ///
  /// In en, this message translates to:
  /// **'Future preferences'**
  String get futurePreferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @futurePreferenceDescription.
  ///
  /// In en, this message translates to:
  /// **'Available in a later milestone'**
  String get futurePreferenceDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
