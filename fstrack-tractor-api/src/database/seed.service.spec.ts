import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { SeedService } from './seed.service';
import { User } from '../users/entities/user.entity';
import { UserRole } from '../users/enums/user-role.enum';

describe('SeedService', () => {
  let service: SeedService;
  let mockFindOne: jest.Mock;
  let mockCreate: jest.Mock;
  let mockSave: jest.Mock;
  let mockConfigGet: jest.Mock;

  const mockUser: Partial<User> = {
    id: 1,
    username: 'dev_kasie',
    fullName: 'Dev Kasie User',
    role: UserRole.KASIE,
    isFirstTime: true,
  };

  beforeEach(async () => {
    mockFindOne = jest.fn();
    mockCreate = jest.fn();
    mockSave = jest.fn();
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

    it('should NOT seed when environment is development', async () => {
      mockConfigGet.mockReturnValue('development');

      await service.onModuleInit();

      expect(mockFindOne).not.toHaveBeenCalled();
      expect(mockSave).not.toHaveBeenCalled();
    });

    it('should seed dev user when environment is staging', async () => {
      mockConfigGet.mockReturnValue('staging');
      mockFindOne.mockResolvedValue(null);
      mockCreate.mockReturnValue(mockUser as User);
      mockSave.mockResolvedValue(mockUser as User);

      await service.onModuleInit();

      expect(mockFindOne).toHaveBeenCalledWith({
        where: { username: 'dev_kasie' },
      });
      expect(mockCreate).toHaveBeenCalledWith(
        expect.objectContaining({
          username: 'dev_kasie',
          fullName: 'Dev Kasie User',
          role: UserRole.KASIE,
          isFirstTime: true,
        }),
      );
      expect(mockSave).toHaveBeenCalled();
    });

    it('should NOT seed if dev user already exists', async () => {
      mockConfigGet.mockReturnValue('staging');
      mockFindOne.mockResolvedValue(mockUser as User);

      await service.onModuleInit();

      expect(mockFindOne).toHaveBeenCalled();
      expect(mockCreate).not.toHaveBeenCalled();
      expect(mockSave).not.toHaveBeenCalled();
    });
  });
});
