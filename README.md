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
<ul>
<li><a href="#Frigate">Frigate</a></li>
<li><a href="#Grafana">Grafana</a></li>
<li><a href="#influxDB">influxDB</a></li>
<li><a href="#jackett">jackett</a></li>
<li><a href="#plex">plex</a></li>
<li><a href="#radar">radar</a></li>
<li><a href="#sickchill">sickchill</a></li>
<li><a href="#nginx_reverse_proxy">nginx Reverse Proxy</a></li>
<li><a href="#jellyfin">jellyfin</a></li>
<li><a href="#tautulli">tautulli</a></li>
<li><a href="#PhP_My_Admin">PHP My Admin</a></li>
<li><a href="#Chromium">Chromium</a></li>
<li><a href="#Torrent_downloader_VPN">Torrent down-loader + VPN</a></li>
<li><a href="#ngninx_PHP_Maria_DB_Stack">ngninx + PHP + Maria DB Stack</a></li>
<li><a href="#DIUN">DIUN - Docker Image Update Notifier</a></li>
<li><a href="#TrueCommand">TrueCommand</a></li>
<li><a href="#Veeam">Veeam</a></li>
<li><a href="#Grey_log">Grey log</a></li>
</ul>
<li><a href="#Data_Logging_Exporting_to_Influx_DB_v2">Data Logging Exporting to Influx DB v2</a></li>
<li><a href="#Install_script_to_pull_TrueNAS_SNMP_data">Install script to pull TrueNAS SNMP data</a></li>
<li><a href="#Setup_Grafana_Dashboard_for_TrueNAS">Setup Grafana Dashboard for TrueNAS</a></li>   
<li><a href="#Setup_Web_site_Details">Setup Web site Details</a></li>
<li><a href="#Setup_Custom_Logging_Scripts_and_Configure_CRON">Setup Custom Logging Scripts and Configure CRON</a></li>
<li><a href="#Configure_Disk_Standby">Configure Disk Standby</a></li>    
<li><a href="#Cloud_backups_to_BackBlaze_B2_Bucket">Cloud backups to BackBlaze B2 Bucket</a></li>
<li><a href="#Replace_DS_File_app_Android_Only">Replace “DS File” app – Android Only</a></li>
<li><a href="#Configure_Data_Scrubs">Configure Data Scrubs</a></li>
<li><a href="#Schedule_SMART_tests">Schedule SMART tests</a></li>
<li><a href="#Configiure_email_sending_from_CLI">Configiure Email Sending From CLI</a></li>
<li><a href="#Configure_Remote_Access_using_Tail_Scale">Configure Remote Access using Tail Scale</a></li>
<li><a href="#Mount_External_NFS_Shares_into_TrueNAS_Dataset">Mount External NFS Shares into TrueNAS Dataset</a></li>
<li><a href="#General_Little_Settings_Here_and_There">General Little Settings Here and There</a></li>
  </ol>

<!-- ABOUT THE PROJECT -->
## 1.) About the project Details
<div id="About_the_project_Details"></div>

I currently have as of May 2025 a Synology DVA3219 with an attached DX517 expansion unit. This unit is running 4x WD Purple drives for Surrveilance Station and has 5x drives for PLEX media. I have another DS920 with 3x 1.92TB SSD for running PLEX itself. Finally I have a DS920+ with an attached DX517 expansion unit. This has 9x drives for PLEX media, backups, docker containers, my home web interfaces and automation and all of my docker container. 

It is obvious from the details above that I am a big Synology user however with the details of the new 2025 models and their restrictive HDD policies are causing me to look else where. Synology has indicated that it is possible to move existing drives from a pre-2025 unit to a 2025 unit and the drives will work. Based on community discussion that has been proven to be true. However if any of those drives fail, unless you use the creat script https://github.com/007revad/Synology_HDD_db, replacement drives must be Synology brand. 

With this news I have decided to move away from Synology and I am eyeing TrueNAS Community (SCALE). I am currently testing TrueNAS on an old Dell Micro PC I had available. I first tried to use a M.2 to 4x SATA adaptor to try adding more drives to the box as the processor and IGPU would actually be enough for me to comfortably move to if I could get drive expansion options to work. Unfortunately with the adaptor in the M.2 slot, the system refused to POST.

For my testing I am using a 256GB SSD from an old laptop and the 512GB NVME drive in the Dell's M.2 slot. 

In the long run in about 1-year's time I plan to build a custom system that can fit all of my drives. I am eyeing products from 45 Homelab, but that can fit 15x 3.5" HDD plus 6x 2.5" SSDs, but I have 18x 3.5" HDD so that will obviously not work unless I do something else. 

## 2.) Current Applications Used on My Various Synology Systems
<div id="Current_Applications_Used_on_My_Various_Synology_Systems"></div>

PLEASE NOTE: I have never used Synology Photos, and I have never used Synology Drive. As such I am not going to be researching replacements for those apps. If someone wishes for me to figure out how to use a possible replacemrnt I can try. However since I have no experiance with Photos or Drive, I have no way of comparing functionality to determine if it is a viable replacement. With this said, it is my understanding that https://immich.app/ appears to be a viable replacement for Synology Photos. 

Please also note I have never used Apple products so I am not in a postion to suggest services that are compatible with Apple. If someone with Apple products has done things to ove from Synology to TrueNAS and I am not detailing that, please submit an issue request and I can work with you to add those details to this guide. 

First and foremost if I wish to leave Synology I need to find replacements for all of the main Apps I am using. This guide willdetail what I chose to replace the Synology Apps. 

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

A lot detail online will indicate that one should have approximately 1GB of RAM for every TB of disk space used for NFS to work best. I feel good information can be found here: <a href="https://www.youtube.com/watch?v=xp6g-8VS06M">Lawrence Systems - How Much Memory Does ZFS Need and Does It Have To Be ECC?</a>

I plan to have 128GB of RAM in the system I will eventually build as it will have 14x 18TB drives + 4x 8TB drives and 6x 1.92TB SSD for a total RAW capacity of 295.52TB of space. As most of my space is comprised on large media files that basically never change, I do not anticipate any issues. 

The big thing to understand about TrueNAS and the ZFS file system that accompanies it, is that it will use un-used RAM space as a cache drive. This caching is doing the same thing a read only NVMA chache does on Synology. It will save commonly accessed files in the RAM cache so it does not need to read the data of the hard disks. ZFS calls this ARC or `Adaptive Replacement Cache`. This cache again is for reading data off the system, it does not help writting data to the drives. 

If your system is primarilly used for PLEX (I.E. large continuous file reads) then the ARC will not really help. ARC will help with things like loading PLEX and it's dashboard, art etc as those are small files and when browsing your PLEX libary frequrently are also read frequnetly and will be saved to ARC. 

You can use NVME drives in TrueNAS for caching in a direct similar method as Synology and that is referred to as L2ARC or 'Level 2 Adaptive Replacement Cache' and can assist with read performance if you perhaps do not have lots of RAM. 

Like Synology READ/WRITE cache TrueNAS can use write caching which uses `SLOG` space on separate NVME drives. 

The real question is what is the actual performance difference with using ARC, L2ARC, SLOG etc, and unfortunately that is not always easy to answer as it depends on your usage patterns. 

Many people moving from a Synology should be able to comfortably use TrueNAS with ZFS on systems with 32GB of RAM. The system will run fine, but may not possibly be atthe maximum performance it could otherwise acheive. 

More useful information can be found here <a href="https://www.45drives.com/community/articles/zfs-caching/">45 Drive ZFS Caching Discusion</a>

## 4.) Change TrueNAS GUI Port settings
<div id="Change_TrueNAS_GUI_Port_settings"></div>

This section is not required if you are not planning to host any web services on your TrueNAS lie one would do with Synology's "Web STation" package. I am planning to use the TrueNAS system to host my internal web pages and so I need to free up the ports 80 and 443 used by the TrueNAS GUI by default. Since I am moving from Synology I am already very used to using ports 5000 and 5001, so I decided to use those same ports with TrueNAS. 

- `System --> General Settings --> GUI --> Settings`
- Change Web Interface HTTP Port from 80 to 5000
- Change Web Interface HTTPS Port from 443 to 5001

## 5.) Security Measures To Lock Down Your NAS
<div id="Security_Measures_To_Lock_Down_Your_NAS"></div>

There have been plently of discussions and articles on how to secure a Synology NAS and a lot of them are applicable to TrueNAS like not using a root/admin account unless you need to, using Muilti-Factor-Authentication, not exposing the NAS directly to the internet, use proper passwords etc. 

This Youtube guide by Lawrence Syetems is very helpful and I have included some of the information below: <a href="https://www.youtube.com/watch?v=u0btB6IkkEk">Lawrence Systems - Hardening TrueNAS Scale: Security Measures To Lock Down Your NAS</a>

I performed the following actions on my system:

<ol>
<li><strong>System --> Advanced Settings --> Console --> Configure</strong> and turn off <strong>Show Text Console without Password Prompt</strong></li>
<ul>
<li>This as Tom indicates in his video locks down the HMI GUI available to prevent someone from changing configuration settings. <br>Obviously if you either do not use the video out of your NAS, or it is in a locked / secure area, this is not as required. I personally have my TrueNAS on a JetKVM, and so if someone were to somehow acess my KVM, they will at least then not be able to have access to my TrueNAS.</li>
</ul>
<br>
<li>Adjust auto-time out as desired. The default is 300 seconds</li>
<ul>
<li><strong>System --> Advanced Settings --> Access -> Configure</strong></li>
<li>I set mine to 1800 seconds (30 mins) which is probably longer than I should but I like extended log in times.</li>
</ul>
<br>
<li>Setup two factor authentication</li>
<ul>
<li>Under your user(s) click on the user name in the upper right and select <strong>Two-Factor Authentication</strong> and generate a QR code to use in an app like Microsoft Authenticator or your prerferred app. You will need to generate this QR code for all of the users who will need Web GUI access.</li>
<li><strong>System --> Advanced Settings --> Global Two Factor Authentication – Configure</strong></li>
<li>Turn on 2FA and set time window to 1. If using passwords for SSH, check the option to also use 2FA for SSH.</li>
</ul>
<br>
<li>Bind SSH to only certain ethernet port</li>
<ul>
<li><strong>System --> Services -> SSH --> Click on the pencil edit icon on the right</strong></li>
<li>Click advanced settings</li>
<li>Under <strong>Bind Interfaces</strong> choose the correct interface so only that interface will allow SSH</li>
<li>SSH is off by default but if it is enabled this increases security by ensuring only network users on those certain port(s) can access SSH.</li>
</ul>
</ol>

## 6.)  Create storage pool using available drives as desired.  
<div id="Create_storage_pool_using_available_drives_as_desired"></div>

This is something I am not going to go into significant detail on as the choices of what type of disk configurtion you choose is different from user to user

I will however touch on a few key details. 

1. If you are using Synology SHR or SHR2 where your disks are of various different sizes, that functionality as of 5/8/2025 is NOT available on ZFS. On ZFS all disks need to be the same size or larger, and if you do use larger drives with smaller drives, you will loose any of the extra space, ZFS cannot use it.
2. Synology does have the ability to go from one raid type to the next when using SHR/SHR2. For example you could start with two drives, which Synology will put into a mirror, then add another drive to the pool and have the option to change to raid 5 and so on. On ZFS once you make your VDEV, you are stuck with the type you make (mirror, Z1, Z2 ect) and the only way to change the type is to destroy the Vdev which will destory what ever pool is attached to it.
3. You can (as of late 2024) now expand ZFS by adding one drive at a time. So for example if you have a raid Z1 with 4 disks, you can add a 5th drive to that Vdev like we could with Synology, however the underlying methods on how ZFS expansion work are different from the Synology MDADM / Linux Volume Manager methods.

For more details on expanding ZFS, these two videos are very helful: <a href="https://www.youtube.com/watch?v=11bWnvCwTOU">Lawrence Systems - TrueNAS: How To Expand A ZFS Pool</a> and <a href="https://www.youtube.com/watch?v=uPCrDmjWV_I">Lawrence Systems - TrueNAS Tutorial: Expanding Your ZFS RAIDz VDEV with a Single Drive</a>

I also suggest this video on creating your disk storage: <a href="https://www.youtube.com/watch?v=ykhaXo6m-04">Hardware Haven - Choosing The BEST Drive Layout For Your NAS</a>

## 7.)  Create new data sets as required 
<div id="Create_new_data_sets_as_required"></div>

Two useful guides on how to use data sets and their permissions can be found here: <a href="https://www.youtube.com/watch?v=0d4_nvdZdOc">Lawrence Systems - ZFS 101: Leveraging Datasets and Zvols for Better Data Management</a> and  <a href="https://www.youtube.com/watch?v=59NGNZ0kO04">Lawrence Systems - TrueNAS Scale: A Step-by-Step Guide to Dataset, Shares, and App Permissions</a>

<ol>
<li>For example I have 1 storage pool <strong>volume1</strong></li>
<li>On <b></b>/mnt/volume1</b> I have the following data sets</li>
   <ul>
	   <li> <strong>Apps</strong> <small>[Note, only make the data sets / folders as needed for your desired apps]. [Ensure the “Dataset Preset” is set to “Apps”]</small></li>
	   <ul>
		<li><ins>Frigate</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		   <ul>
			<li>Then created the following “regular folders”</li>
			   <ul>
   				<li>Cache</li>
      				<li>Config</li>
			   </ul>
		   </ul>
	   	<li><ins>InfluxDB</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		   <ul>
			<li>Then created the following “regular folders”</li>
			   <ul>
   				<li>Config</li>
       				<li>data</li>
			   </ul>
		   </ul>
		<li><ins>Jackett</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		   <ul>
			<li>Then created the following “regular folders”</li>
			   <ul>
   				<li>Blackhole</li>
       				<li>config</li>
			   </ul>
		   </ul>
		<li><ins>Plex</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		   <ul>
			<li>Then created the following “regular folders”</li>
			   <ul>
   				<li>Config</li>
       				<li>Data</li>
				<li>logs</li>
			   </ul>
		   </ul>
		<li><ins>Radar</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>GraphiteExporter</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>chromium</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>flaresolverr</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>ytdlp</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		   <ul>
			<li>Then created the following “regular folders”</li>
			   <ul>
   				<li>config</li>
				<li>downloads</li>
				<li>ffmpeg</li>
			   </ul>
		   </ul>
		<li><ins>nginx_reverse_proxy</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
   		   <ul>
			   <li>Then created the following additional “regular folders”</li>
			   <ul>
			   <li>certs</li> 
			   <li>config</li> 
			   </ul>
		   </ul>
	   </ul>
	  <li><strong>Surveillance</strong> <small>[For Frigate to record to] [Ensure the “Dataset Preset” is set to “SMB” and choose to create share]</small></li>
	  <li> <strong>Users</strong> <small>[Ensure the “Dataset Preset” is set to “SMB” and choose to create share]</small></li>
   		   <ul>
			   <li>Then created the following additional nested data set [And more for other user as needed/desired]</li>
			   <ul>
			   <li>John_Doe_User</li> 
			   </ul>
		   </ul>
	   <li> <strong>Video</strong> <small>[Ensure the “Dataset Preset” is set to “SMB” and choose to create share]</small></li>
   		   <ul>
			   <li>Then created the following additional nested data sets</li>
			   <ul>
			   <li>4k_Movies</li> 
			   <li>Home_Video</li> 
			   <li>Movies</li> 
		           <li>TV_Shows</li> 
			   </ul>
		   </ul>
	   <li> <strong>Backups</strong> <small>[Ensure the “Dataset Preset” is set to “SMB” and choose to create share]</small></li>
   	   <li> <strong>Web</strong> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
   		   <ul>
			   <li>Then created the following additional nested data sets</li>
			   <ul>
			   <li>Config</li> 
			   <li>logging</li> 
			   </ul>
		   </ul>
	   <li> <strong>torrent</strong> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
   		   <ul>
			   <li>Then created the following additional “regular folders”</li>
			   <ul>
				   <li>bt</li>
				   	<ul>
					   <li>Then created the following additional “regular folders”</li>
				   		<ul>
						   <li>incomplete</li>
						   <li>torrents</li> 
      						</ul>
					</ul>
				   <li>gluetun_config</li>
				   <li>gluetun_tmp</li> 
				   <li>transmission_config</li> 
			   </ul>
		   </ul>
	   <li> <strong>Pictures</strong> <small>[Ensure the “Dataset Preset” is set to “SMB” and choose to create share]</small></li>
   </ul>
</ol>
<br>

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

NFS shares are not required unless you are sharing this TrueNAS system's data with other linux systems. I am doing so in the beginning to use the shares currently on my Synology units so I can expose PLEX to my movies and TV shows. If you do not need NFS shares, skip this section. 

Useful information:  <a href="https://www.youtube.com/watch?v=mdHmcwWTNWA">Lawrence Systems - Configuring TrueNAS NFS Share for XCP-ng</a> 

For each share created for NFS, it is suggested to define the IP address of the host(s) that will connect to limit who can connect for added security. For example, during this testing I plan to allow my current Synology systems to access my NFS shares and my three systems have IPs 192.168.1.178, 192.168.1.200, and finally 192.168.1.13. Since I plan to have no other systems access my TrueNAS NFS shares, limiting connections to only thsoe three host IPs increases my security a little. 

As a note, for my current Synology systems I have PLEX running on one DS920 with all of my media on the other DS920 pared with a DX517 and my DVA3219 paired with a DX517. I am using NFS shares to allow the PLEX Synology box to access the media files on the other two systems. I have not bothered to research why this was the case, BUT on the two systems sharing their files over NFS I had to configure the NFS permissions to "Squash all users to Admin", otherwise it refused to work. I have noticed a similar issue with TrueNAS where I needed to use the `Mapall User` and `Mapall Group` advanced options and set those both to `root`. 

1. Ensure NFS is turned on
- Go to `System --> Services` and ensure NFS is set to running and to start automatically
2. create needed shares
- Go to `Shares --> UNIX (NFS) Shares --> Add'
- Path: Choose the correct path to the folder to share
- Description: add a description for the share
- if desired, the NFS shares can be limited to specific networks and specific host IP addresses for added security. configure as desired, I am adding my three Synology NAS systems to this list.
- click on `Advanced Options` and scroll down to set `Mapall User` and `Mapall Group` to `root` and set `security` to `SYS`
- if desired there is an option under the `Advanced Options` to set the NFS share as Read Only. Set as your setup requires. 
- click save
3. repeat step above as needed for addtional shares as desired.

Note: I had difficulty in sharing a data set with child data sets over NFS, specifcally the `/mnt/volume1/video` data set. For some reason i could see and access the data on that `/mnt/volume1/video` main data set i was directly sharing over NFS, but i was NOT able to acces the files in the child data sets `4k_movies`, `TV_shows` etc... even after playing around with permissions. If there were "regular" folders created within the main data set `/mnt/volume1/video` i was directly sharing with NFS, i was able to see THOSE folders and files fine. I am sure there is a fix for this, but for my limited testing and now getting it to work well enough for my needs. As such i just made individual NFS shares for the data sets i made under `/mnt/volume1/video` and everything seemed to work fine. 

## 11.)  Create snapshots
<div id="Create_snapshots"></div>

Snapshots work the same with TrueNAS as they do with Synology as they can be restored if needed to recover data. 

To schedule snapshots:
1. go to `Data Protection -> Periodic Snapshot Tasks -> Add`
2. choose the desired data set. I would recommend to make scheduled snapshots for each separate data set to allow for flexibility in possible future data recovery. To assist with this, an option check box `recursive` is available when schedulign snapshots. This will create separate snapshots for all of the child data sets. As such i made one scheudled snap shot task for my `/mnt/volume1` data set and chose the recursive option to also make separate snap shots of everything under it to. 
- also be aware that on our SMB shares, by defualt the option `Enable Shaow Copies` is enabled. This allows windows users to use the `Previous Versions` feature to recover older copies of individual files and folders. This allows for granualr per-file recovery in an easy to use manner. As i will be accessing my TrueNAS files near constantly over SMB (I am a windows user YAY!) this is a very handy feature if i need to recover a file as i do not need to directly interact with the TrueNAS GUI etc. 
3. Choose the amount of time the snap shot is retained
- this is accomplished using the `Snapshot Lifetime` and `Unit` options. I am choosing 1 week of retention. 
4. I am leaving the naming process `Naming Schema` as the default of `auto-%Y-%m-%d_%H-%M`
5. Choose how often the snap shots are taken, the main options are Hourly, Daily, Weekly, Monthly. However custom options are also available. I am going with Daily.
6. I am leaving the `Allow Taking Empty Snapshot` option enabled
7. I am not excluding anything from my snapshots so I am leaving `Exclude` enpty

## 12.)  Install required Apps 
<div id="Install_required_Apps"></div>

On my Synology systems I purposfully made separate users for every docker container so i could restrict each container to only the data it needs. On my Synology systems i had a "docker" folder where i had sub folders for each container. If i were to use one user for every container, it would allow the different containers to read eachother's data. This is especially importaint when ruinning things like PLEX or JellyFin in docker where those two apps will also need access to your media libraies. You probably do not want all of your containers to have access to thise. Making separate users per container helps solve this problem as each user can be restricted individually on what they can and cannot acccess. 

1. Create required users/groups
- On a **per-app basis**, create a user and user group
  - Create new user `Credentials --> Users`
    - **Full Name**: Full name of user based on app name, for example “Plex”
    - **Username**: “Plex”
    - **Email**: leave blank
    - **Passwords**: check the box `disable password`
    - **UID**: leave as is, however record the UID being assigned to this user, as this will be needed later
    - **Auxiliary Groups**: leave blank
    - **Primary Group**: check box `Create New Primary Group`
    - **Home Directory**: leave blank
    - **Create Home Directory**: leave unchecked
    - **SSH password login enabled**: leave unchecked
    - **Allow all sudo commands**: leave unchecked
    - **Allow all sudo commands with no password**: leave unchecked
    - **SMB User**: uncheck the box
    - Record the **GID** of the newly created group `Credentials --> Groups`
    - Find the group with the name of the user just created and in the `GID` column, record the number assigned.
The PID and GID created for this user, in this example “Plex” will be used to assign that app rights to ONLY the data sets required and desired for the app. Otherwise by default the app will be placed inside the system default “apps” user and we will otherwise not be able to have as much fine grain detail and control over what this particular app can and cannot access.
2. Go to the `Datasets` page
- Select the data set the app will have access to for example `apps`
- On the right side scroll down to `Permissions` and click `edit`
- Click `add item`
- In the `Access Control Entry` area, under `who` select `group` and under `group` select the user needed in this example “Plex”
- Under the `Permissions` area, `Permission Type` should be set to `Basic` and the `Permissions` should be set to `Traverse` so this app can enter the `apps` data set to get access to the `PLEX` data set within it. 
- Click button `Apply permissions recursively`, agree to the confirmation popup. Note: the `Traverse` option is needed for nested data sets only. This allows the PLEX app to "move through" the `apps` data set, but cannot actually access any data within it. We need to configure the child data set(s) we want PLEX to be able to access individually. 
  - IF the desire is to have this app (Plex) be able to traverse ALL data sets inside the current data set, click the `Apply permissions to child data sets`. In this example we will NOT be doing that as we want PLEX to only have access to its data set we created under the apps data set.
- Click `Save Access Control List`
- We now need to give the app (PLEX) access to the data set `PLEX` under “apps” in this case the `/volume1/apps/plex`. Click on the plex data set and repeat steps above for that data set. However for the permissions set it to `Full Control` so the App (PLEX) can control it’s assigned app directory `/volume1/apps/plex`. <ins>For other data sets outside of the apps area</ins>, the default can be used, or limited to just read as desired.
- Repeat these steps for ANY and ALL other data sets you wish this particular app to access. In our example, we would also want to make sure plex had access to the `video` data set we created, and in this instance, we WOULD want to check the box `Apply permissions to child data sets` and the box `Apply permissions recursively`, to ensure plex can access all of the needed media files in the /volume1/video directory.

<div id="Frigate"></div>

3. **Frigate**
- Refer here for detailed information on <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main/frigate">Frigate Configuration on TrueNAS</a>

I have been using Synology Surrveilance Station (Referred here on out as SSS) since 2019. Prior to that i had been using a SWANN 8x camera system with 4k cameras. I kept the cameras but simply replaced the NVR with the DVA3219 and i have been very happy since.

If I was going to move away from Synology, then would need to find a good replacement for SSS. I looked into various options like Blue Iris but that only runs on windows. I also looked into Zoneminder and Frigate and really liked what i was seeing with Frigate.

With my DVA3219 and the NVidia graphics card inside it I have currently been utilizing its 4x max concurrent "dep video analsysis" features to perform person, vehicle and object detetion, which has been working well. What has really made me appreciate Frigate is that i can do the same object detection and MORE on ALL of my 12x cameras while also using LESS wattage on my electricity bill.

To acheive this I am using a single Google Coral Tensor Processor Unit (TPU) and iGPU passthrough from my Core i7-8700T CPU in my test Dell Micro PC to the container to perform all of the analsys on 12x cameras at the same time. The TPU uses less than 5 watts, and the iGPU is only being loaded to 4-ish percent and the CPU was loaded to around 20%. This is compared to the DVA3219 which loads by CPU to arond 50%, loads the GPU to around 90%.

I used a kilo-watt meter to get a good understanding of the power draw on the Dell micro PC when Frigate was ON and when it was OFF and the power usage difference was around 18 watts. I did the same comparison on the DVA3219 and the power diffrential when SSS is ON vs OFF was about 75 watts. That is a huge difference in 24/7 on-going power draw and yet Frigate is doing even more analsysis!!.

something of note: Frigate does NOT use any of the detections built into cameras, it only performs all processing and detections/triggers internally using your CPU, GPU, TPU etc. This means if you have really fancy AI cameras that can natively perform people, object, motion detection etc, those features cannot be leaveraged by Frigate. Persoanlly after using Frigate, i think Frigate does a better job anyways but your milage may vary.

another thing to note: when looking at the Frigate web GUI live stream page showing multiple cameras, the video wil NOT be 100% live. The video will only "activate" when there is actively detected motion, alerts, or detections. Then the video will show the live stream and as soon as the event(s) are over the video will "pause". This was initially confusing for me as SSS will show the live stream at all times when looking at all the cameras to gether.

<div id="Grafana"></div>

4. ***Grafana***

<div id="influxDB"></div>

5. ***influxDB***

<div id="jackett"></div>

6. ***jackett***

<div id="plex"></div>

7. ***plex***

<div id="radar"></div>

8. ***radarr***

<div id="sickchill"></div>

9. ***sickchill***

<div id="nginx_reverse_proxy"></div>

10. ***nginx reverse proxy***
- https://www.youtube.com/watch?v=jx6T6lqX-QM

<div id="jellyfin"></div>

11. ***jellyfin***

<div id="tautulli"></div>

12. ***tautulli***

<div id="PhP_My_Admin"></div>

13. ***PhP My Admin***

<div id="Chromium"></div>

14. ***Chromium***

<div id="Portainer"></div>

15. ***Portainer***

<div id="Torrent_downloader_VPN"></div>

16. ***Torrent downloader + VPN***
- very useful step by step guide on using GlueTUN for docker app VPN tunnels: https://www.youtube.com/watch?v=TJ28PETdlGE

<div id="ngninx_PHP_Maria_DB_Stack"></div>

17. ***ngninx + PHP + Maria DB Stack*** (replaces web station)

https://medium.com/@tech_18484/deploying-a-php-web-app-with-docker-compose-nginx-and-mariadb-d61a84239c0d
https://linuxiac.com/how-to-set-up-lemp-stack-with-docker-compose/

<div id="DIUN"></div>

18. ***DIUN – Docker Image Update Notifier***

<div id="TrueCommand"></div>

19. ***TrueCommand***

<div id="Veeam"></div>

20. ***Veeam*** *[Replaces Active Backup for Business]*

<div id="Grey_log"></div>

21. ***Grey log***
- https://www.youtube.com/watch?v=PoP9BTktlFc
- https://www.youtube.com/watch?v=DwYwrADwCmg

<div id="flaresolverr"></div>

22. ***flaresolverr***

<div id="ytdlp"></div>

23. ***ytdlp***


## 13.)  Data Logging Exporting to Influx DB v2  
<div id="Data_Logging_Exporting_to_Influx_DB_v2"></div>

TrueNAS has built in metrics that show CPU usage, network usage and more. This is great, but oen might want to export this data to be able to better display it in Grafana for exmaple. Unfortunately TrueNAS only exports data over Graphite and I like to use InfluxDB v2 which removed the ability to natively ingest graphite formatted data. Because of this i needed an intermediary step to convert the graphite data into somethign InfluxDB could ingest. To do this i used a `truenas-graphite-to-prometheus` exporter. InfluxDB can ingest prometheus data. 

1. Setup TrueNAS exporter under `Reporting --> Exporters` so we can get the data out of TrueNAS. 
- **Name**: netdata
- **Type**: Graphite
- **Destination IP**: 192.168.1.8 (TrueNAS System IP)
- **Destination Port**: 9109 [This will be the port used in the custom app we are about to install in the next section]
- **Prefix**: truenas
- **Update Every**: 10
- **Buffer On Failures**: 10
- **Matching Charts**: *
- Click Save
2. Create Custom App per *https://github.com/Supporterino/truenas-graphite-to-prometheus/blob/main/TRUENAS.md*
- Install App through `Apps --> Discover Apps --> Custom App`
  - **Application Name**: netdata
  - **Image -> Repository**: ghcr.io/supporterino/truenas-graphite-to-prometheus
  - **Tag**: latest
  - **Pull Policy**: Pull the image if it is not already present on the host.
  - **Hostname**: <leave blank>
  - **Entrypoint**: No items have been added yet
  - **Command**: No items have been added yet
  - **Timezone**: 'America/Chicago' timezone [Set as required to your time zone]
  - **Environment Variables**: No items have been added yet.
  - **Restart Policy**: Unless Stopped - Restarts the container irrespective of the exit code but stops restarting when the service is stopped or removed.
  - **Disable Builtin Healthcheck**: unchecked
  - **TTY**: unchecked
  - **Stdin**: unchecked
  - **Devices**: No items have been added yet.
  - **Security Context Configuration Privileged**: unchecked
  - **Capabilities add**: No items have been added yet.
  - **Custom User**: checked
  - **User ID**: 568 [This is one app i have not made a separate user for since it does so little]
  - **Group ID**: 568
  - **Network Configuration Host Network**: unchecked
  - **Ports**:
    - Add #1:
      - Container Port: 9109 [Used to ingest data from TrueNAS]
      - Host Port: 9109
      - Protocol: TCP
    - Add #2:
      - Container Port: 9108 [The web GUI where we wil be using InfluxDB to scrape the data from]
      - Host Port: 9108
      - Protocol: TCP
  - **Custom DNS Setup**: No items have been added yet.
  - **Search Domains**: No items have been added yet.
  - **DNS Options**: No items have been added yet.
  - **Portal Configuration**: No items have been added yet.
  - **Storage Configuration**:
    - Mount Path: `/config`
    - Host Path: choose to store on an “app” data set that you already created, in my example `/volume1/apps/netdata`
  - **Labels Configuration**: No items have been added yet.
  - **Resources Configuration**:
    - Enable it, choose 2 CPUs and 512 MB of memory. Leave `Passthrough available (non-NVIDIA) GPUs` unchecked
    - you can now create the app. 
3. InfluxDB Scrapper Configuration
- Open a new browser window and browse to `http://<server-IP>:9108`
- On the page titled `Graphite Exporter` click on the “metrics” link
- There should be a ton of text displayed showing the last set of data received from TrueNAS. I have configrued TrueNAS to export data every 10 seconds so data should already be available. However if you chose a slower rate like every few minutes, you will need to wait until TrueNAS sends data to it's exporter before you will see data on the metrics page. 
- Copy the URL, in my case that is `http://192.168.1.8:9108/metrics`
- Launch influxDB web portal in the apps page
- On the left click the Up arrow and select “buckets”
- Select `create bucket` Give the bucket a desired name, in my example “TrueNAS” and select the length of time to keep the data as desired, I chose “older than” and chose “90 days”
- Click “create”
- On the left click the Up arrow and the option “Scrapers”
- Click “create scraper”
- Give the scraper a name, in my example “TrueNAS”, select the bucket we just created
- In the “Target URL” enter the URL for the Graphite Exporter, in this example `http://192.168.1.8:9108/metrics`
- Click “create”
- Data will now be saved into InfluxDB

## 14.)  Install script to pull TrueNAS SNMP data
<div id="Install_script_to_pull_TrueNAS_SNMP_data"></div>

We now have a lot of the available data metrics from TrueNAS being saved to InfluxDB, but this is not ALL of the data available to use. The rest needs to be accessed over SNMP. You are going to want to enable SNMP and use an snmp walking client to gather the data. I have instead created a custom bash shell script that i have execute every 60 seconds to save the SNMP data to influxDB for me. 

You will need the SNMP OIDs or you can use the TrueNAS MIB file: https://www.truenas.com/docs/scale/scaletutorials/systemsettings/services/snmpservicescale/

I used paessler MIB importer to imoport the MIB and view the OIDs of the different SNMP metrics. The following metrics are vaialble over SNMP and will be gatehred by my script. 

- Zpool name
- Zpool health
- Zpool read/write ops
- Zpool read/write bytes
- Zpool read/write ops 1sec
- Zvol description
- Zvol used bytes
- Zvol available bytes
- Zvol referenced bytes
- Zfs arc size
- Zfs arc meta
- Zfs arc data
- Zfs arc hits
- Zfs arc misses
- Zfs arc arcc
- Zfs arc miss percent
- Zfs arc cache hit ratio
- Zfs arc cache miss ratio
- and more.....
## 15.)  Setup Grafana Dashboard for TrueNAS
<div id="Setup_Grafana_Dashboard_for_TrueNAS"></div>

## 16.)  Setup Web site Details
<div id="Setup_Web_site_Details"></div>

Synology has a easy to use package `Web Station` to rather easilly create and configure either nginx or appache based PHP powered web services. Unfortunately TrueNAS does not have this package but we have already installed our <a href="#ngninx_PHP_Maria_DB_Stack">ngninx + PHP + Maria DB Stack</a> to give us the ability to host a web site. This section will go over what i had to do to copy over all of my set site files already hosted on my Synology unit onto TrueNAS. 

## 17.)  Setup Custom Logging Scripts and Configure CRON
<div id="Setup_Custom_Logging_Scripts_and_Configure_CRON"></div>

## 18.)  Configure Disk Standby
<div id="Configure_Disk_Standby"></div>

## 18.)  Cloud backups to BackBlaze B2 Bucket
<div id="Cloud_backups_to_BackBlaze_B2_Bucket"></div>

## 19.)  Replace “DS File” app – Android Only
<div id="Replace_DS_File_app_Android_Only"></div>

## 20.)  Configure Data Scrubs
<div id="Configure_Data_Scrubs"></div>

## 21.)  Schedule SMART tests
<div id="Schedule_SMART_tests"></div>

There will be two ways of scheduling SMART tests. The first is TrueNAS native SMART scheduling. The second uses my custom SMART scheduler here: https://github.com/wallacebrf/Synology-SMART-test-scheduler. I will describe how to setup both. 

## 22.)  Configiure Email Sending From CLI
<div id="Configiure_email_sending_from_CLI"></div>

## 23.)  Configure Remote Access using Tail Scale
<div id="Configure_Remote_Access_using_Tail_Scale"></div>

https://www.youtube.com/watch?v=o0Py62k63_c

## 24.)  Mount External NFS Shares into TrueNAS Dataset
<div id="Mount_External_NFS_Shares_into_TrueNAS_Dataset"></div>

## 25.)  General Little Settings Here and There
<div id="General_Little_Settings_Here_and_There"></div>
