import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateUsersTable1738572000000 implements MigrationInterface {
  name = 'CreateUsersTable1738572000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        fullname VARCHAR(255) NOT NULL,
        username VARCHAR(50) UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role_id VARCHAR(32) REFERENCES roles(id),
        plantation_group_id VARCHAR(10) REFERENCES plantation_groups(id),
        is_first_time BOOLEAN DEFAULT TRUE,
        failed_login_attempts INT DEFAULT 0,
        locked_until TIMESTAMP,
        last_login TIMESTAMP,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await queryRunner.query(
      `CREATE INDEX idx_users_username ON users(username)`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS idx_users_username`);
    await queryRunner.query(`DROP TABLE IF EXISTS users`);
  }
}
