// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get progressCompletedSessions => 'Phiên đã hoàn thành';

  @override
  String get progressAverageAccuracy => 'Độ chính xác trung bình';

  @override
  String get progressCompletedQuestionSets => 'Bộ câu hỏi đã làm';

  @override
  String get progressLatestActivity => 'Hoạt động gần nhất';

  @override
  String get progressRecentResults => 'Kết quả gần đây';

  @override
  String get progressNoHistoryTitle => 'Chưa có tiến độ';

  @override
  String get progressNoHistoryBody =>
      'Hoàn thành một phiên Kiểm tra hoặc Luyện tập để tạo lịch sử học trên thiết bị này.';

  @override
  String get progressExamSession => 'Kiểm tra';

  @override
  String get progressPracticeSession => 'Luyện tập';

  @override
  String progressScoreSummary(Object correct, Object total) {
    return 'Đúng $correct/$total câu';
  }

  @override
  String get progressClearHistory => 'Xóa lịch sử';

  @override
  String get progressClearHistoryTitle => 'Xóa lịch sử trên thiết bị?';

  @override
  String get progressClearHistoryBody =>
      'Thao tác này xóa các phiên đã hoàn thành trên thiết bị và không thể hoàn tác.';

  @override
  String get progressCancel => 'Hủy';

  @override
  String get progressConfirmClear => 'Xóa';

  @override
  String get progressHistoryCleared => 'Đã xóa lịch sử tiến độ.';

  @override
  String get progressHistoryClearError => 'Không thể xóa lịch sử tiến độ.';

  @override
  String get progressLoadError => 'Không thể tải tiến độ.';

  @override
  String get progressSaveError =>
      'Kết quả vẫn an toàn nhưng không thể lưu tiến độ trên thiết bị.';

  @override
  String get progressLocalOnlyNote => 'Chỉ lưu trên thiết bị này';

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
  String examAnswerStatus(Object answered, Object unanswered) {
    return 'Đã trả lời $answered · Chưa trả lời $unanswered';
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
  String get submitExamTitle => 'Nộp bài kiểm tra?';

  @override
  String submitWithUnanswered(Object count) {
    return 'Còn $count câu chưa trả lời. Vẫn nộp bài?';
  }

  @override
  String get submitAnyway => 'Vẫn nộp bài';

  @override
  String get leaveExamTitle => 'Rời bài kiểm tra?';

  @override
  String get discardExamProgressMessage => 'Các đáp án bạn đã chọn sẽ bị hủy.';

  @override
  String get keepLearning => 'Tiếp tục làm bài';

  @override
  String get discardProgress => 'Hủy tiến trình';

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
  String get unansweredAnswers => 'Chưa trả lời';

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
  String get unanswered => 'Chưa trả lời';

  @override
  String get yourChoice => 'Đáp án của bạn';

  @override
  String get correctChoice => 'Đáp án đúng';

  @override
  String get explanation => 'Giải thích';

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

  @override
  String get homeGreeting => 'Sẵn sàng học chưa?';

  @override
  String get homeSupportingLine =>
      'Chọn điểm đến và bắt đầu buổi học hiệu quả.';

  @override
  String get featuredSection => 'Nổi bật';

  @override
  String get featuredModesTitle => 'Hai cách học';

  @override
  String get featuredModesBody =>
      'Tự kiểm tra với Chế độ kiểm tra hoặc nhận phản hồi ngay khi ôn tập.';

  @override
  String get featuredModesAction => 'Khám phá chế độ';

  @override
  String get featuredSetsTitle => 'Tìm bộ câu hỏi tiếp theo';

  @override
  String get featuredSetsBody =>
      'Duyệt theo môn, tìm theo tên và lọc theo chủ đề.';

  @override
  String get featuredSetsAction => 'Xem bộ câu hỏi';

  @override
  String get featuredProgressTitle => 'Xem lại tiến độ';

  @override
  String get featuredProgressBody =>
      'Các phiên Kiểm tra và Luyện tập đã hoàn thành được lưu trên thiết bị này.';

  @override
  String get featuredProgressAction => 'Xem Tiến độ';

  @override
  String bannerPageSemantics(Object current, Object total) {
    return 'Nội dung nổi bật $current/$total';
  }

  @override
  String get quickActionsSection => 'Thao tác nhanh';

  @override
  String get browseSubjects => 'Khám phá môn học';

  @override
  String get continueLearningSection => 'Bắt đầu buổi học';

  @override
  String get continueLearningBody =>
      'Chọn môn học rồi tiếp tục với một bộ câu hỏi tập trung.';

  @override
  String get learningModesCompactSubtitle =>
      'Chọn chế độ sau khi mở một bộ câu hỏi.';

  @override
  String get examModeCompactBody => 'Nộp bài cuối buổi rồi xem lại.';

  @override
  String get practiceModeCompactBody => 'Kiểm tra từng câu rồi xem tổng kết.';

  @override
  String get exploreSection => 'Khám phá thêm';

  @override
  String get comingSoon => 'Sắp ra mắt';

  @override
  String get studyMaterials => 'Tài liệu học tập';

  @override
  String get savedContent => 'Nội dung đã lưu';

  @override
  String get learningPlans => 'Kế hoạch học tập';

  @override
  String upcomingFeatureSemantics(Object feature) {
    return '$feature, sắp ra mắt';
  }

  @override
  String get progressOverview => 'Tổng quan học tập';

  @override
  String get progressOverviewSubtitle =>
      'Dữ liệu làm bài thật sẽ xuất hiện khi tính năng lưu tiến độ hoàn tất.';

  @override
  String get noDataYet => 'Chưa có dữ liệu';

  @override
  String get recentResults => 'Kết quả gần đây';

  @override
  String get accuracy => 'Độ chính xác';

  @override
  String get completedSets => 'Bộ đã hoàn thành';

  @override
  String get learningActivity => 'Hoạt động học tập';

  @override
  String get progressStartTitle => 'Tạo dấu mốc học tập đầu tiên';

  @override
  String get progressStartBody =>
      'Bạn có thể học ngay; lịch sử đã lưu sẽ được bổ sung ở cột mốc sau.';

  @override
  String get futurePreferences => 'Tùy chọn tương lai';

  @override
  String get appearance => 'Giao diện';

  @override
  String get notifications => 'Thông báo';

  @override
  String get futurePreferenceDescription => 'Sẽ có ở cột mốc sau';

  @override
  String get studyMaterialsTitle => 'Tài liệu học tập';

  @override
  String get studyMaterialsSubtitle =>
      'Khám phá tài nguyên học tập đáng tin cậy theo môn và định dạng.';

  @override
  String get searchMaterialsHint => 'Tìm tài liệu học tập';

  @override
  String get allSubjects => 'Tất cả môn học';

  @override
  String get allMaterialTypes => 'Tất cả định dạng';

  @override
  String get allLanguages => 'Tất cả ngôn ngữ';

  @override
  String get materialTypePdf => 'PDF';

  @override
  String get materialTypeSlides => 'Bài trình chiếu';

  @override
  String get materialTypeNotes => 'Ghi chú';

  @override
  String get materialTypeDocument => 'Tài liệu';

  @override
  String get materialTypeLink => 'Liên kết';

  @override
  String get materialTypeOther => 'Khác';

  @override
  String get loadingMaterials => 'Đang tải tài liệu học tập';

  @override
  String get searchingMaterials => 'Đang tìm tài liệu học tập';

  @override
  String get materialsLoadErrorTitle => 'Không thể tải tài liệu học tập';

  @override
  String get noMaterialsTitle => 'Chưa có tài liệu học tập';

  @override
  String get noMaterialsMessage =>
      'Hãy thử môn học, định dạng, ngôn ngữ hoặc từ khóa khác.';

  @override
  String get materialDetailTitle => 'Tài liệu học tập';

  @override
  String get materialSource => 'Nguồn';

  @override
  String get externalResource => 'Tài nguyên bên ngoài';

  @override
  String get uploadedFile => 'Tệp đã tải lên';

  @override
  String get fileUnavailable => 'Tệp này chưa khả dụng trong bản thử nghiệm.';

  @override
  String fileNameLabel(Object name) {
    return 'Tệp: $name';
  }

  @override
  String fileSizeLabel(Object size) {
    return 'Dung lượng: $size';
  }

  @override
  String languageLabel(Object language) {
    return 'Ngôn ngữ: $language';
  }

  @override
  String openMaterialSemantics(Object title) {
    return 'Mở tài liệu $title';
  }

  @override
  String get contributionTitle => 'Tạo bộ câu hỏi';

  @override
  String get contributionCreateSet => 'Tạo bộ câu hỏi';

  @override
  String get contributionIntroHeading => 'Chia sẻ bộ câu hỏi hữu ích';

  @override
  String get contributionIntroBody =>
      'Soạn câu hỏi và đáp án trên thiết bị, sau đó gửi bộ hoàn chỉnh để duyệt.';

  @override
  String get contributionReviewGuideline =>
      'Mọi nội dung đều được duyệt trước khi người học nhìn thấy.';

  @override
  String get contributionSafetyGuideline =>
      'Đáp án đúng vẫn được bảo vệ trong chế độ học.';

  @override
  String get contributionLocalGuideline =>
      'Chưa có tài khoản sở hữu hoặc đồng bộ bản nháp.';

  @override
  String get contributionDetails => 'Thông tin bộ câu hỏi';

  @override
  String get contributionDetailsIntro =>
      'Chọn nơi phù hợp và đặt tiêu đề rõ ràng cho người học.';

  @override
  String get contributionSubject => 'Môn học';

  @override
  String get contributionTopicOptional => 'Chủ đề (không bắt buộc)';

  @override
  String get contributionSetTitle => 'Tiêu đề';

  @override
  String get contributionDescription => 'Mô tả';

  @override
  String get contributionQuestionBuilder => 'Soạn câu hỏi';

  @override
  String get contributionAddQuestion => 'Thêm câu hỏi';

  @override
  String get contributionQuestion => 'Câu hỏi';

  @override
  String get contributionQuestionText => 'Nội dung câu hỏi';

  @override
  String get contributionExplanationOptional => 'Giải thích (không bắt buộc)';

  @override
  String get contributionAnswerOptions => 'Các đáp án';

  @override
  String get contributionAnswer => 'Đáp án';

  @override
  String get contributionAddAnswer => 'Thêm đáp án';

  @override
  String get contributionCorrectAnswer => 'Đáp án đúng';

  @override
  String get contributionRemove => 'Xóa';

  @override
  String get contributionRemoveQuestion => 'Xóa câu hỏi';

  @override
  String get contributionRemoveQuestionConfirm =>
      'Xóa câu hỏi này cùng các đáp án?';

  @override
  String get contributionRemoveAnswer => 'Xóa đáp án';

  @override
  String get contributionRemoveAnswerConfirm => 'Xóa lựa chọn đáp án này?';

  @override
  String contributionQuestionCount(Object count) {
    return '$count câu hỏi';
  }

  @override
  String get contributionReviewSubmission => 'Xem lại nội dung';

  @override
  String get contributionSubmitForReview => 'Gửi để duyệt';

  @override
  String get contributionSubmitConfirm =>
      'Gửi bộ câu hỏi này để kiểm duyệt? Bạn không thể sửa sau khi gửi.';

  @override
  String get contributionPendingReview => 'Đang chờ duyệt';

  @override
  String get contributionPendingBody =>
      'Bộ câu hỏi chưa được công khai. Nội dung phải được duyệt trước khi người học có thể tìm thấy.';

  @override
  String get contributionSubmissionSuccessful => 'Gửi thành công';

  @override
  String get contributionSubmissionFailed =>
      'Gửi thất bại. Bản nháp vẫn còn; hãy thử lại.';

  @override
  String get contributionUnsavedTitle => 'Bỏ thay đổi chưa lưu?';

  @override
  String get contributionUnsavedBody => 'Bản nháp cục bộ này sẽ bị mất.';

  @override
  String get contributionDiscardDraft => 'Bỏ bản nháp';

  @override
  String get contributionContinueEditing => 'Tiếp tục chỉnh sửa';

  @override
  String get contributionValidationRequired => 'Vui lòng nhập trường này.';

  @override
  String get contributionValidationAddQuestion =>
      'Hãy thêm ít nhất một câu hỏi.';

  @override
  String get contributionValidationQuestionText =>
      'Vui lòng nhập nội dung câu hỏi.';

  @override
  String get contributionValidationAddAnswers => 'Hãy thêm ít nhất hai đáp án.';

  @override
  String get contributionValidationCorrectAnswer =>
      'Hãy chọn đúng một đáp án đúng.';

  @override
  String get contributionValidationUniqueAnswers =>
      'Các đáp án không được trùng nhau.';

  @override
  String get contributionValidationTooLong => 'Nội dung này quá dài.';

  @override
  String get contributionValidationMaxQuestions =>
      'Một bộ có tối đa 50 câu hỏi.';

  @override
  String get contributionValidationMaxAnswers =>
      'Một câu hỏi có tối đa 8 đáp án.';

  @override
  String get contributionValidationSubjectUnavailable =>
      'Môn học đã chọn không còn khả dụng.';

  @override
  String get contributionCreateQuickly => 'Tạo đề nhanh';

  @override
  String get contributionPasteFullExam => 'Dán toàn bộ đề';

  @override
  String get contributionContinue => 'Tiếp tục';

  @override
  String get contributionAddNextQuestion => 'Thêm câu tiếp theo';

  @override
  String get contributionReviewAndFinish => 'Xem lại và hoàn tất';

  @override
  String get contributionDuplicateQuestion => 'Nhân bản câu hỏi';

  @override
  String get contributionResetDraft => 'Đặt lại bản nháp';

  @override
  String get contributionResetDraftConfirm =>
      'Xóa tiêu đề, mô tả và các câu hỏi? Môn học và chủ đề đã chọn sẽ được giữ lại.';

  @override
  String get contributionReset => 'Đặt lại';

  @override
  String get contributionReplaceQuestionsTitle => 'Thay các câu hỏi hiện tại?';

  @override
  String get contributionReplaceQuestionsBody =>
      'Nhập đề đã dán sẽ thay thế các câu hỏi đang có trong bản nháp này.';

  @override
  String get contributionReplaceQuestions => 'Thay câu hỏi';

  @override
  String get pasteExamTitle => 'Dán toàn bộ đề';

  @override
  String get pasteExamIntro =>
      'Dán toàn bộ đề bằng các thẻ /question, /answer1, /correct và /explanation không bắt buộc. Hãy xem lại mọi câu được nhận diện trước khi nhập.';

  @override
  String get pasteExamInputLabel => 'Nội dung đề có cấu trúc';

  @override
  String get copyFormatTemplate => 'Sao chép mẫu định dạng';

  @override
  String get formatTemplateCopied => 'Đã sao chép mẫu định dạng.';

  @override
  String get parseExamPreview => 'Kiểm tra và xem trước';

  @override
  String get pasteExamPreviewTitle => 'Tóm tắt nhận diện';

  @override
  String recognizedQuestions(Object count) {
    return 'Nhận diện $count câu';
  }

  @override
  String validQuestions(Object count) {
    return '$count câu hợp lệ';
  }

  @override
  String invalidQuestions(Object count) {
    return '$count câu chưa hợp lệ';
  }

  @override
  String get pasteExamFixErrors =>
      'Sửa các lỗi được đánh dấu trong nội dung đã dán rồi kiểm tra lại. Chưa có câu hỏi nào được nhập.';

  @override
  String get pasteExamUseQuestions => 'Chỉnh sửa các câu đã nhận diện';

  @override
  String pasteExamQuestionAtLine(Object lineNumber, Object questionNumber) {
    return 'Câu $questionNumber · dòng $lineNumber';
  }

  @override
  String pasteExamIgnoredText(Object lineNumber) {
    return 'Nội dung ở dòng $lineNumber bị bỏ qua vì nằm ngoài trường được nhận diện.';
  }

  @override
  String pasteExamUnknownTag(Object lineNumber, Object tag) {
    return 'Thẻ không xác định $tag ở dòng $lineNumber đã bị bỏ qua.';
  }

  @override
  String pasteExamAliasUsed(Object lineNumber, Object tag) {
    return 'Bí danh tương thích $tag được chấp nhận ở dòng $lineNumber; nên dùng định dạng chuẩn khi có thể.';
  }

  @override
  String pasteExamDuplicateTag(Object lineNumber, Object tag) {
    return 'Thẻ $tag bị lặp ở dòng $lineNumber.';
  }

  @override
  String get pasteExamMissingQuestion => 'Thiếu nội dung câu hỏi.';

  @override
  String get pasteExamMissingAnswers => 'Cần ít nhất hai đáp án.';

  @override
  String get pasteExamMissingCorrect => 'Thiếu thẻ /correct.';

  @override
  String pasteExamInvalidCorrect(Object value) {
    return 'Chỉ số đáp án đúng $value không khớp với đáp án nào.';
  }

  @override
  String get pasteExamDuplicateAnswers =>
      'Nội dung đáp án trong một câu không được trùng nhau.';

  @override
  String get pasteExamContentTooLong =>
      'Nội dung câu hỏi, đáp án hoặc giải thích vượt quá độ dài cho phép.';

  @override
  String pasteExamTooManyQuestions(Object max) {
    return 'Một đề được dán có tối đa $max câu hỏi.';
  }

  @override
  String get pasteExamFixInSource => 'Sửa câu này trong nội dung nguồn';

  @override
  String get history => 'Lịch sử';

  @override
  String get attemptHistory => 'Lịch sử làm đề';

  @override
  String get attemptHistoryDescription =>
      'Mở lại các bài thi đã hoàn thành và xem kết quả đáng tin cậy.';

  @override
  String get noAttemptsYet => 'Chưa có lượt làm đề';

  @override
  String get tryYourFirstExam =>
      'Hoàn thành bài đầu tiên ở Chế độ thi để tạo lịch sử.';

  @override
  String get completed => 'Đã hoàn thành';

  @override
  String get score => 'Điểm';

  @override
  String get viewResult => 'Xem kết quả';

  @override
  String get unableToSaveResult => 'Không thể lưu kết quả';

  @override
  String get retrySave => 'Thử lưu lại';

  @override
  String get unableToLoadHistory => 'Không thể tải lịch sử làm đề';

  @override
  String get resultSaved => 'Đã lưu kết quả';

  @override
  String get resultNotYetSaved => 'Kết quả chưa được lưu';

  @override
  String get savingResult => 'Đang lưu kết quả...';

  @override
  String attemptCorrectSummary(Object correct, Object total) {
    return 'Đúng $correct/$total câu';
  }

  @override
  String get attemptHistoryLocalIdentity =>
      'Lịch sử hiện thuộc về danh tính demo tạm thời trên backend. Tài khoản thật sẽ thay thế ranh giới này khi thêm xác thực.';
}
