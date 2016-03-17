set terminal postscript eps enhanced color font 'Helvetica,10' size 4,2
set output 'regular-max-lat.eps'
set key top left
set title 'pgbench / CDF of max latency (per second)'
plot \
'master/default/percentiles.data'  using 4:1 with lines title 'master (a298a1e06)', \
'patched/default/percentiles.data' using 4:1 with lines title 'patched (23a27b03)'
