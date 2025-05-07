# Synology-to-TrueNAS
My Guide when I moved from Synology to TrueNAS

<div id="top"></div>
<!-- TABLE OF CONTENTS -->
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#About_the_project_Details">About The Project</a> 
   </li>
	<li><a href="#Current_Applications_Used_on_My_Various_Synology_Systems">Current Applications Used on My Various Synology Systems</a> </li>
	<li><a href="#Does_My_System_Have_Enough_RAM">Does My System Have Enough RAM?</a></li>
	<li><a href="#Change_TrueNAS_GUI_Port_settings">Change TrueNAS GUI Port settings</a></li>
	<li><a href="#Security_Measures_To_Lock_Down_Your_NAS">Security Measures To Lock Down Your NAS</a> </li>
	<li><a href="#Create_storage_pool_using_available_drives_as_desired">Create storage pool using available drives as desired. </a></li>
  	<li><a href="#Create_new_data_sets_as_required">Create new data sets as required </a></li>
	<li><a href="#Create_new_user">Create new user</a></li>
      	<li><a href="#Create_needed_SMB">Create needed SMB</a></li>
      	<li><a href="#Create_needed_NFS_shares">Create needed NFS shares</a></li>
      	<li><a href="#Create_snapshots">Create snapshots</a></li>
      	<li><a href="#Install_required_Apps">Install required Apps</a></li>
     	<li><a href="#Data_Logging_Exporting_to_Influx_DB_v2">Data Logging Exporting to Influx DB v2</a></li>
     	<li><a href="#Setup_Web_site_Details">Setup Web site Details</a></li>
      	<li><a href="#Cloud_backups_to_BackBlaze_B2_Bucket">Cloud backups to BackBlaze B2 Bucket</a></li>
     	<li><a href="#Replace_DS_File_app_Android_Only">Replace “DS File” app – Android Only</a></li>

<!-- ABOUT THE PROJECT -->
## 1.) About the project Details
<div id="About_the_project_Details"></div>

I currently have as of May 2025 a Synology DVA3219 with an attached DX517 expansion unit. This unit is running 4x WD Purple drives for Surrveilance Station and has 5x drives for PLEX media. I have another DS920 with 3x 1.92TB SSD for running PLEX itself. Finally I have a DS920+ with an attached DX517 expansion unit. This has 9x drives for PLEX media, backups, docker containers, my home web interfaces and automation and all of my docker container. 

It is obvious from the details above that I am a big Synology user however with the details of the new 2025 models and their restrictive HDD policies are causing me to look else where. Synology has indicated that it is possible to move existing drives from a pre-2025 unit to a 2025 unit and the drives will work. Based on community discussion that has been proven to be true. However if any of those drives fail, unless you use the creat script https://github.com/007revad/Synology_HDD_db, replacement drives must be Synology brand. 

With this news I have decided to move away from Synology and I am eyeing TrueNAS Community (SCALE). I am currently testing TrueNAS on an old Dell Micro PC i had available. I first tried to use a M.2 to 4x SATA adaptor to try adding more drives to the box as the processor and IGPU would actually be enough for me to comfortably move to if I could get drive expansion options to work. Unfortunately with the adaptor in the M.2 slot, the system refused to POST.

For my testing I am using a 256GB SSD from an old laptop and the 512GB NVME drive in the Dell's M.2 slot. 

In the long run in about 1-year's time I plan to build a custom system that can fit all of my drives. I am eyeing products from 45 Homelab, but that can fit 15x 3.5" HDD plus 6x 2.5" SSDs, but I have 18x 3.5" HDD so that will obviously not work unless I do something else. 

## 2.) Current Applications Used on My Various Synology Systems
<div id="Current_Applications_Used_on_My_Various_Synology_Systems"></div>

PLEASE NOTE: I have never used Synology Photos, and I have never used Synology Drive. As such I am not going to be researching replacements for those apps. If someone wishes for me to figure out how to use a possible replacemrnt I can try. However since I have no experiance with Photos or Drive, I have no way of comparing functionality to determine if it is a viable replacement. 

First and foremost if I wish to leave Synology I need to find replacements for all of the main Apps i am using. This guide willdetail what I chose to replace the Synology Apps. 

1.) My Main DS920 with attached DX517
  - Synology Calandar
  - Antivirus Essential
  - Synology Mail Plus Server
  - Web Station
  - Hyper Backup
  - Hyper Backup Vault
  - Central Management System
  - Maria DB
  - PHP Myadmin
  - LOg Center
  - Active Backup For Business
  - Container Manager
  - Snapshot Replication

2.) On my DVA3219
  - Antivirus Essential
  - Synology Mail Plus Server
  - Hyper Backup
  - Log Center
  - Container Manager
  - Snapshot Replication

3.) On my DS920 running plex
  - PLEX
  - Antivirus Essential
  - Synology Mail Plus Server
  - Hyper Backup
  - Log Center
  - Snapshot Replication

## 3.) Does My System Have Enough RAM?
<div id="Does_My_System_Have_Enough_RAM"></div>

A lot detail online will indicate that one should have approximately 1GB of RAM for every TB of disk space used for NFS to work best. I feel good information can be found here:

https://www.youtube.com/watch?v=xp6g-8VS06M

I plan to have 128GB of RAM in the system I will eventually build as it will have 14x 18TB drives + 4x 8TB drives and 6x 1.92TB SSD for a total RAW capacity of 295.52TB of space. As most of my space is comprised on large media files that basically never change, I do not anticipate any issues. 

## 4.) Change TrueNAS GUI Port settings
<div id="Change_TrueNAS_GUI_Port_settings"></div>

I am planning to use the TrueNAS system to host my internal web pages and so I need to free up the ports 80 and 443 used by the TrueNAS GUI. 

- `System --> General Settings --> GUI --> Settings`
- Change Web Interface HTTP Port from 80 to 5000
- Change Web Interface HTTPS Port from 443 to 5001

## 5.) Security Measures To Lock Down Your NAS
<div id="Security_Measures_To_Lock_Down_Your_NAS"></div>

This guide is very helpful: https://www.youtube.com/watch?v=u0btB6IkkEk

I performed the following actions:
1. `System --> Advanced Settings --> Console --> Configure` and turn off `Show Text Console without Password Prompt`
2. Adjust auto-time out as desired. The default is 300 seconds
  - `System --> Advanced Settings --> Access -> Configure`
  - I set mine to 1800 seconds (30 mins) which is probably longer than I should but I like extended log in times.
3. Setup two factor authentication 
  - Under your user(s) click on the user name in the upper right and select `Two-Factor Authentication` and generate a QR code to use in an app like Microsoft Authenticator.
  - `System --> Advanced Settings --> Global Two Factor Authentication – Configure`
  - Turn on 2FA and set time window to 1. If using passwords for SSH, check the option to also use 2FA for SSH. 
4. Bind SSH to only certain ethernet port
  - `System --> Services -> SSH` --> Click on the pencil edit icon on the right
  - Click advanced settings
  - Under `Bind Interfaces` choose the correct interface so only that interface will allow SSH
  - SSH is off by default but if it is enabled this increases security


## 6.)  Create storage pool using available drives as desired.  
<div id="Create_storage_pool_using_available_drives_as_desired"></div>

- https://www.youtube.com/watch?v=0d4_nvdZdOc
- How to expand if needed:
  - https://www.youtube.com/watch?v=11bWnvCwTOU
  - https://www.youtube.com/watch?v=uPCrDmjWV_I


## 7.)  Create new data sets as required 
<div id="Create_new_data_sets_as_required"></div>

1. Useful explanation: 
- https://www.youtube.com/watch?v=0d4_nvdZdOc
- https://www.youtube.com/watch?v=59NGNZ0kO04
  
2. For example I have 1 storage pool `volume1`
- On `/mnt/volume1` I have the following data sets
	- **Apps** *[Note, only make the data sets / folders as needed for your desired apps]*. *[Ensure the “Dataset Preset” is set to “Apps”]*
		- <ins>Frigate</ins> *[Ensure the “Dataset Preset” is set to “Apps”]*
			- Then created the following “regular folders”
   				- Cache
      			- Config
		- <ins>InfluxDB</ins> *[Ensure the “Dataset Preset” is set to “Apps”]*
			- Then created the following “regular folders”
   				- Config
       			- data
		- <ins>Jackett</ins> *[Ensure the “Dataset Preset” is set to “Apps”]*
			- Then created the following “regular folders”
   				- Blackhole
   				- config
		- <ins>Plex</ins> *[Ensure the “Dataset Preset” is set to “Apps”]*
			- Then created the following “regular folders”
   				- Config
       			- Data
				- logs
		- <ins>Radar</ins> *[Ensure the “Dataset Preset” is set to “Apps”]*
		- <ins>GraphiteExporter</ins> *[Ensure the “Dataset Preset” is set to “Apps”]*
		- <ins>Surveillance</ins> *[For Frigate to record to] [Ensure the “Dataset Preset” is set to “Apps”]*
			- Then created the following “regular folders”
				- Frigate
	- **Users** *[Ensure the “Dataset Preset” is set to “SMB” and choose to create share]*
		- Then created the following additional nested data set *[And more for other user as needed/desired]*
			- John_Doe_User
	- **Video** *[Ensure the “Dataset Preset” is set to “SMB” and choose to create share]*
		- Then created the following additional nested data sets
			- 4k_Movies
			- Home_Video
			- Movies
			- TV_Shows
	- **Backups** *[Ensure the “Dataset Preset” is set to “SMB” and choose to create share]*
	- **Web** *[Ensure the “Dataset Preset” is set to “Apps”]*
		- Then created the following “regular folders”
			- Config
			- logging
	- **Pictures** *[Ensure the “Dataset Preset” is set to “SMB” and choose to create share]*

## 8.)  Create new user
<div id="Create_new_user"></div>

- Create new user `Credentials --> Users`
- Full Name: Full name of user, for example `John Doe`
- Username: Actual user name, for example `John_Doe_User`
- Email: set user’s contact email
- Passwords: either set password or use other form of authorization
- UID: leave as default
- Auxiliary Groups: builtin_users
- Primary Group: builtin_administrators
- Home Directory: set to `/mnt/volume1/users/ John_Doe_User`
- Home Directory Permissions: ensure user can read/write/execute

## 9.)  Create needed SMB   
<div id="Create_needed_SMB"></div>

- Go to `Shares -> Windows (SMB) Shares --> View All`
- Ensure all of the main data sets are being shared. If not, click `add`. Choose the missing main data set(s) 
- Under the `Audit Logging` column, ensure all say `Yes` except for the “apps” share.
- If they do not say Yes, then click the pencil edit icon, click on `Advanced Options` and under Audit Logging, click the “enabled” check box, click Save
- Ensure all shares are enabled


## 10.)  Create needed NFS shares  
<div id="Create_needed_NFS_shares"></div>

## 11.)  Create snapshots
<div id="Create_snapshots"></div>

## 12.)  Install required Apps 
<div id="Install_required_Apps"></div>

## 13.)  Data Logging Exporting to Influx DB v2  
<div id="Data_Logging_Exporting_to_Influx_DB_v2"></div>

## 14.)  Setup Web site Details
<div id="Setup_Web_site_Details"></div>

## 15.)  Cloud backups to BackBlaze B2 Bucket
<div id="Cloud_backups_to_BackBlaze_B2_Bucket"></div>

## 16.)  Replace “DS File” app – Android Only
<div id="Replace_DS_File_app_Android_Only"></div>

