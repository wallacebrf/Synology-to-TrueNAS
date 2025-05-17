<?php
error_reporting(E_NOTICE);
date_default_timezone_set('America/Chicago');

print ("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">
<head>
<style>
body {font-family: Verdana, Arial, sans-serif;background: #fff;margin: 0px auto;padding: 0 0 20px 0;}
#title {background: #ffffff;padding: 5px;color: #000000;height: auto;border-bottom-style: solid;border-bottom-color: #000000;margin-left: 10px;margin-right: 10px;}
#title .right {float: center;width: auto;text-align: center;	font-size: 50px;}
#page {background: #ffffff;	padding: 4px;		color: #000000;	margin-bottom: 5px;	height: auto;	border-bottom-style: none;	margin-left: 10px;	margin-right: 10px;}
#page .center {width: auto;	text-align: center;	font-size: 35px;}
#attributes {	background: #ffffff;	padding: 0px;		color: #000000;	height: auto;	width:100%}
#menu {float: left;	width: 150px;	padding-right: 20px;font-weight: bolder;	margin-left: 10px;	margin-right: 10px;	height: 100%;}
#menu a {width: 140px;	display: block;	color: white;	padding: 8px;	border-bottom: 1px solid #fff;	text-decoration: none;	background-color: #0087FF;}
#menu a:hover {background-color: #555;	cursor:pointer;}
* {	margin: 0;}
html, body {	height: 100%;}
.wrapper {	min-height: 100%;	height: auto !important;	height: 100%;	margin: 0 auto -4em;}
.footer, .push {	height: 4em;}
");

print ("</style>");

print "<style>
body {
  margin: 0;
}

ul {
  list-style-type: none;
  margin: 0;
  padding: 0;
  width: 11%;
  background-color: #0087FF;
  position: fixed;
  height: 100%;
  overflow: auto;
  font-weight: bolder;
}

li a {
  display: block;
  color: #FFF;
  padding: 8px 16px;
  text-decoration: none;
}

li a.active {
  background-color: #0000FF;
  color: white;
}

li a:hover:not(.active) {
  background-color: #555;
  color: white;
}
</style>";


print "<style> details {
  user-select: none;
}

details>summary span.icon {
  width: 24px;
  height: 24px;
  transition: all 0.3s;
  margin-left: auto;
}

details[open] summary span.icon {
  transform: rotate(180deg);
}

summary {
  display: flex;
  cursor: pointer;
}

summary::-webkit-details-marker {
  display: none;
}
</style>";

print ("</head>");

?>
