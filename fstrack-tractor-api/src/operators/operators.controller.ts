import { Controller, Get, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { OperatorsService } from './operators.service';
import { OperatorResponseDto } from './dto/operator-response.dto';

/**
 * Operators Controller
 * Handles operator-related endpoints
 *
 * Base path: /api/v1/operators
 *
 * RBAC Rules:
 * - LIST: kasie_fe only (for assignment purposes)
 * - Other roles may be added later for viewing
 */
@ApiTags('Operators')
@Controller('api/v1/operators')
export class OperatorsController {
  constructor(private readonly operatorsService: OperatorsService) {}

  /**
   * Get all operators with user names
   * GET /api/v1/operators
   *
   * Returns list of active operators sorted alphabetically by name.
   * Each operator includes id, operatorName (from user.fullname), and unitId.
   *
   * RBAC: @Roles('kasie_fe') - Uncomment when auth guard is enabled
   * Currently open for testing, must add role guard before production
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  // TODO: Add @Roles('kasie_fe') decorator when RolesGuard is configured
  // TODO: Add @UseGuards(JwtAuthGuard, RolesGuard) for RBAC enforcement
  @ApiOperation({ summary: 'Dapatkan daftar operator (kasie_fe only)' })
  @ApiResponse({
    status: 200,
    description: 'Daftar operator berhasil diambil',
    type: [OperatorResponseDto],
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden - Hanya kasie_fe yang bisa melihat daftar operator',
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
