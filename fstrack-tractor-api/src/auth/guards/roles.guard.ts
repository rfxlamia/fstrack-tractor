import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { AUTH_ERROR_MESSAGES } from '../constants/error-messages.constant';

/**
 * Guard that enforces role-based access control (RBAC).
 *
 * This guard checks if the authenticated user has at least one of the required
 * roles specified by the @Roles() decorator. Multiple roles are treated as
 * OR logic - the user only needs to match one role to be granted access.
 *
 * Execution order: This guard should be used AFTER JwtAuthGuard to ensure
 * the user object is available in the request. If no roles are defined
 * for a route, the guard allows all authenticated users.
 *
 * @example
 * // Controller-level usage
 * @Controller('api/v1/schedules')
 * @UseGuards(JwtAuthGuard, RolesGuard)
 * export class SchedulesController { ... }
 *
 * @example
 * // Method-level usage
 * @Post()
 * @Roles('kasie_pg')
 * async create(...) { ... }
 */
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  /**
   * Determines if the current user can access the resource.
   *
   * @param context - Execution context containing the request
   * @returns true if user has required role, otherwise throws ForbiddenException
   * @throws ForbiddenException when user lacks required role
   */
  canActivate(context: ExecutionContext): boolean {
    // Get required roles from method-level or controller-level decorator
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(
      ROLES_KEY,
      [
        context.getHandler(), // Method-level @Roles() - takes precedence
        context.getClass(), // Controller-level @Roles()
      ],
    );

    // If no roles are defined, allow access to all authenticated users
    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    // Extract user from request (set by JwtAuthGuard)
    interface JwtUser {
      sub: number;
      username: string;
      role: string;
    }
    const { user } = context.switchToHttp().getRequest<{ user: JwtUser }>();

    // Check if user has at least one of the required roles (OR logic)
    const hasRole = requiredRoles.includes(user?.role ?? '');

    if (!hasRole) {
      throw new ForbiddenException(AUTH_ERROR_MESSAGES.FORBIDDEN);
    }

    return hasRole;
  }
}
