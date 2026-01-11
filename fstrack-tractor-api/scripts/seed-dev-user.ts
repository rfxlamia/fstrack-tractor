import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';
import * as dotenv from 'dotenv';

dotenv.config({ path: '.env.development' });

const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DATABASE_HOST || 'localhost',
  port: parseInt(process.env.DATABASE_PORT || '5432', 10),
  username: process.env.DATABASE_USERNAME || 'postgres',
  password: process.env.DATABASE_PASSWORD || '',
  database: process.env.DATABASE_NAME || 'fstrack_tractor',
});

async function seed() {
  await dataSource.initialize();

  const passwordHash = await bcrypt.hash('DevPassword123', 10);

  // Upsert dev user
  await dataSource.query(
    `
    INSERT INTO users (username, password_hash, full_name, role, is_first_time)
    VALUES ($1, $2, $3, $4, $5)
    ON CONFLICT (username) DO UPDATE SET
      password_hash = $2,
      full_name = $3,
      role = $4,
      is_first_time = $5
  `,
    ['dev_kasie', passwordHash, 'Dev Kasie User', 'KASIE', true],
  );

  console.log('✅ Dev user seeded: dev_kasie / DevPassword123');

  await dataSource.destroy();
}

seed().catch(console.error);
