#!/bin/bash
targetDir="/mnt/volume1/apps/torrent/bt/torrents"
email_address="email@email.com" # semi-colon separate list of email addresses to be informed of the results of the script
from_email_address="email@email.com"
email_subject="New Files Available"
log_file_location="/mnt/volume1/logging/notifications/download_notify.txt"


if [ -r "$log_file_location" ]; then
	#file is available and readable 
	read newest_last_execution < "$log_file_location"
else
	newest_last_execution=0
fi	

newest=0

for file in "$targetDir"/*; do
  ## Get the file's modification time in seconds since the epoch
  lastMod=$(stat -c "%Y" "$file")
  ## Is this file newer than the current newest?
  if [[ $lastMod -gt $newest ]]; then
    newest=$lastMod
  fi
done

if [[ $newest_last_execution -eq $newest ]]; then
	exit 1
else
	echo "$newest" > "$log_file_location"
fi


## Get the current time in seconds since the epoch
now=$(date '+%s')
## If the newest file is older than half an hour
if [[ $((now - newest)) -gt 1810 ]]; then
    echo "No new files added since $(date -d '- 30 min')"
else
	address_explode=$(echo "$email_address" | sed 's/;/\n/g')
	bb=0
	for bb in "${!address_explode[@]}"; do
		python3 /mnt/volume1/logging/multireport_sendemail.py --subject "$email_subject" --to_address "${address_explode[$bb]}" --mail_body_html "$email_subject" --override_fromemail "$from_email_address"
	done
fi


