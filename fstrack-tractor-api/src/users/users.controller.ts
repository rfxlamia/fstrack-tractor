import { Body, Controller, Patch, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { UpdateFirstTimeDto } from './dto/update-first-time.dto';
import { UsersService } from './users.service';

@ApiTags('users')
@Controller('v1/users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Patch('me/first-time')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update first-time user status' })
  @ApiResponse({ status: 200, description: 'Status updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid request body' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateFirstTimeStatus(
    @CurrentUser() user: { id: number },
    @Body() dto: UpdateFirstTimeDto,
  ) {
    await this.usersService.updateFirstTime(user.id, dto.isFirstTime);
    return {
      statusCode: 200,
      message: 'Status updated',
      data: { success: true },
    };
  }
}
