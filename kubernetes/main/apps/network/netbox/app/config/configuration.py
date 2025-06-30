import os
import re
from pathlib import Path

# For reference see http://netbox.readthedocs.io/en/latest/configuration/mandatory-settings/
# Based on https://github.com/netbox-community/netbox/blob/develop/netbox/netbox/configuration.example.py

# Read secret from file
def _read_secret(secret_name, default=None):
    try:
        f = open('/run/secrets/' + secret_name, 'r', encoding='utf-8')
    except EnvironmentError:
        return default
    else:
        with f:
            return f.readline().strip()

BASE_PATH = Path(__file__).resolve().parent.parent.parent

#########################
#                       #
#   Required settings   #
#                       #
#########################

# This is a list of valid fully-qualified domain names (FQDNs) for the NetBox server. NetBox will not permit write
# access to the server via any other hostnames. The first FQDN in the list will be treated as the preferred name.
#
# Example: ALLOWED_HOSTS = ['netbox.example.com', 'netbox.internal.local']
ALLOWED_HOSTS = ['*']

# PostgreSQL database configuration. See the Django documentation for a complete list of available parameters:
#   https://docs.djangoproject.com/en/stable/ref/settings/#databases
DATABASE = {
    'NAME': os.environ.get('DB_NAME', 'netbox'),
    'USER': os.environ.get('DB_USER', 'netbox'),
    'PASSWORD': os.environ.get('DB_PASSWORD', ''),
    'HOST': os.environ.get('DB_HOST', 'localhost'),
    'PORT': os.environ.get('DB_PORT', ''),
    'CONN_MAX_AGE': int(os.environ.get('DB_CONN_MAX_AGE', '300')),
}

# Redis database settings. Redis is used for caching and for queuing background tasks such as webhook events. A separate
# configuration exists for each. Full connection details are required in both sections, and it is strongly recommended
# to use two separate database IDs.
REDIS = {
    'tasks': {
        'HOST': os.environ.get('REDIS_HOST', 'localhost'),
        'PORT': int(os.environ.get('REDIS_PORT', 6379)),
        'PASSWORD': os.environ.get('REDIS_PASSWORD', ''),
        'DATABASE': int(os.environ.get('REDIS_DATABASE', 0)),
        'SSL': os.environ.get('REDIS_SSL', 'False').lower() == 'true',
    },
    'caching': {
        'HOST': os.environ.get('REDIS_HOST', 'localhost'),
        'PORT': int(os.environ.get('REDIS_PORT', 6379)),
        'PASSWORD': os.environ.get('REDIS_PASSWORD', ''),
        'DATABASE': int(os.environ.get('REDIS_CACHE_DATABASE', 1)),
        'SSL': os.environ.get('REDIS_SSL', 'False').lower() == 'true',
    }
}

# This key is used for secure generation of random numbers and strings. It must never be exposed outside of this file.
# For optimal security, SECRET_KEY should be at least 50 characters in length and contain a mix of letters, numbers, and
# symbols. NetBox will not run without this defined. For more information, see
# https://docs.djangoproject.com/en/stable/ref/settings/#std:setting-SECRET_KEY
SECRET_KEY = os.environ.get('SECRET_KEY', '')

#########################
#                       #
#   Optional settings   #
#                       #
#########################

# Specify one or more name and email address tuples representing NetBox administrators. These people will be notified of
# application errors (assuming correct email settings are provided).
ADMINS = [
    # ['John Doe', 'jdoe@example.com'],
]

# URL schemes that are allowed within links in NetBox
ALLOWED_URL_SCHEMES = (
    'file', 'ftp', 'ftps', 'http', 'https', 'irc', 'mailto', 'sftp', 'ssh', 'tel', 'telnet', 'tftp', 'vnc', 'xmpp',
)

# Optionally display a persistent banner at the top and/or bottom of every page.
# HTML is allowed. To display the same content in both banners, define BANNER_TOP and set BANNER_BOTTOM = BANNER_TOP.
BANNER_TOP = os.environ.get('BANNER_TOP', '')
BANNER_BOTTOM = os.environ.get('BANNER_BOTTOM', '')

# Text to include on the login page above the login form. HTML is allowed.
BANNER_LOGIN = os.environ.get('BANNER_LOGIN', '')

# Base URL path if accessing NetBox within a directory. For example, if installed at https://example.com/netbox/, set:
# BASE_PATH = 'netbox/'
BASE_PATH = os.environ.get('BASE_PATH', '')

# API Cross-Origin Resource Sharing (CORS) settings. If CORS_ORIGIN_ALLOW_ALL is set to True, all origins will be
# allowed. Otherwise, define a list of allowed origins using either CORS_ORIGIN_WHITELIST or
# CORS_ORIGIN_REGEX_WHITELIST. For more information, see https://github.com/adamchainz/django-cors-headers
CORS_ORIGIN_ALLOW_ALL = os.environ.get('CORS_ORIGIN_ALLOW_ALL', 'False').lower() == 'true'
CORS_ORIGIN_WHITELIST = [
    # 'https://hostname.example.com',
]
CORS_ORIGIN_REGEX_WHITELIST = [
    # r'^(https?://)?(\w+\.)?example\.com$',
]

# Set to True to enable server debugging. WARNING: Debugging introduces a substantial performance penalty and may reveal
# sensitive information about your installation. Only enable debugging while performing testing. Never enable debugging
# on a production system.
DEBUG = os.environ.get('DEBUG', 'False').lower() == 'true'

# Email settings
EMAIL = {
    'SERVER': os.environ.get('EMAIL_SERVER', 'localhost'),
    'PORT': int(os.environ.get('EMAIL_PORT', 25)),
    'USERNAME': os.environ.get('EMAIL_USERNAME', ''),
    'PASSWORD': os.environ.get('EMAIL_PASSWORD', ''),
    'USE_SSL': os.environ.get('EMAIL_USE_SSL', 'False').lower() == 'true',
    'USE_TLS': os.environ.get('EMAIL_USE_TLS', 'False').lower() == 'true',
    'TIMEOUT': int(os.environ.get('EMAIL_TIMEOUT', 10)),
    'FROM_EMAIL': os.environ.get('EMAIL_FROM', ''),
}

# Enforcement of unique IP space can be toggled on a per-VRF basis. To enforce unique IP space within the global table
# (all prefixes and IP addresses not assigned to a VRF), set ENFORCE_GLOBAL_UNIQUE to True.
ENFORCE_GLOBAL_UNIQUE = os.environ.get('ENFORCE_GLOBAL_UNIQUE', 'False').lower() == 'true'

# Exempt certain models from the enforcement of view permissions. Models listed here will be viewable by all users and
# by anonymous users. List models in the form `<app>.<model>`. Add '*' to this list to exempt all models.
EXEMPT_VIEW_PERMISSIONS = [
    # 'dcim.site',
    # 'dcim.region',
    # 'ipam.prefix',
]

# HTTP proxies NetBox should use when sending outbound HTTP requests (e.g. for webhooks).
# HTTP_PROXIES = {
#     'http': 'http://10.10.1.10:3128',
#     'https': 'http://10.10.1.11:1080',
# }

# IP addresses recognized as internal to the system. The debugging toolbar will be available only to clients accessing
# NetBox from an internal IP.
INTERNAL_IPS = ('127.0.0.1', '::1')

# Enable custom logging. Please see the Django documentation for detailed guidance on configuring custom logs:
#   https://docs.djangoproject.com/en/stable/topics/logging/
LOGGING = {}

# Automatically reset the lifetime of a valid session upon each authenticated request. Enables users to remain
# authenticated to NetBox indefinitely.
LOGIN_PERSISTENCE = os.environ.get('LOGIN_PERSISTENCE', 'False').lower() == 'true'

# Setting this to True will permit only authenticated users to access any part of NetBox. By default, anonymous users
# are permitted to access most data in NetBox but not make any changes.
LOGIN_REQUIRED = os.environ.get('LOGIN_REQUIRED', 'False').lower() == 'true'

# The length of time (in seconds) for which a user will remain logged into the web UI before being prompted to
# re-authenticate. (Default: 1209600 [14 days])
LOGIN_TIMEOUT = int(os.environ.get('LOGIN_TIMEOUT', 1209600))

# Setting this to True will display a "maintenance mode" banner at the top of every page.
MAINTENANCE_MODE = os.environ.get('MAINTENANCE_MODE', 'False').lower() == 'true'

# An API consumer can request an arbitrary number of objects =by appending the "limit" parameter to the URL (e.g.
# "?limit=1000"). This setting defines the maximum limit. Setting it to 0 or None will allow an API consumer to request
# all objects by specifying "?limit=0".
MAX_PAGE_SIZE = int(os.environ.get('MAX_PAGE_SIZE', 1000))

# The file path where uploaded media files are stored. A trailing slash is not needed. Note that the default value of
# this setting is derived from the installed location.
MEDIA_ROOT = os.environ.get('MEDIA_ROOT', os.path.join(BASE_PATH, 'media'))

# By default uploaded media is stored on the local filesystem. Using Django-storages is also supported. Provide the
# class path of the storage driver in STORAGE_BACKEND and any configuration options in STORAGE_CONFIG. For example:
# STORAGE_BACKEND = 'storages.backends.s3boto3.S3Boto3Storage'
# STORAGE_CONFIG = {
#     'AWS_ACCESS_KEY_ID': 'Key ID',
#     'AWS_SECRET_ACCESS_KEY': 'Secret',
#     'AWS_STORAGE_BUCKET_NAME': 'netbox',
#     'AWS_S3_REGION_NAME': 'us-west-2',
# }

# Expose Prometheus monitoring metrics at the HTTP endpoint '/metrics'
METRICS_ENABLED = os.environ.get('METRICS_ENABLED', 'False').lower() == 'true'

# Credentials that NetBox will uses to authenticate to devices when connecting via NAPALM.
NAPALM_USERNAME = os.environ.get('NAPALM_USERNAME', '')
NAPALM_PASSWORD = os.environ.get('NAPALM_PASSWORD', '')

# NAPALM timeout (in seconds). (Default: 30)
NAPALM_TIMEOUT = int(os.environ.get('NAPALM_TIMEOUT', 30))

# NAPALM optional arguments (see https://napalm.readthedocs.io/en/latest/support/#optional-arguments). Arguments must
# be provided as a dictionary.
NAPALM_ARGS = {}

# Determine how many objects to display per page within a list. (Default: 50)
PAGINATE_COUNT = int(os.environ.get('PAGINATE_COUNT', 50))

# Enable installed plugins. Add the name of each plugin to the list.
PLUGINS = []

# Plugins configuration settings. These settings are used by various plugins that the user may have installed.
# Each key in the dictionary is the name of an installed plugin and its value is a dictionary of settings.
PLUGINS_CONFIG = {}

# When determining the primary IP address for a device, IPv6 is preferred over IPv4 by default. Set this to False to
# prefer IPv4 instead.
PREFER_IPV4 = os.environ.get('PREFER_IPV4', 'False').lower() == 'true'

# Rack elevation size defaults, in pixels. For best results, the ratio of width to height should be roughly 10:1.
RACK_ELEVATION_DEFAULT_UNIT_HEIGHT = int(os.environ.get('RACK_ELEVATION_DEFAULT_UNIT_HEIGHT', 22))
RACK_ELEVATION_DEFAULT_UNIT_WIDTH = int(os.environ.get('RACK_ELEVATION_DEFAULT_UNIT_WIDTH', 220))

# Remote authentication support
REMOTE_AUTH_ENABLED = os.environ.get('REMOTE_AUTH_ENABLED', 'False').lower() == 'true'
REMOTE_AUTH_BACKEND = os.environ.get('REMOTE_AUTH_BACKEND', 'netbox.authentication.RemoteUserBackend')
REMOTE_AUTH_HEADER = os.environ.get('REMOTE_AUTH_HEADER', 'HTTP_REMOTE_USER')
REMOTE_AUTH_AUTO_CREATE_USER = os.environ.get('REMOTE_AUTH_AUTO_CREATE_USER', 'True').lower() == 'true'
REMOTE_AUTH_DEFAULT_GROUPS = []
REMOTE_AUTH_DEFAULT_PERMISSIONS = {}

# This repository is used to check whether there is a new release of NetBox available. Set to None to disable the
# version check or use the URL below to check for pre-releases instead of stable releases.
# RELEASE_CHECK_URL = 'https://api.github.com/repos/netbox-community/netbox/releases'
RELEASE_CHECK_URL = None

# The file path where custom reports are stored. A trailing slash is not needed. Note that the default value of
# this setting is derived from the installed location.
REPORTS_ROOT = os.environ.get('REPORTS_ROOT', os.path.join(BASE_PATH, 'reports'))

# The file path where custom scripts are stored. A trailing slash is not needed. Note that the default value of
# this setting is derived from the installed location.
SCRIPTS_ROOT = os.environ.get('SCRIPTS_ROOT', os.path.join(BASE_PATH, 'scripts'))

# By default, NetBox will store session data in the database. Alternatively, a file path can be specified here to use
# local file storage instead. (This can be useful for enabling authentication on a standby instance with read-only
# database access.) Note that the NetBox system user must have read and write permissions to this path.
SESSION_FILE_PATH = os.environ.get('SESSION_FILE_PATH', None)

# Configure SSO, for more information see docs/configuration/authentication/sso.md
SOCIAL_AUTH_POSTGRES_JSONFIELD = False

# Time zone (default: UTC)
TIME_ZONE = os.environ.get('TIME_ZONE', 'UTC')

# Date/time formatting. See the following link for supported formats:
# https://docs.djangoproject.com/en/stable/ref/templates/builtins/#date
DATE_FORMAT = os.environ.get('DATE_FORMAT', 'N j, Y')
SHORT_DATE_FORMAT = os.environ.get('SHORT_DATE_FORMAT', 'Y-m-d')
TIME_FORMAT = os.environ.get('TIME_FORMAT', 'g:i A')
SHORT_TIME_FORMAT = os.environ.get('SHORT_TIME_FORMAT', 'H:i:s')
DATETIME_FORMAT = os.environ.get('DATETIME_FORMAT', 'N j, Y g:i A')
SHORT_DATETIME_FORMAT = os.environ.get('SHORT_DATETIME_FORMAT', 'Y-m-d H:i')

# A boolean indicating whether Django's translation system should be enabled. This provides a mechanism for
# displaying NetBox in language other than English. Note that enabling this feature has a performance impact.
USE_I18N = os.environ.get('USE_I18N', 'False').lower() == 'true'

# Localization
USE_L10N = True

# Use timezone-aware datetimes
USE_TZ = True
