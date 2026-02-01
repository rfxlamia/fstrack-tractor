import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  ParseIntPipe,
  ParseUUIDPipe,
  DefaultValuePipe,
  UsePipes,
  ValidationPipe,
  BadRequestException,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiQuery,
  ApiParam,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { plainToInstance } from 'class-transformer';
import { SchedulesService } from './schedules.service';
import { CreateScheduleDto, AssignOperatorDto } from './dto';
import {
  ScheduleResponseDto,
  PaginatedSchedulesResponseDto,
} from './dto/schedule-response.dto';
import { JwtAuthGuard, RolesGuard } from '../auth/guards';
import { Roles } from '../auth/decorators';

/**
 * Schedules Controller
 * Handles CRUD operations for work plans (schedules)
 *
 * Base path: /api/v1/schedules
 *
 * RBAC Rules:
 * - CREATE: KASIE_PG only (enforced via @Roles decorator)
 * - ASSIGN: KASIE_FE only (enforced via @Roles decorator)
 * - VIEW: All authenticated roles (no @Roles decorator on GET endpoints)
 */
@ApiTags('Schedules')
@ApiBearerAuth()
@Controller('api/v1/schedules')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SchedulesController {
  constructor(private readonly schedulesService: SchedulesService) {}

  /**
   * Create a new schedule
   * POST /api/v1/schedules
   *
   * RBAC: Only KASIE_PG can create schedules
   */
  @Post()
  @Roles('KASIE_PG')
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ValidationPipe({ transform: true }))
  @ApiOperation({ summary: 'Buat rencana kerja baru (KASIE_PG only)' })
  @ApiResponse({
    status: 201,
    description: 'Rencana kerja berhasil dibuat',
    type: ScheduleResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Validasi gagal',
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Hanya KASIE_PG yang bisa membuat rencana kerja',
  })
  async create(@Body() createScheduleDto: CreateScheduleDto) {
    const schedule = await this.schedulesService.create(createScheduleDto);

    return {
      statusCode: 201,
      message: 'Rencana kerja berhasil dibuat!',
      data: plainToInstance(ScheduleResponseDto, schedule, {
        excludeExtraneousValues: true,
      }),
    };
  }

  /**
   * Get all schedules with pagination
   * GET /api/v1/schedules?page=1&limit=10
   *
   * Pagination limits enforced:
   * - Max limit: 100 (prevents DoS)
   * - Min page: 1
   */
  @Get()
  @ApiOperation({ summary: 'Dapatkan daftar rencana kerja' })
  @ApiQuery({
    name: 'page',
    required: false,
    type: Number,
    description: 'Nomor halaman (minimal 1)',
    example: 1,
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    description: 'Jumlah item per halaman (maksimal 100)',
    example: 10,
  })
  @ApiResponse({
    status: 200,
    description: 'Daftar rencana kerja',
    type: PaginatedSchedulesResponseDto,
  })
  async findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number,
  ) {
    // Validate pagination bounds (prevent DoS attacks)
    if (page < 1) {
      throw new BadRequestException('Nomor halaman minimal 1');
    }
    if (limit < 1) {
      throw new BadRequestException('Limit minimal 1');
    }
    if (limit > 100) {
      throw new BadRequestException('Limit maksimal 100');
    }

    const result = await this.schedulesService.findAll({ page, limit });

    return {
      statusCode: 200,
      message: 'Daftar rencana kerja berhasil diambil',
      data: {
        ...result,
        data: result.data.map((schedule) =>
          plainToInstance(ScheduleResponseDto, schedule, {
            excludeExtraneousValues: true,
          }),
        ),
      },
    };
  }

  /**
   * Get a schedule by ID
   * GET /api/v1/schedules/:id
   *
   * UUID validation enforced via ParseUUIDPipe
   */
  @Get(':id')
  @ApiOperation({ summary: 'Dapatkan detail rencana kerja' })
  @ApiParam({
    name: 'id',
    description: 'ID schedule (UUID format)',
    example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  })
  @ApiResponse({
    status: 200,
    description: 'Detail rencana kerja',
    type: ScheduleResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Format UUID tidak valid',
  })
  @ApiResponse({
    status: 404,
    description: 'Rencana kerja tidak ditemukan',
  })
  async findOne(@Param('id', ParseUUIDPipe) id: string) {
    const schedule = await this.schedulesService.findOne(id);

    return {
      statusCode: 200,
      message: 'Detail rencana kerja berhasil diambil',
      data: plainToInstance(ScheduleResponseDto, schedule, {
        excludeExtraneousValues: true,
      }),
    };
  }

  /**
   * Assign an operator to a schedule
   * PATCH /api/v1/schedules/:id
   *
   * RBAC: Only KASIE_FE can assign operators
   * Changes schedule status from OPEN to CLOSED (production schema)
   */
  @Patch(':id')
  @Roles('KASIE_FE')
  @UsePipes(new ValidationPipe({ transform: true }))
  @ApiOperation({
    summary: 'Tugaskan operator ke rencana kerja (KASIE_FE only)',
  })
  @ApiParam({
    name: 'id',
    description: 'ID schedule (UUID format)',
    example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  })
  @ApiResponse({
    status: 200,
    description: 'Operator berhasil ditugaskan',
    type: ScheduleResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Validasi gagal atau schedule tidak dalam status OPEN',
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Hanya KASIE_FE yang bisa menugaskan operator',
  })
  @ApiResponse({
    status: 404,
    description: 'Rencana kerja tidak ditemukan',
  })
  async assignOperator(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() assignOperatorDto: AssignOperatorDto,
  ) {
    const schedule = await this.schedulesService.assignOperator(
      id,
      assignOperatorDto,
    );

    return {
      statusCode: 200,
      message: 'Operator berhasil ditugaskan!',
      data: plainToInstance(ScheduleResponseDto, schedule, {
        excludeExtraneousValues: true,
      }),
    };
  }

  /**
   * Cancel a schedule
   * PATCH /api/v1/schedules/:id/cancel
   *
   * RBAC: Both KASIE_PG and KASIE_FE can cancel schedules
   * Only schedules in OPEN status can be cancelled
   */
  @Patch(':id/cancel')
  @Roles('KASIE_PG', 'KASIE_FE')
  @UsePipes(new ValidationPipe({ transform: true }))
  @ApiOperation({ summary: 'Batalkan rencana kerja' })
  @ApiParam({
    name: 'id',
    description: 'ID schedule (UUID format)',
    example: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  })
  @ApiResponse({
    status: 200,
    description: 'Rencana kerja berhasil dibatalkan',
    type: ScheduleResponseDto,
  })
  @ApiResponse({
    status: 400,
    description:
      'Transisi status tidak valid (schedule tidak dalam status OPEN)',
  })
  @ApiResponse({
    status: 403,
    description:
      'Forbidden - Hanya KASIE_PG atau KASIE_FE yang bisa membatalkan',
  })
  @ApiResponse({
    status: 404,
    description: 'Rencana kerja tidak ditemukan',
  })
  async cancel(@Param('id', ParseUUIDPipe) id: string) {
    const schedule = await this.schedulesService.cancel(id);

    return {
      statusCode: 200,
      message: 'Rencana kerja berhasil dibatalkan!',
      data: plainToInstance(ScheduleResponseDto, schedule, {
        excludeExtraneousValues: true,
      }),
    };
  }
}
