import os
import logging
import json
from pprint import pprint
from dopplersdk import DopplerSDK

# Set the root logger's level to DEBUG
logging.getLogger().setLevel(logging.DEBUG)

# Get logger
logger = logging.getLogger("my logger")

# Create a handler and set logging level for the handler
c_handler = logging.StreamHandler()
c_handler.setLevel(logging.DEBUG)

# link handler to logger
logger.addHandler(c_handler)

def main():
    # Init envs
    access_token = os.environ.get("DOPPLER_TOKEN")
    akeyless_token = os.environ.get("AKEYLESS_TOKEN")

    doppler = DopplerSDK()  

    doppler.set_access_token(access_token)

    projects_response = doppler.projects.list()
    projects_json = projects_response.projects   
    
    logger.debug("Project Names:")
    config_name = 'prod'
    for project in projects_json:
        project_name = (project['name'])
        secrets_response = doppler.secrets.list(project = project_name, config = config_name)
        secrets = secrets_response.secrets
        
        logger.debug("Secret Names:")
        for secret in secrets:
            logger.debug(secret)
            secret_detail = doppler.secrets.get(project =project_name, config= config_name, name= secret )
            logger.debug(pprint(vars(secret_detail)))
            
        
        
if __name__ == '__main__':
    main()