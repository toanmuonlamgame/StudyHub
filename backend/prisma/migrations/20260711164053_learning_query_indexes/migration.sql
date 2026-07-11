-- DropIndex
DROP INDEX "AnswerOption_questionId_idx";

-- DropIndex
DROP INDEX "Question_questionSetId_idx";

-- DropIndex
DROP INDEX "QuestionSet_subjectId_idx";

-- DropIndex
DROP INDEX "QuestionSet_topicId_idx";

-- DropIndex
DROP INDEX "Topic_subjectId_idx";

-- CreateIndex
CREATE INDEX "QuestionSet_subjectId_createdAt_id_idx" ON "QuestionSet"("subjectId", "createdAt", "id");

-- CreateIndex
CREATE INDEX "QuestionSet_topicId_createdAt_id_idx" ON "QuestionSet"("topicId", "createdAt", "id");

-- CreateIndex
CREATE INDEX "Topic_subjectId_name_idx" ON "Topic"("subjectId", "name");
