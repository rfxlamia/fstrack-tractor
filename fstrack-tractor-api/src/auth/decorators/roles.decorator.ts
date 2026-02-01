import { SetMetadata } from '@nestjs/common';

/**
 * Key used to store roles metadata
 */
export const ROLES_KEY = 'roles';

/**
 * Decorator to specify required roles for accessing a route or controller.
 * Multiple roles are treated as OR logic (user needs at least one matching role).
 *
 * @example
 * // Single role
 * @Roles('KASIE_PG')
 * async createSchedule(...) { }
 *
 * @example
 * // Multiple roles (OR logic)
 * @Roles('KASIE_PG', 'KASIE_FE')
 * async someEndpoint(...) { }
 *
 * @param roles - Array of role strings required to access the resource
 * @returns Metadata decorator
 */
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
