#4/22/2022 --- Webfire --- Garrett Mathers
#automatically upgrades the firmware and then reboots the router
#if the current firmware and the upgradable firmware aren't the same

:global currfirm [ /system routerboard get current-firmware ];
:global upgradefirm [ /system routerboard get upgrade-firmware ];

:if ($currfirm != $upgradefirm) do={
	/log info "Updating firmware from ver: $currfirm to ver: $upgradefirm"
	/system routerboard upgrade
	y
	/system reboot
	y
}



