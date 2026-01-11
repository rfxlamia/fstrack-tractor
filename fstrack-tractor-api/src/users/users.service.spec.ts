/* eslint-disable @typescript-eslint/no-unsafe-assignment */
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { UsersService } from './users.service';
import { User } from './entities/user.entity';
import { UserRole } from './enums/user-role.enum';

interface MockUpdateCall {
  lastLogin: Date;
}

describe('UsersService', () => {
  let service: UsersService;

  const mockUser: User = {
    id: '123e4567-e89b-12d3-a456-426614174000',
    username: 'dev_kasie',
    passwordHash: '$2b$10$abcdefghijklmnopqrstuv',
    fullName: 'Dev Kasie User',
    role: UserRole.KASIE,
    estateId: null,
    isFirstTime: true,
    failedLoginAttempts: 0,
    lockedUntil: null,
    lastLogin: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockRepository = {
    findOne: jest.fn(),
    update: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: getRepositoryToken(User),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);

    // Reset mocks before each test
    jest.clearAllMocks();
  });

  describe('findByUsername', () => {
    it('should return a user when found', async () => {
      mockRepository.findOne.mockResolvedValue(mockUser);

      const result = await service.findByUsername('dev_kasie');

      expect(result).toEqual(mockUser);
      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { username: 'dev_kasie' },
      });
    });

    it('should return null when user not found', async () => {
      mockRepository.findOne.mockResolvedValue(null);

      const result = await service.findByUsername('nonexistent');

      expect(result).toBeNull();
      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { username: 'nonexistent' },
      });
    });
  });

  describe('findById', () => {
    it('should return a user when found', async () => {
      mockRepository.findOne.mockResolvedValue(mockUser);

      const result = await service.findById(mockUser.id);

      expect(result).toEqual(mockUser);
      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: mockUser.id },
      });
    });

    it('should return null when user not found', async () => {
      mockRepository.findOne.mockResolvedValue(null);

      const result = await service.findById('nonexistent-id');

      expect(result).toBeNull();
      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: 'nonexistent-id' },
      });
    });
  });

  describe('updateFirstTime', () => {
    it('should update isFirstTime to false', async () => {
      mockRepository.update.mockResolvedValue({
        affected: 1,
        raw: {},
        generatedMaps: [],
      });

      await service.updateFirstTime(mockUser.id, false);

      expect(mockRepository.update).toHaveBeenCalledWith(mockUser.id, {
        isFirstTime: false,
      });
    });

    it('should update isFirstTime to true', async () => {
      mockRepository.update.mockResolvedValue({
        affected: 1,
        raw: {},
        generatedMaps: [],
      });

      await service.updateFirstTime(mockUser.id, true);

      expect(mockRepository.update).toHaveBeenCalledWith(mockUser.id, {
        isFirstTime: true,
      });
    });

    it('should not throw when updating non-existent user', async () => {
      mockRepository.update.mockResolvedValue({
        affected: 0,
        raw: {},
        generatedMaps: [],
      });

      await expect(
        service.updateFirstTime('non-existent-id', false),
      ).resolves.not.toThrow();
      expect(mockRepository.update).toHaveBeenCalledWith('non-existent-id', {
        isFirstTime: false,
      });
    });
  });

  describe('updateLastLogin', () => {
    it('should update lastLogin timestamp', async () => {
      const beforeTest = new Date();
      mockRepository.update.mockResolvedValue({
        affected: 1,
        raw: {},
        generatedMaps: [],
      });

      await service.updateLastLogin(mockUser.id);

      expect(mockRepository.update).toHaveBeenCalledWith(
        mockUser.id,
        expect.objectContaining({
          lastLogin: expect.any(Date),
        }),
      );

      const updateCall = mockRepository.update.mock.calls[0] as [
        string,
        MockUpdateCall,
      ];
      const passedDate = updateCall[1].lastLogin;
      expect(passedDate.getTime()).toBeGreaterThanOrEqual(beforeTest.getTime());
    });

    it('should not throw when updating non-existent user', async () => {
      mockRepository.update.mockResolvedValue({
        affected: 0,
        raw: {},
        generatedMaps: [],
      });

      await expect(
        service.updateLastLogin('non-existent-id'),
      ).resolves.not.toThrow();
    });
  });
});
