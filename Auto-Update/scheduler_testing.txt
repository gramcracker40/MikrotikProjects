#This script will add the automatic updates and NTP check scripts to be automatically 
#configured whenever we run the default configuration script
#In progress--- Does not work...

:global currdate [/system clock get date];

/system scheduler add name="Router OS Update" start-date=$currdate start-time=01:00:00 interval=48:00:00 on-event={:global checkforupdates [ /system upgrade get 0 completed ]

:if ([:typeof $checkforupdates] != nothing) do={
	/log info "Updating to the newest version of Router OS"
	/system upgrade download-all reboot-after-download=yes download-beta=no
}}

/system scheduler add name="Firmware Update" start-date=$currdate start-time=01:15:00 interval=48:00:00 on-event={:global currfirm [ /system routerboard get current-firmware ];
:global upgradefirm [ /system routerboard get upgrade-firmware ];

:if ($currfirm != $upgradefirm) do={
	/log info "Updating firmware from ver: $currfirm to ver: $upgradefirm"
	/system routerboard upgrade
	y
	/system reboot
	y
}}







