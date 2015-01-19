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

for currentthreadnumber in $(seq 1 $numberofthread)
do
	outputiostat=$outputIostat"/iostat"$currentthreadnumber".csv"
	iostat $frequency -xt | awk -v r=$outputiostat '
		NF==2 {
			getline;getline;uservar=$1;systemvar=$3;getline;getline;getline;
			print uservar+systemvar";"$14 > r
		}
		' &
	sleep 15
	outputjava=$outputJava"/output"$currentthreadnumber".txt"
	reportjava=$reportJava"/report"$currentthreadnumber".txt"
	java -jar wordcountjava.jar $input $outputjava $reportjava $currentthreadnumber
	sleep 15
	killall iostat

	splitvalue=$(($(awk -F " " '{getline;print $4}' $reportjava)/1000))
	mapvalue=$(($(awk -F " " '{getline;print $5}' $reportjava)/1000))
	reducevalue=$(($(awk -F " " '{getline;print $6}' $reportjava)/1000))

	reportpngjava=$reportJava"/"$reportjavat$currentthreadnumber".png"
	title="CPU & Disk usage during a WordCountJava application execution ("$currentthreadnumber" thread "$sizeinput")"
	gnuplot -e "frequency='$frequency';reportpng='$reportpngjava';sizeinput='$title';splitvalue='$splitvalue';mapvalue='$mapvalue';reducevalue='$reducevalue';outputiostat='$outputiostat'" wcbench.plt
done
