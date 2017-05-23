CREATE MASTER KEY;

CREATE DATABASE SCOPED CREDENTIAL blob_db_credential
WITH
    IDENTITY = 'user',
    SECRET = 'sL6Vnjf8/AwWqAgyKSNSPdHpTaxk/oz8QWp2uCj2OKyyuMvYUFZt7Rh1i1D6dtLNu4nFjpiJQyw1adN0IK0jpg=='
;

CREATE EXTERNAL DATA SOURCE blob_data_source
WITH (
       TYPE = HADOOP,
       LOCATION = 'wasbs://data@lacetramsbstor.blob.core.windows.net',
       CREDENTIAL = blob_db_credential
);

CREATE EXTERNAL FILE FORMAT csv_file WITH 
(
	FORMAT_TYPE = DELIMITEDTEXT, 
	FORMAT_OPTIONS (FIELD_TERMINATOR = N',', STRING_DELIMITER = N'"', USE_TYPE_DEFAULT = False)
)

-- B: Create a database scoped credential
-- IDENTITY: Pass the client id and OAuth 2.0 Token Endpoint taken from your Azure Active Directory Application
-- SECRET: Provide your AAD Application Service Principal key.
-- For more information on Create Database Scoped Credential: https://msdn.microsoft.com/en-us/library/mt270260.aspx

CREATE DATABASE SCOPED CREDENTIAL adl_db_credential
WITH
    IDENTITY = 'ce671692-869d-4fcd-a9a8-07ab9d579866@https://login.windows.net/26413907-7646-48ee-8f93-5a56a7794210/oauth2/token',
    SECRET = 'c2iykIBzJ4OzJ9ARIaWTvjHvq/u0efMZML1pCKLsrzg='
;

-- C: Create an external data source
-- TYPE: HADOOP - PolyBase uses Hadoop APIs to access data in Azure Data Lake Store.
-- LOCATION: Provide Azure Data Lake accountname and URI
-- CREDENTIAL: Provide the credential created in the previous step.

DROP EXTERNAL DATA SOURCE adl_data_source
CREATE EXTERNAL DATA SOURCE adl_data_source
WITH (
    TYPE = HADOOP,
    LOCATION = 'adl://lacetramsdlstor.azuredatalakestore.net',
    CREDENTIAL = adl_db_credential
);
----------------------------------------------------------------------------------------
-- TABLES


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

--tram stats
DROP EXTERNAL TABLE dbo.tram_stats_ext;
CREATE EXTERNAL TABLE dbo.tram_stats_ext (
	[year] INT,
    [month] VARCHAR(100),
    [month_num] INT,
  	[hour] INT,
    [cordoned] INT,
    [location_id] INT,
    [location] VARCHAR(100),
    [route] VARCHAR(100), 
    [direction] VARCHAR(100),
    [rolling_hour_start] VARCHAR(100),
    [rolling_hour_end] VARCHAR(100),
    [rolling_hour_average_load] FLOAT,
    [rolling_hour_max_capacity] FLOAT,
    [perc_average_max_capacity] FLOAT
)
WITH (
       LOCATION = 'tram_stats/',
       DATA_SOURCE = blob_data_source,
       FILE_FORMAT = csv_file,
	   REJECT_TYPE = VALUE,
	   REJECT_VALUE = 1
);
CREATE TABLE dbo.tram_stats
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
)
AS
SELECT * FROM dbo.tram_stats_ext;


--employment
DROP EXTERNAL TABLE dbo.employment_ext;
CREATE EXTERNAL TABLE dbo.employment_ext (
	[year] INT,
    [month] VARCHAR(100),
    [month_num] INT,
  	[year_month] DATETIME2(0),
    [greater_melbourne_labour_force] INT
)
WITH (
       LOCATION = 'employment/',
       DATA_SOURCE = blob_data_source,
       FILE_FORMAT = csv_file,
	   REJECT_TYPE = VALUE,
	   REJECT_VALUE = 1
);
CREATE TABLE dbo.employment
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
)
AS
SELECT * FROM dbo.employment_ext;


--tram location
DROP EXTERNAL TABLE dbo.tram_location_ext;
CREATE EXTERNAL TABLE dbo.tram_location_ext (
	[location_id] INT,
    [location] VARCHAR(100)
)
WITH (
       LOCATION = 'tram_location/',
       DATA_SOURCE = blob_data_source,
       FILE_FORMAT = csv_file,
	   REJECT_TYPE = VALUE,
	   REJECT_VALUE = 1
);
CREATE TABLE dbo.tram_location
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
)
AS
SELECT * FROM dbo.tram_location_ext;

--sensor
DROP EXTERNAL TABLE dbo.sensor_ext;
CREATE EXTERNAL TABLE dbo.sensor_ext (
	[sensor_id] INT,
    [sensor_name] VARCHAR(100),
    [sensor_desc] VARCHAR(100),
    [status] VARCHAR(100),
    [year_installed] INT,
    [location_type] VARCHAR(100),
    [geometry] VARCHAR(100),
    [latitude] FLOAT,
    [longitude] FLOAT
)
WITH (
       LOCATION = 'sensor/',
       DATA_SOURCE = blob_data_source,
       FILE_FORMAT = csv_file,
	   REJECT_TYPE = VALUE,
	   REJECT_VALUE = 1
);
CREATE TABLE dbo.sensor
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
)
AS
SELECT * FROM dbo.sensor_ext;


--sensor tram
DROP EXTERNAL TABLE dbo.sensor_tram_ext;
CREATE EXTERNAL TABLE dbo.sensor_tram_ext (
	[sensor_id] INT,
    [location_id] INT
)
WITH (
       LOCATION = 'sensor_tram/',
       DATA_SOURCE = blob_data_source,
       FILE_FORMAT = csv_file,
	   REJECT_TYPE = VALUE,
	   REJECT_VALUE = 1
);
CREATE TABLE dbo.sensor_tram
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
)
AS
SELECT * FROM dbo.sensor_tram_ext;


--trams_features_scored

--DROP TABLE dbo.trams_features_scored
CREATE TABLE dbo.trams_features_scored (
	[year] INT,
	month_num INT,
	[hour] INT,
	[day] [int] NULL,
	location_id INT,
	is_free_tram_zone INT,
	mean_count FLOAT,
	std_count FLOAT,
	max_count FLOAT,
	min_count FLOAT,
	greater_melbourne_labour_force FLOAT,
	scored_labels INT,
	scored_prob FLOAT
)
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
)

SELECT * FROM dbo.trams_features_scored