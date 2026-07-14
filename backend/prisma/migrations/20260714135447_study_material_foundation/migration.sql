-- CreateEnum
CREATE TYPE "StudyMaterialType" AS ENUM ('pdf', 'slides', 'notes', 'document', 'link', 'other');

-- CreateEnum
CREATE TYPE "StudyMaterialSourceType" AS ENUM ('externalLink', 'uploadedFile');

-- CreateEnum
CREATE TYPE "StudyMaterialStatus" AS ENUM ('draft', 'pendingReview', 'published', 'rejected');

-- CreateTable
CREATE TABLE "StudyMaterial" (
    "id" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "topicId" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "materialType" "StudyMaterialType" NOT NULL,
    "sourceType" "StudyMaterialSourceType" NOT NULL,
    "sourceUrl" TEXT,
    "fileName" TEXT,
    "mimeType" TEXT,
    "fileSizeBytes" INTEGER,
    "language" TEXT,
    "status" "StudyMaterialStatus" NOT NULL DEFAULT 'draft',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StudyMaterial_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "StudyMaterial_status_createdAt_id_idx" ON "StudyMaterial"("status", "createdAt", "id");

-- CreateIndex
CREATE INDEX "StudyMaterial_subjectId_status_createdAt_id_idx" ON "StudyMaterial"("subjectId", "status", "createdAt", "id");

-- CreateIndex
CREATE INDEX "StudyMaterial_topicId_status_createdAt_id_idx" ON "StudyMaterial"("topicId", "status", "createdAt", "id");

-- CreateIndex
CREATE INDEX "StudyMaterial_materialType_status_createdAt_id_idx" ON "StudyMaterial"("materialType", "status", "createdAt", "id");

-- AddForeignKey
ALTER TABLE "StudyMaterial" ADD CONSTRAINT "StudyMaterial_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES "Subject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudyMaterial" ADD CONSTRAINT "StudyMaterial_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES "Topic"("id") ON DELETE SET NULL ON UPDATE CASCADE;
