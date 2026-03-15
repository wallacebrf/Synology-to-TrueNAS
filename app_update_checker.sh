#!/bin/bash

Application_name=()
apps_not_installed=()
apps_up_to_date=()
apps_update_available=()
change_logs=()
apps_custom=()
app_version_installed=()
app_version_available=()
email_body=""
email_address="email@email.com" # semi-colon separate list of email addresses to be informed of the results of the script
from_email_address="email@email.com"
email_subject="TrueNAS Application Updates"

#Ensure the app name as displayed in the TrueNAS GUI is used
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
Application_name+=("nginx-proxy-manager")		#entry 19
Application_name+=("plex")						#entry 20
Application_name+=("sftpgo")					#entry 21
Application_name+=("tautulli")					#entry 22
Application_name+=("tftpd-hpa")					#entry 23
Application_name+=("web")						#entry 24
Application_name+=("urbackup")					#entry 25
Application_name+=("metadata-remote")			#entry 26
Application_name+=("pangolin")					#entry 27
Application_name+=("watchtower")				#entry 28

#####################################
#Script Start
#####################################

yy=0
for yy in "${!Application_name[@]}"; do

	#get current app state. it will return either "RUNNING" or "STOPPED" if the app is installed, or it will return "" if the app is not found
	current_install_status=$(midclt call app.query '[["name", "=", "'${Application_name[$yy]}'"]]' | jq -r '.[] | .state')
	
	if [[ "$current_install_status" == "" ]]; then #app is not installed
		apps_not_installed+=("${Application_name[$yy]}")
		echo "${Application_name[$yy]} not installed"
	else
		echo "${Application_name[$yy]} installed"
		
		#get status of app to see if the TrueNAS GUI is reporting an update is available
		current_app_update_status=$(midclt call app.query '[["name", "=", "'${Application_name[$yy]}'"]]' | jq -r '.[] | .upgrade_available')
		
		#get the truenas app catalog name for the installed app as the name of the app in the TrueNAS GUI may be different from the default catalog app name
		truenas_app_catalog_name=$(midclt call app.query '[["name", "=", "'${Application_name[$yy]}'"]]' | jq -r '.[] | .metadata.name')
		
		if [[ "$current_app_update_status" == "true" ]]; then #does app have an update available as shown in the truenas GUI?
			echo "${Application_name[$yy]} has update available"
			
			#determine if the app is a custom app or one through the Truenas App catalog
			current_app_custom_app=$(midclt call app.query '[["name", "=", "'${Application_name[$yy]}'"]]' | jq -r '.[] | .custom_app')
			
			if [[ "$current_app_custom_app" == "true" ]]; then #if the app is a custom app, then we cannot use the Truenas App catalog to verify the update version
				apps_custom+=("${Application_name[$yy]}")
				echo "${Application_name[$yy]} is a custom app"
			else
				#get version of the app installed
				current_app_version=$(midclt call app.query '[["name", "=", "'${Application_name[$yy]}'"]]' | jq -r '.[] | .metadata.app_version')
				
				#get latest version off truenas website app catalog 
				current_app_latest_version_available=$(curl -s "https://apps.truenas.com/catalog/$truenas_app_catalog_name/" | grep "app_version" | head -1)

				base="&#34;app_version&#34;:&#34;"
				secondString=""
				current_app_latest_version_available=${current_app_latest_version_available//\ /$secondString} #remove all spaces
				current_app_latest_version_available=$(echo ${current_app_latest_version_available#${base}}) #remove the uneeded information in base variable from string
				current_app_latest_version_available=$(echo "${current_app_latest_version_available::-6}") #remove last 6 chars from string
				
				#see if the version installed is the same as the latest version available on the truenas app catalog
				if [[ "$current_app_version" == "$current_app_latest_version_available" ]]; then
					echo "${Application_name[$yy]} does not have an updated docker version to update to, only the truenas app version is updated"
					apps_up_to_date+=("${Application_name[$yy]}")
				else
					apps_update_available+=("${Application_name[$yy]}")
					echo "${Application_name[$yy]} is currently version \"$current_app_version\" with version \"$current_app_latest_version_available\" available to update to"
					
					#get changelog link
					current_app_latest_version_link=$(curl -s "https://apps.truenas.com/catalog/$truenas_app_catalog_name/" | awk '/github.com/{i++}i==2' | grep "Changelog")
					current_app_latest_version_link=$(echo "${current_app_latest_version_link#*=}") #remove everything on the left
					current_app_latest_version_link=$(echo "${current_app_latest_version_link%% *}") #remove everything on the left
					echo "changelog link: \"$current_app_latest_version_link\""
					change_logs+=("$current_app_latest_version_link")
					app_version_available+=("$current_app_latest_version_available")
					app_version_installed+=("$current_app_version")
				fi
			fi
		else
			apps_up_to_date+=("${Application_name[$yy]}")
			echo "${Application_name[$yy]} is up to date"
		fi
	fi
done

echo -e "\n______________________________________________\n"
echo "Apps Not Installed"
email_body=$email_body"<b><u>Apps Not Installed:</u></b><br>"
yy=0
for yy in "${!apps_not_installed[@]}"; do
	echo "$(( $yy + 1 )): ${apps_not_installed[$yy]}"
	email_body=$email_body"<font color=\"red\">$(( $yy + 1 )): ${apps_not_installed[$yy]}</font><br>"
done

echo -e "\n______________________________________________\n"
email_body=$email_body"______________________________________________<br>"

echo "Up-to-date Apps"
email_body=$email_body"<b><u>Up-to-date Apps</u></b>:<br>"
yy=0
for yy in "${!apps_up_to_date[@]}"; do
	echo "$(( $yy + 1 )): ${apps_up_to_date[$yy]}"
	email_body=$email_body"<font color=\"green\">$(( $yy + 1 )): ${apps_up_to_date[$yy]}</font><br>"
done

echo -e "\n______________________________________________\n"
email_body=$email_body"______________________________________________<br>"

echo "Apps with Available Updates"
echo "Custom Apps:"
email_body=$email_body"<b><u>Apps with Available Updates<br>Custom Apps:</u></b><br>"
yy=0
counter=1
for yy in "${!apps_custom[@]}"; do
	echo "$counter: ${apps_custom[$yy]}"
	email_body=$email_body"<font color=\"orange\">$counter: ${apps_custom[$yy]}</font><br>"
	let counter=counter+1
done

echo "Truenas App Catalog Apps:"
email_body=$email_body"<b><u>Truenas App Catalog Apps:</u></b><br>"
yy=0
for yy in "${!apps_update_available[@]}"; do
	echo "$counter: ${apps_update_available[$yy]}  --> Changelogs: ${change_logs[$yy]}"
	email_body=$email_body"<font color=\"orange\">$counter: ${apps_update_available[$yy]}  --> <u>Version Installed</u>: ${app_version_installed[$yy]}. <u>Latest Version Available</u>: ${app_version_available[$yy]}. <a href=\"${change_logs[$yy]}\">Changelog</a></font><br>"
	let counter=counter+1
done

echo -e "\n______________________________________________\n"


#the command can only take one email address destination at a time. so if there are more than one email addresses in the list, we need to send them one at a time
	address_explode=(`echo "$email_address" | sed 's/;/\n/g'`)
	bb=0
	for bb in "${!address_explode[@]}"; do
		python3 /mnt/volume1/logging/multireport_sendemail.py --subject "$email_subject" --to_address "${address_explode[$bb]}" --mail_body_html "$email_body" --override_fromemail "$from_email_address"
	done