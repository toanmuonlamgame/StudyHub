ALTER TABLE "QuestionSet" ADD COLUMN "language" TEXT;
ALTER TABLE "QuestionSet" ADD CONSTRAINT "QuestionSet_language_check"
  CHECK ("language" IN ('vi', 'en', 'zh', 'other'));
CREATE INDEX "QuestionSet_language_status_createdAt_id_idx"
  ON "QuestionSet"("language", "status", "createdAt", "id");
