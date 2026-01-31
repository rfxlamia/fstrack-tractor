import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Unit } from '../../shared/entities/unit.entity';

/**
 * Operator Entity
 * Maps to the 'operators' table in production Bulldozer DB
 *
 * IMPORTANT: This entity matches the EXACT production schema.
 * - id is INTEGER auto-increment (not UUID)
 * - user_id has UNIQUE constraint (one operator per user)
 */
@Entity('operators')
@Index('idx_operators_user_id', ['userId'], { unique: true })
export class Operator {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id', type: 'int', nullable: true })
  userId: number | null;

  @Column({ name: 'unit_id', type: 'varchar', length: 16, nullable: true })
  unitId: string | null;

  // Relationships
  @ManyToOne(() => User, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User | null;

  @ManyToOne(() => Unit, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'unit_id' })
  unit: Unit | null;
}
