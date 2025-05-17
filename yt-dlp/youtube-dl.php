<?php


//********************************
//USER VARIABLES
//********************************
$form_submit_location="index.php?page=13";			#the form submit location. NOTE: i have this .PHP file included within another PHP file "index.php" which is why the form submit location shows "index.php?page=13". If running this PHP file standalone, change this value to the name of the PHP file.
#include_once 'header_yt_dlp.php';					#note, as previously indicated i am running this PHP file through another file which is handling the header details for me. If running this PHP stand alone, uncomment this line to allow proper formatting
$youtube_folder_location="/var/www/html/youtube";   #this is the directory within the PHP docker container NOT the TrueNAS operating system
$page_title="Youtube-dlp --> Video/Audio Downloader";
$web_url_to_youtube_directory="http://192.168.1.8/youtube"; #replace with your TrueNAS IP or replace with your TrueNAS domain name
$use_sessions=false; #use log in sessions?

//********************************
//Code Start
//********************************
if($use_sessions){
	if($_SERVER['HTTPS']!="on") {

	$redirect= "https://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];

	header("Location:$redirect"); } 

	// Initialize the session
	if(session_status() !== PHP_SESSION_ACTIVE) session_start();
	// Check if the user is logged in, if not then redirect him to login page
	$current_time=time();

	if(!isset($_SESSION["session_start_time"])){
		$expire_time=$current_time-60;
	}else{
		$expire_time=$_SESSION["session_start_time"]+3600; #un-refreshed session will only be good for 1 hour
	}


	// Check if the user is logged in, if not then redirect him to login page
	if(!isset($_SESSION["loggedin"]) || $_SESSION["loggedin"] !== true || $current_time > $expire_time || !isset($_SESSION["session_user_id"])){
		// Unset all of the session variables
		$_SESSION = array();
		// Destroy the session.
		session_destroy();
		header("location: login.php");
		exit;
	}else{
		$_SESSION["session_start_time"]=$current_time; //refresh session start time
	}
}
#error_reporting(E_ALL ^ E_NOTICE);
include $_SERVER['DOCUMENT_ROOT']."/functions.php";
$playlist_start_error=0;
$playlist_end_error=0;		
$playlist_items_error=0;		
$max_downloads_error=0;		
$postprocessor_args_error=0;
$video_file_error=0;
$username_error=0;
$password_error=0;
$auth_error=0;
$generic_error="";

		/***************************************
		Delete an already downloaded file?
		/**************************************/
		if(isset($_POST['delete_files_submit'])){
			[$delete_file, $generic_error] = test_input_processing($_POST['delete_file'], "", "file", 0, 0);
			if($generic_error=="" AND $delete_file!=""){
				if(file_exists("".$_SERVER['DOCUMENT_ROOT']."/youtube/".$delete_file."")){
					unlink(RemoveSpecialChar_directory("".$_SERVER['DOCUMENT_ROOT']."/youtube/".$delete_file.""));
				}
			}
		}
		
		
		/***************************************
		Delete a log file?
		/**************************************/
		if(isset($_POST['delete_log_files_submit'])){
			[$delete_log_file, $generic_error] = test_input_processing($_POST['delete_log_file'], "", "file", 0, 0);
			if($generic_error=="" AND $delete_log_file!=""){	
				if(file_exists("".$_SERVER['DOCUMENT_ROOT']."/youtube/log/".$delete_file."")){
					unlink(RemoveSpecialChar_directory("".$_SERVER['DOCUMENT_ROOT']."/youtube/log/".$delete_log_file.""));
				}
			}
		}
		
		
		
		/*******************************************************************************************************************
		Begin Downloading a video/audio?
		begin processing all of the submitted form data to determine what command parameters to send to youtibe-dl
		/******************************************************************************************************************/
		if(isset($_POST['submit'])){
		   
		   
		    /***************************************
			Does the user want to save the audio from the video into a separate file?
			/**************************************/
			if (($_POST['extract_audio']) != "-x"){
				$extract_audio="";
			}else{
			   $extract_audio="-x";
			}
		   
		   
			/***************************************
			Does the user want to keep either partial files, or the video file after the audio is exacted?
			by default if the audio is extracted, the video and part files are deleted
			/**************************************/
			if (($_POST['extract_audio_keep_video'])== "-k"){
				$extract_audio_keep_video="-k";
			}else{
			   $extract_audio_keep_video="";
			}
		   
		   
			/***************************************
			what audio format should any extracted audio be saved as?
			the result of this statement will only output if the user has also enabled audio extraction. 
			if audio extraction is not called for, the format parameter is left blank
			/**************************************/
			if ($_POST['audio_format']=="--audio-format aac" OR $_POST['audio_format']=="--audio-format flac" OR $_POST['audio_format']=="--audio-format mp3" OR $_POST['audio_format']=="--audio-format m4a" OR $_POST['audio_format']=="--audio-format best" OR $_POST['audio_format']=="--audio-format opus" OR $_POST['audio_format']=="--audio-format vorbis" OR $_POST['audio_format']=="--audio-format wav"){
				if ($extract_audio=="-x"){
					$audio_format=$_POST['audio_format'];
				}else{
					$audio_format="";
				}
			}else{
				$audio_format="";
			}
		   
		   
		   /***************************************
			what audio quality level should any extracted audio be saved as?
			the result of this statement will only output if the user has also enabled audio extraction. 
			if audio extraction is not called for, the quality parameter is left blank
			/**************************************/
			if ($_POST['audio_quality']=="--audio-quality 0" OR $_POST['audio_quality']=="--audio-quality 1" OR $_POST['audio_quality']=="--audio-quality 2" OR $_POST['audio_quality']=="--audio-quality 3" OR $_POST['audio_quality']=="--audio-quality 4" OR $_POST['audio_quality']=="--audio-quality 5" OR $_POST['audio_quality']=="--audio-quality 6" OR $_POST['audio_quality']=="--audio-quality 7" OR $_POST['audio_quality']=="--audio-quality 8" OR $_POST['audio_quality']=="--audio-quality 9" AND $extract_audio=="-x"){
				if ($extract_audio=="-x"){
					$audio_quality=$_POST['audio_quality'];
				}else{
					$audio_quality="";
				}
			}else{
			   $audio_quality="";
			}
			
			
			/***************************************
			Should any errors be ignored?
			by default errors will be ignored. this is especially important for play lists encase one or more videos are unable to be downloaded
			at least all other videos will be downloaded 
			/**************************************/
			if (($_POST['ignore_errors'])=="--ignore-errors" OR $_POST['ignore_errors']=="--abort-on-error"){
				$ignore_errors=$_POST['ignore_errors'];
			}else{
			   $ignore_errors="";
			}
		   
		   
		   /***************************************
			should youtube-dl display the user agent information?
			this is only visible if the log file is viewed 
			/**************************************/
			if (($_POST['dump_user_agent'])=="--dump-user-agent"){
				$dump_user_agent="--dump-user-agent";
			}else{
			   $dump_user_agent="";
			}
		   
			/***************************************
			should youtube-dl list the possible extractor operations?
			this is only visible if the log file is viewed 
			/**************************************/
			if (($_POST['list_extractors'])=="--list-extractors"){
				$list_extractors="--list-extractors";
			}else{
			   $list_extractors="";
			}
			
			
			/***************************************
			should youtube-dl list the possible extractor descriptions?
			this is only visible if the log file is viewed 
			/**************************************/
		   
			if (($_POST['extractor_descriptions'])=="--extractor-descriptions"){
				$extractor_descriptions="--extractor-descriptions";
			}else{
			   $extractor_descriptions="";
			}
			
			
			/***************************************
			should youtube-dl use a generic extractor even if a better option is available?
			/**************************************/
		   
			if (($_POST['force_generic_extractor'])=="--force-generic-extractor"){
				$force_generic_extractor="--force-generic-extractor";
			}else{
			   $force_generic_extractor="";
			}
		   
		   
			/***************************************
			should youtube-dl list just list the videos in a play list and not actually download them?
			this is only visible if the log file is viewed 
			/**************************************/
			if (($_POST['flat_playlist'])=="--flat-playlist"){
				$flat_playlist="--flat-playlist";
			}else{
			   $flat_playlist="";
			}
			
			
			/***************************************
			should the video(s) downloaded be marked "as watched"?
			/**************************************/
			if (($_POST['mark_watched'])=="--no-mark-watched" OR $_POST['mark_watched']=="--mark-watched"){
				$mark_watched=$_POST['mark_watched'];
			}else{
			   $mark_watched="";
			}
			
			
			/***************************************
			should youtube-dl download all videos in a play list or only the single video?
			/**************************************/
			if (($_POST['process_playlists'])=="--no-playlist" OR ($_POST['process_playlists'])=="--yes-playlist"){
				$process_playlists=$_POST['process_playlists'];
			}else{
				$process_playlists="";
			}
			
			
			/***************************************
			is the user choosing specific videos off a play list to download? 
			/**************************************/
			if (($_POST['process_playlists'])=="--yes-playlist") {
				if (($_POST['playlist_items_enable'])=="--playlist-items"){
					if (!empty($_POST['playlist_items'])){
						$playlist_items_enable="--playlist-items";
						[$playlist_items, $generic_error] = test_input_processing($_POST['playlist_items'], "", "name", 0, 1);
					}else{
					  $playlist_items_enable="";
					  $playlist_items="";
					  $playlist_items_error=1;
					}
				}else{
				   $playlist_items_enable="";
				   $playlist_items="";
				}
			}
	      
		  
			/***************************************
			this parameter will only be processed if play list processing is activated 
			this will also only be processed if the "playlist items" choice is not being used. as the playlist items option lets the user more fine control which videos to download, it superceeds this option
			if play list processing is enabled, then this will control which video on the play list to start with
			/**************************************/
			if (($_POST['playlist_items_enable'])!="--playlist-items"){
				if (($_POST['process_playlists'])=="--yes-playlist"){
					if (($_POST['playlist_start_enable'])=="--playlist-start"){
						if (filter_var($_POST['playlist_start'], FILTER_SANITIZE_NUMBER_INT)>0 AND filter_var($_POST['playlist_start'], FILTER_SANITIZE_NUMBER_INT)!=""){
							$playlist_start_enable="--playlist-start";
							[$playlist_start, $generic_error] = test_input_processing($_POST['playlist_start'], "", "numeric", 0, 10000);
						}else{
						  $playlist_start_enable="";
						  $playlist_start="";
						  $playlist_start_error=1;
						}
					}else{
					   $playlist_start_enable="";
					   $playlist_start="";
					}
				}
			}
		   
		   
			/***************************************
			this parameter will only be processed if play list processing is activated 
			this will also only be processed if the "playlist items" choice is not being used. as the playlist items option lets the user more fine control which videos to download, it superceeds this option
			if play list processing is enabled, then this will control which video on the play list to end at
			/**************************************/
			if (($_POST['playlist_items_enable'])!="--playlist-items"){
				if (($_POST['process_playlists'])=="--yes-playlist"){
					if (($_POST['playlist_end_enbale'])=="--playlist-end"){
						if (filter_var($_POST['playlist_end'], FILTER_SANITIZE_NUMBER_INT)>0 AND filter_var($_POST['playlist_end'], FILTER_SANITIZE_NUMBER_INT)!=""){
							$playlist_end_enbale="--playlist-end";
							[$playlist_end, $generic_error] = test_input_processing($_POST['playlist_end'], "", "numeric", 0, 10000);
						}else{
						  $playlist_end_enbale="";
						  $playlist_end="";
						  $playlist_end_error=1;
						}
					}else{
					   $playlist_end_enbale="";
					   $playlist_end="";
					}
				}
			}
		  
		  
		  
		   /***************************************
			this parameter will only be processed if play list processing is activated 
			this will also only be processed if the "playlist items" choice is not being used. as the playlist items option lets the user more fine control which videos to download, it superceeds this option
			if play list processing is enabled, then this will control the total number of videos to download
			/**************************************/
			if (($_POST['playlist_items_enable'])!="--playlist-items"){
				if (($_POST['max_downloads_enable'])=="--max-downloads"){
					if (filter_var($_POST['max_downloads'], FILTER_SANITIZE_NUMBER_INT) AND !empty($_POST['max_downloads'])){
						$max_downloads_enable="--max-downloads";
						[$max_downloads, $generic_error] = test_input_processing($_POST['max_downloads'], "", "numeric", 0, 10000);
					}else{
					  $max_downloads_enable="";
					  $max_downloads="";
					  $max_downloads_error=1;
					}
				}else{
				   $max_downloads_enable="";
				   $max_downloads="";
				}
			}
		   
		   
		   /***************************************
			this parameter will only be processed if extracting of audio is enabled
			this allows the user to set a start and end time of the video file where the audio will be extradited from
			this is needed if a music video has any intros or end credits that are not wanted in the audio file
			/**************************************/
			if (($_POST['postprocessor_args'])=="--postprocessor-args" AND $extract_audio=="-x"){
				if (filter_var($_POST['audio_start_hour'], FILTER_SANITIZE_NUMBER_INT) >=0 AND filter_var($_POST['audio_start_hour'], FILTER_SANITIZE_NUMBER_INT) <=100 AND filter_var($_POST['audio_start_hour'], FILTER_SANITIZE_NUMBER_INT)!=""){
					if (filter_var($_POST['audio_start_min'], FILTER_SANITIZE_NUMBER_INT) >=0 AND filter_var($_POST['audio_start_min'], FILTER_SANITIZE_NUMBER_INT) <=59 AND filter_var($_POST['audio_start_min'], FILTER_SANITIZE_NUMBER_INT)!=""){
						if (filter_var($_POST['audio_start_second'],FILTER_SANITIZE_NUMBER_INT) >=0 AND filter_var($_POST['audio_start_second'],FILTER_SANITIZE_NUMBER_INT) <=59 AND filter_var($_POST['audio_start_second'],FILTER_SANITIZE_NUMBER_INT)!=""){
							if (filter_var($_POST['audio_end_hour'],FILTER_SANITIZE_NUMBER_INT) >=0 AND filter_var($_POST['audio_end_hour'],FILTER_SANITIZE_NUMBER_INT) <=100 AND filter_var($_POST['audio_end_hour'],FILTER_SANITIZE_NUMBER_INT)!=""){
								if (filter_var($_POST['audio_end_min'],FILTER_SANITIZE_NUMBER_INT) >=0 AND filter_var($_POST['audio_end_min'],FILTER_SANITIZE_NUMBER_INT) <=59 AND filter_var($_POST['audio_end_min'],FILTER_SANITIZE_NUMBER_INT)!=""){
									if (filter_var($_POST['audio_end_second'],FILTER_SANITIZE_NUMBER_INT) >=0 AND filter_var($_POST['audio_end_second'],FILTER_SANITIZE_NUMBER_INT) <=59 AND filter_var($_POST['audio_end_second'],FILTER_SANITIZE_NUMBER_INT)!=""){
									   
									   //set the variables if all verification pass
									   $postprocessor_args="--postprocessor-args \"-ss ".filter_var($_POST['audio_start_hour'],FILTER_SANITIZE_NUMBER_INT).":".filter_var($_POST['audio_start_min'],FILTER_SANITIZE_NUMBER_INT).":".filter_var($_POST['audio_start_second'],FILTER_SANITIZE_NUMBER_INT)." -to ".filter_var($_POST['audio_end_hour'],FILTER_SANITIZE_NUMBER_INT).":".filter_var($_POST['audio_end_min'],FILTER_SANITIZE_NUMBER_INT).":".filter_var($_POST['audio_end_second'],FILTER_SANITIZE_NUMBER_INT)."\"";
									   $postprocessor_args_error=0;
									}else{
									   $postprocessor_args_error=7;
									   $postprocessor_args="";
									}
							    }else{
								   $postprocessor_args_error=6;
								   $postprocessor_args="";
								}
						    }else{
							   $postprocessor_args_error=5;
							   $postprocessor_args="";
							}
					    }else{
						   $postprocessor_args_error=4;
							$postprocessor_args="";
						}
				    }else{
					   $postprocessor_args_error=3;
						$postprocessor_args="";
					}
			    }else{
				   $postprocessor_args_error=2;
				   $postprocessor_args="";
				}
			}else{
			   $postprocessor_args="";
			}
		    
		
			/***************************************
			process the video file URL
			/**************************************/
			if (filter_var($_POST['video_file'], FILTER_VALIDATE_URL)){
				[$video_file, $generic_error] = test_input_processing($_POST['video_file'], "", "url", 0, 0);
			}else{
				$video_file_error=1;
				$video_file="";
			}
			
			
			
			/***************************************
			does the user wish to see the command this PHP script generates and sends to youtube-dl?
			/**************************************/
			if (($_POST['show_command'])==1){
				$show_command=1;
			}else{
				$show_command=0;
			}
			
			
			/***************************************
			should youtube-dl overwrite any already existing files?
			/**************************************/
			if (($_POST['no_overwrites'])=="--no-overwrites"){
				$no_overwrites="--no-overwrites";
			}else{
				$no_overwrites="";
			}
			
			
			/***************************************
			should youtube-dl resume any downlaods if they initially fail?
			/**************************************/
			if (($_POST['resume_download'])=="--continue" OR ($_POST['resume_download'])=="--no-continue"){
				$resume_download=$_POST['resume_download'];
			}else{
				$resume_download="";
			}
			
			
			/***************************************
			should youtube-dl write directly to the final file, or utilize part files and merge them together at the end?
			/**************************************/
			if (($_POST['no_part'])=="--no-part"){
				$no_part="--no-part";
			}else{
				$no_part="";
			}
			
			
			/***************************************
			should youtube-dl use mtime or not?
			/**************************************/
			if (($_POST['no_mtime'])=="--no-mtime"){
				$no_mtime="--no-mtime";
			}else{
				$no_mtime="";
			}
			
			
			/***************************************
			should youtube-dl save the video description information to a file?
			/**************************************/
			if (($_POST['write_discriptions'])=="--write-description"){
				$write_discriptions="--write-description";
			}else{
				$write_discriptions="";
			}
			
			
			/***************************************
			should youtube-dl save the video information to a file?
			/**************************************/
			if (($_POST['write_info_json'])=="--write-info-json"){
				$write_info_json="--write-info-json";
			}else{
				$write_info_json="";
			}
			
			
			/***************************************
			should youtube-dl save any annotations of the video to a file?
			/**************************************/
			if (($_POST['write_annotations'])=="--write-annotations"){
				$write_annotations="--write-annotations";
			}else{
				$write_annotations="";
			}
			
			
			/***************************************
			should youtube-dl save any thumbnails of the video?
			/**************************************/
			if (($_POST['write_thumbnail'])=="--write-thumbnail" OR ($_POST['write_thumbnail'])=="" OR ($_POST['write_thumbnail'])=="--write-all-thumbnails" OR ($_POST['write_thumbnail'])=="--list-thumbnails"){
				$write_thumbnail=$_POST['write_thumbnail'];
			}else{
				$write_thumbnail="";
			}
			
			
			/***************************************
			should youtube-dl output details in verbose mode?
			by default it does not
			this output will only be visible if the log file(s) are viewed. 
			/**************************************/
			if (($_POST['verbose'])=="--verbose"){
				$verbose="--verbose";
			}else{
				$verbose="";
			}
			
			
			/***************************************
			should youtube-dl save any of the subtitle information to a file?
			/**************************************/
			if (($_POST['write_sub'])=="" OR ($_POST['write_sub'])=="--write-sub" OR ($_POST['write_sub'])=="--write-auto-sub" OR ($_POST['write_sub'])=="--all-subs" OR ($_POST['write_sub'])=="--list-subs"){
				$write_sub=$_POST['write_sub'];
			}else{
				$write_sub="";
			}


			/***************************************
			is the video and or play list behind a user account? 
			if it is, youtube-dl will need the username and password. 
			/**************************************/
			if (($_POST['need_auth'])==1){
				if(filter_var($_POST['username'], FILTER_SANITIZE_STRING)!=""){
					[$username, $sensor_location_error] = test_input_processing($_POST['username'], "", "name", 0, 0);
					$username="--username ".$username."";
				}else{
					$username="";
					$username_error=1;
				}
				if(filter_var($_POST['password'], FILTER_SANITIZE_STRING)!=""){
					[$password, $sensor_location_error] = test_input_processing($_POST['password'], "", "password", 0, 0);
					$password="--password ".$password."";
				}else{
					$password="";
					$password_error=1;
				}
				
				if(filter_var($_POST['two_f_auth_code'], FILTER_SANITIZE_STRING)==""){
					$two_f_auth_code="";
				}else{
					[$two_f_auth_code, $sensor_location_error] = test_input_processing($_POST['two_f_auth_code'], "", "password", 0, 0);
					$two_f_auth_code="--twofactor ".$two_f_auth_code."";
				}
			}else{
				$username="";
				$username_error=0;
				$password="";
				$password_error=0;
				$two_f_auth_code="";
			}
			
			
			
			/***************************************
			we have finished processing all of the submitted form data
			
			we now know how to structure the command to be send to youtube-dl
			/**************************************/


			/***************************************
			get the date/time. this is used so the log file generated for every video submission will be unique. 
			/**************************************/
			$today = getdate();
		  
		  
			/***************************************
			format the command to youtube-dl
			/**************************************/
			
			$command="yt-dlp --paths \"".$youtube_folder_location."\" --cache-dir ".$youtube_folder_location." --ffmpeg-location ".$youtube_folder_location."/ffmpeg --default-search auto --restrict-filenames ".$postprocessor_args." ".$extract_audio." ".$extract_audio_keep_video." ".$audio_format." ".$audio_quality." ".$ignore_errors." ".$dump_user_agent." ".$list_extractors." ".$extractor_descriptions." ".$force_generic_extractor." ".$flat_playlist." ".$mark_watched." ".$playlist_start_enable." ".$playlist_start." ".$playlist_end_enbale." ".$playlist_end." ".$playlist_items_enable." ".$playlist_items." ".$max_downloads_enable." ".$max_downloads." ".$process_playlists." ".$no_overwrites." ".$resume_download." ".$no_part." ".$no_mtime." ".$write_discriptions." ".$write_info_json." ".$write_annotations." ".$write_thumbnail." ".$verbose." ".$write_sub." ".$username." ".$password." ".$two_f_auth_code." ".$video_file." > log/yt-dl-progress_".$today['mon']."-".$today['mday']."-".$today['year']."_".$today['hours']."_".$today['minutes']."_".$today['seconds'].".txt  2>&1 &";
		  
		  
		}
	   
	   
		/*******************************************************************************************************************
		begin generating the HTML page
		/******************************************************************************************************************/
	   
		print "<br><fieldset><legend><h3>".$page_title."</h3></legend>";	
		print "<table border=\"0\">";
		print "<tr><td align=\"left\">";
		
		
		
		/***************************************
		has the user chosen to see if updates are available for youtube-dl?
		/**************************************/
		print "<form action=\"".$form_submit_location."\" method=\"post\">";
		print "</p><input type=\"submit\" name=\"update\" value=\"Update Youtube-dlp?\" /></p></form>";
		if(isset($_POST['update'])){
			$output = shell_exec('yt-dlp -U');
			print "Update Log:<br>";
			echo "<pre>$output</pre>";			
		}
		
		/***************************************
		has the user chosen to see what version of youtube-dl is currently installed? 
		/**************************************/
		print "<form action=\"".$form_submit_location."\" method=\"post\">";
		print "</p><input type=\"submit\" name=\"version_check\" value=\"Display Youtube-dlp Version\" /></p></form>";
		if(isset($_POST['version_check'])){
			$output = shell_exec('yt-dlp --version');
			print "Youtube-dlp Version: $output";
		}
		
		
		/***************************************
		has the user chosen to list any already downloaded files?
		/**************************************/
		print "<form action=\"".$form_submit_location."\" method=\"post\">";
		print "<br><br></p><input type=\"submit\" name=\"list_files\" value=\"List Downloaded Files\" /></p></form>";
		if(isset($_POST['list_files'])){
			$dir    = 'youtube';
			$files1 = scandir($dir);
			$counter=1;
			// Loop through array
			foreach($files1 as $value){
				if ($value!="log"){
					if ($value!="."){
						if ($value!=".."){
							if ($value!="ffmpeg"){
								if ($value!="phantomjs"){
									if ($value!="phantomjs-2.1.1-linux-x86_64"){
										if ($value!="youtube-nsig"){
											if ($value!="youtube-sigfuncs"){
												if ($value!="youtube-sts"){
													print "<form action=\"".$form_submit_location."\" method=\"post\">";
													print "<p>".$counter.".) <a href=\"".$web_url_to_youtube_directory."/".$value."\" download><font size=\"2\">".$value."</font></a>";
													$size=round(filesize("".$dir."/".$value."")/1024,0);
													print " (".$size." KB)";
													print "  |  <input type=\"submit\" name=\"delete_files_submit\" value=\"Delete File\" />";
													print "<input type=\"hidden\" name=\"delete_file\" value=\"".$value."\" />";
													print "</p></form>";
													$counter++;
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		
		
		
		
		/***************************************
		does the user want to list all available log files so they can be viewed? 
		/**************************************/  
		print "<form action=\"".$form_submit_location."\" method=\"post\">";
		print "<input type=\"submit\" name=\"view_all_log\" value=\"List all Log Files?\" />";
		print "</p></form>";
		if(isset($_POST['view_all_log'])){
			$dir    = 'youtube/log';
			$files1 = scandir($dir);
			$counter=1;
			// Loop through array
			foreach($files1 as $value){
				if ($value!="."){
					if ($value!=".."){
						print "<form action=\"".$form_submit_location."\" method=\"post\">";
						print "<p>".$counter.".) <a href=\"".$web_url_to_youtube_directory."/log/".$value."\" target=\"blank\"><font size=\"2\">".$value."</font></a>";
						$size=round(filesize("".$dir."/".$value.""),0);
						print " (".$size." bytes)";
						print "  |  <input type=\"submit\" name=\"delete_log_files_submit\" value=\"Delete File\" />";
						print "<input type=\"hidden\" name=\"delete_log_file\" value=\"".$value."\" />";
						print "</p></form>";
						$counter++;
					}
				}
			}
		}


		/***************************************
		does the user want to display the active log file for the video just downloaded or in the process of downloading? 
		/**************************************/
		if(isset($_POST['submit'])){
			if ($playlist_start_error==0 AND $playlist_end_error==0 AND $playlist_items_error==0 AND $max_downloads_error==0 AND $postprocessor_args_error==0 AND $video_file_error==0 AND $username_error==0 AND $password_error==0){
				print "<form action=\"".$form_submit_location."\" method=\"post\">";
				print "<br><input type=\"submit\" name=\"view_single_log\" value=\"View Log File?\" />";
				print "<input type=\"hidden\" name=\"single_log\" value=\"yt-dl-progress_".$today['mon']."-".$today['mday']."-".$today['year']."_".$today['hours']."_".$today['minutes']."_".$today['seconds'].".txt\" />";
				print "</p></form>";
			}
		}
		  
		if(isset($_POST['view_single_log'])){
			print "<form action=\"".$form_submit_location."\" method=\"post\">";
			print "<input type=\"submit\" name=\"view_single_log\" value=\"View Log File?\" />";
			print "<input type=\"hidden\" name=\"single_log\" value=\"".$_POST['single_log']."\" />";
			print "</p></form>";
			  
			if (file_exists("".$youtube_folder_location."/log/".$_POST['single_log']."")) {
				$data = file_get_contents("".$youtube_folder_location."/log/".$_POST['single_log']."");
				print "Viewing log file \"/log/".$_POST['single_log']."\"<br>";
				echo "<font size=\"1\">".nl2br($data)."</font>";
			}
		}
		
		
		
		/***************************************
		let's begin the main part of the page
		/**************************************/
		print "<br><br>";
		print "<form action=\"".$form_submit_location."\" method=\"post\">";
		
		
		//Print out video URL test box
		if ($video_file_error==0){
		    print "<p>URL of Desired Youtube Video: <input type=\"text\" name=\"video_file\" value=\"\"></p>";
		}else{
		    print "<p>URL of Desired Youtube Video: <INPUT type=\"text\" name=\"video_file\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['video_file']."\"></p>";
		}
			   
		print "<center><input type=\"submit\" name=\"submit\" value=\"Submit\" /></center>";
		
		
		/***************************************
		if the user has submitted the page to download a video let's check to make sure everything is OK first
		/**************************************/
		if(isset($_POST['submit'])){
			chdir('youtube');
			//print out the command if the user wanted to see it
			if ($show_command==1){
				print "Verbosity Activated --> Command Being sent to youtube-dlp:<br><font size=\"2\">".$command."</font>";
			}
			
			//verify none of the text box based fields had incorrectly entered information
			//if the information was entered wrong, the text box will become red. since the information was wrong, we do not want to actually perform the command
			if ($playlist_start_error==0 AND $playlist_end_error==0 AND $playlist_items_error==0 AND $max_downloads_error==0 AND $postprocessor_args_error==0 AND $video_file_error==0 AND $username_error==0 AND $password_error==0){
				
				//everything looks good, process the command
				print "<br><font color=\"green\"><b>Command Executed. Please allow time for the video to download. Use the \"List Downloaded Files\" button to retrieve the downloaded video</b></font><br>";
				shell_exec($command);
			}else{
				
				//something was wrong, inform the user
				print "<br><font color=\"red\"><b>Command Not Executed - One or More Errors Were Made, Please Correct Errors and Try Again</b></font><br>";	
			}			
		}
		  
			  
		  
		print "________________________________________________<br><br><b>POST-PROCESSING OPTIONS</b>";
		
		/***************************************
		Extract Audio From Video check box
		/**************************************/		
		if ($playlist_start_error>0 OR $playlist_end_error>0 OR $playlist_items_error>0 OR $max_downloads_error>0 OR $postprocessor_args_error>0 OR $video_file_error>0 OR $username_error>0 OR $password_error>0){
			if ($_POST['extract_audio']=="-x"){
				print "<p><input type=\"checkbox\" name=\"extract_audio\" value=\"-x\" checked>Extract Audio From Video?</p>";	
			}else{
				print "<p><input type=\"checkbox\" name=\"extract_audio\" value=\"-x\">Extract Audio From Video?</p>";
			}
		}else{
			print "<p><input type=\"checkbox\" name=\"extract_audio\" value=\"-x\" checked>Extract Audio From Video?</p>";	
		}	
		
		/***************************************
		After Audio Extract, Keep Video File checkbox
		/**************************************/
		if ($playlist_start_error>0 OR $playlist_end_error>0 OR $playlist_items_error>0 OR $max_downloads_error>0 OR $postprocessor_args_error>0 OR $video_file_error>0 OR $username_error>0 OR $password_error>0){
			if ($_POST['extract_audio_keep_video']=="-k"){
				print "<p><input type=\"checkbox\" name=\"extract_audio_keep_video\" value=\"-k\" checked>After Audio Extract, Keep Video File?</p>";
			}else{
				print "<p><input type=\"checkbox\" name=\"extract_audio_keep_video\" value=\"-k\">After Audio Extract, Keep Video File?</p>";
			}
		}else{
			print "<p><input type=\"checkbox\" name=\"extract_audio_keep_video\" value=\"-k\">After Audio Extract, Keep Video File?</p>";
		}
				
		
		/***************************************
		Audio Format of Extracted Audio selector box
		/**************************************/
		if ($playlist_start_error>0 OR $playlist_end_error>0 OR $playlist_items_error>0 OR $max_downloads_error>0 OR $postprocessor_args_error>0 OR $video_file_error>0 OR $username_error>0 OR $password_error>0){
			print "<p>Audio Format of Extracted Audio <select name=\"audio_format\">
				<option value=\"--audio-format best\"";
				if ($_POST['audio_format']=="--audio-format best"){
					print " selected";
				}
				print ">Best</option>
				<option value=\"--audio-format aac\"";
				if ($_POST['audio_format']=="--audio-format aac"){
					print " selected";
				}
				print ">aac</option>
				<option value=\"--audio-format flac\"";
				if ($_POST['audio_format']=="--audio-format flac"){
					print " selected";
				}
				print ">flac</option>
				<option value=\"--audio-format mp3\"";
				if ($_POST['audio_format']=="--audio-format mp3"){
					print " selected";
				}
				print ">mp3</option>
				<option value=\"--audio-format m4a\"";
				if ($_POST['audio_format']=="--audio-format m4a"){
					print " selected";
				}
				print ">m4a</option>
				<option value=\"--audio-format opus\"";
				if ($_POST['audio_format']=="--audio-format opus"){
					print " selected";
				}
				print ">opus</option>
				<option value=\"--audio-format vorbis\"";
				if ($_POST['audio_format']=="--audio-format vorbis"){
					print " selected";
				}
				print ">vorbis</option>
				<option value=\"--audio-format wav\"";
				if ($_POST['audio_format']=="--audio-format wav"){
					print " selected";
				}
				print ">wav</option></select>			
			</p>";	
		}else{
			print "<p>Audio Format of Extracted Audio <select name=\"audio_format\">
				<option value=\"--audio-format best\">Best</option>
				<option value=\"--audio-format aac\">aac</option>
				<option value=\"--audio-format flac\">flac</option>
				<option value=\"--audio-format mp3\" selected>mp3</option>
				<option value=\"--audio-format m4a\">m4a</option>
				<option value=\"--audio-format opus\">opus</option>
				<option value=\"--audio-format vorbis\">vorbis</option>
				<option value=\"--audio-format wav\">wav</option></select>			
			</p>";	
		}
		
		
		/***************************************
		Audio quality of Extracted Audio selector box
		/**************************************/
		if ($playlist_start_error>0 OR $playlist_end_error>0 OR $playlist_items_error>0 OR $max_downloads_error>0 OR $postprocessor_args_error>0 OR $video_file_error>0 OR $username_error>0 OR $password_error>0){
			print "<p>Audio Quality of Extracted Audio <select name=\"audio_quality\">
				<option value=\"--audio-quality 0\"";
				if ($_POST['audio_quality']=="--audio-quality 0"){
					print " selected";
				}
				print ">0 (Best)</option>
				<option value=\"--audio-quality 1\"";
				if ($_POST['audio_quality']=="--audio-quality 1"){
					print " selected";
				}
				print ">1</option>
				<option value=\"--audio-quality 2\"";
				if ($_POST['audio_quality']=="--audio-quality 2"){
					print " selected";
				}
				print ">2</option>
				<option value=\"--audio-quality 3\"";
				if ($_POST['audio_quality']=="--audio-quality 3"){
					print " selected";
				}
				print ">3</option>
				<option value=\"--audio-quality 4\"";
				if ($_POST['audio_quality']=="--audio-quality 4"){
					print " selected";
				}
				print ">4</option>
				<option value=\"--audio-quality 5\"";
				if ($_POST['audio_quality']=="--audio-quality 5"){
					print " selected";
				}
				print ">5</option>
				<option value=\"--audio-quality 6\"";
				if ($_POST['audio_quality']=="--audio-quality 6"){
					print " selected";
				}
				print ">6</option>
				<option value=\"--audio-quality 7\"";
				if ($_POST['audio_quality']=="--audio-quality 7"){
					print " selected";
				}
				print ">7</option>
				<option value=\"--audio-quality 8\"";
				if ($_POST['audio_quality']=="--audio-quality 8"){
					print " selected";
				}
				print ">8</option>
				<option value=\"--audio-quality 9\"";
				if ($_POST['audio_quality']=="--audio-quality 9"){
					print " selected";
				}
				print ">9</option></select>
				<font size=\"1\">0 (better) and 9 (worse)</font>
				</p>";	
		}else{
				print "<p>Audio Quality of Extracted Audio <select name=\"audio_quality\">
				<option value=\"--audio-quality 0\" selected>0 (Best)</option>
				<option value=\"--audio-quality 1\">1</option>
				<option value=\"--audio-quality 2\">2</option>
				<option value=\"--audio-quality 3\">3</option>
				<option value=\"--audio-quality 4\">4</option>
				<option value=\"--audio-quality 5\">5</option>
				<option value=\"--audio-quality 6\">6</option>
				<option value=\"--audio-quality 7\">7</option>
				<option value=\"--audio-quality 8\">8</option>
				<option value=\"--audio-quality 9\">9</option></select>
				<font size=\"1\">0 (better) and 9 (worse)</font>
				</p>";	
		}

		/***************************************
		Are intros and/or end-credits in video? Enter when the song starts and when the song ends checkbox
		/**************************************/
		if ($playlist_start_error>0 OR $playlist_end_error>0 OR $playlist_items_error>0 OR $max_downloads_error>0 OR $postprocessor_args_error>0 OR $video_file_error>0 OR $username_error>0 OR $password_error>0){
			if ($_POST['postprocessor_args']=="--postprocessor-args"){
				print "<p><input type=\"checkbox\" name=\"postprocessor_args\" value=\"--postprocessor-args\" checked>Are intros and/or end-credits in video? Enter when the song starts and when the song ends</p>";
			}else{
				print "<p><input type=\"checkbox\" name=\"postprocessor_args\" value=\"--postprocessor-args\">Are intros and/or end-credits in video? Enter when the song starts and when the song ends</p>";
			}
		}else{
			print "<p><input type=\"checkbox\" name=\"postprocessor_args\" value=\"--postprocessor-args\">Are intros and/or end-credits in video? Enter when the song starts and when the song ends</p>";
		}
		
		/***************************************
		post processing audio_start_hour text box
		/**************************************/
		if ($playlist_start_error>0 OR $playlist_end_error>0 OR $playlist_items_error>0 OR $max_downloads_error>0 OR $postprocessor_args_error>0 OR $video_file_error>0 OR $username_error>0 OR $password_error>0){
			if ($postprocessor_args_error==2){
				print "<p>Audio/Song Start Time: [h] <INPUT type=\"text\" name=\"audio_start_hour\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['audio_start_hour']."\" size=\"1\">";
			}else{
				print "</p>Audio/Song Start Time: [h] <input type=\"text\" name=\"audio_start_hour\" value=\"".$_POST['audio_start_hour']."\" size=\"1\">";
			}
		}else{
			print "</p>Audio/Song Start Time: [h] <input type=\"text\" name=\"audio_start_hour\" value=\"0\" size=\"1\">";
		}
		

		/***************************************
		post processing audio_start_min text box
		/**************************************/
		if ($playlist_start_error>0 OR $playlist_end_error>0 OR $playlist_items_error>0 OR $max_downloads_error>0 OR $postprocessor_args_error>0 OR $video_file_error>0 OR $username_error>0 OR $password_error>0){
			if ($postprocessor_args_error==3){
				print " : [m] <INPUT type=\"text\" name=\"audio_start_min\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['audio_start_min']."\" size=\"1\">";
			}else{
				print " : [m] <input type=\"text\" name=\"audio_start_min\" value=\"".$_POST['audio_start_min']."\" size=\"1\">";
			}
		}else{
			print " : [m] <input type=\"text\" name=\"audio_start_min\" value=\"0\" size=\"1\">";
		}
		
		/***************************************
		post processing audio_start_second text box
		/**************************************/		
		if ($playlist_start_error>0 OR $playlist_end_error>0 OR $playlist_items_error>0 OR $max_downloads_error>0 OR $postprocessor_args_error>0 OR $video_file_error>0 OR $username_error>0 OR $password_error>0){
			if ($postprocessor_args_error==4){
				print " : [s] <INPUT type=\"text\" name=\"audio_start_second\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['audio_start_second']."\" size=\"1\"></p>";
			}else{
				print " : [s] <input type=\"text\" name=\"audio_start_second\" value=\"".$_POST['audio_start_second']."\" size=\"1\"></p>";
			}
		}else{
			print " : [s] <input type=\"text\" name=\"audio_start_second\" value=\"0\" size=\"1\"></p>";
		}
		
		/***************************************
		post processing audio_end_hour text box
		/**************************************/
		if ($playlist_start_error>0 OR $playlist_end_error>0 OR $playlist_items_error>0 OR $max_downloads_error>0 OR $postprocessor_args_error>0 OR $video_file_error>0 OR $username_error>0 OR $password_error>0){
			if ($postprocessor_args_error==5){
				print "<p>Audio/Song End Time: [h] <INPUT type=\"text\" name=\"audio_end_hour\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['audio_end_hour']."\" size=\"1\">";
			}else{   
				print "</p>Audio/Song End Time: [h] <input type=\"text\" name=\"audio_end_hour\" value=\"".$_POST['audio_end_hour']."\" size=\"1\">";
			}
		}else{
			print "</p>Audio/Song End Time: [h] <input type=\"text\" name=\"audio_end_hour\" value=\"0\" size=\"1\">";
		}

		/***************************************
		post processing audio_end_min text box
		/**************************************/
		if ($playlist_start_error>0 OR $playlist_end_error>0 OR $playlist_items_error>0 OR $max_downloads_error>0 OR $postprocessor_args_error>0 OR $video_file_error>0 OR $username_error>0 OR $password_error>0){
			if ($postprocessor_args_error==6){
				print " : [m] <INPUT type=\"text\" name=\"audio_end_min\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['audio_end_min']."\" size=\"1\">";
			}else{   
				print " : [m] <input type=\"text\" name=\"audio_end_min\" value=\"".$_POST['audio_end_min']."\" size=\"1\">";
			}
		}else{
			print " : [m] <input type=\"text\" name=\"audio_end_min\" value=\"0\" size=\"1\">";
		}

		/***************************************
		post processing audio_end_second text box
		/**************************************/			   
		if ($playlist_start_error>0 OR $playlist_end_error>0 OR $playlist_items_error>0 OR $max_downloads_error>0 OR $postprocessor_args_error>0 OR $video_file_error>0 OR $username_error>0 OR $password_error>0){
			if ($postprocessor_args_error==7){
				print " : [s] <INPUT type=\"text\" name=\"audio_end_second\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['audio_end_second']."\" size=\"1\"></p>";
			}else{   
				print " : [s] <input type=\"text\" name=\"audio_end_second\" value=\"".$_POST['audio_end_second']."\" size=\"1\"></p>";
			}
		}else{
			print " : [s] <input type=\"text\" name=\"audio_end_second\" value=\"0\" size=\"1\"></p>";
		}
		
			   
		print "<br>________________________________________________<br><br><b>GENERAL OPTIONS</b>";
		print "<p>Ignore Errors? <select name=\"ignore_errors\">
			<option value=\"--ignore-errors\"><font size=\"1\">Continue on download errors, for example to skip unavailable videos in a playlist</option>
			<option value=\"--abort-on-error\">Abort downloading of further videos (in the playlist or the command line) if an error occurs</option></select></p>";
		print "<p><input type=\"checkbox\" name=\"dump_user_agent\" value=\"--dump-user-agent\">Dump User Agent <font size=\"1\">Display the current browser identification</font></p>";
		print "<p><input type=\"checkbox\" name=\"list_extractors\" value=\"--list-extractors\">List Extractors <font size=\"1\">List all supported extractors</font></p>";
		print "<p><input type=\"checkbox\" name=\"extractor_descriptions\" value=\"--extractor-descriptions\">List Extractors Descriptions <font size=\"1\">Output descriptions of all supported extractors</font></p>";
		print "<p><input type=\"checkbox\" name=\"force_generic_extractor\" value=\"--force-generic-extractor\">Force Generic Extractor <font size=\"1\">Output descriptions of all supported extractors</font></p>";
		print "<p><input type=\"checkbox\" name=\"flat_playlist\" value=\"--flat-playlist\">Flat Play List <font size=\"1\">Do not extract the videos of a playlist, only list them.</font></p>";
		print "________________________________________________<br><br><b>VIDEO OPTIONS</b>";
		print "<p>Mark Video as Watched? (Youtube Only) <select name=\"mark_watched\">
			<option value=\"--no-mark-watched\">Do Not Mark as Watched</option>
			<option value=\"--mark-watched\"><font size=\"1\">Mark as Watched</option></select></p>";
		print "<p><select name=\"process_playlists\">
			<option value=\"--no-playlist\">Download only the video, if the URL refers to a video and a playlist</option>
			<option value=\"--yes-playlist\"><font size=\"1\">Download the playlist, if the URL refers to a video and a playlist</option></select></p>";
			
		if ($playlist_items_error > 0){
		    print "<p><input type=\"checkbox\" name=\"playlist_items_enable\" value=\"--playlist-items\">Play List Items to Download <INPUT type=\"text\" name=\"playlist_items\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['playlist_items']."\"><font size=\"1\">Playlist video items to download. Specify indices of the videos in the playlist separated by commas like: \"1,2,5,8\" if you want to download videos indexed 1, 2, 5, 8 in the playlist. You can specify range: \"1-3,7,10-13\", it will download the videos at index 1, 2, 3, 7, 10, 11, 12 and 13.</font></p>";
		}else{
		    print "<p><input type=\"checkbox\" name=\"playlist_items_enable\" value=\"--playlist-items\">Play List Items to Download <input type=\"text\" name=\"playlist_items\" value=\"\"><font size=\"1\">Playlist video items to download. Specify indices of the videos in the playlist separated by commas like: \"1,2,5,8\" if you want to download videos indexed 1, 2, 5, 8 in the playlist. You can specify range: \"1-3,7,10-13\", it will download the videos at index 1, 2, 3, 7, 10, 11, 12 and 13.</font></p>";
		}	 
		
		print "_________________________________________________<br>if not using the above text box, choose start and stop video only?<br><br>";
		if ($playlist_start_error > 0){
		    print "<p>--<input type=\"checkbox\" name=\"playlist_start_enable\" value=\"--playlist-start\">Play List Start Video <INPUT type=\"text\" name=\"playlist_start\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['playlist_start']."\"><font size=\"1\">Play List video to start at (default is 1)</font></p>";
		}else{
		    print "<p>--<input type=\"checkbox\" name=\"playlist_start_enable\" value=\"--playlist-start\">Play List Start Video <input type=\"text\" name=\"playlist_start\" value=\"\"><font size=\"1\">Play List video to start at (default is 1)</font></p>";
		}
			  			   
		if ($playlist_end_error > 0){
		    print "<p>--<input type=\"checkbox\" name=\"playlist_end_enbale\" value=\"--playlist-end\">Play List End Video <INPUT type=\"text\" name=\"playlist_end\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['playlist_end']."\"><font size=\"1\">Play List video to end at (default is last)</font></p>";
		}else{
		    print "<p>--<input type=\"checkbox\" name=\"playlist_end_enbale\" value=\"--playlist-end\">Play List End Video <input type=\"text\" name=\"playlist_end\" value=\"\"><font size=\"1\">Play List video to end at (default is last)</font></p>";
		}
		  
		  
		if ($max_downloads_error > 0){
		    print "<p>--<input type=\"checkbox\" name=\"max_downloads_enable\" value=\"--max-downloads\">Abort after downloading NUMBER files <INPUT type=\"text\" name=\"max_downloads\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['max_downloads']."\"></p>";
		}else{
		    print "<p>--<input type=\"checkbox\" name=\"max_downloads_enable\" value=\"--max-downloads\">Abort after downloading NUMBER files <input type=\"text\" name=\"max_downloads\" value=\"\"></p>";
		}
		
		print "________________________________________________<br><br><b>FILE SYSTEM OPTIONS</b>";
		print "<p><input type=\"checkbox\" name=\"no_overwrites\" value=\"--no-overwrites\">Do not overwrite already existing files</p>";
		print "<p>Resume of partially downloaded files? <select name=\"resume_download\">
			<option value=\"--continue\">Force resume of partially downloaded files</option>
			<option value=\"--no-continue\"><font size=\"1\">Do not resume partially downloaded files (restart from beginning)</font></option></select></p>";
		print "<p><input type=\"checkbox\" name=\"no_part\" value=\"--no-part\">Do not use .part files - write directly into output file</p>";
		print "<p><input type=\"checkbox\" name=\"no_mtime\" value=\"--no-mtime\">Do not use the Last-modified header to set the file modification time</p>";
		print "<p><input type=\"checkbox\" name=\"write_discriptions\" value=\"--write-description\">Write video description to a .description file</p>";
		print "<p><input type=\"checkbox\" name=\"write_info_json\" value=\"--write-info-json\">Write video metadata to a .info.json file</p>";
		print "<p><input type=\"checkbox\" name=\"write_annotations\" value=\"--write-annotations\">Write video annotations to a .annotations.xml file</p>";
		   
		print "________________________________________________<br><br><b>THUMBNAIL IMAGE OPTIONS</b>";
		print "<p>Write thumbnail image to disk? <select name=\"write_thumbnail\">
			<option value=\"\" selected>Do NOT Write thumbnails</option>
			<option value=\"--write-thumbnail\"><font size=\"1\">Write thumbnail image to disk</font></option>
			<option value=\"--write-all-thumbnails\"><font size=\"1\">Write all thumbnail image formats to disk</font></option>
			<option value=\"--list-thumbnails\"><font size=\"1\">Simulate and list all available thumbnail formats</font></option>
			</select></p>";
		print "________________________________________________<br><br><b>VERBOSITY / SIMULATION OPTIONS</b>";
		print "<p><input type=\"checkbox\" name=\"verbose\" value=\"--verbose\">Print various debugging information</p>";
		print "<p><input type=\"checkbox\" name=\"show_command\" value=\"1\">Show the command sent to youtube-dl by this page</p>";
		print "________________________________________________<br><br><b>WORKAROUND OPTIONS</b>";
		print "<p><input type=\"checkbox\" name=\"no_check_certificate\" value=\"--no-check-certificate\">Suppress HTTPS certificate validation</p>";
		print "<p><input type=\"checkbox\" name=\"prefer_insecure \" value=\"--prefer-insecure \">Use an un-encrypted connection to retrieve information about the video</p>";
		print "________________________________________________<br><br><b>SUB TITLE OPTIONS</b>";
		print "<p><select name=\"write_sub\">
			<option value=\"\" selected>Do NOT Write Subs</option>
			<option value=\"--write-sub\"><font size=\"1\">Write subtitle file</font></option>
			<option value=\"--write-auto-sub\"><font size=\"1\">Write automatically generated subtitle file</font></option>
			<option value=\"--all-subs\"><font size=\"1\">Download all the available subtitles of the video</font></option>
			<option value=\"--list-subs\"><font size=\"1\">List all available subtitles for the video</font></option>
			</select></p>";
		print "________________________________________________<br><br><b>AUTHENTICATION OPTIONS</b>";
		print "<p><input type=\"checkbox\" name=\"need_auth\" value=\"1\">Does the video or playlist require user name and password? (user lists for example)</p>";
		
		if ($username_error==0){
			print "<p>User Name: <input type=\"text\" name=\"username\" value=\"\">";
		}else{
		   print "<p>User Name: <INPUT type=\"text\" name=\"username\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['username']."\">";
		}
		  
		if ($password_error==0){
		   print " || password: <input type=\"text\" name=\"password\" value=\"\">";
		}else{
		   print " || password: <INPUT type=\"text\" name=\"password\" STYLE=\"color: #FFFFFF; font-family: Verdana; font-weight: bold; font-size: 12px; background-color: red;\" value=\"".$_POST['password']."\">";
		}
		  
		print "|| 2F Auth Code (If 2-Factor Auth is used on the account): <input type=\"text\" name=\"two_f_auth_code\" value=\"\"></p>";
		  	  
		print "</form>";
		print "</td></tr></table></fieldset>";
?>