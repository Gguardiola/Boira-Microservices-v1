#DISCLAIMER: use this script in the DEVELOPMENT MACHINE to generate the images
# Description: This script generates images for a microservice

import os;
from auto_config import MS_NAME, IMG_TAG, IMG_SERVICES, TARGET_DIR, COMPOSER_FILENAME

def main(MS_NAME, IMG_TAG, IMG_SERVICES, TARGET_DIR):
    print("Starting autogen_images.py")
    print("Microservice name: " + MS_NAME)
    print("Image tag: " + IMG_TAG)
    print("Image services: " + str(IMG_SERVICES))
    print("----------------------------------")
    opt = input("Start? (y/n)")
    if(opt == "y" or opt == "Y"):
            print("Generating images...")
            generate_images(MS_NAME, IMG_TAG, IMG_SERVICES, TARGET_DIR)    
            print("Done!")
    else:
        print("Bye!")    

def generate_images(MS_NAME, IMG_TAG, IMG_SERVICES, TARGET_DIR):
    for service in IMG_SERVICES:
        print("Generating image for " + service)
        ##generate docker save -o image.tar image:tag
        os.system("docker save -o " + "./"+ TARGET_DIR + "/" + service + ".tar " + MS_NAME + "-" + service + ":" + IMG_TAG)

##INIT MAIN
if __name__ == "__main__":
    main(MS_NAME, IMG_TAG, IMG_SERVICES, TARGET_DIR)