import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Operator } from '../../operators/entities/operator.entity';
import { Unit } from '../../shared/entities/unit.entity';
import { Location } from '../../shared/entities/location.entity';

/**
 * Schedule Entity
 * Maps to the 'schedules' table in production Bulldozer DB
 *
 * IMPORTANT: This entity matches the EXACT production schema.
 * - operator_id is INTEGER (not UUID) - matches operators.id
 * - location_id is VARCHAR(32) - matches locations.id
 * - unit_id is VARCHAR(16) - matches units.id
 */
@Entity('schedules')
@Index('idx_schedules_operator_id', ['operatorId'])
@Index('idx_schedules_work_date', ['workDate'])
@Index('idx_schedules_status', ['status'])
export class Schedule {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'work_date', type: 'date', nullable: false })
  workDate: Date;

  @Column({ type: 'varchar', length: 16, nullable: false })
  pattern: string;

  @Column({ type: 'varchar', length: 16, nullable: true })
  shift: string | null;

  @Column({
    type: 'varchar',
    length: 16,
    nullable: false,
    default: 'OPEN',
  })
  status: string;

  @Column({ name: 'start_time', type: 'timestamptz', nullable: true })
  startTime: Date | null;

  @Column({ name: 'end_time', type: 'timestamptz', nullable: true })
  endTime: Date | null;

  @Column({ type: 'text', nullable: true })
  notes: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;

  // Foreign Key columns (stored as snake_case in DB)
  @Column({ name: 'location_id', type: 'varchar', length: 32, nullable: true })
  locationId: string | null;

  @Column({ name: 'unit_id', type: 'varchar', length: 16, nullable: true })
  unitId: string | null;

  @Column({ name: 'operator_id', type: 'int', nullable: true })
  operatorId: number | null;

  @Column({ name: 'report_id', type: 'uuid', nullable: true })
  reportId: string | null;

  // Relationships
  @ManyToOne(() => Location, { nullable: true })
  @JoinColumn({ name: 'location_id' })
  location: Location | null;

  @ManyToOne(() => Unit, { nullable: true })
  @JoinColumn({ name: 'unit_id' })
  unit: Unit | null;

  @ManyToOne(() => Operator, { nullable: true })
  @JoinColumn({ name: 'operator_id' })
  operator: Operator | null;
}
