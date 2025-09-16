-- CreateEnum
CREATE TYPE "SubscriptionTier" AS ENUM ('free', 'pro', 'enterprise');

-- CreateEnum
CREATE TYPE "Difficulty" AS ENUM ('Fácil', 'Médio', 'Difícil');

-- CreateEnum
CREATE TYPE "CorrectAnswer" AS ENUM ('A', 'B', 'C', 'D');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "clerk_id" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "username" VARCHAR(100),
    "tiktok_username" VARCHAR(100),
    "subscription_tier" "SubscriptionTier" NOT NULL DEFAULT 'free',
    "subscription_status" VARCHAR(50),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "questions" (
    "id" SERIAL NOT NULL,
    "text" TEXT NOT NULL,
    "option_a" VARCHAR(255) NOT NULL,
    "option_b" VARCHAR(255) NOT NULL,
    "option_c" VARCHAR(255) NOT NULL,
    "option_d" VARCHAR(255) NOT NULL,
    "correct_answer" "CorrectAnswer" NOT NULL,
    "difficulty" "Difficulty" NOT NULL,
    "category" VARCHAR(100),
    "times_used" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "questions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "quizzes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "room_id" VARCHAR(100),
    "title" VARCHAR(255),
    "question_count" INTEGER,
    "time_per_question" INTEGER,
    "status" VARCHAR(50) NOT NULL DEFAULT 'created',
    "started_at" TIMESTAMP(3),
    "ended_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "quizzes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "quiz_results" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "quiz_id" UUID NOT NULL,
    "participant_count" INTEGER,
    "questions_answered" INTEGER,
    "average_score" DECIMAL(10,2),
    "winner_username" VARCHAR(100),
    "winner_score" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "quiz_results_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "analytics_events" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID,
    "event_type" VARCHAR(100) NOT NULL,
    "event_data" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "analytics_events_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_clerk_id_key" ON "users"("clerk_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE INDEX "idx_users_clerk_id" ON "users"("clerk_id");

-- CreateIndex
CREATE INDEX "idx_users_subscription" ON "users"("subscription_tier", "subscription_status");

-- CreateIndex
CREATE INDEX "idx_questions_difficulty" ON "questions"("difficulty");

-- CreateIndex
CREATE UNIQUE INDEX "quizzes_room_id_key" ON "quizzes"("room_id");

-- CreateIndex
CREATE INDEX "idx_quizzes_user_status" ON "quizzes"("user_id", "status");

-- CreateIndex
CREATE INDEX "idx_quizzes_room_id" ON "quizzes"("room_id");

-- CreateIndex
CREATE INDEX "idx_analytics_user_event" ON "analytics_events"("user_id", "event_type");

-- AddForeignKey
ALTER TABLE "quizzes" ADD CONSTRAINT "quizzes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quiz_results" ADD CONSTRAINT "quiz_results_quiz_id_fkey" FOREIGN KEY ("quiz_id") REFERENCES "quizzes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "analytics_events" ADD CONSTRAINT "analytics_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;