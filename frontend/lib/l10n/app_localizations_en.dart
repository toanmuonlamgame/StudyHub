// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get progressCompletedSessions => 'Completed sessions';

  @override
  String get progressAverageAccuracy => 'Average accuracy';

  @override
  String get progressCompletedQuestionSets => 'Completed sets';

  @override
  String get progressLatestActivity => 'Latest activity';

  @override
  String get progressRecentResults => 'Recent results';

  @override
  String get progressNoHistoryTitle => 'No progress yet';

  @override
  String get progressNoHistoryBody =>
      'Complete an Exam or Practice session to build your local learning history.';

  @override
  String get progressExamSession => 'Exam';

  @override
  String get progressPracticeSession => 'Practice';

  @override
  String progressScoreSummary(Object correct, Object total) {
    return '$correct of $total correct';
  }

  @override
  String get progressClearHistory => 'Clear history';

  @override
  String get progressClearHistoryTitle => 'Clear local history?';

  @override
  String get progressClearHistoryBody =>
      'This removes completed sessions stored on this device. It cannot be undone.';

  @override
  String get progressCancel => 'Cancel';

  @override
  String get progressConfirmClear => 'Clear';

  @override
  String get progressHistoryCleared => 'Progress history cleared.';

  @override
  String get progressHistoryClearError =>
      'Progress history could not be cleared.';

  @override
  String get progressLoadError => 'Progress could not be loaded.';

  @override
  String get progressSaveError =>
      'Your result is safe, but local progress could not be saved.';

  @override
  String get progressLocalOnlyNote => 'Saved on this device only';

  @override
  String get appTitle => 'StudyHub';

  @override
  String get homeTab => 'Home';

  @override
  String get learnTab => 'Learn';

  @override
  String get progressTab => 'Progress';

  @override
  String get settingsTab => 'Settings';

  @override
  String get startLearning => 'Start learning';

  @override
  String get homeHeadline => 'Learn with focus. Review with confidence.';

  @override
  String get homeSubtitle =>
      'Choose a subject, practise with trusted feedback, or test yourself in Exam Mode.';

  @override
  String get answersHiddenNote =>
      'Answers stay hidden until you submit or check.';

  @override
  String get learningModes => 'Learning modes';

  @override
  String get learningModesSubtitle =>
      'Choose the right mode for each study session.';

  @override
  String get examMode => 'Exam Mode';

  @override
  String get practiceMode => 'Practice Mode';

  @override
  String get safeReview => 'Safe Review';

  @override
  String get examModePreview =>
      'Answer the full set, then submit for your score and review.';

  @override
  String get practiceModePreview =>
      'Check each answer and learn from immediate trusted feedback.';

  @override
  String get safeReviewPreview =>
      'Correct answers appear only after submit or check answer.';

  @override
  String get howItWorks => 'How it works';

  @override
  String get howItWorksSubtitle =>
      'Move from a subject to a focused result review.';

  @override
  String get pickSubjectStep => 'Pick a subject';

  @override
  String get chooseQuestionSetStep => 'Choose a question set';

  @override
  String get learnOrExamStep => 'Practise or take an exam';

  @override
  String get reviewResultsStep => 'Review your results';

  @override
  String get browseSubjectsTitle => 'Browse subjects';

  @override
  String get chooseSubjectTitle => 'Choose a subject';

  @override
  String get chooseSubjectSubtitle =>
      'Start with a subject to find question sets for your next study session.';

  @override
  String get loadingSubjects => 'Loading subjects';

  @override
  String get subjectsLoadErrorTitle => 'Subjects could not be loaded';

  @override
  String get connectionRetryMessage => 'Check your connection and try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get noSubjectsTitle => 'No subjects yet';

  @override
  String get noSubjectsMessage =>
      'Subjects will appear here when learning content is available.';

  @override
  String openSubjectSemantics(Object subjectName) {
    return 'Open $subjectName';
  }

  @override
  String schoolMetadata(Object value) {
    return 'School: $value';
  }

  @override
  String programMetadata(Object value) {
    return 'Program: $value';
  }

  @override
  String majorMetadata(Object value) {
    return 'Major: $value';
  }

  @override
  String get questionSetsTitle => 'Question sets';

  @override
  String get chooseQuestionSetSubtitle =>
      'Choose a question set to review its details.';

  @override
  String get searchQuestionSetsHint => 'Search question-set titles';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String get allTopics => 'All topics';

  @override
  String get topicsLabel => 'Topics';

  @override
  String get loadingQuestionSets => 'Loading question sets';

  @override
  String get searchingQuestionSets => 'Searching question sets';

  @override
  String get questionSetsLoadErrorTitle => 'Question sets could not be loaded';

  @override
  String get searchLoadErrorTitle => 'Search could not be completed';

  @override
  String get noQuestionSetsTitle => 'No question sets yet';

  @override
  String noQuestionSetsMessage(Object subjectName) {
    return 'There are no question sets for $subjectName yet.';
  }

  @override
  String get noSearchResultsTitle => 'No matching question sets';

  @override
  String get noSearchResultsMessage =>
      'Try a shorter title or clear the search.';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get loadMore => 'Load more';

  @override
  String get loadingMore => 'Loading more...';

  @override
  String get loadMoreError => 'More question sets could not be loaded.';

  @override
  String get retryLoadMore => 'Retry';

  @override
  String questionCount(Object count) {
    return '$count questions';
  }

  @override
  String minuteCount(Object count) {
    return '$count min';
  }

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String openQuestionSetSemantics(Object title) {
    return 'Open $title';
  }

  @override
  String get questionSetTitle => 'Question set';

  @override
  String get aboutQuestionSet => 'About this question set';

  @override
  String get answersHiddenDetail =>
      'Correct answers stay hidden until you submit or check an answer.';

  @override
  String get chooseLearningMode => 'Choose learning mode';

  @override
  String get modeSelectionTitle => 'Learning mode';

  @override
  String get modeSelectionHeading => 'How do you want to learn?';

  @override
  String get modeSelectionSubtitle =>
      'Choose the experience that fits this study session.';

  @override
  String get examModeDescription =>
      'Answer every question without feedback, then submit and review at the end.';

  @override
  String get practiceModeDescription =>
      'Check each answer immediately, learn from feedback, and finish with a summary.';

  @override
  String get startExamMode => 'Start Exam Mode';

  @override
  String get startPracticeMode => 'Start Practice Mode';

  @override
  String get loadingQuestions => 'Loading questions';

  @override
  String get questionsLoadErrorTitle => 'Questions could not be loaded';

  @override
  String get noQuestionsTitle => 'No questions yet';

  @override
  String get noQuestionsMessage =>
      'This question set is not ready for a quiz session.';

  @override
  String questionProgress(Object current, Object total) {
    return 'Question $current of $total';
  }

  @override
  String answeredCount(Object count) {
    return '$count answered';
  }

  @override
  String get instantFeedback => 'Instant feedback';

  @override
  String get previous => 'Previous';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get submitQuiz => 'Submit Quiz';

  @override
  String get submitting => 'Submitting...';

  @override
  String get finishPractice => 'Finish Practice';

  @override
  String get checkingAnswer => 'Checking answer...';

  @override
  String get answerCheckError => 'Answer could not be checked.';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String yourAnswer(Object answer) {
    return 'Your answer: $answer';
  }

  @override
  String correctAnswer(Object answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get chooseOneAnswer => 'Choose one answer.';

  @override
  String get answerEveryQuestion => 'Answer every question before submitting.';

  @override
  String get quizSubmitError => 'Quiz could not be submitted.';

  @override
  String get examResult => 'Exam Result';

  @override
  String get practiceResult => 'Practice Result';

  @override
  String get strongResultMessage => 'Strong result. Keep the momentum going.';

  @override
  String get goodResultMessage =>
      'Good progress. Review the missed answers below.';

  @override
  String get learningResultMessage =>
      'Every review builds understanding. Try the set again when ready.';

  @override
  String get correctAnswers => 'Correct answers';

  @override
  String get wrongAnswers => 'Wrong answers';

  @override
  String get totalQuestions => 'Total questions';

  @override
  String get answerReview => 'Answer review';

  @override
  String questionNumber(Object number) {
    return 'Question $number';
  }

  @override
  String get notAnswered => 'Not answered';

  @override
  String get backToQuestionSet => 'Back to Question Set';

  @override
  String get progressPlannedTitle => 'Progress tracking is planned';

  @override
  String get progressPlannedMessage =>
      'Completed sessions and learning history will appear here after secure progress storage is implemented.';

  @override
  String get languageSection => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String selectedLanguageSemantics(Object language) {
    return 'Selected language: $language';
  }

  @override
  String get aboutStudyHub => 'About StudyHub';

  @override
  String get settingsIntro =>
      'Choose your interface language. More preferences will appear only when they are functional.';

  @override
  String get mobileLearningPlatform => 'Mobile learning platform';

  @override
  String get mobileLearningPlatformDescription =>
      'Browse question sets, practise, take exams, and review results.';

  @override
  String get learningSafety => 'Learning safety';

  @override
  String get learningSafetyDescription =>
      'Correct answers stay hidden until submit or check answer.';

  @override
  String get dataSafety => 'App data safety';

  @override
  String get dataSafetyDescription =>
      'Secrets and private keys do not belong in the app.';

  @override
  String get activeDevelopment => 'Active development';

  @override
  String get activeDevelopmentDescription =>
      'StudyHub is growing through small, tested learning milestones.';

  @override
  String get homeGreeting => 'Ready to learn?';

  @override
  String get homeSupportingLine =>
      'Choose a destination and make this session count.';

  @override
  String get featuredSection => 'Featured';

  @override
  String get featuredModesTitle => 'Two ways to learn';

  @override
  String get featuredModesBody =>
      'Use Exam Mode to test yourself or Practice Mode for instant feedback.';

  @override
  String get featuredModesAction => 'Explore modes';

  @override
  String get featuredSetsTitle => 'Find your next question set';

  @override
  String get featuredSetsBody =>
      'Browse by subject, search titles, and filter by topic.';

  @override
  String get featuredSetsAction => 'Browse sets';

  @override
  String get featuredProgressTitle => 'Review your progress';

  @override
  String get featuredProgressBody =>
      'Completed Exam and Practice sessions are saved on this device.';

  @override
  String get featuredProgressAction => 'View Progress';

  @override
  String bannerPageSemantics(Object current, Object total) {
    return 'Featured item $current of $total';
  }

  @override
  String get quickActionsSection => 'Quick actions';

  @override
  String get browseSubjects => 'Browse subjects';

  @override
  String get continueLearningSection => 'Start a learning session';

  @override
  String get continueLearningBody =>
      'Pick a subject and continue to a focused question set.';

  @override
  String get learningModesCompactSubtitle =>
      'Choose the mode after opening a question set.';

  @override
  String get examModeCompactBody => 'Submit at the end, then review.';

  @override
  String get practiceModeCompactBody =>
      'Check answers now, then see a summary.';

  @override
  String get exploreSection => 'Explore more';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get studyMaterials => 'Study Materials';

  @override
  String get savedContent => 'Saved Content';

  @override
  String get learningPlans => 'Learning Plans';

  @override
  String upcomingFeatureSemantics(Object feature) {
    return '$feature, coming soon';
  }

  @override
  String get progressOverview => 'Your learning overview';

  @override
  String get progressOverviewSubtitle =>
      'Real attempt data will appear here when progress storage is ready.';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get recentResults => 'Recent Results';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get completedSets => 'Completed Sets';

  @override
  String get learningActivity => 'Learning Activity';

  @override
  String get progressStartTitle => 'Build your first learning record';

  @override
  String get progressStartBody =>
      'Learning works now; saved history will follow in a later milestone.';

  @override
  String get futurePreferences => 'Future preferences';

  @override
  String get appearance => 'Appearance';

  @override
  String get notifications => 'Notifications';

  @override
  String get futurePreferenceDescription => 'Available in a later milestone';

  @override
  String get studyMaterialsTitle => 'Study Materials';

  @override
  String get studyMaterialsSubtitle =>
      'Browse trusted learning resources by subject and format.';

  @override
  String get searchMaterialsHint => 'Search study materials';

  @override
  String get allSubjects => 'All subjects';

  @override
  String get allMaterialTypes => 'All types';

  @override
  String get allLanguages => 'All languages';

  @override
  String get materialTypePdf => 'PDF';

  @override
  String get materialTypeSlides => 'Slides';

  @override
  String get materialTypeNotes => 'Notes';

  @override
  String get materialTypeDocument => 'Document';

  @override
  String get materialTypeLink => 'Link';

  @override
  String get materialTypeOther => 'Other';

  @override
  String get loadingMaterials => 'Loading study materials';

  @override
  String get searchingMaterials => 'Searching study materials';

  @override
  String get materialsLoadErrorTitle => 'Study materials could not be loaded';

  @override
  String get noMaterialsTitle => 'No study materials yet';

  @override
  String get noMaterialsMessage =>
      'Try another subject, type, language, or search term.';

  @override
  String get materialDetailTitle => 'Study material';

  @override
  String get materialSource => 'Source';

  @override
  String get externalResource => 'External resource';

  @override
  String get uploadedFile => 'Uploaded file';

  @override
  String get fileUnavailable =>
      'This file is not available in the prototype yet.';

  @override
  String fileNameLabel(Object name) {
    return 'File: $name';
  }

  @override
  String fileSizeLabel(Object size) {
    return 'Size: $size';
  }

  @override
  String languageLabel(Object language) {
    return 'Language: $language';
  }

  @override
  String openMaterialSemantics(Object title) {
    return 'Open study material $title';
  }

  @override
  String get contributionTitle => 'Contribute Questions';

  @override
  String get contributionCreateSet => 'Create Question Set';

  @override
  String get contributionIntroHeading => 'Share a useful question set';

  @override
  String get contributionIntroBody =>
      'Prepare questions and answers on this device, then submit the complete set for review.';

  @override
  String get contributionReviewGuideline =>
      'Every submission is reviewed before learners can see it.';

  @override
  String get contributionSafetyGuideline =>
      'Correct answers remain protected in learner mode.';

  @override
  String get contributionLocalGuideline =>
      'Account ownership and draft sync are not available yet.';

  @override
  String get contributionDetails => 'Question Set Details';

  @override
  String get contributionDetailsIntro =>
      'Choose where this set belongs and give learners a clear title.';

  @override
  String get contributionSubject => 'Subject';

  @override
  String get contributionTopicOptional => 'Topic (optional)';

  @override
  String get contributionSetTitle => 'Title';

  @override
  String get contributionDescription => 'Description';

  @override
  String get contributionQuestionBuilder => 'Question Builder';

  @override
  String get contributionAddQuestion => 'Add Question';

  @override
  String get contributionQuestion => 'Question';

  @override
  String get contributionQuestionText => 'Question text';

  @override
  String get contributionExplanationOptional => 'Explanation (optional)';

  @override
  String get contributionAnswerOptions => 'Answer Options';

  @override
  String get contributionAnswer => 'Answer';

  @override
  String get contributionAddAnswer => 'Add Answer';

  @override
  String get contributionCorrectAnswer => 'Correct Answer';

  @override
  String get contributionRemove => 'Remove';

  @override
  String get contributionRemoveQuestion => 'Remove question';

  @override
  String get contributionRemoveQuestionConfirm =>
      'Remove this question and its answers?';

  @override
  String get contributionRemoveAnswer => 'Remove answer';

  @override
  String get contributionRemoveAnswerConfirm => 'Remove this answer option?';

  @override
  String contributionQuestionCount(Object count) {
    return '$count questions';
  }

  @override
  String get contributionReviewSubmission => 'Review Submission';

  @override
  String get contributionSubmitForReview => 'Submit for Review';

  @override
  String get contributionSubmitConfirm =>
      'Submit this question set for moderation? You cannot edit it after submission.';

  @override
  String get contributionPendingReview => 'Pending Review';

  @override
  String get contributionPendingBody =>
      'This question set is not public. It must be reviewed before learners can find it.';

  @override
  String get contributionSubmissionSuccessful => 'Submission Successful';

  @override
  String get contributionSubmissionFailed =>
      'Submission failed. Your draft is still here; try again.';

  @override
  String get contributionUnsavedTitle => 'Discard unsaved changes?';

  @override
  String get contributionUnsavedBody => 'This local draft will be lost.';

  @override
  String get contributionDiscardDraft => 'Discard Draft';

  @override
  String get contributionContinueEditing => 'Continue Editing';

  @override
  String get contributionValidationRequired => 'This field is required.';

  @override
  String get contributionValidationAddQuestion => 'Add at least one question.';

  @override
  String get contributionValidationQuestionText => 'Question text is required.';

  @override
  String get contributionValidationAddAnswers => 'Add at least two answers.';

  @override
  String get contributionValidationCorrectAnswer =>
      'Choose exactly one correct answer.';

  @override
  String get contributionValidationUniqueAnswers => 'Answers must be unique.';

  @override
  String get contributionValidationTooLong => 'This text is too long.';

  @override
  String get contributionValidationMaxQuestions =>
      'A question set can contain up to 50 questions.';

  @override
  String get contributionValidationMaxAnswers =>
      'A question can contain up to 8 answers.';

  @override
  String get contributionValidationSubjectUnavailable =>
      'The selected subject is unavailable.';
}
