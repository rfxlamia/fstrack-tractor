import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateSchedulesTable1738573000000 implements MigrationInterface {
  name = 'CreateSchedulesTable1738573000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE schedules (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        work_date DATE NOT NULL,
        pattern VARCHAR(16) NOT NULL,
        shift VARCHAR(16),
        status VARCHAR(16) DEFAULT 'OPEN',
        start_time TIMESTAMPTZ,
        end_time TIMESTAMPTZ,
        notes TEXT,
        operator_id INTEGER REFERENCES operators(id),
        location_id VARCHAR(32) REFERENCES locations(id),
        unit_id VARCHAR(16) REFERENCES units(id),
        report_id UUID,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      )
    `);

    await queryRunner.query(`
      CREATE INDEX idx_schedules_operator_id ON schedules(operator_id)
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
