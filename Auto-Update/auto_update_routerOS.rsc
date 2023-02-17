#4/22/2022 --- Webfire --- Garrett Mathers
#auto updates the router os and then reboots the router - if there is no updates to perform
#the script exits

:global checkforupdates [ /system upgrade get 0 completed ]

:if ([:typeof $checkforupdates] != nothing) do={
	/log info "Updating to the newest version of Router OS"
	/system upgrade download-all reboot-after-download=yes download-beta=no
}

	

