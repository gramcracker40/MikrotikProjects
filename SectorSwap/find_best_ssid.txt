#Garrett Mathers --> Webfire Wireless --> Scripts --> Antennas --> Sector Swap
#
#5/25/2022
#
#Purpose:
#This program determines the next best webfire sector antenna and then switches the antenna
#to the new sector automatically when ran. This is the extension of "antenna_sitter" 
#meant to be used to ensure the customer maintains a connection even with sector antenna issues
#
#Usage: 
#It will simply take the scan file produced by SCAN_SAVE_TO_FILE and parse it out accordingly
#Once parsed it will compare each signal and find the best signal as well as the ssid associated 

#grabbing the file created by SCAN_SAVE_TO_FILE
:global content [/file get [/file find name="wlan1scan.txt"] contents];
:global contentLen [:len $content];

#Grabbing the old ssid for storage - to swap back to after delay
:global primarySSID [/interface wireless get 0 ssid];

#Showing contents and the length of the file
:put $content ; 
:put $contentLen ;
:put [:typeof $contentLen]; 

#Setting variables to hold the beginning and end of the line to create the array
:global lineEnd 0;
:global line "";
:global lastEnd 0;
:global comparison; 

#Meant to be switched variables - used in loop for determining best signal and ssid
:global bestssid;
:global bestsignal;
:set bestsignal -110 ;
:set bestssid "NA/FAIL" ; 
:set comparison 0 ; 

#-------------------------
#-- Main Process begins --
#-------------------------

#do this while the lastEnd is not at the last character,
#loops through every line and splits it into an array
#once the data is fully looped through we find our best ssid and signal 
:do {
    :set lineEnd [:find $content "\n" $lastEnd ] ;
    :set line [:pick $content $lastEnd $lineEnd] ;
    :set lastEnd ( $lineEnd + 1 ) ;
	
    :set comparison ($comparison + $lineEnd) ; 
    :local tmpArray [:toarray $line] ;
	
    :if ( [:pick $line 0] != "" ) do={
	:put $tmpArray;
    :local mac [:pick $tmpArray 0];
	:put $mac ; 
	:local ssid [:pick $tmpArray 1]; 
	:put $ssid ; 
    :local channel [:pick $tmpArray 2]; 
	:put $channel ; 
	:local signal [:pick $tmpArray 3];
	:put $signal ; 
    :local protocol [:pick $tmpArray 4];
	:put $protocol ; 
	:local privacy [:pick $tmpArray 5];
	:put $privacy ; 
		
	:put "Array Length: $lineEnd , Character count: $comparison , Content Count: $contentLen" ;
	
	:put [:pick $ssid 0 4] ;

	#If the signal is better, and it's one of our sector antennas, 
	#make this ssid and signal the new best ones
	:if ($signal > $bestsignal && [:pick $ssid 0 4] ="'wf-") do={
		:set bestsignal ($signal) ; 
		:set bestssid ($ssid) ;
		:put "swapping best" ;
		}
	}
} while (($lineEnd + 1) < $contentLen)


:put "Best Signal: $bestsignal ... Best SSID: $bestssid"; 

:global date [/system clock get date] ; 
:global time [/system clock get time] ; 

/log info "Switched SSID ---> $bestssid " 

#setting the sector for the antenna to be on the best sector possible - have to pull off first
#and last character because of file formatting
:if ([:pick $bestssid 0 4] ="'wf-") do={
	:global formatSSID [:pick $bestssid 1 ([:len $bestssid] - 1)] ; 
	:put $formatSSID ; 
	/interface wireless set 0 ssid=$formatSSID 
	/system scheduler add name=primarySwap on-event=PingPrimarySSID interval=00:03:00 start-date=$date start-time=$time 
}

#Explanation of code:

#This line of code checks to make sure the first three letters of the ssid
#are simply 'w' then 'f' then '-' to make sure they are one of our sector antennas
#&& ($ssidA->0) = "w" && ($ssidA->1) = "f" && ($ssidA->2) = "-"

