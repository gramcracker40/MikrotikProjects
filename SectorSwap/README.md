
---

# Webfire Wireless Sector Swap Script
**Version:** 1.0  
**Date:** 5/28/2022

## Purpose
Facilitates the automatic swapping of customer antennas' wlan1 interface affiliated SSID whenever the customer antenna goes offline for more than 15 minutes, or any specified interval of time.

## Usage
1. Connect your computer to the antenna and open Winbox to access the antenna's RouterOS.
2. Pause the schedule (see RouterOS Guide) after running the script. This is necessary to associate your antenna with the sector before allowing the script to begin.
3. Open a new terminal and type `import sector_swap.txt` or `.rsc` (depending on file format).
4. The program will place four scripts in the Scripts section and a schedule in the Scheduler. Check these to confirm execution.

## Info
The `antennaSitter` script is scheduled to run every 3 minutes. After 4 fails (12 minutes) without a connection, `sectorSwap` is initiated. Upon reconnection, `PingPrimarySSID` is launched. It sets the Primary SSID as a global variable within RouterOS, allowing the system to reconnect to the original SSID when possible. Global variables reset once the primary connection is re-established, and regular checks resume.

## Scripts
1. **antennaSitter**: Monitors the antenna's connection status.
2. **findBestSSID**: Determines the next best sector antenna and switches the antenna to it automatically.
3. **PingPrimarySSID**: Pings the original sector antenna's IP address to attempt reconnection.
4. **scanSaveToFile**: Scans for available antennas and saves findings for `antennaSitter`.

## Scheduler
- **SectorCheck**

---

### find_best_ssid
**Date:** 5/25/2022

#### Purpose
Determines the next best Webfire sector antenna and switches the antenna to the new sector automatically. This script is an extension of `antenna_sitter`.

#### Usage
Takes the scan file from `SCAN_SAVE_TO_FILE`, parses it, and finds the best signal and its associated SSID.

---

### antenna_sitter
**Date:** 5/25/2022

#### Description
This script monitors the antenna's sector ID and internet connection status. It increments a fail count for each check without internet and resets this count when the internet is available. It's designed to initiate a switch after a specified number of failures.

---

### scan_save_to_file
**Date:** 5/23/2022

#### Description
Scans for available antennas and documents findings for `antenna_sitter`. It also declares a global `failCount` variable for `antennaSitter`.

---

### ping_primary_ssid
**Date:** 5/26/2022

#### Description
Launched when `find_best_ssid` is initiated. Pings the previous sector antenna until reconnection is possible, then reassociates the SSID to the original one before the outage.

---
