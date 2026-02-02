import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateSchedulesTable1738573000000 implements MigrationInterface {
  name = 'CreateSchedulesTable1738573000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE schedules (
        id SERIAL PRIMARY KEY,
        work_date DATE NOT NULL,
        pattern VARCHAR(50) NOT NULL,
        shift VARCHAR(20) NOT NULL,
        status VARCHAR(20) DEFAULT 'OPEN',
        operator_id INTEGER,
        created_by INTEGER REFERENCES users(id),
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await queryRunner.query(`
      CREATE INDEX idx_schedules_work_date ON schedules(work_date)
    `);

    await queryRunner.query(`
      CREATE INDEX idx_schedules_status ON schedules(status)
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS idx_schedules_status`);
    await queryRunner.query(`DROP INDEX IF EXISTS idx_schedules_work_date`);
    await queryRunner.query(`DROP TABLE IF EXISTS schedules`);
  }
}
