#DISCLIMER: use this script in the DEVELOPMENT MACHINE to push the configuration files to REMOTE SERVER
# Description: This script sends the configuration files to the remote server
import os
from auto_config import MS_NAME, IMG_TAG, IMG_SERVICES, REMOTE_TARGET_DIR, SOURCE_DIR, REMOTE_SERVER, CONFIG_FILES

print("Sending configuration files to "+ REMOTE_SERVER +"...")
for file in CONFIG_FILES:
    print("Sending "+ file +"...")
    if(".env" in file): 
        os.system("scp ./"+ file +" "+ REMOTE_SERVER +":"+REMOTE_TARGET_DIR + file)
    if(".sql" in file): 
        os.system("scp ./"+ file +" "+ REMOTE_SERVER +":"+ REMOTE_TARGET_DIR + file)
    else:
        os.system("scp ./"+ file +" "+ REMOTE_SERVER +":"+ REMOTE_TARGET_DIR)
    

print("Done!")