import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddScheduleStatusCheckConstraint1769942419371 implements MigrationInterface {
  name = 'AddScheduleStatusCheckConstraint1769942419371';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Clean up any existing invalid status values before adding constraint
    // This ensures migration succeeds even if there's legacy data
    await queryRunner.query(
      `UPDATE schedules SET status = 'OPEN' WHERE status NOT IN ('OPEN', 'CLOSED', 'CANCEL')`,
    );

    // Add CHECK constraint to ensure status values are valid
    await queryRunner.query(
      `ALTER TABLE schedules ADD CONSTRAINT chk_schedules_status CHECK (status IN ('OPEN', 'CLOSED', 'CANCEL'))`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop the CHECK constraint
    await queryRunner.query(
      `ALTER TABLE schedules DROP CONSTRAINT IF EXISTS chk_schedules_status`,
    );
  }
}
