import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Schedule } from './entities/schedule.entity';
import { Operator } from '../operators/entities/operator.entity';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import { AssignOperatorDto } from './dto/assign-operator.dto';

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
    @InjectRepository(Operator)
    private readonly operatorRepository: Repository<Operator>,
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

  /**
   * Assign an operator to a schedule
   * Changes status from OPEN to CLOSED (production schema behavior)
   *
   * @param id - Schedule UUID
   * @param assignOperatorDto - Contains operatorId (INTEGER)
   * @returns Updated schedule
   * @throws NotFoundException if schedule not found
   * @throws NotFoundException if operator not found
   * @throws BadRequestException if schedule is not in OPEN status
   */
  async assignOperator(
    id: string,
    assignOperatorDto: AssignOperatorDto,
  ): Promise<Schedule> {
    const schedule = await this.findOne(id);

    // Validate schedule is in OPEN status (can be assigned)
    if (schedule.status !== 'OPEN') {
      throw new BadRequestException(
        `Tidak dapat menugaskan operator. Status schedule harus OPEN, saat ini: ${schedule.status}`,
      );
    }

    // Validate operator exists
    const operator = await this.operatorRepository.findOne({
      where: { id: assignOperatorDto.operatorId },
    });

    if (!operator) {
      throw new NotFoundException(
        `Operator dengan ID ${assignOperatorDto.operatorId} tidak ditemukan`,
      );
    }

    // Update schedule with operator and change status to CLOSED
    schedule.operatorId = assignOperatorDto.operatorId;
    schedule.status = 'CLOSED'; // Production schema: CLOSED means assigned

    const updatedSchedule = await this.scheduleRepository.save(schedule);
    this.logger.log(
      `Operator assigned to schedule ${id}: operatorId=${assignOperatorDto.operatorId}`,
    );

    return updatedSchedule;
  }

  /**
   * Cancel a schedule
   * Changes status from OPEN to CANCEL (cancellation always allowed from OPEN)
   *
   * @param id - Schedule UUID
   * @returns Cancelled schedule
   * @throws NotFoundException if schedule not found
   * @throws BadRequestException if schedule is not in OPEN status
   */
  async cancel(id: string): Promise<Schedule> {
    const schedule = await this.findOne(id);

    // Validate status transition using state machine
    // Note: validateStatusTransition throws BadRequestException if invalid
    this.validateStatusTransition(schedule.status as ScheduleStatus, 'CANCEL');

    schedule.status = 'CANCEL';

    const cancelledSchedule = await this.scheduleRepository.save(schedule);
    this.logger.log(`Schedule cancelled: ${id}`);

    return cancelledSchedule;
  }
}
