# Garrett Mathers --> Webfire Wireless --> Scripts --> Antennas --> Sector Swap
# 5/23/2022
#Description:
#This script scans for available Antennas and documents its findings
#in a file for the antenna_sitter script to pull from every 12 hours
#it will also declare failCount for antennaSitter to be able to manipulate it as a global variable
#This may create some interference if the fail count is at three say and the variable is reset. 
#The likelihood of it happening is slim and will only result in the customer being down for an hour and 45 minutes
#instead of just an hour. 

#scans potential sectors without bringing the customer down
/interface wireless scan wlan1 background=no duration=15s save-file=wlan1scan.txt;

#declaring failCount for antennaSitter
:global failCount 0 ;
:put [$failCount] ;

