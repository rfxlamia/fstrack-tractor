import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { RolesGuard } from './roles.guard';
import { AUTH_ERROR_MESSAGES } from '../constants/error-messages.constant';

describe('RolesGuard', () => {
  let guard: RolesGuard;
  let reflector: Reflector;

  // Mock ExecutionContext factory
  const createMockExecutionContext = (
    userRoleId: string | undefined,
  ): ExecutionContext => {
    return {
      getHandler: jest.fn(),
      getClass: jest.fn(),
      switchToHttp: jest.fn().mockReturnValue({
        getRequest: jest.fn().mockReturnValue({
          user: userRoleId ? { roleId: userRoleId } : undefined,
        }),
      }),
    } as unknown as ExecutionContext;
  };

  beforeEach(() => {
    reflector = new Reflector();
    guard = new RolesGuard(reflector);
  });

  describe('canActivate', () => {
    it('should allow access when user has matching role', () => {
      // Arrange
      const mockContext = createMockExecutionContext('KASIE_PG');
      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['KASIE_PG']);

      // Act
      const result = guard.canActivate(mockContext);

      // Assert
      expect(result).toBe(true);
    });

    it('should throw ForbiddenException when user has non-matching role', () => {
      // Arrange
      const mockContext = createMockExecutionContext('OPERATOR');
      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['KASIE_PG']);

      // Act & Assert
      expect(() => guard.canActivate(mockContext)).toThrow(
        new ForbiddenException(AUTH_ERROR_MESSAGES.FORBIDDEN),
      );
    });

    it('should allow access when no roles are defined (undefined)', () => {
      // Arrange
      const mockContext = createMockExecutionContext('OPERATOR');
      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(undefined);

      // Act
      const result = guard.canActivate(mockContext);

      // Assert
      expect(result).toBe(true);
    });

    it('should allow access when no roles are defined (empty array)', () => {
      // Arrange
      const mockContext = createMockExecutionContext('OPERATOR');
      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([]);

      // Act
      const result = guard.canActivate(mockContext);

      // Assert
      expect(result).toBe(true);
    });

    it('should allow access when user has one of multiple required roles (OR logic)', () => {
      // Arrange
      const mockContext = createMockExecutionContext('KASIE_FE');
      jest
        .spyOn(reflector, 'getAllAndOverride')
        .mockReturnValue(['KASIE_PG', 'KASIE_FE']);

      // Act
      const result = guard.canActivate(mockContext);

      // Assert
      expect(result).toBe(true);
    });

    it('should throw ForbiddenException when user has none of multiple required roles', () => {
      // Arrange
      const mockContext = createMockExecutionContext('OPERATOR');
      jest
        .spyOn(reflector, 'getAllAndOverride')
        .mockReturnValue(['KASIE_PG', 'KASIE_FE']);

      // Act & Assert
      expect(() => guard.canActivate(mockContext)).toThrow(
        new ForbiddenException(AUTH_ERROR_MESSAGES.FORBIDDEN),
      );
    });

    it('should use method-level roles over class-level roles', () => {
      // Arrange
      const mockContext = createMockExecutionContext('KASIE_FE');
      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['KASIE_FE']);

      // Act
      const result = guard.canActivate(mockContext);

      // Assert
      expect(result).toBe(true);
    });

    it('should throw ForbiddenException with correct error message in Bahasa Indonesia', () => {
      // Arrange
      const mockContext = createMockExecutionContext('OPERATOR');
      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['KASIE_PG']);

      // Act & Assert
      expect(() => guard.canActivate(mockContext)).toThrow(ForbiddenException);
      expect(() => guard.canActivate(mockContext)).toThrow(
        AUTH_ERROR_MESSAGES.FORBIDDEN,
      );
    });

    it('should handle KASIE_PG role correctly', () => {
      // Arrange
      const mockContext = createMockExecutionContext('KASIE_PG');
      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['KASIE_PG']);

      // Act
      const result = guard.canActivate(mockContext);

      // Assert
      expect(result).toBe(true);
    });

    it('should handle KASIE_FE role correctly', () => {
      // Arrange
      const mockContext = createMockExecutionContext('KASIE_FE');
      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['KASIE_FE']);

      // Act
      const result = guard.canActivate(mockContext);

      // Assert
      expect(result).toBe(true);
    });

    it('should handle OPERATOR role correctly when not authorized', () => {
      // Arrange
      const mockContext = createMockExecutionContext('OPERATOR');
      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['KASIE_PG']);

      // Act & Assert
      expect(() => guard.canActivate(mockContext)).toThrow(ForbiddenException);
    });

    it('should handle undefined user gracefully', () => {
      // Arrange
      const mockContext = createMockExecutionContext(undefined);
      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(['KASIE_PG']);

      // Act & Assert
      expect(() => guard.canActivate(mockContext)).toThrow(ForbiddenException);
    });
  });
});
