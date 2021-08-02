CREATE TABLESPACE sb_mbackup
DATAFILE 'sb_mbackup.dat'
SIZE 200M
 AUTOEXTEND ON NEXT 100M
 SEGMENT SPACE MANAGEMENT AUTO;

CREATE USER u_sb_mbackup
  IDENTIFIED BY "12345"
    DEFAULT TABLESPACE sb_mbackup;

GRANT CONNECT,RESOURCE TO u_sb_mbackup;
GRANT UNLIMITED TABLESPACE TO u_sb_mbackup;

DROP TABLE u_sb_mbackup.t_geo_denorm;
CREATE TABLE u_sb_mbackup.t_geo_denorm AS 
SELECT
      lpad(' ', LEVEL * 2 - 1, '_') || child_geo_id                     child_id
     ,(SELECT region_desc
        FROM u_dw_references.cu_countries countries
            WHERE links.child_geo_id = countries.geo_id)                country_name
    ,CONNECT_BY_ISLEAF                                                  is_leaf_
    ,decode (LEVEL, 1, '_r', 
                    2, '_b', 
                    3, '_l')                                            node_type
    ,parent_geo_id                                                      parent_id
    ,sys_connect_by_path(parent_geo_id, '/')                            full_path
    ,(SELECT region_desc
        FROM u_dw_references.cu_geo_regions regions
            WHERE links.child_geo_id = regions.geo_id)                  region_name

FROM u_dw_references.t_geo_object_links links
CONNECT BY PRIOR child_geo_id = parent_geo_id;
