SET hive.mapred.supports.subdirectories = true;
SET mapred.input.dir.recursive = true;
SET hive.optimize.listbucketing = false;
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

CREATE DATABASE IF NOT EXISTS `trams`;

--pedestrian_foot_traffic
DROP TABLE IF EXISTS `trams`.`pedestrian_foot_traffic_ext`;
CREATE EXTERNAL TABLE `trams`.`pedestrian_foot_traffic_ext` (
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
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/initial/pedestrian_foot_traffic/'
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
STORED AS ORC
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/base/pedestrian_foot_traffic/';

INSERT OVERWRITE TABLE `trams`.`pedestrian_foot_traffic`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `trams`.`pedestrian_foot_traffic_ext` d;

DROP TABLE IF EXISTS `trams`.`pedestrian_foot_traffic_ext`;

--TRAM_STATS
DROP TABLE IF EXISTS `trams`.`tram_stats_ext`;
CREATE EXTERNAL TABLE `trams`.`tram_stats_ext` (
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
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/initial/tram_stats/'
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
STORED AS ORC
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/base/tram_stats/';

INSERT OVERWRITE TABLE `trams`.`tram_stats`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `trams`.`tram_stats_ext` d;

DROP TABLE IF EXISTS `trams`.`tram_stats_ext`;

--employment
DROP TABLE IF EXISTS `trams`.`employment_ext`;
CREATE EXTERNAL TABLE `trams`.`employment_ext` (
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
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/initial/employment/'
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
STORED AS ORC
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/base/employment/';

INSERT OVERWRITE TABLE `trams`.`employment`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `trams`.`employment_ext` d;

DROP TABLE IF EXISTS `trams`.`employment_ext`;

--Tram location
DROP TABLE IF EXISTS `trams`.`tram_location_ext`;
CREATE EXTERNAL TABLE `trams`.`tram_location_ext` (
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
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/initial/tram_location/'
tblproperties ("skip.header.line.count"="1");

DROP TABLE IF EXISTS `trams`.`tram_location`;
CREATE TABLE `trams`.`tram_location` (
    `location_id` INT,
    `location` STRING,
    `df_loaded_date` TIMESTAMP
) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS ORC
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/base/tram_location/';

INSERT OVERWRITE TABLE `trams`.`tram_location`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `trams`.`tram_location_ext` d;

DROP TABLE IF EXISTS `trams`.`tram_location_ext`;

--sensor
DROP TABLE IF EXISTS `trams`.`sensor_ext`;
CREATE EXTERNAL TABLE `trams`.`sensor_ext` (
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
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/initial/sensor/'
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
STORED AS ORC
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/base/sensor/';

INSERT OVERWRITE TABLE `trams`.`sensor`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `trams`.`sensor_ext` d;

DROP TABLE IF EXISTS `trams`.`sensor_ext`;

--sensor_tram
DROP TABLE IF EXISTS `trams`.`sensor_tram_ext`;
CREATE EXTERNAL TABLE `trams`.`sensor_tram_ext` (
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
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/initial/sensor_tram/'
tblproperties ("skip.header.line.count"="1");

DROP TABLE IF EXISTS `trams`.`sensor_tram`;
CREATE TABLE `trams`.`sensor_tram` (
    `sensor_id` INT,
    `location_id` INT,
    `df_loaded_date` TIMESTAMP
) 
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS ORC
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/base/sensor_tram/';

INSERT OVERWRITE TABLE `trams`.`sensor_tram`
SELECT 
    d.*, 
    current_timestamp AS df_loaded_date 
FROM `trams`.`sensor_tram_ext` d;

DROP TABLE IF EXISTS `trams`.`sensor_tram_ext`;


--- trams_features_unscored
DROP TABLE IF EXISTS `trams`.`trams_features_unscored`;
CREATE TABLE trams.`trams_features_unscored` (
    `location_id` INT,
    `is_free_tram_zone` INT,
    `mean_count` FLOAT,
    `std_count` FLOAT,
    `max_count` FLOAT,
    `min_count` FLOAT,
    `greater_melbourne_labour_force` FLOAT
)
PARTITIONED BY (
    `year` INT,
    `month_num` INT,
    `day` INT,
    `hour` INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar"     = '"',
"escapeChar"    = "\\"
)
STORED AS TEXTFILE 
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/base/tram_features_unscored/';


--- trams_features_scored
DROP TABLE IF EXISTS `trams`.`trams_features_scored`;
CREATE TABLE trams.`trams_features_scored` (
    `year` INT,
    `month_num` INT,
    `hour` INT,
    `location_id` INT,
    `is_free_tram_zone` INT,
    `mean_count` FLOAT,
    `std_count` FLOAT,
    `max_count` FLOAT,
    `min_count` FLOAT,
    `greater_melbourne_labour_force` FLOAT,
    `scored_labels` INT,
    `scored_prob` INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
"separatorChar" = ",",
"quoteChar"     = '"',
"escapeChar"    = "\\"
)
STORED AS TEXTFILE 
LOCATION 'adl://lacetramsdlstor.azuredatalakestore.net/data/trams/base/tram_features_scored/';
