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


DROP TABLE u_sb_mbackup.test_denorm_vehicles;
CREATE TABLE u_sb_mbackup.test_denorm_vehicles AS
SELECT 
       ROWNUM                                                    vehicle_id
      ,dbms_random.VALUE(1000, 9999)                             vehicle_code
      ,dbms_random.STRING('U', 20)                               vehicle_desc
      ,round(dbms_random.VALUE(1, 16))                           vehicle_mark
      ,'fuel_type_' || to_char(round(dbms_random.VALUE(1, 5)))   fuel_type
FROM ( 
SELECT ROWNUM
FROM dual
CONNECT BY LEVEL <= 100 );
SELECT * FROM u_sb_mbackup.test_denorm_vehicles;



DROP TABLE u_sb_mbackup.test_denorm;
CREATE TABLE u_sb_mbackup.test_denorm AS 
SELECT
      vehicle_id               vehicle_id
     ,vehicle_mark             vehicle_mark
     ,CONNECT_BY_ISLEAF        is_leaf_
     ,sys_connect_by_path(vehicle_mark, '/') path_    
     ,CONNECT_BY_ISCYCLE AS    CYCLE
     ,LEVEL                    level_ 
     ,CONNECT_BY_ROOT vehicle_id root_id

FROM u_sb_mbackup.test_denorm_vehicles vehicles
START WITH vehicle_mark = 1
CONNECT BY NOCYCLE PRIOR vehicle_id = vehicle_mark
ORDER BY vehicle_mark;

SELECT * FROM u_sb_mbackup.test_denorm;


