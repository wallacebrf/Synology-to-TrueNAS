#!/bin/bash

#check that the script is running as root or some of the commands required will not work
if [[ $( whoami ) != "root" ]]; then
	echo -e "ERROR - Script requires ROOT permissions, exiting script"
	exit 1
fi

lock_file_location="/mnt/volume1/logging/notifications/scrubbing_status.lock"	
truenas_multireport_sendemail="/mnt/volume1/logging/multireport_sendemail.py"
email_address="email@email.com"
from_email="email@email.com"
subject="TrueNAS Scrubbing Status"



#create a lock file in the configuration directory to prevent more than one instance of this script from executing  at once
if ! mkdir "$lock_file_location"; then
	printf "Failed to acquire lock.\n" >&2
	exit 1
fi
trap 'rm -rf "$lock_file_location"' EXIT #remove the lockdir on exit

xx=0
while IFS= read -r line; do				
	echo "Processing ZFS Volume $line"
	volume_status=$(zpool status -LP $line)
	if [[ "$(echo -n "$volume_status" | grep "progress")" != "" ]]; then #scrub is active
		now=$(date +"%T")
		address_explode=(`echo "${email_address}" | sed 's/;/\n/g'`)
		 bb=0
		for bb in "${!address_explode[@]}"; do
			python3 "$truenas_multireport_sendemail" --subject "$subject" --to_address "${address_explode[$bb]}" --mail_body_html "$now - ${volume_status//$'\n'/<br>}" --override_fromemail "$from_email"
		done
	fi
	let xx=xx+1
done < <(zpool status | grep "NAME" -A 1 | awk '{print $1}' | sed s/"NAME"// | sed s/"--"// | sed '/^[[:space:]]*$/d')

