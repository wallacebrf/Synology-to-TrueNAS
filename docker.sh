#!/bin/bash
#version 1.0 dated 5/11/2025
#By Brian Wallace

#initially based on the script found here by user kernelkaribou
#https://github.com/kernelkaribou/TrueNAS-monitoring

#This script pulls various information from TrueNAS that are not otherwise available through the exporters. 

#This script works in conjunction with a PHP powered web-based administration control panel to configure all of the script settings

#***************************************************
#Dependencies:
#***************************************************
#1.) this script is designed to be executed every 60 seconds. It has a configurable parameter "capture_interval" that allows the script to loop 6x, 4x, 2x, or 1x time(s) every 60 seconds. 
#2.) this script only supports SNMP V3. This is because lower versions are less secure 
	#SNMP must be enabled on the host NAS for the script to gather the needed information
	#the snmp settings for the NAS can all be entered into the web administration page
#3.) This script only supports InfluxdB version 2.x as version 1.x is no longer supported, it is recommended to upgrade to version 2 anyways
#4.) IN order to send emails, this script relies on the "multireport_sendemail.py" file available from https://github.com/oxyde1989/standalone-tn-send-email/tree/main

#########################################
#variable initialization
#########################################

#########################################################
#EMAIL SETTINGS USED IF CONFIGURATION FILE IS UNAVAILABLE
#These variables will be overwritten with new corrected data if the configuration file loads properly. 
email_address="email@email.com"
from_email_address="email@email.com"
#########################################################


log_file_location="/mnt/volume1/logging/notifications"
lock_file_location="$log_file_location/docker_stats.lock"
config_file_location="/mnt/volume1/hosting/web/config/config_files/docker_config.txt"

nas_name="TrueNAS" #this is only needed if the script cannot access the server name over SNMP, or if the config file is unavailable and will be used in any error messages
capture_interval_adjustment=3
debug=0

#########################################
#Script Start
#########################################

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


#check that the required working directory is available, readable, and writable. it should be since we are root, but better check
if [ -d "$log_file_location" ]; then
	if [ -r "$log_file_location" ]; then
		if [ ! -r "$log_file_location" ]; then
			echo -e "ERROR - The script directory \"$log_file_location\" is not writable, exiting script"
			exit 1
		fi
	else
		echo -e "ERROR - The script directory \"$log_file_location\" is not readable, exiting script"
		exit 1
	fi
else
	echo -e "ERROR - The script directory \"$log_file_location\" is not available, exiting script"
	exit 1
fi

#create a lock file in the ramdisk directory to prevent more than one instance of this script from executing at once
if ! mkdir "$lock_file_location"; then
	echo -e "Failed to acquire lock.\n" >&2
	exit 1
fi
trap 'rm -rf $lock_file_location' EXIT #remove the lockdir on exit

#########################################################
#this function is used to send notifications
#########################################################
function send_mail(){
#email_last_sent_log_file=${1}			this file contains the UNIX time stamp of when the email is sent so we can track how long ago an email was last sent
#message_text=${2}						this string of text contains the body of the email message
#email_subject=${3}						this string of text contains the email subject line
#email_interval=${4}					this numerical value will control how many minutes must pass before the next email is allowed to be sent
	local message_tracker=""
	local time_diff=0
	echo "${2}"
	echo ""
	local current_time=$( date +%s )
	if [ -r "${1}" ]; then #file is available and readable 
		read message_tracker < "${1}"
		time_diff=$((( $current_time - $message_tracker ) / 60 ))
	else
		echo -n "$current_time" > "${1}"
		time_diff=$(( ${4} + 1 ))
	fi
			
	if [ $time_diff -ge ${4} ]; then
		local now=$(date +"%T")
		echo "the email has not been sent in over ${4} minutes, re-sending email"
	
		#https://github.com/oxyde1989/standalone-tn-send-email/tree/main
				
		#the command can only take one email address destination at a time. so if there are more than one email addresses in the list, we need to send them one at a time
		address_explode=(`echo "$email_address" | sed 's/;/\n/g'`)
		local bb=0
		for bb in "${!address_explode[@]}"; do
			python3 /mnt/volume1/web/logging/multireport_sendemail.py --subject "${3}" --to_address "${address_explode[$bb]}" --mail_body_html "$now - ${2}" --override_fromemail "$from_email_address"
		done
		echo -n "$current_time" > "${1}"
	else
		echo -e "Only $time_diff minuets have passed since the last notification, email will be sent every ${4} minutes. $(( ${4} - $time_diff )) Minutes Remaining Until Next Email\n"
	fi
}

#reading in variables from configuration file. this configuration file is edited using a web administration page. or the file can be edited directly. 
#If the file does not yet exist, opening the web administration page will create a file with default settings
if [ -r "$config_file_location" ]; then
	#file is available and readable 
	read input_read < "$config_file_location"
	explode=(`echo $input_read | sed 's/,/\n/g'`) #explode on the comma separating the variables
	
	#verify the correct number of configuration parameters are in the configuration file
	if [[ ! ${#explode[@]} == 10 ]]; then
		echo ""
		send_mail "$log_file_location/${0##*/}_Config_file_incorrect_last_message_sent.txt" "WARNING - the configuration file is incorrect or corrupted. It should have 10 parameters, it currently has ${#explode[@]} parameters." "Warning NAS \"$nas_name\" SNMP Monitoring Failed for script \"${0##*/}\" - Configuration file is incorrect" 60
		exit 1
	fi
	
	email_address=${explode[0]}
	email_interval=${explode[1]} #in minutes 
	influxdb_host=${explode[2]}
	influxdb_port=${explode[3]}
	influxdb_name=${explode[4]}
	influxdb_pass=${explode[5]}
	script_enable=${explode[6]}
	from_email_address=${explode[7]}
	influxdb_org=${explode[8]}
	capture_interval=${explode[9]}


	if [ $script_enable -eq 1 ]
	then

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
			
			#Create empty URL
			post_url=
	#		containerID=()
	#		containerName=()
	#		containerCPU=()
	#		containerMemUsage=()
	#		containerMemLimit=()
	#		containerMemPercent=()
	#		containerNetIO=()
	#		containerBlockIO=()
	#		containerPID=()
			secondString=""

				xx=0
				while IFS= read -r line; do	
					if [[ $xx -gt 0 ]]; then
						#echo -e "\nline $xx: $line\n"
						explode=(`echo $line | sed 's/,/ /g'`)
						
						yy=0
						for yy in "${!explode[@]}"; do
							if [ $yy -eq 3 ] || [ $yy -eq 5 ] || [ $yy -eq 7 ] || [ $yy -eq 9 ] || [ $yy -eq 10 ] || [ $yy -eq 12 ]; then
								if [[ ${explode[$yy]} =~ "MiB" ]]; then
									filtered=${explode[$yy]}
									filtered=$(echo "${filtered::-3}")
									filtered=$(printf "%.0f\n" "${filtered}e2")
									explode[$yy]=$(( $filtered * 1024 * 1024 / 100 ))
								elif [[ ${explode[$yy]} =~ "MB" ]]; then
									filtered=${explode[$yy]}
									filtered=$(echo "${filtered::-2}")
									filtered=$(printf "%.0f\n" "${filtered}e2")
									explode[$yy]=$(( $filtered * 1024 * 1024 / 100 ))
								elif [[ ${explode[$yy]} =~ "GiB" ]]; then
									filtered=${explode[$yy]}
									filtered=$(echo "${filtered::-3}")
									filtered=$(printf "%.0f\n" "${filtered}e2")
									explode[$yy]=$(( $filtered * 1024 * 1024 * 1024 / 100 ))
								elif [[ ${explode[$yy]} =~ "GB" ]]; then
									filtered=${explode[$yy]}
									filtered=$(echo "${filtered::-2}")
									filtered=$(printf "%.0f\n" "${filtered}e2")
									explode[$yy]=$(( $filtered * 1024 * 1024 * 1024 / 100 ))
								elif [[ ${explode[$yy]} =~ "KB" ]]; then
									filtered=${explode[$yy]}
									filtered=$(echo "${filtered::-2}")
									filtered=$(printf "%.0f\n" "${filtered}e2")
									explode[$yy]=$(( $filtered * 1024 / 100 ))
								elif [[ ${explode[$yy]} =~ "KiB" ]]; then
									filtered=${explode[$yy]}
									filtered=$(echo "${filtered::-3}")
									filtered=$(printf "%.0f\n" "${filtered}e2")
									explode[$yy]=$(( $filtered * 1024 / 100 ))
								elif [[ ${explode[$yy]} =~ "k" ]]; then
									filtered=${explode[$yy]}
									filtered=$(echo "${filtered::-1}")
									filtered=$(printf "%.0f\n" "${filtered}e2")
									explode[$yy]=$(( $filtered * 1024 / 100 ))
								elif [[ ${explode[$yy]} =~ "K" ]]; then
									filtered=${explode[$yy]}
									filtered=$(echo "${filtered::-1}")
									filtered=$(printf "%.0f\n" "${filtered}e2")
									explode[$yy]=$(( $filtered * 1024 / 100 ))
								elif [[ ${explode[$yy]} =~ "TB" ]]; then
									filtered=${explode[$yy]}
									filtered=$(echo "${filtered::-2}")
									filtered=$(printf "%.0f\n" "${filtered}e2")
									explode[$yy]=$(( $filtered *1024 * 1024 * 1024 * 1024 / 100 ))
								elif [[ ${explode[$yy]} =~ "TiB" ]]; then
									filtered=${explode[$yy]}
									filtered=$(echo "${filtered::-3}")
									filtered=$(printf "%.0f\n" "${filtered}e2")
									explode[$yy]=$(( $filtered *1024 * 1024 * 1024 * 1024 / 100 ))
								elif [[ ${explode[$yy]} =~ "B" ]]; then
									filtered=${explode[$yy]}
									filtered=$(echo "${filtered::-1}")
									explode[$yy]=$filtered
								fi
							fi
							if [ $yy -eq 2 ] || [ $yy -eq 6 ]; then
								filtered=${explode[$yy]}
								filtered=$(echo "${filtered::-1}")
								explode[$yy]=$filtered
							fi
						done
						#echo "ContainerID: \"${explode[0]}\""
						#echo "containerName: \"${explode[1]}\""
						#echo "containerCPU: \"${explode[2]}\""
						#echo "containerMemUsage: \"${explode[3]}\""
						#echo "containerMemLimit: \"${explode[5]}\""
						#echo "containerMemPercent: \"${explode[6]}\""
						#echo "containerNetIO_data_received: \"${explode[7]}\""
						#echo "containerNetIO_data_transmitted: \"${explode[9]}\""
						#echo "containerBlockIO_data_read: \"${explode[10]}\""
						#echo "containerBlockIO_data_written: \"${explode[12]}\""
						#echo "containerPID: \"${explode[13]}\""
						post_url=$post_url"docker_stats,nas_name=$nas_name,containerName=${explode[1]} containerCPU=${explode[2]},containerMemUsage=${explode[3]},containerMemLimit=${explode[5]},containerMemPercent=${explode[6]},containerNetIO_data_received=${explode[7]},containerNetIO_data_transmitted=${explode[9]},containerBlockIO_data_read=${explode[10]},containerBlockIO_data_written=${explode[12]},containerPID=${explode[13]}
"
					fi
					let xx=xx+1
				done < <(docker stats --no-stream)
					
			if [[ $debug -eq 1 ]]; then
				echo "$post_url"
			fi
			
			influxdb_name="d08bef3a660d435d"
			echo "$post_url" > "/mnt/ramfs/docker_data.txt"
			
			curl -XPOST "http://$influxdb_host:$influxdb_port/api/v2/write?bucket=$influxdb_name&org=$influxdb_org" -H "Authorization: Token $influxdb_pass" --data-binary "@/mnt/ramfs/docker_data.txt"
			
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
	if [[ "$email_address" == "" || "$from_email_address" == "" ]];then
		echo -e "\n\nNo email address information is configured, Cannot send an email indicating script \"${0##*/}\" config file is missing and script will not run"
	else
		send_mail "$log_file_location/${0##*/}_Config_file_missing_last_message_sent.txt" "Warning NAS \"$nas_name\" Docker Monitoring Failed for script \"${0##*/}\" - Configuration file is missing" "Warning NAS \"$nas_name\" Docker Monitoring Failed for script \"${0##*/}\" - Configuration file is missing" 60
	fi
	exit 1
fi
