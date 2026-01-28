import {
  validateHeaders,
  validateUsername,
  validatePassword,
  validateFullname,
  validateRoleId,
  validatePlantationGroupId,
  validateOptionalFields,
  validateRow,
  checkUsernameExists,
  getValidRoles,
  getValidPlantationGroups,
  detectDuplicateUsernames,
  validateUserData,
  type CsvRow,
  type ValidationError,
} from '../lib/csv-validator';
import { query } from '../lib/db-connection';

// Mock db-connection
jest.mock('../lib/db-connection');

const mockQuery = query as jest.MockedFunction<typeof query>;

describe('csv-validator', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('validateHeaders', () => {
    it('passes with all required headers', () => {
      const headers = ['username', 'password', 'fullname', 'role_id', 'plantation_group_id'];
      const errors = validateHeaders(headers);
      expect(errors).toHaveLength(0);
    });

    it('fails when required headers are missing', () => {
      const headers = ['username', 'password', 'fullname'];
      const errors = validateHeaders(headers);
      expect(errors.length).toBeGreaterThan(0);
      expect(errors[0].field).toBe('header');
      expect(errors[0].value).toBe('role_id');
      expect(errors[0].message).toContain('is required');
    });

    it('passes with optional headers included', () => {
      const headers = ['username', 'password', 'fullname', 'role_id', 'plantation_group_id', 'email', 'phone'];
      const errors = validateHeaders(headers);
      expect(errors).toHaveLength(0);
    });
  });

  describe('validateUsername', () => {
    it('passes with valid username', () => {
      const errors = validateUsername('testuser', 2);
      expect(errors).toHaveLength(0);
    });

    it('fails with empty username', () => {
      const errors = validateUsername('', 2);
      expect(errors).toHaveLength(1);
      expect(errors[0].field).toBe('username');
      expect(errors[0].message).toContain('required');
    });

    it('fails with whitespace-only username', () => {
      const errors = validateUsername('   ', 2);
      expect(errors).toHaveLength(1);
      expect(errors[0].message).toContain('required');
    });

    it('fails with username > 255 characters', () => {
      const longUsername = 'a'.repeat(256);
      const errors = validateUsername(longUsername, 2);
      expect(errors).toHaveLength(1);
      expect(errors[0].message).toContain('too long');
    });
  });

  describe('validatePassword', () => {
    it('passes with valid password', () => {
      const errors = validatePassword('Password123', 2);
      expect(errors).toHaveLength(0);
    });

    it('fails with empty password', () => {
      const errors = validatePassword('', 2);
      expect(errors).toHaveLength(1);
      expect(errors[0].message).toContain('required');
    });

    it('fails with password < 8 characters', () => {
      const errors = validatePassword('Pass1', 2);
      expect(errors).toHaveLength(1);
      expect(errors[0].message).toContain('too short');
    });

    it('fails with password without digit', () => {
      const errors = validatePassword('Password', 2);
      expect(errors).toHaveLength(1);
      expect(errors[0].message).toContain('digit');
    });
  });

  describe('validateFullname', () => {
    it('passes with valid fullname', () => {
      const errors = validateFullname('John Doe', 2);
      expect(errors).toHaveLength(0);
    });

    it('fails with empty fullname', () => {
      const errors = validateFullname('', 2);
      expect(errors).toHaveLength(1);
      expect(errors[0].message).toContain('required');
    });

    it('fails with fullname > 255 characters', () => {
      const longName = 'a'.repeat(256);
      const errors = validateFullname(longName, 2);
      expect(errors).toHaveLength(1);
      expect(errors[0].message).toContain('too long');
    });
  });

  describe('validateRoleId', () => {
    it('passes with valid role_id', async () => {
      const validRoles = new Set(['OPERATOR', 'KASIE_FE', 'MANAGER']);
      const errors = await validateRoleId('OPERATOR', 2, validRoles);
      expect(errors).toHaveLength(0);
    });

    it('fails with empty role_id', async () => {
      const validRoles = new Set(['OPERATOR']);
      const errors = await validateRoleId('', 2, validRoles);
      expect(errors).toHaveLength(1);
      expect(errors[0].message).toContain('required');
    });

    it('fails with invalid role_id', async () => {
      const validRoles = new Set(['OPERATOR']);
      const errors = await validateRoleId('INVALID_ROLE', 2, validRoles);
      expect(errors).toHaveLength(1);
      expect(errors[0].message).toContain('not valid');
    });
  });

  describe('validatePlantationGroupId', () => {
    it('passes with valid plantation_group_id', async () => {
      const validGroups = new Set(['PG1', 'PG2', 'MG1']);
      const errors = await validatePlantationGroupId('PG1', 2, validGroups);
      expect(errors).toHaveLength(0);
    });

    it('passes with empty plantation_group_id (optional field)', async () => {
      const validGroups = new Set(['PG1']);
      const errors = await validatePlantationGroupId('', 2, validGroups);
      expect(errors).toHaveLength(0);
    });

    it('fails with invalid plantation_group_id', async () => {
      const validGroups = new Set(['PG1']);
      const errors = await validatePlantationGroupId('INVALID', 2, validGroups);
      expect(errors).toHaveLength(1);
      expect(errors[0].message).toContain('does not exist');
    });
  });

  describe('validateOptionalFields', () => {
    it('passes with valid email', () => {
      const row: CsvRow = {
        line: 2,
        username: 'test',
        password: 'Password123',
        fullname: 'Test',
        role_id: 'OPERATOR',
        plantation_group_id: 'PG1',
        email: 'test@example.com',
      };
      const errors = validateOptionalFields(row);
      expect(errors).toHaveLength(0);
    });

    it('fails with invalid email format', () => {
      const row: CsvRow = {
        line: 2,
        username: 'test',
        password: 'Password123',
        fullname: 'Test',
        role_id: 'OPERATOR',
        plantation_group_id: 'PG1',
        email: 'invalid-email',
      };
      const errors = validateOptionalFields(row);
      expect(errors).toHaveLength(1);
      expect(errors[0].field).toBe('email');
    });

    it('fails with invalid URL', () => {
      const row: CsvRow = {
        line: 2,
        username: 'test',
        password: 'Password123',
        fullname: 'Test',
        role_id: 'OPERATOR',
        plantation_group_id: 'PG1',
        picture_url: 'not-a-url',
      };
      const errors = validateOptionalFields(row);
      expect(errors).toHaveLength(1);
      expect(errors[0].field).toBe('picture_url');
    });

    it('passes with relative path picture_url (production pattern)', () => {
      const row: CsvRow = {
        line: 2,
        username: 'test',
        password: 'Password123',
        fullname: 'Test',
        role_id: 'OPERATOR',
        plantation_group_id: 'PG1',
        picture_url: 'uploads/image-1755068257883-816381660.jpg',
      };
      const errors = validateOptionalFields(row);
      expect(errors).toHaveLength(0);
    });

    it('passes with absolute URL picture_url', () => {
      const row: CsvRow = {
        line: 2,
        username: 'test',
        password: 'Password123',
        fullname: 'Test',
        role_id: 'OPERATOR',
        plantation_group_id: 'PG1',
        picture_url: 'https://example.com/images/photo.jpg',
      };
      const errors = validateOptionalFields(row);
      expect(errors).toHaveLength(0);
    });
  });

  describe('validateRow', () => {
    it('aggregates row-level validation errors', async () => {
      const row: CsvRow = {
        line: 2,
        username: '',
        password: '123',
        fullname: '',
        role_id: 'INVALID',
        plantation_group_id: 'INVALID',
      };
      const validRoles = new Set(['OPERATOR']);
      const validGroups = new Set(['PG1']);

      const errors = await validateRow(row, validRoles, validGroups);
      expect(errors.length).toBeGreaterThan(0);
      expect(errors.some(error => error.field === 'username')).toBe(true);
      expect(errors.some(error => error.field === 'password')).toBe(true);
      expect(errors.some(error => error.field === 'fullname')).toBe(true);
      expect(errors.some(error => error.field === 'role_id')).toBe(true);
      expect(errors.some(error => error.field === 'plantation_group_id')).toBe(true);
    });
  });

  describe('detectDuplicateUsernames', () => {
    it('detects duplicate usernames', () => {
      const rows: CsvRow[] = [
        { line: 2, username: 'dupe', password: 'Passw0rd', fullname: 'A', role_id: 'OPERATOR', plantation_group_id: 'PG1' },
        { line: 3, username: 'unique', password: 'Passw0rd', fullname: 'B', role_id: 'OPERATOR', plantation_group_id: 'PG1' },
        { line: 4, username: 'dupe', password: 'Passw0rd', fullname: 'C', role_id: 'OPERATOR', plantation_group_id: 'PG2' },
      ];
      const errors = detectDuplicateUsernames(rows);
      expect(errors).toHaveLength(1); // One error for the duplicate
      expect(errors[0].message).toContain('duplicate');
      expect(errors[0].message).toContain('line 2');
    });

    it('passes with all unique usernames', () => {
      const rows: CsvRow[] = [
        { line: 2, username: 'user1', password: 'Passw0rd', fullname: 'A', role_id: 'OPERATOR', plantation_group_id: 'PG1' },
        { line: 3, username: 'user2', password: 'Passw0rd', fullname: 'B', role_id: 'OPERATOR', plantation_group_id: 'PG1' },
      ];
      const errors = detectDuplicateUsernames(rows);
      expect(errors).toHaveLength(0);
    });
  });

  describe('checkUsernameExists', () => {
    it('returns true when username exists', async () => {
      mockQuery.mockResolvedValue([{ exists: true }]);
      const exists = await checkUsernameExists('existinguser');
      expect(exists).toBe(true);
      expect(mockQuery).toHaveBeenCalledWith(
        'SELECT EXISTS(SELECT 1 FROM users WHERE username = $1) as exists',
        ['existinguser']
      );
    });

    it('returns false when username does not exist', async () => {
      mockQuery.mockResolvedValue([{ exists: false }]);
      const exists = await checkUsernameExists('newuser');
      expect(exists).toBe(false);
    });
  });

  describe('getValidRoles', () => {
    it('returns set of valid role IDs', async () => {
      mockQuery.mockResolvedValue([
        { id: 'OPERATOR' },
        { id: 'KASIE_FE' },
        { id: 'MANAGER' },
      ]);
      const roles = await getValidRoles();
      expect(roles).toBeInstanceOf(Set);
      expect(roles.has('OPERATOR')).toBe(true);
      expect(roles.has('KASIE_FE')).toBe(true);
      expect(roles.has('MANAGER')).toBe(true);
      expect(roles.has('INVALID')).toBe(false);
    });
  });

  describe('getValidPlantationGroups', () => {
    it('returns set of valid plantation group IDs', async () => {
      mockQuery.mockResolvedValue([
        { id: 'PG1' },
        { id: 'PG2' },
        { id: 'MG1' },
      ]);
      const groups = await getValidPlantationGroups();
      expect(groups).toBeInstanceOf(Set);
      expect(groups.has('PG1')).toBe(true);
      expect(groups.has('PG2')).toBe(true);
      expect(groups.has('MG1')).toBe(true);
      expect(groups.has('INVALID')).toBe(false);
    });
  });

  describe('validateUserData', () => {
    it('validates all rows correctly', async () => {
      const rows: CsvRow[] = [
        {
          line: 2,
          username: 'user1',
          password: 'Password123',
          fullname: 'User One',
          role_id: 'OPERATOR',
          plantation_group_id: 'PG1',
        },
      ];

      mockQuery
        .mockResolvedValueOnce([{ id: 'OPERATOR' }]) // getValidRoles
        .mockResolvedValueOnce([{ id: 'PG1' }]) // getValidPlantationGroups
        .mockResolvedValueOnce([{ exists: false }]); // checkUsernameExists

      const result = await validateUserData(rows);
      expect(result.isValid).toBe(true);
      expect(result.errors).toHaveLength(0);
      expect(result.rowCount).toBe(1);
    });

    it('collects all validation errors', async () => {
      const rows: CsvRow[] = [
        {
          line: 2,
          username: '', // empty
          password: '123', // too short, no digit
          fullname: 'a'.repeat(300), // too long
          role_id: 'INVALID', // invalid role
          plantation_group_id: 'INVALID', // invalid group
        },
      ];

      mockQuery
        .mockResolvedValueOnce([{ id: 'OPERATOR' }]) // getValidRoles
        .mockResolvedValueOnce([{ id: 'PG1' }]); // getValidPlantationGroups

      const result = await validateUserData(rows);
      expect(result.isValid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
    });

    it('tracks role breakdown', async () => {
      const rows: CsvRow[] = [
        {
          line: 2,
          username: 'user1',
          password: 'Password123',
          fullname: 'User One',
          role_id: 'OPERATOR',
          plantation_group_id: 'PG1',
        },
        {
          line: 3,
          username: 'user2',
          password: 'Password123',
          fullname: 'User Two',
          role_id: 'KASIE_FE',
          plantation_group_id: 'PG1',
        },
        {
          line: 4,
          username: 'user3',
          password: 'Password123',
          fullname: 'User Three',
          role_id: 'OPERATOR',
          plantation_group_id: 'PG1',
        },
      ];

      mockQuery
        .mockResolvedValueOnce([{ id: 'OPERATOR' }, { id: 'KASIE_FE' }])
        .mockResolvedValueOnce([{ id: 'PG1' }])
        .mockResolvedValueOnce([{ exists: false }])
        .mockResolvedValueOnce([{ exists: false }])
        .mockResolvedValueOnce([{ exists: false }]);

      const result = await validateUserData(rows);
      expect(result.roleBreakdown['OPERATOR']).toBe(2);
      expect(result.roleBreakdown['KASIE_FE']).toBe(1);
    });
  });
});
