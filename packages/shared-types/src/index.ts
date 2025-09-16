// Game Types
export interface IUser {
  id: string;
  username: string;
  email: string;
  tiktokHandle?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface IQuiz {
  id: string;
  title: string;
  description: string;
  questions: IQuestion[];
  createdBy: string;
  difficulty: 'easy' | 'medium' | 'hard';
  categories: string[];
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface IQuestion {
  id: string;
  question: string;
  options: string[];
  correctAnswer: number;
  explanation?: string;
  timeLimit: number;
  points: number;
}

export interface IGameSession {
  id: string;
  quizId: string;
  userId: string;
  score: number;
  currentQuestionIndex: number;
  answers: IUserAnswer[];
  startedAt: Date;
  completedAt?: Date;
  status: 'in_progress' | 'completed' | 'abandoned';
}

export interface IUserAnswer {
  questionId: string;
  selectedAnswer: number;
  isCorrect: boolean;
  timeSpent: number;
  points: number;
}

// API Response Types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

// TikTok Integration Types
export interface ITikTokVideo {
  id: string;
  url: string;
  author: string;
  description: string;
  hashtags: string[];
  views: number;
  likes: number;
  shares: number;
  createdAt: Date;
}

export interface ITikTokQuizRequest {
  videoId: string;
  difficulty: 'easy' | 'medium' | 'hard';
  questionCount: number;
  categories?: string[];
}