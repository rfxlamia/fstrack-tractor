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

  const mockQueryBuilder = {
    update: jest.fn().mockReturnThis(),
    set: jest.fn().mockReturnThis(),
    where: jest.fn().mockReturnThis(),
    execute: jest.fn(),
  };

  const mockRepository = {
    findOne: jest.fn(),
    update: jest.fn(),
    createQueryBuilder: jest.fn(() => mockQueryBuilder),
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

  describe('incrementFailedAttempts', () => {
    it('should increment failed login attempts atomically', async () => {
      mockQueryBuilder.execute.mockResolvedValue({ affected: 1 });
      mockRepository.findOne.mockResolvedValue({
        ...mockUser,
        failedLoginAttempts: 1,
      });

      const result = await service.incrementFailedAttempts(mockUser.id);

      expect(mockRepository.createQueryBuilder).toHaveBeenCalled();
      expect(mockQueryBuilder.update).toHaveBeenCalledWith(User);
      expect(mockQueryBuilder.set).toHaveBeenCalledWith({
        failedLoginAttempts: expect.any(Function),
      });
      expect(mockQueryBuilder.where).toHaveBeenCalledWith('id = :id', {
        id: mockUser.id,
      });
      expect(mockQueryBuilder.execute).toHaveBeenCalled();
      expect(result).toBe(1);
    });

    it('should return 0 when user not found after increment', async () => {
      mockQueryBuilder.execute.mockResolvedValue({ affected: 1 });
      mockRepository.findOne.mockResolvedValue(null);

      const result = await service.incrementFailedAttempts(mockUser.id);

      expect(result).toBe(0);
    });
  });

  describe('resetFailedAttempts', () => {
    it('should reset failed attempts and clear lockedUntil', async () => {
      mockRepository.update.mockResolvedValue({
        affected: 1,
        raw: {},
        generatedMaps: [],
      });

      await service.resetFailedAttempts(mockUser.id);

      expect(mockRepository.update).toHaveBeenCalledWith(mockUser.id, {
        failedLoginAttempts: 0,
        lockedUntil: null,
      });
    });

    it('should not throw when resetting non-existent user', async () => {
      mockRepository.update.mockResolvedValue({
        affected: 0,
        raw: {},
        generatedMaps: [],
      });

      await expect(
        service.resetFailedAttempts('non-existent-id'),
      ).resolves.not.toThrow();
    });
  });

  describe('lockAccount', () => {
    it('should set lockedUntil to 30 minutes from now', async () => {
      mockRepository.update.mockResolvedValue({
        affected: 1,
        raw: {},
        generatedMaps: [],
      });

      const beforeLock = Date.now();
      await service.lockAccount(mockUser.id);

      expect(mockRepository.update).toHaveBeenCalledWith(
        mockUser.id,
        expect.objectContaining({
          lockedUntil: expect.any(Date),
        }),
      );

      const updateCall = mockRepository.update.mock.calls[0] as [
        string,
        { lockedUntil: Date },
      ];
      const lockUntil = updateCall[1].lockedUntil;
      const expectedMinTime = new Date(beforeLock + 29 * 60 * 1000);
      const expectedMaxTime = new Date(beforeLock + 31 * 60 * 1000);
      expect(lockUntil.getTime()).toBeGreaterThanOrEqual(
        expectedMinTime.getTime(),
      );
      expect(lockUntil.getTime()).toBeLessThanOrEqual(
        expectedMaxTime.getTime(),
      );
    });

    it('should not throw when locking non-existent user', async () => {
      mockRepository.update.mockResolvedValue({
        affected: 0,
        raw: {},
        generatedMaps: [],
      });

      await expect(
        service.lockAccount('non-existent-id'),
      ).resolves.not.toThrow();
    });
  });

  describe('clearExpiredLockout', () => {
    it('should reset failed attempts and clear lockedUntil', async () => {
      mockRepository.update.mockResolvedValue({
        affected: 1,
        raw: {},
        generatedMaps: [],
      });

      await service.clearExpiredLockout(mockUser.id);

      expect(mockRepository.update).toHaveBeenCalledWith(mockUser.id, {
        failedLoginAttempts: 0,
        lockedUntil: null,
      });
    });

    it('should not throw when clearing non-existent user', async () => {
      mockRepository.update.mockResolvedValue({
        affected: 0,
        raw: {},
        generatedMaps: [],
      });

      await expect(
        service.clearExpiredLockout('non-existent-id'),
      ).resolves.not.toThrow();
    });
  });
});
