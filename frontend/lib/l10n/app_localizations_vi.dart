// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'StudyHub';

  @override
  String get homeTab => 'Trang chủ';

  @override
  String get learnTab => 'Học tập';

  @override
  String get progressTab => 'Tiến độ';

  @override
  String get settingsTab => 'Cài đặt';

  @override
  String get startLearning => 'Bắt đầu học';

  @override
  String get homeHeadline => 'Học tập trung. Ôn tập tự tin.';

  @override
  String get homeSubtitle =>
      'Chọn môn học, ôn tập với phản hồi đáng tin cậy hoặc tự kiểm tra kiến thức.';

  @override
  String get answersHiddenNote =>
      'Đáp án được ẩn cho đến khi bạn nộp bài hoặc kiểm tra.';

  @override
  String get learningModes => 'Chế độ học';

  @override
  String get learningModesSubtitle => 'Chọn cách học phù hợp cho từng buổi.';

  @override
  String get examMode => 'Chế độ kiểm tra';

  @override
  String get practiceMode => 'Chế độ ôn tập';

  @override
  String get safeReview => 'Xem lại an toàn';

  @override
  String get examModePreview =>
      'Làm hết câu hỏi, sau đó nộp bài để xem điểm và đáp án.';

  @override
  String get practiceModePreview =>
      'Kiểm tra từng câu và học ngay từ phản hồi đáng tin cậy.';

  @override
  String get safeReviewPreview =>
      'Đáp án đúng chỉ hiện sau khi nộp bài hoặc kiểm tra câu trả lời.';

  @override
  String get howItWorks => 'Cách học';

  @override
  String get howItWorksSubtitle =>
      'Từ chọn môn học đến xem lại kết quả một cách tập trung.';

  @override
  String get pickSubjectStep => 'Chọn môn học';

  @override
  String get chooseQuestionSetStep => 'Chọn bộ câu hỏi';

  @override
  String get learnOrExamStep => 'Ôn tập hoặc làm bài kiểm tra';

  @override
  String get reviewResultsStep => 'Xem lại kết quả';

  @override
  String get browseSubjectsTitle => 'Danh sách môn học';

  @override
  String get chooseSubjectTitle => 'Chọn môn học';

  @override
  String get chooseSubjectSubtitle =>
      'Chọn một môn để tìm bộ câu hỏi cho buổi học tiếp theo.';

  @override
  String get loadingSubjects => 'Đang tải môn học';

  @override
  String get subjectsLoadErrorTitle => 'Không thể tải môn học';

  @override
  String get connectionRetryMessage => 'Kiểm tra kết nối rồi thử lại.';

  @override
  String get tryAgain => 'Thử lại';

  @override
  String get noSubjectsTitle => 'Chưa có môn học';

  @override
  String get noSubjectsMessage =>
      'Môn học sẽ xuất hiện khi có nội dung phù hợp.';

  @override
  String openSubjectSemantics(Object subjectName) {
    return 'Mở môn $subjectName';
  }

  @override
  String schoolMetadata(Object value) {
    return 'Trường: $value';
  }

  @override
  String programMetadata(Object value) {
    return 'Chương trình: $value';
  }

  @override
  String majorMetadata(Object value) {
    return 'Ngành: $value';
  }

  @override
  String get questionSetsTitle => 'Bộ câu hỏi';

  @override
  String get chooseQuestionSetSubtitle =>
      'Chọn một bộ câu hỏi để xem thông tin chi tiết.';

  @override
  String get searchQuestionSetsHint => 'Tìm theo tên bộ câu hỏi';

  @override
  String get clearSearchTooltip => 'Xóa nội dung tìm kiếm';

  @override
  String get allTopics => 'Tất cả chủ đề';

  @override
  String get topicsLabel => 'Chủ đề';

  @override
  String get loadingQuestionSets => 'Đang tải bộ câu hỏi';

  @override
  String get searchingQuestionSets => 'Đang tìm bộ câu hỏi';

  @override
  String get questionSetsLoadErrorTitle => 'Không thể tải bộ câu hỏi';

  @override
  String get searchLoadErrorTitle => 'Không thể hoàn tất tìm kiếm';

  @override
  String get noQuestionSetsTitle => 'Chưa có bộ câu hỏi';

  @override
  String noQuestionSetsMessage(Object subjectName) {
    return 'Môn $subjectName chưa có bộ câu hỏi.';
  }

  @override
  String get noSearchResultsTitle => 'Không tìm thấy bộ câu hỏi phù hợp';

  @override
  String get noSearchResultsMessage =>
      'Thử tên ngắn hơn hoặc xóa nội dung tìm kiếm.';

  @override
  String get clearSearch => 'Xóa tìm kiếm';

  @override
  String get loadMore => 'Xem thêm';

  @override
  String get loadingMore => 'Đang tải thêm...';

  @override
  String get loadMoreError => 'Không thể tải thêm bộ câu hỏi.';

  @override
  String get retryLoadMore => 'Thử lại';

  @override
  String questionCount(Object count) {
    return '$count câu hỏi';
  }

  @override
  String minuteCount(Object count) {
    return '$count phút';
  }

  @override
  String get difficultyEasy => 'Dễ';

  @override
  String get difficultyMedium => 'Trung bình';

  @override
  String get difficultyHard => 'Khó';

  @override
  String openQuestionSetSemantics(Object title) {
    return 'Mở bộ câu hỏi $title';
  }

  @override
  String get questionSetTitle => 'Bộ câu hỏi';

  @override
  String get aboutQuestionSet => 'Giới thiệu bộ câu hỏi';

  @override
  String get answersHiddenDetail =>
      'Đáp án đúng được ẩn cho đến khi bạn nộp bài hoặc kiểm tra câu trả lời.';

  @override
  String get chooseLearningMode => 'Chọn chế độ học';

  @override
  String get modeSelectionTitle => 'Chế độ học';

  @override
  String get modeSelectionHeading => 'Bạn muốn học theo cách nào?';

  @override
  String get modeSelectionSubtitle => 'Chọn cách học phù hợp với buổi học này.';

  @override
  String get examModeDescription =>
      'Làm tất cả câu hỏi, không xem đúng sai ngay, rồi nộp bài và xem lại.';

  @override
  String get practiceModeDescription =>
      'Kiểm tra từng câu ngay, học từ phản hồi và nhận tổng kết cuối buổi.';

  @override
  String get startExamMode => 'Bắt đầu kiểm tra';

  @override
  String get startPracticeMode => 'Bắt đầu ôn tập';

  @override
  String get loadingQuestions => 'Đang tải câu hỏi';

  @override
  String get questionsLoadErrorTitle => 'Không thể tải câu hỏi';

  @override
  String get noQuestionsTitle => 'Chưa có câu hỏi';

  @override
  String get noQuestionsMessage => 'Bộ câu hỏi này chưa sẵn sàng để làm bài.';

  @override
  String questionProgress(Object current, Object total) {
    return 'Câu $current/$total';
  }

  @override
  String answeredCount(Object count) {
    return 'Đã trả lời $count';
  }

  @override
  String get instantFeedback => 'Phản hồi ngay';

  @override
  String get previous => 'Câu trước';

  @override
  String get nextQuestion => 'Câu tiếp theo';

  @override
  String get submitQuiz => 'Nộp bài';

  @override
  String get submitting => 'Đang nộp bài...';

  @override
  String get finishPractice => 'Hoàn thành ôn tập';

  @override
  String get checkingAnswer => 'Đang kiểm tra...';

  @override
  String get answerCheckError => 'Không thể kiểm tra câu trả lời.';

  @override
  String get correct => 'Chính xác';

  @override
  String get incorrect => 'Chưa chính xác';

  @override
  String yourAnswer(Object answer) {
    return 'Bạn chọn: $answer';
  }

  @override
  String correctAnswer(Object answer) {
    return 'Đáp án đúng: $answer';
  }

  @override
  String get chooseOneAnswer => 'Hãy chọn một đáp án.';

  @override
  String get answerEveryQuestion =>
      'Hãy trả lời tất cả câu hỏi trước khi nộp bài.';

  @override
  String get quizSubmitError => 'Không thể nộp bài.';

  @override
  String get examResult => 'Kết quả kiểm tra';

  @override
  String get practiceResult => 'Kết quả ôn tập';

  @override
  String get strongResultMessage => 'Kết quả rất tốt. Hãy tiếp tục phát huy.';

  @override
  String get goodResultMessage =>
      'Bạn đang tiến bộ. Hãy xem lại các câu chưa đúng.';

  @override
  String get learningResultMessage =>
      'Mỗi lần xem lại đều giúp bạn hiểu sâu hơn. Hãy thử lại khi sẵn sàng.';

  @override
  String get correctAnswers => 'Số câu đúng';

  @override
  String get wrongAnswers => 'Số câu sai';

  @override
  String get totalQuestions => 'Tổng số câu';

  @override
  String get answerReview => 'Xem lại đáp án';

  @override
  String questionNumber(Object number) {
    return 'Câu $number';
  }

  @override
  String get notAnswered => 'Chưa trả lời';

  @override
  String get backToQuestionSet => 'Quay lại bộ câu hỏi';

  @override
  String get progressPlannedTitle =>
      'Tính năng theo dõi tiến độ đang được phát triển';

  @override
  String get progressPlannedMessage =>
      'Lịch sử học và các buổi đã hoàn thành sẽ xuất hiện sau khi có lưu trữ tiến độ an toàn.';

  @override
  String get languageSection => 'Ngôn ngữ';

  @override
  String get systemDefault => 'Theo hệ thống';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String selectedLanguageSemantics(Object language) {
    return 'Ngôn ngữ đang chọn: $language';
  }

  @override
  String get aboutStudyHub => 'Giới thiệu StudyHub';

  @override
  String get settingsIntro =>
      'Chọn ngôn ngữ giao diện. Các tùy chọn khác chỉ xuất hiện khi hoạt động thật.';

  @override
  String get mobileLearningPlatform => 'Nền tảng học tập trên di động';

  @override
  String get mobileLearningPlatformDescription =>
      'Duyệt bộ câu hỏi, ôn tập, làm bài kiểm tra và xem lại kết quả.';

  @override
  String get learningSafety => 'An toàn khi học';

  @override
  String get learningSafetyDescription =>
      'Đáp án đúng được ẩn cho đến khi nộp bài hoặc kiểm tra câu trả lời.';

  @override
  String get dataSafety => 'An toàn dữ liệu ứng dụng';

  @override
  String get dataSafetyDescription =>
      'Không đưa khóa bí mật hoặc thông tin riêng tư vào ứng dụng.';

  @override
  String get activeDevelopment => 'Đang phát triển';

  @override
  String get activeDevelopmentDescription =>
      'StudyHub phát triển qua từng cột mốc học tập nhỏ và có kiểm thử.';
}
