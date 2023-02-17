Webfire Wireless Sector Swap Script
Version: 1.0  Date: 5/28/2022

I	Purpose:
Facilitates the automatic 'swapping' of customer antennas' wlan1 interface affiliated SSID
whenever the customer antenna goes offline for more than 15 minutes. Or whatever interval of time
specified.

I	Usage:
Simply, connect your computer into the antenna, open up winbox and get into the antennas routeros
Note before hand, you will need to pause the schedule (RouterOS Guide) after running the script
the reason for this is you need to associate your antenna with the sector before allowing the script to begin
open up a new terminal, type "import sector_swap.txt" or ".rsc" depending on how the file was saved.
The program will place four scripts in the Scripts section and will place a schedule in the Scheduler.
check for them to confirm the process executed

I	Info:
It is programmed below to schedule the antennaSitter script to run every 3 minutes, with 4 fails (12 minutes)
of the script it will initiate sector swap. This can be changed once the schedule is placed. Once it has initiated
Sector Swap and the antenna has regained a connection, it will launch PingPrimarySSID. It will set the Primary SSID as
a global variable within the RouterOS before it switches the SSID of the antenna. So when it does switch the SSID
it will remember which one it was on and begin sending a series of pings at it every 10 minutes to check for the ability 
to reconnect. Once it regains connection of its primary sector antenna, all of the global variables reset and Sector Swap
begins its regular checks to ensure the antenna stays online. 

I	Name Of Scripts:
#antennaSitter
#findBestSSID
#PingPrimarySSID
#scanSaveToFile
#
#I	Name Of Scheduler:
#SectorCheck
#


Webfire Wireless --> Scripts --> Antennas --> Sector Swap -> find_best_ssid
#5/25/2022

Purpose:
#This program determines the next best webfire sector antenna and then switches the antenna
#to the new sector automatically when ran. This is the extension of "antenna_sitter" 
#meant to be used to ensure the customer maintains a connection even with sector antenna issues
Usage: 
#It will simply take the scan file produced by SCAN_SAVE_TO_FILE and parse it out accordingly
#Once parsed it will compare each signal and find the best signal as well as the ssid associated 


Webfire Wireless --> Scripts --> Antennas --> Sector Swap -> antenna_sitter
#
#5/25/2022
# 
#Description:
#This script will sit on the antenna and perform this automated test for the antenna's sector ID
#If the antenna has no internet, increment the check fail count by one
#If the antenna has internet, pass the check with all good logged and reset the check fail count
#Designed to be ran every ex minutes --- ex errors = down for hour. initiate switch...


Webfire Wireless --> Scripts --> Antennas --> Sector Swap -> scan_save_to_file
5/23/2022
#This script scans for available Antennas and documents its findings
#in a file for the antenna_sitter script to pull from every 12 hours
#it will also declare failCount for antennaSitter to be able to manipulate it as a global variable
#This may create some interference if the fail count is at three say and the variable is reset. 
#The likelihood of it happening is slim and will only result in the customer being down for an hour and 45 minutes
#instead of just an hour. 


Webfire Wireless --> Scripts --> Antennas --> Sector Swap -> ping_primary_ssid
# 5/26/2022
# Description:
#	This program will be launched whenever find_best_ssid is initiated.
#	It will simply ping the old sector antenna until it is able to reconnect
#	When the old one it was on comes back online, it will reassociate its SSID
#	to be the same as it was before the outage. 