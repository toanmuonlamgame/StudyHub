ALTER TABLE "StudyMaterial"
ADD COLUMN "createdByUserId" TEXT,
ADD COLUMN "clientSubmissionId" TEXT,
ADD COLUMN "submissionFingerprint" TEXT,
ADD COLUMN "submittedAt" TIMESTAMP(3),
ADD COLUMN "reviewedAt" TIMESTAMP(3),
ADD COLUMN "rejectionReason" TEXT;

CREATE INDEX "StudyMaterial_createdByUserId_updatedAt_id_idx"
ON "StudyMaterial"("createdByUserId", "updatedAt", "id");

CREATE UNIQUE INDEX "StudyMaterial_clientSubmissionId_key"
ON "StudyMaterial"("clientSubmissionId");

ALTER TABLE "StudyMaterial"
ADD CONSTRAINT "StudyMaterial_createdByUserId_fkey"
FOREIGN KEY ("createdByUserId") REFERENCES "User"("id")
ON DELETE CASCADE ON UPDATE CASCADE;
