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


log_file_location="/mnt/volume1/web/logging/notifications"
lock_file_location="$log_file_location/trueNAS_snmp.lock"
config_file_location="/mnt/volume1/web/config/trueNAS_snmp_config.txt"

nas_name="TrueNAS" #this is only needed if the script cannot access the server name over SNMP, or if the config file is unavailable and will be used in any error messages
capture_interval_adjustment=3

#########################################
#Script Start
#########################################

#########################################################
#this function removes unneeded text "STRING: " from SNMP output, and unneeded " characters
#########################################################
function filter_data(){
	local sub_string_to_remove="$1"
	local item_being_filtered="$2"
	local filtered=$(echo ${item_being_filtered#${sub_string_to_remove}})
	local secondString=""
	filtered=${filtered//\"/$secondString}
	echo "$filtered"
}

debug=0

#check that the script is running as root or some of the commands required will not work
if [[ $( whoami ) != "root" ]]; then
	echo -e "ERROR - Script requires ROOT permissions, exiting script"
	exit 1
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
	if [[ ! ${#explode[@]} == 28 ]]; then
		echo ""
		send_mail "$log_file_location/${0##*/}_Config_file_incorrect_last_message_sent.txt" "WARNING - the configuration file is incorrect or corrupted. It should have 28 parameters, it currently has ${#explode[@]} parameters." "Warning NAS \"$nas_name\" SNMP Monitoring Failed for script \"${0##*/}\" - Configuration file is incorrect" 60
		exit 1
	fi
	
	max_hdd_temp=${explode[0]}
	email_address=${explode[1]}
	email_interval=${explode[2]} #in minutes 
	nas_url=${explode[3]}
	influxdb_host=${explode[4]}
	influxdb_port=${explode[5]}
	influxdb_name=${explode[6]}
	influxdb_pass=${explode[7]}
	script_enable=${explode[8]}
	snmp_authPass1=${explode[9]}
	snmp_privPass2=${explode[10]}
	nas_snmp_user=${explode[11]}
	snmp_auth_protocol=${explode[12]} #MD5  or SHA 
	snmp_privacy_protocol=${explode[13]} #AES or DES
	from_email_address=${explode[14]}
	influx_http_type=${explode[15]} #set to "http" or "https" based on your influxDB version
	influxdb_org=${explode[16]}
	capture_interval=${explode[17]}
	capture_zpool=${explode[18]}
	capture_zvol=${explode[19]}
	capture_arc=${explode[20]}
	capture_l2arc=${explode[21]}
	capture_zil=${explode[22]}
	capture_hdd_temps=${explode[23]}
	max_nvme_temp=${explode[24]}
	capture_nvidia=${explode[25]}
	max_GPU=${explode[26]}
	min_GPU_fan_RPM=${explode[27]}


	if [ $script_enable -eq 1 ]
	then
		
		#confirm that the SNMP settings were configured otherwise exit script
		if [ "$nas_snmp_user" = "" ];then
			send_mail "$log_file_location/${0##*/}_SNMP-Error_last_message_sent.txt" "TrueNAS NAS Username is BLANK, please configure the SNMP settings" "SNMP Setting Error for \"$nas_name_error\"" $email_interval
			exit 1
		else
			if [ "$snmp_authPass1" = "" ];then
				send_mail "$log_file_location/${0##*/}_SNMP-Error_last_message_sent.txt" "TrueNAS NAS Authentication Password is BLANK, please configure the SNMP settings" "SNMP Setting Error for \"$nas_name_error\"" $email_interval
				exit 1
			else
				if [ "$snmp_privPass2" = "" ];then
					send_mail "$log_file_location/${0##*/}_SNMP-Error_last_message_sent.txt" "TrueNAS NAS Privacy Password is BLANK, please configure the SNMP settings" "SNMP Setting Error for \"$nas_name_error\"" $email_interval
					exit 1
				else
					if [ $debug -eq 1 ];then
						echo "TrueNAS SNMP settings are not Blank"
					fi
				fi
			fi
		fi

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

			#########################################
			#GETTING VARIOUS SYSTEM INFORMATION
			#########################################
				
					
			if [ $capture_zpool -eq 1 ]; then
				measurement="zpool"
				zpool_name=()
				zpool_index=()
				zpool_health=()
				zpool_read_ops=()
				zpool_write_ops=()
				zpool_read_bytes=()
				zpool_write_bytes=()
				
				xx=0
				while IFS= read -r line; do	
					zpool_index+=($(filter_data "INTEGER: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.1.1.1.1 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zpool_name+=($(filter_data "STRING: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.1.1.1.2 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zpool_health+=($(filter_data "STRING: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.1.1.1.3 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zpool_read_ops+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.1.1.1.4 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zpool_write_ops+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.1.1.1.5 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zpool_write_ops+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.1.1.1.5 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zpool_read_bytes+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.1.1.1.6 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zpool_write_bytes+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.1.1.1.7 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zpool_write_bytes+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.1.1.1.7 -Ovt)



		
				xx=0
				for xx in "${!zpool_index[@]}"; do
					post_url=$post_url"$measurement,nas_name=$nas_name,zpool_index=${zpool_index[$xx]} zpool_name=\"${zpool_name[$xx]}\",zpool_health=\"${zpool_health[$xx]}\",zpool_read_ops=${zpool_read_ops[$xx]},zpool_write_ops=${zpool_write_ops[$xx]},zpool_read_bytes=${zpool_read_bytes[$xx]},zpool_write_bytes=${zpool_write_bytes[$xx]}
"
				done
			else
				echo "Skipping Zpool Data Collection"
			fi
			
			
			if [ $capture_zvol -eq 1 ]; then
				measurement="zvol"
				zvol_index=()
				zvol_descr=()
				zvol_used_bytes=()
				zvol_available_bytes=()
				zvol_referenced_bytes=()
				
				xx=0
				while IFS= read -r line; do	
					zvol_index+=($(filter_data "INTEGER: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.2.1.1.1 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zvol_descr+=($(filter_data "STRING: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.2.1.1.2 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zvol_used_bytes+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.2.1.1.3 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zvol_available_bytes+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.2.1.1.4 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zvol_referenced_bytes+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.2.1.1.5 -Ovt)


		
				xx=0
				for xx in "${!zvol_index[@]}"; do
					post_url=$post_url"$measurement,nas_name=$nas_name,zvol_index=${zvol_index[$xx]} zvol_descr=\"${zvol_descr[$xx]}\",zvol_used_bytes=${zvol_used_bytes[$xx]},zvol_available_bytes=${zvol_available_bytes[$xx]},zvol_referenced_bytes=${zvol_referenced_bytes[$xx]}
"
				done
			else
				echo "Skipping Zvol Data Collection"
			fi
			
			if [ $capture_arc -eq 1 ]; then
				measurement="arc"
				zfs_arc_size=()
				zfs_arc_meta=()
				zfs_arc_data=()
				zfs_arc_hits=()
				zfs_arc_misses=()
				zfs_arcc=()
				zfs_arc_miss_percent=()
				zfs_arc_cache_hit_ratio=()
				zfs_arc_cache_miss_ratio=()
				
				xx=0
				while IFS= read -r line; do	
					zfs_arc_size+=($(filter_data "Gauge32: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.3.1.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfs_arc_meta+=($(filter_data "Gauge32: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.3.2.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfs_arc_data+=($(filter_data "Gauge32: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.3.3.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfs_arc_hits+=($(filter_data "Gauge32: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.3.4.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfs_arc_misses+=($(filter_data "Gauge32: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.3.5.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfs_arcc+=($(filter_data "Gauge32: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.3.6.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfs_arc_miss_percent+=($(filter_data "STRING: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.3.8.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfs_arc_cache_hit_ratio+=($(filter_data "STRING: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.3.9.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfs_arc_cache_miss_ratio+=($(filter_data "STRING: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.3.10.0 -Ovt)

				xx=0
				post_url=$post_url"$measurement,nas_name=$nas_name zfs_arc_size=${zfs_arc_size[$xx]},zfs_arc_meta=${zfs_arc_meta[$xx]},zfs_arc_data=${zfs_arc_data[$xx]},zfs_arc_hits=${zfs_arc_hits[$xx]},zfs_arc_misses=${zfs_arc_misses[$xx]},zfs_arcc=${zfs_arcc[$xx]},zfs_arc_miss_percent=${zfs_arc_miss_percent[$xx]},zfs_arc_cache_hit_ratio=${zfs_arc_cache_hit_ratio[$xx]},zfs_arc_cache_miss_ratio=${zfs_arc_cache_miss_ratio[$xx]}
"

			else
				echo "Skipping arc Data Collection"
			fi
			
			if [ $capture_l2arc -eq 1 ]; then
				measurement="l2arc"
				zfsl2arc_hits=()
				zfsl2arc_misses=()
				zfsl2arc_read=()
				zfsl2arc_write=()
				zfsl2arc_size=()
				
				xx=0
				while IFS= read -r line; do	
					zfsl2arc_hits+=($(filter_data "Counter32: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.4.1.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfsl2arc_misses+=($(filter_data "Counter32: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.4.2.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfsl2arc_read+=($(filter_data "Counter32: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.4.3.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfsl2arc_write+=($(filter_data "Counter32: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.4.4.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfsl2arc_size+=($(filter_data "Gauge32: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.4.5.0 -Ovt)

				xx=0
					post_url=$post_url"$measurement,nas_name=$nas_name zfsl2arc_hits=${zfsl2arc_hits[$xx]},zfsl2arc_misses=${zfsl2arc_misses[$xx]},zfsl2arc_read=${zfsl2arc_read[$xx]},zfsl2arc_write=${zfsl2arc_write[$xx]},zfsl2arc_size=${zfsl2arc_size[$xx]}
"
			else
				echo "Skipping l2arc Data Collection"
			fi
			
			if [ $capture_zil -eq 1 ]; then
				measurement="zil"
				zfs_zilstat_ops1sec=()
				zfs_zilstat_ops5sec=()
				zfs_zilstat_ops10sec=()
				
				xx=0
				while IFS= read -r line; do	
					zfs_zilstat_ops1sec+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.5.1.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfs_zilstat_ops5sec+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.5.2.0 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					zfs_zilstat_ops10sec+=($(filter_data "Counter64: " "$line"))
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.1.5.3.0 -Ovt)
				
				xx=0
					post_url=$post_url"$measurement,nas_name=$nas_name zfs_zilstat_ops1sec=${zfs_zilstat_ops1sec[$xx]},zfs_zilstat_ops5sec=${zfs_zilstat_ops5sec[$xx]},zfs_zilstat_ops10sec=${zfs_zilstat_ops10sec[$xx]}
"
			else
				echo "Skipping zil Data Collection"
			fi
			
			if [ $capture_hdd_temps -eq 1 ]; then
				measurement="hdd_temp"
				hdd_temp_device=()
				hdd_temp_value=()

				xx=0
				while IFS= read -r line; do	
					hdd_temp_device+=($(filter_data "STRING: " "$line"))
					
					#many NVME devices have more than one temperature sensor. Unfortunately TueNAS SNMP only returns one value. 
					#to get around this we will pull the multiple sensors directly off the NVME drives if they exist
					#for example, on my MNVE drive, there are three temperatures as can be seen from the "hdd_temp_nvme" line, and one sensor is reading 5 degrees higher then the others, and it seems this temperature does not always match what Truenas is reporting in the line "hdd_temp_snmp"
					
					#hdd_temp_nvme,nas_name=TrueNAS,device="nvme0n1" nvme_temp=41,nvme_temp1=41,nvme_temp2=46
					#hdd_temp_snmp,nas_name=TrueNAS,device="sda" hdd_temp_value="32000"
					#hdd_temp_snmp,nas_name=TrueNAS,device="nvme0n1" hdd_temp_value="40000"
					
					if [[ "$(echo $line | grep "nvme")" != "" ]]; then
						nvme_data=$(nvme smart-log /dev/${hdd_temp_device[$xx]} | grep "temperature")
						nvme_data=$(echo ${nvme_data##*:} | xargs) #remove "temperature:" from beginning of line
						nvme_temp=$(echo "${nvme_data%°*}") #remove "°(xxKelvin)" from temperatures
						if [[ $nvme_temp == "" ]]; then
							nvme_temp=0
						fi
						
						nvme_data=$(nvme smart-log /dev/${hdd_temp_device[$xx]} | grep "Temperature Sensor 1")
						nvme_data=$(echo ${nvme_data##*:} | xargs) #remove "Temperature Sensor 1:" from beginning of line
						nvme_temp1=$(echo "${nvme_data%°*}") #remove "°(xxKelvin)" from temperatures
						if [[ $nvme_temp1 == "" ]]; then
							nvme_temp1=0
						fi
						
						nvme_data=$(nvme smart-log /dev/${hdd_temp_device[$xx]} | grep "Temperature Sensor 2")
						nvme_data=$(echo ${nvme_data##*:} | xargs) #remove "Temperature Sensor 2:" from beginning of line
						nvme_temp2=$(echo "${nvme_data%°*}") #remove "°(xxKelvin)" from temperatures
						if [[ $nvme_temp2 == "" ]]; then
							nvme_temp2=0
						fi

						if [[ $nvme_temp > $max_nvme_temp ]] || [[ $nvme_temp1 > $max_nvme_temp ]] || [[ $nvme_temp2 > $max_nvme_temp ]]; then
							send_mail "$log_file_location/${0##*/}_nvme_temp_last_message_sent.txt" "TrueNAS NVME drive \"/dev/${hdd_temp_device[$xx]}\" is reporting over $max_nvme_temp degrees C. It is currently reporting Temperature: $nvme_temp, Temperature Sensor 1: $nvme_temp1, and Temperature Sensor 2: $nvme_temp2 degrees C" "TrueNAS NMVE Disk Temperature Alert" $email_interval
						fi
					
						post_url=$post_url"${measurement}_nvme,nas_name=$nas_name,device=${hdd_temp_device[$xx]} nvme_temp=$nvme_temp,nvme_temp1=$nvme_temp1,nvme_temp2=$nvme_temp2
"
					fi
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.3.1.2 -Ovt)
				#########################################	
				xx=0
				while IFS= read -r line; do	
					hdd_temp_value+=($(filter_data "Gauge32: " "$line"))

					if [[ $(( ${hdd_temp_value[$xx]} / 1000 )) > $max_hdd_temp ]]; then
						send_mail "$log_file_location/${0##*/}_hdd_temp_last_message_sent.txt" "TrueNAS HDD drive \"/dev/${hdd_temp_device[$xx]}\" is reporting over $max_hdd_temp degrees C. It is currently reporting Temperature: $(( ${hdd_temp_value[$xx]} / 1000 )) degrees C" "TrueNAS HDD Disk Temperature Alert" $email_interval
					fi
					
					let xx=xx+1
				done < <(snmpwalk -v3 -l authPriv -u $nas_snmp_user -a $snmp_auth_protocol -A $snmp_authPass1 -x $snmp_privacy_protocol -X $snmp_privPass2 $snmp_device_url:161 1.3.6.1.4.1.50536.3.1.3 -Ovt)
				
				xx=0
				for xx in "${!hdd_temp_device[@]}"; do
					post_url=$post_url"${measurement}_snmp,nas_name=$nas_name,device=${hdd_temp_device[$xx]} hdd_temp=${hdd_temp_value[$xx]}
"
				done
			else
				echo "Skipping HDD Temp Data Collection"
			fi
			
			#The TrueNAS exported data does not include GPU temperature or GPU fan speed data. Let's gather that from the NVidia drivers directly
			if [ $capture_nvidia -eq 1 ]; then
				#confirm that the NVidia drivers are actually installed.
				if ! command -v nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader &> /dev/null
				then
					echo "NVidia Drivers are not installed"
				else
					measurement="GPU"
					
					#RAW Data
					raw_data=$(nvidia-smi --query-gpu=temperature.gpu,gpu_name,fan.speed,gpu_bus_id,vbios_version,driver_version,pcie.link.gen.max,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used,gpu_serial,pstate,encoder.stats.sessionCount,encoder.stats.averageFps,encoder.stats.averageLatency,temperature.memory,power.draw,power.limit,clocks.current.graphics,clocks.current.sm,clocks.current.memory,clocks.current.video --format=csv,noheader)
					
					#${main_string/search_term/replace_term}
					raw_data=$(echo ${raw_data// %/}) #remove all instances of " %"
					raw_data=$(echo ${raw_data// MiB/}) #remove all instances of " MiB"
					raw_data=$(echo ${raw_data// W/}) #remove all instances of " W"
					raw_data=$(echo ${raw_data// MHz/}) #remove all instances of " MHz"
					raw_data=$(echo ${raw_data// /}) #replace all remaining spaces with ""
					
					echo -e "\n\n$raw_data\n\n"
					
					raw_data=(`echo $raw_data | sed 's/,/\n/g'`) #explode the results into an array so we can extract each item

					gpuTemperature=${raw_data[0]}
					
					gpuName=${raw_data[1]}
				
					gpuFanSpeed=${raw_data[2]}
					
					gpu_bus_id=${raw_data[3]}
					
					vbios_version=${raw_data[4]}
					
					driver_version=${raw_data[5]}
					
					pcie_link_gen_max=${raw_data[6]}
					
					utilization_gpu=${raw_data[7]}
					
					utilization_memory=${raw_data[8]}
					
					memory_total=${raw_data[9]}
					
					memory_free=${raw_data[10]}
					
					memory_used=${raw_data[11]}
					
					gpu_serial=${raw_data[12]}
					
					pstate=${raw_data[13]}
					
					encoder_stats_sessionCount=${raw_data[14]}					
					
					encoder_stats_averageFps=${raw_data[15]}
					
					encoder_stats_averageLatency=${raw_data[16]}
					
					temperature_memory=${raw_data[17]}
					if [[ "$temperature_memory" == "N/A" ]]; then
						temperature_memory=0
					fi
					
					power_draw=${raw_data[18]}
					if [[ "$power_draw" == "[NotSupported]" ]]; then
						power_draw=0
					fi
					
					power_limit=${raw_data[19]}
					
					clocks_current_graphics=${raw_data[20]}
					
					clocks_current_sm=${raw_data[21]}
					
					clocks_current_memory=${raw_data[22]}
					
					clocks_current_video=${raw_data[23]}
	
					if [[ $gpuTemperature > $max_GPU ]]; then
						send_mail "$log_file_location/${0##*/}_gpu_temp_last_message_sent.txt" "TrueNAS GPU Temperature is reporting over $max_GPU degrees C. It is currently reporting $gpuTemperature degrees C" "TrueNAS GPU Temperature Alert" $email_interval
					fi
					
					if [[ $gpuFanSpeed < $min_GPU_fan_RPM ]]; then
						send_mail "$log_file_location/${0##*/}_gpu_fan_last_message_sent.txt" "TrueNAS GPU Fan Speed is reporting below $min_GPU_fan_RPM degrees C. It is currently reporting $gpuFanSpeed RPM" "TrueNAS GPU Fan Speed Alert" $email_interval
					fi
					
					post_url=$post_url"$measurement,nas_name=$nas_name gpuTemperature=$gpuTemperature,gpuName=\"$gpuName\",gpuFanSpeed=$gpuFanSpeed,gpu_bus_id=\"$gpu_bus_id\",vbios_version=\"$vbios_version\",driver_version=\"$driver_version\",pcie_link_gen_max=$pcie_link_gen_max,utilization_gpu=$utilization_gpu,utilization_memory=$utilization_memory,memory_total=$memory_total,memory_free=$memory_free,memory_used=$memory_used,gpu_serial=\"$gpu_serial\",pstate=\"$pstate\",encoder_stats_sessionCount=$encoder_stats_sessionCount,encoder_stats_averageFps=$encoder_stats_averageFps,encoder_stats_averageLatency=$encoder_stats_averageLatency,temperature_memory=$temperature_memory,power_draw=$power_draw,power_limit=$power_limit,clocks_current_graphics=$clocks_current_graphics,clocks_current_sm=$clocks_current_sm,clocks_current_memory=$clocks_current_memory,clocks_current_video=$clocks_current_video
"
					echo "$post_url"
				fi
			else
				echo "Skipping NVidia Capture"
			fi
			
			
			if [[ $debug -eq 1 ]]; then
				echo "$post_url"
			fi
			
			curl -XPOST "http://$influxdb_host:$influxdb_port/api/v2/write?bucket=$influxdb_name&org=$influxdb_org" -H "Authorization: Token $influxdb_pass" --data-raw "$post_url"
			
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
		send_mail "$SS_Station_restart_tracking" "Warning NAS \"$nas_name_error\" SNMP Monitoring Failed for script \"${0##*/}\" - Configuration file is missing" "Warning NAS \"$nas_name_error\" SNMP Monitoring Failed for script \"${0##*/}\" - Configuration file is missing" 60
	fi
	exit 1
fi
