TRUNCATE TABLE dbo.pedestrian_foot_traffic;
TRUNCATE TABLE dbo.trams_features_scored;

--pedestrian_foot_traffic
DROP EXTERNAL TABLE dbo.pedestrian_foot_traffic_ext;
CREATE EXTERNAL TABLE dbo.pedestrian_foot_traffic_ext (
	[year] INT,
	[month] VARCHAR(100),
	[month_num] INT,
	[mdate] INT,
	[day] VARCHAR(100),
	[hour] INT,
	[date_time] DATETIME2(0),
	sensor_id VARCHAR(100),
	sensor_name VARCHAR(500),
	hourly_counts INT
)
WITH (
       LOCATION = 'pedestrian_foot_traffic/initial/',
       DATA_SOURCE = blob_data_source,
       FILE_FORMAT = csv_file,
	   REJECT_TYPE = VALUE,
		REJECT_VALUE = 1
);

CREATE TABLE dbo.pedestrian_foot_traffic
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
)
AS
SELECT * FROM dbo.pedestrian_foot_traffic_ext;