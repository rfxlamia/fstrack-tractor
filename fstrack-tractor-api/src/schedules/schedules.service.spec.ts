import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotFoundException, BadRequestException } from '@nestjs/common';
import { SchedulesService, VALID_STATUSES } from './schedules.service';
import { Schedule } from './entities/schedule.entity';
import { CreateScheduleDto } from './dto/create-schedule.dto';

/**
 * Mock repository factory
 */
const createMockRepository = () => ({
  create: jest.fn(),
  save: jest.fn(),
  findAndCount: jest.fn(),
  findOne: jest.fn(),
});

type MockRepository<T = any> = Partial<Record<keyof Repository<T>, jest.Mock>>;

describe('SchedulesService', () => {
  let service: SchedulesService;
  let repository: MockRepository<Schedule>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SchedulesService,
        {
          provide: getRepositoryToken(Schedule),
          useValue: createMockRepository(),
        },
      ],
    }).compile();

    service = module.get<SchedulesService>(SchedulesService);
    repository = module.get<MockRepository<Schedule>>(
      getRepositoryToken(Schedule),
    );
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    const validCreateDto: CreateScheduleDto = {
      workDate: '2026-01-30',
      pattern: 'Rotasi',
      shift: 'Pagi',
      locationId: 'LOC001',
      unitId: 'UNIT01',
      operatorId: 123,
      notes: 'Test notes',
    };

    it('should create schedule with status OPEN', async () => {
      const mockSchedule = {
        id: 'test-uuid',
        workDate: new Date('2026-01-30'),
        pattern: 'Rotasi',
        shift: 'Pagi',
        locationId: 'LOC001',
        unitId: 'UNIT01',
        operatorId: 123,
        notes: 'Test notes',
        status: 'OPEN',
        createdAt: new Date(),
        updatedAt: new Date(),
      } as Schedule;

      repository.create?.mockReturnValue(mockSchedule);
      repository.save?.mockResolvedValue(mockSchedule);

      const result = await service.create(validCreateDto);

      expect(result.status).toBe('OPEN');

      expect(repository.create).toHaveBeenCalled();
      expect(repository.save).toHaveBeenCalledWith(mockSchedule);
    });

    it('should accept INTEGER operatorId', async () => {
      const dtoWithIntOperator: CreateScheduleDto = {
        workDate: '2026-01-30',
        pattern: 'Rotasi',
        operatorId: 456,
      };

      const mockSchedule = {
        id: 'test-uuid',
        operatorId: 456,
        status: 'OPEN',
      } as Schedule;

      repository.create?.mockReturnValue(mockSchedule);
      repository.save?.mockResolvedValue(mockSchedule);

      const result = await service.create(dtoWithIntOperator);

      expect(result.operatorId).toBe(456);
      expect(typeof result.operatorId).toBe('number');
    });

    it('should accept null operatorId', async () => {
      const dtoWithoutOperator: CreateScheduleDto = {
        workDate: '2026-01-30',
        pattern: 'Rotasi',
      };

      const mockSchedule = {
        id: 'test-uuid',
        operatorId: null,
        status: 'OPEN',
      } as Schedule;

      repository.create?.mockReturnValue(mockSchedule);
      repository.save?.mockResolvedValue(mockSchedule);

      const result = await service.create(dtoWithoutOperator);

      expect(result.operatorId).toBeNull();
    });

    it('should throw BadRequestException for float operatorId', async () => {
      const dtoWithFloatOperator: CreateScheduleDto = {
        workDate: '2026-01-30',
        pattern: 'Rotasi',
        operatorId: 123.45, // Float passes TypeScript but fails runtime validation
      };

      await expect(service.create(dtoWithFloatOperator)).rejects.toThrow(
        BadRequestException,
      );
      await expect(service.create(dtoWithFloatOperator)).rejects.toThrow(
        'ID operator harus berupa angka bulat',
      );
    });

    it('should accept VARCHAR locationId (not UUID)', async () => {
      const dtoWithVarcharLocation: CreateScheduleDto = {
        workDate: '2026-01-30',
        pattern: 'Rotasi',
        locationId: 'LOC001',
      };

      const mockSchedule = {
        id: 'test-uuid',
        locationId: 'LOC001',
        status: 'OPEN',
      } as Schedule;

      repository.create?.mockReturnValue(mockSchedule);
      repository.save?.mockResolvedValue(mockSchedule);

      const result = await service.create(dtoWithVarcharLocation);

      expect(result.locationId).toBe('LOC001');
      expect(result.locationId).not.toMatch(
        /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i,
      );
    });

    it('should accept VARCHAR unitId (not UUID)', async () => {
      const dtoWithVarcharUnit: CreateScheduleDto = {
        workDate: '2026-01-30',
        pattern: 'Rotasi',
        unitId: 'UNIT01',
      };

      const mockSchedule = {
        id: 'test-uuid',
        unitId: 'UNIT01',
        status: 'OPEN',
      } as Schedule;

      repository.create?.mockReturnValue(mockSchedule);
      repository.save?.mockResolvedValue(mockSchedule);

      const result = await service.create(dtoWithVarcharUnit);

      expect(result.unitId).toBe('UNIT01');
      expect(result.unitId).not.toMatch(
        /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i,
      );
    });

    it('should handle optional fields as null', async () => {
      const minimalDto: CreateScheduleDto = {
        workDate: '2026-01-30',
        pattern: 'Rotasi',
      };

      const mockSchedule = {
        id: 'test-uuid',
        workDate: new Date('2026-01-30'),
        pattern: 'Rotasi',
        shift: null,
        locationId: null,
        unitId: null,
        operatorId: null,
        notes: null,
        status: 'OPEN',
      } as Schedule;

      repository.create?.mockReturnValue(mockSchedule);
      repository.save?.mockResolvedValue(mockSchedule);

      const result = await service.create(minimalDto);

      expect(result.shift).toBeNull();
      expect(result.locationId).toBeNull();
      expect(result.unitId).toBeNull();
      expect(result.operatorId).toBeNull();
      expect(result.notes).toBeNull();
    });
  });

  describe('findAll', () => {
    it('should return paginated schedules', async () => {
      const mockSchedules: Schedule[] = [
        {
          id: 'uuid-1',
          workDate: new Date('2026-01-30'),
          pattern: 'Rotasi',
          status: 'OPEN',
        } as Schedule,
        {
          id: 'uuid-2',
          workDate: new Date('2026-01-29'),
          pattern: 'Non-Rotasi',
          status: 'CLOSED',
        } as Schedule,
      ];

      repository.findAndCount?.mockResolvedValue([mockSchedules, 2]);

      const result = await service.findAll({ page: 1, limit: 10 });

      expect(result.data).toHaveLength(2);
      expect(result.total).toBe(2);
      expect(result.page).toBe(1);
      expect(result.limit).toBe(10);
      expect(result.totalPages).toBe(1);
      expect(repository.findAndCount).toHaveBeenCalledWith({
        skip: 0,
        take: 10,
        order: {
          workDate: 'DESC',
          createdAt: 'DESC',
        },
      });
    });

    it('should calculate pagination correctly for page 2', async () => {
      repository.findAndCount?.mockResolvedValue([[], 25]);

      const result = await service.findAll({ page: 2, limit: 10 });

      expect(result.page).toBe(2);
      expect(result.totalPages).toBe(3);
      expect(repository.findAndCount).toHaveBeenCalledWith({
        skip: 10,
        take: 10,
        order: {
          workDate: 'DESC',
          createdAt: 'DESC',
        },
      });
    });
  });

  describe('findOne', () => {
    it('should return schedule by ID', async () => {
      const mockSchedule = {
        id: 'test-uuid',
        workDate: new Date('2026-01-30'),
        pattern: 'Rotasi',
        status: 'OPEN',
      } as Schedule;

      repository.findOne?.mockResolvedValue(mockSchedule);

      const result = await service.findOne('test-uuid');

      expect(result.id).toBe('test-uuid');
      expect(repository.findOne).toHaveBeenCalledWith({
        where: { id: 'test-uuid' },
      });
    });

    it('should throw NotFoundException for non-existent schedule', async () => {
      repository.findOne?.mockResolvedValue(null);

      await expect(service.findOne('non-existent-uuid')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('validateStatus', () => {
    it('should accept valid statuses', () => {
      VALID_STATUSES.forEach((status) => {
        expect(service.validateStatus(status)).toBe(true);
      });
    });

    it('should throw BadRequestException for invalid status', () => {
      expect(() => service.validateStatus('INVALID')).toThrow(
        BadRequestException,
      );
    });

    it('should throw BadRequestException for ASSIGNED status (not in production)', () => {
      expect(() => service.validateStatus('ASSIGNED')).toThrow(
        BadRequestException,
      );
    });

    it('should throw BadRequestException for IN_PROGRESS status (not in production)', () => {
      expect(() => service.validateStatus('IN_PROGRESS')).toThrow(
        BadRequestException,
      );
    });
  });

  describe('validateStatusTransition', () => {
    it('should allow OPEN to CLOSED', () => {
      expect(service.validateStatusTransition('OPEN', 'CLOSED')).toBe(true);
    });

    it('should allow OPEN to CANCEL', () => {
      expect(service.validateStatusTransition('OPEN', 'CANCEL')).toBe(true);
    });

    it('should reject CLOSED to OPEN', () => {
      expect(() => service.validateStatusTransition('CLOSED', 'OPEN')).toThrow(
        BadRequestException,
      );
    });

    it('should reject CANCEL to OPEN', () => {
      expect(() => service.validateStatusTransition('CANCEL', 'OPEN')).toThrow(
        BadRequestException,
      );
    });

    it('should reject CLOSED to CANCEL', () => {
      expect(() =>
        service.validateStatusTransition('CLOSED', 'CANCEL'),
      ).toThrow(BadRequestException);
    });
  });
});
