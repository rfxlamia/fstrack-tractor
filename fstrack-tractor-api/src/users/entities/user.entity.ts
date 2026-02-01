import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 50, unique: true })
  @Index('idx_users_username')
  username: string;

  @Column({ type: 'text' })
  password: string; // was: passwordHash with column 'password_hash'

  @Column({ type: 'varchar', length: 255 })
  fullname: string; // was: fullName with column 'full_name'

  @Column({ name: 'role_id', type: 'varchar', length: 32, nullable: true })
  roleId: string | null; // was: role: UserRole (enum)

  @Column({
    name: 'plantation_group_id',
    type: 'varchar',
    length: 10,
    nullable: true,
  })
  plantationGroupId: string | null; // was: estateId: string (UUID)

  @Column({ name: 'is_first_time', type: 'boolean', default: true })
  isFirstTime: boolean;

  @Column({ name: 'failed_login_attempts', type: 'int', default: 0 })
  failedLoginAttempts: number;

  @Column({ name: 'locked_until', type: 'timestamp', nullable: true })
  lockedUntil: Date | null;

  @Column({ name: 'last_login', type: 'timestamp', nullable: true })
  lastLogin: Date | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
