# Frigate
How I have (Currently) Installed Frigate

<div id="top"></div>
<!-- TABLE OF CONTENTS -->
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#About_the_project_Details">About The Project</a> 
   </li>
	<li><a href="#Frigate_Configuration">Frigate Configuration YAML file</a> </li>
	<li><a href="#rueNAS_Frigate_App_Setings">TrueNAS Frigate App Setings</a> </li>
	 <li><a href="#frigate_metrics_export">Frigate Metrics Export</a> </li>
  </ol>

<!-- ABOUT THE PROJECT -->
## 1.) About the project Details
<div id="About_the_project_Details"></div>

I have been using Synology Surrveilance Station (Referred here on out as SSS) since 2019. Prior to that i had been using a SWANN 8x camera system with 4k cameras. I kept the cameras but simply replaced the NVR with the DVA3219 and i have been very happy since. 

If I was going to move away from Synology, then would need to find a good replacement for SSS. I looked into various options like Blue Iris but that only runs on windows. I also looked into Zoneminder and Frigate and really liked what i was seeing with Frigate. 

With my DVA3219 and the NVidia graphics card inside it I have currently been utilizing its 4x max concurrent "dep video analsysis" features to perform person, vehicle and object detetion, which has been working well. What has really made me appreciate Frigate is that i can do the same object detection and MORE on ALL of my 12x cameras while also using LESS wattage on my electricity bill. 

To acheive this I am using a single Google Coral Tensor Processor Unit (TPU) and iGPU passthrough from my Core i7-8700T CPU in my test Dell Micro PC to the container to perform all of the analsys on 12x cameras at the same time. The TPU uses less than 5 watts, and the iGPU is only being loaded to 4-ish percent and the CPU was loaded to around 20%. This is compared to the DVA3219 which loads by CPU to arond 50%, loads the GPU to around 90%. 

I used a kilo-watt meter to get a good understanding of the power draw on the Dell micro PC when Frigate was ON and when it was OFF and the power usage difference was around 18 watts. I did the same comparison on the DVA3219 and the power diffrential when SSS is ON vs OFF was about 75 watts. That is a huge difference in 24/7 on-going power draw and yet Frigate is doing even more analsysis!!. 

something of note: Frigate does NOT use any of the detections built into cameras, it only performs all processing and detections/triggers internally using your CPU, GPU, TPU etc. This means if you have really fancy AI cameras that can natively perform people, object, motion detection etc, those features cannot be leaveraged by Frigate. Persoanlly after using Frigate, i think Frigate does a better job anyways but your milage may vary. 

another thing to note: when looking at the Frigate web GUI live stream page showing multiple cameras, the video wil NOT be 100% live. The video will only "activate" when there is actively detected motion, alerts, or detections. Then the video will show the live stream and as soon as the event(s) are over the video will "pause". This was initially confusing for me as SSS will show the live stream at all times when looking at all the cameras to gether. 

## 2.) Frigate Configuration
<div id="Frigate_Configuration"></div>

Definately something that will take getting used to when moving from SSS to Frigate is that Frigate does require text based configuration. Luckilly the configuration details are documented VERY well and are easy to understand here https://docs.frigate.video/, but it still takes time to read through and understand everything. Some people might not be comfortable with this which is totally understandable. 

I have supplied my configuration file for my Frigate Installation <a href="https://github.com/wallacebrf/Synology-to-TrueNAS/blob/main/frigate/config.yaml">Here</a> and i will be doing a basic breakdown on why I did what i did. I am not going to be going into sigificant detail on what each section of the config is doing as that is aleady available in Frigate's documentation. 

1.) MQTT
  - I have MQTT off as i am NOT using any MQTT services like home assistant.

2.) detectors:
  - This is where one defines what is going to be used for object detection proessing. As i said before i have a Google Coral TPU going through <a href="https://www.amazon.com/dp/B0CDGT75SH">USB</a> and I need to tell Frigate to use it. For the USB version of Coral, no drivers are needed as they are included, but Coral TPUs are available in M.2 and PCIe versions and those need drivers, so i went the lazy route and used the USB version, even though it is twice the cost of the other versions. 

2.) tls
  - This controlls if the Frigate web GUI uses HTTP or HTTPS, i went with HTTPS. 

3.) auth
  - leave the `reset_admin_password` set to false UNLESS you need to reset your password for some reason. 
    - NOTE: when frigate first starts up, it will auto generate a password on its own. You can access that generated password using Frigate's logs.
    - The logs for Frigate can be access by going to the `apps` page, click on your Frigate app after starting it (will get to that soon), scroll down on the right side and click on the `view Logs ` button  <img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/images/container_shell_and_logs.png" alt="container_shell_and_logs.png">.
  - `failed_login_rate_limit` i set to help limit the number of failed log in attempt Frigate will allow

4.) audio
  - Seeing has how all of my cameras do not support audio, i just disabled it system wide.

4.) birdseye
  - as of 5/10/2025 i have NOT actually messed wiht this functionality of Frigate, but i beleive this will do what i want, but until i complete my testing etc and know my config is good, i will be skpping the explaination for this section for now. 

4.) ffmpeg
  - Frigate uses ffmpeg to perform all of the video processing.
  - since in this test system using the Dell micro PC, i am using the iGPU, i passed through the driver for it `preset-vaapi`
  - input_args is set to `preset-rtsp-generic` as i do not need to process audio.
  - output_args are set to their default settings, i just had them in the config incase i needed to adjust them

4.) detect
  - fps are limited to only 5 frame per second being sent to the Coral TPU, but that is enough for it to do its job. Having this too high requires more processing and therefore more wattage.
  - enabled -> by default this needs to be disabled until you know your cameras are working, after you get your cameras working, then you can come back and set this to enabled.
  - stationary is left at the default values for now

4.) objects
  - these are all of the object types that i wish Frigate to tag my videos with.
  - Frigate is free to use, however they offer Frigate+ (which i have not used as of 5/10/25) that costs $50 per year, but allows for custom trained models on your cameras and what they see to cut down on false positives. It also enables a LOT more types of detections down to birds, squirrels, even logos on delivery vehicles. I do plan on tinkering with Frigate + but i want to wait until i build my final system so i know what kind of hardware i am using. 

4.) motion
  - This enables plain motion detection
  - enabled --> when you first start, set this to disabled until you have all of your cameras working and sending video to Frigate. After they are workig come back and enable this.
  - threshold --> i set this to 100 as (at least for me) i am getting the detections i want, but am getting fewer flase postives. Again this may be different for your setup. To start i suggest using the default values.
  - lightning_threshold i kept at the default value
  - contour_area i set a little higher to reduce false positives

4.) record:
  - NOTE: unlike SSS which can delete video after a user defined amount of disk space is used, Frigate will do one of two things, either it will fill the disks to 100% and then start deleting olf videos, or it will be limited to a certain number of days of record. My test system only has 256GB of disk space to work with so i cannot record much 4k video. as such i ave realy small numbers here. Please adjust to match your needs.
  - enabled --> like other areas, i suggest leaving this disabled until you have all of your camera feeds working in Frigate then come back and enable it
  - sync_recordings --> if you are manaully deleting files, you may need to enable this feature so Frigate can discover the files are mssing, but this does use more processing power. I am letting Frigate handle everything so i am leaving it disabled
  - retain -> I have this set to ALL. I plan to set this to around 1 day so that if i have a triggered event and it failed to record the entire event, i have at least 24 hours of ALL video recorded so i can rewind etc. This does take up a lot of disk spoace when using 12x 4k cameras at 20FPS. once i am using my final 4x 8TB raid5 array i will have to experiment with settings to get the best retention time and staying below 90% disk usage.
  - export --> i thought this would be liks SSS time lapse, but as of 5/10/25 i have not confirmed if this is working
  - alerts --> I have this set to `active_objects` so that i will get alerts when according to my `objects` settings when people vehicles etc are detected. I have configured the alerts to save 15 seconds before and after the event is over and currently only retaining 0.05 days of time again since i am limited to my 256GB disk.
  - detections i have set to motion, so that if anything not detected by the alerts will still be recorded as well.

4.) snapshots
  - I configured this to take a photo of what caused a trigger so it can be quick and easy to see what caused the trigger.

4.) go2rtc
  - This is where i configured my camera details. I have two video feeds per camera, the main stream which in my case is the 4k video at 20FPS, and the secondary stream used for liek view and processing that is limited to a much smaller resolution. This is probably the HARDEST part of using Frigate. In SSS you had MANY MANY pre-built camera options where SSS just knew how to talk to the camera whcih made setup so simple. With Frigate you need to figure out on your own how to get to your camera's video streams as they are NOT the same with every camera. I am lucky that my SWANN 4k cameras ae just rebranded hikvision casmeras (knew this from looking at the web interface of the cameras) so i was able to google hikvision camera details. Frigate does document the default stream details for several major camera types, but it is not guaranteed your cameras will be easy to figure out.
  - please note how each camers (we will use `FRONT LEFT CANMERA`) has a `front_left` and a `front_left_sub`. The text `front_left` is what Frigate will display as the camera's name in its Web GUI. the substream needs to be the same name, just with `_sub` added to the end.

4.) cameras
  - This is where we define the detals of each camera. we will continue to use the `FRONT LEFT CANMERA` as an example in this explination.
  - what ever name you gave the camera in the `go2rtc` section MUST be the same here, in this case `front_left`.
  - to ensure the camera is available, ensure the camera is enabled  `enabled: true`
  - webui_url is just a quick link to the web GUI of the camera
  - ffmpeg --> inputs --> path. If you notice the url of the camera is  `rtsp://127.0.0.1:8554/front_left`. The `rtsp://127.0.0.1:8554` is the interal localhost address of the Frigate container and port `8554` is what Frigate will use to talk to itself to process the cameras. the name of the camera MUST continue to match, which in this case is `front_left`
  - roles: if you notice, the stream that just says `front_left` which is our RAW 4k 20 FPS video stream is set to `record` while the `front_left_sub` is set to a role of `detect`. This allows us to record the full resolution, while only using the lower resolution feed to perform processing of detections and alerts to save on processing power.
  - detect is set to true so it will perform detections, but i can turn that off and on per camera here
  - the `width` and `height` match the video resolution of the sub stream configured in my camera's web GUI
  - zones: this is an area that is configured through the Frigate web-GUI so do not worry about this for now
  - motion: this is an area that is configured through the Frigate web-GUI so do not worry about this for now
  - review: this is an area that is configured through the Frigate web-GUI so do not worry about this for now
  - record: leave this disabled until your camera streams are working, then come back and enable it
  - live: this controls what video stream is available through the Frigate Web GUI when viewing live video. I have it set to the low resolution sub stream so when i am using my phone etc, i am not tring to send the full 4k video through. In SSS we were able to switch between main streams and sub streams on the fly in the SSS GUI, unfortunately that is not supported by Frigate.
  - ui: this controls what order the cameras are displayed in the Frigate web GUI. I wanted this camera to be first so it starts at `0`

4.) camera_groups
  - This allows you to create groups of cameras where each group will be a separate button on the Frigate web GUI so you can see ONLY the cameras assigned to that group rather than all cameras at the same time. 

## 2.) TrueNAS Frigate App Setings
<div id="rueNAS_Frigate_App_Setings"></div>

Frigate installed through the TrueNAS "app store" does not support changing the user or group details, and instead the Frigate app will simply be instaled under the "apps" user and group. 

Create new data set for Frigate Confuration files `/mnt/volume1/apps/frigate`

<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/frigate/images/frigate_create_dataset.png" alt="Create new data set">

Create new data set for Frigate recorded files `/mnt/volume1/surveillance`

<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/frigate/images/frigate_making_surveillance.png" alt="Create surveillance">

Set ACL for Frigate recorded files `/mnt/volume1/surveillance`

<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/frigate/images/surveillance_acl_setting.png" alt="surveillance ACL">

Frigate App Config During Install in TrueNAS "Apps" page

<img src="https://raw.githubusercontent.com/wallacebrf/Synology-to-TrueNAS/refs/heads/main/frigate/images/frigate_config.png" alt="frigate config settings">

## 1.) Frigate Metrics Export
<div id="frigate_metrics_export"></div>

As of 5/10/25 Frigate 0.15.1 does show available stats at https://<server-ip>:<port>/api/stats however it is not in a format things like prometheus can scrape. 

There is a docker container that is supposed to export data into a format compatable with Prometheus however it does not seem to be working for me. https://github.com/bairhys/prometheus-frigate-exporter

with that said, it appears based on discussion here https://github.com/blakeblackshear/frigate/issues/2266 that Frigate version 0.16 will natevely support Prometheus formatted data exporting. In addtion it appears there is already some documentation showing how it will be formatted here https://github.com/blakeblackshear/frigate/blob/dev/docs/docs/configuration/metrics.md


## 2.) Intel Arc 380 support
https://www.reddit.com/r/frigate_nvr/comments/1f7yi9o/frigate_with_openvino_on_intel_arc_a380/?rdt=44320

```
detectors:
  ov:
    type: openvino
    device: GPU
model:
  width: 300
  height: 300
  input_tensor: nhwc
  input_pixel_format: bgr
  path: /openvino-model/ssdlite_mobilenet_v2.xml
  labelmap_path: /openvino-model/coco_91cl_bkgr.txt
```

https://docs.frigate.video/frigate/hardware/ --> Intel Arc A380 supported
https://docs.frigate.video/configuration/object_detectors#openvino-detector --> SSDLite MobileNet v2
https://github.com/blakeblackshear/frigate/discussions/16156 --> good discussions of suggested resolutions
https://www.reddit.com/r/frigate_nvr/comments/1f7yi9o/frigate_with_openvino_on_intel_arc_a380/?rdt=44320
