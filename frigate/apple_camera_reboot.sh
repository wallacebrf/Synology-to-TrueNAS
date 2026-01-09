#!/bin/bash

snmpset -v3 -l authPriv -u admin -a MD5 -A password -x DES -X password 192.168.11.6:161 1.3.6.1.2.1.105.1.1.1.3.1.6 i 2 #turn off power to port
sleep 10
snmpset -v3 -l authPriv -u admin -a MD5 -A password -x DES -X password 192.168.11.6:161 1.3.6.1.2.1.105.1.1.1.3.1.6 i 1 #turn on power to port

python3 /mnt/volume1/logging/multireport_sendemail.py --subject "Apples Camera Rebooted" --to_address "email@email.com" --mail_body_html "Apples Camera Rebooted" --override_fromemail "email@email.com"