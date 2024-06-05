import os
import logging
import json
from pprint import pprint
from dopplersdk import DopplerSDK

import akeyless

# Set the root logger's level to DEBUG
logging.getLogger().setLevel(logging.DEBUG)

# Get logger
logger = logging.getLogger("logger")

# Create a handler and set logging level for the handler
c_handler = logging.StreamHandler()
c_handler.setLevel(logging.DEBUG)

# link handler to logger
logger.addHandler(c_handler)

# Global token variable
token = None

def setup_doppler_sdk(access_token):
    doppler = DopplerSDK()
    doppler.set_access_token(access_token)
    return doppler

configuration = akeyless.Configuration(
        # default: public API Gateway
        host = "https://api.akeyless.io"
)
def setup_akeyless_sdk(akeyless_access_id, akeyless_access_key):
    global token
    api_client = akeyless.ApiClient(configuration)
    api = akeyless.V2Api(api_client)

    body = akeyless.Auth(access_id=akeyless_access_id, access_key=akeyless_access_key)
    res = api.auth(body)
    token = res.token
    return api

def get_projects(doppler):
    projects_response = doppler.projects.list(per_page=200)
    return projects_response.projects

def process_project_secrets(doppler, akeyless_api, project_name, config_name):
    secrets_response = doppler.secrets.list(project=project_name, config=config_name)
    secrets = secrets_response.secrets

    logger.debug("Secret Names:")
    for secret in secrets:
        logger.debug(secret)
        secret_detail = doppler.secrets.get(project=project_name, config=config_name, name=secret)
        logger.debug(pprint(vars(secret_detail)))
        secret_name_with_path = f'{project_name}'
        try:
            describe_item_body = akeyless.DescribeItem(name=secret_name_with_path, token=token)
            api_response = akeyless_api.describe_item(describe_item_body)
            # If the response is positive, do some action
            logger.debug(f"Secret {secret_name_with_path} exists. Skipping")
            # Add your action for existing secret here
        except akeyless.exceptions.ApiException as e:
            # If an exception occurs, log the error and do other action
            secret_body =  akeyless.CreateSecret(name=secret_name_with_path, tags=[project_name], value=secret_detail.value['raw'], token = token)
            api_response = akeyless_api.create_secret(secret_body)
            logger.debug(f"Secret {secret_name_with_path} Created")
            
def process_project_secrets_json(doppler, akeyless_api, project_name, config_name):
    secrets_response = doppler.secrets.list(project=project_name, config=config_name)
    secrets = secrets_response.secrets

    logger.debug("Secret Names:")
    secrets_json = {}
    for secret in secrets:
        if not secret.startswith("DOPPLER"):
            secret_detail = doppler.secrets.get(project=project_name, config=config_name, name=secret)
            secrets_json[secret_detail.name] = secret_detail.value['raw']
    logger.debug(secrets_json)
    value_json = json.dumps(secrets_json)
    secret_body =  akeyless.CreateSecret(name=project_name, tags=[project_name], value=value_json, token = token, json=True, format='json')
    api_response = akeyless_api.create_secret(secret_body)
    logger.debug(f"Secret {project_name} Created")
    
def delete_all_akeyless_secrets(akeyless_api, items):
    for item in items:
        body = akeyless.DeleteItem(token=token, name=item)
        res = akeyless_api.delete_item(body)
        logger.debug(f'deleted {item}')
    logger.debug('finish deleting')

def list_all_items(akeyless_api):
    list_body = akeyless.ListItems(token = token, auto_pagination = 'enabled')
    list_items = akeyless_api.list_items(list_body)
    item_paths = []
    for item in list_items.items:
        item_paths.append(item.item_name)
    return item_paths

def main():
    # Init envs
    access_token = os.environ.get("DOPPLER_TOKEN")
    akeyless_access_id = os.environ.get("AKEYLESS_ACCESS_ID")
    akeyless_access_key = os.environ.get("AKEYLESS_ACCESS_KEY")

    akeyless_api = setup_akeyless_sdk(akeyless_access_id, akeyless_access_key )
    doppler = setup_doppler_sdk(access_token)
    projects_json = get_projects(doppler)

    logger.debug("Project Names:")
    config_name = 'prod'
    for project in projects_json:
        project_name = project['name']
        process_project_secrets_json(doppler, akeyless_api, project_name, config_name)

if __name__ == '__main__':
    main()