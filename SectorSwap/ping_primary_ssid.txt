# Garrett Mathers --> Webfire Wireless --> Scripts --> Antennas --> Sector Swap
#
# 5/26/2022
#
#
# Description:
#	This program will be launched whenever find_best_ssid is initiated.
#	It will simply ping the old sector antenna until it is able to reconnect
#	When the old one it was on comes back online, it will reassociate its SSID
#	to be the same as it was before the outage. 

:global primarySSID;
:global failCount; 

:global sectors {wf-sector1a=192.168.20.177; wf-sector1b=192.168.20.178; wf-sector1c=192.168.20.179; wf-sector1d=192.168.20.180; wf-sector2a=192.168.20.181; wf-sector2b=192.168.20.182; wf-sector2c=192.168.20.183; wf-sector2d=192.168.20.184; wf-sector3a=192.168.20.185; wf-sector3b=192.168.20.186; wf-sector3c=192.168.20.187; wf-sector3d=192.168.20.188; wf-sector4=192.168.20.251; wf-sector5=192.168.20.250; wf-sector6=192.168.20.249; wf-sector7=192.168.20.237; wf-sector8=192.168.20.226; wf-sector9=192.168.20.207 };
:put $sectors ;

:put ($sectors->$primarySSID);

:global primaryPing [/ping ($sectors->$primarySSID) count=10]; 

:put $primaryPing ; 

:if ($primaryPing > 7) do={
	/log info "Primary SSID back Online: Swapping back to ssid=$primarySSID"
	/interface wireless set 0 ssid=$primarySSID
	/system scheduler remove [find name=primarySwap]
	:set failCount 0 ; 
} else={
	/log info "Primary SSID still down: #ping: $primaryPing " 
}

