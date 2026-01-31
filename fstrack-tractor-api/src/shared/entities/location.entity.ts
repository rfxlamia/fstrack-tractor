import { Entity, Column, PrimaryColumn, Index } from 'typeorm';

/**
 * Location Entity
 * Maps to the 'locations' table in production Bulldozer DB
 *
 * IMPORTANT: This entity matches the EXACT production schema.
 * - id is VARCHAR(32) - manual PK, NOT auto-generated
 * - polygon is GEOMETRY(Polygon,4326) - PostGIS type
 * - area is NUMERIC(10,6)
 */
@Entity('locations')
export class Location {
  @PrimaryColumn({ type: 'varchar', length: 32 })
  id: string;

  @Column({ type: 'varchar', length: 100, nullable: false })
  name: string;

  @Column({ type: 'numeric', precision: 10, scale: 6, nullable: false })
  area: number;

  /**
   * PostGIS Polygon geometry
   * SRID 4326 = WGS 84 (standard GPS coordinate system)
   */
  @Column({
    type: 'geometry',
    spatialFeatureType: 'Polygon',
    srid: 4326,
    nullable: false,
  })
  @Index('idx_locations_polygon', { spatial: true })
  polygon: string; // GeoJSON format: '{"type":"Polygon","coordinates":[[...]]}'

  @Column({ type: 'varchar', length: 8, nullable: true })
  type: string | null;

  @Column({ name: 'region_id', type: 'varchar', length: 10, nullable: true })
  regionId: string | null;
}
