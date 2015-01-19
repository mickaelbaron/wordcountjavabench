#!/bin/bash

frequency=${1:-5}
input=${2:-bigfile.txt}
numberofthread=${3:-6}

outputIostat="output_iostat"
outputJava="output_java"
reportJava="report_java"

rm -rf $outputIostat
rm -rf $outputJava
rm -rf $reportJava

mkdir $outputIostat -p
mkdir $outputJava -p
mkdir $reportJava -p

sizeinput=$(du -h $input)

outputiostat=$outputIostat"/iostat"$numberofthread".csv"
iostat $frequency -xt | awk -v r=$outputiostat '
	NF==2 {
		getline;getline;uservar=$1;systemvar=$3;getline;getline;getline;
		print uservar+systemvar";"$14 > r
	}
	' &
sleep 15
outputjava=$outputJava"/output"$numberofthread".txt"
reportjava=$reportJava"/report"$numberofthread".txt"
/usr/lib/jvm/java-8-oracle/bin/java -jar wordcountjava.jar $input $outputjava $reportjava $numberofthread
sleep 15
killall iostat

splitvalue=$(($(awk -F " " '{getline;print $4}' $reportjava)/1000))
mapvalue=$(($(awk -F " " '{getline;print $5}' $reportjava)/1000))
reducevalue=$(($(awk -F " " '{getline;print $6}' $reportjava)/1000))

reportpngjava=$reportJava"/"$reportjavat$numberofthread".png"
title="CPU & Disk usage during a WordCountJava application execution ("$numberofthread" thread "$sizeinput")"
gnuplot -e "frequency='$frequency';reportpng='$reportpngjava';sizeinput='$title';splitvalue='$splitvalue';mapvalue='$mapvalue';reducevalue='$reducevalue';outputiostat='$outputiostat'" wcbench.plt
