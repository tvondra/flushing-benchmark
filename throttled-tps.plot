set terminal postscript eps enhanced color font 'Helvetica,10' size 4,2
set output 'throttled-tps.eps'
set key top left
set title 'pgbench (throttled to 5000 tps) / CDF of tps (per second)'
plot \
'master/throttled/percentiles.data'  using 2:1 with lines title 'master (a298a1e06)', \
'patched/throttled/percentiles.data' using 2:1 with lines title 'patched (23a27b03)'
