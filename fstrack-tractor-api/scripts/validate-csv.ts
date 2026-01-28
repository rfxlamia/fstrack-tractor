#!/usr/bin/env ts-node
/**
 * CSV Validation Script for User Import
 * Usage: npm run csv:validate -- --file=users.csv
 */

import * as fs from 'fs';
import * as path from 'path';
import csvParser from 'csv-parser';
import { validateHeaders, validateUserData } from './lib/csv-validator';
import { closeConnection } from './lib/db-connection';
import type { CsvRow as ValidatorCsvRow } from './lib/csv-validator';

interface CsvRow {
  line: number;
  [key: string]: string | number;
}

function parseEnvSet(name: string): Set<string> {
  const raw = process.env[name];
  if (!raw) {
    return new Set();
  }
  return new Set(
    raw
      .split(',')
      .map(value => value.trim())
      .filter(Boolean)
  );
}

// ==================== Parse Command Line Arguments ====================

function parseArgs(): { file: string } {
  const args = process.argv.slice(2);
  const fileArg = args.find(arg => arg.startsWith('--file='));

  if (!fileArg) {
    console.error('Error: --file parameter is required');
    console.error('Usage: npm run csv:validate -- --file=users.csv');
    process.exit(1);
  }

  const filePath = fileArg.split('=')[1];
  return { file: filePath };
}

// ==================== Read CSV File ====================

async function readCsvFile(filePath: string): Promise<CsvRow[]> {
  return new Promise((resolve, reject) => {
    const rows: CsvRow[] = [];
    let lineNumber = 1; // Start at 1 for header

    fs.createReadStream(filePath)
      .pipe(csvParser())
      .on('data', (row: any) => {
        lineNumber++;
        rows.push({ line: lineNumber, ...row });
      })
      .on('end', () => {
        resolve(rows);
      })
      .on('error', (error) => {
        reject(error);
      });
  });
}

// ==================== Get CSV Headers ====================

async function getCsvHeaders(filePath: string): Promise<string[]> {
  return new Promise((resolve, reject) => {
    const headers: string[] = [];

    fs.createReadStream(filePath)
      .pipe(csvParser())
      .on('headers', (headerList: string[]) => {
        headers.push(...headerList);
      })
      .on('data', () => {
        // Just read one row to get headers
        fs.createReadStream(filePath).destroy();
      })
      .on('end', () => {
        resolve(headers);
      })
      .on('error', (error) => {
        reject(error);
      });
  });
}

// ==================== Format Error Report ====================

function formatErrorReport(errors: any[]): string {
  let output = '❌ Validation Failed\n\n';

  for (const error of errors) {
    output += `Line ${error.line}: ${error.field} '${error.value}' ${error.message}\n`;
  }

  output += `\nTotal: ${errors.length} error${errors.length !== 1 ? 's' : ''} found\n`;
  return output;
}

// ==================== Format Success Report ====================

function formatSuccessReport(rowCount: number, roleBreakdown: Record<string, number>): string {
  const roleSummary = Object.entries(roleBreakdown)
    .map(([role, count]) => `${role} (${count})`)
    .join(', ');

  return `✅ Validation Passed

Total rows: ${rowCount}
Roles breakdown: ${roleSummary}
Ready for import`;
}

// ==================== Main Function ====================

async function main() {
  try {
    const { file } = parseArgs();

    // Check if file exists
    if (!fs.existsSync(file)) {
      console.error(`Error: File not found: ${file}`);
      process.exit(1);
    }

    // Get absolute path
    const absolutePath = path.resolve(file);

    // Read CSV headers
    const headers = await getCsvHeaders(absolutePath);

    // Validate headers first (fail fast)
    const headerErrors = validateHeaders(headers);
    if (headerErrors.length > 0) {
      console.error(formatErrorReport(headerErrors));
      process.exit(1);
    }

    // Read CSV rows
    const rows = await readCsvFile(absolutePath);

    if (rows.length === 0) {
      console.error('Error: CSV file is empty (no data rows)');
      process.exit(1);
    }

    // Convert to ValidatorCsvRow type
    const validatorRows: ValidatorCsvRow[] = rows.map(row => ({
      line: row.line,
      username: String(row.username || ''),
      password: String(row.password || ''),
      fullname: String(row.fullname || ''),
      role_id: String(row.role_id || ''),
      plantation_group_id: String(row.plantation_group_id || ''),
      index: row.index !== undefined && row.index !== null ? String(row.index) : undefined,
      email: row.email !== undefined && row.email !== null ? String(row.email) : undefined,
      phone: row.phone !== undefined && row.phone !== null ? String(row.phone) : undefined,
      address: row.address !== undefined && row.address !== null ? String(row.address) : undefined,
      picture_url: row.picture_url !== undefined && row.picture_url !== null ? String(row.picture_url) : undefined,
    }));

    // Validate user data (allow mock DB for tests)
    const mockDbEnabled = process.env.CSV_VALIDATE_MOCK_DB === '1' || process.env.CSV_VALIDATE_MOCK_DB === 'true';
    let mockOptions:
      | {
          validRoles: Set<string>;
          validGroups: Set<string>;
          existingUsernames?: Set<string>;
        }
      | undefined;

    if (mockDbEnabled) {
      const validRoles = parseEnvSet('CSV_VALID_ROLES');
      const validGroups = parseEnvSet('CSV_VALID_GROUPS');
      const existingUsernames = parseEnvSet('CSV_EXISTING_USERS');

      if (!validRoles.size || !validGroups.size) {
        throw new Error('CSV_VALIDATE_MOCK_DB requires CSV_VALID_ROLES and CSV_VALID_GROUPS');
      }

      mockOptions = { validRoles, validGroups, existingUsernames };
    }

    const result = await validateUserData(validatorRows, mockOptions);

    if (!result.isValid) {
      console.error(formatErrorReport(result.errors));
      process.exit(1);
    }

    // Success
    console.log(formatSuccessReport(result.rowCount, result.roleBreakdown));
    process.exit(0);

  } catch (error) {
    console.error(`Error: ${error instanceof Error ? error.message : String(error)}`);
    process.exit(1);
  } finally {
    await closeConnection();
  }
}

// Run main function
main();
