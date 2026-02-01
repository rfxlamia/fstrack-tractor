import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { OperatorsService } from './operators.service';
import { Operator } from './entities/operator.entity';
import { User } from '../users/entities/user.entity';
import { OperatorResponseDto } from './dto/operator-response.dto';

/**
 * Mock repository factory
 */
const createMockRepository = () => ({
  find: jest.fn(),
});

type MockRepository<T = any> = Partial<Record<keyof Repository<T>, jest.Mock>>;

describe('OperatorsService', () => {
  let service: OperatorsService;
  let repository: MockRepository<Operator>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OperatorsService,
        {
          provide: getRepositoryToken(Operator),
          useValue: createMockRepository(),
        },
      ],
    }).compile();

    service = module.get<OperatorsService>(OperatorsService);
    repository = module.get<MockRepository<Operator>>(
      getRepositoryToken(Operator),
    );
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return operators with user names (SUCCESS case)', async () => {
      const mockUser1 = { id: 1, fullname: 'Budi Santoso' } as User;
      const mockUser2 = { id: 2, fullname: 'Ahmad Wijaya' } as User;

      const mockOperators: Operator[] = [
        {
          id: 1,
          userId: 1,
          unitId: 'UNIT01',
          user: mockUser1,
        } as Operator,
        {
          id: 2,
          userId: 2,
          unitId: 'UNIT02',
          user: mockUser2,
        } as Operator,
      ];

      repository.find?.mockResolvedValue(mockOperators);

      const result = await service.findAll();

      expect(result).toHaveLength(2);
      expect(result[0]).toBeInstanceOf(OperatorResponseDto);
      expect(result[0].id).toBe(1);
      expect(result[0].operatorName).toBe('Budi Santoso');
      expect(result[0].unitId).toBe('UNIT01');
      expect(result[1].operatorName).toBe('Ahmad Wijaya');
      expect(repository.find).toHaveBeenCalledWith({
        relations: ['user'],
        order: {
          user: {
            fullname: 'ASC',
          },
        },
      });
    });

    it('should handle operator with NULL user (edge case, returns "Unknown")', async () => {
      const mockOperators: Operator[] = [
        {
          id: 1,
          userId: null,
          unitId: 'UNIT01',
          user: null,
        } as Operator,
      ];

      repository.find?.mockResolvedValue(mockOperators);

      const result = await service.findAll();

      expect(result).toHaveLength(1);
      expect(result[0].operatorName).toBe('Unknown');
      expect(result[0].id).toBe(1);
      expect(result[0].unitId).toBe('UNIT01');
    });

    it('should return empty array when no operators exist', async () => {
      repository.find?.mockResolvedValue([]);

      const result = await service.findAll();

      expect(result).toEqual([]);
      expect(result).toHaveLength(0);
    });

    it('should sort operators alphabetically by user.fullname ASC', async () => {
      // Create operators - mock returns them in SORTED order (as DB would)
      // This simulates TypeORM returning sorted results
      const mockUserA = { id: 2, fullname: 'Ahmad Wijaya' } as User;
      const mockUserM = { id: 3, fullname: 'Muhammad Ali' } as User;
      const mockUserZ = { id: 1, fullname: 'Zulkarnain' } as User;

      // Mock returns already sorted (simulating DB ORDER BY)
      const mockOperators: Operator[] = [
        {
          id: 2,
          userId: 2,
          unitId: 'UNIT02',
          user: mockUserA,
        } as Operator,
        {
          id: 3,
          userId: 3,
          unitId: 'UNIT03',
          user: mockUserM,
        } as Operator,
        {
          id: 1,
          userId: 1,
          unitId: 'UNIT01',
          user: mockUserZ,
        } as Operator,
      ];

      repository.find?.mockResolvedValue(mockOperators);

      const result = await service.findAll();

      // Verify repository was called with correct sort order
      expect(repository.find).toHaveBeenCalledWith({
        relations: ['user'],
        order: {
          user: {
            fullname: 'ASC',
          },
        },
      });

      // Verify all operators are returned in correct order
      expect(result).toHaveLength(3);
      expect(result[0].operatorName).toBe('Ahmad Wijaya');
      expect(result[1].operatorName).toBe('Muhammad Ali');
      expect(result[2].operatorName).toBe('Zulkarnain');
    });

    it('should transform entities to DTOs using plainToClass', async () => {
      const mockUser = { id: 1, fullname: 'Budi Santoso' } as User;
      const mockOperators: Operator[] = [
        {
          id: 1,
          userId: 1,
          unitId: 'UNIT01',
          user: mockUser,
        } as Operator,
      ];

      repository.find?.mockResolvedValue(mockOperators);

      const result = await service.findAll();

      expect(result[0]).toBeInstanceOf(OperatorResponseDto);
      expect(result[0].id).toBe(1);
      expect(result[0].operatorName).toBe('Budi Santoso');
      expect(result[0].unitId).toBe('UNIT01');
    });

    it('should handle mixed operators (with and without users)', async () => {
      const mockUser = { id: 1, fullname: 'Budi Santoso' } as User;

      const mockOperators: Operator[] = [
        {
          id: 1,
          userId: 1,
          unitId: 'UNIT01',
          user: mockUser,
        } as Operator,
        {
          id: 2,
          userId: null,
          unitId: 'UNIT02',
          user: null,
        } as Operator,
      ];

      repository.find?.mockResolvedValue(mockOperators);

      const result = await service.findAll();

      expect(result).toHaveLength(2);
      expect(result[0].operatorName).toBe('Budi Santoso');
      expect(result[1].operatorName).toBe('Unknown');
    });

    it('should handle null unitId', async () => {
      const mockUser = { id: 1, fullname: 'Budi Santoso' } as User;

      const mockOperators: Operator[] = [
        {
          id: 1,
          userId: 1,
          unitId: null,
          user: mockUser,
        } as Operator,
      ];

      repository.find?.mockResolvedValue(mockOperators);

      const result = await service.findAll();

      expect(result[0].unitId).toBeNull();
      expect(result[0].operatorName).toBe('Budi Santoso');
    });
  });
});
