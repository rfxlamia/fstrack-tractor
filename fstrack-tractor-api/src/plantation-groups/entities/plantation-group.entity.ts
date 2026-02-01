import { Entity, PrimaryColumn, Column } from 'typeorm';

/**
 * PlantationGroup Entity
 * Maps to 'plantation_groups' table in production Bulldozer DB
 *
 * NOTE: No timestamps by design - matches production schema exactly
 */
@Entity('plantation_groups')
export class PlantationGroup {
  @PrimaryColumn({ type: 'varchar', length: 10 })
  id: string; // e.g., 'PG001'

  @Column({ type: 'varchar', length: 100 })
  name: string;
}
