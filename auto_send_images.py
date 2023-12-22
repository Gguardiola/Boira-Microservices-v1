#DISCLAIMER: use this script in the DEVELOPMENT MACHINE to send the images to the remote server
# Description: This script sends the images to the remote server
import os
from auto_config import MS_NAME, IMG_TAG, IMG_SERVICES, REMOTE_TARGET_DIR, SOURCE_DIR, REMOTE_SERVER, TARGET_DIR

print("Sending images to "+ REMOTE_SERVER +"...")
os.system("scp ./"+ SOURCE_DIR +"/* "+ REMOTE_SERVER +":"+ REMOTE_TARGET_DIR + "/" + TARGET_DIR)
print("Done!")

