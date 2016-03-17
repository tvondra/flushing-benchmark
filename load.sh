dropdb --if-exists pgbench
createdb pgbench

psql pgbench -c "CREATE TABLE results (
   ts       INT,
   tps      INT,
   lat_sum  BIGINT,
   lat_sum2 BIGINT,
   lat_min  INT,
   lat_max  INT,
   lag_sum  BIGINT,
   lag_sum2 BIGINT,
   lag_min  INT,
   lag_max  INT
)"

for f in `ls pgbench_log.*`; do

	if [ $1 == 'throttled' ]; then
		cat $f | psql pgbench -c "COPY results FROM stdout WITH (format CSV, delimiter ' ')"
	else
		cat $f | psql pgbench -c "COPY results(ts, tps, lat_sum, lat_sum2, lat_min, lat_max) FROM stdout WITH (format CSV, delimiter ' ')"
	fi

done


psql pgbench -c "CREATE TABLE results_agg AS SELECT
ts,
sum(tps) AS tps,
(CASE WHEN ((sum(tps) * sum(lat_sum2) - sum(lat_sum) * sum(lat_sum)) > 0) AND (sum(tps) > 1) THEN
    sqrt((sum(tps) * sum(lat_sum2) - sum(lat_sum) * sum(lat_sum)) / (sum(tps) * (sum(tps) - 1)))
ELSE 0 END) AS lat_stddev,
min(lat_min) AS lat_min,
max(lat_max) AS lat_max
FROM results
GROUP BY ts
ORDER BY ts"

psql pgbench -A -F ' ' -c "SELECT
i AS pct,
(SELECT percentile_cont(i/100.0) WITHIN GROUP (ORDER BY tps) FROM results_agg) AS tps,
(SELECT percentile_cont(i/100.0) WITHIN GROUP (ORDER BY lat_min) FROM results_agg) AS min_lat,
(SELECT percentile_cont(i/100.0) WITHIN GROUP (ORDER BY lat_max) FROM results_agg) AS max_lat,
(SELECT percentile_cont(i/100.0) WITHIN GROUP (ORDER BY lat_stddev) FROM results_agg) AS last_stddev
FROM generate_series(1,100) s(i)" > percentiles.data
