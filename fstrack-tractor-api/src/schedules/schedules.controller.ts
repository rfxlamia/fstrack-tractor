import {
  Controller,
  Get,
  Post,
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
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiQuery,
  ApiParam,
} from '@nestjs/swagger';
import { plainToInstance } from 'class-transformer';
import { SchedulesService } from './schedules.service';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import {
  ScheduleResponseDto,
  PaginatedSchedulesResponseDto,
} from './dto/schedule-response.dto';

/**
 * Schedules Controller
 * Handles CRUD operations for work plans (schedules)
 *
 * Base path: /api/v1/schedules
 *
 * RBAC Rules:
 * - CREATE: kasie_pg only (enforced via @Roles decorator when auth enabled)
 * - VIEW: All roles (filtered by role in service layer)
 */
@ApiTags('Schedules')
@Controller('api/v1/schedules')
export class SchedulesController {
  constructor(private readonly schedulesService: SchedulesService) {}

  /**
   * Create a new schedule
   * POST /api/v1/schedules
   *
   * RBAC: @Roles('kasie_pg') - Uncomment when auth guard is enabled
   * Currently open for testing, must add role guard before production
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @UsePipes(new ValidationPipe({ transform: true }))
  // TODO: Add @Roles('kasie_pg') decorator when RolesGuard is configured
  // TODO: Add @UseGuards(JwtAuthGuard, RolesGuard) for RBAC enforcement
  @ApiOperation({ summary: 'Buat rencana kerja baru (kasie_pg only)' })
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
    description: 'Forbidden - Hanya kasie_pg yang bisa membuat rencana kerja',
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
}
