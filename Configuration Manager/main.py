#from APIconnector import api
import re
import json
from ITGlue_pusher import post_configuration_itglue


def grab_variables(config_name):
    config_det = open(f"./configs/config_dictionary.json", 'r')
    configuration = json.loads(config_det.read())

    returner = {}
    found = False
    for config in configuration:
        if config['name'] == config_name:
            returner = config
            found = True
    
    if found:
        return returner
    else:
        print(f"Function Error: grab_variables() --> no config with name: {config_name}")
        return returner


def substitute_variables(config_keys, output_name, config_name=""):
    try:
        config_det = open(f"./configs/{config_name}", 'r')
        strung_v = config_det.readlines()
    except NameError as err:
        print(f"Failed to open file --> {err}, check spelling and the code in substitute_variable()")
        return

    #loops through every line of the pieced up config, on each line it tries to substitute
    # any variable values found on that line. 
    try:
        for index, part in enumerate(strung_v):
            subber = part
            for key in config_keys:
                if key in part and key != "name":
                    subber = re.sub(key, config_keys[key], part)
                    strung_v[index] = subber
    except:
        print("Failed to substitute values properly. Please check the variables and the config trying to be rewritten")
        return

    
    try:
        new_config = open(f'./generated_configs/{output_name}.txt', 'w')
        new_config.writelines(strung_v)
        print(f"Successfully wrote new config, named ---> {output_name}.txt within the generated_configs folder")
    except:
        print("Function error: substitute_variables() failed to write values to new_config file")
        return

    return f"{output_name}.txt"


def grab_values(keys):
    values = {}
    for key in keys:
        if key != "name":
            value = input(f"Please enter value for key --> {key}  ")
            values[key] = value

    return values


#Grabbing the active list of configs
name_and_id_file = open(f"./configs/name_and_id.json", "r")
name_and_id = json.loads(name_and_id_file.read())

#printing off all the configs and config names
for name in name_and_id:
    print(f"{name} : {name_and_id[name]}")
question = input("\nMikrotik Config Manager::: please type the number of the config you want below and press enter: config details will follow\n"
            +"to close out the program simply type '000' . Until then the program will run and spit out configs at your will...\n\n")

print(f"You chose {name_and_id[question]}, please ensure this is the one you wanted and fill in the values below.\n")

config_counter = 0
config_names = []
while(question != '000'):
    #grabbing all variable associated with this config
    keys = grab_variables(name_and_id[question])

    # grabbing the variables and values desired
    values = grab_values(keys)

    #opens file for corresponding config file, filters line by line to see if any keys need swapping with
    #the inputted values, rewrites the list and writes the changes to a new file designated by the user
    output_file_name = input("\nEnsure the naming is unique for storage sake\nPlease enter the desired name of the generated config file: ")
    substitution = substitute_variables(values, output_file_name, config_name=name_and_id[question])
    
    push_question = input("\nWould you like to push this configuration to ITGlue??? No --> 0 : Yes --> 1\n")
    if push_question == "1":
        config_question = input("What would you like to name the configuration?\n")
        post_configuration_itglue(config_file=f"{output_file_name}.txt", config_name=config_question)

    config_counter += 1
    config_names.append(substitution)

    question = input("If you would like, enter another number and the program will begin the process of generating a new config file"
                + "\nOtherwise, simply type '000' to exit. \n")
    
    if question != "000":
        print(f"You chose {name_and_id[question]}, please ensure this is the one you wanted and fill in the values below.")


print(f"Total configs created: {config_counter}")
print(f"Names of configs created: {config_names}")

        
#This is the settings of the connection to the mikrotik router and will be used to send the commands using the api
#connection = api.RouterOsApiPool('192.168.0.2', username='admin', password='********', port=8728, use_ssl=False, ssl_verify=True, ssl_verify_hostname=True)

#This is the module object from routeros_api-use built in methods on the list provided from the api
#commander = connection.get_api()


#files = commander.get_resource('/file').add()

#config name = russellConfig.rsc   file name = config_dictionary.json
