#!/bin/bash
# This APMTool script will start the APM (1-6) processes and collect performance metrics for 15 minutes and
# perform a cleanup at the end to kill these processes and any other processes that the script spawns.

# cleanup function will kill the processes spawned in this script 
cleanup() {
	echo "Killing processes" 
	kill -9 $PID1
	kill -9 $PID2
	kill -9 $PID3
	kill -9 $PID4
	kill -9 $PID5
	kill -9 $PID6

	ifstat_PID=$( ps -u student | grep ifstat | awk '{print $1}' )
	kill -9 $ifstat_PID
    	echo "This script was in an infinite loop for $SECONDS seconds "

}
trap cleanup EXIT


#collect_metrics function when called will collect process & system level metrics and output data to csv file. 
collect_metrics() {

	local file="_metrics.csv"
	local metrics
	local pmetrics

	#Process Level Metrics#
	for z in {1..6}
	do
		pmetrics="$x,$(ps aux | grep ./APM$z | head -1 | awk '{print $3","$4}')"
		echo "$pmetrics" >> APM$z$file	
	done

	#System Level Metrics#

	#collect network bandwidth usage every second.
	metrics="$x,$(ifstat ens33 | tail -n +4  | head -1 | awk '{print $7","$9}' | sed 's/K//g'),"
	
	#Collect disk writes
	metrics+="$(iostat sda | egrep '[sda]{3}' | awk '{print $4}'),"
	
	#Collect disk capacity
	metrics+="$(df -hm | tail -n +2 | head -1 | awk '{print $3}'),"

	#metrics+="$(df -hm | egrep '[/dev/mapper]{10}' | awk '{print $4}'),"
	echo $metrics >> system_metrics.csv
	
	echo "Run every 5 seconds for 900 seconds, currently at $x seconds"
}

systemMetrics="system_metrics.csv"
file="_metrics.csv"
ipAddr="129.21.229.63"

#Check if system and process metrics files already exist. Delete if they exist, otherwise create files.
if [ -e $systemMetrics ] 
then
	rm $systemMetrics
	touch $systemMetrics
else
	touch $systemMetrics
fi

for t in {1..6}
do
	processMetrics="APM$t$file"

	if [ -e $processMetrics ]
	then
		rm $processMetrics
		touch $processMetrics
	else
		touch $processMetrics
	fi

done

#Start Processes
./APM1 $ipAddr &
PID1=$!
./APM2 $ipAddr &
PID2=$!
./APM3 $ipAddr &
PID3=$!
./APM4 $ipAddr &
PID4=$!
./APM5 $ipAddr &
PID5=$!
./APM6 $ipAddr &
PID6=$!

ifstat -d 1

i=1
x=0

#Start of script
echo "Running process and system collection"
for i in {1..180}
do
    sleep 5
   ((x += 5)) 
    collect_metrics
done
