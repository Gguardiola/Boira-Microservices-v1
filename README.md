
# How to deploy Boira-Microservices-v1

Explanation step by step about how to generate the docker images, send them to the remote server and finally build the containers.





## Introduction

We will have the next containers:

- nginx (Reverse Proxy) | port 80 and 443
- next.js app (frontend app) | port 3000
- node.js server (RESTful API) | port 5000
- node.js server (Auth service) | port 3001
- postgres server (BBDD server) | port 5432

### How it works?

The nginx server receives all requests and redirects traffic based on the domain name from which it was accessed. This way, the services inside the server will be protected from intruders and also well distributed in case that we want to scale the server.

- **api.gabodev.com** -> 80/443 -> RESTful API, port 5000
- **goodgifts.gabodev.com** -> 80/443 -> Next.js app, port 3000
- **auth.gabodev.com** -> 80/443 -> auth-service, port 3001 (this one may be disabled in a near future)

The good thing about using docker containers is that we can restrict the traffic and for example made the auth-service only be accessed from the RESTful API and not from the outside network!
## Step 1 - Make the folders for each image container

```bash

├── auth-service
│   ├── Dockerfile
│   ├── README.md
│   ├── api
│   ├── controllers
│   ├── index.js
│   ├── node_modules
│   ├── package-lock.json
│   ├── package.json
|
├── auto_config.py
├── auto_gen_images.py
├── auto_push_config.py
├── auto_send_images.py
├── auto_setup_containers.py
|
├── dboira
│   ├── Dockerfile
│   └── init.sql
|
├── docker-compose.yml
|
├── goodgifts-nextjs-app
│   ├── Dockerfile
│   ├── README.md
│   ├── next-env.d.ts
│   ├── next.config.js
│   ├── node_modules
│   ├── package-lock.json
│   ├── package.json
│   ├── postcss.config.js
│   ├── public
│   ├── src
│   ├── tailwind.config.ts
│   └── tsconfig.json
|
├── goodgifts-rest-api
│   ├── Dockerfile
│   ├── README.md
│   ├── api
│   ├── controllers
│   ├── index.js
│   ├── node_modules
│   ├── package-lock.json
│   ├── package.json
│   ├── service
│   └── utils
|
├── nginx
│   ├── Dockerfile
│   ├── nginx.conf
|
└── remote-docker-compose.yml
```

In the tree view above we can see the folders with their service files. To simplify, the "goodgifts-rest-api" and the "auth-service" have a auto-generated Swagger OpenAPI node.js server (https://editor.swagger.io/).

**NOTE:** Remember to update the port in index.js!

```javascript
var serverPort = 3001; //auth-service
...
var serverPort = 5000; //RESTful-api
```

The "goodgifts-next-app" has been generated following the Next.js oficial documentation. 

Now as we see, each folder have a **Dockerfile**. This file stores the configuration that Docker will automatically execute once the image is builded. They are simple and easy to understand so there is no need to modify anything.







## Step 2 - Docker-Compose configuration

Since we have to automatize the deploying process, it is important to define how the images should be executed, which order, the port that they will listen, etc.

To securize our environment, I highly recommend to set up a **.env** that will store our passwords and the sensitive data. In my case it will only store the Postgres credentials.

```
POSTGRES_USER=dboira-user
POSTGRES_PASSWORD=ultrasecret
POSTGRES_DB=dboira
```
This .env can be readed from docker-compose to automatically configure the postgres authentication. 

The **remote-docker-compose.yml** will be executed from the **production/remote host** and not from the **development/local host**. This is how it looks like:

```yaml
version: "3"

services:
  nginx:
    image: boira-microservices-nginx:latest
    container_name: nginx_reverse_proxy
    ports:
      - 80:80
    networks:
      - nginx-network
      - api-network
      - auth-network
      - next-network
    depends_on:
      - goodgifts-nextjs-app
      - goodgifts-rest-api
      - auth-service


  goodgifts-nextjs-app:
    image: boira-microservices-goodgifts-nextjs-app:latest
    container_name: goodgifts-nextjs-app
    ports:
      - "3000:3000"
    networks:
      - next-network
    

  goodgifts-rest-api:
    image: boira-microservices-goodgifts-rest-api:latest
    container_name: goodgifts-rest-api
    ports:
      - "5000:5000"
    depends_on:
      - dboira
      - auth-service
    networks:
      - api-network
      - db-network
  dboira:
    image: boira-microservices-dboira:latest
    container_name: dboira
    env_file:
      - .env
    ports:
      - "5432:5432"
    networks:
      - db-network

  auth-service:
    image: boira-microservices-auth-service:latest
    container_name: auth-service
    ports:
      - "3001:3001"
    depends_on:
      - dboira
    networks:
      - auth-network
      - db-network

networks:
  nginx-network:
  api-network:
  auth-network:
  next-network:
  db-network:

```
Each service has a **name** (that will be the hostname), the **ports** that will listen, **dependencies** (the containers that needs to be up to run correctly), **networks** (this is like VirtualBox NAT adapter. The networks defined are the ones that the docker will be able to communicate) and finally the **image**.

**NOTE:** This one is the most important one because docker-compose will look for the image with that name (in our case, locally, otherwise from DockerHub).



## Step 3 - Generation of docker images, delivering to production server and deployment

- Dependencies

Install Docker and docker-compose on both servers (development/local and production/remote).

```
  apt-get install docker
  apt-get install docker-compose
```

Now create on the development/local machine a folder to store the .tar images (in my case is called docker-images). Do the same on the remote server if you want.

Next, modify the **auto_config.py** adapted to your case:

```
MS_NAME = "boira-microservices"
IMG_TAG = "latest"
IMG_SERVICES = ["nginx", "dboira", "auth-service", "goodgifts-rest-api", "goodgifts-nextjs-app"]
TARGET_DIR = "docker-images"
SOURCE_DIR = "docker-images"
COMPOSER_FILENAME = "remote-docker-compose.yml"
REMOTE_TARGET_DIR = "boira-stuff/docker-images"
REMOTE_SERVER = "root@XXXXXXXXXX"
CONFIG_FILES = ["auto_config.py", ".env","auto_setup_containers.py", "remote-docker-compose.yml"]
```

Moving to the next point, we have these scripts: 

- **auto_gen_images.py:** to generate the images. **USE ON DEVELOPMENT/CLIENT HOST!**
- **auto_send_images.py:** to send via SSH the .tar images. **USE ON DEVELOPMENT/CLIENT HOST!**
- **auto_push_config.py:** to send the scripts needed to deploy the containers. **USE ON DEVELOPMENT/CLIENT HOST!**
- **auto_setup_containers.py:** to build the docker-compose and build the containers (run the important stuff). **USE ON PRODUCTION/REMOTE HOST!**

Run the first three scripts. If everything works well, go to the production/remote server. Now you will see the "auto_setup_containers.py along with remote-docker-compose.yml and the folder with the images. Run this script to mount the images and run the containers.

**Congratulations! Now you have Boira-Microservices running!**

## Step 4 - Testing

At this point you can go to you browser and access to the different services by only changing the URL route. By default:

- **http://localhost/next** - Next.js app
- **http://localhost/api** - RESTful api
- **http://localhost/auth** - auth service

In the following steps I will explain how to change this configuration for different subdomains via https.

## Step 5 - Configuring nginx to support subdomains

- **https://goodgifts.gabodev.com** - Next.js app
- **https://api.gabodev.com** - RESTful api
- **https://auth.gabodev.com** - auth service

**WIP**

## Step 6 - SSL Encryption

**WIP**

## Step 7 - Pushing changes or new containers


## Step 3 - Generation of docker images, delivering to production server and deployment

- Dependencies

Install Docker and docker-compose on both servers (development/local and production/remote).

```
  apt-get install docker
  apt-get install docker-compose
```

Now create on the development/local machine a folder to store the .tar images (in my case is called docker-images). Do the same on the remote server if you want.

Next, modify the **auto_config.py** adapted to your case:

```
MS_NAME = "boira-microservices"
IMG_TAG = "latest"
IMG_SERVICES = ["nginx", "dboira", "auth-service", "goodgifts-rest-api", "goodgifts-nextjs-app"]
TARGET_DIR = "docker-images"
SOURCE_DIR = "docker-images"
COMPOSER_FILENAME = "remote-docker-compose.yml"
REMOTE_TARGET_DIR = "boira-stuff/docker-images"
REMOTE_SERVER = "root@XXXXXXXXXX"
CONFIG_FILES = ["auto_config.py", ".env","auto_setup_containers.py", "remote-docker-compose.yml"]
```

Moving to the next point, we have these scripts: 

- **auto_gen_images.py:** to generate the images. **USE ON DEVELOPMENT/CLIENT HOST!**
- **auto_send_images.py:** to send via SSH the .tar images. **USE ON DEVELOPMENT/CLIENT HOST!**
- **auto_push_config.py:** to send the scripts needed to deploy the containers. **USE ON DEVELOPMENT/CLIENT HOST!**
- **auto_setup_containers.py:** to build the docker-compose and build the containers (run the important stuff). **USE ON PRODUCTION/REMOTE HOST!**

Run the first three scripts. If everything works well, go to the production/remote server. Now you will see the "auto_setup_containers.py along with remote-docker-compose.yml and the folder with the images. Run this script to mount the images and run the containers.

**Congratulations! Now you have Boira-Microservices running!**

## Step 4 - Testing

At this point you can go to you browser and access to the different services by only changing the URL route. By default:

- **http://localhost/next** - Next.js app
- **http://localhost/api** - RESTful api
- **http://localhost/auth** - auth service

In the following steps I will explain how to change this configuration for different subdomains via https.

## Step 5 - Configuring nginx to support subdomains

- **https://goodgifts.gabodev.com** - Next.js app
- **https://api.gabodev.com** - RESTful api
- **https://auth.gabodev.com** - auth service

**WIP**

## Step 6 - SSL Encryption

**WIP**

## Step 7 - Pushing changes or new containers


## Step 3 - Generation of docker images, delivering to production server and deployment

- Dependencies

Install Docker and docker-compose on both servers (development/local and production/remote).

```
  apt-get install docker
  apt-get install docker-compose
```

Now create on the development/local machine a folder to store the .tar images (in my case is called docker-images). Do the same on the remote server if you want.

Next, modify the **auto_config.py** adapted to your case:

```
MS_NAME = "boira-microservices"
IMG_TAG = "latest"
IMG_SERVICES = ["nginx", "dboira", "auth-service", "goodgifts-rest-api", "goodgifts-nextjs-app"]
TARGET_DIR = "docker-images"
SOURCE_DIR = "docker-images"
COMPOSER_FILENAME = "remote-docker-compose.yml"
REMOTE_TARGET_DIR = "boira-stuff/docker-images"
REMOTE_SERVER = "root@XXXXXXXXXX"
CONFIG_FILES = ["auto_config.py", ".env","auto_setup_containers.py", "remote-docker-compose.yml"]
```

Moving to the next point, we have these scripts: 

- **auto_gen_images.py:** to generate the images. **USE ON DEVELOPMENT/CLIENT HOST!**
- **auto_send_images.py:** to send via SSH the .tar images. **USE ON DEVELOPMENT/CLIENT HOST!**
- **auto_push_config.py:** to send the scripts needed to deploy the containers. **USE ON DEVELOPMENT/CLIENT HOST!**
- **auto_setup_containers.py:** to build the docker-compose and build the containers (run the important stuff). **USE ON PRODUCTION/REMOTE HOST!**

Run the first three scripts. If everything works well, go to the production/remote server. Now you will see the "auto_setup_containers.py along with remote-docker-compose.yml and the folder with the images. Run this script to mount the images and run the containers.

**Congratulations! Now you have Boira-Microservices running!**

## Step 4 - Testing

At this point you can go to you browser and access to the different services by only changing the URL route. By default:

- **http://localhost/next** - Next.js app
- **http://localhost/api** - RESTful api
- **http://localhost/auth** - auth service

In the following steps I will explain how to change this configuration for different subdomains via https.

## Step 5 - Configuring nginx to support subdomains

- **https://goodgifts.gabodev.com** - Next.js app
- **https://api.gabodev.com** - RESTful api
- **https://auth.gabodev.com** - auth service

**WIP**

## Step 6 - SSL Encryption

**WIP**

## Step 7 - Pushing changes or new containers


## Authors

- [@gguardiola](https://www.github.com/gguardiola)

