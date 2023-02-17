#Automated MikroTik SNTP Client Primary NTP Check and Update
#4/13/2022
#This script was built to trouble shoot the issue behind the NTP values being different due to 
#DHCP switching of the IP's, this script will check the IP's on a user determined time basis to 
#perform regular checks on the values. It will switch the DHCP servers networks NTP values if necessary with the 
#last updated NTP from the SNTP client. Uses looping to change each DHCP server to the appropriate NTP value.

#Start of main process
:put "Checking current NTP servers within network/router.";

#pulling the enabled/disabled configuration for the SNTP client
:global sntpcheck [/system ntp client get enabled];

#Last updated NTP --- SNTP client
:global lastupdatedntp [/system ntp client get last-update-from];

#The current DHCP server's NTP
:global networkntp [/ip dhcp-server network get 0 ntp-server];

#Provides a number of total DHCP server networks
:global networktotal [/ip dhcp-server network find];
:put [:len $networktotal]

#Variable checking area, purpose: debugging.
#sntpcheck variable stats
:put [:typeof $sntpcheck];
:put [$sntpcheck];
#Last updated variable stats
:put [$lastupdatedntp];
:put [:typeof $lastupdatedntp];
#Network NTP variable stats
:put [$networkntp];
:put [:typeof $networkntp];


#explanation of logic: if the SNTP client is enabled, both NTP's are not equal to each other and the last updated
#ntp server actually holds a value ---- then change the Network's NTP
#If there are multiple
:if ($sntpcheck = true && $lastupdatedntp != $networkntp && [:typeof $lastupdatedntp] != "nil" && [:typeof $lastupdatedntp] != "nothing") do={
	:for i from=0 to=([:len $networktotal] - 1) do={
		/ip dhcp-server network set 0 ntp-server=$lastupdatedntp
		/log info "(NTP Script) ALL DHCP servers, NTP changed to $lastupdatedntp"
		}
}

#Check to see if the IP addresses are the same
:if ($lastupdatedntp = $networkntp && $sntpcheck = true) do={
        /log info "(NTP Script) IP's are the same, check concluded..."      
        }

#Check to see if the SNTP Client is enabled/disabled
:if ($sntpcheck != true) do={ 
        /log info "(NTP Script) The SNTP client is disabled... Unable to check IP's"
        }

#Check to see if last updated is empty or not
:if ( [ :typeof $lastupdatedntp ] = "nil" ) do={
        /log info "(NTP Script) The last updated section in SNTP client is falsified/empty."
        }


#Check to see if the SNTP Client has been initialized yet
:if ( [ :typeof $lastupdatedntp ] = "nothing" ) do={
	/log info "(NTP Script) The SNTP Client has not yet been initialized yet, please initialize it."
}
