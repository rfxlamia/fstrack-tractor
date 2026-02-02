import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';
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
    // Only auto-seed in staging/development environment
    const env = this.configService.get<string>('nodeEnv');
    if (env !== 'staging' && env !== 'development') {
      return;
    }

    await this.seedDevUser();
  }

  private async seedDevUser() {
    // Check for OLD dev_kasie user (from previous implementation)
    const oldDevUser = await this.usersRepository.findOne({
      where: { username: 'dev_kasie' },
    });
    if (oldDevUser) {
      this.logger.log(
        'Found old dev_kasie user - will be replaced by new dev users',
      );
      await this.usersRepository.delete({ username: 'dev_kasie' });
    }

    // Seed new dev users with distinct roles
    const devUsers = [
      {
        username: 'dev_kasie_pg',
        fullname: 'Dev Kasie PG User',
        roleId: 'KASIE_PG',
      },
      {
        username: 'dev_kasie_fe',
        fullname: 'Dev Kasie FE User',
        roleId: 'KASIE_FE',
      },
      {
        username: 'dev_operator',
        fullname: 'Dev Operator User',
        roleId: 'OPERATOR',
      },
    ];

    const passwordHash = await bcrypt.hash('DevPassword123', 10);

    for (const userData of devUsers) {
      const exists = await this.usersRepository.findOne({
        where: { username: userData.username },
      });
      if (exists) {
        this.logger.log(`Dev user already exists: ${userData.username}`);
        continue;
      }

      const user = this.usersRepository.create({
        ...userData,
        password: passwordHash,
        isFirstTime: true,
      });
      await this.usersRepository.save(user);
      this.logger.log(`Dev user seeded: ${userData.username}`);
    }
  }
}
