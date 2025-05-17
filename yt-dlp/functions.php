<?php

//version 2.2 dated 2/16/2022
//by Brian Wallace

//****************************************************************
//****************************************************************
//SANITIZE USER SUBMITTED DATA
//Strip whitespace (and other characters below) from the beginning and end of a string.
//Un-quotes a quoted string. EXAMPLE: $str = "Is your name O\'reilly?"; --> Outputs: Is your name O'reilly?
//Strip HTML and PHP tags from a string
//Convert special characters to HTML entities
//****************************************************************
//****************************************************************
function sanitize_data($data){
	
	//filter the received data
	$data=trim($data);					
	$data=stripslashes($data);			
	$data=strip_tags($data);			
	$data=htmlspecialchars($data);	
	return $data;
	
}

//****************************************************************
//****************************************************************
//PROCESS / VALIDATE THAT USER SUBMITTED DATA IS WHAT IS EXPECTED
//ensure values are not blank, ensure values are within expected bounds, ensure un-desired characters are not present etc

//PARAMTERS

//$new_data --> fresh user submitted data that may be evil

//$old_data --> previous "safe" value of the variable. this will be returned if the new data is found to not be in compliance with the verification controlled by $arg

//$arg --> the type of variable that is being tested. this controls how the variable to tested, values are:
//			"name" --> a user name, person's name, place or thing, or other string that should not have extended characters and verify certain unwanted contents are not present. 
//			"time" --> validate time is properly formatted as HH:MM, H:MM, HH:MM:SS, or H:MM:SS in either 12 hour or 
//			"password" --> a user submitted password, verify the length, and verify certain unwanted contents are not present 
//			"phone" --> validate phone numbers
//			"date_slash/dash" --> validate either m-d-Y or m/d/Y formatted dates. date_slash returns formatted m/d/Y, date_dash returns formatted m-d-Y
//			"filter" --> do no validations, just perform filtering of the data
//			"email" --> validate email address is acceptable. supports multiple emails separated by a semi-colon. verify certain unwanted contents are not present
//			"url" --> validates a URL is acceptable and verify certain unwanted contents are not present
//			"ip" --> validate an IP address is the minimum number of characters, verify it has periods in it, and verify certain unwanted contents are not present
//			"mac" --> validate an MAC address is the minimum number of characters, ensure it only has colons in it, and verify certain unwanted contents are not present
//			"dir" --> validate that a directory path is acceptable, and verify certain unwanted contents are not present
//			"file" --> validates that a file name is acceptable and ensures the file extensions is one of the whitelisted file extensions
//			"numeric" --> validate a whole integer number is a number, verify it is within the $max and $min window, and verify certain unwanted contents are not present
//			"float" --> validate an decimal number is a number, verify it is within the $max and $min window, and verify certain unwanted contents are not present
//			"checkbox" --> validate the value is either a 1 or a 0 and nothing else. defaults to 0 if set to anything other than 1 or 0
//			"string" --> validates a string and verify certain unwanted contents are not present

//$min --> only used by the "numeric" and "float" argument types to ensure the number is not below a certain value

//$max --> only used by the "numeric" and "float" argument types to ensure the number is not above a certain value

//returns an array with two values [verified_data, error]. 
//****************************************************************
//****************************************************************
function test_input_processing($new_data, $old_data, $arg, $min, $max){
	$error="";
	
	
	//validate names
	if($arg=="name"){
		if ($new_data==""){
			$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
			$new_data=$old_data;
		}else{
			if (strpos($new_data, '\\')!==false || 
				strpos($new_data, '\"')!== false || 
				strpos($new_data, '..')!== false || 
				strpos($new_data, '/')!== false || 
				strpos($new_data, ';')!== false || 
				strpos($new_data, '<')!== false || 
				strpos($new_data, '>')!== false || 
				strpos($new_data, '}')!== false || 
				strpos($new_data, '{')!== false || 
				strpos($new_data, '[')!== false || 
				strpos($new_data, ']')!== false || 
				strpos($new_data, '^')!== false || 
				strpos($new_data, '#')!== false || 
				strpos($new_data, '%')!== false || 
				strpos($new_data, '*')!== false || 
				strpos($new_data, '&')!== false || 
				strpos($new_data, '!')!== false || 
				strpos($new_data, '@')!== false || 
				strpos($new_data, '|')!== false || 
				strpos($new_data, ')')!== false || 
				strpos($new_data, '(')!== false || 
				strpos($new_data, '?')!== false ||
				strpos($new_data, ':')!== false ||
				strpos($new_data, '+')!== false ||
				strpos($new_data, '=')!== false ||
				strpos($new_data, '$')!== false) 
			{
				$error = "<font size=\"1\"><font color=\"red\">The following characters are not allowed \ \" .. / ; < > } { [ ] ^ # % * & ! @ $ | ( ) ? : + =</font></font>";
				$new_data=$old_data;
			}else{
				$new_data=trim(stripslashes(strip_tags(filter_var($new_data, FILTER_SANITIZE_STRING))));
			}
		}
		
	//validate time allows for either
	// 9:05
	// 09:05
	// 9:05:01
	// 09:05:01
	}else if($arg=="time"){
		if ($new_data==""){
			$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
			$new_data=$old_data;
		}else{
			$time_explode  = explode(':', $new_data); 
			//if($time_explode[0]>12){ //must it is 24 hour format
				//process the time as 24 hour time first
				if (count($time_explode) == 2) { //just HH:MM
					if (preg_match('/^(?(?=\d{2})(?:2[0-3]|[01][0-9])|[0-9]):[0-5][0-9]$/', $new_data)!=1) { 
						$error = "<font size=\"1\"><font color=\"red\">Invalid 24-Hour Time HH:MM</font></font>";
						$new_data=$old_data;
					}
				}else if (count($time_explode) == 3) { // HH:MM:SS
					if (preg_match('/^(?(?=\d{2})(?:2[0-3]|[01][0-9])|[0-9]):[0-5][0-9]:[0-5][0-9]$/', $new_data)!=1) { 
						$error = "<font size=\"1\"><font color=\"red\">Invalid 24-Hour Time HH:MM:SS</font></font>";
						$new_data=$old_data;
					}
				}else{
					$error = "<font size=\"1\"><font color=\"red\">Invalid 24-Hour Time</font></font>";
					$new_data=$old_data;
				}
			//}else{ //process as 12 hour time
			if($error!=""){
				if (count($time_explode) == 2) { //just HH:MM
					if (preg_match('/^(1[0-2]|0?[1-9]):[0-5][0-9]$/i', $new_data)!=1) { 
						$error = "<font size=\"1\"><font color=\"red\">Invalid Time Format</font></font>";
						$new_data=$old_data;
					}
				}else if (count($time_explode) == 3) { // HH:MM:SS
					if (preg_match('/^(1[0-2]|0?[1-9]):[0-5][0-9]:[0-5][0-9]$/i', $new_data)!=1) { 
						$error = "<font size=\"1\"><font color=\"red\">Invalid Time Format</font></font>";
						$new_data=$old_data;
					}
				}else{
					$error = "<font size=\"1\"><font color=\"red\">Invalid Time Format</font></font>";
					$new_data=$old_data;
				}
			}
		}
		$new_data=trim(stripslashes(strip_tags(htmlspecialchars(filter_var($new_data, FILTER_SANITIZE_STRING)))));
		
	//validate phone numbers
	}else if($arg=="phone"){
		$minDigits = 9;//smallest allowable phone number digit length
		$maxDigits = 14; //largest allowable phone number digit length
		if ($new_data==""){
			$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
			$new_data=$old_data;
		}else{
			 //remove white space, dots, hyphens and brackets if they were submitted
			$new_data = str_replace([' ', '.', '-', '(', ')'], '', $new_data); 
			
			if (preg_match('/^[+][0-9]/', $new_data)==1) { //is the first character + followed by a digit?
				$count=1;
				$new_data = str_replace(['+'], '', $new_data, $count); //remove + at beginning but leave any other possible + characters intact
			}
			
			if(preg_match('/^[0-9]{'.$minDigits.','.$maxDigits.'}\z/', $new_data)!=1){
				$error = "<font size=\"1\"><font color=\"red\">The Phone Number is Invalid</font></font>";
				$new_data=$old_data;
			}
		}
		$new_data=trim(stripslashes(strip_tags(htmlspecialchars(filter_var($new_data, FILTER_SANITIZE_STRING)))));
	
	//validate date.
	}else if($arg=="date_dash" || $arg=="date_slash"){
		if ($new_data==""){
			$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
			$new_data=$old_data;
		}else{
			if (strpos($new_data, '/')==false){
				$date_explode  = explode('-', $new_data); //slashes in the date were not found, assume the date is structured as m-d-Y
			}else{
				$date_explode  = explode('/', $new_data);  //slashes in the date was appear to have been found, assume the date is structured as m/d/Y
			}
			if (count($date_explode) == 3) {
				if(is_numeric($date_explode[0]) && is_numeric($date_explode[1]) && is_numeric($date_explode[2])){
					if (checkdate($date_explode[0], $date_explode[1], $date_explode[2])) {
						if($arg=="date_dash"){
							$new_data="".filter_var($date_explode[0], FILTER_SANITIZE_NUMBER_INT)."-".filter_var($date_explode[1], FILTER_SANITIZE_NUMBER_INT)."-".filter_var($date_explode[2], FILTER_SANITIZE_NUMBER_INT)."";
						}else if($arg=="date_slash"){
							$new_data="".filter_var($date_explode[0], FILTER_SANITIZE_NUMBER_INT)."/".filter_var($date_explode[1], FILTER_SANITIZE_NUMBER_INT)."/".filter_var($date_explode[2], FILTER_SANITIZE_NUMBER_INT)."";
						}
					} else {
						$error = "<font size=\"1\"><font color=\"red\">Invalid Date: supplied date is not a real date on the calendar</font></font>";
						$new_data=$old_data;
					}
				}else{
					$error = "<font size=\"1\"><font color=\"red\">Invalid Date: Non-numeric value(s) submitted</font></font>";
					$new_data=$old_data;
				}
			}else {
				$error = "<font size=\"1\"><font color=\"red\">Invalid Date - Missing a part of the Date</font></font>";
				$new_data=$old_data;
			}
		}
		$new_data=trim(stripslashes(strip_tags(htmlspecialchars($new_data))));
		
	//validate password
	}else if($arg=="password"){
		if ($new_data==""){
			$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
			$new_data=$old_data;
		}else{
			if (strpos($new_data, '\\')!==false || 
				strpos($new_data, '\"')!== false || 
				strpos($new_data, ',')!== false || 
				strpos($new_data, '..')!== false || 
				strpos($new_data, '/')!== false || 
				strpos($new_data, ';')!== false || 
				strpos($new_data, '<')!== false || 
				strpos($new_data, '>')!== false || 
				strpos($new_data, '}')!== false || 
				strpos($new_data, '{')!== false || 
				strpos($new_data, '[')!== false || 
				strpos($new_data, ']')!== false || 
				strpos($new_data, '|')!== false || 
				strpos($new_data, ':')!== false || 
				strpos($new_data, '?')!== false) 
			{
				$error = "<font size=\"1\"><font color=\"red\">The following characters are not allowed \ \" , .. / ; < > } { [ ] | ? :</font></font>";
				$new_data=$old_data;
			}else{
				if ( strlen( $new_data ) < 8 ) {
					$error = "<font size=\"1\"><font color=\"red\">Password must be a minimum of 8 characters</font></font>";
					$new_data=$old_data;
				}else{
					$new_data=trim(stripslashes(strip_tags(htmlspecialchars(filter_var($new_data, FILTER_SANITIZE_STRING)))));
				}
			}
		}
		
	
	//perform filtering only
	}else if($arg=="filter"){
		$error="";
		$new_data=RemoveSpecialChar(trim(stripslashes(strip_tags(htmlspecialchars(filter_var($new_data, FILTER_SANITIZE_STRING))))));
	
	//validate email address
	}else if($arg=="email"){
		$email_exploded = explode(";", $new_data);//see if we have multiple email addresses separated by a semicolon. if we do, separate them so they can each be separately validated
		$address_counter=0;
		foreach ($email_exploded as $email_addresses) {
			if ($email_addresses==""){
				$error = "<font size=\"1\"><font color=\"red\">Email Address cannot be blank</font></font>";
			}else{
				if ( strlen( $email_addresses ) < 6 ) {
					$error = "<font size=\"1\"><font color=\"red\">Email Address is less than 6 characters</font></font>";
				}else{
					if (strpos($email_addresses, '\\')!==false || 
						strpos($email_addresses, '\"')!== false || 
						strpos($email_addresses, ',')!== false || 
						strpos($email_addresses, '..')!== false || 
						strpos($email_addresses, '/')!== false || 
						strpos($email_addresses, '<')!== false || 
						strpos($email_addresses, '>')!== false || 
						strpos($email_addresses, '}')!== false || 
						strpos($email_addresses, '{')!== false || 
						strpos($email_addresses, '[')!== false || 
						strpos($email_addresses, ']')!== false || 
						strpos($email_addresses, '^')!== false || 
						strpos($email_addresses, '#')!== false || 
						strpos($email_addresses, '%')!== false || 
						strpos($email_addresses, '*')!== false || 
						strpos($email_addresses, '&')!== false || 
						strpos($email_addresses, '!')!== false || 
						strpos($email_addresses, '=')!== false || 
						strpos($email_addresses, ' ')!== false ||
						strpos($email_addresses, '|')!== false || 
						strpos($email_addresses, '?')!== false || 
						strpos($email_addresses, ':')!== false || 
						strpos($email_addresses, '+')!== false || 
						strpos($email_addresses, ')')!== false || 
						strpos($email_addresses, '(')!== false || 
						strpos($email_addresses, '$')!== false) 
					{
						$error = "<font size=\"1\"><font color=\"red\">White spaces and the following characters are not allowed \ \" , .. / < > } { [ ] ^ #  % * & ! $ = | ? : ) ( + </font></font>";
					}else{
						if (!filter_var($email_addresses, FILTER_VALIDATE_EMAIL)) {
							$error = "<font size=\"1\"><font color=\"red\">Invalid email format</font></font>";
						}else{
							$filtered_email=filter_var($email_addresses, FILTER_SANITIZE_EMAIL);
						}
					}
				}
			}
			if($error==""){
				if($address_counter==0){
					//this is the first email, so no semicolons are needed and no concatenation is needed
					$new_data=$filtered_email;
				}else{
					#if this is an additional email, concatenate with a semicolon separating
					$new_data .= ";";
					$new_data .=$filtered_email;
				}
			}else{
				$new_data=$old_data;
				
			}
			$address_counter++;
		}
		$new_data=trim(stripslashes(strip_tags(htmlspecialchars(filter_var($new_data, FILTER_SANITIZE_STRING)))));
	
	
	//validate URL address
	}else if($arg=="url"){
		if ($new_data==""){
			$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
			$new_data=$old_data;
		}else{
			if ( strlen( $new_data ) < 4 ) {
				$error = "<font size=\"1\"><font color=\"red\">URL is less than 4 characters</font></font>";
				$new_data=$old_data;
			}else{
				if (strpos($new_data, '\\')!==false || 
					strpos($new_data, '\"')!== false || 
					strpos($new_data, '..')!== false || 
					strpos($new_data, '<')!== false || 
					strpos($new_data, '>')!== false || 
					strpos($new_data, '}')!== false || 
					strpos($new_data, '{')!== false || 
					strpos($new_data, '^')!== false || 
					strpos($new_data, '%')!== false || 
					strpos($new_data, '~')!== false)
				{
					$error = "<font size=\"1\"><font color=\"red\">The following characters are not allowed \ \" .. < > } { ^ % ~</font></font>";
					$new_data=$old_data;
				}else{
					if($new_data=="localhost" || $new_data=="Localhost" || $new_data=="LOCALHOST" || $new_data=="LocalHost"){
						$new_data=$new_data;
					}else if (strpos($new_data, '.')==false) {
						$error = "<font size=\"1\"><font color=\"red\">Invalid URL.</font></font>";
						$new_data=$old_data;
					}else{
						$new_data=filter_var($new_data, FILTER_SANITIZE_URL);
					}
				}
			}
		}
		$new_data=trim(stripslashes(strip_tags(htmlspecialchars(filter_var($new_data, FILTER_SANITIZE_STRING)))));
	
	//validate IP address
	}else if($arg=="ip"){
		if ($new_data==""){
			$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
			$new_data=$old_data;
		}else{
			if ( strlen( $new_data ) < 7 ) {
				$error = "<font size=\"1\"><font color=\"red\">IP address is too short</font></font>";
				$new_data=$old_data;
			}else{
				if (strpos($new_data, '\\')!==false || 
					strpos($new_data, '\"')!== false || 
					strpos($new_data, ',')!== false || 
					strpos($new_data, '..')!== false || 
					strpos($new_data, '/')!== false || 
					strpos($new_data, '<')!== false || 
					strpos($new_data, '>')!== false || 
					strpos($new_data, '}')!== false || 
					strpos($new_data, '{')!== false || 
					strpos($new_data, '[')!== false || 
					strpos($new_data, ']')!== false || 
					strpos($new_data, '^')!== false || 
					strpos($new_data, '#')!== false || 
					strpos($new_data, '%')!== false || 
					strpos($new_data, '*')!== false || 
					strpos($new_data, '&')!== false || 
					strpos($new_data, '!')!== false || 
					strpos($new_data, '=')!== false || 
					strpos($new_data, ' ')!== false ||
					strpos($new_data, '|')!== false ||
					strpos($new_data, '?')!== false ||
					strpos($new_data, '@')!== false ||
					strpos($new_data, '(')!== false ||
					strpos($new_data, ')')!== false ||
					strpos($new_data, ':')!== false ||
					strpos($new_data, ';')!== false ||
					strpos($new_data, '~')!== false ||
					strpos($new_data, '`')!== false ||
					strpos($new_data, '$')!== false) 
				{
					$error = "<font size=\"1\"><font color=\"red\">White spaces and the following characters are not allowed \ \" , .. / < > } { [ ] ^ #  % * & ! $ = | ? @ ( ) : ; ~ `</font></font>";
					$new_data=$old_data;
				}else{
					if($new_data=="localhost" || $new_data=="Localhost" || $new_data=="LOCALHOST" || $new_data=="LocalHost"){
						$new_data=$new_data;
					}else if (!filter_var($new_data, FILTER_VALIDATE_IP)) {
						$error = "<font size=\"1\"><font color=\"red\">Invalid IP Address.</font></font>";
						$new_data=$old_data;
					}else{
						$new_data=filter_var($new_data, FILTER_VALIDATE_IP);
					}
				}
			}
		}
		$new_data=trim(stripslashes(strip_tags(htmlspecialchars(filter_var($new_data, FILTER_SANITIZE_STRING)))));
		
	//validate MAC address
	}else if($arg=="mac"){
		if ($new_data==""){
			$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
			$new_data=$old_data;
		}else{
			if (strpos($new_data, '-')!==false){
				$new_data = str_replace("-", ":", $new_data);
				$alert="<font size=\"1\"><font color=\"red\">ALERT! all \"-\" were replaced with semicolons.  </font></font>";
			}else{
				$alert="";
			}
			if ( strlen( $new_data ) < 17 ) {
				$error = "<font size=\"1\"><font color=\"red\">MAC is too short</font></font>";
				$new_data=$old_data;
			}else{
				if (strpos($new_data, '\\')!==false || 
					strpos($new_data, '\"')!== false || 
					strpos($new_data, ',')!== false || 
					strpos($new_data, '..')!== false || 
					strpos($new_data, '/')!== false || 
					strpos($new_data, '<')!== false || 
					strpos($new_data, '>')!== false || 
					strpos($new_data, '}')!== false || 
					strpos($new_data, '{')!== false || 
					strpos($new_data, '[')!== false || 
					strpos($new_data, ']')!== false || 
					strpos($new_data, '^')!== false || 
					strpos($new_data, '#')!== false || 
					strpos($new_data, '%')!== false || 
					strpos($new_data, '*')!== false || 
					strpos($new_data, '&')!== false || 
					strpos($new_data, '!')!== false || 
					strpos($new_data, '=')!== false || 
					strpos($new_data, ' ')!== false ||
					strpos($new_data, '|')!== false ||
					strpos($new_data, '?')!== false ||
					strpos($new_data, '~')!== false ||
					strpos($new_data, '`')!== false ||
					strpos($new_data, '@')!== false ||
					strpos($new_data, ')')!== false ||
					strpos($new_data, '(')!== false ||
					strpos($new_data, '-')!== false ||
					strpos($new_data, '_')!== false ||
					strpos($new_data, '$')!== false) 
				{
					$error = "<font size=\"1\"><font color=\"red\">White spaces and the following characters are not allowed \ \" , .. / < > } { [ ] ^ #  % * & ! $ =  ? | ~ ` @ ( ) - _</font></font>";
					$new_data=$old_data;
				}else{
					if (!filter_var($new_data, FILTER_VALIDATE_MAC)) {
						$error = "<font size=\"1\"><font color=\"red\">Invalid MAC Address.</font></font>";
						$new_data=$old_data;
					}else{
						$new_data=filter_var($new_data, FILTER_VALIDATE_MAC);
					}
				}
			}
		}
		if($alert!=""){
			$error = "".$alert."".$error."";
		}
		$new_data=trim(stripslashes(strip_tags(htmlspecialchars(filter_var($new_data, FILTER_SANITIZE_STRING)))));
		
		//validate directory
	}else if($arg=="dir"){
		if ($new_data==""){
			$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
			$new_data=$old_data;
		}else{
			if (strpos($new_data, '..')!== false || 			
				strpos($new_data, ';')!== false ||
				strpos($new_data, '<')!== false || 
				strpos($new_data, '>')!== false || 
				strpos($new_data, '}')!== false || 
				strpos($new_data, '{')!== false ||  
				strpos($new_data, '^')!== false || 
				strpos($new_data, '#')!== false || 
				strpos($new_data, '%')!== false || 
				strpos($new_data, '*')!== false || 
				strpos($new_data, '&')!== false || 
				strpos($new_data, '!')!== false || 
				strpos($new_data, '=')!== false || 
				strpos($new_data, '|')!== false ||
				strpos($new_data, '~')!== false ||
				strpos($new_data, '`')!== false ||
				strpos($new_data, '$')!== false) 
			{
				$error = "<font size=\"1\"><font color=\"red\">The following characters are not allowed .. ; < > } { ^ #  % * & ! $ = | ~ ` </font></font>";
				$new_data=$old_data;
			}else{
				$new_data=trim(strip_tags(htmlspecialchars(filter_var($new_data, FILTER_SANITIZE_STRING))));
			}
		}
	
		//validate file name
	}else if($arg=="file"){
		if ($new_data==""){
			$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
			$new_data=$old_data;
		}else{
			if (strpos($new_data, '..')!== false || 			
				strpos($new_data, ';')!== false ||
				strpos($new_data, '<')!== false || 
				strpos($new_data, '>')!== false || 
				strpos($new_data, '}')!== false || 
				strpos($new_data, '{')!== false ||  
				strpos($new_data, '^')!== false || 
				strpos($new_data, '#')!== false || 
				strpos($new_data, '%')!== false || 
				strpos($new_data, '*')!== false || 
				strpos($new_data, '&')!== false || 
				strpos($new_data, '!')!== false || 
				strpos($new_data, '=')!== false || 
				strpos($new_data, '|')!== false ||
				strpos($new_data, '~')!== false ||
				strpos($new_data, '`')!== false ||
				strpos($new_data, '?')!== false ||
				strpos($new_data, '/')!== false ||
				strpos($new_data, '\\')!== false ||
				strpos($new_data, ':')!== false ||
				strpos($new_data, ',')!== false ||
				strpos($new_data, "'")!== false ||
				strpos($new_data, '"')!== false ||
				strpos($new_data, '$')!== false) 
			{
				$error = "<font size=\"1\"><font color=\"red\">The following characters are not allowed ' .. ; : < > } { ^ #  % * & ! $ = | ~ ` ? \ / , \"</font></font>";
				$new_data=$old_data;
			}else{
							
				//validate extensions are allowed extensions. add additional extensions if required 
				$file_explode  = explode('.', $new_data); 
				$last_substrring=count($file_explode)-1;
				if (strpos($file_explode[$last_substrring], 'zip')!== false || 			
					strpos($file_explode[$last_substrring], 'tar')!== false ||
					strpos($file_explode[$last_substrring], 'mp3')!== false || 
					strpos($file_explode[$last_substrring], 'wav')!== false || 
					strpos($file_explode[$last_substrring], 'doc')!== false || 
					strpos($file_explode[$last_substrring], 'docx')!== false ||  
					strpos($file_explode[$last_substrring], 'xls')!== false || 
					strpos($file_explode[$last_substrring], 'xlxs')!== false || 
					strpos($file_explode[$last_substrring], 'pdf')!== false || 
					strpos($file_explode[$last_substrring], 'ppt')!== false || 
					strpos($file_explode[$last_substrring], 'pptx')!== false ||  
					strpos($file_explode[$last_substrring], 'txt')!== false || 
					strpos($file_explode[$last_substrring], 'lock')!== false ||
					strpos($file_explode[$last_substrring], 'log')!== false ||
					strpos($file_explode[$last_substrring], 'aif')!== false ||
					strpos($file_explode[$last_substrring], 'cda')!== false ||
					strpos($file_explode[$last_substrring], 'mid')!== false ||
					strpos($file_explode[$last_substrring], 'midi')!== false ||
					strpos($file_explode[$last_substrring], 'mpa')!== false ||
					strpos($file_explode[$last_substrring], 'ogg')!== false ||
					strpos($file_explode[$last_substrring], 'wpl')!== false ||
					strpos($file_explode[$last_substrring], '7z')!== false ||
					strpos($file_explode[$last_substrring], 'arj')!== false ||
					strpos($file_explode[$last_substrring], 'deb')!== false ||
					strpos($file_explode[$last_substrring], 'pkg')!== false ||
					strpos($file_explode[$last_substrring], 'rar')!== false ||
					strpos($file_explode[$last_substrring], 'gz')!== false ||
					strpos($file_explode[$last_substrring], 'z')!== false ||
					strpos($file_explode[$last_substrring], 'csv')!== false ||
					strpos($file_explode[$last_substrring], 'ai')!== false ||
					strpos($file_explode[$last_substrring], 'bmp')!== false ||
					strpos($file_explode[$last_substrring], 'gif')!== false ||
					strpos($file_explode[$last_substrring], 'ico')!== false ||
					strpos($file_explode[$last_substrring], 'jpeg')!== false ||
					strpos($file_explode[$last_substrring], 'jpg')!== false ||
					strpos($file_explode[$last_substrring], 'png')!== false ||
					strpos($file_explode[$last_substrring], 'tif')!== false ||
					strpos($file_explode[$last_substrring], 'tiff')!== false ||
					strpos($file_explode[$last_substrring], '3g2')!== false ||
					strpos($file_explode[$last_substrring], '3gp')!== false ||
					strpos($file_explode[$last_substrring], 'avi')!== false ||
					strpos($file_explode[$last_substrring], 'flv')!== false ||
					strpos($file_explode[$last_substrring], 'h264')!== false ||
					strpos($file_explode[$last_substrring], 'm4v')!== false ||
					strpos($file_explode[$last_substrring], 'mkv')!== false ||
					strpos($file_explode[$last_substrring], 'mov')!== false ||
					strpos($file_explode[$last_substrring], 'mp4')!== false ||
					strpos($file_explode[$last_substrring], 'mpg')!== false ||
					strpos($file_explode[$last_substrring], 'mpeg')!== false ||
					strpos($file_explode[$last_substrring], 'rm')!== false ||
					strpos($file_explode[$last_substrring], 'swf')!== false ||
					strpos($file_explode[$last_substrring], 'vob')!== false ||
					strpos($file_explode[$last_substrring], 'wmv')!== false ||
					strpos($file_explode[$last_substrring], 'webm')!== false ||
					strpos($file_explode[$last_substrring], 'skip')!== false ||
					strpos($file_explode[$last_substrring], 'wma')!== false) 
				{
					$new_data = preg_replace( '/[\r\n\t -]+/', '-', $new_data );
					$new_data = trim( $new_data, '.-_' );
					$new_data=strip_tags(htmlspecialchars(filter_var($new_data, FILTER_SANITIZE_STRING)));
				}else{
					$error = "<font size=\"1\"><font color=\"red\">Unallowable File Extension</font></font>";
					$new_data=$old_data;
				}
			}
		}
		
	//validate numeric only values
	}else if($arg=="numeric"){
		if ($new_data==""){
				$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
				$new_data=$old_data;
		}else{
			if ($new_data > $max || $new_data < $min){
				$error = "<font size=\"1\"><font color=\"red\">Outside allowable range of ".$min." to ".$max."</font></font>";
				$new_data=$old_data;
			}else{
				if (!is_numeric($new_data)) {
					$error = "<font size=\"1\"><font color=\"red\">Submitted Value was not numeric</font></font>";
					$new_data=$old_data;
				}else{
					$new_data=RemoveSpecialChar(filter_var($new_data, FILTER_SANITIZE_NUMBER_INT));
					$new_data=trim(stripslashes(strip_tags(htmlspecialchars($new_data))));
				}
			}
		}
	
	
	//validate numeric only values
	}else if($arg=="float"){
		if ($new_data==""){
				$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
				$new_data=$old_data;
		}else{
			if ($new_data > $max || $new_data < $min){
				$error = "<font size=\"1\"><font color=\"red\">Exceeded allowable range of ".$min." to ".$max."</font></font>";
				$new_data=$old_data;
			}else{
				$new_data=RemoveSpecialChar(filter_var($new_data, FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION));
				$new_data=trim(stripslashes(strip_tags(htmlspecialchars($new_data))));
			}
		}
	
	//validate checkbox submitting (check boxes are either value 1 or 0)
	}else if($arg=="checkbox"){
		if ($new_data!=1){
			$new_data=0;
		}else{
			$new_data=1;
		}
	
	
	
	//perform data verification of submitted values
	}else if($arg=="string"){
		if (filter_var($new_data, FILTER_SANITIZE_STRING)) {
			if ($new_data==""){
				$error = "<font size=\"1\"><font color=\"red\">Value cannot be blank</font></font>";
				$new_data=$old_data;
			}else{
				$new_data=filter_var($new_data, FILTER_SANITIZE_STRING);
			}
		}else{
			$error = "<font size=\"1\"><font color=\"red\">Submitted Value was not a valid string</font></font>";
			$new_data=$old_data;
		}
	}else{
		$error = "<font size=\"1\"><font color=\"red\">Code Error: Argument value \"".$arg."\" is invalid</font></font>";
		$new_data=$old_data;
	}
	
	
	return [$new_data, $error];
}

//****************************************************************
//****************************************************************
//remove certain characters from a string
//****************************************************************
//****************************************************************
  function RemoveSpecialChar($str) {
  
      // Using str_replace() function 
      // to replace the word 
      $res = str_replace( array( '\'', '"',
  ',' , '..' , '/' ,';', '<', '>', '}', '{', '[', ']', '^', '#', '%', '*', '&', '!', '@', '$' ), '', $str);
  
      // Returning the result 
      return $res;
  }
  
//****************************************************************
//****************************************************************
//remove certain characters from a string that is specifically to be used within a URL link variable
//****************************************************************
//**************************************************************** 
  function RemoveSpecialChar_url($str) {
  
      // Using str_replace() function 
      // to replace the word 
      $res = str_replace( array( '\'', '"' , '..', '<', '>', '}', '{', '^', '%', '~' ), '', $str);
  
      // Returning the result 
      return $res;
  }
  
//****************************************************************
//****************************************************************
//remove certain characters from a string that is specifically to be used within a email address variable
//****************************************************************
//**************************************************************** 
  function RemoveSpecialChar_email($str) {
  
      // Using str_replace() function 
      // to replace the word 
      $res = str_replace( array( '\'', '"',
  ',' , '..' , '/' , '<', '>', '}', '{', '[', ']', '^', '#', '%', '*', '&', '!', '$', '|', '=' ), '', $str);
  
      // Returning the result 
      return $res;
  }
  
//****************************************************************
//****************************************************************
//remove certain characters from a string that is specifically to be used within a directory/file link/location variable
//****************************************************************
//****************************************************************
  function RemoveSpecialChar_directory($str) {
  
      // Using str_replace() function 
      // to replace the word 
      $res = str_replace( array( '"',
  ',' , '..' ,';', '<', '>', '}', '{', '^', '#', '%', '*', '&', '!', '@', '$', '%', '?', '|', '=' ), '', $str);
  
      // Returning the result 
      return $res;
  }

//testing purposes only

/*$new_submitted="Gifts'--";
$old="old safe string";
$min=0;
$max=0;
$error="";
$filtered_string="";
echo "old string is...................................".$old."<br>";
echo "new string is ........................".$new_submitted."<br>";

[$filtered_string, $error] = test_input_processing($new_submitted, $old, "name", $min, $max);

			echo "filtered string is ........................".$filtered_string."<br>";
			echo "error is ".$error."<br><br>";*/

?>