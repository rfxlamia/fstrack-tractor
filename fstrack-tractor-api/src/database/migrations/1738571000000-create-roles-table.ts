import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateRolesTable1738571000000 implements MigrationInterface {
  name = 'CreateRolesTable1738571000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE roles (
        id VARCHAR(32) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      )
    `);

    await queryRunner.query(`
      INSERT INTO roles (id, name) VALUES
        ('ADMINISTRASI', 'Administrasi FE FS'),
        ('ADMINISTRASI_PG', 'Administrasi FE PG'),
        ('ASSISTANT_MANAGER', 'SubDep Head FE FS'),
        ('DEPUTY', 'Deputy'),
        ('KABAG_FIELD_ESTABLISHMENT', 'SubDep Head FE PG'),
        ('KASIE_FE', 'Kasie FE FS'),
        ('KASIE_PG', 'Kasie FE PG'),
        ('MANAGER', 'Manager FE FS'),
        ('MANAGER_FE_PG', 'Manager FE PG'),
        ('MANDOR', 'Mandor'),
        ('MASTER_LOKASI', 'Master Lokasi'),
        ('OPERATOR', 'Operator'),
        ('OPERATOR_PG1', 'Operator PG 1'),
        ('PG_MANAGER', 'PG Manager'),
        ('SUPERADMIN', 'Super Admin')
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS roles`);
  }
}
