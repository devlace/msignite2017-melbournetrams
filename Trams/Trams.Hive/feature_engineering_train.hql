SET hive.mapred.supports.subdirectories = true;
SET mapred.input.dir.recursive = true;
SET hive.optimize.listbucketing = false;
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

DROP VIEW IF EXISTS trams.v_fe_tram;
CREATE VIEW trams.v_fe_tram AS
SELECT 
	`year`,
	`month_num`,						
	`hour`,
	`location_id`,
	`location`,
	SUM(CASE WHEN perc_average_max_capacity > 0.9 THEN 1 ELSE 0 END) AS `over_perc_avg_max`
FROM
	trams.tram_stats
GROUP BY
	`year`,
	`month_num`,
	`hour`,
	`location_id`,
	`location`;


DROP VIEW IF EXISTS trams.v_fe_pedestrian_foot_traffic;
CREATE VIEW trams.v_fe_pedestrian_foot_traffic AS
SELECT 
	p.`year`,
	p.month_num,
	p.`hour`,
	st.location_id,
    AVG(hourly_counts) AS mean_count,
    STDDEV_POP(hourly_counts) AS std_count,
    MAX(hourly_counts) AS max_count,
    MIN(hourly_counts) AS min_count
FROM
	trams.pedestrian_foot_traffic p

	INNER JOIN
	trams.sensor_tram st
	ON	p.sensor_id = st.sensor_id 
GROUP BY
	p.`year`,
	p.month_num,
	p.`hour`,
	st.location_id;


SELECT 
	t.`year`,
	t.`month_num`,
	t.`hour`,
	t.`location_id`,
    CASE WHEN t.`year` >= 2015 THEN 1 ELSE 0 END AS is_free_tram_zone,
	mean_count,
	std_count,
	max_count,
	min_count,
	greater_melbourne_labour_force,
	CASE WHEN over_perc_avg_max > 0 THEN 1 ELSE 0 END AS rating
FROM
	trams.v_fe_tram t
	
	INNER JOIN
	trams.v_fe_pedestrian_foot_traffic p
	ON
		t.`year` = p.`year`
		AND	t.`month_num` = p.`month_num`
		AND t.`hour` = p.`hour` + 1
		AND t.location_id = p.location_id
	
	INNER JOIN
	trams.employment l
	ON
		t.`year` = l.`year`
		AND	t.`month_num` = l.`month_num`