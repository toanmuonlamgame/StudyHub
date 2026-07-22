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

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @takeAnotherExam.
  ///
  /// In en, this message translates to:
  /// **'Take another exam'**
  String get takeAnotherExam;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

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

  /// No description provided for @examAnswerStatus.
  ///
  /// In en, this message translates to:
  /// **'{answered} answered · {unanswered} unanswered'**
  String examAnswerStatus(Object answered, Object unanswered);

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

  /// No description provided for @submitExamTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit exam?'**
  String get submitExamTitle;

  /// No description provided for @submitWithUnanswered.
  ///
  /// In en, this message translates to:
  /// **'{count} unanswered question(s) remain. Submit anyway?'**
  String submitWithUnanswered(Object count);

  /// No description provided for @submitAnyway.
  ///
  /// In en, this message translates to:
  /// **'Submit anyway'**
  String get submitAnyway;

  /// No description provided for @leaveExamTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave exam?'**
  String get leaveExamTitle;

  /// No description provided for @discardExamProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'Your selected answers will be discarded.'**
  String get discardExamProgressMessage;

  /// No description provided for @keepLearning.
  ///
  /// In en, this message translates to:
  /// **'Keep learning'**
  String get keepLearning;

  /// No description provided for @discardProgress.
  ///
  /// In en, this message translates to:
  /// **'Discard progress'**
  String get discardProgress;

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

  /// No description provided for @unansweredAnswers.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get unansweredAnswers;

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

  /// No description provided for @unanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get unanswered;

  /// No description provided for @yourChoice.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourChoice;

  /// No description provided for @correctChoice.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get correctChoice;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

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

  /// No description provided for @homeGreetingName.
  ///
  /// In en, this message translates to:
  /// **'Ready to learn, {name}?'**
  String homeGreetingName(String name);

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

  /// No description provided for @studyMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Materials'**
  String get studyMaterialsTitle;

  /// No description provided for @studyMaterialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse trusted learning resources by subject and format.'**
  String get studyMaterialsSubtitle;

  /// No description provided for @searchMaterialsHint.
  ///
  /// In en, this message translates to:
  /// **'Search study materials'**
  String get searchMaterialsHint;

  /// No description provided for @allSubjects.
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get allSubjects;

  /// No description provided for @allMaterialTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get allMaterialTypes;

  /// No description provided for @allLanguages.
  ///
  /// In en, this message translates to:
  /// **'All languages'**
  String get allLanguages;

  /// No description provided for @materialTypePdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get materialTypePdf;

  /// No description provided for @materialTypeSlides.
  ///
  /// In en, this message translates to:
  /// **'Slides'**
  String get materialTypeSlides;

  /// No description provided for @materialTypeNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get materialTypeNotes;

  /// No description provided for @materialTypeDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get materialTypeDocument;

  /// No description provided for @materialTypeLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get materialTypeLink;

  /// No description provided for @materialTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get materialTypeOther;

  /// No description provided for @loadingMaterials.
  ///
  /// In en, this message translates to:
  /// **'Loading study materials'**
  String get loadingMaterials;

  /// No description provided for @searchingMaterials.
  ///
  /// In en, this message translates to:
  /// **'Searching study materials'**
  String get searchingMaterials;

  /// No description provided for @materialsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Study materials could not be loaded'**
  String get materialsLoadErrorTitle;

  /// No description provided for @noMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'No study materials yet'**
  String get noMaterialsTitle;

  /// No description provided for @noMaterialsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another subject, type, language, or search term.'**
  String get noMaterialsMessage;

  /// No description provided for @materialDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Study material'**
  String get materialDetailTitle;

  /// No description provided for @materialSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get materialSource;

  /// No description provided for @externalResource.
  ///
  /// In en, this message translates to:
  /// **'External resource'**
  String get externalResource;

  /// No description provided for @uploadedFile.
  ///
  /// In en, this message translates to:
  /// **'Uploaded file'**
  String get uploadedFile;

  /// No description provided for @fileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This file is not available in the prototype yet.'**
  String get fileUnavailable;

  /// No description provided for @fileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'File: {name}'**
  String fileNameLabel(Object name);

  /// No description provided for @fileSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size: {size}'**
  String fileSizeLabel(Object size);

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language: {language}'**
  String languageLabel(Object language);

  /// No description provided for @openMaterialSemantics.
  ///
  /// In en, this message translates to:
  /// **'Open study material {title}'**
  String openMaterialSemantics(Object title);

  /// No description provided for @contributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contribute Questions'**
  String get contributionTitle;

  /// No description provided for @contributionCreateSet.
  ///
  /// In en, this message translates to:
  /// **'Create Question Set'**
  String get contributionCreateSet;

  /// No description provided for @contributionIntroHeading.
  ///
  /// In en, this message translates to:
  /// **'Share a useful question set'**
  String get contributionIntroHeading;

  /// No description provided for @contributionIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Prepare questions and answers on this device, then submit the complete set for review.'**
  String get contributionIntroBody;

  /// No description provided for @contributionReviewGuideline.
  ///
  /// In en, this message translates to:
  /// **'Every submission is reviewed before learners can see it.'**
  String get contributionReviewGuideline;

  /// No description provided for @contributionSafetyGuideline.
  ///
  /// In en, this message translates to:
  /// **'Correct answers remain protected in learner mode.'**
  String get contributionSafetyGuideline;

  /// No description provided for @contributionLocalGuideline.
  ///
  /// In en, this message translates to:
  /// **'Account ownership and draft sync are not available yet.'**
  String get contributionLocalGuideline;

  /// No description provided for @contributionDetails.
  ///
  /// In en, this message translates to:
  /// **'Question Set Details'**
  String get contributionDetails;

  /// No description provided for @contributionDetailsIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose where this set belongs and give learners a clear title.'**
  String get contributionDetailsIntro;

  /// No description provided for @contributionSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get contributionSubject;

  /// No description provided for @contributionTopicOptional.
  ///
  /// In en, this message translates to:
  /// **'Topic (optional)'**
  String get contributionTopicOptional;

  /// No description provided for @contributionSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get contributionSetTitle;

  /// No description provided for @contributionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get contributionDescription;

  /// No description provided for @contributionQuestionBuilder.
  ///
  /// In en, this message translates to:
  /// **'Question Builder'**
  String get contributionQuestionBuilder;

  /// No description provided for @contributionAddQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add Question'**
  String get contributionAddQuestion;

  /// No description provided for @contributionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get contributionQuestion;

  /// No description provided for @contributionQuestionText.
  ///
  /// In en, this message translates to:
  /// **'Question text'**
  String get contributionQuestionText;

  /// No description provided for @contributionExplanationOptional.
  ///
  /// In en, this message translates to:
  /// **'Explanation (optional)'**
  String get contributionExplanationOptional;

  /// No description provided for @contributionAnswerOptions.
  ///
  /// In en, this message translates to:
  /// **'Answer Options'**
  String get contributionAnswerOptions;

  /// No description provided for @contributionAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get contributionAnswer;

  /// No description provided for @contributionAddAnswer.
  ///
  /// In en, this message translates to:
  /// **'Add Answer'**
  String get contributionAddAnswer;

  /// No description provided for @contributionCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct Answer'**
  String get contributionCorrectAnswer;

  /// No description provided for @contributionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get contributionRemove;

  /// No description provided for @contributionRemoveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove question'**
  String get contributionRemoveQuestion;

  /// No description provided for @contributionRemoveQuestionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this question and its answers?'**
  String get contributionRemoveQuestionConfirm;

  /// No description provided for @contributionRemoveAnswer.
  ///
  /// In en, this message translates to:
  /// **'Remove answer'**
  String get contributionRemoveAnswer;

  /// No description provided for @contributionRemoveAnswerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this answer option?'**
  String get contributionRemoveAnswerConfirm;

  /// No description provided for @contributionQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String contributionQuestionCount(Object count);

  /// No description provided for @contributionReviewSubmission.
  ///
  /// In en, this message translates to:
  /// **'Review Submission'**
  String get contributionReviewSubmission;

  /// No description provided for @contributionSubmitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get contributionSubmitForReview;

  /// No description provided for @contributionSubmitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Submit this question set for moderation? You cannot edit it after submission.'**
  String get contributionSubmitConfirm;

  /// No description provided for @contributionPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get contributionPendingReview;

  /// No description provided for @contributionPendingBody.
  ///
  /// In en, this message translates to:
  /// **'This question set is not public. It must be reviewed before learners can find it.'**
  String get contributionPendingBody;

  /// No description provided for @contributionSubmissionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Submission Successful'**
  String get contributionSubmissionSuccessful;

  /// No description provided for @contributionSubmissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed. Your draft is still here; try again.'**
  String get contributionSubmissionFailed;

  /// No description provided for @contributionUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard unsaved changes?'**
  String get contributionUnsavedTitle;

  /// No description provided for @contributionUnsavedBody.
  ///
  /// In en, this message translates to:
  /// **'This local draft will be lost.'**
  String get contributionUnsavedBody;

  /// No description provided for @contributionDiscardDraft.
  ///
  /// In en, this message translates to:
  /// **'Discard Draft'**
  String get contributionDiscardDraft;

  /// No description provided for @contributionContinueEditing.
  ///
  /// In en, this message translates to:
  /// **'Continue Editing'**
  String get contributionContinueEditing;

  /// No description provided for @contributionValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get contributionValidationRequired;

  /// No description provided for @contributionValidationAddQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add at least one question.'**
  String get contributionValidationAddQuestion;

  /// No description provided for @contributionValidationQuestionText.
  ///
  /// In en, this message translates to:
  /// **'Question text is required.'**
  String get contributionValidationQuestionText;

  /// No description provided for @contributionValidationAddAnswers.
  ///
  /// In en, this message translates to:
  /// **'Add at least two answers.'**
  String get contributionValidationAddAnswers;

  /// No description provided for @contributionValidationCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Choose exactly one correct answer.'**
  String get contributionValidationCorrectAnswer;

  /// No description provided for @contributionValidationUniqueAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answers must be unique.'**
  String get contributionValidationUniqueAnswers;

  /// No description provided for @contributionValidationTooLong.
  ///
  /// In en, this message translates to:
  /// **'This text is too long.'**
  String get contributionValidationTooLong;

  /// No description provided for @contributionValidationMaxQuestions.
  ///
  /// In en, this message translates to:
  /// **'A question set can contain up to 50 questions.'**
  String get contributionValidationMaxQuestions;

  /// No description provided for @contributionValidationMaxAnswers.
  ///
  /// In en, this message translates to:
  /// **'A question can contain up to 8 answers.'**
  String get contributionValidationMaxAnswers;

  /// No description provided for @contributionValidationSubjectUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The selected subject is unavailable.'**
  String get contributionValidationSubjectUnavailable;

  /// No description provided for @contributionCreateQuickly.
  ///
  /// In en, this message translates to:
  /// **'Create exam quickly'**
  String get contributionCreateQuickly;

  /// No description provided for @contributionPasteFullExam.
  ///
  /// In en, this message translates to:
  /// **'Paste full exam'**
  String get contributionPasteFullExam;

  /// No description provided for @contributionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get contributionContinue;

  /// No description provided for @contributionAddNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add next question'**
  String get contributionAddNextQuestion;

  /// No description provided for @contributionReviewAndFinish.
  ///
  /// In en, this message translates to:
  /// **'Review and finish'**
  String get contributionReviewAndFinish;

  /// No description provided for @contributionDuplicateQuestion.
  ///
  /// In en, this message translates to:
  /// **'Duplicate question'**
  String get contributionDuplicateQuestion;

  /// No description provided for @contributionResetDraft.
  ///
  /// In en, this message translates to:
  /// **'Reset draft'**
  String get contributionResetDraft;

  /// No description provided for @contributionResetDraftConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear the title, description, and questions? Your selected subject and topic will be kept.'**
  String get contributionResetDraftConfirm;

  /// No description provided for @contributionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get contributionReset;

  /// No description provided for @contributionReplaceQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current questions?'**
  String get contributionReplaceQuestionsTitle;

  /// No description provided for @contributionReplaceQuestionsBody.
  ///
  /// In en, this message translates to:
  /// **'Importing a pasted exam will replace the questions currently in this draft.'**
  String get contributionReplaceQuestionsBody;

  /// No description provided for @contributionReplaceQuestions.
  ///
  /// In en, this message translates to:
  /// **'Replace questions'**
  String get contributionReplaceQuestions;

  /// No description provided for @pasteExamTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste full exam'**
  String get pasteExamTitle;

  /// No description provided for @pasteExamIntro.
  ///
  /// In en, this message translates to:
  /// **'Paste the complete exam using /question, /answer1, /correct, and optional /explanation tags. Review every recognized question before importing.'**
  String get pasteExamIntro;

  /// No description provided for @pasteExamInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Structured exam text'**
  String get pasteExamInputLabel;

  /// No description provided for @copyFormatTemplate.
  ///
  /// In en, this message translates to:
  /// **'Copy format template'**
  String get copyFormatTemplate;

  /// No description provided for @formatTemplateCopied.
  ///
  /// In en, this message translates to:
  /// **'Format template copied.'**
  String get formatTemplateCopied;

  /// No description provided for @parseExamPreview.
  ///
  /// In en, this message translates to:
  /// **'Check and preview'**
  String get parseExamPreview;

  /// No description provided for @pasteExamPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognition summary'**
  String get pasteExamPreviewTitle;

  /// No description provided for @recognizedQuestions.
  ///
  /// In en, this message translates to:
  /// **'{count} recognized'**
  String recognizedQuestions(Object count);

  /// No description provided for @validQuestions.
  ///
  /// In en, this message translates to:
  /// **'{count} valid'**
  String validQuestions(Object count);

  /// No description provided for @invalidQuestions.
  ///
  /// In en, this message translates to:
  /// **'{count} invalid'**
  String invalidQuestions(Object count);

  /// No description provided for @pasteExamFixErrors.
  ///
  /// In en, this message translates to:
  /// **'Fix the marked errors in the pasted text, then check it again. Nothing has been imported yet.'**
  String get pasteExamFixErrors;

  /// No description provided for @pasteExamUseQuestions.
  ///
  /// In en, this message translates to:
  /// **'Edit recognized questions'**
  String get pasteExamUseQuestions;

  /// No description provided for @pasteExamQuestionAtLine.
  ///
  /// In en, this message translates to:
  /// **'Question {questionNumber} · line {lineNumber}'**
  String pasteExamQuestionAtLine(Object lineNumber, Object questionNumber);

  /// No description provided for @pasteExamIgnoredText.
  ///
  /// In en, this message translates to:
  /// **'Text at line {lineNumber} was ignored because it is outside a recognized field.'**
  String pasteExamIgnoredText(Object lineNumber);

  /// No description provided for @pasteExamUnknownTag.
  ///
  /// In en, this message translates to:
  /// **'Unknown tag {tag} at line {lineNumber} was ignored.'**
  String pasteExamUnknownTag(Object lineNumber, Object tag);

  /// No description provided for @pasteExamAliasUsed.
  ///
  /// In en, this message translates to:
  /// **'Compatibility alias {tag} was accepted at line {lineNumber}; use the canonical format when possible.'**
  String pasteExamAliasUsed(Object lineNumber, Object tag);

  /// No description provided for @pasteExamDuplicateTag.
  ///
  /// In en, this message translates to:
  /// **'Duplicate tag {tag} at line {lineNumber}.'**
  String pasteExamDuplicateTag(Object lineNumber, Object tag);

  /// No description provided for @pasteExamMissingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question text is missing.'**
  String get pasteExamMissingQuestion;

  /// No description provided for @pasteExamMissingAnswers.
  ///
  /// In en, this message translates to:
  /// **'At least two answers are required.'**
  String get pasteExamMissingAnswers;

  /// No description provided for @pasteExamMissingCorrect.
  ///
  /// In en, this message translates to:
  /// **'The /correct tag is missing.'**
  String get pasteExamMissingCorrect;

  /// No description provided for @pasteExamInvalidCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct-answer index {value} does not match an answer.'**
  String pasteExamInvalidCorrect(Object value);

  /// No description provided for @pasteExamDuplicateAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answer text must be unique within a question.'**
  String get pasteExamDuplicateAnswers;

  /// No description provided for @pasteExamContentTooLong.
  ///
  /// In en, this message translates to:
  /// **'Question, answer, or explanation content exceeds the allowed length.'**
  String get pasteExamContentTooLong;

  /// No description provided for @pasteExamTooManyQuestions.
  ///
  /// In en, this message translates to:
  /// **'A pasted exam can contain at most {max} questions.'**
  String pasteExamTooManyQuestions(Object max);

  /// No description provided for @pasteExamFixInSource.
  ///
  /// In en, this message translates to:
  /// **'Fix this question in the source'**
  String get pasteExamFixInSource;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @attemptHistory.
  ///
  /// In en, this message translates to:
  /// **'Attempt history'**
  String get attemptHistory;

  /// No description provided for @attemptHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Reopen completed exams and review trusted results.'**
  String get attemptHistoryDescription;

  /// No description provided for @noAttemptsYet.
  ///
  /// In en, this message translates to:
  /// **'No attempts yet'**
  String get noAttemptsYet;

  /// No description provided for @tryYourFirstExam.
  ///
  /// In en, this message translates to:
  /// **'Complete your first Exam Mode session to build history.'**
  String get tryYourFirstExam;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @viewResult.
  ///
  /// In en, this message translates to:
  /// **'View result'**
  String get viewResult;

  /// No description provided for @unableToSaveResult.
  ///
  /// In en, this message translates to:
  /// **'Unable to save result'**
  String get unableToSaveResult;

  /// No description provided for @retrySave.
  ///
  /// In en, this message translates to:
  /// **'Retry save'**
  String get retrySave;

  /// No description provided for @unableToLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Unable to load attempt history'**
  String get unableToLoadHistory;

  /// No description provided for @resultSaved.
  ///
  /// In en, this message translates to:
  /// **'Result saved'**
  String get resultSaved;

  /// No description provided for @resultNotYetSaved.
  ///
  /// In en, this message translates to:
  /// **'Result not yet saved'**
  String get resultNotYetSaved;

  /// No description provided for @savingResult.
  ///
  /// In en, this message translates to:
  /// **'Saving result...'**
  String get savingResult;

  /// No description provided for @attemptCorrectSummary.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String attemptCorrectSummary(Object correct, Object total);

  /// No description provided for @attemptHistoryLocalIdentity.
  ///
  /// In en, this message translates to:
  /// **'Your history is securely linked to your signed-in account.'**
  String get attemptHistoryLocalIdentity;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New to StudyHub?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Continue your learning journey'**
  String get authWelcome;

  /// No description provided for @authWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep attempts, saved sets, and contributions under your account.'**
  String get authWelcomeBody;

  /// No description provided for @authOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get authOrContinueWith;

  /// No description provided for @googleSignInComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in - coming soon'**
  String get googleSignInComingSoon;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get authInvalidCredentials;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authInvalidEmail;

  /// No description provided for @authPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must contain between 8 and 128 characters.'**
  String get authPasswordLength;

  /// No description provided for @authRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete this request. Try again.'**
  String get authRequestFailed;

  /// No description provided for @authSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get authSessionExpired;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @editDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Edit display name'**
  String get editDisplayName;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy and security'**
  String get privacySecurity;

  /// No description provided for @privacySecurityNote.
  ///
  /// In en, this message translates to:
  /// **'StudyHub keeps credentials out of the app and verifies ownership on the backend.'**
  String get privacySecurityNote;

  /// No description provided for @savedQuestionSets.
  ///
  /// In en, this message translates to:
  /// **'Saved question sets'**
  String get savedQuestionSets;

  /// No description provided for @saveForLater.
  ///
  /// In en, this message translates to:
  /// **'Save for later'**
  String get saveForLater;

  /// No description provided for @removeFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeFromSaved;

  /// No description provided for @savedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved question sets yet.'**
  String get savedEmpty;

  /// No description provided for @savedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save a useful question set from its detail page to find it here.'**
  String get savedEmptyBody;

  /// No description provided for @savedAdded.
  ///
  /// In en, this message translates to:
  /// **'Saved for later.'**
  String get savedAdded;

  /// No description provided for @savedRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved.'**
  String get savedRemoved;

  /// No description provided for @myContributions.
  ///
  /// In en, this message translates to:
  /// **'My contributions'**
  String get myContributions;

  /// No description provided for @contributionDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get contributionDraft;

  /// No description provided for @contributionApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get contributionApproved;

  /// No description provided for @contributionRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get contributionRejected;

  /// No description provided for @contributionStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get contributionStatus;

  /// No description provided for @contributionRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Review note'**
  String get contributionRejectionReason;

  /// No description provided for @contributionNoItems.
  ///
  /// In en, this message translates to:
  /// **'No contributions yet.'**
  String get contributionNoItems;

  /// No description provided for @contributionCreateDraft.
  ///
  /// In en, this message translates to:
  /// **'Create a draft'**
  String get contributionCreateDraft;

  /// No description provided for @contributionSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get contributionSaveDraft;

  /// No description provided for @contributionDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved.'**
  String get contributionDraftSaved;

  /// No description provided for @contributionEditDraft.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get contributionEditDraft;

  /// No description provided for @contributionDeleteDraft.
  ///
  /// In en, this message translates to:
  /// **'Delete draft'**
  String get contributionDeleteDraft;

  /// No description provided for @contributionDeleteDraftConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this draft permanently?'**
  String get contributionDeleteDraftConfirm;

  /// No description provided for @contributionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted.'**
  String get contributionDeleted;

  /// No description provided for @completedAttempts.
  ///
  /// In en, this message translates to:
  /// **'Completed attempts'**
  String get completedAttempts;

  /// No description provided for @submittedQuestionSets.
  ///
  /// In en, this message translates to:
  /// **'Submitted question sets'**
  String get submittedQuestionSets;

  /// No description provided for @aboutStudyHubBody.
  ///
  /// In en, this message translates to:
  /// **'A mobile learning platform for structured study, safe quizzes, and community-created content.'**
  String get aboutStudyHubBody;

  /// No description provided for @accountActive.
  ///
  /// In en, this message translates to:
  /// **'Active account'**
  String get accountActive;

  /// No description provided for @accountOverview.
  ///
  /// In en, this message translates to:
  /// **'Account overview'**
  String get accountOverview;

  /// No description provided for @yourLearning.
  ///
  /// In en, this message translates to:
  /// **'Your learning'**
  String get yourLearning;

  /// No description provided for @profileStatsError.
  ///
  /// In en, this message translates to:
  /// **'Account activity could not be loaded'**
  String get profileStatsError;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Your display name could not be updated. Try again.'**
  String get profileUpdateFailed;

  /// No description provided for @confirmLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out of StudyHub?'**
  String get confirmLogOut;

  /// No description provided for @confirmLogOutBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access account-owned learning data.'**
  String get confirmLogOutBody;

  /// No description provided for @socialSignIn.
  ///
  /// In en, this message translates to:
  /// **'Social sign-in'**
  String get socialSignIn;

  /// No description provided for @socialSignInUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Provider setup and secure backend verification are still required.'**
  String get socialSignInUnavailable;

  /// No description provided for @savedLoadError.
  ///
  /// In en, this message translates to:
  /// **'Saved question sets could not be loaded'**
  String get savedLoadError;

  /// No description provided for @savedActionError.
  ///
  /// In en, this message translates to:
  /// **'The saved item could not be updated. Try again.'**
  String get savedActionError;

  /// No description provided for @savedOpenError.
  ///
  /// In en, this message translates to:
  /// **'This saved question set could not be opened.'**
  String get savedOpenError;

  /// No description provided for @checkConnectionBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get checkConnectionBody;

  /// No description provided for @contributionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Contributions could not be loaded'**
  String get contributionLoadError;

  /// No description provided for @contributionEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a draft when you are ready to share a useful question set.'**
  String get contributionEmptyBody;

  /// No description provided for @contributionActionError.
  ///
  /// In en, this message translates to:
  /// **'The contribution could not be updated. Your existing content is safe.'**
  String get contributionActionError;

  /// No description provided for @openDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get openDetails;

  /// No description provided for @studyReminders.
  ///
  /// In en, this message translates to:
  /// **'Study reminders'**
  String get studyReminders;

  /// No description provided for @enableReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable daily reminder'**
  String get enableReminders;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification permission'**
  String get notificationPermission;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied. Open system settings to allow reminders.'**
  String get permissionDenied;

  /// No description provided for @permissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Blocked in system settings.'**
  String get permissionPermanentlyDenied;

  /// No description provided for @permissionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this platform.'**
  String get permissionUnavailable;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @studyReminderReason.
  ///
  /// In en, this message translates to:
  /// **'A quiet daily reminder helps you return to your planned study time.'**
  String get studyReminderReason;

  /// No description provided for @studyReminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to study'**
  String get studyReminderNotificationTitle;

  /// No description provided for @studyReminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Continue learning with StudyHub.'**
  String get studyReminderNotificationBody;

  /// No description provided for @notificationScheduleFailed.
  ///
  /// In en, this message translates to:
  /// **'The reminder could not be scheduled. Try again.'**
  String get notificationScheduleFailed;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get testNotification;

  /// No description provided for @chooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get chooseImage;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// No description provided for @replaceImage.
  ///
  /// In en, this message translates to:
  /// **'Replace image'**
  String get replaceImage;

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image...'**
  String get uploadingImage;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed. Your text is still safe.'**
  String get imageUploadFailed;

  /// No description provided for @unsupportedFile.
  ///
  /// In en, this message translates to:
  /// **'Only JPEG, PNG, and WebP images are supported.'**
  String get unsupportedFile;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image must be 5 MiB or smaller.'**
  String get fileTooLarge;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @imagePreview.
  ///
  /// In en, this message translates to:
  /// **'Image preview'**
  String get imagePreview;

  /// No description provided for @questionImageOptional.
  ///
  /// In en, this message translates to:
  /// **'Question image (optional)'**
  String get questionImageOptional;

  /// No description provided for @explanationImageOptional.
  ///
  /// In en, this message translates to:
  /// **'Explanation image (optional)'**
  String get explanationImageOptional;

  /// No description provided for @continueStudying.
  ///
  /// In en, this message translates to:
  /// **'Continue studying'**
  String get continueStudying;

  /// No description provided for @advertisement.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get advertisement;

  /// No description provided for @advertising.
  ///
  /// In en, this message translates to:
  /// **'Advertising'**
  String get advertising;

  /// No description provided for @advertisingStatus.
  ///
  /// In en, this message translates to:
  /// **'Advertising status'**
  String get advertisingStatus;

  /// No description provided for @adsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Ads enabled'**
  String get adsEnabled;

  /// No description provided for @adsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Ads disabled'**
  String get adsDisabled;

  /// No description provided for @adsWaitingForConsent.
  ///
  /// In en, this message translates to:
  /// **'Ads unavailable until consent requirements are resolved'**
  String get adsWaitingForConsent;

  /// No description provided for @sessionAdFree.
  ///
  /// In en, this message translates to:
  /// **'Ads disabled for this session'**
  String get sessionAdFree;

  /// No description provided for @testAdvertisingMode.
  ///
  /// In en, this message translates to:
  /// **'Test advertising mode'**
  String get testAdvertisingMode;

  /// No description provided for @testAdvertisingModeBody.
  ///
  /// In en, this message translates to:
  /// **'Only provider test ads are requested in this build.'**
  String get testAdvertisingModeBody;

  /// No description provided for @adPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get adPrivacy;

  /// No description provided for @adPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'StudyHub requests non-personalized ads. Production consent configuration is still required where applicable.'**
  String get adPrivacyBody;

  /// No description provided for @removeAdsForSession.
  ///
  /// In en, this message translates to:
  /// **'Remove ads for this session'**
  String get removeAdsForSession;

  /// No description provided for @removeAdsForSessionBody.
  ///
  /// In en, this message translates to:
  /// **'Optionally watch one ad. Learning content stays available without it.'**
  String get removeAdsForSessionBody;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad'**
  String get watchAd;

  /// No description provided for @adUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ad unavailable. Continue without ad.'**
  String get adUnavailable;

  /// No description provided for @continueWithoutAd.
  ///
  /// In en, this message translates to:
  /// **'Continue without ad'**
  String get continueWithoutAd;

  /// No description provided for @rewardReceived.
  ///
  /// In en, this message translates to:
  /// **'Reward received. Ads are off for this session.'**
  String get rewardReceived;

  /// No description provided for @unableToLoadAdvertisement.
  ///
  /// In en, this message translates to:
  /// **'Unable to load advertisement'**
  String get unableToLoadAdvertisement;
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
