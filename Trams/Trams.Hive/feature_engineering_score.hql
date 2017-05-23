SET hive.mapred.supports.subdirectories = true;
SET mapred.input.dir.recursive = true;
SET hive.optimize.listbucketing = false;
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

--records between 30 days of a given date and until the given date (using the pedestrian_foot_traffic.datetime as record's date)
--2592000 = 30 * 24 * 60 * 60;
--SELECT *
--FROM trams.pedestrian_foot_traffic2
--WHERE
--    unix_timestamp('2010-01-01 01:00', 'yyyy-MM-dd HH:mm') - unix_timestamp(pedestrian_foot_traffic2.date_time) < 2592000
---	AND unix_timestamp(pedestrian_foot_traffic2.date_time) <= unix_timestamp('2010-01-01 01:00', 'yyyy-MM-dd HH:mm');           

DROP VIEW IF EXISTS `trams.v_pedestrian_foot_traffic_${hiveconf:SliceText}`;
CREATE VIEW `trams.v_pedestrian_foot_traffic` AS
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
WHERE
    (unix_timestamp('${hiveconf:SliceEnd}', 'yyyy-MM-dd HH:mm') - unix_timestamp(p.date_time) < 2592000)
    AND (unix_timestamp(p.date_time) <= unix_timestamp('${hiveconf:SliceEnd}', 'yyyy-MM-dd HH:mm'))
GROUP BY
	p.`year`,
	p.month_num,
	p.`hour`,
	st.location_id;

--Create 
CREATE VIEW trams.`v_trams_features_unscored_${hiveconf:SliceText}` AS
SELECT 
	p.`year`,
	p.`month_num`,
	p.`hour`,
	p.`location_id`,
    CASE WHEN p.`year` >= 2015 THEN 1 ELSE 0 END AS is_free_tram_zone,
	mean_count,
	std_count,
	max_count,
	min_count,
	greater_melbourne_labour_force
FROM
	trams.v_pedestrian_foot_traffic p

	INNER JOIN
	trams.employment l
	ON
		p.`year` = l.`year`
		AND	p.`month_num` = l.`month_num`;

DROP VIEW IF EXISTS `trams.v_pedestrian_foot_traffic_${hiveconf:SliceText}`;