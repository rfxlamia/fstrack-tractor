import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';

// Load environment-specific .env file
const envFile = process.env.NODE_ENV === 'staging'
  ? '.env.staging'
  : process.env.NODE_ENV === 'test'
  ? '.env.test'
  : '.env.development';

dotenv.config({ path: envFile });

// Support both DATABASE_URL (Supabase/Railway) and individual vars
const getDatabaseConfig = () => {
  if (process.env.DATABASE_URL) {
    // Parse DATABASE_URL for cloud providers (Supabase, Railway, Render)
    return {
      url: process.env.DATABASE_URL,
    };
  }

  // Fallback to individual env vars for local development
  return {
    host: process.env.DATABASE_HOST || 'localhost',
    port: parseInt(process.env.DATABASE_PORT || '5432', 10),
    username: process.env.DATABASE_USERNAME || 'postgres',
    password: process.env.DATABASE_PASSWORD || '',
    database: process.env.DATABASE_NAME || 'fstrack_tractor_dev',
  };
};

export default new DataSource({
  type: 'postgres',
  ...getDatabaseConfig(),
  entities: ['src/**/*.entity.ts'],
  migrations: ['src/database/migrations/*.ts'],
});
