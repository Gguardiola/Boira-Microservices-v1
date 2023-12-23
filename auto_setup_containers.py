#DISCLAIMER: Use this script in the REMOTE SERVER to setup the containers
# Description: This script loads the images and runs the containers
import os
from auto_config import MS_NAME, IMG_TAG, IMG_SERVICES, TARGET_DIR, COMPOSER_FILENAME

#print("Loading images...")
#for i in range(len(IMG_SERVICES)):
#    os.system("docker load -i " + TARGET_DIR + "/"+ IMG_SERVICES[i] + ".tar")
#    print("Loaded " + IMG_SERVICES[i] + " image")
#
#print("Done!")
#
opt = input("Do you want to run the containers? (y/n) ")
if(opt == "y"):
    print("Running containers...")
    #start remote composer
    os.system("docker-compose -f "+ COMPOSER_FILENAME +" up -d --force-recreate --build")
    print("Done!") 