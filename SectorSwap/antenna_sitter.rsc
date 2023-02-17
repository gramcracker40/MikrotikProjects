#Garrett Mathers --> Webfire Wireless --> Scripts --> Antennas --> Sector Swap
#
#5/25/2022
# 
#Description:
#This script will sit on the antenna and perform this automated test for the antenna's sector ID
#If the antenna has no internet, increment the check fail count by one
#If the antenna has internet, pass the check with all good logged and reset the check fail count
#Designed to be ran every ex minutes --- ex errors = down for hour. initiate switch...

#Declaring header variables
:global failCount; 

#grabbing the wireless registration for the antenna
:global registration [/interface wireless registration-table find] ;


:if ([:typeof $registration] = "nothing" || $registration = "") do={
    :set failCount ($failCount + 1) ; 
    :put "adding 1: failcount: $failCount " ; 
    /log info "Sector Swap Check: FAIL # $failCount " ;
} else={
    /log info "Sector Swap Check: ALL GOOD" ;
    :set failCount 0; 
    :put $failCount ;
}

#If the fail count is equal to 4, they have been down for an hour, swap the sectors
:if ($failCount = 4) do={
    /log info "Sector Swap Check: Swapping Sectors" 
    /system script run [find name=scanSaveToFile] ; 
    /delay 2s
    /system script run [find name=findBestSSID] ; 
    }
