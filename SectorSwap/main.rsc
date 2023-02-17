#Webfire Wireless Sector Swap Script
#Version: 1.0  Date: 5/28/2022
#I	Purpose:
#Facilitates the automatic 'swapping' of customer antennas' wlan1 interface affiliated SSID
#whenever the customer antenna goes offline for more than 15 minutes. Or whatever interval of time
#specified.
#
#I	Usage:
#Simply, connect your computer into the antenna, open up winbox and get into the antennas routeros
#Note before hand, you will need to pause the schedule (RouterOS Guide) after running the script
#the reason for this is you need to associate your antenna with the sector before allowing the script to begin
#open up a new terminal, type "import sector_swap.txt" or ".rsc" depending on how the file was saved.
#The program will place four scripts in the Scripts section and will place a schedule in the Scheduler.
#check for them to confirm the process executed
#
#I	Info:
#It is programmed below to schedule the antennaSitter script to run every 3 minutes, with 4 fails (12 minutes)
#of the script it will initiate sector swap. This can be changed once the schedule is placed.
#
#I	Name Of Scripts:
#antennaSitter
#findBestSSID
#PingPrimarySSID
#scanSaveToFile
#
#I	Name Of Scheduler:
#SectorCheck
#
#	RouterOS Guide:
#CHANGING INTERVAL --> Scroll to bottom of script before running and find the comment explaining where to change
#I			the interval.
#PAUSING INTERVAL --> Go to System->Scheduler->Click on the schedule->disable

/system script add name=antennaSitter source="\n#Garrett Mathers --> Webfire Wireless --> Scripts --> Antennas --> Sector Swap\r\
	\n#\r\
	\n#5/25/2022\r\
	\n# \r\
	\n#Description:\r\
	\n#This script will sit on the antenna and perform this automated test for the antenna's sector ID\r\
	\n#If the antenna has no internet, increment the check fail count by one\r\
	\n#If the antenna has internet, pass the check with all good logged and reset the check fail count\r\
	\n#Designed to be ran every 15 minutes --- 4 errors = down for hour. initiate switch...\r\
	\n\r\
	\n\r\
	\n:global failCount ; \r\
	\n\r\
	\n\r\
	\n#grabbing the wireless registration for the antenna\r\
	\n:global registration [/interface wireless registration-table find] ;\r\
	\n\r\
	\n:if ([:typeof \$registration] = \"nothing\" || \$registration = \"\" ) do={\r\
	\n    :set failCount (\$failCount + 1) ; \r\
	\n    :put \"adding 1: failcount: \$failCount \" ; \r\
	\n    /log info \"Sector Swap Check: FAIL # \$failCount \" ;\r\
	\n} else={\r\
	\n    /log info \"Sector Swap Check: ALL GOOD\" ;\r\
	\n    :set failCount 0; \r\
	\n    :put \$failCount ;\r\
	\n}\r\
	\n\r\
	\n#If the fail count is equal to 4, swap the sectors\r\
	\n:if (\$failCount = 4) do={\r\
	\n    /log info \"Sector Swap Check: Swapping Sectors\" \r\
	\n    /system script run [find name=scanSaveToFile] ; \r\
	\n    /delay 2s\r\
	\n    /system script run [find name=findBestSSID] ; \r\
	\n    }"


/system script add name=findBestSSID source="\n#Garrett Mathers --> Webfire Wireless --> Scripts --> Antennas --> Sector Swap\r\
	\n#\r\
	\n#5/25/2022\r\
	\n#\r\
	\n#Purpose:\r\
	\n#This program determines the next best webfire sector antenna and then switches the antenna\r\
	\n#to the new sector automatically when ran. This is the extension of \"antenna_sitter\" \r\
	\n#meant to be used to ensure the customer maintains a connection even with sector antenna issues\r\
	\n#\r\
	\n#Usage: \r\
	\n#It will simply take the scan file produced by SCAN_SAVE_TO_FILE and parse it out accordingly\r\
	\n#Once parsed it will compare each signal and find the best signal as well as the ssid associated \r\
	\n\r\
	\n#grabbing the file created by SCAN_SAVE_TO_FILE\r\
	\n:global content [/file get [/file find name=\"wlan1scan.txt\"] contents];\r\
	\n:global contentLen [:len \$content];\r\
	\n\r\
	\n#Grabbing the old ssid for storage to swap back to after delay\r\
	\n:global primarySSID [/interface wireless get 0 ssid];\r\
	\n\r\
	\n#Showing contents and the length of the file\r\
	\n:put \$content ; \r\
	\n:put \$contentLen ;\r\
	\n:put [:typeof \$contentLen]; \r\
	\n\r\
	\n#Setting variables to hold the beginning and end of the line to create the array\r\
	\n:global lineEnd 0;\r\
	\n:global line \"\";\r\
	\n:global lastEnd 0;\r\
	\n:global comparison;\r\
	\n\r\
	\n#Meant to be switched variables - used in loop for determining best signal and ssid\r\
	\n:global bestssid;\r\
	\n:global bestsignal;\r\
	\n:set bestsignal -110 ;\r\
	\n:set bestssid \"NA/FAIL\" ; \r\
	\n:set comparison 0 ; \r\
	\n\r\
	\n#-------------------------\r\
	\n#-- Main Process begins --\r\
	\n#-------------------------\r\
	\n\r\
	\n#do this while the lastEnd is not at the last character,\r\
	\n#loops through every line and splits it into an array\r\
	\n#once the data is fully looped through we find our best ssid and signal \r\
	\n:do {\r\
	\n    :set lineEnd [:find \$content \"\n\" \$lastEnd ] ;\r\
	\n    :set line [:pick \$content \$lastEnd \$lineEnd] ;\r\
	\n    :set lastEnd ( \$lineEnd + 1 ) ;\r\
	\n\r\	
	\n    :set comparison (\$comparison + \$lineEnd) ; \r\
	\n    :local tmpArray [:toarray \$line] ;\r\
	\n\r\	
	\n    :if ( [:pick \$line 0] != \"\" ) do={\r\
	\n\t      :put \$tmpArray;\r\
	\n     	  :local mac [:pick \$tmpArray 0];\r\
	\n	  :put \$mac ; \r\
	\n	  :local ssid [:pick \$tmpArray 1];\r\
	\n	  :put \$ssid ; \r\
	\n   	  :local channel [:pick \$tmpArray 2]; \r\
	\n	  :put \$channel ; \r\
	\n	  :local signal [:pick \$tmpArray 3];\r\
	\n	  :put \$signal ; \r\
	\n  	  :local protocol [:pick \$tmpArray 4];\r\
	\n	  :put \$protocol ; \r\
	\n	  :local privacy [:pick \$tmpArray 5];\r\
	\n	  :put \$privacy ; \r\
	\n\r\		
	\n	  :put \"Array Length: \$lineEnd , Character count: \$comparison , Content Count: \$contentLen\" ;\r\
	\n\r\
	\n	  :put [:pick \$ssid 0 4] ;\r\
	\n\r\
	\n\t	#If the signal is better, and it's one of our sector antennas, \r\
	\n\t	#make this ssid and signal the new best ones\r\
	\n\t	:if (\$signal > \$bestsignal && [:pick \$ssid 0 4] =\"'wf-\") do={\r\
	\n\t		:set bestsignal (\$signal) ; \r\
	\n\t		:set bestssid (\$ssid) ;\r\
	\n\t		:put \"swapping best\" ;\r\
	\n\t		}\r\
	\n	}\r\
	\n} while ((\$lineEnd + 1) < \$contentLen)\r\
	\n\r\
	\n\r\
	\n:put \"Best Signal: \$bestsignal ... Best SSID: \$bestssid\"; \r\
	\n\r\
	\n:global date [/system clock get date] ; \r\
	\n:global time [/system clock get time] ; \r\
	\n\r\
	\n#setting the sector for the antenna to be on the best sector possible - have to pull off first\r\
	\n#and last character because of file formatting\r\
	\n:if ([:pick \$bestssid 0 4] =\"'wf-\") do={\r\
	\n	:global formatSSID [:pick \$bestssid 1 ([:len \$bestssid] - 1)] ; \r\
	\n	:put \$formatSSID ; \r\
	\n	/interface wireless set 0 ssid=\$formatSSID \r\
	\n	/system scheduler add name=primarySwap on-event=PingPrimarySSID interval=00:03:00 start-date=\$date start-time=\$time \r\
	\n}"

/system script add name=PingPrimarySSID source="\n# Garrett Mathers --> Webfire Wireless --> Scripts --> Antennas --> Sector Swap\r\
	\n#\r\
	\n# 5/26/2022\r\
	\n#\r\
	\n#\r\
	\n# Description:\r\
	\n#	This program will be launched whenever find_best_ssid is initiated.\r\
	\n#	It will simply ping the old sector antenna until it is able to reconnect\r\
	\n\r\
	\n:global primarySSID;\r\
	\n:global failCount; \r\
	\n\r\
	\n:global sectors {wf-sector1a=192.168.; wf-sector1b=192.168.; wf-sector1c=192.168.; wf-sector1d=192.168.; wf-sector2a=192.168.; wf-sector2b=192.168.; wf-sector2c=192.168.; wf-sector2d=192.168.; wf-sector3a=192.168.; wf-sector3b=192.168; wf-sector3c=192.168.; wf-sector3d=192.168.; wf-sector4=192.168.; wf-sector5=192.168; wf-sector6=192.168.; wf-sector7=192.168.; wf-sector8=192.168.; wf-sector9=192.168.};\r\
	\n:put \$sectors ;\r\
	\n\r\
	\n:put (\$sectors->\$primarySSID);\r\
	\n\r\
	\n:global primaryPing [/ping (\$sectors->\$primarySSID) count=10];\r\
	\n\r\
	\n:put \$primaryPing ;\r\
	\n\r\
	\n:if (\$primaryPing > 7) do={\r\
	\n\t	/log info \"Primary SSID back Online: Swapping back to ssid=\$primarySSID\"\r\
	\n\t	/interface wireless set 0 ssid=\$primarySSID\r\
	\n\t	/system scheduler remove [find name=primarySwap]\r\
	\n\t	:set failCount 0 ;\r\
	\n} else={\r\
	\n\t	/log info \"Primary SSID still down: #ping: \$primaryPing \" \r\
	\n}"

/system script add name=scanSaveToFile source="\n# Garrett Mathers --> Webfire Wireless --> Scripts --> Antennas --> Sector Swap\r\
	\n# 5/23/2022\r\
	\n#Description:\r\
	\n#This script scans for available Antennas and documents its findings\r\
	\n#in a file for the antenna_sitter script to pull from every 12 hours\r\
	\n#it will also declare failCount for antennaSitter to be able to manipulate it as a global variable\r\
	\n#This may create some interference if the fail count is at three say and the variable is reset. \r\
	\n#The likelihood of it happening is slim and will only result in the customer being down for an hour and 45 minutes\r\
	\n#instead of just an hour. \r\
	\n\r\
	\n#scans potential sectors without bringing the customer down\r\
	\n/interface wireless scan wlan1 background=no duration=15s save-file=wlan1scan.txt;\r\
	\n\r\
	\n#declaring failCount for antennaSitter\r\
	\n:global failCount 0 ;\r\
	\n:put [\$failCount] ;"

:global date [/system clock get date] ; 
:global time [/system clock get time] ; 

#CHANGE SCHEDULER INTERVAL ON LINE BELOW
/system scheduler add name=SectorCheck on-event=antennaSitter start-date=$date start-time=$time interval=00:03:00 





