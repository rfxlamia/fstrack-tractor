import { Test, TestingModule } from '@nestjs/testing';
import { OperatorsController } from './operators.controller';
import { OperatorsService } from './operators.service';
import { OperatorResponseDto } from './dto/operator-response.dto';

describe('OperatorsController', () => {
  let controller: OperatorsController;
  let service: {
    findAll: jest.Mock;
  };

  const mockOperatorsService: {
    findAll: jest.Mock;
  } = {
    findAll: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [OperatorsController],
      providers: [
        {
          provide: OperatorsService,
          useValue: mockOperatorsService,
        },
      ],
    }).compile();

    controller = module.get<OperatorsController>(OperatorsController);
    service = module.get<typeof mockOperatorsService>(OperatorsService);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('GET /api/v1/operators', () => {
    it('should return 200 OK with operators list', async () => {
      const mockOperators: OperatorResponseDto[] = [
        {
          id: 1,
          operatorName: 'Budi Santoso',
          unitId: 'UNIT01',
        },
        {
          id: 2,
          operatorName: 'Ahmad Wijaya',
          unitId: 'UNIT02',
        },
      ];

      service.findAll.mockResolvedValue(mockOperators);

      const result = await controller.findAll();

      expect(result.statusCode).toBe(200);
      expect(result.message).toBe('Daftar operator berhasil diambil');
      expect(result.data).toHaveLength(2);
      expect(result.data[0].id).toBe(1);
      expect(result.data[0].operatorName).toBe('Budi Santoso');
      expect(result.data[0].unitId).toBe('UNIT01');
      expect(result.data[1].operatorName).toBe('Ahmad Wijaya');
      expect(service.findAll).toHaveBeenCalled();
    });

    it('should return empty array when no operators exist', async () => {
      service.findAll.mockResolvedValue([]);

      const result = await controller.findAll();

      expect(result.statusCode).toBe(200);
      expect(result.message).toBe('Daftar operator berhasil diambil');
      expect(result.data).toEqual([]);
      expect(result.data).toHaveLength(0);
    });

    it('should return response format matching { statusCode, message, data }', async () => {
      const mockOperators: OperatorResponseDto[] = [
        {
          id: 1,
          operatorName: 'Budi Santoso',
          unitId: 'UNIT01',
        },
      ];

      service.findAll.mockResolvedValue(mockOperators);

      const result = await controller.findAll();

      expect(result).toHaveProperty('statusCode');
      expect(result).toHaveProperty('message');
      expect(result).toHaveProperty('data');
      expect(typeof result.statusCode).toBe('number');
      expect(typeof result.message).toBe('string');
      expect(Array.isArray(result.data)).toBe(true);
    });

    it('should handle operators with null unitId', async () => {
      const mockOperators: OperatorResponseDto[] = [
        {
          id: 1,
          operatorName: 'Budi Santoso',
          unitId: null,
        },
      ];

      service.findAll.mockResolvedValue(mockOperators);

      const result = await controller.findAll();

      expect(result.data[0].unitId).toBeNull();
      expect(result.data[0].operatorName).toBe('Budi Santoso');
    });

    it('should handle operators with "Unknown" name (no user)', async () => {
      const mockOperators: OperatorResponseDto[] = [
        {
          id: 1,
          operatorName: 'Unknown',
          unitId: 'UNIT01',
        },
      ];

      service.findAll.mockResolvedValue(mockOperators);

      const result = await controller.findAll();

      expect(result.data[0].operatorName).toBe('Unknown');
      expect(result.statusCode).toBe(200);
    });

    it('should verify response data is OperatorResponseDto array', async () => {
      const mockOperators: OperatorResponseDto[] = [
        {
          id: 1,
          operatorName: 'Budi Santoso',
          unitId: 'UNIT01',
        },
        {
          id: 2,
          operatorName: 'Ahmad Wijaya',
          unitId: 'UNIT02',
        },
      ];

      service.findAll.mockResolvedValue(mockOperators);

      const result = await controller.findAll();

      // Verify each item has the expected structure
      result.data.forEach((item) => {
        expect(item).toHaveProperty('id');
        expect(item).toHaveProperty('operatorName');
        expect(item).toHaveProperty('unitId');
        expect(typeof item.id).toBe('number');
        expect(typeof item.operatorName).toBe('string');
      });
    });
  });
});
