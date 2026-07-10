import '../models/answer_option.dart';
import '../models/question.dart';
import '../models/question_set.dart';
import '../models/subject.dart';
import '../models/topic.dart';

const List<Subject> mockSubjects = [
  Subject(
    id: 'subject_javascript',
    name: 'JavaScript Basics',
    description: 'Core JavaScript syntax and functions.',
  ),
  Subject(
    id: 'subject_java',
    name: 'Java OOP',
    description: 'Object-oriented programming concepts in Java.',
  ),
  Subject(
    id: 'subject_database',
    name: 'Database Fundamentals',
    description: 'Relational databases and basic SQL.',
  ),
];

const List<Topic> mockTopics = [
  Topic(
    id: 'topic_js_syntax',
    subjectId: 'subject_javascript',
    name: 'Syntax and Variables',
  ),
  Topic(
    id: 'topic_js_functions',
    subjectId: 'subject_javascript',
    name: 'Functions',
  ),
  Topic(
    id: 'topic_java_classes',
    subjectId: 'subject_java',
    name: 'Classes and Objects',
  ),
  Topic(
    id: 'topic_java_inheritance',
    subjectId: 'subject_java',
    name: 'Inheritance',
  ),
  Topic(
    id: 'topic_database_sql',
    subjectId: 'subject_database',
    name: 'SQL Basics',
  ),
  Topic(
    id: 'topic_database_relations',
    subjectId: 'subject_database',
    name: 'Relational Design',
  ),
];

const List<QuestionSet> mockQuestionSets = [
  QuestionSet(
    id: 'question_set_js_basics',
    subjectId: 'subject_javascript',
    topicId: 'topic_js_syntax',
    title: 'JavaScript Basics Check',
    description: 'Review variables, equality, and arrays.',
    questionCount: 3,
  ),
  QuestionSet(
    id: 'question_set_js_functions',
    subjectId: 'subject_javascript',
    topicId: 'topic_js_functions',
    title: 'JavaScript Functions',
    description: 'Practice function syntax and behavior.',
    questionCount: 3,
  ),
  QuestionSet(
    id: 'question_set_java_oop',
    subjectId: 'subject_java',
    topicId: 'topic_java_classes',
    title: 'Java OOP Essentials',
    description: 'Review classes, inheritance, and access control.',
    questionCount: 3,
  ),
  QuestionSet(
    id: 'question_set_database',
    subjectId: 'subject_database',
    topicId: 'topic_database_sql',
    title: 'Database Fundamentals',
    description: 'Review SQL and relational database concepts.',
    questionCount: 3,
  ),
];

const List<Question> mockQuestions = [
  Question(
    id: 'question_js_basics_1',
    questionSetId: 'question_set_js_basics',
    text: 'Which keyword declares a block-scoped variable that can change?',
    answerOptions: [
      AnswerOption(id: 'js_b1_a', text: 'var', isCorrect: false),
      AnswerOption(id: 'js_b1_b', text: 'const', isCorrect: false),
      AnswerOption(id: 'js_b1_c', text: 'let', isCorrect: true),
      AnswerOption(id: 'js_b1_d', text: 'static', isCorrect: false),
    ],
  ),
  Question(
    id: 'question_js_basics_2',
    questionSetId: 'question_set_js_basics',
    text: 'Which operator checks value and type equality?',
    answerOptions: [
      AnswerOption(id: 'js_b2_a', text: '==', isCorrect: false),
      AnswerOption(id: 'js_b2_b', text: '===', isCorrect: true),
      AnswerOption(id: 'js_b2_c', text: '=', isCorrect: false),
      AnswerOption(id: 'js_b2_d', text: '!=', isCorrect: false),
    ],
  ),
  Question(
    id: 'question_js_basics_3',
    questionSetId: 'question_set_js_basics',
    text: 'Which array method adds an item to the end?',
    answerOptions: [
      AnswerOption(id: 'js_b3_a', text: 'pop', isCorrect: false),
      AnswerOption(id: 'js_b3_b', text: 'shift', isCorrect: false),
      AnswerOption(id: 'js_b3_c', text: 'push', isCorrect: true),
      AnswerOption(id: 'js_b3_d', text: 'slice', isCorrect: false),
    ],
  ),
  Question(
    id: 'question_js_functions_1',
    questionSetId: 'question_set_js_functions',
    text: 'Which example is a valid arrow function?',
    answerOptions: [
      AnswerOption(id: 'js_f1_a', text: '(a, b) => a + b', isCorrect: true),
      AnswerOption(id: 'js_f1_b', text: '(a, b) -> a + b', isCorrect: false),
      AnswerOption(id: 'js_f1_c', text: 'function => (a, b)', isCorrect: false),
      AnswerOption(id: 'js_f1_d', text: 'arrow(a, b): a + b', isCorrect: false),
    ],
  ),
  Question(
    id: 'question_js_functions_2',
    questionSetId: 'question_set_js_functions',
    text: 'What does a function return when no value is returned?',
    answerOptions: [
      AnswerOption(id: 'js_f2_a', text: 'null', isCorrect: false),
      AnswerOption(id: 'js_f2_b', text: 'false', isCorrect: false),
      AnswerOption(id: 'js_f2_c', text: '0', isCorrect: false),
      AnswerOption(id: 'js_f2_d', text: 'undefined', isCorrect: true),
    ],
  ),
  Question(
    id: 'question_js_functions_3',
    questionSetId: 'question_set_js_functions',
    text: 'What are function parameters used for?',
    answerOptions: [
      AnswerOption(
        id: 'js_f3_a',
        text: 'Receiving input values',
        isCorrect: true,
      ),
      AnswerOption(id: 'js_f3_b', text: 'Naming files', isCorrect: false),
      AnswerOption(
        id: 'js_f3_c',
        text: 'Installing packages',
        isCorrect: false,
      ),
      AnswerOption(id: 'js_f3_d', text: 'Creating databases', isCorrect: false),
    ],
  ),
  Question(
    id: 'question_java_oop_1',
    questionSetId: 'question_set_java_oop',
    text: 'What is the blueprint used to create Java objects?',
    answerOptions: [
      AnswerOption(id: 'java_1_a', text: 'Package', isCorrect: false),
      AnswerOption(id: 'java_1_b', text: 'Class', isCorrect: true),
      AnswerOption(id: 'java_1_c', text: 'Loop', isCorrect: false),
      AnswerOption(id: 'java_1_d', text: 'Array', isCorrect: false),
    ],
  ),
  Question(
    id: 'question_java_oop_2',
    questionSetId: 'question_set_java_oop',
    text: 'Which keyword lets a Java class inherit another class?',
    answerOptions: [
      AnswerOption(id: 'java_2_a', text: 'extends', isCorrect: true),
      AnswerOption(id: 'java_2_b', text: 'imports', isCorrect: false),
      AnswerOption(id: 'java_2_c', text: 'inherits', isCorrect: false),
      AnswerOption(id: 'java_2_d', text: 'includes', isCorrect: false),
    ],
  ),
  Question(
    id: 'question_java_oop_3',
    questionSetId: 'question_set_java_oop',
    text: 'Where can a private field be accessed directly?',
    answerOptions: [
      AnswerOption(id: 'java_3_a', text: 'From any package', isCorrect: false),
      AnswerOption(
        id: 'java_3_b',
        text: 'From every subclass',
        isCorrect: false,
      ),
      AnswerOption(
        id: 'java_3_c',
        text: 'Inside its own class',
        isCorrect: true,
      ),
      AnswerOption(
        id: 'java_3_d',
        text: 'From any application',
        isCorrect: false,
      ),
    ],
  ),
  Question(
    id: 'question_database_1',
    questionSetId: 'question_set_database',
    text: 'Which SQL command reads rows from a table?',
    answerOptions: [
      AnswerOption(id: 'db_1_a', text: 'SELECT', isCorrect: true),
      AnswerOption(id: 'db_1_b', text: 'UPDATE', isCorrect: false),
      AnswerOption(id: 'db_1_c', text: 'DELETE', isCorrect: false),
      AnswerOption(id: 'db_1_d', text: 'INSERT', isCorrect: false),
    ],
  ),
  Question(
    id: 'question_database_2',
    questionSetId: 'question_set_database',
    text: 'What is the main purpose of a primary key?',
    answerOptions: [
      AnswerOption(id: 'db_2_a', text: 'Sort every query', isCorrect: false),
      AnswerOption(id: 'db_2_b', text: 'Identify each row', isCorrect: true),
      AnswerOption(id: 'db_2_c', text: 'Hide a table', isCorrect: false),
      AnswerOption(
        id: 'db_2_d',
        text: 'Delete duplicates automatically',
        isCorrect: false,
      ),
    ],
  ),
  Question(
    id: 'question_database_3',
    questionSetId: 'question_set_database',
    text: 'What links a child table row to a parent table row?',
    answerOptions: [
      AnswerOption(id: 'db_3_a', text: 'View', isCorrect: false),
      AnswerOption(id: 'db_3_b', text: 'Index name', isCorrect: false),
      AnswerOption(id: 'db_3_c', text: 'Foreign key', isCorrect: true),
      AnswerOption(id: 'db_3_d', text: 'Column alias', isCorrect: false),
    ],
  ),
];

List<Topic> getTopicsBySubjectId(String subjectId) {
  return mockTopics
      .where((topic) => topic.subjectId == subjectId)
      .toList(growable: false);
}

List<QuestionSet> getQuestionSetsBySubjectId(String subjectId) {
  return mockQuestionSets
      .where((questionSet) => questionSet.subjectId == subjectId)
      .toList(growable: false);
}

List<Question> getQuestionsByQuestionSetId(String questionSetId) {
  return mockQuestions
      .where((question) => question.questionSetId == questionSetId)
      .toList(growable: false);
}

QuestionSet? getQuestionSetById(String questionSetId) {
  for (final questionSet in mockQuestionSets) {
    if (questionSet.id == questionSetId) {
      return questionSet;
    }
  }

  return null;
}
