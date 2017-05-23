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
