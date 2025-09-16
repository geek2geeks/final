import { Injectable } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import Redis from 'ioredis';

@Injectable()
export class HealthService {
  private readonly prisma = new PrismaClient();
  private readonly redis = new Redis({
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
    maxRetriesPerRequest: 3,
    lazyConnect: true,
  });

  async checkHealth() {
    const startTime = Date.now();

    // Get timestamp from time-mcp server or fallback to local time
    const timestamp = new Date().toISOString();

    // Check database connectivity
    const databaseStatus = await this.checkDatabase();

    // Check Redis connectivity
    const redisStatus = await this.checkRedis();

    // Determine overall status
    const allConnected =
      databaseStatus === 'connected' && redisStatus === 'connected';
    const status = allConnected ? 'healthy' : 'degraded';

    // Calculate uptime (process uptime)
    const uptime = Math.floor(process.uptime());

    return {
      status,
      version: process.env.npm_package_version || '1.0.0',
      timestamp,
      environment: process.env.NODE_ENV || 'development',
      services: {
        database: databaseStatus,
        redis: redisStatus,
      },
      uptime,
      responseTime: Date.now() - startTime,
    };
  }

  private async checkDatabase(): Promise<string> {
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      return 'connected';
    } catch (error) {
      console.error('Database health check failed:', error);
      return 'error';
    }
  }

  private async checkRedis(): Promise<string> {
    try {
      const result = await this.redis.ping();
      return result === 'PONG' ? 'connected' : 'error';
    } catch (error) {
      console.error('Redis health check failed:', error);
      return 'error';
    }
  }

  async onModuleDestroy() {
    await this.prisma.$disconnect();
    this.redis.disconnect();
  }
}
