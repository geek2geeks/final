import { IGameSession, IQuestion, IUserAnswer } from '@quizztok/shared-types';

export class GameEngine {
  static calculateScore(answers: IUserAnswer[]): number {
    return answers.reduce((total, answer) => {
      return total + (answer.isCorrect ? answer.points : 0);
    }, 0);
  }

  static calculateTimeBonus(timeSpent: number, timeLimit: number): number {
    const ratio = (timeLimit - timeSpent) / timeLimit;
    return Math.max(0, Math.floor(ratio * 100));
  }

  static evaluateAnswer(
    question: IQuestion,
    selectedAnswer: number,
    timeSpent: number
  ): IUserAnswer {
    const isCorrect = selectedAnswer === question.correctAnswer;
    const basePoints = isCorrect ? question.points : 0;
    const timeBonus = isCorrect ? this.calculateTimeBonus(timeSpent, question.timeLimit) : 0;

    return {
      questionId: question.id,
      selectedAnswer,
      isCorrect,
      timeSpent,
      points: basePoints + timeBonus
    };
  }

  static updateGameSession(
    session: IGameSession,
    answer: IUserAnswer
  ): IGameSession {
    const updatedAnswers = [...session.answers, answer];
    const updatedScore = this.calculateScore(updatedAnswers);

    return {
      ...session,
      answers: updatedAnswers,
      score: updatedScore,
      currentQuestionIndex: session.currentQuestionIndex + 1
    };
  }

  static completeGameSession(session: IGameSession): IGameSession {
    return {
      ...session,
      status: 'completed',
      completedAt: new Date()
    };
  }
}

export * from '@quizztok/shared-types';