set terminal pngcairo color dashed enhanced size 800,500
set title sizeinput
set label 1 "Finish Split=".splitvalue."s" at splitvalue+100,40
set arrow from splitvalue,0 to splitvalue,80 nohead
set label 2 "Finish Map=".mapvalue."s" at mapvalue-10,40 right
set arrow from mapvalue,0 to mapvalue,80 nohead
set label 3 "Finish Reduce=".reducevalue."s" at reducevalue-10,60 right
set arrow from reducevalue,0 to reducevalue,80 nohead
set datafile separator ';'
set xlabel "Time (hh:mm:ss)"
set ylabel "Percentage (%)"
set xdata time
set xtics 900
set xtics format "%H:%M:%S"
set output reportpng
set yrange [0:100]
set grid x y
plot outputiostat using ($0*frequency):1 w l lt rgb "#0000FF" title 'CPU usage', outputiostat using ($0*frequency):2 w l lt rgb "#FF0000" title 'Disk usage'
