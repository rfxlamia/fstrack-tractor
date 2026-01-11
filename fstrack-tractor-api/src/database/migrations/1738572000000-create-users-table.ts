import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateUsersTable1738572000000 implements MigrationInterface {
  name = 'CreateUsersTable1738572000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Enable uuid-ossp extension for UUID generation
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`);

    // Create users table with all 12 columns
    await queryRunner.query(`
      CREATE TABLE users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        username VARCHAR(50) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(100) NOT NULL,
        role VARCHAR(20) NOT NULL,
        estate_id UUID,
        is_first_time BOOLEAN DEFAULT TRUE,
        failed_login_attempts INT DEFAULT 0,
        locked_until TIMESTAMP,
        last_login TIMESTAMP,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    // Create index on username column for login performance
    await queryRunner.query(`CREATE INDEX idx_users_username ON users(username)`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop index first (foreign key dependency)
    await queryRunner.query(`DROP INDEX IF EXISTS idx_users_username`);

    // Drop users table
    await queryRunner.query(`DROP TABLE IF EXISTS users`);
  }
}
