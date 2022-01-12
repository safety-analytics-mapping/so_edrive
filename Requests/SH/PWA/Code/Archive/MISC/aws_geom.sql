SELECT geom
  FROM working.aws_geom;


ALTER TABLE working.aws_geom

	                ALTER COLUMN aws_geom TYPE Geometry USING aws_geom::Geometry;
	                
	                grant all on aws_geom to public;