/**
 * CSV Validation Library for User Import
 * Shared validation logic used by both validate and import scripts
 */

import { query } from './db-connection';

// ==================== Types ====================

export interface CsvRow {
  line: number;
  username: string;
  password: string;
  fullname: string;
  role_id: string;
  plantation_group_id: string;
  index?: string;
  email?: string;
  phone?: string;
  address?: string;
  picture_url?: string;
}

export interface ValidationError {
  line: number;
  field: string;
  value: string;
  message: string;
}

export interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
  rowCount: number;
  roleBreakdown: Record<string, number>;
}

// ==================== Required Columns ====================

export const REQUIRED_COLUMNS = [
  'username',
  'password',
  'fullname',
  'role_id',
  'plantation_group_id',
];

// ==================== Header Validation ====================

export function validateHeaders(headers: string[]): ValidationError[] {
  const errors: ValidationError[] = [];
  const missing = REQUIRED_COLUMNS.filter(col => !headers.includes(col));

  for (const col of missing) {
    errors.push({
      line: 1,
      field: 'header',
      value: col,
      message: 'missing required column',
    });
  }

  return errors;
}

// ==================== Username Validation ====================

export function validateUsername(username: string, line: number): ValidationError[] {
  const errors: ValidationError[] = [];

  if (!username || username.trim() === '') {
    errors.push({
      line,
      field: 'username',
      value: username,
      message: 'is required (cannot be empty)',
    });
  } else if (username.length > 255) {
    errors.push({
      line,
      field: 'username',
      value: username,
      message: 'too long (maximum 255 characters)',
    });
  }

  return errors;
}

// ==================== Password Validation ====================

export function validatePassword(password: string, line: number): ValidationError[] {
  const errors: ValidationError[] = [];

  if (!password || password.trim() === '') {
    errors.push({
      line,
      field: 'password',
      value: password,
      message: 'is required (cannot be empty)',
    });
  } else if (password.length < 8) {
    errors.push({
      line,
      field: 'password',
      value: password,
      message: 'too short (minimum 8 characters)',
    });
  } else if (!/\d/.test(password)) {
    errors.push({
      line,
      field: 'password',
      value: password,
      message: 'must contain at least 1 digit',
    });
  }

  return errors;
}

// ==================== Fullname Validation ====================

export function validateFullname(fullname: string, line: number): ValidationError[] {
  const errors: ValidationError[] = [];

  if (!fullname || fullname.trim() === '') {
    errors.push({
      line,
      field: 'fullname',
      value: fullname,
      message: 'is required (cannot be empty)',
    });
  } else if (fullname.length > 255) {
    errors.push({
      line,
      field: 'fullname',
      value: fullname,
      message: 'too long (maximum 255 characters)',
    });
  }

  return errors;
}

// ==================== Role ID Validation ====================

export async function validateRoleId(roleId: string, line: number, validRoles: Set<string>): Promise<ValidationError[]> {
  const errors: ValidationError[] = [];

  if (!roleId || roleId.trim() === '') {
    errors.push({
      line,
      field: 'role_id',
      value: roleId,
      message: 'is required (cannot be empty)',
    });
  } else if (!validRoles.has(roleId)) {
    errors.push({
      line,
      field: 'role_id',
      value: roleId,
      message: `is not valid (must exist in roles table)`,
    });
  }

  return errors;
}

// ==================== Plantation Group ID Validation ====================

export async function validatePlantationGroupId(groupId: string, line: number, validGroups: Set<string>): Promise<ValidationError[]> {
  const errors: ValidationError[] = [];

  // Optional field - can be empty
  if (!groupId || groupId.trim() === '') {
    return errors;
  }

  if (!validGroups.has(groupId)) {
    errors.push({
      line,
      field: 'plantation_group_id',
      value: groupId,
      message: `does not exist in database`,
    });
  }

  return errors;
}

// ==================== Optional Fields Validation ====================

export function validateOptionalFields(row: CsvRow): ValidationError[] {
  const errors: ValidationError[] = [];
  const { line, email, picture_url } = row;

  // Email validation (basic format)
  if (email && email.trim() !== '') {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      errors.push({
        line,
        field: 'email',
        value: email,
        message: 'invalid email format',
      });
    }
  }

  // URL validation for picture_url
  // Production allows both absolute URLs and relative paths (e.g., uploads/image-123.jpg)
  if (picture_url && picture_url.trim() !== '') {
    // Try as absolute URL first
    try {
      new URL(picture_url);
    } catch {
      // If not absolute URL, check if it's a valid relative path pattern
      // Valid patterns: uploads/*, http://, https://
      const isValidRelativePath = /^[a-zA-Z0-9_\-\/\.]+\.(jpg|jpeg|png|gif|webp)$/i.test(picture_url);
      const isHttpUrl = picture_url.startsWith('http://') || picture_url.startsWith('https://');

      if (!isValidRelativePath && !isHttpUrl) {
        errors.push({
          line,
          field: 'picture_url',
          value: picture_url,
          message: 'invalid URL format (must be valid URL or relative path like uploads/image.jpg)',
        });
      }
    }
  }

  return errors;
}

// ==================== Row Validation ====================

export async function validateRow(
  row: CsvRow,
  validRoles: Set<string>,
  validGroups: Set<string>
): Promise<ValidationError[]> {
  const errors: ValidationError[] = [];

  errors.push(...validateUsername(row.username, row.line));
  errors.push(...validatePassword(row.password, row.line));
  errors.push(...validateFullname(row.fullname, row.line));
  errors.push(...validateOptionalFields(row));
  errors.push(...await validateRoleId(row.role_id, row.line, validRoles));
  errors.push(...await validatePlantationGroupId(row.plantation_group_id, row.line, validGroups));

  return errors;
}

// ==================== Username Existence Check ====================

export async function checkUsernameExists(username: string): Promise<boolean> {
  const result = await query<{ exists: boolean }>(
    'SELECT EXISTS(SELECT 1 FROM users WHERE username = $1) as exists',
    [username]
  );
  return result[0]?.exists || false;
}

// ==================== Get Valid Roles ====================

export async function getValidRoles(): Promise<Set<string>> {
  const roles = await query<{ id: string }>('SELECT id FROM roles');
  return new Set(roles.map(r => r.id));
}

// ==================== Get Valid Plantation Groups ====================

export async function getValidPlantationGroups(): Promise<Set<string>> {
  const groups = await query<{ id: string }>('SELECT id FROM plantation_groups');
  return new Set(groups.map(g => g.id));
}

// ==================== Duplicate Username Detection ====================

export function detectDuplicateUsernames(rows: CsvRow[]): ValidationError[] {
  const errors: ValidationError[] = [];
  const usernameMap = new Map<string, number>();

  for (const row of rows) {
    const username = row.username;
    if (usernameMap.has(username)) {
      errors.push({
        line: row.line,
        field: 'username',
        value: username,
        message: `duplicate username within file (first occurrence at line ${usernameMap.get(username)})`,
      });
    } else {
      usernameMap.set(username, row.line);
    }
  }

  return errors;
}

// ==================== Main Validation Function ====================

export async function validateUserData(
  rows: CsvRow[],
  options?: {
    validRoles?: Set<string>;
    validGroups?: Set<string>;
    existingUsernames?: Set<string>;
  }
): Promise<ValidationResult> {
  const errors: ValidationError[] = [];
  const roleBreakdown: Record<string, number> = {};

  // Get valid values from database
  const validRoles = options?.validRoles ?? await getValidRoles();
  const validGroups = options?.validGroups ?? await getValidPlantationGroups();
  const existingUsernames = options?.existingUsernames;

  // Check for duplicates within file
  const duplicateErrors = detectDuplicateUsernames(rows);
  errors.push(...duplicateErrors);
  const duplicateLines = new Set(duplicateErrors.map(error => error.line));

  // Collect usernames for database existence check
  const usernamesToCheck = new Set<string>();

  // Validate each row
  for (const row of rows) {
    const rowErrors = await validateRow(row, validRoles, validGroups);
    errors.push(...rowErrors);

    // Track role breakdown
    if (row.role_id && !rowErrors.some(e => e.field === 'role_id')) {
      roleBreakdown[row.role_id] = (roleBreakdown[row.role_id] || 0) + 1;
    }

    // Collect username for DB check (only if no duplicate error)
    if (!duplicateLines.has(row.line) && !rowErrors.some(e => e.field === 'username')) {
      usernamesToCheck.add(row.username);
    }
  }

  // Check for existing usernames in database (or mock set if provided)
  for (const username of Array.from(usernamesToCheck)) {
    const exists = existingUsernames
      ? existingUsernames.has(username)
      : await checkUsernameExists(username);

    if (exists) {
      const row = rows.find(r => r.username === username);
      if (row) {
        errors.push({
          line: row.line,
          field: 'username',
          value: username,
          message: 'already exists in database',
        });
      }
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
    rowCount: rows.length,
    roleBreakdown,
  };
}
