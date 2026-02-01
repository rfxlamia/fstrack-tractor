/**
 * Centralized authentication and authorization error messages.
 * All messages are in Bahasa Indonesia as per project requirements.
 */
export const AUTH_ERROR_MESSAGES = {
  /**
   * Used when user does not have the required role for an operation
   */
  FORBIDDEN: 'Anda tidak memiliki akses untuk operasi ini',

  /**
   * Used when JWT token is invalid, expired, or missing
   */
  UNAUTHORIZED: 'Token tidak valid atau telah expired',

  /**
   * Used when user's role is not valid for the system
   */
  INVALID_ROLE: 'Role tidak valid untuk operasi ini',
} as const;
