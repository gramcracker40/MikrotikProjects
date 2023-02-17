# Purpose: 
SectorSwap was built as a form of automated redundancy among our wireless customers antennas.
You simply would run this script on any routerOS antenna the below explanation will go over each scripts purpose
The script "antenna_sitter" simply runs as a check, once there is no established 
connection for 3-4 continous checks it will launch "sector_swap" to perform the automated swapping
The swap will place the antenna on another sector antenna of the companies

to choose from whenever the antenna needs to switch. You can filter based off IP, signal strength, etc. just
run scan_save_to_file.txt in the mikrotik to see what fields are available in the returned scan file that
gets save to the mikrotik for us to go off of in the scripting. 
Since the scan takes a while we have to do it this way. 
Scan first, determine second. 

You must specify the companies sector antennas in an array with their ip's as values, or whatever attribute you want to check for each of them 
to be able to properly determine.

Whenever the swap is performed, another script will be sent to the scheduler. 
ping_primary_ssid.txt will ping the original sector antennas ip address to try to get back on whenever it comes back up. 
This way, a network administrator would not have to play clean up after this script runs. Must have list of sector antenna
names and ip's in order to do this


SCRIPTS:
sector_swap.rsc
antenna_sitter.rsc
scan_save_to_file.rsc
ping_primary_ssid.rsc

main.rsc will be the installer originally built. format as needed
