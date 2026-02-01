import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Schedule } from './entities/schedule.entity';
import { CreateScheduleDto } from './dto/create-schedule.dto';

/**
 * Valid status values from production schema
 */
export const VALID_STATUSES = ['OPEN', 'CLOSED', 'CANCEL'] as const;
export type ScheduleStatus = (typeof VALID_STATUSES)[number];

/**
 * Valid state transitions
 */
const VALID_TRANSITIONS: Record<ScheduleStatus, ScheduleStatus[]> = {
  OPEN: ['CLOSED', 'CANCEL'],
  CLOSED: [],
  CANCEL: [],
};

/**
 * Pagination options interface
 */
export interface PaginationOptions {
  page: number;
  limit: number;
}

/**
 * Paginated result interface
 */
export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

@Injectable()
export class SchedulesService {
  private readonly logger = new Logger(SchedulesService.name);

  constructor(
    @InjectRepository(Schedule)
    private readonly scheduleRepository: Repository<Schedule>,
  ) {}

  /**
   * Create a new schedule
   * Status defaults to 'OPEN' as per production schema
   *
   * @param createScheduleDto - Schedule data
   * @returns Created schedule
   */
  async create(createScheduleDto: CreateScheduleDto): Promise<Schedule> {
    // Validate operatorId is integer if provided
    if (createScheduleDto.operatorId !== undefined) {
      if (!Number.isInteger(createScheduleDto.operatorId)) {
        throw new BadRequestException('ID operator harus berupa angka bulat');
      }
    }

    // Create schedule entity
    const schedule = this.scheduleRepository.create({
      workDate: new Date(createScheduleDto.workDate),
      pattern: createScheduleDto.pattern,
      shift: createScheduleDto.shift,
      locationId: createScheduleDto.locationId,
      unitId: createScheduleDto.unitId,
      operatorId: createScheduleDto.operatorId,
      notes: createScheduleDto.notes,
      status: 'OPEN', // Default status as per production schema
    });

    const savedSchedule = await this.scheduleRepository.save(schedule);
    this.logger.log(`Schedule created: ${savedSchedule.id}`);

    return savedSchedule;
  }

  /**
   * Find all schedules with pagination
   *
   * @param options - Pagination options (page, limit)
   * @returns Paginated schedules ordered by workDate DESC, createdAt DESC
   */
  async findAll(
    options: PaginationOptions,
  ): Promise<PaginatedResult<Schedule>> {
    const { page, limit } = options;
    const skip = (page - 1) * limit;

    const [data, total] = await this.scheduleRepository.findAndCount({
      skip,
      take: limit,
      order: {
        workDate: 'DESC',
        createdAt: 'DESC',
      },
    });

    const totalPages = Math.ceil(total / limit);

    return {
      data,
      total,
      page,
      limit,
      totalPages,
    };
  }

  /**
   * Find a schedule by ID
   *
   * @param id - Schedule UUID (validated by controller ParseUUIDPipe)
   * @returns Schedule entity
   * @throws NotFoundException if schedule not found
   */
  async findOne(id: string): Promise<Schedule> {
    const schedule = await this.scheduleRepository.findOne({
      where: { id },
    });

    if (!schedule) {
      throw new NotFoundException(
        `Rencana kerja dengan ID ${id} tidak ditemukan`,
      );
    }

    return schedule;
  }

  /**
   * Validate status value
   *
   * @param status - Status to validate
   * @returns true if valid
   * @throws BadRequestException if invalid
   */
  validateStatus(status: string): boolean {
    if (!VALID_STATUSES.includes(status as ScheduleStatus)) {
      throw new BadRequestException(
        `Status tidak valid. Status yang diperbolehkan: ${VALID_STATUSES.join(', ')}`,
      );
    }
    return true;
  }

  /**
   * Validate state transition
   *
   * @param currentStatus - Current status
   * @param newStatus - New status
   * @returns true if transition is valid
   * @throws BadRequestException if transition is invalid
   */
  validateStatusTransition(
    currentStatus: ScheduleStatus,
    newStatus: ScheduleStatus,
  ): boolean {
    const allowedTransitions = VALID_TRANSITIONS[currentStatus];

    if (!allowedTransitions.includes(newStatus)) {
      throw new BadRequestException(
        `Transisi status tidak valid dari ${currentStatus} ke ${newStatus}`,
      );
    }

    return true;
  }
}
