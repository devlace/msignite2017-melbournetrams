

SET hive.mapred.supports.subdirectories = true;
SET mapred.input.dir.recursive = true;
SET hive.optimize.listbucketing = false;
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

CREATE DATABASE IF NOT EXISTS `trams`;

--pedestrian_foot_traffic
DROP TABLE IF EXISTS `pedestrian_foot_traffic`;
CREATE EXTERNAL TABLE `pedestrian_foot_traffic` (
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
LOCATION 'wasbs://aemodw@hdstor74tac7ufwt3i2.blob.core.windows.net/example/data/ig/initial/pedestrian_foot_traffic/'
tblproperties ("skip.header.line.count"="1");

DROP TABLE IF EXISTS `trams`.`pedestrian_foot_traffic`;
CREATE TABLE `trams`.`pedestrian_foot_traffic` (
    `year` INT,
    `month` STRING,
    `month_num` INT,
    `mdate` INT,
    `day` STRING,
    `hour` INT,
    `date_time` TIMESTAMP,
    `sensor_id` STRING,
    `sensor_name` STRING,
    `hourly_counts` INT,
    `df_loaded_date` TIMESTAMP
) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS ORC;

INSERT OVERWRITE TABLE `trams`.`pedestrian_foot_traffic`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `pedestrian_foot_traffic` d;

DROP TABLE IF EXISTS `pedestrian_foot_traffic`;

--TRAM_STATS

DROP TABLE IF EXISTS `tram_stats`;
CREATE EXTERNAL TABLE `tram_stats` (
    `year` INT,
    `month` STRING,
    `month_num` INT,
  	`hour` INT,
    `cordoned` INT,
    `location_id` INT,
    `location` STRING,
    `route_id` INT, 
    `direction` STRING,
    `rolling_hour_start` STRING,
    `rolling_hour_end` STRING,
    `rolling_hour_average_load` FLOAT,
    `rolling_hour_max_capacity` FLOAT,
    `perc_average_max_capacity` FLOAT
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar"     = '"',
"escapeChar"    = "\\"
) 
STORED AS TEXTFILE 
LOCATION 'wasbs://aemodw@hdstor74tac7ufwt3i2.blob.core.windows.net/example/data/ig/initial/tram_stats/'
tblproperties ("skip.header.line.count"="1");

DROP TABLE IF EXISTS `trams`.`tram_stats`;
CREATE TABLE `trams`.`tram_stats` (
    `year` INT,
    `month` STRING,
    `month_num` INT,
  	`hour` INT,
    `cordoned` INT,
    `location_id` INT,
    `location` STRING,
    `route_id` INT, 
    `direction` STRING,
    `rolling_hour_start` STRING,
    `rolling_hour_end` STRING,
    `rolling_hour_average_load` FLOAT,
    `rolling_hour_max_capacity` FLOAT,
    `perc_average_max_capacity` FLOAT,
    `df_loaded_date` TIMESTAMP
) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS ORC;

INSERT OVERWRITE TABLE `trams`.`tram_stats`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `tram_stats` d;

DROP TABLE IF EXISTS `tram_stats`;

--employment

DROP TABLE IF EXISTS `employment`;
CREATE EXTERNAL TABLE `employment` (
    `year` INT,
    `month` STRING,
    `month_num` INT,
  	`year_month` TIMESTAMP,
    `greater_melbourne_labour_force` INT
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar"     = '"',
"escapeChar"    = "\\"
) 
STORED AS TEXTFILE 
LOCATION 'wasbs://aemodw@hdstor74tac7ufwt3i2.blob.core.windows.net/example/data/ig/initial/employment/'
tblproperties ("skip.header.line.count"="1");

DROP TABLE IF EXISTS `trams`.`employment`;
CREATE TABLE `trams`.`employment` (
    `year` INT,
    `month` STRING,
    `month_num` INT,
  	`year_month` TIMESTAMP,
    `greater_melbourne_labour_force` INT,
    `df_loaded_date` TIMESTAMP
) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS ORC;

INSERT OVERWRITE TABLE `trams`.`employment`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `employment` d;

DROP TABLE IF EXISTS `employment`;

--Tram location
DROP TABLE IF EXISTS `tram_location`;
CREATE EXTERNAL TABLE `tram_location` (
    `location_id` INT,
    `location` STRING
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar"     = '"',
"escapeChar"    = "\\"
) 
STORED AS TEXTFILE 
LOCATION 'wasbs://aemodw@hdstor74tac7ufwt3i2.blob.core.windows.net/example/data/ig/initial/tram_location/'
tblproperties ("skip.header.line.count"="1");

DROP TABLE IF EXISTS `trams`.`tram_location`;
CREATE TABLE `trams`.`tram_location` (
    `location_id` INT,
    `location` STRING,
    `df_loaded_date` TIMESTAMP
) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS ORC;

INSERT OVERWRITE TABLE `trams`.`tram_location`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `tram_location` d;

DROP TABLE IF EXISTS `tram_location`;

--sensor
DROP TABLE IF EXISTS `sensor`;
CREATE EXTERNAL TABLE `sensor` (
    `sensor_id` INT,
    `sensor_name` STRING,
    `sensor_desc` STRING,
    `status` STRING,
    `year_installed` INT,
    `location_type` STRING,
    `geometry` STRING,
    `latitude` FLOAT,
    `longitude` FLOAT
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar"     = '"',
"escapeChar"    = "\\"
) 
STORED AS TEXTFILE 
LOCATION 'wasbs://aemodw@hdstor74tac7ufwt3i2.blob.core.windows.net/example/data/ig/initial/sensor/'
tblproperties ("skip.header.line.count"="1");

DROP TABLE IF EXISTS `trams`.`sensor`;
CREATE TABLE `trams`.`sensor` (
    `sensor_id` INT,
    `sensor_name` STRING,
    `sensor_desc` STRING,
    `status` STRING,
    `year_installed` INT,
    `location_type` STRING,
    `geometry` STRING,
    `latitude` FLOAT,
    `longitude` FLOAT,
    `df_loaded_date` TIMESTAMP
) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS ORC;

INSERT OVERWRITE TABLE `trams`.`sensor`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `sensor` d;

DROP TABLE IF EXISTS `sensor`;

--sensor_tram
DROP TABLE IF EXISTS `sensor_tram`;
CREATE EXTERNAL TABLE `sensor_tram` (
    `sensor_id` INT,
    `location_id` INT
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar"     = '"',
"escapeChar"    = "\\"
) 
STORED AS TEXTFILE 
LOCATION 'wasbs://aemodw@hdstor74tac7ufwt3i2.blob.core.windows.net/example/data/ig/initial/sensor_tram/'
tblproperties ("skip.header.line.count"="1");

DROP TABLE IF EXISTS `trams`.`sensor_tram`;
CREATE TABLE `trams`.`sensor_tram` (
    `sensor_id` INT,
    `location_id` INT,
    `df_loaded_date` TIMESTAMP
) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS ORC;

INSERT OVERWRITE TABLE `trams`.`sensor_tram`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `sensor_tram` d;

DROP TABLE IF EXISTS `sensor_tram`;