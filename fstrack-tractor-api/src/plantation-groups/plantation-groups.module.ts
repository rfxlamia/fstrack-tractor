import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PlantationGroup } from './entities/plantation-group.entity';

@Module({
  imports: [TypeOrmModule.forFeature([PlantationGroup])],
  exports: [TypeOrmModule],
})
export class PlantationGroupsModule {}
