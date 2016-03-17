mkdir -p $1/default

pg_ctl -D /data/tomas/pgdata -l $1/default/pg.log -w -t 3600 restart

sleep 5

psql pgbench -c "checkpoint"
pgbench -c 32 -j 8 -T 86400 -l --aggregate-interval=1 pgbench > $1/default/pgbench.log 2>&1
tar -czf $1/default/pgbench.tgz pgbench_log.*
rm pgbench_log.*

mkdir -p $1/throttled

pg_ctl -D /data/tomas/pgdata -l $1/throttled/pg.log -w -t 3600 restart

sleep 5

psql pgbench -c "checkpoint"
pgbench -c 32 -j 8 -T 86400 -R 5000 -l --aggregate-interval=1 pgbench > $1/throttled/pgbench.log 2>&1
tar -czf $1/throttled/pgbench.tgz pgbench_log.*
rm pgbench_log.*
