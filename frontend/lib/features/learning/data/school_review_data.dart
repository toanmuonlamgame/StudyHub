import '../models/answer_option.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/topic.dart';

const schoolReviewSubjectId = 'subject_school_review';

const schoolReviewTopics = [
  Topic(id: 'review_math', subjectId: schoolReviewSubjectId, name: 'Toán'),
  Topic(
    id: 'review_english',
    subjectId: schoolReviewSubjectId,
    name: 'Tiếng Anh',
  ),
  Topic(
    id: 'review_science',
    subjectId: schoolReviewSubjectId,
    name: 'Khoa học',
  ),
];

typedef ReviewItem = ({
  String prompt,
  List<String> choices,
  int correct,
  String explanation,
});

class _ReviewSet {
  const _ReviewSet(
    this.id,
    this.topicId,
    this.title,
    this.description,
    this.items,
  );

  final String id;
  final String topicId;
  final String title;
  final String description;
  final List<ReviewItem> items;

  QuestionSet get metadata => QuestionSet(
    id: id,
    subjectId: schoolReviewSubjectId,
    topicId: topicId,
    language: 'vi',
    title: title,
    description: description,
    questionCount: items.length,
    estimatedMinutes: 7,
    difficulty: 'easy',
  );

  Iterable<Question> get questions sync* {
    for (final (index, item) in items.indexed) {
      final questionId = '${id}_${index + 1}';
      yield Question(
        id: questionId,
        questionSetId: id,
        text: item.prompt,
        answerOptions: [
          for (final (choiceIndex, choice) in item.choices.indexed)
            AnswerOption(id: '${questionId}_$choiceIndex', text: choice),
        ],
      );
    }
  }
}

const _sets = [
  _ReviewSet(
    'school_review_math',
    'review_math',
    'Toán nhanh: Phân số và phần trăm',
    'Ôn cách tính phân số, giảm giá và tỉ lệ qua các tình huống hằng ngày.',
    [
      (
        prompt:
            'Một cuốn vở giá 40.000 đồng, giảm 25%. Giá sau giảm là bao nhiêu?',
        choices: ['10.000 đồng', '25.000 đồng', '30.000 đồng', '35.000 đồng'],
        correct: 2,
        explanation:
            '25% của 40.000 đồng là 10.000 đồng. Lấy 40.000 trừ 10.000 được 30.000 đồng.',
      ),
      (
        prompt: 'Tổng của 1/3 và 1/6 bằng bao nhiêu?',
        choices: ['2/9', '1/2', '1/9', '2/6'],
        correct: 1,
        explanation: 'Đổi 1/3 thành 2/6 rồi cộng 1/6, được 3/6 = 1/2.',
      ),
      (
        prompt:
            'Lớp có 30 bạn, trong đó 12 bạn đi xe đạp. Tỉ lệ đi xe đạp là bao nhiêu?',
        choices: ['25%', '30%', '36%', '40%'],
        correct: 3,
        explanation: 'Chia 12 cho 30 được 0,4. Đổi sang phần trăm được 40%.',
      ),
      (
        prompt:
            'Bạn đọc 3/5 của một cuốn sách có 100 trang. Bạn đã đọc bao nhiêu trang?',
        choices: ['60 trang', '35 trang', '40 trang', '80 trang'],
        correct: 0,
        explanation:
            'Một phần năm của 100 trang là 20 trang. Ba phần năm là 60 trang.',
      ),
      (
        prompt: 'Số nào lớn nhất?',
        choices: ['45%', '0,6', '2/3', '1/2'],
        correct: 2,
        explanation: '2/3 xấp xỉ 0,667, lớn hơn 0,6, 0,5 và 0,45.',
      ),
    ],
  ),
  _ReviewSet(
    'school_review_english',
    'review_english',
    'Tiếng Anh: Một ngày đi học',
    'Luyện từ vựng quen thuộc và cách dùng thì hiện tại đơn.',
    [
      (
        prompt: 'Chọn từ đúng: “She ___ to school by bus every day.”',
        choices: ['go', 'goes', 'going', 'gone'],
        correct: 1,
        explanation:
            'Với “she” ở thì hiện tại đơn, động từ “go” đổi thành “goes”.',
      ),
      (
        prompt: 'Từ nào chỉ thư viện?',
        choices: ['Cafeteria', 'Playground', 'Classroom', 'Library'],
        correct: 3,
        explanation: '“Library” là thư viện, nơi đọc hoặc mượn sách.',
      ),
      (
        prompt: 'Chọn giới từ đúng: “Class starts ___ seven o’clock.”',
        choices: ['at', 'in', 'on', 'under'],
        correct: 0,
        explanation: 'Dùng “at” với một giờ cụ thể.',
      ),
      (
        prompt: 'Câu nào hỏi về môn học yêu thích?',
        choices: [
          'Where is your classroom?',
          'How do you get to school?',
          'What is your favorite subject?',
          'When do you study?',
        ],
        correct: 2,
        explanation: '“Favorite subject” nghĩa là môn học yêu thích.',
      ),
      (
        prompt: 'Chọn câu phủ định đúng.',
        choices: [
          'He don’t like math.',
          'He doesn’t like math.',
          'He doesn’t likes math.',
          'He not likes math.',
        ],
        correct: 1,
        explanation: 'Sau “doesn’t”, dùng động từ nguyên mẫu “like”.',
      ),
    ],
  ),
  _ReviewSet(
    'school_review_science',
    'review_science',
    'Khoa học: Trái Đất và môi trường',
    'Tìm hiểu vòng tuần hoàn của nước, cây xanh và thói quen bảo vệ môi trường.',
    [
      (
        prompt:
            'Nước trên mặt hồ chuyển thành hơi dưới nắng. Đó là quá trình nào?',
        choices: ['Đông đặc', 'Ngưng tụ', 'Bay hơi', 'Nóng chảy'],
        correct: 2,
        explanation:
            'Bay hơi là quá trình chất lỏng chuyển thành hơi từ bề mặt.',
      ),
      (
        prompt: 'Khí nào được cây xanh sử dụng khi quang hợp?',
        choices: ['Oxy', 'Cacbon đioxit', 'Heli', 'Nitơ'],
        correct: 1,
        explanation:
            'Cây dùng cacbon đioxit và nước, nhờ năng lượng ánh sáng, để tạo chất hữu cơ.',
      ),
      (
        prompt: 'Vì sao một nơi trên Trái Đất có ngày và đêm luân phiên?',
        choices: [
          'Mặt Trăng che Mặt Trời mỗi tối',
          'Mặt Trời tắt vào ban đêm',
          'Trái Đất đổi kích thước',
          'Trái Đất tự quay quanh trục',
        ],
        correct: 3,
        explanation:
            'Khi Trái Đất quay, nơi đó lần lượt hướng về và quay khỏi phía Mặt Trời.',
      ),
      (
        prompt: 'Thói quen nào giúp giảm chai nhựa dùng một lần?',
        choices: [
          'Dùng bình nước cá nhân nhiều lần',
          'Mỗi ngày mua một chai mới',
          'Bỏ chai vào rác hữu cơ',
          'Đốt chai nhựa tại nhà',
        ],
        correct: 0,
        explanation:
            'Dùng bình nhiều lần giúp giảm số chai nhựa mới cần sử dụng.',
      ),
      (
        prompt: 'Hiện tượng nào là ví dụ của ngưng tụ?',
        choices: [
          'Đá tan trong cốc',
          'Nước trong ấm sôi',
          'Giọt nước xuất hiện ngoài cốc lạnh',
          'Vũng nước cạn dần',
        ],
        correct: 2,
        explanation:
            'Hơi nước gặp thành cốc lạnh và chuyển thành giọt nước lỏng.',
      ),
    ],
  ),
];

final schoolReviewSets = [for (final set in _sets) set.metadata];
final schoolReviewQuestions = [for (final set in _sets) ...set.questions];
final schoolReviewAnswers = {
  for (final set in _sets)
    for (final (index, item) in set.items.indexed)
      '${set.id}_${index + 1}': (
        optionId: '${set.id}_${index + 1}_${item.correct}',
        explanation: item.explanation,
      ),
};
