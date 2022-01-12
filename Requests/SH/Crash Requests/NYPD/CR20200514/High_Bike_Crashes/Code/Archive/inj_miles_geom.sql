SELECT id, street, borough, bike_inj, shape_length_corridor, mileage, inj_rate, 
       segmentid, shape_length_segmentid, geom
  FROM working.inj_miles_geom;


ALTER TABLE working.inj_miles_geom 
ALTER COLUMN geom TYPE geometry USING geom::geometry


ALTER TABLE working.inj_miles_geom 
ALTER COLUMN mileage TYPE double precision USING mileage::double precision


ALTER TABLE working.inj_miles_geom 
ALTER COLUMN shape_length_corridor TYPE double precision USING shape_length_corridor::double precision


ALTER TABLE working.inj_miles_geom 
ALTER COLUMN shape_length_segmentid TYPE double precision USING shape_length_segmentid::double precision




ALTER TABLE working.inj_miles_geom RENAME COLUMN "shape_length_x" TO "shape_length_corridor";
ALTER TABLE working.inj_miles_geom RENAME COLUMN "shape_length_y" TO "shape_length_segmentid"