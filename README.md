# Synology-to-TrueNAS
My Guide when I moved from Synology to TrueNAS

To-Do List:
- <ins>DIUN</ins> (Docker Image Update Notifier)
  - **have not tried package yet**
- <ins>Grey Log</ins>
  - **have not tried package yet**
- <ins>jellyfin</ins>
  - **have not tried package yet**
- <ins>radar</ins>
  - have package working, need to update github
- <ins>Tautulli</ins>
  - **have not tried package yet**
- <ins>TrueCommand</ins>
  - **have not tried package yet**
- <ins>Setup Grafana Dashboard for TrueNAS</ins>
  - have working, need to update github
- <ins>Configure Disk Standby</ins>
- <ins>Cloud backups to BackBlaze B2 Bucket</ins>
- <ins>Replace “DS File” app – Android Only</ins>
  - have working, need to update github
- <ins>flaresolverr</ins>
- <ins>address issue #1</ins> "DSM in docker to mitigate DS apps"
- <ins>address issue #2</ins> "Recycle bin in Truenas"
- <ins>Configure Remote Access using Tail Scale</ins>
  - **have not tried package yet**
- <ins>portainer</ins>
  - have package working, need to update github
- <ins>complete PHP config page for TrueNAS SNMP</ins>
- <ins>Syncthing</ins>
- test new frigate phone app - https://github.com/sfortis/frigate-viewer/tree/main
- try self hosted media comverter - https://www.xda-developers.com/free-self-hosted-tool-converts-basically-any-file-all-your-browser/



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
<li><a href="#Chromium">Chromium</a></li>
<li><a href="#Torrent_downloader_VPN">Torrent down-loader + VPN</a></li>
<li><a href="#ngninx_PHP_Maria_DB_Stack">ngninx + PHP + MySQL Stack + PHPMyAdmin</a></li>
<li><a href="#DIUN">DIUN - Docker Image Update Notifier</a></li>
<li><a href="#TrueCommand">TrueCommand</a></li>
<li><a href="#Veeam">Veeam</a></li>
<li><a href="#Grey_log">Grey log</a></li>
<li><a href="#flaresolverr">flaresolverr</a></li>
<li><a href="#ytdlp">YT-DLP</a></li>
</ul>
<li><a href="#Data_Logging_Exporting_to_Influx_DB_v2">Data Logging Exporting to Influx DB v2</a></li>
<li><a href="#Install_script_to_pull_TrueNAS_SNMP_data">Install script to pull TrueNAS SNMP data + Non-SNMP Data like GPU Details</a></li>
<li><a href="#Setup_Grafana_Dashboard_for_TrueNAS">Setup Grafana Dashboard for TrueNAS</a></li>   
<li><a href="#Setup_Custom_Logging_Scripts_and_Configure_CRON">Setup Custom Logging Scripts and Configure CRON</a></li>
<li><a href="#Configure_Disk_Standby">Configure Disk Standby</a></li>    
<li><a href="#Cloud_backups_to_BackBlaze_B2_Bucket">Cloud backups to BackBlaze B2 Bucket</a></li>
<li><a href="#Replace_DS_File_app_Android_Only">Replace “DS File” app – Android Only</a></li>
<li><a href="#Configure_Data_Scrubs">Configure Data Scrubs</a></li>
<li><a href="#Schedule_SMART_tests">Schedule SMART tests</a></li>
<li><a href="#Configiure_email_sending_from_CLI">Configure Email Sending From CLI</a></li>
<li><a href="#Configure_Remote_Access_using_Tail_Scale">Configure Remote Access using Tail Scale</a></li>
<li><a href="#Mount_External_NFS_Shares_into_TrueNAS_Dataset">Mount External NFS Shares into TrueNAS Dataset</a></li>
<li><a href="#General_Little_Settings_Here_and_There">General Little Settings Here and There</a></li>
<li><a href="#Rsync_Files_From_Synology_to_TrueNAS">Rsync Files From Synology to TrueNAS</a></li>
<li><a href="#On_Systems_with_IPMI_supported_motherboards">On Systems with IPMI supported motherboards</a></li>
<li><a href="#File_Managers">File Managers</a></li>
  </ol>

<!-- ABOUT THE PROJECT -->
## 1.) About the project Details
<div id="About_the_project_Details"></div>

I currently have as of May 2025 a Synology DVA3219 with an attached DX517 expansion unit. This unit is running 4x WD Purple drives for Surveillance Station and has 5x drives for PLEX media. I have another DS920 with 3x 1.92TB SSD for running PLEX itself. Finally I have a DS920+ with an attached DX517 expansion unit. This has 9x drives for PLEX media, backups, docker containers, my home web interfaces and automation and all of my docker container. 

It is obvious from the details above that I am a big Synology user however with the details of the new 2025 models and their restrictive HDD policies are causing me to look else where. Synology has indicated that it is possible to move existing drives from a pre-2025 unit to a 2025 unit and the drives will work. Based on community discussion that has been proven to be true. However if any of those drives fail, unless you use the great script https://github.com/007revad/Synology_HDD_db, replacement drives must be Synology brand. 

With this news I have decided to move away from Synology and I am eyeing TrueNAS Community (SCALE). I am currently testing TrueNAS on an old Dell Micro PC I had available. I first tried to use a M.2 to 4x SATA adapter to try adding more drives to the box as the processor and IGPU would actually be enough for me to comfortably move to if I could get drive expansion options to work. Unfortunately with the adapter in the M.2 slot, the system refused to POST.

For my testing I am using a 256GB SSD from an old laptop and the 512GB NVME drive in the Dell's M.2 slot. 

In the long run in about 1-year's time I plan to build a custom system that can fit all of my drives. I am eying products from 45 Home lab, but that can fit 15x 3.5" HDD plus 6x 2.5" SSDs, but I have 18x 3.5" HDD so that will obviously not work unless I do something else. 

## 2.) Current Applications Used on My Various Synology Systems
<div id="Current_Applications_Used_on_My_Various_Synology_Systems"></div>

PLEASE NOTE: I have never used Synology Photos, and I have never used Synology Drive. As such I am not going to be researching replacements for those apps. If someone wishes for me to figure out how to use a possible replacement I can try. However since I have no experience with Photos or Drive, I have no way of comparing functionality to determine if it is a viable replacement. With this said, it is my understanding that https://immich.app/ appears to be a viable replacement for Synology Photos. 

Please also note I have never used Apple products so I am not in a postion to suggest services that are compatible with Apple. If someone with Apple products has done things to ove from Synology to TrueNAS and I am not detailing that, please submit an issue request and I can work with you to add those details to this guide. 

First and foremost if I wish to leave Synology I need to find replacements for all of the main Apps I am using. This guide will detail what I chose to replace the Synology Apps. 

1.) My Main DS920 with attached DX517
  - Synology Calendar
  - Antivirus Essential
  - Synology Mail Plus Server  <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main?tab=readme-ov-file#Configiure_email_sending_from_CLI">Replaced by scripts to send emails through CLI</a> 
  - Web Station <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main?tab=readme-ov-file#ngninx_PHP_Maria_DB_Stack">Replaced by ngninx + PHP + MySQL Stack + PHPMyAdmin also known as LEMP stack</a> 
  - Hyper Backup <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main?tab=readme-ov-file#Cloud_backups_to_BackBlaze_B2_Bucket">Replaced by Cloud backups to BackBlaze B2 Bucket</a> 
  - Hyper Backup Vault
  - Central Management System
  - Maria DB <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main?tab=readme-ov-file#ngninx_PHP_Maria_DB_Stack">Replaced by ngninx + PHP + MySQL Stack + PHPMyAdmin also known as LEMP stack</a> 
  - PHP My Admin <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main?tab=readme-ov-file#ngninx_PHP_Maria_DB_Stack">Replaced by ngninx + PHP + MySQL Stack + PHPMyAdmin also known as LEMP stack</a> 
  - LOg Center <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main?tab=readme-ov-file#Grey_log">Replaced by Grey log</a> 
  - Active Backup For Business <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main?tab=readme-ov-file#Veeam">Replaced by Veeam</a> 
  - Container Manager - replaced by TrueNAS native apps page
  - Snapshot Replication - <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main?tab=readme-ov-file#Create_snapshots">replaced by TrueNAS native ZFS snapshots</a>

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

A lot detail on line will indicate that one should have approximately 1GB of RAM for every TB of disk space used for NFS to work best. I feel good information can be found here: <a href="https://www.youtube.com/watch?v=xp6g-8VS06M">Lawrence Systems - How Much Memory Does ZFS Need and Does It Have To Be ECC?</a>

I plan to have 128GB of RAM in the system I will eventually build as it will have 14x 18TB drives + 4x 8TB drives and 6x 1.92TB SSD for a total RAW capacity of 295.52TB of space. As most of my space is comprised on large media files that basically never change, I do not anticipate any issues. 

The big thing to understand about TrueNAS and the ZFS file system that accompanies it, is that it will use un-used RAM space as a cache drive. This caching is doing the same thing a read only NVMA cache does on Synology. It will save commonly accessed files in the RAM cache so it does not need to read the data of the hard disks. ZFS calls this ARC or `Adaptive Replacement Cache`. This cache again is for reading data off the system, it does not help writing data to the drives. 

If your system is primarily used for PLEX (I.E. large continuous file reads) then the ARC will not really help. ARC will help with things like loading PLEX and it's dashboard, art etc as those are small files and when browsing your PLEX library frequently are also read frequently and will be saved to ARC. 

You can use NVME drives in TrueNAS for caching in a direct similar method as Synology and that is referred to as L2ARC or 'Level 2 Adaptive Replacement Cache' and can assist with read performance if you perhaps do not have lots of RAM. 

Like Synology READ/WRITE cache TrueNAS can use write caching which uses `SLOG` space on separate NVME drives. 

The real question is what is the actual performance difference with using ARC, L2ARC, SLOG etc, and unfortunately that is not always easy to answer as it depends on your usage patterns. 

Many people moving from a Synology should be able to comfortably use TrueNAS with ZFS on systems with 32GB of RAM. The system will run fine, but may not possibly be at the maximum performance it could otherwise achieve. 

More useful information can be found here <a href="https://www.45drives.com/community/articles/zfs-caching/">45 Drive ZFS Caching Discussion</a>

## 4.) Change TrueNAS GUI Port settings
<div id="Change_TrueNAS_GUI_Port_settings"></div>

This section is not required if you are not planning to host any web services on your TrueNAS lie one would do with Synology's "Web STation" package. I am planning to use the TrueNAS system to host my internal web pages and so I need to free up the ports 80 and 443 used by the TrueNAS GUI by default. Since I am moving from Synology I am already very used to using ports 5000 and 5001, so I decided to use those same ports with TrueNAS. 

- `System --> General Settings --> GUI --> Settings`
- Change Web Interface HTTP Port from 80 to 5000
- Change Web Interface HTTPS Port from 443 to 5001

## 5.) Security Measures To Lock Down Your NAS
<div id="Security_Measures_To_Lock_Down_Your_NAS"></div>

There have been plenty of discussions and articles on how to secure a Synology NAS and a lot of them are applicable to TrueNAS like not using a root/admin account unless you need to, using Multi-Factor-Authentication, not exposing the NAS directly to the Internet, use proper passwords etc. 

This Youtube guide by Lawrence Systems is very helpful and I have included some of the information below: <a href="https://www.youtube.com/watch?v=u0btB6IkkEk">Lawrence Systems - Hardening TrueNAS Scale: Security Measures To Lock Down Your NAS</a>

I performed the following actions on my system:

<ol>
<li><strong>System --> Advanced Settings --> Console --> Configure</strong> and turn off <strong>Show Text Console without Password Prompt</strong></li>
<ul>
<li>This as Tom indicates in his video locks down the HMI GUI available to prevent someone from changing configuration settings. <br>Obviously if you either do not use the video out of your NAS, or it is in a locked / secure area, this is not as required. I personally have my TrueNAS on a JetKVM, and so if someone were to somehow access my KVM, they will at least then not be able to have access to my TrueNAS.</li>
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
<li>Bind SSH to only certain Ethernet port</li>
<ul>
<li><strong>System --> Services -> SSH --> Click on the pencil edit icon on the right</strong></li>
<li>Click advanced settings</li>
<li>Under <strong>Bind Interfaces</strong> choose the correct interface so only that interface will allow SSH</li>
<li>SSH is off by default but if it is enabled this increases security by ensuring only network users on those certain port(s) can access SSH.</li>
</ul>
</ol>

## 6.)  Create storage pool using available drives as desired.  
<div id="Create_storage_pool_using_available_drives_as_desired"></div>

This is something I am not going to go into significant detail on as the choices of what type of disk configuration you choose is different from user to user

I will however touch on a few key details. 

1. If you are using Synology SHR or SHR2 where your disks are of various different sizes, that functionality as of 5/8/2025 is NOT available on ZFS. On ZFS all disks need to be the same size or larger, and if you do use larger drives with smaller drives, you will loose any of the extra space, ZFS cannot use it.
2. Synology does have the ability to go from one raid type to the next when using SHR/SHR2. For example you could start with two drives, which Synology will put into a mirror, then add another drive to the pool and have the option to change to raid 5 and so on. On ZFS once you make your VDEV, you are stuck with the type you make (mirror, Z1, Z2 ect) and the only way to change the type is to destroy the Vdev which will destroy what ever pool is attached to it.
3. You can (as of late 2024) now expand ZFS by adding one drive at a time. So for example if you have a raid Z1 with 4 disks, you can add a 5th drive to that Vdev like we could with Synology, however the underlying methods on how ZFS expansion work are different from the Synology MDADM / Linux Volume Manager methods.

For more details on expanding ZFS, these two videos are very helpful: <a href="https://www.youtube.com/watch?v=11bWnvCwTOU">Lawrence Systems - TrueNAS: How To Expand A ZFS Pool</a> and <a href="https://www.youtube.com/watch?v=uPCrDmjWV_I">Lawrence Systems - TrueNAS Tutorial: Expanding Your ZFS RAIDz VDEV with a Single Drive</a>

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
		<li><ins>Radarr</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>GraphiteExporter</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>chromium</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>chromium_normal</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>flaresolverr</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>filebrowser</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>jellyfin</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>sickchill</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>flaresolverr</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>grey_log</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>truecommand</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
		<li><ins>diun</ins> <small>[Ensure the “Dataset Preset” is set to “Apps”]</small></li>
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
	  <li><strong>hosting</strong> <small>[for our web hosting] use unix permissions, set all nine checkboxes </small></li>
	   <ul>
			   <li>Then created the following additional "normal directories"</li>
			   <ul>
			   <li>nginx</li> 
			   <li>sql</li>
		           <li>web</li>
				   <ul>
					<li>config</li>
					   <ul>
						<li>config_files</li>
					   </ul>
				   </ul>
			   </ul>
		   </ul>
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
			   <li>logging</li> 
				   <ul>
				   <li>notifications</li> 
				   </ul>
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
	   <li> <strong>Veeam</strong> <small>[Ensure the “Dataset Preset” is set to “SMB” and choose to create share]</small></li>
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

NFS shares are not required unless you are sharing this TrueNAS system's data with other Linux systems. I am doing so in the beginning to use the shares currently on my Synology units so I can expose PLEX to my movies and TV shows. If you do not need NFS shares, skip this section. 

Useful information:  <a href="https://www.youtube.com/watch?v=mdHmcwWTNWA">Lawrence Systems - Configuring TrueNAS NFS Share for XCP-ng</a> 

For each share created for NFS, it is suggested to define the IP address of the host(s) that will connect to limit who can connect for added security. For example, during this testing I plan to allow my current Synology systems to access my NFS shares and my three systems have IPs 192.168.1.178, 192.168.1.200, and finally 192.168.1.13. Since I plan to have no other systems access my TrueNAS NFS shares, limiting connections to only those three host IPs increases my security a little. 

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
3. repeat step above as needed for additional shares as desired.

Note: I had difficulty in sharing a data set with child data sets over NFS, specifically the `/mnt/volume1/video` data set. For some reason I could see and access the data on that `/mnt/volume1/video` main data set I was directly sharing over NFS, but I was NOT able to acces the files in the child data sets `4k_movies`, `TV_shows` etc... even after playing around with permissions. If there were "regular" folders created within the main data set `/mnt/volume1/video` I was directly sharing with NFS, I was able to see THOSE folders and files fine. I am sure there is a fix for this, but for my limited testing and now getting it to work well enough for my needs. As such I just made individual NFS shares for the data sets I made under `/mnt/volume1/video` and everything seemed to work fine. 

## 11.)  Create snapshots
<div id="Create_snapshots"></div>

Snapshots work the same with TrueNAS as they do with Synology as they can be restored if needed to recover data. 

To schedule snapshots:
1. go to `Data Protection -> Periodic Snapshot Tasks -> Add`
2. choose the desired data set. I would recommend to make scheduled snapshots for each separate data set to allow for flexibility in possible future data recovery. To assist with this, an option check box `recursive` is available when scheduling snapshots. This will create separate snapshots for all of the child data sets. As such I made one scheduled snap shot task for my `/mnt/volume1` data set and chose the recursive option to also make separate snap shots of everything under it to. 
- also be aware that on our SMB shares, by default the option `Enable Shadow Copies` is enabled. This allows windows users to use the `Previous Versions` feature to recover older copies of individual files and folders. This allows for granular per-file recovery in an easy to use manner. As I will be accessing my TrueNAS files near constantly over SMB (I am a windows user YAY!) this is a very handy feature if I need to recover a file as I do not need to directly interact with the TrueNAS GUI etc. 
3. Choose the amount of time the snap shot is retained
- this is accomplished using the `Snapshot Lifetime` and `Unit` options. I am choosing 1 week of retention. 
4. I am leaving the naming process `Naming Schema` as the default of `auto-%Y-%m-%d_%H-%M`
5. Choose how often the snap shots are taken, the main options are Hourly, Daily, Weekly, Monthly. However custom options are also available. I am going with Daily.
6. I am leaving the `Allow Taking Empty Snapshot` option enabled
7. I am not excluding anything from my snapshots so I am leaving `Exclude` empty

## 12.)  Install required Apps 
<div id="Install_required_Apps"></div>

On my Synology systems I purposefully made separate users for every docker container so I could restrict each container to only the data it needs. On my Synology systems I had a "docker" folder where I had sub folders for each container. If I were to use one user for every container, it would allow the different containers to read each other's data. This is especially important when running things like PLEX or JellyFin in docker where those two apps will also need access to your media libraries. You probably do not want all of your containers to have access to those. Making separate users per container helps solve this problem as each user can be restricted individually on what they can and cannot access. 

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
    - **SMB User**: un-check the box
    - Record the **GID** of the newly created group `Credentials --> Groups`
    - Find the group with the name of the user just created and in the `GID` column, record the number assigned.
The PID and GID created for this user, in this example “Plex” will be used to assign that app rights to ONLY the data sets required and desired for the app. Otherwise by default the app will be placed inside the system default “apps” user and we will otherwise not be able to have as much fine grain detail and control over what this particular app can and cannot access.
2. Go to the `Datasets` page
- Select the data set the app will have access to for example `apps`
- On the right side scroll down to `Permissions` and click `edit`
- Click `add item`
- In the `Access Control Entry` area, under `who` select `group` and under `group` select the user needed in this example “Plex”
- Under the `Permissions` area, `Permission Type` should be set to `Basic` and the `Permissions` should be set to `Traverse` so this app can enter the `apps` data set to get access to the `PLEX` data set within it. 
- Click button `Apply permissions recursively`, agree to the confirmation pop-up. Note: the `Traverse` option is needed for nested data sets only. This allows the PLEX app to "move through" the `apps` data set, but cannot actually access any data within it. We need to configure the child data set(s) we want PLEX to be able to access individually. 
  - IF the desire is to have this app (Plex) be able to traverse ALL data sets inside the current data set, click the `Apply permissions to child data sets`. In this example we will NOT be doing that as we want PLEX to only have access to its data set we created under the apps data set.
- Click `Save Access Control List`
- We now need to give the app (PLEX) access to the data set `PLEX` under “apps” in this case the `/volume1/apps/plex`. Click on the plex data set and repeat steps above for that data set. However for the permissions set it to `Full Control` so the App (PLEX) can control it’s assigned app directory `/volume1/apps/plex`. <ins>For other data sets outside of the apps area</ins>, the default can be used, or limited to just read as desired.
- Repeat these steps for ANY and ALL other data sets you wish this particular app to access. In our example, we would also want to make sure plex had access to the `video` data set we created, and in this instance, we WOULD want to check the box `Apply permissions to child data sets` and the box `Apply permissions recursively`, to ensure plex can access all of the needed media files in the /volume1/video directory.

<div id="Frigate"></div>

3. **Frigate**
- Refer here for detailed information on <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main/frigate">Frigate Configuration on TrueNAS</a>

I have been using Synology Surveillance Station (Referred here on out as SSS) since 2019. Prior to that I had been using a SWANN 8x camera system with 4k cameras. I kept the cameras but simply replaced the NVR with the DVA3219 and I have been very happy since.

If I was going to move away from Synology, then would need to find a good replacement for SSS. I looked into various options like Blue Iris but that only runs on windows. I also looked into Zoneminder and Frigate and really liked what I was seeing with Frigate.

With my DVA3219 and the NVidia graphics card inside it I have currently been utilizing its 4x max concurrent "deep video analysis" features to perform person, vehicle and object detection, which has been working well. What has really made me appreciate Frigate is that I can do the same object detection and MORE on ALL of my 12x cameras while also using LESS wattage on my electricity bill.

To achieve this I am using a single Google Coral Tensor Processor Unit (TPU) and iGPU pass-through from my Core i7-8700T CPU in my test Dell Micro PC to the container to perform all of the analysis on 12x cameras at the same time. The TPU uses less than 5 watts, and the iGPU is only being loaded to 4-ish percent and the CPU was loaded to around 20%. This is compared to the DVA3219 which loads by CPU to around 50%, loads the GPU to around 90%.

I used a kilo-watt meter to get a good understanding of the power draw on the Dell micro PC when Frigate was ON and when it was OFF and the power usage difference was around 18 watts. I did the same comparison on the DVA3219 and the power differential when SSS is ON vs OFF was about 75 watts. That is a huge difference in 24/7 on-going power draw and yet Frigate is doing even more analysis!!.

something of note: Frigate does NOT use any of the detections built into cameras, it only performs all processing and detections/triggers internally using your CPU, GPU, TPU etc. This means if you have really fancy AI cameras that can natively perform people, object, motion detection etc, those features cannot be leveraged by Frigate. Personally after using Frigate, I think Frigate does a better job anyways but your mileage may vary.

another thing to note: when looking at the Frigate web GUI live stream page showing multiple cameras, the video wil NOT be 100% live. The video will only "activate" when there is actively detected motion, alerts, or detections. Then the video will show the live stream and as soon as the event(s) are over the video will "pause". This was initially confusing for me as SSS will show the live stream at all times when looking at all the cameras together.

<div id="Grafana"></div>

4. ***Grafana***

Nothing too special is needed for Grafana as it is available directly through the Discover Apps page. <a href="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/grafana/grafana_app_settings.png">Here are my settings</a>

<div id="influxDB"></div>

5. ***influxDB***

Nothing too special is needed for InfluxDB as it is available directly through the Discover Apps page. <a href="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/influxDB/influxdb_app_settings.png">Here are my settings</a>

<div id="jackett"></div>

6. ***jackett***

We do NOT want to install the version of Jackett directly available through Discover Apps because we want to ensure Jackett runs through our GlueTUN VPN tunnel. <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/blob/main/Jackett/docker-compsoe.yaml">Here are my settings</a>. 

<div id="plex"></div>

7. ***plex***

Nothing too special is needed for PLEX as it is available directly through the Discover Apps page. <a href="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/PLEX/plext_app_settings.png">Here are my settings</a>

<div id="radar"></div>

8. ***radarr***

<div id="sickchill"></div>

9. ***sickchill***

Sickchill is not available through the `Discover App` page on TrueNAS but I was able to use the compose file method to install it. My <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/blob/main/SickChill/docker-compose.yaml">docker-compose.yaml</a> file is available.  

This app requires gluetun to be operational as we are tunneling all of sick chill's web traffic through the gluetun app to ensure it uses our VPN tunnel. 

To acheive this, the key line is `network_mode: "container:gluetun"` making all of this containers traffic flow through the GlueTun container. In addtion, the normal `ports:` lines are NOT needed. Instead we need to edit/revise the gluetun docker compose stack file with the added line of `- 8081:8081/tcp`. 

<div id="nginx_reverse_proxy"></div>

10. ***nginx reverse proxy manager***

Nothing too special is needed for Nginx Reverse Proxy Manager as it is available directly through the Discover Apps page. <a href="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/nginx%20Reverse%20Proxy/nrpm.png">My Configuration</a>

A useful video on the app: <a href="https://www.youtube.com/watch?v=jx6T6lqX-QM">Lawrence Systems - Self-Hosted SSL Simplified: Nginx Proxy Manager</a>

<div id="jellyfin"></div>

11. ***jellyfin***

<div id="tautulli"></div>

12. ***tautulli***

<div id="Chromium"></div>

14. ***Chromium***

I have TWO copies of the chromium browser installed on my system. One is linked to the gluetun network so I can easilly go to Nord VPN's DNS checker and tunnel status check pages to prove that the VPN tunnel is working as expected. The second one is "normal" and runs through my normal public IP adress. The main reason why I need this second tunnel is it allows me to access the web GUI interfaces for my 12x security cameras running in Frigate. Unfortunately because the first chromium container is linked to the gluetun container/VPN tunnel, it is not able to access my security camera network. 

The copy running through the GlueTun VPN tunnel <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/blob/main/chromium/docker-compose-VPN.yaml">docker-compose.yaml</a> file is available. This app requires gluetun to be operational as we are tunneling all of the chromium web traffic through the gluetun app to ensure it uses our VPN tunnel. 

To acheive this, the key line is `network_mode: "container:gluetun"` and the normal `ports:` lines are NOT needed. Instead we need to edit/revise the gluetun docker compose stack file with the added line of `- '3410:3001'`. 

The second version not running through the VPN tunnel <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/blob/main/chromium/docker-compose-Normal.yaml">docker-compose.yaml</a> is available. 

Running the two chromium containers side-by-side it can be easilly seem that the VPN tunnel is working as expected

RUNNING THROUGH VPN
<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/chromium/chromium_ip_address_VPN.png" alt="chromium_ip_address_VPN.png" width="540" height="269">

NOT RUNNING THROUGH VPN
<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/chromium/chromium_ip_address_normal.png" alt="chromium_ip_address_normal.png" width="393" height="234">

My actual public IPv4 address starts with 98.... which is what the normal chromium is reporting. In addtion, the normal chromium also is properly reporting my IPv6 address. The VPN version of chromium is properly reporting `94.140.9.159` which is an IP address assigned to NORD VPN. In addition, this is the same IP address reported at the bottom of qBittorrent. Based on this I know that my VPN traffic is properly being routed through the VPN. 

<div id="Portainer"></div>

15. ***Portainer***

<div id="Torrent_downloader_VPN"></div>

16. ***Torrent down loader + VPN***

<a href="https://www.youtube.com/watch?v=TJ28PETdlGE">very useful step by step guide on using GlueTUN for docker app VPN tunnels</a>

To get my Qbittorrent and GlueTUN VPN tunnel working with Nord VPN, I have my <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/blob/main/torrent/dockercompose.yaml">docker-compose.yaml</a> available. 

breakdown of the importaint parts for the `GlueTUN` container:

```
cap_add:
      - NET_ADMIN
```

this allows the GlueTUN app to create and manage networks

```
 devices:
      - /dev/net/tun:/dev/net/tun
```

this is the tunnel that will be used to allow the VPN to function

```
ports:
      - 8888:8888/tcp #proxy port
      - 8388:8388/tcp #shadowsocket
      - 8388:8388/udp #shadowsocket
      - '10095:10095' #qbittorrent web interface
      - '16881:16881' #torrent download port
      - 6881:6881/udp  #torrent download port
      - '3410:3001' #chromium HTTPS port (host port 3410, container port 3001)
      - 8081:8081/tcp #sickchill
```

ALL containers that you wish to have tunneled through the GlueTUN app must have their ports defined here. Due to this, every time a new app is added needing to run through the tunnel, the compose file will need to be revised and the container relaunched. 

```
- VPN_SERVICE_PROVIDER=custom
      - VPN_TYPE=openvpn
      - OPENVPN_CUSTOM_CONFIG=/gluetun/custom.conf
      - OPENVPN_USER=nord_VPN_user
      - OPENVPN_PASSWORD=nord_VPN_password
      - HEALTH_TARGET_ADDRESS=google.com
      - HEALTH_VPN_DURATION_INITIAL=30s
      - HEALTH_VPN_DURATION_ADDITION=10s
      - HEALTH_SUCCESS_WAIT_DURATION=60s
      - DOT=off
      - DNS_ADDRESS=103.86.96.100 #NORD VPN DNS server
```

This is my configuration for NordVPN, but will be different if you use one of the MANY VPN providers supported by GlueTun. If your VPN provider also has its own DNS, ensure you configure the `DNS_ADDRESS` paramter to ensure no DNS leaks occur. Now,I purposfuly have encrypted DNS off `DOT=off` for because NordVPN DNS does not seem to support it, but if your VPN provider does, ensure it is set to ON for more security. I also have a `healthcheck` task running that will ping google and if it fails, it will restart the cotainer to hopefully re-connect to Nord VPN again. 

breakdown of the importaint parts for the `qBittorrent` container:

```
depends_on:
      - gluetun
```
if the gluetun app is not running, the qBittorrent app will not run

`network_mode: service:gluetun` ensures the qBittorrent app runs through the network created by the GlueTUN app ensuring it flows through the VPN tunnel

<div id="ngninx_PHP_Maria_DB_Stack"></div>

17. ***ngninx + PHP + MySQL Stack + PHPMyAdmin*** also known as LEMP stack (replaces web station)

I based my stack off the following: <a href="https://linuxiac.com/how-to-set-up-lemp-stack-with-docker-compose/">how-to-set-up-lemp-stack-with-docker-compose</a> combined with the example here detailing <a href="https://www.hostmycode.in/tutorials/lemp-stack-on-docker">Nginx with port 80 to 443 forwarding and ssl certs</a>. 

I am aware this is not considered the best security practice however I was not able to get the LEMP stack to work unless I set the permissions to `/mnt/volume1/hosting` to `777`. To acheive this I went to the permissions for the `/mnt/volume1/hosting` share, wiped the ACL and set the user and group to the `web` user and set all permissions to read/write/execute. I have been experimenting on trying to rein in these permissions, but anything other than this prevents the stack from working correctly. 

My final configuration and needed files are <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main/nginx%20%2B%20PHP%20%2B%20MariaDB%20Stack">found here</a>. 

Download all of the files and folders and place them in the data set `/mnt/volume1/hosting`. If using anyb other directory, update the `docker-compose.yaml` file accordingly. 

to get the HTTPS working, your SSL cert "full chain" cert file and the private key file need to be placed in the `/mnt/volume1/hosting/nginx` dirctory. The "full chain" cert will be one file that contains your personal domain cert and your intermetiate cert all in one file. 

within TrueNAS go to `apps --> discover apps --> next to the "custom app" click on the three dots --> install via yaml`. Give the stack a name, I named it `web` and paste the contents of the docker-compose.yaml file. 

once the stack is up, go to `http://<server-ip>:444/index.php` and you should see details of your PHP installation on the browser after you go through the cert warning page. The cert warning page is because we are accessing the site through the IP adress and not our domain name. I am configuring the port to be port `444` because port `443` is being used by Nginx Reverse Proxy Manager. We will be using NRPM to acess the site through our domain name, but we know that the communications between NRPM and our LEMP stack will also be encrypted. 

Now we need to transfer some files from Synology. Let's start with SQL databases from synology. Some of my databases are hundreds of GB in size and to prevent timeout issues when importing .SQL files within PHPMyAdmin, I decided to import the .SQL files through the command line. If your files are small, importing through PHPMyAdmin should be fine. 

- export current databases on synology. I am not deatiling how to do this as there is no guarantee you have been using PHPMyAdmin on Synology. 
- copy files to SMB `\\<trueNAS_IP>\hosting`
- Log into TrueNAS SSH and change to the hosting directory. `cd /mnt/volmume1/hosting`
- Copy the files from the hosting directory to where the SQL data is being saved. `cp home_temp.sql /mnt/volume1/hosting/sql/home_temp.sql` where `home_temp.sql`is the backup file exported from synology and `/mnt/volume1/hosting/sql/` is where my `mysql` container is saving data. 
- go to apps, click on "web" app we created and select MySQL's shell
- within MySQL's shell: `cd /var/lib/mysql`
- log into sql. `mysql -u root -p` and enter password when asked
- create database with same name as one exported from synology. `CREATE DATABASE home_temp;` 
- we now need to tell MySQL to use the new database to ensure our import goes into it correctly: `use home_temp;`
- import sql file. `source home_temp.sql`
- you can now delete the .SQL files in the `/mnt/volmume1/hosting` and `/mnt/volume1/hosting/sql` we copied over from Synology. 

we need to copy any web hosted files from the synology and place those files in the `/mnt/volmume1/hosting/web`

Your web services should now be working

If you wish to upgrade your version of PHP or if you wish to add or remove PHP modules, you wil need to edit the `/mnt/volmume1/hosting/php-dockerfile`

```
FROM php:8.4-fpm

# Installing dependencies for the PHP modules
RUN apt-get update && \
    apt-get install -y zip libzip-dev libpng-dev && \
	cd /bin && \
	apt-get install pip -y && \
	echo "Python and PIP now installed" && \
	curl -L "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp" -o yt-dlp && \
	echo "YT-DLP Binary downloaded to /bin" && \
	chmod a+rx yt-dlp && \
	echo "YT-DLP binary now executable\nInstallation Complete"

# Installing additional PHP modules
RUN docker-php-ext-install mysqli pdo pdo_mysql gd zip

```

as of this writting, this file is using PHP 8.4 <a href="https://www.php.net/supported-versions">few months</a>. If a new PHP version is available the line `FROM php:8.4-fpm` would have to change to `FROM php:8.5-fpm` for example. After making the changes to the file, the stack will have to be **removed within TrueNAS**, and the option to `remove images` must be checked or we will have an un-used older image of PHP taking up disk space. Then recreate the stack using our docker-compose file and the new version of PHP and or the updated extensions wil be installed. 

Please note: This `/mnt/volmume1/hosting/php-dockerfile` file is also commanding docker-compose to install PIP (which also installs Python3) and YT-DLP within the PHP container itself. This is done so i can use my PHP based yt-dlp control page to command ty-dlp without using the command line. if you do not wish to have yt-dlp or PIP installed as part of your PHP image file, change the file to the following:

```
FROM php:8.4-fpm

# Installing dependencies for the PHP modules
RUN apt-get update && \
    apt-get install -y zip libzip-dev libpng-dev

# Installing additional PHP modules
RUN docker-php-ext-install mysqli pdo pdo_mysql gd zip

```

<div id="DIUN"></div>

18. ***DIUN – Docker Image Update Notifier***

<div id="TrueCommand"></div>

19. ***TrueCommand***

<div id="Veeam"></div>

20. ***Veeam*** *[Replaces Active Backup for Business]*

I have been usingSynology Active Backup for Business to perform bare metal backups of my 4x windows machines and needed a way to perform this same function. I found Veeam free for windows which does exactly what i needed. This is a program that runs solely on the windows machine and simply uses SMB to save the backup data to your trueNAS. It allows for incremental backups, backup retention policies just like Active Backup for Buisnss. One thing Active Backup for Business was really good at was de-duplication which Veeam is not as good as, but i am OK with that. 

Veeam free for windows can be downloaded here: <a href="https://www.veeam.com/products/free/microsoft-windows.html">Veeam windows client free</a>

The configuration settings that i sucessfully used to perform bare metal backups to by trueNAS server can be found <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main/Veeam">here</a>. 

I am also going to be combining Veeam with Syncthing to perform versioned backups of specific directories on my windows machines. <a href="https://www.youtube.com/watch?v=cccPnXnh6wA">Lawrence Systems - How I Use Syncthing for Real Time Backups</a>

<div id="Grey_log"></div>

21. ***Grey log***
- https://www.youtube.com/watch?v=PoP9BTktlFc
- https://www.youtube.com/watch?v=DwYwrADwCmg

<div id="flaresolverr"></div>

22. ***flaresolverr***

<div id="ytdlp"></div>

23. ***ytdlp***

I have been using a  <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/blob/main/yt-dlp/youtube-dl.php">custom made PHP based web page</a> that generates the commands needed to control YT-DLP. 

 <img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/images/ytdlp_downloader.png" alt="ytdlp_downloader.png" width="469" height="922"> 

The actual YT-DLP binary and Python3 dependancies, plus the needed PHP web server must first be installed per  <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main?tab=readme-ov-file#ngninx_PHP_Maria_DB_Stack">ngninx + PHP + MySQL Stack + PHPMyAdmin</a>. 

Once YT-DLP is installed within the PHP docker image, download the contents of <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main/yt-dlp">this page</a> and place the contents in the `/mnt/volume1/hosting/web` directory used by the PHP server and extract the contents. 

The zip file is broken into several pieces as Github was preventing me from uploading files over 25MB in size. The zip file contains the following:

<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/images/youtube_zip_file_contents.png" alt="youtube_zip_file_contents.png" width="705" height="205">

`ffmpeg` is where the ffmpeg program is stored to allow YT-DLP to edit the length of files, for example if savings just the .mp3 version of a video, but needing to cut out unwanted material in the beginning or end

`youtube-nsig`, `youtube-sigfuncs`, and `youtube-sts` are cache directories used by YT-DLP. 

`log` is where YT-DLP will save logs of files downloaded

`phantomjs` allows YT-DLP to download videos from sites other than youtube by simulating a normal web browser and isolating the video stream to download. 

Please note that the `youtube-dl.php` file in my configuration is called within a different PHP file that has proper headers and formatting. If using the `youtube-dl.php` file stand alone, usea and edit the internal variables detailed below

```
//********************************
//USER VARIABLES
//********************************
$form_submit_location="index.php?page=13";			#the form submit location. NOTE: i have this .PHP file included within another PHP file "index.php" which is why the form submit location shows "index.php?page=13". If running this PHP file standalone, change this value to the name of the PHP file.
#include_once 'header_yt_dlp.php';					#note, as previously indicated i am running this PHP file through another file which is handling the header details for me. If running this PHP stand alone, uncomment this line to allow proper formatting
$youtube_folder_location="/var/www/html/youtube";   #this is the directory within the PHP docker container NOT the TrueNAS operating system
$page_title="Youtube-dlp --> Video/Audio Downloader";
$web_url_to_youtube_directory="http://192.168.1.8/youtube"; #replace with your TrueNAS IP or replace with your TrueNAS domain name
$use_sessions=false; #use log in sessions?
```

`form_submit_location` the form submit location. NOTE: i have this .PHP file included within another PHP file "index.php" which is why the form submit location shows "index.php?page=13". If running this PHP file standalone, change this value to the name of the PHP file.

`#include_once 'header_yt_dlp.php';` uncomment if using file stand alone

`youtube_folder_location` this is the directory within the PHP docker container NOT the TrueNAS operating system

`page_title` is the title of the page displayed on the web page

`web_url_to_youtube_directory` #replace with your TrueNAS IP or replace with your TrueNAS domain name

`use_sessions` use sessions or do not use sessions. If using stand alone, do not enable sessions. 


## 13.)  Data Logging Exporting to Influx DB v2  
<div id="Data_Logging_Exporting_to_Influx_DB_v2"></div>

TrueNAS has built in metrics that show CPU usage, network usage and more. This is great, but one might want to export this data to be able to better display it in Grafana for example. Unfortunately TrueNAS only exports data over Graphite and I like to use InfluxDB v2 which removed the ability to natively ingest graphite formatted data. Because of this I needed an intermediary step to convert the graphite data into something InfluxDB could ingest. To do this I used a `truenas-graphite-to-prometheus` exporter. InfluxDB can ingest prometheus data. 

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
  - **User ID**: 568 [This is one app I have not made a separate user for since it does so little]
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
- There should be a ton of text displayed showing the last set of data received from TrueNAS. I have configured TrueNAS to export data every 10 seconds so data should already be available. However if you chose a slower rate like every few minutes, you will need to wait until TrueNAS sends data to it's exporter before you will see data on the metrics page. 
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

## 14.)  Install script to pull TrueNAS SNMP data + Non-SNMP Data like GPU Details
<div id="Install_script_to_pull_TrueNAS_SNMP_data"></div>

1.) **Intro**
We now have a lot of the available data metrics from TrueNAS being saved to InfluxDB, but this is not ALL of the data available to use. The rest needs to be accessed over SNMP or directly off things like smartctl and NVidia drivers. You are going to want to enable SNMP to use this script which I will document below so the script I will detail can collect the needed information. 

The SNMP data is collected based on the details of the <a href="https://www.truenas.com/docs/scale/scaletutorials/systemsettings/services/snmpservicescale/">TrueNAS MIB file</a>

on a system not running NVidia drivers, here is an example of the data it can collect:

```
zpool,nas_name=TrueNAS,zpool_index=1 zpool_name="boot-pool",zpool_health="ONLINE",zpool_read_ops=51163,zpool_write_ops=1214320,zpool_read_bytes=1740320768,zpool_write_bytes=16606257152

zpool,nas_name=TrueNAS,zpool_index=2 zpool_name="volume1",zpool_health="ONLINE",zpool_read_ops=1614890,zpool_write_ops=9019562,zpool_read_bytes=202085289984,zpool_write_bytes=468552794112

zvol,nas_name=TrueNAS,zvol_index=1 zvol_descr="boot-pool",zvol_used_bytes=3044765696,zvol_available_bytes=242506588160,zvol_referenced_bytes=98304

zvol,nas_name=TrueNAS,zvol_index=2 zvol_descr="volume1",zvol_used_bytes=271744225280,zvol_available_bytes=219358752768,zvol_referenced_bytes=131072

arc,nas_name=TrueNAS zfs_arc_size=7985746,zfs_arc_meta=634447,zfs_arc_data=7340832,zfs_arc_hits=174587035,zfs_arc_misses=1669275,zfs_arcc=8081757,zfs_arc_miss_percent=0.9470724764406953,zfs_arc_cache_hit_ratio=99.05,zfs_arc_cache_miss_ratio=0.95

l2arc,nas_name=TrueNAS zfsl2arc_hits=0,zfsl2arc_misses=0,zfsl2arc_read=0,zfsl2arc_write=0,zfsl2arc_size=0

zil,nas_name=TrueNAS zfs_zilstat_ops1sec=0,zfs_zilstat_ops5sec=0,zfs_zilstat_ops10sec=0

hdd_temp_nvme,nas_name=TrueNAS,device="nvme0n1" nvme_temp=41,nvme_temp1=41,nvme_temp2=47

hdd_temp_snmp,nas_name=TrueNAS,device="sda" hdd_temp_value="32000"

hdd_temp_snmp,nas_name=TrueNAS,device="nvme0n1" hdd_temp_value="41000" 
```

for systems running NVidia drivers, the script will collect the following

gpuTemperature, gpuName, gpuFanSpeed, gpu_bus_id, vbios_version, driver_version, pcie_link_gen_max, utilization_gpu, utilization_memory, memory_total, memory_free, memory_used, gpu_serial, pstate encoder_stats_sessionCount, encoder_stats_averageFps, encoder_stats_averageLatency, temperature_memory, power_draw, power_limit, clocks_current_graphics, clocks_current_sm, clocks_current_memory, clocks_current_video 

I have the script configured to run every 60 seconds, and each execution, it will collect data 4x times so I am collecting data every 15 seconds. 

This script does need to have a working PHP web site to allow for the configuration of the script. As of 5/11/2025, I have not yet written the PHP web page code for this script. 

2. **Install Script and Support Files**

- This assumes you already have the <a href="#ngninx_PHP_Maria_DB_Stack">nginx + PHP + MySQL docker stack</a> installed which means it assumes you already have some data sets and folder structures already created.
- Download the following files `multireport_sendemail.py` and `trueNAS_snmp.sh` and place them in the `/mnt/volume1/web/logging` directory if you used the same folder structure I did, or place it where you have your web site files stored.
- create a `/mnt/volume1/web/logging/notifications` directory as the script will use this for temp files
- create a `/mnt/volume1/web/config` directory as this is where the script will save its config file.
- download the example `trueNAS_snmp_config.txt` file and place it in your `/mnt/volume1/web/config` directory
- download the TBD .PHP file to the `/mnt/volume1/web/config` directory so we can configure the script

3. **Configure the .SH script file**

- inside the script there is a section asking for emails. This is so the script can still send you emails if the config file is missing or corrupted. Adjust to match your needs. 
```
#########################################################
#EMAIL SETTINGS USED IF CONFIGURATION FILE IS UNAVAILABLE
#These variables will be overwritten with new corrected data if the configuration file loads properly. 
email_address="email@email.com"
from_email_address="email@email.com"
#########################################################
```
- the script has the following settings that need to be set if you are using a folder structure different from my example
```
log_file_location="/mnt/volume1/web/logging/notifications"
lock_file_location="$log_file_location/trueNAS_snmp.lock"
config_file_location="/mnt/volume1/web/config/trueNAS_snmp_config.txt"

nas_name="TrueNAS" #this is only needed if the script cannot access the server name over SNMP, or if the config file is unavailable and will be used in any error messages
capture_interval_adjustment=3
```
- `log_file_location` is where logs and other intermediate files are saved while the script is working
- `lock_file_location` is where the script will create en empty directory that will then be deleted when the script's execution is complete. this is to prevent more than one copy of the script from running at the same time
- `config_file_location` is where the config file is located
- `nas_name` is what you have named your TrueNAS system so the emails and notifications can refer to the correct system
- `capture_interval_adjustment` is used if the script takes too long to execute and does not complete in less than 60 seconds. The default is 3. This should not need to be adjusted.

4. **Configure the .PHP Config File**
- open the .PHP file and ensure the line `$config_file_location="/mnt/volume1/web/config/trueNAS_snmp_config.txt";` matches the same directory as the .SH script file.

5. **Launch PHP web page and configure the script**

## 15.)  Setup Grafana Dashboard for TrueNAS
<div id="Setup_Grafana_Dashboard_for_TrueNAS"></div>

## 16.)  Setup Custom Logging Scripts and Configure CRON
<div id="Setup_Custom_Logging_Scripts_and_Configure_CRON"></div>

I have many scripts running on my Synology that collect data from themselves (DSM SNMP monitoring), UPS mnitoring, nework switch monitoring and more. These scripts need to be configured to run automatically. One example of this type of script is <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/blob/main/trueNAS_snmp.sh">here</a>.

I first started out using the `System --> Advanced Settings --> Cron Jobs` option and that worked. what i realized though is that this was clogging up my `Running Jobs` page and making lots of un-needed log files. As such i am instead directly editing the crontab file by `vi /etc/crontab`

here are the contents of my crontab file

```
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || { cd / && run-parts --report /etc/cron.daily; }
47 6    * * 7   root    test -x /usr/sbin/anacron || { cd / && run-parts --report /etc/cron.weekly; }
52 6    1 * *   root    test -x /usr/sbin/anacron || { cd / && run-parts --report /etc/cron.monthly; }
#
* * * * * root bash /mnt/volume1/web/logging/trueNAS_snmp.sh
0 * * * * root bash /mnt/volume1/web/logging/smart_logger.sh
```

please note the last two lines, these are the lines i added. 

```
* * * * * root bash /mnt/volume1/web/logging/trueNAS_snmp.sh
0 * * * * root bash /mnt/volume1/web/logging/smart_logger.sh
```

line `* * * * * root bash /mnt/volume1/web/logging/trueNAS_snmp.sh` runs my truenas logging script every 60 seconds

line `0 * * * * root bash /mnt/volume1/web/logging/smart_logger.sh` runs my SMART logging script every hour

## 17.)  Configure Disk Standby
<div id="Configure_Disk_Standby"></div>

## 18.)  Cloud backups to BackBlaze B2 Bucket
<div id="Cloud_backups_to_BackBlaze_B2_Bucket"></div>

## 19.)  Replace “DS File” app – Android Only
<div id="Replace_DS_File_app_Android_Only"></div>

## 20.)  Configure Data Scrubs
<div id="Configure_Data_Scrubs"></div>

Like Synology's Storage Manager data scrub scheduling, TrueNAS can schedule data scrubs. This setting can be found at `Data Protection--> Scrub Tasks --> Add`

here are my settings:
<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/images/scrub_task.png" alt="scrub_task.png">

I have the `Schedule` set to daily, however the key is i have `Threshold Days` set to 90. Per the tool tip next to Threshold Days `Days before a completed scrub is allowed to run again. This controls the task schedule. For example, scheduling a scrub to run daily and setting Threshold days to 7 means the scrub attempts to run daily. When the scrub is successful, it continues to check daily but does not run again until seven days have elapsed. Using a multiple of seven ensures the scrub always occurs on the same weekday.` A such, while the task is scheduled to run every day, it will only actually run every 90 days. 

## 21.)  Schedule SMART tests
<div id="Schedule_SMART_tests"></div>

There will be two ways of scheduling SMART tests. The first is TrueNAS native SMART scheduling. The second uses my custom SMART scheduler. I will describe how to setup both. 

**Native TrueNAS SMART scheduling**

`Data Protection--> Periodic S.M.A.R.T. Tests --> Add`

We will add two tasks, one short, one long

Long SMART settings:
<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/images/long_smart.png" alt="long_smart.png">
Notice the custom settings, this will run the long SMART test every 3 months on the 1st day of the month on only January, April, July, and October at 4:00 AM in the morning. 

Short SMART settings:
<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/images/short_smart.png" alt="short_smart.png">

**Custom SMART Scheduler**

this script requires a working PHP web server per <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main?tab=readme-ov-file#ngninx_PHP_Maria_DB_Stack">ngninx + PHP + MySQL Stack + PHPMyAdmin</a>.

I have written a custom SMART test scheduling script detailed <a href="https://github.com/wallacebrf/Synology-SMART-test-scheduler">here</a>.

The installation is the same as the details in that page <ins>EXCEPT</ins> that the `script_location="/mnt/volume1/hosting/web/synology_smart"` within the `synology_SMART_control.sh` file is where the file is located on the <ins>TrueNAS system</ins> **BUT** the value of `$script_location="/var/www/html/synology_smart";` within file `smart_scheduler_config.php` is the location of the script within the <ins>PHP docker continer</ins>. 

The reason why i prefer this over the functionality built into TrueNAS is that it allows for:
- the option to more easilly see the live status of a SMART test
- to scheudle SMART tests on disks seqentuially or all at once
- receive email notiifcations of when tests finish and start
- better log history details

to enable the script to run every 10 to 15 minutes, we need to edit crontab `nano /etc/crontab` and we need to add the fillowing line: `0,15,30,45 * * * * root bash /mnt/volume1/hosting/web/synology_smart/synology_SMART_control.sh` which will run the script at minute 0, 15, 30, andn 45 of every hour of every day

## 22.)  Configure Email Sending From CLI
<div id="Configiure_email_sending_from_CLI"></div>

For some reason TrueNAS does not have `sendmail` or other readily available methods to send emails using the CLI and or within scripts. <a href="https://github.com/oxyde1989/standalone-tn-send-email/tree/main">Luckily I stumbled upon </a> that allows for easy sending of emails. 

The command to send emails is as follows: `python3 /mnt/volume1/web/logging/multireport_sendemail.py --subject "${subject}" --to_address "${to_email_address}" --mail_body_html "${mail_body_contents}" --override_fromemail "${from_email_address}"`

I put this into the function I previously used to send emails that also tracks when the last email was sent to prevent scripts from spamming every time they execute and will instead only send new messages after a defined set point of time

```
function send_mail(){
#email_last_sent_log_file=${1}		this file contains the UNIX time stamp of when the email is sent so we can track how long ago an email was last sent
#message_text=${2}			this string of text contains the body of the email message
#email_subject=${3}			this string of text contains the email subject line
#email_interval=${4}			this numerical value will control how many minutes must pass before the next email is allowed to be sent
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
```

Now I can send emails through scripts. I am also using this to send emails when my TrueNAS restarts and when it boots. 

I added two `Init/Shutdown Scripts` entries: Here is an example of one.

Within TrueNAS go to `System --> Advanced Settings --> Init/Shutdown Scripts` and click Add

- Description: set a description, I named mine `Startup Email`
- Type: set to `command`
- Command: `python3 /mnt/volume1/web/logging/multireport_sendemail.py --subject "TrueNAS Has Started" --to_address "${address_explode[$bb]}" --mail_body_html "TrueNAS has started" --override_fromemail "$from_email_address"` where you will need to enter your email details. 
- When: set to `post init` for startup
- ensure the task is enabled
- set time out to 3


## 23.)  Configure Remote Access using Tail Scale
<div id="Configure_Remote_Access_using_Tail_Scale"></div>

https://www.youtube.com/watch?v=o0Py62k63_c

## 24.)  Mount External NFS Shares into TrueNAS Dataset
<div id="Mount_External_NFS_Shares_into_TrueNAS_Dataset"></div>

Since I will be slowly migrating from Synology to TrueNAS I still want my Synology units to store some of my data, but this is data is need by PLEX etc that will be running on TrueNAS. As such I need to link my systems together. 

I created NFS permissions for some of my folders in Synology as seen below

<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/images/synology_nfs_settings.png" alt="synology_nfs_settings.png" width="518" height="348">

Then to mount the NFS share on TrueNAS, I created a dedicated dataset `/mnt/volume1/server2` since server2 is the name of one of my NAS and it makes it easier to know whcih NAS this is linked to. When creating this share, I left the `Dataset Preset` to `Generic` and left all other settings at default. I did not need to adjust permissions. 

Within TrueNAS go to `System --> Advanced Settings --> Init/Shutdown Scripts` and click Add

- Description: set a description, I named mine `NFS Server2 Video Mount`
- Type: set to `command`
- Command: `mount -o rw -t nfs 192.168.1.13:/volume1/video /mnt/volume1/server2`
  -Breakdown:
   -  `rw` for read/write. If you want read only, set to just `r`
   -  `192.168.1.13` IP of my remote Synology NAS
   -  `/volume1/video` the share on the remote Synology NAS I am trying to access
   -  `/mnt/volume1/server2` where on the TrueNAS system I want these files mounted
- When: set to `post init` so the share is mounted on startup
- ensure the task is enabled
- set time out to 3

The share will now mount at startup, but unless we restart the system, the share is not yet mounted so:

- go to `System --> Shell`
- enter `sudo -i` and log in under sudo
- enter the same command we configured to happen during startup `mount -o rw -t nfs 192.168.1.13:/volume1/video /mnt/volume1/server2` and the share should be mounted.

within my PLEX docker container I mapped the `/mnt/volume1/server2` folder under the app's settings

<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/images/plex_acess_NFS.png" alt="plex_acess_NFS.png" width="227" height="326">

Then within PLEX I was free to add the needed folders to my libraries

<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/images/plex_acess_NFS2.png" alt="plex_acess_NFS.png" width="321" height="310">

## 25.)  General Little Settings Here and There
<div id="General_Little_Settings_Here_and_There"></div>

https://github.com/kneutron/ansitest/blob/master/ZFS/scrubwatch.sh
https://github.com/markusressel/zfs-inplace-rebalancing

## 26.)  On Systems with IPMI supported motherboards
<div id="On_Systems_with_IPMI_supported_motherboards"></div>

Plan to add support for IPMI measurements to <a href="#Install_script_to_pull_TrueNAS_SNMP_data">Install script to pull TrueNAS SNMP data + Non-SNMP Data like GPU Details</a> to allow it to poll sensors and other details status from the motherboard directly

https://www.tzulo.com/crm/knowledgebase/47/IPMI-and-IPMITOOL-Cheat-sheet.html

https://www.ibm.com/docs/en/power9/9183-22X?topic=ipmi-common-commands

https://docs.oracle.com/cd/E19860-01/E21549/z400000c1016683.html


also, using the scripts on 45 drive's github page, try to adopt it so users who are using TrueNAS on 45 drives HL15 etc can determine which disks are in which drive slots etc. 
https://github.com/45Drives/cockpit-hardware/tree/master/45drives-motherboard/public/helper_scripts

these scripts appear to be what they use to gather all of the details needed for their hardware overview pages. 

## 27.)  Rsync Files From Synology to TrueNAS
<div id="Rsync_Files_From_Synology_to_TrueNAS"></div>

this amazing guide is what i used small modfications
https://www.reddit.com/r/truenas/comments/xk5nxm/solved_rsync_task_to_synology_nas/

- Create a new user account on **both** your TrueNAS and Synology NAS. <ins>It needs to be the same user name (for example `rsync`)</ins>. The password does not matter; does not need to be the same.
- enable the Rsync service on your Synology: `Control Panel --> File services --> "rsync" tab.
  - Tick `Enable rsync service` as well as `Enable rsync account`.
  - Click `edit rsync account`, add the user you just created (e.g. rsync) and set a secure password. <ins>Make sure to note down this password!</ins>
- Set the permissions for the user on your Synology
  - Allow access to all shared folder(s) you want to sync from the Synology system to the TrueNAS system. 
    - Make sure to give the user "full control" permissions to the folders by giving the user "custom" permissions and ticking all boxes including "change permissions" and "take ownership"   
  - Allow access to the rsync application. 
- On the TrueNAS system, we need to edit the ACL for the `/mnt/volume1/web/` data set to allow the "group" `rsync` we created so it can access the `/mnt/volume1/web/logging/syno.pw` file
- we need to edit the ACL(s) for any of the other datasets that we will be allowing rsync to write data to when it is copying from the Synology system. 
- On the TrueNAS system, create a file with the rsync password you noted down earlier. It needs to be owned and exclusively accessible by the rsync user

```
cd /mnt/volume1/web/logging
echo "your_password" > syno.pw
chown rsync:rsync syno.pw
chmod 600 syno.pw  
```

- go to `Data Protection --> Rsync Tasks --> Add` to set up the rsync task on TrueNAS. 
  - Select the `rsync` user created earlier. Choose `module` under the `rsync mode` drop down
  - For the `module name` enter the root share of the synology. For example, if a share is `\\<Syno_nas_IP>\photos` then enter just `photos` for the module. This is case senstive!
  - `Direcion` set to `PULL`
  - for `Path` set to the dataset / direcotry inside a dataset where the data copied from Synolgy will be placed
  - Under `auxiliary parameters` enter: `-hv --dry-run --password-file=<path-to-your-file> --log-file=<path-to-your-log-file>` which for our example would be `-hv --dry-run --password-file=/mnt/volume1/web/logging/syno.pw --log-file=/mnt/volume1/web/logging/syno_sync.log`
  - Ensure `Recursive` is checked
  - Ensure `enabled` is checked
  - Set `More Options` as desired, but default settings are OK
  - click `Save`
- To run the task right away, click the "play" icon


- This will sync the particualr shared folder from the Synology System, HOWEVER we have configured rsync to perform a dry run using the `--dry-run` `auxiliary parameters`. We have also told it to log everythign to `/mnt/volume1/web/logging/syno_sync.log`. 
- After the task completes, open the log file and ensure no errors occured and that the data would have been copied properly. 
- If everything looks good, edit the rsync task and remove the `--dry-run` entry by changing the `auxiliary parameters` to `-hv --password-file=/mnt/volume1/web/logging/syno.pw --log-file=/mnt/volume1/web/logging/syno_sync.log`
- Since we are just copying the data, once the copy process is done, delete the task, and create a new task with the same settings but for another shared folder on the Synology until all shared folders that need to be copied over are sucessfully copied. 

## 28.)  File Managers
<div id="File_Managers"></div>

Synology's File Manager is a fantastic app that is unfortunatyely missing from TrueNAS. I tried other apps like  <a href="https://filebrowser.org/">FileBrowser</a> but it did not support recycle bins and it did not show the active status of file copy and move activities like Synology File Manager. 

I wanted something that would show me the speed files were copying/moving and I wnated something that would show me the percent complete. I found <a href="https://mariushosting.com/synology-install-double-commander-with-portainer/">This Article</a> that talked about <a href="https://doublecmd.sourceforge.io/">DoubleCommander</a>.

This app does everything i was looking for. It has support for recycle bins, and shows the speed and progress of copy and move processes, and it allows you to CANCEL current active copy/move processes all in a nice web accessable GUI. 

I have my <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/blob/main/doublecommander/docker-compose.yaml">docker-compose.yaml</a> file available. Some notes on the configuration, i have 

```
cap_drop:     #removing the ability of the container to create outside network connections to block access to the internet
      - NET_RAW
      - NET_ADMIN
    dns:
      - "0.0.0.0"    #removing the ability of the container to resolve DNS connections to block access to the internet
    container_name: Double-Commander
```

to prevent the container from accessing any external network. since his app will have basically read/write access to my ENTIRE server basically, i want to make sure it has little to no ablity to phone home any informaiton. 
