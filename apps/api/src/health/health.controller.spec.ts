import { Test, TestingModule } from '@nestjs/testing';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';

describe('HealthController', () => {
  let controller: HealthController;

  const mockHealthService = {
    checkHealth: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        {
          provide: HealthService,
          useValue: mockHealthService,
        },
      ],
    }).compile();

    controller = module.get<HealthController>(HealthController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should return health status', async () => {
    const mockHealthData = {
      status: 'healthy',
      version: '1.0.0',
      timestamp: '2024-01-15T10:30:00Z',
      environment: 'test',
      services: {
        database: 'connected',
        redis: 'connected',
      },
      uptime: 3600,
      responseTime: 50,
    };

    mockHealthService.checkHealth.mockResolvedValue(mockHealthData);

    const result = await controller.getHealth();

    expect(result).toEqual(mockHealthData);
    expect(mockHealthService.checkHealth).toHaveBeenCalled();
  });
});
