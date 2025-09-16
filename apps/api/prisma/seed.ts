import { PrismaClient, Difficulty, CorrectAnswer } from '@prisma/client';

const prisma = new PrismaClient();

const sampleQuestions = [
  {
    text: 'Qual é a capital do Brasil?',
    optionA: 'São Paulo',
    optionB: 'Rio de Janeiro',
    optionC: 'Brasília',
    optionD: 'Salvador',
    correctAnswer: CorrectAnswer.C,
    difficulty: Difficulty.Facil,
    category: 'Geografia',
  },
  {
    text: 'Quem escreveu "Dom Casmurro"?',
    optionA: 'José de Alencar',
    optionB: 'Machado de Assis',
    optionC: 'Clarice Lispector',
    optionD: 'Graciliano Ramos',
    correctAnswer: CorrectAnswer.B,
    difficulty: Difficulty.Medio,
    category: 'Literatura',
  },
  {
    text: 'Qual é a fórmula química da água?',
    optionA: 'H2O',
    optionB: 'CO2',
    optionC: 'NaCl',
    optionD: 'O2',
    correctAnswer: CorrectAnswer.A,
    difficulty: Difficulty.Facil,
    category: 'Química',
  },
  {
    text: 'Em que ano foi proclamada a República no Brasil?',
    optionA: '1888',
    optionB: '1889',
    optionC: '1890',
    optionD: '1891',
    correctAnswer: CorrectAnswer.B,
    difficulty: Difficulty.Medio,
    category: 'História',
  },
  {
    text: 'Qual é o maior planeta do sistema solar?',
    optionA: 'Terra',
    optionB: 'Saturno',
    optionC: 'Júpiter',
    optionD: 'Netuno',
    correctAnswer: CorrectAnswer.C,
    difficulty: Difficulty.Facil,
    category: 'Astronomia',
  },
  {
    text: 'Quem desenvolveu a teoria da relatividade?',
    optionA: 'Isaac Newton',
    optionB: 'Albert Einstein',
    optionC: 'Galileu Galilei',
    optionD: 'Stephen Hawking',
    correctAnswer: CorrectAnswer.B,
    difficulty: Difficulty.Medio,
    category: 'Física',
  },
  {
    text: 'Qual é a moeda oficial do Japão?',
    optionA: 'Won',
    optionB: 'Yuan',
    optionC: 'Yen',
    optionD: 'Dong',
    correctAnswer: CorrectAnswer.C,
    difficulty: Difficulty.Facil,
    category: 'Geografia',
  },
  {
    text: 'Quantos continentes existem?',
    optionA: '5',
    optionB: '6',
    optionC: '7',
    optionD: '8',
    correctAnswer: CorrectAnswer.C,
    difficulty: Difficulty.Facil,
    category: 'Geografia',
  },
  {
    text: 'Qual é o elemento químico representado pelo símbolo "Au"?',
    optionA: 'Prata',
    optionB: 'Ouro',
    optionC: 'Alumínio',
    optionD: 'Argônio',
    correctAnswer: CorrectAnswer.B,
    difficulty: Difficulty.Medio,
    category: 'Química',
  },
  {
    text: 'Em que século viveu Leonardo da Vinci?',
    optionA: 'XIV',
    optionB: 'XV',
    optionC: 'XVI',
    optionD: 'XVII',
    correctAnswer: CorrectAnswer.B,
    difficulty: Difficulty.Dificil,
    category: 'História',
  },
];

async function main() {
  console.log('🌱 Starting database seed...');

  // Clear existing data
  console.log('🧹 Cleaning existing data...');
  await prisma.analyticsEvent.deleteMany();
  await prisma.quizResult.deleteMany();
  await prisma.quiz.deleteMany();
  await prisma.question.deleteMany();
  await prisma.user.deleteMany();

  // Seed questions
  console.log('📝 Seeding questions...');
  const questions = await prisma.question.createMany({
    data: sampleQuestions,
    skipDuplicates: true,
  });
  console.log(`✅ Created ${questions.count} questions`);

  // Create a test user
  console.log('👤 Creating test user...');
  const testUser = await prisma.user.create({
    data: {
      clerkId: 'test_user_123',
      email: 'test@quizztok.com',
      username: 'testuser',
      tiktokUsername: 'testuser_tiktok',
      subscriptionTier: 'free',
      subscriptionStatus: 'active',
    },
  });
  console.log(`✅ Created test user: ${testUser.email}`);

  // Create a sample quiz
  console.log('🎯 Creating sample quiz...');
  const sampleQuiz = await prisma.quiz.create({
    data: {
      userId: testUser.id,
      roomId: 'DEMO123',
      title: 'Quiz de Demonstração',
      questionCount: 5,
      timePerQuestion: 15000,
      status: 'created',
    },
  });
  console.log(`✅ Created sample quiz: ${sampleQuiz.title}`);

  // Create analytics events
  console.log('📊 Creating sample analytics events...');
  await prisma.analyticsEvent.createMany({
    data: [
      {
        userId: testUser.id,
        eventType: 'quiz_created',
        eventData: { quizId: sampleQuiz.id, roomId: sampleQuiz.roomId },
      },
      {
        userId: testUser.id,
        eventType: 'user_signup',
        eventData: { source: 'web', provider: 'clerk' },
      },
      {
        eventType: 'page_view',
        eventData: { page: '/dashboard', anonymous: true },
      },
    ],
  });
  console.log('✅ Created sample analytics events');

  console.log('🎉 Database seeding completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Error during seed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });