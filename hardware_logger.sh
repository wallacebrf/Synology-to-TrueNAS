#!/bin/bash
# shellcheck disable=SC2162,SC2004,SC2129,SC2116,SC2321,SC2027,SC2086,SC2219
#Version 6/11/2025
#made updates to appease shell check
#By Brian Wallace
#########################################################


#check that the script is running as root or some of the commands required will not work
if [[ $( whoami ) != "root" ]]; then
	echo -e "ERROR - Script requires ROOT permissions, exiting script"
	exit 1
fi

if [ -d "/mnt/ramfs" ]; then
	echo "RAM disk \"/mnt/ramfs\" Exists"
else
	echo "creating RAM disk \"/mnt/ramfs\""
	mkdir /mnt/ramfs && mount -t tmpfs -o size=100m ramdisk /mnt/ramfs
fi

#########################################################
#USER ADJUSABLE SCRIPT VARIABLES
email_contents="/mnt/volume1/logging/notifications/Hardware_Logging_email_contents.txt"					#when email notifications are sent, the contents of the email and a log entry if the email successfully sent is saved to this file
lock_file_location="/mnt/volume1/logging/notifications/Hardware_Logging.lock"								#file created while the script is running and deleted when the script is done. this is to prevent more than one copy of the script from running at a time
email_last_sent="/mnt/volume1/logging/notifications/${0##*/}_Hardware_Logging_last_message_sent.txt"		#some emails are to be sent only every 60 minutes (like config file missing/corrupt messages) to prevent your inbox from being spammed
debug=0																									#if set to "1" the script will display all of the collected data being sent to InfluxDB
nas_name_error="TrueNAS"																				#if the config file fails to load, this will ensure the script describes what system the email is from																							#set to a value of 1 if using synology															
config_file_location="/mnt/volume1/hosting/web/config/config_files"
config_file_name="hardware_logging_config.txt"
measurement="TrueNAS_Hardware_status"
nas_name="TrueNAS"																						#set to "1" to use "sendmail" command, set to "0" to use the "ssmtp" command when sending email notifications, set to "2" if using trueNAS
capture_interval_adjustment=4

#########################################################
#EMAIL SETTINGS USED IF CONFIGURATION FILE IS UNAVAILABLE
#These variables will be overwritten with new corrected data if the configuration file loads properly. 
#If the config file does not load properly, then the script will still be able to send alert emails informing the user the config file is missing/corrupted
email_address="email@email.com"
from_email_address="email@email.com"
#########################################################


#create a lock file in the configuration directory to prevent more than one instance of this script from executing  at once
if ! mkdir "$lock_file_location"; then
	printf "Failed to acquire lock.\n" >&2
	exit 1
fi
trap 'rm -rf "$lock_file_location"' EXIT #remove the lockdir on exit

	
#########################################################
#this function is used to send notifications
#########################################################
function send_mail(){
#email_last_sent_log_file=${1}			this file contains the UNIX time stamp of when the email is sent so we can track how long ago an email was last sent
#message_text=${2}						this string of text contains the body of the email message
#email_subject=${3}						this string of text contains the email subject line
#email_contents_file=${4}				this file is where the contents of the email are saved prior to sending and it contains the log of the email transmission, either will indicated email sent successfully or will include the error details
#error_message=${5}						this string of text is only displayed when the script is executed from the CLI, it will be part of the error message if the email is not sent correctly
#email_interval=${6}					this numerical value will control how many minutes must pass before the next email is allowed to be sent
	
	#check to make sure the email address infomation is not blank
	if [[ $from_email_address == "" || $email_address == "" ]]; then
		echo "From / To email address information is blank, cannot send email notifications"
		return
	fi
	
	#make sure the email address at least contains an "@" symbol and a "." as email addresses must have those
	if [[ $(echo "$email_address" | grep "@") == "" || $(echo "$from_email_address" | grep "@") == "" || $(echo "$from_email_address" | grep ".") == "" || $(echo "$email_address" | grep ".") == "" ]]; then
		echo "From / To email address information is not an email address, cannot send email notifications"
		return
	fi
	
	local message_tracker=""
	local time_diff=0
	echo -e "${2}"
	echo ""

	local current_time
	current_time=$( date +%s )
	if [ -r "${1}" ]; then #file is available and readable 
		read message_tracker < "${1}"
		time_diff=$((( $current_time - $message_tracker ) / 60 ))
	else
		echo -n "$current_time" > "${1}"
		time_diff=$(( ${6} + 1 ))
	fi
				
	if [ "$time_diff" -ge "${6}" ]; then
		local now
		now=$(date +"%T")
		echo "the email has not been sent in over ${6} minutes, re-sending email"
			#https://github.com/oxyde1989/standalone-tn-send-email/tree/main
			
		#the command can only take one email address destination at a time. so if there are more than one email addresses in the list, we need to send them one at a time
		address_explode=(`echo "$email_address" | sed 's/;/\n/g'`)
		local bb=0
		for bb in "${!address_explode[@]}"; do
			python3 /mnt/volume1/logging/multireport_sendemail.py --subject "${3}" --to_address "${address_explode[$bb]}" --mail_body_html "$now - ${2}" --override_fromemail "$from_email_address"
		done
	else
		echo -e "Only $time_diff minuets have passed since the last notification, email will be sent every ${6} minutes. $(( ${6} - $time_diff )) Minutes Remaining Until Next Email\n"
	fi
}	

if [ -r "$config_file_location"/"$config_file_name" ]; then
	#file is available and readable 
	
	#read in file, explode the configuration into an array with the colon as the delimiter
	IFS=$',' read -d '' -r -a explode < "$config_file_location/$config_file_name"
	
	#verify the correct number of configuration parameters are in the configuration file
	if [[ ! ${#explode[@]} == 140 ]]; then
		send_mail "$email_last_sent" "WARNING - the configuration file is incorrect or corrupted. It should have 140 parameters, it currently has ${#explode[@]} parameters." "Warning NAS \"$nas_name\" SNMP Monitoring Failed for script \"${0##*/}\" - Configuration file is incorrect" "$email_contents" "Config File Error" 60
		exit 1
	fi	
	paramter_name=()
	paramter_notification_threshold=()
	paramter_type=()
	hba_name=()
	hba_max_temp=()
	hba_temp=()
	sensor_name=()
	sensor_value=()
	sensor_unit=()
	sensor_stats=()
	sensor_low_non_recoverable=()
	sensor_low_critical=()
	sensor_low_not_critical=()
	sensor_high_non_critical=()
	sensor_high_critical=()
	sensor_high_non_recoverable=()
	
	#save the parameter values into the respective variable and remove the quotes
	influxdb_host="${explode[0]}"
	influxdb_port="${explode[1]}"
	influxdb_name="${explode[2]}"
	influxdb_pass="${explode[3]}"
	script_enable="${explode[4]}"
	influxdb_org="${explode[5]}"
	enable_email_notifications="${explode[6]}"
	email_address="${explode[7]}"
	from_email_address="${explode[8]}"
	
	#IPMI Hardware Paramters Being Monitored
	paramter_name+=("${explode[9]}")
	paramter_notification_threshold+=("${explode[10]}")
	paramter_type+=("${explode[11]}")
	paramter_name+=("${explode[12]}")
	paramter_notification_threshold+=("${explode[13]}")
	paramter_type+=("${explode[14]}")
	paramter_name+=("${explode[15]}")
	paramter_notification_threshold+=("${explode[16]}")
	paramter_type+=("${explode[17]}")
	paramter_name+=("${explode[18]}")
	paramter_notification_threshold+=("${explode[19]}")
	paramter_type+=("${explode[20]}")
	paramter_name+=("${explode[21]}")
	paramter_notification_threshold+=("${explode[22]}")
	paramter_type+=("${explode[23]}")
	paramter_name+=("${explode[24]}")
	paramter_notification_threshold+=("${explode[25]}")
	paramter_type+=("${explode[26]}")
	paramter_name+=("${explode[27]}")
	paramter_notification_threshold+=("${explode[28]}")
	paramter_type+=("${explode[29]}")
	paramter_name+=("${explode[30]}")
	paramter_notification_threshold+=("${explode[31]}")
	paramter_type+=("${explode[32]}")
	paramter_name+=("${explode[33]}")
	paramter_notification_threshold+=("${explode[34]}")
	paramter_type+=("${explode[35]}")
	paramter_name+=("${explode[36]}")
	paramter_notification_threshold+=("${explode[37]}")
	paramter_type+=("${explode[38]}")
	paramter_name+=("${explode[39]}")
	paramter_notification_threshold+=("${explode[40]}")
	paramter_type+=("${explode[41]}")
	paramter_name+=("${explode[42]}")
	paramter_notification_threshold+=("${explode[43]}")
	paramter_type+=("${explode[44]}")
	paramter_name+=("${explode[45]}")
	paramter_notification_threshold+=("${explode[46]}")
	paramter_type+=("${explode[47]}")
	paramter_name+=("${explode[48]}")
	paramter_notification_threshold+=("${explode[49]}")
	paramter_type+=("${explode[50]}")
	paramter_name+=("${explode[51]}")
	paramter_notification_threshold+=("${explode[52]}")
	paramter_type+=("${explode[53]}")
	paramter_name+=("${explode[54]}")
	paramter_notification_threshold+=("${explode[55]}")
	paramter_type+=("${explode[56]}")
	paramter_name+=("${explode[57]}")
	paramter_notification_threshold+=("${explode[58]}")
	paramter_type+=("${explode[59]}")
	paramter_name+=("${explode[60]}")
	paramter_notification_threshold+=("${explode[61]}")
	paramter_type+=("${explode[62]}")
	paramter_name+=("${explode[63]}")
	paramter_notification_threshold+=("${explode[64]}")
	paramter_type+=("${explode[65]}")
	paramter_name+=("${explode[66]}")
	paramter_notification_threshold+=("${explode[67]}")
	paramter_type+=("${explode[68]}")
	paramter_name+=("${explode[69]}")
	paramter_notification_threshold+=("${explode[70]}")
	paramter_type+=("${explode[71]}")
	paramter_name+=("${explode[72]}")
	paramter_notification_threshold+=("${explode[73]}")
	paramter_type+=("${explode[74]}")
	paramter_name+=("${explode[75]}")
	paramter_notification_threshold+=("${explode[76]}")
	paramter_type+=("${explode[77]}")
	paramter_name+=("${explode[78]}")
	paramter_notification_threshold+=("${explode[79]}")
	paramter_type+=("${explode[80]}")
	paramter_name+=("${explode[81]}")
	paramter_notification_threshold+=("${explode[82]}")
	paramter_type+=("${explode[83]}")
	paramter_name+=("${explode[84]}")
	paramter_notification_threshold+=("${explode[85]}")
	paramter_type+=("${explode[86]}")
	paramter_name+=("${explode[87]}")
	paramter_notification_threshold+=("${explode[88]}")
	paramter_type+=("${explode[89]}")
	paramter_name+=("${explode[90]}")
	paramter_notification_threshold+=("${explode[91]}")
	paramter_type+=("${explode[92]}")
	paramter_name+=("${explode[93]}")
	paramter_notification_threshold+=("${explode[94]}")
	paramter_type+=("${explode[95]}")
	paramter_name+=("${explode[96]}")
	paramter_notification_threshold+=("${explode[97]}")
	paramter_type+=("${explode[98]}")
	paramter_name+=("${explode[99]}")
	paramter_notification_threshold+=("${explode[100]}")
	paramter_type+=("${explode[101]}")
	paramter_name+=("${explode[102]}")
	paramter_notification_threshold+=("${explode[103]}")
	paramter_type+=("${explode[104]}")
	paramter_name+=("${explode[105]}")
	paramter_notification_threshold+=("${explode[106]}")
	paramter_type+=("${explode[107]}")
	paramter_name+=("${explode[108]}")
	paramter_notification_threshold+=("${explode[109]}")
	paramter_type+=("${explode[110]}")
	paramter_name+=("${explode[111]}")
	paramter_notification_threshold+=("${explode[112]}")
	paramter_type+=("${explode[113]}")
	paramter_name+=("${explode[114]}")
	paramter_notification_threshold+=("${explode[115]}")
	paramter_type+=("${explode[116]}")
	paramter_name+=("${explode[117]}")
	paramter_notification_threshold+=("${explode[118]}")
	paramter_type+=("${explode[119]}")
	paramter_name+=("${explode[120]}")
	paramter_notification_threshold+=("${explode[121]}")
	paramter_type+=("${explode[122]}")
	paramter_name+=("${explode[123]}")
	paramter_notification_threshold+=("${explode[124]}")
	paramter_type+=("${explode[125]}")
	paramter_name+=("${explode[126]}")
	paramter_notification_threshold+=("${explode[127]}")
	paramter_type+=("${explode[128]}")
	
	#HBA Hardware Paramters Being Monitored
	hba_name_monitored+=("${explode[129]}")
	hba_max_temp+=("${explode[130]}")
	hba_name_monitored+=("${explode[131]}")
	hba_max_temp+=("${explode[132]}")
	hba_name_monitored+=("${explode[133]}")
	hba_max_temp+=("${explode[134]}")
	hba_name_monitored+=("${explode[135]}")
	hba_max_temp+=("${explode[136]}")
	hba_name_monitored+=("${explode[137]}")
	hba_max_temp+=("${explode[138]}")
	capture_interval="${explode[139]}"
	
	#script_enable=0

	if [ "$script_enable" -eq 1 ]; then
	
		if [ ! $capture_interval -eq 10 ]; then
			if [ ! $capture_interval -eq 15 ]; then
				if [ ! $capture_interval -eq 30 ]; then
					if [ ! $capture_interval -eq 60 ]; then
						echo "capture interval is not one of the allowable values of 10, 15, 30, or 60 seconds. Exiting the script"
						exit 1
					fi
				fi
			fi
		fi
		
		#loop the script 
		total_executions=$(( 60 / $capture_interval))
		echo "Capturing $total_executions times"
		i=0
		while [ $i -lt $total_executions ]; do
		
			post_url=""
			if [[ $i -eq 0 ]]; then
				measurement="HBA_Temp"
				num_controllers=$(/mnt/volume1/logging/storcli64 show ctrlcount nolog | grep "Count" | sed 's/^.\{19\}//')
				echo "HBA Controllers Found: $num_controllers"
			
				xx=0
				while [ $xx -lt $num_controllers ]; do
					hba_name_raw="$(/mnt/volume1/logging/storcli64 show nolog | grep -B 0 -A 3 "Ctl Model" | grep -m 1 " $xx " | cut -c 5- | cut -d 'x' -f 1 | sed 's/.\{2\}$//')"
					
					secondString="_"
					hba_name_raw=${hba_name_raw//\ /$secondString} #replace spaces with underscore
					hba_name+=("$hba_name_raw")
					
					hba_temp+=("$(/mnt/volume1/logging/storcli64 /c$xx show all nolog | egrep Degree | sed 's/^.\{34\}//')")
					
					post_url=$post_url"$measurement,nas_name=$nas_name,hba_name=${hba_name[$xx]} hba_temp=${hba_temp[$xx]}
"
					if [[ $enable_email_notifications == 1 ]]; then
						if [[ "${hba_temp[$xx]}" -gt "${hba_max_temp[$xx]}" ]]; then
							send_mail "$email_last_sent" "Warning HBA \"${hba_name[$xx]}\" on $nas_name has exceeded the max temperature of ${hba_max_temp[$xx]} Degrees C. It currently is reporting a value of ${hba_temp[$xx]} Degrees C." "HBA ALERT for $nas_name" "$email_contents" "HBA Alert" 60
						fi
					fi
					let xx=xx+1
				done
			fi
			
			measurement="IPMI_sensors"
			xx=0
			while IFS= read -r line; do				
				IFS=$'|' read -rd '' -a explode <<<"$line"
				
				yy=0
				for yy in "${!explode[@]}"; do
					secondString=""
					filtered=${explode[$yy]}
					filtered=$(echo "${filtered//[$'\t\r\n ']}") #remove new lines
					filtered=${filtered//\ /$secondString} #replace spaces with empty
					if [[ $filtered =~ "na" ]]; then
						filtered=-1
					elif [[ $filtered =~ "ok" ]]; then
						filtered=1
					elif [[ $filtered =~ "0x04ff" ]]; then
						filtered=1
					elif [[ $filtered =~ "0x" ]]; then
						filtered=$(printf "%d\n" $filtered)
					fi
					
					if [[ $yy -eq 0 ]]; then
						sensor_name+=("$filtered")
					elif [[ $yy -eq 1 ]]; then
						sensor_value+=("$filtered")
					elif [[ $yy -eq 2 ]]; then
						sensor_unit+=("$filtered")
					elif [[ $yy -eq 3 ]]; then
						if [[ $filtered != -1 ]] && [[ $filtered != 1 ]]; then
							filtered=0
						fi
						sensor_stats+=("$filtered")
					elif [[ $yy -eq 4 ]]; then
						sensor_low_non_recoverable+=("$filtered")
					elif [[ $yy -eq 5 ]]; then
						sensor_low_critical+=("$filtered")
					elif [[ $yy -eq 6 ]]; then
						sensor_low_not_critical+=("$filtered")
					elif [[ $yy -eq 7 ]]; then
						sensor_high_non_critical+=("$filtered")
					elif [[ $yy -eq 8 ]]; then
						sensor_high_critical+=("$filtered")
					elif [[ $yy -eq 9 ]]; then
						sensor_high_non_recoverable+=("$filtered")
					fi
				done
				
				#are email notifications enabled?
				if [[ $enable_email_notifications == 1 ]]; then
					if [[ "${sensor_name[$xx]}" == "${paramter_name[$xx]}" ]]; then
						if [[ "${paramter_type[$xx]}" == ">" ]]; then
							if [ "${sensor_value[$xx]}" -gt "${paramter_notification_threshold[$xx]}" ]; then
								send_mail "$email_last_sent" "Warning IPMI Attribute \"${sensor_name[$xx]}\" on $nas_name has exceeded the threshold value of ${paramter_notification_threshold[$xx]} ${sensor_unit[$xx]}. It currently is reporting a value of ${sensor_value[$xx]} ${sensor_unit[$xx]}." "IPMI ALERT for $nas_name" "$email_contents" "IPMI Alert" 60
							fi
						elif [[ "${paramter_type[$xx]}" == "=" ]]; then
							if [ "${sensor_value[$xx]}" -eq "${paramter_notification_threshold[$xx]}" ]; then
								send_mail "$email_last_sent" "Warning IPMI Attribute \"${sensor_name[$xx]}\" on $nas_name is equal to the threshold value of ${paramter_notification_threshold[$xx]} ${sensor_unit[$xx]}. It currently is reporting a value of ${sensor_value[$xx]} ${sensor_unit[$xx]}." "IPMI ALERT for $nas_name" "$email_contents" "IPMI Alert" 60
							fi
						elif [[ "${paramter_type[$xx]}" == "<" ]]; then
							if [ "${sensor_value[$xx]}" -lt "${paramter_notification_threshold[$xx]}" ]; then
								send_mail "$email_last_sent" "Warning IPMI Attribute \"${sensor_name[$xx]}\" $nas_name is less than the threshold value of ${paramter_notification_threshold[$xx]} ${sensor_unit[$xx]}. It currently is reporting a value of ${sensor_value[$xx]} ${sensor_unit[$xx]}." "IPMI ALERT for $nas_name" "$email_contents" "IPMI Alert" 60
							fi
						fi
					fi	
				fi
				post_url=$post_url"$measurement,nas_name=$nas_name,sensor_name=${sensor_name[$xx]} sensor_value=${sensor_value[$xx]},sensor_unit=\"${sensor_unit[$xx]}\",sensor_stats=${sensor_stats[$xx]},sensor_low_non_recoverable=${sensor_low_non_recoverable[$xx]},sensor_low_critical=${sensor_low_critical[$xx]},sensor_low_not_critical=${sensor_low_not_critical[$xx]},sensor_high_non_critical=${sensor_high_non_critical[$xx]},sensor_high_critical=${sensor_high_critical[$xx]},sensor_high_non_recoverable=${sensor_high_non_recoverable[$xx]}
"
				let xx=xx+1
			done < <(ipmitool sensor)
			
			
			#if [[ $debug -eq 1 ]]; then
				echo "$post_url"
			#fi
					
			echo "$post_url" > "/mnt/ramfs/hardware_data.txt"
				
			curl -XPOST "http://$influxdb_host:$influxdb_port/api/v2/write?bucket=$influxdb_name&org=$influxdb_org" -H "Authorization: Token $influxdb_pass" --data-binary "@/mnt/ramfs/hardware_data.txt"
			
			let i=i+1
			echo "Capture #$i complete"
			
			#Sleeping for capture interval unless its last capture then we dont sleep
			if (( $i < $total_executions)); then
				sleep $(( $capture_interval - $capture_interval_adjustment ))
			fi
		done
	else
		echo "script is disabled"
	fi
else
	if [[ "$email_address" == "" || "$from_email_address" == "" || $(echo "$email_address" | grep "@") == "" || $(echo "$from_email_address" | grep "@") == "" || $(echo "$from_email_address" | grep ".") == "" || $(echo "$email_address" | grep ".") == "" ]];then
		echo -e "\n\nNo email address information is configured, Cannot send an email indicating script \"${0##*/}\" config file is missing and script will not run"
	else
		send_mail "$email_last_sent" "Warning NAS \"$nas_name\" IPMI Logging Failed for script \"${0##*/}\" - Configuration file is missing" "Warning NAS \"$nas_name_error\" IPMI Data Collection Failed for script \"${0##*/}\" - Configuration file is missing" "$email_contents" "Config File Missing Alert" 60
	fi
	exit 1
fi

