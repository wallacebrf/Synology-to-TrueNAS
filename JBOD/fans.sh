#!/bin/bash
value=""
stty -F /dev/ttyACM0 raw
stty -F /dev/ttyACM0 -echo
while read -rs -n 1 c && [[ $c != 'q' ]] #read one character at a time until the letter "q" is received for "quit"
do
		value=$value"$c"
done < /dev/ttyACM0

echo "$value"

explode=(`echo $value | sed 's/,/\n/g'`) #explode on the comma separating the variables

fan1="${explode[0]}"
fan2="${explode[1]}"
fan3="${explode[2]}"
fan4="${explode[3]}"
fan5="${explode[4]}"
fan6="${explode[5]}"
temperature="${explode[6]}"
IFS='.' read -ra explode <<< "$temperature"
temperature_whole=${explode[0]}
temperature_fract=${explode[1]}


echo "Fan1 Staus: $fan1"
echo "Fan2 Staus: $fan2"
echo "Fan3 Staus: $fan3"
echo "Fan4 Staus: $fan4"
echo "Fan5 Staus: $fan5"
echo "Fan6 Staus: $fan6"
echo "Temperature [F]: $temperature"
echo "Temperature Whole [F]: $temperature_whole"
echo "Temperature Fract [F]: $temperature_fract"
echo -e "________________________________\n\n"


if [[ $fan1 -eq 0 ]]; then
	echo "FAN 1 is OFFLINE"
elif [[ $fan1 -eq 1 ]]; then
	echo "FAN 1 is ONLINE"
else
	echo "FAN 1 is UNKNOWN"
fi

if [[ $fan2 -eq 0 ]]; then
	echo "FAN 2 is OFFLINE"
elif [[ $fan2 -eq 1 ]]; then
	echo "FAN 2 is ONLINE"
else
	echo "FAN 2 is UNKNOWN"
fi

if [[ $fan3 -eq 0 ]]; then
	echo "FAN 3 is OFFLINE"
elif [[ $fan3 -eq 1 ]]; then
	echo "FAN 3 is ONLINE"
else
	echo "FAN 3 is UNKNOWN"
fi

if [[ $fan4 -eq 0 ]]; then
	echo "FAN 1 is OFFLINE"
elif [[ $fan4 -eq 1 ]]; then
	echo "FAN 4 is ONLINE"
else
	echo "FAN 4 is UNKNOWN"
fi

if [[ $fan5 -eq 0 ]]; then
	echo "FAN 5 is OFFLINE"
elif [[ $fan5 -eq 1 ]]; then
	echo "FAN 5 is ONLINE"
else
	echo "FAN 5 is UNKNOWN"
fi

if [[ $fan6 -eq 0 ]]; then
	echo "FAN 6 is OFFLINE"
elif [[ $fan6 -eq 1 ]]; then
	echo "FAN 6 is ONLINE"
else
	echo "FAN 6 is UNKNOWN"
fi

if [[ $temperature_whole -le 80 ]]; then
	echo "Temperature is OK"
elif [[ $temperature_whole -gt 80 ]]; then
	echo "Temperature is WARNING"
else
	echo "Temperature is UNKNOWN"
fi