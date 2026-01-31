import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Unit } from './entities/unit.entity';
import { Location } from './entities/location.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Unit, Location])],
  exports: [TypeOrmModule],
})
export class SharedModule {}
