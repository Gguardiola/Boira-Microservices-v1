#DISCLAIMER: do NOT execute this file directly, just change the values

MS_NAME = "boira-microservices"
IMG_TAG = "latest"
IMG_SERVICES = ["nginx", "dboira", "auth-service", "goodgifts-rest-api", "goodgifts-nextjs-app"]
TARGET_DIR = "docker-images"
SOURCE_DIR = "docker-images"
COMPOSER_FILENAME = "remote-docker-compose.yml"
REMOTE_TARGET_DIR = "boira-stuff/"
REMOTE_SERVER = "root@167.172.168.118"
CONFIG_FILES = ["auto_config.py", ".env","auto_setup_containers.py", "remote-docker-compose.yml"]