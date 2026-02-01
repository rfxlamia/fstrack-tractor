import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException, BadRequestException } from '@nestjs/common';
import { SchedulesController } from './schedules.controller';
import { SchedulesService } from './schedules.service';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import { Schedule } from './entities/schedule.entity';

describe('SchedulesController', () => {
  let controller: SchedulesController;
  let service: {
    create: jest.Mock;
    findAll: jest.Mock;
    findOne: jest.Mock;
  };

  const mockSchedulesService: {
    create: jest.Mock;
    findAll: jest.Mock;
    findOne: jest.Mock;
  } = {
    create: jest.fn(),
    findAll: jest.fn(),
    findOne: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [SchedulesController],
      providers: [
        {
          provide: SchedulesService,
          useValue: mockSchedulesService,
        },
      ],
    }).compile();

    controller = module.get<SchedulesController>(SchedulesController);
    service = module.get<typeof mockSchedulesService>(SchedulesService);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('POST /api/v1/schedules', () => {
    const validCreateDto: CreateScheduleDto = {
      workDate: '2026-01-30',
      pattern: 'Rotasi',
      shift: 'Pagi',
      locationId: 'LOC001',
      unitId: 'UNIT01',
      operatorId: 123,
      notes: 'Test notes',
    };

    it('should return 201 with created schedule data', async () => {
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
        startTime: null,
        endTime: null,
        reportId: null,
        createdAt: new Date('2026-01-30T08:30:00.000Z'),
        updatedAt: new Date('2026-01-30T08:30:00.000Z'),
      } as Schedule;

      service.create.mockResolvedValue(mockSchedule);

      const result = await controller.create(validCreateDto);

      expect(result.statusCode).toBe(201);
      expect(result.message).toBe('Rencana kerja berhasil dibuat!');
      expect(result.data).toBeDefined();
      expect(result.data.id).toBe('test-uuid');
      expect(result.data.status).toBe('OPEN');
      expect(service.create).toHaveBeenCalledWith(validCreateDto);
    });

    it('should handle minimal create DTO', async () => {
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
        startTime: null,
        endTime: null,
        reportId: null,
        createdAt: new Date(),
        updatedAt: new Date(),
      } as Schedule;

      service.create.mockResolvedValue(mockSchedule);

      const result = await controller.create(minimalDto);

      expect(result.statusCode).toBe(201);
      expect(result.data.pattern).toBe('Rotasi');
    });
  });

  describe('GET /api/v1/schedules', () => {
    it('should return paginated list with default pagination', async () => {
      const mockSchedules: Schedule[] = [
        {
          id: 'uuid-1',
          workDate: new Date('2026-01-30'),
          pattern: 'Rotasi',
          status: 'OPEN',
          createdAt: new Date(),
          updatedAt: new Date(),
        } as Schedule,
        {
          id: 'uuid-2',
          workDate: new Date('2026-01-29'),
          pattern: 'Non-Rotasi',
          status: 'CLOSED',
          createdAt: new Date(),
          updatedAt: new Date(),
        } as Schedule,
      ];

      service.findAll.mockResolvedValue({
        data: mockSchedules,
        total: 2,
        page: 1,
        limit: 10,
        totalPages: 1,
      });

      const result = await controller.findAll(1, 10);

      expect(result.statusCode).toBe(200);
      expect(result.message).toBe('Daftar rencana kerja berhasil diambil');
      expect(result.data.data).toHaveLength(2);
      expect(result.data.total).toBe(2);
      expect(result.data.page).toBe(1);
      expect(result.data.limit).toBe(10);
      expect(service.findAll).toHaveBeenCalledWith({ page: 1, limit: 10 });
    });

    it('should handle custom pagination params', async () => {
      service.findAll.mockResolvedValue({
        data: [],
        total: 100,
        page: 2,
        limit: 20,
        totalPages: 5,
      });

      const result = await controller.findAll(2, 20);

      expect(result.data.page).toBe(2);
      expect(result.data.limit).toBe(20);
      expect(result.data.totalPages).toBe(5);
      expect(service.findAll).toHaveBeenCalledWith({ page: 2, limit: 20 });
    });

    it('should throw BadRequestException for page < 1', async () => {
      await expect(controller.findAll(0, 10)).rejects.toThrow(
        BadRequestException,
      );
      await expect(controller.findAll(0, 10)).rejects.toThrow(
        'Nomor halaman minimal 1',
      );
    });

    it('should throw BadRequestException for limit < 1', async () => {
      await expect(controller.findAll(1, 0)).rejects.toThrow(
        BadRequestException,
      );
      await expect(controller.findAll(1, 0)).rejects.toThrow('Limit minimal 1');
    });

    it('should throw BadRequestException for limit > 100', async () => {
      await expect(controller.findAll(1, 101)).rejects.toThrow(
        BadRequestException,
      );
      await expect(controller.findAll(1, 101)).rejects.toThrow(
        'Limit maksimal 100',
      );
    });

    it('should serialize schedule data correctly', async () => {
      const mockSchedule = {
        id: 'uuid-1',
        workDate: new Date('2026-01-30'),
        pattern: 'Rotasi',
        shift: 'Pagi',
        locationId: 'LOC001',
        unitId: 'UNIT01',
        operatorId: 123,
        status: 'OPEN',
        startTime: null,
        endTime: null,
        notes: 'Test notes',
        reportId: null,
        createdAt: new Date('2026-01-30T08:30:00.000Z'),
        updatedAt: new Date('2026-01-30T08:30:00.000Z'),
      } as Schedule;

      service.findAll.mockResolvedValue({
        data: [mockSchedule],
        total: 1,
        page: 1,
        limit: 10,
        totalPages: 1,
      });

      const result = await controller.findAll(1, 10);

      const firstItem = result.data.data[0];
      expect(firstItem.id).toBe('uuid-1');
      expect(firstItem.pattern).toBe('Rotasi');
      expect(firstItem.locationId).toBe('LOC001');
      expect(firstItem.unitId).toBe('UNIT01');
      expect(firstItem.operatorId).toBe(123);
      expect(firstItem.status).toBe('OPEN');
    });
  });

  describe('GET /api/v1/schedules/:id', () => {
    it('should return 200 with schedule details', async () => {
      const mockSchedule = {
        id: 'test-uuid',
        workDate: new Date('2026-01-30'),
        pattern: 'Rotasi',
        shift: 'Pagi',
        locationId: 'LOC001',
        unitId: 'UNIT01',
        operatorId: 123,
        status: 'OPEN',
        startTime: null,
        endTime: null,
        notes: 'Test notes',
        reportId: null,
        createdAt: new Date('2026-01-30T08:30:00.000Z'),
        updatedAt: new Date('2026-01-30T08:30:00.000Z'),
      } as Schedule;

      service.findOne.mockResolvedValue(mockSchedule);

      const result = await controller.findOne('test-uuid');

      expect(result.statusCode).toBe(200);
      expect(result.message).toBe('Detail rencana kerja berhasil diambil');
      expect(result.data.id).toBe('test-uuid');
      expect(service.findOne).toHaveBeenCalledWith('test-uuid');
    });

    it('should propagate NotFoundException from service', async () => {
      service.findOne.mockRejectedValue(
        new NotFoundException('Rencana kerja tidak ditemukan'),
      );

      await expect(controller.findOne('non-existent')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should return correct types for VARCHAR fields', async () => {
      const mockSchedule = {
        id: 'test-uuid',
        workDate: new Date('2026-01-30'),
        pattern: 'Rotasi',
        locationId: 'LOC001', // VARCHAR, not UUID
        unitId: 'UNIT01', // VARCHAR, not UUID
        operatorId: 123, // INTEGER, not UUID
        status: 'OPEN',
        createdAt: new Date(),
        updatedAt: new Date(),
      } as Schedule;

      service.findOne.mockResolvedValue(mockSchedule);

      const result = await controller.findOne('test-uuid');

      expect(typeof result.data.locationId).toBe('string');
      expect(typeof result.data.unitId).toBe('string');
      expect(typeof result.data.operatorId).toBe('number');
      expect(result.data.locationId).toBe('LOC001');
      expect(result.data.unitId).toBe('UNIT01');
      expect(result.data.operatorId).toBe(123);
    });
  });
});
