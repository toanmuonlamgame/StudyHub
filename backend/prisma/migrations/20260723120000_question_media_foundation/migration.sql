-- Optional media metadata remains internal JSON so existing questions and attempts stay valid.
ALTER TABLE "Question"
ADD COLUMN "media" JSONB,
ADD COLUMN "explanationMedia" JSONB;

ALTER TABLE "ExamAttemptAnswer"
ADD COLUMN "questionMedia" JSONB,
ADD COLUMN "explanationMedia" JSONB;
