SET hive.mapred.supports.subdirectories = true;
SET mapred.input.dir.recursive = true;
SET hive.optimize.listbucketing = false;
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

--wasbs://data@lacetramsbstor.blob.core.windows.net/data/
--wasbs://data@lacetramsbstor.blob.core.windows.net/data/

SET hive.mapred.supports.subdirectories = true;
SET mapred.input.dir.recursive = true;
SET hive.optimize.listbucketing = false;
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

CREATE DATABASE IF NOT EXISTS `trams`;

--pedestrian_foot_traffic
DROP TABLE IF EXISTS `pedestrian_foot_traffic_${hiveconf:SliceText}`;
CREATE EXTERNAL TABLE `pedestrian_foot_traffic_${hiveconf:SliceText}` (
    `year` INT,
    `month` STRING,
    `month_num` INT,
    `mdate` INT,
    `day` STRING,
    `hour` INT,
    `date_time` TIMESTAMP,
    `sensor_id` STRING,
    `sensor_name` STRING,
    `hourly_counts` INT
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar"     = '"',
"escapeChar"    = "\\"
)
STORED AS TEXTFILE 
LOCATION '${hiveconf:FileLocation}';

INSERT INTO TABLE `trams`.`pedestrian_foot_traffic`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `pedestrian_foot_traffic` d;

DROP TABLE IF EXISTS `pedestrian_foot_traffic_${hiveconf:SliceText}`;

