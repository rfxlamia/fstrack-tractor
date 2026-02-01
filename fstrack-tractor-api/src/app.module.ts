import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import configuration from './config/configuration';
import { HealthModule } from './health/health.module';
import { DatabaseModule } from './database/database.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { WeatherModule } from './weather/weather.module';
import { SchedulesModule } from './schedules/schedules.module';
import { OperatorsModule } from './operators/operators.module';
import { SharedModule } from './shared/shared.module';
import { RolesModule } from './roles/roles.module';
import { PlantationGroupsModule } from './plantation-groups/plantation-groups.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      envFilePath: ['.env.development', '.env'],
    }),
    HealthModule,
    DatabaseModule,
    RolesModule,
    PlantationGroupsModule,
    UsersModule,
    AuthModule,
    WeatherModule,
    SchedulesModule,
    OperatorsModule,
    SharedModule,
  ],
})
export class AppModule {}
