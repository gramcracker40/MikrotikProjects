import requests
import json
from dotenv import dotenv_values

#Connection details
config = dotenv_values(".env")
#Connection details
API_KEY = config["API_KEY"]
baseUrl = config["base_url"]
organizationID = 6266809
configuration_post = f'/organizations/{organizationID}/relationships/configurations'

mt_configuration_id = 580388

allHeaders = {'x-api-key': API_KEY, 'Content-Type': 'application/vnd.api+json'}


def post_configuration_itglue(config_file, config_name):
    faker = ""
    realFaker = ""
    faker = config_file.readlines()

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

    postToITGlue = requests.post(url = f"{baseUrl}{configuration_post}", headers=allHeaders, data=json.dumps(post_configuration_data))

    if postToITGlue.status_code == 201:
        print(f"Post successful to ITGlue")
    else:
        print(f"{postToITGlue.text} \n Status Code: {postToITGlue.status_code}")

output = open("outputsample.txt", "r")

post_configuration_itglue(output, "outputsample.txt")

