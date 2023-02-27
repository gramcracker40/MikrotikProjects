import requests
import json
from dotenv import dotenv_values

#Connection details
config = dotenv_values(".env")

# specifying the ID of the ITGlue company to push to as well as the configuration to be push
organizationID = 6266809
mt_configuration_id = 580388

configuration_post_url = f'/organizations/{organizationID}/relationships/configurations'
headers = {'x-api-key': config['API_KEY'], 'Content-Type': 'application/vnd.api+json'}


def post_configuration_itglue(config_file, config_name):
    faker = ""
    realFaker = ""
    output = open(f"generated_configs/{config_file}", 'r')
    faker = output.readlines()

    for line in faker:
        realFaker += line

    post_configuration_data = {
        "data": {
            "type": "configurations", 
            "attributes": {
                "name": config_name,
                "configuration-type-id" : mt_configuration_id,
                "notes" : realFaker
            }
        }
    }

    postToITGlue = requests.post(url=f"{config['base_url']}{configuration_post_url}", headers=headers, data=json.dumps(post_configuration_data))

    if postToITGlue.status_code == 201:
        print(f"Post successful to ITGlue")
    else:
        print(f"{postToITGlue.text} \n Status Code: {postToITGlue.status_code}")



#post_configuration_itglue(config_file="outputsample.txt", config_name="Mikrotik test thing")

