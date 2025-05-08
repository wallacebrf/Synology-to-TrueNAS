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
  </ol>

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

PLEASE NOTE: I have never used Synology Photos, and I have never used Synology Drive. As such I am not going to be researching replacements for those apps. If someone wishes for me to figure out how to use a possible replacemrnt I can try. However since I have no experiance with Photos or Drive, I have no way of comparing functionality to determine if it is a viable replacement. With this said, it is my understanding that https://immich.app/ appears to be a viable replacement for Synology Photos. 

Please also note I have never used Apple products so I am not in a postion to suggest services that are compatible with Apple. If someone with Apple products has done things to ove from Synology to TrueNAS and i am not detailing that, please submit an issue request and I can work with you to add those details to this guide. 

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

The big thing to understand about TrueNAS and the ZFS file system that accompanies it, is that it will use un-used RAM space as a cache drive. This caching is doing the same thing a read only NVMA chache does on Synology. It will save commonly accessed files in the RAM cache so it does not need to read the data of the hard disks. ZFS calls this ARC or `Adaptive Replacement Cache`. This cache again is for reading data off the system, it does not help writting data to the drives. 

If your system is primarilly used for PLEX (I.E. large continuous file reads) then the ARC will not really help. ARC will help with things like loading PLEX and it's dashboard, art etc as those are small files and when browsing your PLEX libary frequrently are also read frequnetly and will be saved to ARC. 

You can use NVME drives in TrueNAS for caching in a direct similar method as Synology and that is referred to as L2ARC or 'Level 2 Adaptive Replacement Cache' and can assist with read performance if you perhaps do not have lots of RAM. 

Like Synology READ/WRITE cache TrueNAS can use write caching which uses `SLOG` space on separate NVME drives. 

The real question is what is the actual performance difference with using ARC, L2ARC, SLOG etc, and unfortunately that is not always easy to answer as it depends on your usage patterns. 

Many people moving from a Synology should be able to comfortably use TrueNAS with ZFS on systems with 32GB of RAM. The system will run fine, but may not possibly be atthe maximum performance it could otherwise acheive. 

More useful information can be found here <a href="https://www.45drives.com/community/articles/zfs-caching/">45 Drive ZFS Caching Discusion</a>

## 4.) Change TrueNAS GUI Port settings
<div id="Change_TrueNAS_GUI_Port_settings"></div>

This section is not required if you are not planning to host any web services on your TrueNAS lie one would do with Synology's "Web STation" package. I am planning to use the TrueNAS system to host my internal web pages and so I need to free up the ports 80 and 443 used by the TrueNAS GUI by default. Since i am moving from Synology I am already very used to using ports 5000 and 5001, so i decided to use those same ports with TrueNAS. 

- `System --> General Settings --> GUI --> Settings`
- Change Web Interface HTTP Port from 80 to 5000
- Change Web Interface HTTPS Port from 443 to 5001

## 5.) Security Measures To Lock Down Your NAS
<div id="Security_Measures_To_Lock_Down_Your_NAS"></div>

There have been plently of discussions and articles on how to secure a Synology NAS and a lot of them are applicable to TrueNAS like not using a root/admin account unless you need to, using Muilti-Factor-Authentication, not exposing the NAS directly to the internet, use proper passwords etc. 

This Youtube guide by Lawrence Syetems is very helpful and I have included some of the information below: <a href="https://www.youtube.com/watch?v=u0btB6IkkEk">Lawrence Systems - Hardening TrueNAS Scale: Security Measures To Lock Down Your NAS</a>

I performed the following actions on my system:

<ol>
<li>`System --> Advanced Settings --> Console --> Configure` and turn off `Show Text Console without Password Prompt`</li>
<ul>
<li>This as Tom indicates in his video locks down the HMI GUI available to prevent someone from changing configuration settings. <br>Obviously if you either do not use the video out of your NAS, or it is in a locked / secure area, this is not as required. I personally have my TrueNAS on a JetKVM, and so if someone were to somehow acess my KVM, they will at least then not be able to have access to my TrueNAS.</li>
</ul>
<br>
<li>Adjust auto-time out as desired. The default is 300 seconds</li>
<ul>
<li>`System --> Advanced Settings --> Access -> Configure`</li>
<li>I set mine to 1800 seconds (30 mins) which is probably longer than I should but I like extended log in times.</li>
</ul>
<br>
<li>Setup two factor authentication</li>
<ul>
<li>Under your user(s) click on the user name in the upper right and select `Two-Factor Authentication` and generate a QR code to use in an app like Microsoft Authenticator or your prerferred app. You will need to generate this QR code for all of the users who will need Web GUI access.</li>
<li>`System --> Advanced Settings --> Global Two Factor Authentication – Configure`</li>
<li>Turn on 2FA and set time window to 1. If using passwords for SSH, check the option to also use 2FA for SSH.</li>
</ul>
<br>
<li>Bind SSH to only certain ethernet port</li>
<ul>
<li>`System --> Services -> SSH` --> Click on the pencil edit icon on the right</li>
<li>Click advanced settings</li>
<li>Under `Bind Interfaces` choose the correct interface so only that interface will allow SSH</li>
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

I also suggest these two videos on creating your disk storage: <a href="https://www.youtube.com/watch?v=0d4_nvdZdOc">Lawrence Systems - ZFS 101: Leveraging Datasets and Zvols for Better Data Management</a> and <a href="https://www.youtube.com/watch?v=ykhaXo6m-04">Hardware Haven - Choosing The BEST Drive Layout For Your NAS</a>

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

NFS shares are not required unless you are sharing this TrueNAS system's data with other linux systems. I am doing so in the beginning to use the shares currently on my Synology units so I can expose PLEX to my movies and TV shows. If you do not need NFS shares, skip this section

Useful information: https://www.youtube.com/watch?v=mdHmcwWTNWA

For each share created for NFS, it is suggested to define the IP address of the host(s) that will connect to limit who can connect for added security 
1. Ensure NFS is turned on
- Go to `System --> Services` and ensure NFS is set to running and to sart automatically
2. create needed shares
- Go to `Shares --> UNIX (NFS) Shares --> Add'
- Path: Choose the correct path to the folder to share
- Description: add a description for the share
- if desired, the NFS shares can be limited to specific networks and specific host IP addresses for added security. configure as desired
- click save
3. repeat step 2 as needed for addtional shares

## 11.)  Create snapshots
<div id="Create_snapshots"></div>

Snapshots work the same with TrueNAS as they do with Synology as they can be restored if needed to recover data

To schedule snapshots:
1. go to `Data Protection -> Periodic Snapshot Tasks -> Add`
2. choose the desired data set
- Be aware that when restoring a data set, everyting under that data set is restored. So in this example, if I made a snapshot of the root /volume1 and restored it, i will loose anything in ALL child data sets made since that snap shot was made.
- Due to this, i would recommend to make scheduled snapshots for each separate data set to allow for flexibility in possible future data recovery. To assist with this, an option check box `recursive` is available when schedulign snapshots. 
- also be aware that on our SMB shares, by defualt the option `Enable Shaow Copies` is enabled. This allows windows users to use the `Previous Versions` feature to recover older copies of individual files and folders. This allows for granualr per-file recovery in an easy to use manner
3. Choose the amount of time the snap shot is retained
- this is accomplished using the `Snapshot Lifetime` and `Unit` options. I am choosing 1 week
4. I am leaving the naming process `Naming Schema` as the default of `auto-%Y-%m-%d_%H-%M`
5. Choose how often the snap shots are taken, the main options are Hourly, Daily, Weekly, Monthly. However custom options are also available. I am going with Daily.
6. I am leaving the `Allow Taking Empty Snapshot` option enabled
7. I am not excluding anything from my snapshots so i am leaving `Exclude` enpty

## 12.)  Install required Apps 
<div id="Install_required_Apps"></div>

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
- Click button `Apply permissions recursively`, agree to the confirmation popup
  - IF the desire is to have this app (Plex) be able to traverse ALL data sets inside the current data set, click the `Apply permissions to child data sets`. In this example we will NOT be doing that as we want PLEX to only have access to its data set we created under the apps data set.
- Click `Save Access Control List`
- We now need to give the app (PLEX) access to the data `PLEX` set under “apps” in this case the `/volume1/apps/plex` data set. Click on the plex data set and repeat steps above for that data set. However for the permissions set it to `Full Control` so the App (PLEX) can control it’s assigned app directory `/volume1/apps/plex`. <ins>For other data sets outside of the apps area</ins>, the default can be used, or limited to just read as desired.
- Repeat these steps for ANY and ALL other data sets you wish this particular app to access. In our example, we would also want to make sure plex had access to the `video` data set we created, and in this instance, we WOULD want to check the box `Apply permissions to child data sets` and the box `Apply permissions recursively`, to ensure plex can access all of the needed media files in the /volume1/video directory.

<div id="Frigate"></div>

3. **Frigate**
- Refer to additional details here: https://github.com/wallacebrf/Synology-to-TrueNAS/tree/main/frigate
- **TBD**

<div id="Grafana"></div>

4. Grafana

<div id="influxDB"></div>

5. influxDB

<div id="jackett"></div>

6. jackett

<div id="plex"></div>

7. plex

<div id="radar"></div>

8. radar

<div id="sickchill"></div>

9. sickchill

<div id="nginx_reverse_proxy"></div>

10. nginx reverse proxy
- https://www.youtube.com/watch?v=jx6T6lqX-QM

<div id="jellyfin"></div>

11. jellyfin

<div id="tautulli"></div>

12. tautulli

<div id="PhP_My_Admin"></div>

13. PhP My Admin

<div id="Chromium"></div>

14. Chromium

<div id="Portainer"></div>

15. Portainer

<div id="Torrent_downloader_VPN"></div>

16. Torrent downloader + VPN
- very useful step by step guide on using GlueTUN for docker app VPN tunnels: https://www.youtube.com/watch?v=TJ28PETdlGE

<div id="ngninx_PHP_Maria_DB_Stack"></div>

17. ngninx + PHP + Maria DB Stack (replaces web station)

<div id="DIUN"></div>

18. DIUN – Docker Image Update Notifier

<div id="TrueCommand"></div>

19. TrueCommand

<div id="Veeam"></div>

20. Veeam *[Replaces Active Backup for Business]*

<div id="Grey_log"></div>

21. Grey log	
- https://www.youtube.com/watch?v=PoP9BTktlFc
- https://www.youtube.com/watch?v=DwYwrADwCmg


## 13.)  Data Logging Exporting to Influx DB v2  
<div id="Data_Logging_Exporting_to_Influx_DB_v2"></div>

1. Setup TrueNAS exporter under `Reporting --> Exporters`
- **Name**: netdata
- **Type**: Graphite
- **Destination IP**: 192.168.1.8 (TrueNAS System IP)
- **Destination Port**: 9109
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
  - **Timezone**: 'America/Chicago' timezone
  - **Environment Variables**: No items have been added yet.
  - **Restart Policy**: Unless Stopped - Restarts the container irrespective of the exit code but stops restarting when the service is stopped or removed.
  - **Disable Builtin Healthcheck**: unchecked
  - **TTY**: unchecked
  - **Stdin**: unchecked
  - **Devices**: No items have been added yet.
  - **Security Context Configuration Privileged**: unchecked
  - **Capabilities add**: No items have been added yet.
  - **Custom User**: checked
  - **User ID**: 568
  - **Group ID**: 568
  - **Network Configuration Host Network**: unchecked
  - **Ports**:
    - Add #1:
      - Container Port: 9109
      - Host Port: 9109
      - Protocol: TCP
    - Add #2:
      - Container Port: 9108
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
    - Enable it, choose 2 CPUs and 2048 MB of memory. Leave `Passthrough available (non-NVIDIA) GPUs` unchecked
3. InfluxDB Scrapper Configuration
- Open a new browser window and browse to `http://<server-IP>:9108`
- On the page titled `Graphite Exporter` click on the “metrics” link
- There should be a ton of text displayed showing the last set of data received from TrueNAS
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

## 15.)  Setup Grafana Dashboard for TrueNAS
<div id="Setup_Grafana_Dashboard_for_TrueNAS"></div>

## 16.)  Setup Web site Details
<div id="Setup_Web_site_Details"></div>

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

