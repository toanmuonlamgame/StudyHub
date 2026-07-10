import type {
  Question,
  QuestionSet,
  Subject,
  Topic,
} from '../types/learning.js';

export const subjects: Subject[] = [
  {
    id: 'subject_javascript',
    name: 'JavaScript Basics',
    description: 'Core JavaScript syntax and functions.',
  },
  {
    id: 'subject_java',
    name: 'Java OOP',
    description: 'Object-oriented programming concepts in Java.',
  },
  {
    id: 'subject_database',
    name: 'Database Fundamentals',
    description: 'Relational databases and basic SQL.',
  },
];

export const topics: Topic[] = [
  {
    id: 'topic_js_syntax',
    subjectId: 'subject_javascript',
    name: 'Syntax and Variables',
  },
  {
    id: 'topic_js_functions',
    subjectId: 'subject_javascript',
    name: 'Functions',
  },
  {
    id: 'topic_java_classes',
    subjectId: 'subject_java',
    name: 'Classes and Objects',
  },
  {
    id: 'topic_java_inheritance',
    subjectId: 'subject_java',
    name: 'Inheritance',
  },
  {
    id: 'topic_database_sql',
    subjectId: 'subject_database',
    name: 'SQL Basics',
  },
  {
    id: 'topic_database_relations',
    subjectId: 'subject_database',
    name: 'Relational Design',
  },
];

export const questionSets: QuestionSet[] = [
  {
    id: 'question_set_js_basics',
    subjectId: 'subject_javascript',
    topicId: 'topic_js_syntax',
    title: 'JavaScript Basics Check',
    description: 'Review variables, equality, and arrays.',
    questionCount: 3,
  },
  {
    id: 'question_set_js_functions',
    subjectId: 'subject_javascript',
    topicId: 'topic_js_functions',
    title: 'JavaScript Functions',
    description: 'Practice function syntax and behavior.',
    questionCount: 3,
  },
  {
    id: 'question_set_java_oop',
    subjectId: 'subject_java',
    topicId: 'topic_java_classes',
    title: 'Java OOP Essentials',
    description: 'Review classes, inheritance, and access control.',
    questionCount: 3,
  },
  {
    id: 'question_set_database',
    subjectId: 'subject_database',
    topicId: 'topic_database_sql',
    title: 'Database Fundamentals',
    description: 'Review SQL and relational database concepts.',
    questionCount: 3,
  },
];

export const questions: Question[] = [
  {
    id: 'question_js_basics_1',
    questionSetId: 'question_set_js_basics',
    text: 'Which keyword declares a block-scoped variable that can change?',
    answerOptions: [
      { id: 'js_b1_a', text: 'var' },
      { id: 'js_b1_b', text: 'const' },
      { id: 'js_b1_c', text: 'let' },
      { id: 'js_b1_d', text: 'static' },
    ],
  },
  {
    id: 'question_js_basics_2',
    questionSetId: 'question_set_js_basics',
    text: 'Which operator checks value and type equality?',
    answerOptions: [
      { id: 'js_b2_a', text: '==' },
      { id: 'js_b2_b', text: '===' },
      { id: 'js_b2_c', text: '=' },
      { id: 'js_b2_d', text: '!=' },
    ],
  },
  {
    id: 'question_js_basics_3',
    questionSetId: 'question_set_js_basics',
    text: 'Which array method adds an item to the end?',
    answerOptions: [
      { id: 'js_b3_a', text: 'pop' },
      { id: 'js_b3_b', text: 'shift' },
      { id: 'js_b3_c', text: 'push' },
      { id: 'js_b3_d', text: 'slice' },
    ],
  },
  {
    id: 'question_js_functions_1',
    questionSetId: 'question_set_js_functions',
    text: 'Which example is a valid arrow function?',
    answerOptions: [
      { id: 'js_f1_a', text: '(a, b) => a + b' },
      { id: 'js_f1_b', text: '(a, b) -> a + b' },
      { id: 'js_f1_c', text: 'function => (a, b)' },
      { id: 'js_f1_d', text: 'arrow(a, b): a + b' },
    ],
  },
  {
    id: 'question_js_functions_2',
    questionSetId: 'question_set_js_functions',
    text: 'What does a function return when no value is returned?',
    answerOptions: [
      { id: 'js_f2_a', text: 'null' },
      { id: 'js_f2_b', text: 'false' },
      { id: 'js_f2_c', text: '0' },
      { id: 'js_f2_d', text: 'undefined' },
    ],
  },
  {
    id: 'question_js_functions_3',
    questionSetId: 'question_set_js_functions',
    text: 'What are function parameters used for?',
    answerOptions: [
      { id: 'js_f3_a', text: 'Receiving input values' },
      { id: 'js_f3_b', text: 'Naming files' },
      { id: 'js_f3_c', text: 'Installing packages' },
      { id: 'js_f3_d', text: 'Creating databases' },
    ],
  },
  {
    id: 'question_java_oop_1',
    questionSetId: 'question_set_java_oop',
    text: 'What is the blueprint used to create Java objects?',
    answerOptions: [
      { id: 'java_1_a', text: 'Package' },
      { id: 'java_1_b', text: 'Class' },
      { id: 'java_1_c', text: 'Loop' },
      { id: 'java_1_d', text: 'Array' },
    ],
  },
  {
    id: 'question_java_oop_2',
    questionSetId: 'question_set_java_oop',
    text: 'Which keyword lets a Java class inherit another class?',
    answerOptions: [
      { id: 'java_2_a', text: 'extends' },
      { id: 'java_2_b', text: 'imports' },
      { id: 'java_2_c', text: 'inherits' },
      { id: 'java_2_d', text: 'includes' },
    ],
  },
  {
    id: 'question_java_oop_3',
    questionSetId: 'question_set_java_oop',
    text: 'Where can a private field be accessed directly?',
    answerOptions: [
      { id: 'java_3_a', text: 'From any package' },
      { id: 'java_3_b', text: 'From every subclass' },
      { id: 'java_3_c', text: 'Inside its own class' },
      { id: 'java_3_d', text: 'From any application' },
    ],
  },
  {
    id: 'question_database_1',
    questionSetId: 'question_set_database',
    text: 'Which SQL command reads rows from a table?',
    answerOptions: [
      { id: 'db_1_a', text: 'SELECT' },
      { id: 'db_1_b', text: 'UPDATE' },
      { id: 'db_1_c', text: 'DELETE' },
      { id: 'db_1_d', text: 'INSERT' },
    ],
  },
  {
    id: 'question_database_2',
    questionSetId: 'question_set_database',
    text: 'What is the main purpose of a primary key?',
    answerOptions: [
      { id: 'db_2_a', text: 'Sort every query' },
      { id: 'db_2_b', text: 'Identify each row' },
      { id: 'db_2_c', text: 'Hide a table' },
      { id: 'db_2_d', text: 'Delete duplicates automatically' },
    ],
  },
  {
    id: 'question_database_3',
    questionSetId: 'question_set_database',
    text: 'What links a child table row to a parent table row?',
    answerOptions: [
      { id: 'db_3_a', text: 'View' },
      { id: 'db_3_b', text: 'Index name' },
      { id: 'db_3_c', text: 'Foreign key' },
      { id: 'db_3_d', text: 'Column alias' },
    ],
  },
];

const correctAnswerOptionIdsByQuestionId: Record<string, string> = {
  question_js_basics_1: 'js_b1_c',
  question_js_basics_2: 'js_b2_b',
  question_js_basics_3: 'js_b3_c',
  question_js_functions_1: 'js_f1_a',
  question_js_functions_2: 'js_f2_d',
  question_js_functions_3: 'js_f3_a',
  question_java_oop_1: 'java_1_b',
  question_java_oop_2: 'java_2_a',
  question_java_oop_3: 'java_3_c',
  question_database_1: 'db_1_a',
  question_database_2: 'db_2_b',
  question_database_3: 'db_3_c',
};

export function getCorrectAnswerOptionId(questionId: string): string | undefined {
  return correctAnswerOptionIdsByQuestionId[questionId];
}
