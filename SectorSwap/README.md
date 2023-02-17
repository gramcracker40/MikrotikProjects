# Purpose: 
SectorSwap was built as a form of automated redundancy among our wireless customers antennas.
You simply would run this script on any routerOS antenna and the antenna was given 4 scripts
and had one of those scripts to add to the scheduler to run every 3 minutes or however long was
specified. The script "antenna_sitter" simply runs as a check, once there is no established 
connection for 3-4 continous checks it will launch "sector_swap" to perform the automated swapping
and remembrance of the antenna. The swap will place the antenna on another sector antenna of the companies
the remembrance will remember the old sector antenna it was on and ping back at it every minute or so to
swap back over to it whenever it comes back online. Fool proof redundancy.
