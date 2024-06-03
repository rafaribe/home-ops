import os
import logging
from pprint import pprint
from dopplersdk import DopplerSDK

import hvac

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


def setup_vault_client(url, token):
    client = hvac.Client(url=url, token=token)
    if not client.is_authenticated():
        raise Exception("Vault authentication failed")
    return client

def get_projects(doppler):
    projects_response = doppler.projects.list()
    return projects_response.projects

def process_project_secrets(doppler, akeyless_api, project_name, config_name):
    secrets_response = doppler.secrets.list(project=project_name, config=config_name)
    secrets = secrets_response.secrets

    logger.debug("Secret Names:")
    for secret in secrets:
        logger.debug(secret)
        secret_detail = doppler.secrets.get(project=project_name, config=config_name, name=secret)
        logger.debug(pprint(vars(secret_detail)))
        secret_body =  akeyless.CreateSecret(name=secret, tags=[project_name], value=secret_detail.value['raw'], token = token)
        api_response = akeyless_api.create_secret(secret_body)
        pprint(api_response)

def main():
    # Init envs
    access_token = os.environ.get("DOPPLER_TOKEN")
    vault_token = os.environ.get("VAULT_TOKEN")
    vault_url = os.environ.get("VAULT_URL")

    akeyless_api = setup_akeyless_sdk(akeyless_access_id, akeyless_access_key )
    doppler = setup_doppler_sdk(access_token)
    projects_json = get_projects(doppler)

    logger.debug("Project Names:")
    config_name = 'prod'
    for project in projects_json:
        project_name = project['name']
        process_project_secrets(doppler, akeyless_api, project_name, config_name)

if __name__ == '__main__':
    main()