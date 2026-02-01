import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { OperatorsService } from './operators.service';
import { OperatorResponseDto } from './dto/operator-response.dto';
import { JwtAuthGuard, RolesGuard } from '../auth/guards';
import { Roles } from '../auth/decorators';

/**
 * Operators Controller
 * Handles operator-related endpoints
 *
 * Base path: /api/v1/operators
 *
 * RBAC Rules:
 * - LIST: KASIE_FE only (for assignment purposes)
 * - Other roles may be added later for viewing
 */
@ApiTags('Operators')
@ApiBearerAuth()
@Controller('api/v1/operators')
@UseGuards(JwtAuthGuard, RolesGuard)
export class OperatorsController {
  constructor(private readonly operatorsService: OperatorsService) {}

  /**
   * Get all operators with user names
   * GET /api/v1/operators
   *
   * Returns list of active operators sorted alphabetically by name.
   * Each operator includes id, operatorName (from user.fullname), and unitId.
   *
   * RBAC: Only KASIE_FE can access this endpoint
   */
  @Get()
  @Roles('KASIE_FE')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Dapatkan daftar operator (KASIE_FE only)' })
  @ApiResponse({
    status: 200,
    description: 'Daftar operator berhasil diambil',
    type: [OperatorResponseDto],
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Hanya KASIE_FE yang bisa melihat daftar operator',
  })
  async findAll(): Promise<{
    statusCode: number;
    message: string;
    data: OperatorResponseDto[];
  }> {
    const operators = await this.operatorsService.findAll();

    return {
      statusCode: 200,
      message: 'Daftar operator berhasil diambil',
      data: operators,
    };
  }
}
