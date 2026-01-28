import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

// Integration tests for validate-csv.ts script
// These tests run the actual CLI script with fixture files

const SCRIPT_PATH = path.join(__dirname, '../validate-csv.ts');
const FIXTURES_DIR = path.join(__dirname, 'fixtures');
const TEST_ENV = {
  ...process.env,
  CSV_VALIDATE_MOCK_DB: '1',
  CSV_VALID_ROLES: 'OPERATOR,KASIE_FE,MANDOR,ASSISTANT_MANAGER,SUPERADMIN',
  CSV_VALID_GROUPS: 'PG1,PG2,MG1,ALL',
  CSV_EXISTING_USERS: 'tyastono,agungm',
};

describe('validate-csv CLI script', () => {
  describe('valid CSV', () => {
    it('validates successfully with exit code 0', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'valid-users.csv');

      expect(() => {
        execSync(`npm run csv:validate -- --file=${fixturePath}`, {
          cwd: process.cwd(),
          env: TEST_ENV,
          stdio: 'pipe',
        });
      }).not.toThrow();
    });

    it('outputs success message with role breakdown', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'valid-users.csv');

      const result = execSync(`npm run csv:validate -- --file=${fixturePath}`, {
        cwd: process.cwd(),
        env: TEST_ENV,
        encoding: 'utf-8',
        stdio: 'pipe',
      });

      expect(result).toContain('✅');
      expect(result).toContain('Validation Passed');
      expect(result).toContain('Total rows');
      expect(result).toContain('Roles breakdown');
    });
  });

  describe('invalid CSV with password errors', () => {
    it('fails validation with exit code 1', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-password.csv');

      let exitCode: number | null = null;
      try {
        execSync(`npm run csv:validate -- --file=${fixturePath}`, {
          cwd: process.cwd(),
          env: TEST_ENV,
          stdio: 'pipe',
        });
      } catch (error) {
        exitCode = (error as any).status;
      }

      expect(exitCode).toBe(1);
    });

    it('outputs password validation error', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-password.csv');

      let output = '';
      try {
        execSync(`npm run csv:validate -- --file=${fixturePath}`, {
          cwd: process.cwd(),
          env: TEST_ENV,
          encoding: 'utf-8',
          stdio: 'pipe',
        });
      } catch (error) {
        output = (error as any).stdout || (error as any).stderr || '';
      }

      expect(output).toContain('❌');
      expect(output).toContain('Validation Failed');
      expect(output).toContain('password');
    });
  });

  describe('invalid CSV with role errors', () => {
    it('fails validation with exit code 1', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-role.csv');

      let exitCode: number | null = null;
      try {
        execSync(`npm run csv:validate -- --file=${fixturePath}`, {
          cwd: process.cwd(),
          env: TEST_ENV,
          stdio: 'pipe',
        });
      } catch (error) {
        exitCode = (error as any).status;
      }

      expect(exitCode).toBe(1);
    });

    it('outputs role_id validation error', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-role.csv');

      let output = '';
      try {
        execSync(`npm run csv:validate -- --file=${fixturePath}`, {
          cwd: process.cwd(),
          env: TEST_ENV,
          encoding: 'utf-8',
          stdio: 'pipe',
        });
      } catch (error) {
        output = (error as any).stdout || (error as any).stderr || '';
      }

      expect(output).toContain('❌');
      expect(output).toContain('role_id');
    });
  });

  describe('invalid CSV with duplicate usernames', () => {
    it('fails validation with exit code 1', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'duplicate-username.csv');

      let exitCode: number | null = null;
      try {
        execSync(`npm run csv:validate -- --file=${fixturePath}`, {
          cwd: process.cwd(),
          env: TEST_ENV,
          stdio: 'pipe',
        });
      } catch (error) {
        exitCode = (error as any).status;
      }

      expect(exitCode).toBe(1);
    });

    it('outputs duplicate username error', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'duplicate-username.csv');

      let output = '';
      try {
        execSync(`npm run csv:validate -- --file=${fixturePath}`, {
          cwd: process.cwd(),
          env: TEST_ENV,
          encoding: 'utf-8',
          stdio: 'pipe',
        });
      } catch (error) {
        output = (error as any).stdout || (error as any).stderr || '';
      }

      expect(output).toContain('❌');
      expect(output).toContain('duplicate');
    });
  });

  describe('invalid CSV with missing headers', () => {
    it('fails validation with exit code 1', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-headers.csv');

      let exitCode: number | null = null;
      try {
        execSync(`npm run csv:validate -- --file=${fixturePath}`, {
          cwd: process.cwd(),
          env: TEST_ENV,
          stdio: 'pipe',
        });
      } catch (error) {
        exitCode = (error as any).status;
      }

      expect(exitCode).toBe(1);
    });

    it('outputs header validation error', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'invalid-headers.csv');

      let output = '';
      try {
        execSync(`npm run csv:validate -- --file=${fixturePath}`, {
          cwd: process.cwd(),
          env: TEST_ENV,
          encoding: 'utf-8',
          stdio: 'pipe',
        });
      } catch (error) {
        output = (error as any).stdout || (error as any).stderr || '';
      }

      expect(output).toContain('❌');
      expect(output).toContain('header');
    });
  });

  describe('missing file', () => {
    it('fails with clear error message', () => {
      const fixturePath = path.join(FIXTURES_DIR, 'non-existent.csv');

      let output = '';
      let exitCode: number | null = null;
      try {
        execSync(`npm run csv:validate -- --file=${fixturePath}`, {
          cwd: process.cwd(),
          env: TEST_ENV,
          encoding: 'utf-8',
          stdio: 'pipe',
        });
      } catch (error) {
        exitCode = (error as any).status;
        output = (error as any).stdout || (error as any).stderr || '';
      }

      expect(exitCode).toBe(1);
      expect(output).toContain('Error');
      expect(output).toContain('File not found');
    });
  });

  describe('missing --file parameter', () => {
    it('fails with usage message', () => {
      let output = '';
      let exitCode: number | null = null;
      try {
        execSync('npm run csv:validate', {
          cwd: process.cwd(),
          env: TEST_ENV,
          encoding: 'utf-8',
          stdio: 'pipe',
        });
      } catch (error) {
        exitCode = (error as any).status;
        output = (error as any).stdout || (error as any).stderr || '';
      }

      expect(exitCode).toBe(1);
      expect(output).toContain('--file');
      expect(output).toContain('Usage');
    });
  });
});
