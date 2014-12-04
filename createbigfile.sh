#!/bin/bash
OUTPUT=${2:-bigfile.txt}
ITERATE=${3:-10000}

for ((c=1; c<=$ITERATE; c++))
do
	cat $1 >> $OUTPUT
done

