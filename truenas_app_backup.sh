#!/bin/bash
Application_name=()
app_folder_location=()
backup_dir=()


#####################################
#USER Variables
#####################################

log_file_location="/mnt/volume1/logging/notifications/docker_backup.txt"
number_of_bakups_to_keep=3
email_notifications=1 #set to 0 to disable email notifications
email_address="email@email.com" # semi-colon separate list of email addresses to be informed of the results of the script
from_email_address="email@email.com"
email_subject="TrueNAS Application Backup Log"

#!!!!!!ENSURE THE ORDER OF THE APPLICATION NAMES, APPLICATION FOLDER LOCATIONS, AND APPLICATION BACKUP TARGETS ARE ALL IN THE CORRECT ORDER BELOW OR THE SCRIPT WILL NOT OPERATE CORRECTLY


#Ensure the app name as used in the TrueNAS Gui is used
Application_name+=("torrent")					#entry 0
Application_name+=("chromium")					#entry 1
Application_name+=("jackett")					#entry 2
Application_name+=("prowlarr")					#entry 3
Application_name+=("radarr")					#entry 4
Application_name+=("sickchill")					#entry 5
Application_name+=("flaresolverr")				#entry 6
Application_name+=("chromiumnormal")			#entry 7
Application_name+=("convertx")					#Entry 8
Application_name+=("doublecommander")			#entry 9
Application_name+=("dozzle")					#entry 10
Application_name+=("filebrowser")				#entry 11
Application_name+=("frigate-tensorrt")			#entry 12
Application_name+=("grafana")					#entry 13
Application_name+=("greylog")					#entry 14
Application_name+=("immich")					#entry 15
Application_name+=("influxdb")					#entry 16
Application_name+=("jellyfin")					#entry 17
Application_name+=("netdata")					#entry 18
Application_name+=("netdataofficial")			#entry 19
Application_name+=("nginx-proxy-manager")		#entry 20
Application_name+=("plex")						#entry 21
Application_name+=("sftpgo")					#entry 22
Application_name+=("tautulli")					#entry 23
Application_name+=("tftpd-hpa")					#entry 24
Application_name+=("web")						#entry 25
Application_name+=("urbackup")					#entry 26
###########################
###########################
app_folder_location+=("/mnt/volume1/apps/torrent/transmission_config")	#entry 0
app_folder_location+=("/mnt/volume1/apps/chromium")					#entry 1
app_folder_location+=("/mnt/volume1/apps/jackett")					#entry 2
app_folder_location+=("/mnt/volume1/apps/prowlarr")					#entry 3
app_folder_location+=("/mnt/volume1/apps/radarr")					#entry 4
app_folder_location+=("/mnt/volume1/apps/sickchill")				#entry 5
app_folder_location+=("")											#entry 6
app_folder_location+=("/mnt/volume1/apps/chromiumnormal")			#entry 7
app_folder_location+=("/mnt/volume1/apps/convertx")					#Entry 8
app_folder_location+=("/mnt/volume1/apps/doublecommander")			#entry 9
app_folder_location+=("/mnt/volume1/apps/dozzel")					#entry 10
app_folder_location+=("/mnt/volume1/apps/filebrowser")				#entry 11
app_folder_location+=("/mnt/volume1/apps/figate")					#entry 12
app_folder_location+=("/mnt/volume1/apps/grafana")					#entry 13
app_folder_location+=("/mnt/volume1/apps/greylog")					#entry 14
app_folder_location+=("/mnt/volume1/apps/immich")					#entry 15
app_folder_location+=("/mnt/volume1/apps/influxdb")					#entry 16
app_folder_location+=("/mnt/volume1/apps/jellyfin")					#entry 17
app_folder_location+=("/mnt/volume1/apps/telegraph")				#entry 18
app_folder_location+=("/mnt/volume1/apps/netdata")					#entry 19
app_folder_location+=("/mnt/volume1/apps/nginx_reverse_proxy")		#entry 20
app_folder_location+=("/mnt/volume1/apps/plex")						#entry 21
app_folder_location+=("/mnt/volume2/fortigate_auto_backup")			#entry 22
app_folder_location+=("/mnt/volume1/apps/tautulli")					#entry 23
app_folder_location+=("/mnt/volume1/tftpd-hpa")						#entry 24
app_folder_location+=("/mnt/volume1/hosting")						#entry 25
app_folder_location+=("/mnt/volume1/apps/urbackup")					#entry 26
###########################
###########################
backup_dir+=("/mnt/volume2/Backups/apps/torrent")					#entry 0
backup_dir+=("/mnt/volume2/Backups/apps/chromium")					#entry 1
backup_dir+=("/mnt/volume2/Backups/apps/jackett")					#entry 2
backup_dir+=("/mnt/volume2/Backups/apps/prowlarr")					#entry 3
backup_dir+=("/mnt/volume2/Backups/apps/radarr")					#entry 4
backup_dir+=("/mnt/volume2/Backups/apps/sickchill")					#entry 5
backup_dir+=("/mnt/volume2/Backups/apps/flaresolverr")				#entry 6
backup_dir+=("/mnt/volume2/Backups/apps/chromiumnormal")			#entry 7
backup_dir+=("/mnt/volume2/Backups/apps/convertx")					#Entry 8
backup_dir+=("/mnt/volume2/Backups/apps/doublecommander")			#entry 9
backup_dir+=("/mnt/volume2/Backups/apps/dozzle")					#entry 10
backup_dir+=("/mnt/volume2/Backups/apps/filebrowser")				#entry 11
backup_dir+=("/mnt/volume2/Backups/apps/frigate")					#entry 12
backup_dir+=("/mnt/volume2/Backups/apps/grafana")					#entry 13
backup_dir+=("/mnt/volume2/Backups/apps/greylog")					#entry 14
backup_dir+=("/mnt/volume2/Backups/apps/immich")					#entry 15
backup_dir+=("/mnt/volume2/Backups/apps/influxdb")					#entry 16
backup_dir+=("/mnt/volume2/Backups/apps/jellyfin")					#entry 17
backup_dir+=("/mnt/volume2/Backups/apps/netdata")					#entry 18
backup_dir+=("/mnt/volume2/Backups/apps/netdataofficial")			#entry 19
backup_dir+=("/mnt/volume2/Backups/apps/nginx-proxy-manager")		#entry 20
backup_dir+=("/mnt/volume2/Backups/apps/plex")						#entry 21
backup_dir+=("/mnt/volume2/Backups/apps/sftpgo")					#entry 22
backup_dir+=("/mnt/volume2/Backups/apps/tautulli")					#entry 23
backup_dir+=("/mnt/volume2/Backups/apps/tftpd-hpa")					#entry 24
backup_dir+=("/mnt/volume2/Backups/apps/web")						#entry 25
backup_dir+=("/mnt/volume2/Backups/apps/urbackup")					#entry 26


#####################################
#Script Start
#####################################


#create a lock file to prevent more than one instance of this script from executing  at once
if ! mkdir -p "/mnt/volume1/web/logging/notifications/trueNAS_app_backup.lock"; then
	echo "Failed to aquire lock.\n" >&2
	exit 1
fi
trap 'rm -rf "/mnt/volume1/web/logging/notifications/plex_docker_backup.lock"' EXIT #remove the lockdir on exit


#####################################
#get current date
#####################################

DATE=$(date +%m-%d-%Y);

now=$(date +"%T")
 
#####################################
#Backup Docker directories
#####################################
echo "" |& tee -a "$log_file_location"
now=$(date +"%T")
echo "$now - BACKING UP TRUENAS APPLICATIONS" |& tee "$log_file_location"

 #####################################
#Function to perform docker directory backups
#####################################
# Usage docker_Application_backup Application_name docker_dir backup_dir tar_file_name log_location DATE app_folder_location
#Application_name=$1
#UNUSED=$2
#backup_dir=$3
#tar_file_name=$4
#log_location=$5
#DATE=$6
#$app_folder_location=$7
docker_Application_backup(){
	#extract the name of the directory we are making a .tar of, and extract where that directory is located
	local temp_dir="$7" #example /mnt/volume1/apps
	local base="${temp_dir##*/}" #result is "apps" (basepath)
	local dir="${temp_dir%$base}" #result is "/mnt/volume1/" (dirpath)
	dir="${dir::-1}" #get rid of trailing "/" so we end up with just "/mnt/volume1"
	
	echo "Changing working directory to \"$dir\"" |& tee -a "$5"
	
	cd "$dir"
	local current_dir=$(pwd)
	if [ "$current_dir" != "$dir" ]; then
		echo "Failed to change to directory \"$dir\", skipping backup of TrueNAS Application \"$1\" " |& tee -a "$5"
	else
		local app_installed=0
		local app_state=0
		local app_stopped=0
		local current_app_status=$(midclt call app.query '[["name", "=", "'$1'"]]' | jq -r '.[] | .state')
		
		#determine if the app is installed and if it is installed determine its running state so we can maintain the current state after the backup is complete
		if [[ "$current_app_status" == "" ]]; then #app is not installed
			echo "TrueNAS Application \"$1\" is NOT installed" |& tee -a "$5"
		elif [[ "$current_app_status" == "RUNNING" ]]; then #app is installed and running
			app_installed=1
			app_state=1
			echo "TrueNAS Application \"$1\" is installed and running" |& tee -a "$5"
		elif [[ "$current_app_status" == "STOPPED" ]]; then #app is installed and stopped
			app_installed=1
			echo "TrueNAS Application \"$1\" is installed but currently stopped" |& tee -a "$5"
		fi
		
		if [[ $app_installed -eq 1 ]]; then #is app installed
			now=$(date +"%T")
			echo "" |& tee -a "$5"
			echo "$now - Backing up TrueNAS Application \"$1\"" |& tee -a "$5"
			if [ -f "$3/$4-$6.tar" ]; then
				echo "Backup file \"$3/$4-$6.tar\" already exists, skipping backup process of Docker Application \"$1\"" |& tee -a "$5"
			else
				if [[ $app_state -eq 1 ]]; then #app was found in the running state
					echo "Stopping Application \"$1\"" |& tee -a "$5"
					midclt call app.stop "$1"
					echo "Waiting 60 seconds for app to stop" |& tee -a "$5" #the midclt command returns a value immediatwlly even though the app is not yet stopped
					sleep 10
					echo "50 seconds remaining"
					sleep 10
					echo "40 seconds remaining"
					sleep 10
					echo "30 seconds remaining"
					sleep 10
					echo "20 seconds remaining"
					sleep 10
					echo "10 seconds remaining"
					sleep 10
					if [ "$( midclt call app.query '[["name", "=", "'$1'"]]' | jq -r '.[] | .state' )" == "STOPPED" ]; then #app is installed and stopped
						echo "Application \"$1\" Sucessfully Stopped" |& tee -a "$5"
						app_stopped=1
					else
						echo "Application \"$1\" Failed to Stop " |& tee -a "$5"
						app_stopped=0
					fi
				else
					echo "Application \"$1\" was already stopped" |& tee -a "$5"
					app_stopped=1
				fi
			
				if [[ $app_stopped -eq 1 ]]; then 
					echo "Creating backup file $4-$6.tar" |& tee -a "$5"
					tar cfW "$4-$6.tar" "$base"  |& tee -a "$5"
					if [ -f "$4-$6.tar" ]; then
						echo "\"$dir/$4-$6.tar\" created" |& tee -a "$5"
						echo "Moving \"$dir/$4-$6.tar\" to \"$3\"" |& tee -a "$5"
						mv "$4-$6.tar" "$3/$4-$6.tar"
						if [ -f "$3/$4-$6.tar" ]; then
							echo "Backup of \"$1\" complete" |& tee -a "$5"
						else
							echo "Backup of \"$1\" failed, file was not moved to the final destination" |& tee -a "$5"
						fi
					else
						echo "Backup of \"$1\" failed, .tar file was not created" |& tee -a "$5"
					fi
				else
					echo "Backup of \"$1\" skipped as the TrueNAS Application was not stopped" |& tee -a "$5"
				fi

				if [[ $app_state -eq 1 ]]; then #app was installed and found running, so we want to return the app to the running state after the backup nis complete
					if [[ $app_stopped -eq 1 ]]; then	#we sucessfully stopped the app, let's restart it
						echo "Starting Application \"$1\"" |& tee -a "$5"
						midclt call app.start "$1"
						echo "Waiting 60 seconds for app to start" |& tee -a "$5" #the midclt command returns a value immediatwlly even though the app is not yet started
						sleep 10
						echo "50 seconds remaining"
						sleep 10
						echo "40 seconds remaining"
						sleep 10
						echo "30 seconds remaining"
						sleep 10
						echo "20 seconds remaining"
						sleep 10
						echo "10 seconds remaining"
						sleep 10
						if [ "$( midclt call app.query '[["name", "=", "'$1'"]]' | jq -r '.[] | .state' )" == "RUNNING" ]; then #app is installed and running
							echo "Application \"$1\" Sucessfully Started" |& tee -a "$5"
						else
							echo "Application \"$1\" Failed to Start" |& tee -a "$5"
						fi
					else
						echo "Application \"$1\" Failed to Stop prior to backup process, leaving app as is" |& tee -a "$5"
					fi
				else
					echo "Application \"$1\" was already stopped, leaving app as it was found" |& tee -a "$5"
				fi
			fi
		else
			echo "Application \"$1\" is not installed on the system, nothing to back up" |& tee -a "$5"
		fi
	fi
}

yy=0
for yy in "${!Application_name[@]}"; do
	if [ "${app_folder_location[$yy]}" == "" ]; then
		echo "Restarting \"${Application_name[$yy]}\", but not performing a backup. This may be needed when one docker TrueNAS Application is dependant on one already backed up" |& tee -a "$log_file_location"
		echo "---------------------------------------------------" |& tee -a "$log_file_location"
		midclt call app.start "${Application_name[$yy]}" #this command both starts a stopped TrueNAS Application, but also re-starts an already running TrueNAS Application
	else
		#check to make sure our target backup directory exists, if not make it
		if [ -d "${backup_dir[$yy]}" ]; then
			echo "\"${backup_dir[$yy]}\" does exist" |& tee -a "$log_file_location"
		else
			echo "Creating backup directory \"${backup_dir[$yy]}\"" |& tee -a "$log_file_location"
			mkdir -p "${backup_dir[$yy]}"
		fi
		
		#check that we made the needed directory, if not, do not proceed with backup
		if [ -d "${backup_dir[$yy]}" ]; then
			docker_Application_backup "${Application_name[$yy]}" "" "${backup_dir[$yy]}" "${Application_name[$yy]}" "$log_file_location" "$DATE" "${app_folder_location[$yy]}"
		
			#performning cleanup of the backup directory to only keep a certain number of backups
			cd "${backup_dir[$yy]}"
			current_dir=$(pwd)
			if [ "$current_dir" = "${backup_dir[$yy]}" ]; then
				echo "Cleaning up \"${Application_name[$yy]}\" backup directory \"${backup_dir[$yy]}\"" |& tee -a "$log_file_location"
				ls -1t | tail -n +$number_of_bakups_to_keep | xargs rm -f
			else
				echo "Could not change directory to \"${backup_dir[$yy]}\", canceling cleaning of ${Application_name[$yy]} backup directory \"${backup_dir[$yy]}\"" |& tee -a "$log_file_location"
			fi
		else
			echo "Failed to create backup directory \"${backup_dir[$yy]}\", skipping app backup" |& tee -a "$log_file_location"
		fi
		echo "---------------------------------------------------" |& tee -a "$log_file_location"
	fi
done

now=$(date +"%T")
echo "$now - Backup Process Complete" |& tee -a "$log_file_location"

#email_notifications=0
if [[ $email_notifications -eq 1 ]]; then
	#https://github.com/oxyde1989/standalone-tn-send-email/tree/main
					
	#the command can only take one email address destination at a time. so if there are more than one email addresses in the list, we need to send them one at a time
	address_explode=(`echo "$email_address" | sed 's/;/\n/g'`)
	bb=0
	for bb in "${!address_explode[@]}"; do
		python3 /mnt/volume1/logging/multireport_sendemail.py --subject "$email_subject" --to_address "${address_explode[$bb]}" --mail_body_html "$email_subject" --override_fromemail "$from_email_address"  --attachment_files "$log_file_location"
	done
fi

exit


#cleanup command explanation
#ls : List directory contents.
#-1t : 1(Number one) indicates that the output of ls should be one file per line. t indicates sort contents by modification time, newest first.
#tail : Output the last part of files.
#-n +x : output the last x NUM lines, instead of the last 10; or use -n +NUM to output starting with line NUM
#xargs : Build and execute command lines from standard input.
#rm -f : Remove files or directories. f indicates ignore nonexistent files and arguments, never prompt. It means that this command won't display any error messages if there are less than 10 files.
#| - It is a pipeline. It is generally a sequence of one or more commands separated by one of the control operators | or |&.
#So, the above command will delete the oldest files if there are more than 10 files in the current working directory. To verify how many files are in the directory after deleting the oldest file(s), just run:
