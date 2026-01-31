import { spawnSync } from 'child_process';
import * as path from 'path';

// Integration tests for validate-csv.ts script
// These tests run the actual CLI script with fixture files

const FIXTURES_DIR = path.join(__dirname, 'fixtures');
const TEST_ENV = {
  ...process.env,
  CSV_VALIDATE_MOCK_DB: '1',
  CSV_VALID_ROLES: 'OPERATOR,KASIE_FE,MANDOR,ASSISTANT_MANAGER,SUPERADMIN',
  CSV_VALID_GROUPS: 'PG1,PG2,MG1,ALL',
  CSV_EXISTING_USERS: 'tyastono,agungm',
};

function runCsvValidate(filePath?: string): { exitCode: number; output: string } {
  const args = filePath
    ? ['run', 'csv:validate', '--', `--file=${filePath}`]
    : ['run', 'csv:validate'];

  const result = spawnSync('npm', args, {
    cwd: process.cwd(),
    env: TEST_ENV,
    encoding: 'utf-8',
  });

  const output = (result.stdout || '') + (result.stderr || '');
  return {
    exitCode: result.status ?? 1,
    output,
  };
}

describe('validate-csv CLI script', () => {
  describe('valid CSV', () => {
    it('validates successfully with exit code 0', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'valid-users.csv');
      const { exitCode } = runCsvValidate(fixturePath);
      expect(exitCode).toBe(0);
    });

    it('outputs success message with role breakdown', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'valid-users.csv');
      const { output } = runCsvValidate(fixturePath);

      expect(output).toContain('✅');
      expect(output).toContain('Validation Passed');
      expect(output).toContain('Total rows');
      expect(output).toContain('Roles breakdown');
    });
  });

  describe('invalid CSV with password errors', () => {
    it('fails validation with exit code 1', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-password.csv');
      const { exitCode } = runCsvValidate(fixturePath);
      expect(exitCode).toBe(1);
    });

    it('outputs password validation error', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-password.csv');
      const { output } = runCsvValidate(fixturePath);

      expect(output).toContain('❌');
      expect(output).toContain('Validation Failed');
      expect(output).toContain('password');
    });
  });

  describe('invalid CSV with role errors', () => {
    it('fails validation with exit code 1', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-role.csv');
      const { exitCode } = runCsvValidate(fixturePath);
      expect(exitCode).toBe(1);
    });

    it('outputs role_id validation error', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-role.csv');
      const { output } = runCsvValidate(fixturePath);

      expect(output).toContain('❌');
      expect(output).toContain('role_id');
    });
  });

  describe('invalid CSV with duplicate usernames', () => {
    it('fails validation with exit code 1', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'duplicate-username.csv');
      const { exitCode } = runCsvValidate(fixturePath);
      expect(exitCode).toBe(1);
    });

    it('outputs duplicate username error', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'duplicate-username.csv');
      const { output } = runCsvValidate(fixturePath);

      expect(output).toContain('❌');
      expect(output).toContain('duplicate');
    });
  });

  describe('invalid CSV with missing headers', () => {
    it('fails validation with exit code 1', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-headers.csv');
      const { exitCode } = runCsvValidate(fixturePath);
      expect(exitCode).toBe(1);
    });

    it('outputs header validation error', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-headers.csv');
      const { output } = runCsvValidate(fixturePath);

      expect(output).toContain('❌');
      expect(output).toContain('header');
    });
  });

  describe('missing file', () => {
    it('fails with clear error message', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'non-existent.csv');
      const { exitCode, output } = runCsvValidate(fixturePath);

      expect(exitCode).toBe(1);
      expect(output).toContain('Error');
      expect(output).toContain('File not found');
    });
  });

  describe('missing --file parameter', () => {
    it('fails with usage message', () => {
      const { exitCode, output } = runCsvValidate();

      expect(exitCode).toBe(1);
      expect(output).toContain('--file');
      expect(output).toContain('Usage');
    });
  });
});
