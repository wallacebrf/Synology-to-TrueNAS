#!/bin/sh

for i in /dev/sd? ; do
	#echo "$i"
	model=$(smartctl -i $i | grep "Device Model")
	if [[ "$model" =~ "Micron" ]] || [[ "$model" =~ "PURZ" ]]; then
		echo "skipping disk: $i --> $model"
	else
		echo "Disabling NCQ for disk $i"
		#echo "/sys/block/${i/\/dev\/}/device/queue_depth"
		echo 1 > "/sys/block/${i/\/dev\/}/device/queue_depth"
	fi
done