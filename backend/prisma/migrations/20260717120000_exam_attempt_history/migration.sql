-- CreateTable
CREATE TABLE "ExamAttempt" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "submissionId" TEXT NOT NULL,
    "requestFingerprint" TEXT NOT NULL,
    "questionSetId" TEXT NOT NULL,
    "sourceQuestionSetId" TEXT,
    "questionSetTitle" TEXT NOT NULL,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "totalQuestions" INTEGER NOT NULL,
    "correctAnswers" INTEGER NOT NULL,
    "wrongAnswers" INTEGER NOT NULL,
    "unansweredAnswers" INTEGER NOT NULL,
    "percentageScore" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ExamAttempt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ExamAttemptAnswer" (
    "id" TEXT NOT NULL,
    "attemptId" TEXT NOT NULL,
    "questionId" TEXT NOT NULL,
    "questionText" TEXT NOT NULL,
    "answerOptions" JSONB NOT NULL,
    "selectedAnswerOptionId" TEXT,
    "selectedAnswerText" TEXT,
    "correctAnswerOptionId" TEXT NOT NULL,
    "correctAnswerText" TEXT NOT NULL,
    "isCorrect" BOOLEAN NOT NULL,
    "explanation" TEXT,
    "position" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ExamAttemptAnswer_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ExamAttempt_userId_submissionId_key" ON "ExamAttempt"("userId", "submissionId");

-- CreateIndex
CREATE INDEX "ExamAttempt_userId_completedAt_id_idx" ON "ExamAttempt"("userId", "completedAt", "id");

-- CreateIndex
CREATE INDEX "ExamAttempt_sourceQuestionSetId_idx" ON "ExamAttempt"("sourceQuestionSetId");

-- CreateIndex
CREATE UNIQUE INDEX "ExamAttemptAnswer_attemptId_position_key" ON "ExamAttemptAnswer"("attemptId", "position");

-- CreateIndex
CREATE INDEX "ExamAttemptAnswer_attemptId_idx" ON "ExamAttemptAnswer"("attemptId");

-- AddForeignKey
ALTER TABLE "ExamAttempt" ADD CONSTRAINT "ExamAttempt_sourceQuestionSetId_fkey" FOREIGN KEY ("sourceQuestionSetId") REFERENCES "QuestionSet"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExamAttemptAnswer" ADD CONSTRAINT "ExamAttemptAnswer_attemptId_fkey" FOREIGN KEY ("attemptId") REFERENCES "ExamAttempt"("id") ON DELETE CASCADE ON UPDATE CASCADE;
