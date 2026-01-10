import { Test, TestingModule } from '@nestjs/testing';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';

describe('HealthController', () => {
  let controller: HealthController;
  let service: HealthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [HealthService],
    }).compile();

    controller = module.get<HealthController>(HealthController);
    service = module.get<HealthService>(HealthService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getHealth', () => {
    it('should return health status from service', () => {
      const mockHealth = {
        status: 'ok',
        timestamp: '2026-01-11T10:30:00.000Z',
      };

      const getHealthSpy = jest
        .spyOn(service, 'getHealth')
        .mockReturnValue(mockHealth);

      const result = controller.getHealth();

      expect(result).toEqual(mockHealth);
      expect(getHealthSpy).toHaveBeenCalled();
    });

    it('should return object with status and timestamp properties', () => {
      const result = controller.getHealth();

      expect(result).toHaveProperty('status');
      expect(result).toHaveProperty('timestamp');
    });
  });
});
