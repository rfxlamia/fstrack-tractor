import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { SeedService } from './seed.service';
import { User } from '../users/entities/user.entity';

describe('SeedService', () => {
  let service: SeedService;
  let mockFindOne: jest.Mock;
  let mockCreate: jest.Mock;
  let mockSave: jest.Mock;
  let mockDelete: jest.Mock;
  let mockConfigGet: jest.Mock;

  const mockUser: Partial<User> = {
    id: 1,
    username: 'dev_kasie_pg',
    fullname: 'Dev Kasie PG User',
    roleId: 'KASIE_PG',
    isFirstTime: true,
  };

  beforeEach(async () => {
    mockFindOne = jest.fn();
    mockCreate = jest.fn();
    mockSave = jest.fn();
    mockDelete = jest.fn();
    mockConfigGet = jest.fn();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SeedService,
        {
          provide: getRepositoryToken(User),
          useValue: {
            findOne: mockFindOne,
            create: mockCreate,
            save: mockSave,
            delete: mockDelete,
          },
        },
        {
          provide: ConfigService,
          useValue: {
            get: mockConfigGet,
          },
        },
      ],
    }).compile();

    service = module.get<SeedService>(SeedService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('onModuleInit', () => {
    it('should NOT seed when environment is not staging', async () => {
      mockConfigGet.mockReturnValue('production');

      await service.onModuleInit();

      expect(mockFindOne).not.toHaveBeenCalled();
      expect(mockSave).not.toHaveBeenCalled();
    });

    it('should seed when environment is development', async () => {
      mockConfigGet.mockReturnValue('development');
      mockFindOne.mockResolvedValue(null);
      mockCreate.mockReturnValue(mockUser as User);
      mockSave.mockResolvedValue(mockUser as User);

      await service.onModuleInit();

      // Should check for old dev_kasie user and seed new users
      expect(mockFindOne).toHaveBeenCalledWith({
        where: { username: 'dev_kasie' },
      });
      expect(mockCreate).toHaveBeenCalledTimes(3);
      expect(mockSave).toHaveBeenCalledTimes(3);
    });

    it('should seed dev user when environment is staging', async () => {
      mockConfigGet.mockReturnValue('staging');
      mockFindOne.mockResolvedValue(null);
      mockCreate.mockReturnValue(mockUser as User);
      mockSave.mockResolvedValue(mockUser as User);

      await service.onModuleInit();

      // Should check for old dev_kasie user first
      expect(mockFindOne).toHaveBeenCalledWith({
        where: { username: 'dev_kasie' },
      });

      // Should create 3 new dev users
      expect(mockCreate).toHaveBeenCalledTimes(3);
      expect(mockSave).toHaveBeenCalledTimes(3);
    });

    it('should NOT seed if dev user already exists', async () => {
      mockConfigGet.mockReturnValue('staging');
      // First call returns old dev_kasie, then all subsequent calls return null
      mockFindOne
        .mockResolvedValueOnce(mockUser as User)
        .mockResolvedValue(null);
      mockCreate.mockReturnValue(mockUser as User);
      mockDelete.mockResolvedValue({ affected: 1 });

      await service.onModuleInit();

      // Should find old user and delete it
      expect(mockFindOne).toHaveBeenCalledWith({
        where: { username: 'dev_kasie' },
      });

      // Should create 3 new users after deletion
      expect(mockCreate).toHaveBeenCalledTimes(3);
      expect(mockSave).toHaveBeenCalledTimes(3);
    });
  });
});
