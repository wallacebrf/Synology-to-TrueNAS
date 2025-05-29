#!/bin/bash
Application_name=()
app_folder_name=()
backup_dir=()


#####################################
#USER Variables
#####################################

log_file_location="/mnt/volume1/web/logging/notifications/app_backup.txt"
apps_directory="/mnt/volume1/apps"
number_of_bakups_to_keep=4
email_notifications=1 #set to 0 to disable email notifications
email_address="email@email.com" # semi-colon separate list of email addresses to be informed of the results of the script
from_email_address="email@email.com"
email_subject="TrueNAS Application Backup Log"

#ensure the order of the entires below match the order of the entires for the app_folder_name and backup_dir entries below. 
#to get the names of the apps used under the hood in TrueNAS, use "docker ps" in shell and look at the right column "NAMES". The name here may not match what the GUI says
Application_name+=("sickchill")							#entry 0
Application_name+=("ix-influxdb-influxdb-1")			#entry 1
Application_name+=("ix-radarr-radarr-1")				#Entry 2
Application_name+=("ix-portainer-portainer-1")			#entry 3
###########################
###########################
app_folder_name+=("sickchill")							#entry 0
app_folder_name+=("influxDB")							#entry 1
app_folder_name+=("radarr")								#entry 2
app_folder_name+=("portainer")							#entry 3
###########################
###########################
backup_dir+=("/mnt/volume1/Backups/apps/sickchill")		#entry 0
backup_dir+=("/mnt/volume1/Backups/apps/Influxdb")		#entry 1
backup_dir+=("/mnt/volume1/Backups/apps/radarr")		#entry 2
backup_dir+=("/mnt/volume1/Backups/apps/portainer")		#entry 3


#####################################
#Script Start
#####################################


#create a lock file to prevent more than one instance of this script from executing  at once
if ! mkdir "/mnt/volume1/web/logging/notifications/app_backup.lock"; then
	echo "Failed to aquire lock.\n" >&2
	exit 1
fi
trap 'rm -rf "/mnt/volume1/web/logging/notifications/app_backup.lock"' EXIT #remove the lockdir on exit


#####################################
#get current date
#####################################

DATE=$(date +%m-%d-%Y);

now=$(date +"%T")
 
#####################################
#Backup Application directories
#####################################
echo "" |& tee -a "$log_file_location"
now=$(date +"%T")
echo "<i>$now</i> - <b>BACKING UP APPLICATIONS</b><br><br>" |& tee "$log_file_location"

 #####################################
#Function to perform Application directory backups
#####################################
#Application_name=$1
#app_dir=$2
#backup_dir=$3
#tar_file_name=$4
#log_location=$5
#DATE=$6
#$app_folder_name=$7
truenas_Application_backup(){
	local app_status_flag=0
	now=$(date +"%T")
	echo "" |& tee -a "$5"
	echo "<br><br>$now - Backing up Application <u><i>\"$1\"</i></u><br>" |& tee -a "$5"
	if [ -f "$3/$4-$6.tar" ]; then
		echo "Backup file <i><u>\"$3/$4-$6.tar\"</u></i> already exists, <font color=\"red\">skipping backup process of Application <u><i>\"$1\"</i></u></font><br>" |& tee -a "$5"
	else
		if [ "$( docker ps | grep "$1" | grep "Up" )" != "" ]; then #app is running
			echo "Stopping Application <u><i>\"$1\"</i></u><br>" |& tee -a "$5"
			docker stop "$1"  |& tee -a "$5"
			app_status_flag=1
			sleep 1
		else
			app_status_flag=0
		fi
		
		if [ "$( docker ps | grep "$1" | grep "Up" )" != "" ]; then #app is running
			echo "<font color=\"red\">Stopping Application <u><i>\"$1\"</i></u> Failed. Skipping backup process for Application <u><i>\"$1\"</i></u></font><br>" |& tee -a "$5"
		else
			echo "<font color=\"green\">Application <u><i>\"$1\"</i></u> was successfully stopped</font><br>" |& tee -a "$5"
			echo "Creating backup file <i><b>$4-$6.tar</b></i><br>" |& tee -a "$5"
			tar cfW "$4-$6.tar" "$7"  |& tee -a "$5"
			if [ -f "$2/$4-$6.tar" ]; then
				echo "<u><i>\"$4-$6.tar\"</i></u> created<br>" |& tee -a "$5"
				echo "Moving <u><i>\"$4-$6.tar\"</i></u> to <u><i>\"$3\"</i></u><br>" |& tee -a "$5"
				mv "$4-$6.tar" "$3/$4-$6.tar"
				if [ -f "$3/$4-$6.tar" ]; then
					echo "Backup of <u><i>\"$1\"</i></u> complete, starting Application<br>" |& tee -a "$5"
					if [ $app_status_flag -eq 0 ]; then
						echo "This script found Application <u><i>\"$1\"</i></u> already in a stopped state, the application will not be restarted<br>" |& tee -a "$5"
					else
						docker start "$1"  |& tee -a "$5"
						if [ "$( docker ps | grep "$1" | grep "Up" )" != "" ]; then #app is running
							echo "<font color=\"green\">Application <u><i>\"$1\"</i></u> was successfully Started</font><br>" |& tee -a "$5"
						else
							echo "<font color=\"red\">Application <u><i>\"$1\"</i></u> could not be restarted</font><br>" |& tee -a "$5"
						fi
						sleep 1
					fi
				else
					echo "<br><font color=\"red\">Backup of <u><i>\"$1\"</i></u> failed, backup file not in destination folder, starting Application</font><br>" |& tee -a "$5"
					if [ $app_status_flag -eq 0 ]; then
						echo "This script found Application <u><i>\"$1\"</i></u> already in a stopped state, the application will not be restarted<br>" |& tee -a "$5"
					else
						docker start "$1"  |& tee -a "$5"
						if [ "$( docker ps | grep "$1" | grep "Up" )" != "" ]; then #app is running
							echo "<font color=\"green\">Application <u><i>\"$1\"</i></u> was successfully Started</font><br>" |& tee -a "$5"
						else
							echo "<font color=\"red\">Application <u><i>\"$1\"</i></u> could not be restarted</font><br>" |& tee -a "$5"
						fi
						sleep 1
					fi
				fi
			else
				echo "<br><font color=\"red\">Backup of <u><i>\"$1\"</i></u> failed, tar file not successfully created, starting Application</font><br>" |& tee -a "$5"
				if [ $app_status_flag -eq 0 ]; then
					echo "This script found Application <u><i>\"$1\"</i></u> already in a stopped state, the application will not be restarted<br>" |& tee -a "$5"
				else
					docker start "$1"  |& tee -a "$5"
					if [ "$( docker ps | grep "$1" | grep "Up" )" != "" ]; then #app is running
							echo "<font color=\"green\">Application <u><i>\"$1\"</i></u> was successfully Started</font><br>" |& tee -a "$5"
						else
							echo "<font color=\"red\">Application <u><i>\"$1\"</i></u> could not be restarted</font><br>" |& tee -a "$5"
						fi
					sleep 1
				fi
			fi
		fi
	fi
}



yy=0
for yy in "${!Application_name[@]}"; do
	cd "$apps_directory"
	current_dir=$(pwd)
	if [ "$current_dir" = "$apps_directory" ]; then
		truenas_Application_backup "${Application_name[$yy]}" "$apps_directory" "${backup_dir[$yy]}" "${Application_name[$yy]}" "$log_file_location" "$DATE" "${app_folder_name[$yy]}"
	else
		echo "<br><br><font color=\"red\">Could not change directory to <b><i>\"$apps_directory\"</i></b>, canceling backup process of <b><i>\"${Application_name[$yy]}\"</i></b></font><br><br>" |& tee -a "$log_file_location"
	fi
	
	cd "${backup_dir[$yy]}"
	current_dir=$(pwd)
	if [ "$current_dir" = "${backup_dir[$yy]}" ]; then
		echo "Cleaning up <i><i>\"sickchill\"</i></i> backup directory <i><i>\"${backup_dir[$yy]}\"</i></i><br>" |& tee -a "$log_file_location"
		ls -1t | tail -n +$number_of_bakups_to_keep | xargs rm -f
	else
		echo "<br><br><font color=\"red\">Could not change directory to <i><i>\"${backup_dir[$yy]}\"</i></i>, canceling cleaning of sickchill backup directory <i><i>\"${backup_dir[$yy]}\"</i></i></font><br><br>" |& tee -a "$log_file_location"
	fi
done

now=$(date +"%T")
echo "<br><br><b>$now - Backup Process Complete</b>" |& tee -a "$log_file_location"


if [[ $email_notifications -eq 1 ]]; then
	#https://github.com/oxyde1989/standalone-tn-send-email/tree/main
					
	#the command can only take one email address destination at a time. so if there are more than one email addresses in the list, we need to send them one at a time
	address_explode=(`echo "$email_address" | sed 's/;/\n/g'`)
	bb=0
	for bb in "${!address_explode[@]}"; do
		python3 /mnt/volume1/web/logging/multireport_sendemail.py --subject "$email_subject" --to_address "${address_explode[$bb]}" --mail_body_html "$(<$log_file_location)" --override_fromemail "$from_email_address"
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
