import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('roles')
export class Role {
  @PrimaryColumn({ type: 'varchar', length: 32 })
  id: string; // e.g., 'KASIE_PG', 'KASIE_FE'

  @Column({ type: 'varchar', length: 255 })
  name: string; // e.g., 'Kasie FE PG'

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;
}
