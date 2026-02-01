import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreatePlantationGroupsTable1738571500000 implements MigrationInterface {
  name = 'CreatePlantationGroupsTable1738571500000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE plantation_groups (
        id VARCHAR(10) PRIMARY KEY,
        name VARCHAR(100) NOT NULL
      )
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS plantation_groups`);
  }
}
