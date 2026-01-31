/* eslint-disable @typescript-eslint/unbound-method */
import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { UpdateFirstTimeDto } from './dto/update-first-time.dto';

describe('UsersController', () => {
  let controller: UsersController;
  let usersService: jest.Mocked<UsersService>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [
        {
          provide: UsersService,
          useValue: {
            updateFirstTime: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<UsersController>(UsersController);
    usersService = module.get(UsersService);
    jest.clearAllMocks();
  });

  describe('updateFirstTimeStatus', () => {
    it('should return 200 response payload on success', async () => {
      usersService.updateFirstTime.mockResolvedValue();

      const user = { id: 1 };
      const dto: UpdateFirstTimeDto = { isFirstTime: false };

      const result = await controller.updateFirstTimeStatus(user, dto);

      expect(result).toEqual({
        statusCode: 200,
        message: 'Status updated',
        data: { success: true },
      });
    });

    it('should call usersService.updateFirstTime with correct params', async () => {
      usersService.updateFirstTime.mockResolvedValue();

      const user = { id: 1 };
      const dto: UpdateFirstTimeDto = { isFirstTime: false };

      await controller.updateFirstTimeStatus(user, dto);

      expect(usersService.updateFirstTime).toHaveBeenCalledWith(
        user.id,
        dto.isFirstTime,
      );
    });

    it('should propagate error when service throws', async () => {
      const error = new Error('Database connection failed');
      usersService.updateFirstTime.mockRejectedValue(error);

      const user = { id: 1 };
      const dto: UpdateFirstTimeDto = { isFirstTime: false };

      await expect(controller.updateFirstTimeStatus(user, dto)).rejects.toThrow(
        'Database connection failed',
      );
    });
  });
});
