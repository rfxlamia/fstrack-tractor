import {
  Entity,
  Column,
  PrimaryColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * Unit Entity
 * Maps to the 'units' table in production Bulldozer DB
 *
 * IMPORTANT: This entity matches the EXACT production schema.
 * - id is VARCHAR(16) - manual PK, NOT auto-generated
 * - threshold columns are NUMERIC(6,2) with defaults
 */
@Entity('units')
export class Unit {
  @PrimaryColumn({ type: 'varchar', length: 16 })
  id: string;

  @Column({ type: 'varchar', length: 255, nullable: false })
  name: string;

  @Column({ type: 'varchar', length: 255, nullable: false })
  brand: string;

  @Column({
    name: 'threshold_one',
    type: 'numeric',
    precision: 6,
    scale: 2,
    nullable: false,
    default: 2.84,
  })
  thresholdOne: number;

  @Column({
    name: 'threshold_two',
    type: 'numeric',
    precision: 6,
    scale: 2,
    nullable: false,
    default: 16.6,
  })
  thresholdTwo: number;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;

  @Column({
    name: 'plantation_group_id',
    type: 'varchar',
    length: 10,
    nullable: true,
  })
  plantationGroupId: string | null;

  @Column({ name: 'node_id', type: 'varchar', length: 16, nullable: true })
  nodeId: string | null;
}
