import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';
import { UserRole } from '../users/enums/user-role.enum';
import * as bcrypt from 'bcrypt';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class SeedService implements OnModuleInit {
  private readonly logger = new Logger(SeedService.name);

  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    private configService: ConfigService,
  ) {}

  async onModuleInit() {
    // Only auto-seed in staging environment
    if (this.configService.get('nodeEnv') !== 'staging') {
      return;
    }

    await this.seedDevUser();
  }

  private async seedDevUser() {
    const existingUser = await this.usersRepository.findOne({
      where: { username: 'dev_kasie' },
    });

    if (existingUser) {
      this.logger.log('Dev user already exists: dev_kasie');
      return;
    }

    const passwordHash = await bcrypt.hash('DevPassword123', 10);

    const devUser = this.usersRepository.create({
      username: 'dev_kasie',
      passwordHash,
      fullName: 'Dev Kasie User',
      role: UserRole.KASIE,
      isFirstTime: true,
    });

    await this.usersRepository.save(devUser);
    this.logger.log('Dev user seeded successfully: dev_kasie');
  }
}
