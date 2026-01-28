import { DataSource } from 'typeorm';
import { config } from 'dotenv';

// Load environment variables
config();

let dataSource: DataSource | null = null;

/**
 * Get database connection for CSV validation scripts
 * Connects directly to production database schema
 */
export async function getConnection(): Promise<DataSource> {
  if (dataSource && dataSource.isInitialized) {
    return dataSource;
  }

  const host = process.env.DB_HOST || process.env.DATABASE_HOST || 'localhost';
  const port = parseInt(process.env.DB_PORT || process.env.DATABASE_PORT || '5432', 10);
  const username = process.env.DB_USERNAME || process.env.DATABASE_USERNAME;
  const password = process.env.DB_PASSWORD || process.env.DATABASE_PASSWORD;
  const database = process.env.DB_DATABASE || process.env.DATABASE_NAME;
  const sslEnabled = (process.env.DB_SSL || process.env.DATABASE_SSL) === 'true';

  // Validate required credentials
  if (!username || !password || !database) {
    throw new Error(
      'Missing required database credentials. Please set:\n' +
      '  - DB_USERNAME (or DATABASE_USERNAME)\n' +
      '  - DB_PASSWORD (or DATABASE_PASSWORD)\n' +
      '  - DB_DATABASE (or DATABASE_NAME)'
    );
  }

  dataSource = new DataSource({
    type: 'postgres',
    host,
    port,
    username,
    password,
    database,
    ssl: sslEnabled ? { rejectUnauthorized: false } : false,
  });

  try {
    await dataSource.initialize();
    return dataSource;
  } catch (error) {
    throw new Error(`Failed to connect to database: ${error instanceof Error ? error.message : String(error)}`);
  }
}

/**
 * Close database connection
 */
export async function closeConnection(): Promise<void> {
  if (dataSource && dataSource.isInitialized) {
    await dataSource.destroy();
    dataSource = null;
  }
}

/**
 * Execute a raw SQL query
 */
export async function query<T = any>(sql: string, params?: any[]): Promise<T[]> {
  const ds = await getConnection();
  const result = await ds.query(sql, params);
  return result;
}
