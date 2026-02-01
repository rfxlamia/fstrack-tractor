import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { plainToClass } from 'class-transformer';
import { Operator } from './entities/operator.entity';
import { OperatorResponseDto } from './dto/operator-response.dto';

/**
 * Operators Service
 * Handles business logic for operator management
 *
 * Key responsibilities:
 * - Fetch operators with user join for names
 * - Sort operators alphabetically by user fullname
 * - Handle edge cases (null user, empty list)
 */
@Injectable()
export class OperatorsService {
  private readonly logger = new Logger(OperatorsService.name);

  constructor(
    @InjectRepository(Operator)
    private readonly operatorRepository: Repository<Operator>,
  ) {}

  /**
   * Find all operators with user names
   * Returns operators sorted alphabetically by user fullname ASC
   *
   * Edge cases handled:
   * - Operator without user: returns operatorName as "Unknown"
   * - Empty list: returns empty array (not 404)
   *
   * @returns Array of OperatorResponseDto sorted by operatorName ASC
   */
  async findAll(): Promise<OperatorResponseDto[]> {
    const operators = await this.operatorRepository.find({
      relations: ['user'],
      order: {
        user: {
          fullname: 'ASC',
        },
      },
    });

    // Transform to DTO with proper handling of null users
    return operators.map((operator) => {
      // Log warning if operator has no associated user
      if (!operator.user) {
        this.logger.warn(`Operator without user: operatorId=${operator.id}`);
      }

      return plainToClass(OperatorResponseDto, {
        id: operator.id,
        operatorName: operator.user?.fullname || 'Unknown',
        unitId: operator.unitId,
      });
    });
  }
}
