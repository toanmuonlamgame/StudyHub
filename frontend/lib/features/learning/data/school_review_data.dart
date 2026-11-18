import '../models/answer_option.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/subject.dart';
import '../models/topic.dart';

const schoolReviewSubjectId = 'subject_school_review';
const schoolReviewSubject = Subject(
  id: schoolReviewSubjectId,
  name: 'Ôn tập phổ thông',
  description: 'Ôn Toán, Tiếng Anh, Khoa học và kỹ năng số theo từng chủ đề.',
);

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
  Topic(
    id: 'review_digital',
    subjectId: schoolReviewSubjectId,
    name: 'Kỹ năng số',
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
  _ReviewSet(
    'school_review_equations',
    'review_math',
    'Toán: Phương trình một ẩn',
    'Giải phương trình và đặt ẩn cho bài toán có lời văn.',
    [
      (
        prompt: 'Nghiệm của 3x + 5 = 20 là gì?',
        choices: ['x = 3', 'x = 5', 'x = 8', 'x = 15'],
        correct: 1,
        explanation: 'Trừ 5 ở hai vế rồi chia hai vế cho 3, được x = 5.',
      ),
      (
        prompt: 'Nếu 2(x − 4) = 10, x bằng bao nhiêu?',
        choices: ['5', '7', '8', '9'],
        correct: 3,
        explanation: 'Chia hai vế cho 2 được x − 4 = 5, sau đó cộng 4.',
      ),
      (
        prompt: 'Nghiệm của 5x = 3x + 8 là gì?',
        choices: ['x = 4', 'x = 8', 'x = 2', 'x = −4'],
        correct: 0,
        explanation: 'Trừ 3x ở hai vế được 2x = 8, nên x = 4.',
      ),
      (
        prompt:
            'Một vé giá x nghìn đồng. Mua 3 vé hết 90 nghìn đồng. Phương trình nào đúng?',
        choices: ['x + 3 = 90', '3 + x = 30', '3x = 90', '90x = 3'],
        correct: 2,
        explanation: 'Ba vé cùng giá x nghìn đồng có tổng giá 3x nghìn đồng.',
      ),
      (
        prompt: 'Phương trình nào có nghiệm x = −2?',
        choices: ['x + 4 = 0', '2x + 4 = 0', '2x − 4 = 0', 'x − 2 = 0'],
        correct: 1,
        explanation: 'Thay −2 vào 2x + 4 được −4 + 4 = 0.',
      ),
    ],
  ),
  _ReviewSet(
    'school_review_data',
    'review_math',
    'Toán: Thống kê và xác suất',
    'Đọc dãy số, tìm trung vị và tính xác suất đơn giản.',
    [
      (
        prompt: 'Trung bình của 4, 6 và 8 là bao nhiêu?',
        choices: ['5', '6', '7', '8'],
        correct: 1,
        explanation: 'Tổng ba số là 18. Chia cho 3 được 6.',
      ),
      (
        prompt: 'Trung vị của 2, 9, 4, 7, 5 là bao nhiêu?',
        choices: ['4', '7', '5', '9'],
        correct: 2,
        explanation: 'Sắp xếp thành 2, 4, 5, 7, 9. Giá trị thứ ba là trung vị.',
      ),
      (
        prompt: 'Gieo một xúc xắc cân đối. Xác suất ra số chẵn là bao nhiêu?',
        choices: ['1/3', '1/6', '2/3', '1/2'],
        correct: 3,
        explanation:
            'Ba mặt 2, 4, 6 trong sáu mặt là số chẵn, nên xác suất bằng 3/6.',
      ),
      (
        prompt: 'Giá trị nào xuất hiện nhiều nhất trong 2, 3, 2, 5, 3, 2?',
        choices: ['2', '3', '4', '5'],
        correct: 0,
        explanation: 'Số 2 xuất hiện 3 lần, nhiều hơn các số còn lại.',
      ),
      (
        prompt: 'Biểu đồ nào thuận tiện để so sánh số học sinh của bốn lớp?',
        choices: [
          'Bản đồ địa lý',
          'Sơ đồ tuần hoàn',
          'Biểu đồ cột',
          'Ảnh chân dung',
        ],
        correct: 2,
        explanation:
            'Mỗi cột biểu diễn một lớp. Chiều cao cột giúp so sánh số lượng.',
      ),
    ],
  ),
  _ReviewSet(
    'school_review_past',
    'review_english',
    'Tiếng Anh: Kể chuyện hôm qua',
    'Luyện động từ có quy tắc, bất quy tắc và câu hỏi quá khứ đơn.',
    [
      (
        prompt: 'Điền từ: “I ___ my homework yesterday.”',
        choices: ['finish', 'finishing', 'finishes', 'finished'],
        correct: 3,
        explanation:
            '“Yesterday” chỉ thời điểm đã qua. Dạng quá khứ của “finish” là “finished”.',
      ),
      (
        prompt: 'Quá khứ của “take” là gì?',
        choices: ['taked', 'took', 'taken', 'takes'],
        correct: 1,
        explanation: '“Take” là động từ bất quy tắc. Quá khứ đơn là “took”.',
      ),
      (
        prompt: 'Hỏi về hôm qua: “Did you ___ the film?”',
        choices: ['watch', 'watched', 'watching', 'watches'],
        correct: 0,
        explanation: 'Sau “did”, dùng động từ nguyên mẫu “watch”.',
      ),
      (
        prompt: 'Chọn câu đúng.',
        choices: [
          'She didn’t went home.',
          'She doesn’t went home.',
          'She didn’t go home.',
          'She don’t go home.',
        ],
        correct: 2,
        explanation:
            'Dùng “didn’t” và động từ nguyên mẫu để phủ định ở quá khứ đơn.',
      ),
      (
        prompt: 'Cụm nào nghĩa là “hai ngày trước”?',
        choices: [
          'two days later',
          'two days ago',
          'every two days',
          'for two days',
        ],
        correct: 1,
        explanation:
            '“Ago” đứng sau khoảng thời gian để chỉ một thời điểm trong quá khứ.',
      ),
    ],
  ),
  _ReviewSet(
    'school_review_reading',
    'review_english',
    'Tiếng Anh: Đọc thông báo ngắn',
    'Tìm giờ, địa điểm và yêu cầu trong những thông báo thường gặp.',
    [
      (
        prompt:
            'Thông báo ghi: “Library closed on Mondays.” Hôm nào thư viện đóng cửa?',
        choices: ['Thứ Ba', 'Thứ Hai', 'Thứ Sáu', 'Chủ Nhật'],
        correct: 1,
        explanation: '“On Mondays” nghĩa là vào các ngày thứ Hai.',
      ),
      (
        prompt: '“Bring a notebook and a pen.” Bạn cần mang gì?',
        choices: [
          'Vở và bút',
          'Vở và thước',
          'Bút và đồng hồ',
          'Máy tính và giấy',
        ],
        correct: 0,
        explanation: '“Notebook” là vở và “pen” là bút.',
      ),
      (
        prompt: '“The club meets in Room 4 at 3 p.m.” Nhóm gặp lúc mấy giờ?',
        choices: ['4 giờ chiều', '3 giờ sáng', '3 giờ chiều', '4 giờ sáng'],
        correct: 2,
        explanation: '“At 3 p.m.” chỉ 3 giờ chiều. “Room 4” là phòng số 4.',
      ),
      (
        prompt: 'Biển “Keep off the grass” nhắc điều gì?',
        choices: [
          'Tưới cỏ sau giờ học',
          'Ngồi nghỉ trên cỏ',
          'Nhặt lá trên cỏ',
          'Không bước lên cỏ',
        ],
        correct: 3,
        explanation: '“Keep off” yêu cầu tránh bước vào một khu vực.',
      ),
      (
        prompt: '“Return books by Friday.” Hạn trả sách là khi nào?',
        choices: [
          'Muộn nhất thứ Sáu',
          'Chỉ sau thứ Sáu',
          'Sáng thứ Hai',
          'Cuối tháng',
        ],
        correct: 0,
        explanation:
            'Trong thông báo về thời hạn, “by Friday” nghĩa là chậm nhất vào thứ Sáu.',
      ),
    ],
  ),
  _ReviewSet(
    'school_review_motion',
    'review_science',
    'Khoa học: Chuyển động và năng lượng',
    'Ôn tốc độ, lực ma sát và sự chuyển hóa năng lượng.',
    [
      (
        prompt: 'Một xe đi 60 km trong 2 giờ. Tốc độ trung bình là bao nhiêu?',
        choices: ['20 km/h', '120 km/h', '30 km/h', '62 km/h'],
        correct: 2,
        explanation:
            'Tốc độ trung bình bằng tổng quãng đường chia tổng thời gian: 60 ÷ 2.',
      ),
      (
        prompt: 'Phanh xe đạp làm xe chậm lại chủ yếu nhờ lực nào?',
        choices: ['Ma sát', 'Lực từ của Trái Đất', 'Lực nổi', 'Lực điện'],
        correct: 0,
        explanation:
            'Má phanh tác dụng lực ma sát làm giảm chuyển động quay của bánh xe.',
      ),
      (
        prompt: 'Pin trong đèn pin lưu trữ năng lượng ở dạng nào?',
        choices: ['Ánh sáng', 'Âm thanh', 'Động năng', 'Hóa năng'],
        correct: 3,
        explanation:
            'Phản ứng hóa học bên trong pin tạo ra điện năng khi mạch hoạt động.',
      ),
      (
        prompt:
            'Quả bóng đang lăn trên sân có dạng năng lượng nào do chuyển động?',
        choices: [
          'Thế năng đàn hồi',
          'Động năng',
          'Hóa năng',
          'Năng lượng ánh sáng',
        ],
        correct: 1,
        explanation: 'Động năng là năng lượng mà vật có do đang chuyển động.',
      ),
      (
        prompt: 'Vì sao tay ấm khi xoa hai bàn tay vào nhau?',
        choices: [
          'Ma sát chuyển một phần cơ năng thành nhiệt',
          'Tay hấp thụ ánh sáng mạnh',
          'Không khí chuyển thành điện',
          'Tay giảm khối lượng',
        ],
        correct: 0,
        explanation:
            'Chuyển động giữa hai bề mặt da tạo ma sát và làm tăng nhiệt độ.',
      ),
    ],
  ),
  _ReviewSet(
    'school_review_biology',
    'review_science',
    'Khoa học: Cơ thể và hệ sinh thái',
    'Nhận diện cơ quan, sinh vật sản xuất và chuỗi thức ăn.',
    [
      (
        prompt: 'Cơ quan nào bơm máu đi khắp cơ thể?',
        choices: ['Phổi', 'Dạ dày', 'Thận', 'Tim'],
        correct: 3,
        explanation: 'Tim co bóp để đưa máu vào các mạch máu.',
      ),
      (
        prompt: 'Trong chuỗi cỏ → châu chấu → ếch, sinh vật sản xuất là gì?',
        choices: ['Cỏ', 'Châu chấu', 'Ếch', 'Cả ba'],
        correct: 0,
        explanation:
            'Cỏ tạo chất hữu cơ nhờ quang hợp và đứng đầu chuỗi thức ăn này.',
      ),
      (
        prompt: 'Cơ quan nào trao đổi oxy và cacbon đioxit với máu?',
        choices: ['Ruột non', 'Gan', 'Phổi', 'Dạ dày'],
        correct: 2,
        explanation: 'Trao đổi khí chủ yếu xảy ra tại các phế nang trong phổi.',
      ),
      (
        prompt: 'Nấm phân hủy lá rụng có vai trò gì?',
        choices: [
          'Tạo ánh sáng',
          'Phân giải chất hữu cơ',
          'Sản xuất oxy bằng quang hợp',
          'Ngăn toàn bộ vi khuẩn',
        ],
        correct: 1,
        explanation:
            'Sinh vật phân giải giúp trả lại chất dinh dưỡng cho môi trường.',
      ),
      (
        prompt: 'Thói quen nào giúp hạn chế lây nhiều bệnh qua bàn tay?',
        choices: [
          'Rửa tay bằng xà phòng',
          'Chỉ lau tay khô',
          'Dùng chung khăn bẩn',
          'Không rửa tay trước khi ăn',
        ],
        correct: 0,
        explanation:
            'Xà phòng và nước giúp loại bỏ bụi bẩn và nhiều tác nhân gây bệnh.',
      ),
    ],
  ),
  _ReviewSet(
    'school_review_digital',
    'review_digital',
    'Kỹ năng số: An toàn trên mạng',
    'Tập nhận biết tin nhắn đáng ngờ và bảo vệ thông tin cá nhân.',
    [
      (
        prompt: 'Ai đó nhắn yêu cầu gửi mã đăng nhập một lần. Bạn nên làm gì?',
        choices: [
          'Gửi ngay',
          'Đăng mã lên nhóm',
          'Không gửi và dùng kênh chính thức kiểm tra',
          'Gửi nếu họ có ảnh đại diện đẹp',
        ],
        correct: 2,
        explanation:
            'Mã dùng một lần có thể cho người khác quyền truy cập tài khoản.',
      ),
      (
        prompt: 'Cách nào giảm rủi ro khi một dịch vụ bị lộ mật khẩu?',
        choices: [
          'Dùng cùng mật khẩu ở mọi nơi',
          'Dùng mật khẩu riêng cho mỗi dịch vụ',
          'Dùng ngày sinh cho tất cả',
          'Gửi mật khẩu cho bạn',
        ],
        correct: 1,
        explanation:
            'Mật khẩu riêng giới hạn ảnh hưởng đến tài khoản dùng mật khẩu đã lộ.',
      ),
      (
        prompt: 'Trước khi chia sẻ ảnh có mặt bạn cùng lớp, nên làm gì?',
        choices: [
          'Hỏi người trong ảnh trước',
          'Đăng công khai ngay',
          'Thêm địa chỉ nhà lên ảnh',
          'Gửi cho người lạ',
        ],
        correct: 0,
        explanation:
            'Xin phép giúp tôn trọng quyền riêng tư và lựa chọn của người trong ảnh.',
      ),
      (
        prompt:
            'Một tin gây sốc không ghi nguồn xuất hiện trong nhóm chat. Bạn nên làm gì?',
        choices: [
          'Chia sẻ cho mọi người',
          'Tin vì có nhiều emoji',
          'Sửa tiêu đề rồi đăng',
          'Kiểm tra nguồn đáng tin trước khi chia sẻ',
        ],
        correct: 3,
        explanation:
            'Đối chiếu nguồn và bối cảnh giúp hạn chế phát tán thông tin sai.',
      ),
      (
        prompt: 'Mục đích của xác thực hai bước là gì?',
        choices: [
          'Thay mật khẩu bằng tên thật',
          'Thêm một bước xác minh khi đăng nhập',
          'Cho mọi người dùng chung tài khoản',
          'Tắt các cảnh báo đăng nhập',
        ],
        correct: 1,
        explanation:
            'Bước xác minh thêm giúp bảo vệ tài khoản nếu mật khẩu bị người khác biết.',
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
