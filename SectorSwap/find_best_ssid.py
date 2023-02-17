#!/usr/bin/python
import routeros_api
import sockets
import json
import pprint
import requests
from datetime import datetime
import time
import datetime

#creating a pretty printer - used to debug the antenna objects and files
nice_printer = pprint.PrettyPrinter(indent=2)

#creating the current date as a callable object along with a time 6 seconds in the future
currentDateAndTime = datetime.datetime.now()
futureDateAndTime = currentDateAndTime + datetime.timedelta(0,20)

##################################################################################################
# Class:    class potential_antenna(object):
# 
# Description: organizes the antennas into a consistent format easy for the program to use
# Usage:       put the results of the scan into this format with the usage of functions below
# 
##################################################################################################
class potential_antenna(object):
    def __init__(self, mac_address, ssid, ant_channel, sig_strength, protocol_used, privacy_setting):
        self.mac = mac_address
        self.ssid = ssid
        self.channel = ant_channel
        self.signal = sig_strength
        self.protocol = protocol_used
        self.privacy = privacy_setting

    def __str__(self):
        return f"SSID: {self.ssid}, MAC: {self.mac}, SIGNAL: {self.signal}"


##################################################################################################
# Function:    def parse_file(scan_file):
# 
# Description: goes into a list of antennas and turns them into "potential_antennas"
# Usage:       used to facilitate ease of use across the program with OOP style
# 
##################################################################################################
def parse_file(scan_file):
    #Collecting all relevant data for each antenna
    all_potential = []

    for each in scan_file:

        info = each.split(",")

        if(len(info) < 2):
            print("Processing complete")
        else:
            potential = potential_antenna(info[0], info[1], info[2], int(info[3]), info[4], info[5])
            all_potential.append(potential)

    return all_potential


##################################################################################################
# Function:    def filter_antennas(all_potential):
# 
# Description: filters out any antennas who are not an available connection for the client 
# Usage:       used in best_ssid_swap to sort out the antennas before picking the best one
# 
##################################################################################################
def filter_antennas(all_potential):
    available_ssid = ['wf-sector1a', 'wf-sector1b', 'wf-sector1c', 'wf-sector1d', 'wf-sector2a', 'wf-sector2b', 'wf-sector2c', 'wf-sector2d', 'wf-sector3a', 'wf-sector3b', 'wf-sector3c', 'wf-sector3d', 'wf-sector4', 'wf-sector5', 'wf-sector5a', 'wf-sector6', 'wf-sector7', 'wf-sector8', 'wf-sector9']

    actual_use = []

    for potential in all_potential:
        if potential.ssid in available_ssid:
            actual_use.append(all_potential)

    return actual_use


##################################################################################################
# Function:    def find_best_antenna(actual_antennas):
# 
# Description: grabs and returns the antenna with the best signal
#              from a list of antennas 
# Usage:       Used to troubleshoot the program
# 
##################################################################################################
def find_best_antenna(actual_antennas):
    best_signal = -110
    best_antenna = potential_antenna('0', '0', '0', '0', '0', '0')

    counter = 0 
    for antenna in actual_antennas:
        if antenna.signal > best_signal and antenna.ssid != '':
            best_antenna = antenna
            best_signal = antenna.signal
       
        counter += 1

    return best_antenna

##################################################################################################

##################################################################################################
# Function:    def print_out_antennas(list_of_antennas):
# 
# Description: print out all of the antennas in a parsed list of antennas 
# Usage:       Used to troubleshoot the program
# 
##################################################################################################
def print_out_antennas(list_of_antennas):
    counter = 0
    for antennas in list_of_antennas:
        print(f"{counter}: {str(antennas)}")
        counter += 1

##################################################################################################

##################################################################################################
# Function:    best_ssid_swap():
# 
# Description: Simply call this function after you have connected to your router
#              to be able to grab the two best antenna connections near you 
#              helps automate and facilitate automated communications for wireless customers
# Usage:       please make sure you run a scan on your wlan1 and enable the option to save to a file
#              or have a script that does it every now and then. 
# 
##################################################################################################
def best_ssid_swap():
    # Grabbing the appropriate file
    scan_results = api.get_resource('/file').get(name="wlan1scan.txt")

    # Parsing the file elements in to seperate elements
    antenna_info = scan_results[0]['contents'].split(",\n")

    # This takes the seperate elements and creates the potential_antenna list of objects
    parsed_antennas = parse_file(antenna_info)

    #filtered_antennas = filter_antennas(parsed_antennas)

    # finally, we choose the singular best antenna to switch the mikrotik too
    best_swap = find_best_antenna(parsed_antennas)

    #remove the best antenna and then find the second best antenna
    parsed_antennas.remove(best_swap)
    second_best = find_best_antenna(parsed_antennas)


    return best_swap, second_best


##################################################################################################
#
# Start of the main process
#
##################################################################################################

#Establishing a connection
connection = routeros_api.RouterOsApiPool('192.168.0.2', username='admin', password='Secure105!', port=8728, use_ssl=False, ssl_verify=True, ssl_verify_hostname=True)

#creating our module object to run commands against
api = connection.get_api()

#Grabbing the two best antennas   ----- reference the function above
best_ssid, second_ssid = best_ssid_swap()

# Test: Which ones did they connect to
# print("First best: " + str(best_ssid))
# print("Second best: " + str(second_ssid))

#Getting all file paths ready for easy access to mikrotik
files = api.get_resource('/file')
scripts = api.get_resource('/system/script')
scheduler = api.get_resource('/system/scheduler')

#rearranging date/time into mikrotik format
month_nums = {'01':'jan', '02':'feb', '03':'mar', '04':'apr', '05':'may', '06':'jun', '07':'jul', '08':'aug', '09':'sep', '10':'oct', '11':'nov', '12':'dec'}

date, curtime = str(futureDateAndTime).split(' ', 1)
year, month, day = date.split('-')
format_date = f"{month_nums[month]}/{day}/{year}"
curtime, _ = str(curtime).split('.', 1)

# Explanation of Logic: try: try to add the script that will create the file. 
# exception: if it already exists then delete it and readd it
try:
    scripts.add(name="createSSIDfile", source=f'/file print file=bestSSID.txt;/delay 2s;/file set bestSSID.txt content="{best_ssid.ssid},{second_ssid.ssid}"')
    scheduler.add(name="ssid_file_creation", on_event="createSSIDfile", start_date=format_date, start_time=curtime, interval="700d")
    time.sleep(15)
except:
    print("File already created...deleting the script/scheduler and readding them")
    
    scripts.remove(id='createSSIDfile')
    scheduler.remove(id='ssid_file_creation')
    
    #If the file already exists, delete it 
    if files.get(name="bestSSID.txt"):   
        files.remove(id="bestSSID.txt")
    
    scripts.add(name="createSSIDfile", source=f'/file print file=bestSSID.txt;/delay 2s;/file set bestSSID.txt content="{best_ssid.ssid},{second_ssid.ssid}"')
    scheduler.add(name="ssid_file_creation", on_event="createSSIDfile", start_date=format_date, start_time=curtime, interval="700d")
    time.sleep(15)


# Test: See what contents the file holds
ssid_file = api.get_resource('/file').get(name="bestSSID.txt")
nice_printer.pprint(ssid_file)

#disconnecting the mikrotik
connection.disconnect()



#------------------------------------#
#  The code below deals with changing the ssid configuration
#------------------------------------#
#add the api call back to the router to change config
#antenna = api.get_resource('/interface/wireless')
#nice_printer.pprint(antenna_ssid.get())

# antenna_ssid = antenna.get()
# print(type(antenna.get('ssid')['ssid']) + "SECTOR" + best_swap.ssid)

#swapping the first wireless interfaces ssid
#antenna.set(id="*1", ssid=best_swap.ssid)



#-------------------------------------#
# The code below is strictly example code to better understand the API
#-------------------------------------#
# #pulling the list of wireless interfaces
# list_of_interfaces = api.get_resource('/interface/wireless')
# neat_interfaces = str(list_of_interfaces.get(name='wlan1'))
#
# #printing wireless interfaces with pretty printer
# nice_printer.pprint(neat_interfaces)

