
# Boira-Microservices-v1

Boira-microservices (v1) is a microservices architecture that I have designed and implemented for the deployment of my personal projects in a production environment.

## Introduction

Current containers deployed:

- nginx (Reverse Proxy) | port 80 and 443
- next.js app (GoodGifts frontend app) | port 3000
- node.js server (Express API REST) | port 5000
- node.js server (Express + JWT Auth service) | port 3001
- postgres server (BBDD server) | port 5432

### How it works?

The Nginx server receives all requests and redirects traffic based on the domain name from which it was accessed. This way, the services inside the server will be protected from intruders and also well distributed in case that we want to scale the services.

- **api.gabodev.com/goodgifts** -> 80/443 -> API REST, port 5000
- **goodgifts.gabodev.com** -> 80/443 -> Next.js app, port 3000
- **auth.gabodev.com** -> 80/443 -> auth-service, port 3001 (this one may be disabled in a near future)

The good thing about using Docker containers is that we can restrict traffic. For example, we can make the auth service only accessible from the API REST and not from the outside network!


### Architecture diagram

This diagram shows the containers and the available routes for each.

![v1-diagran](https://i.imgur.com/6sPhDPP.png)
(2024-01-19)
## How to deploy Boira-Microservices-v1
### Step 1 - Create the service repositories

First, create the folders that will contain the repository of each service (e.g. /auth-service). Then create the corresponding files and make a github repository for each service.

In my case, I have the REST API and the frontend:

- [GoodGifts REST API](https://github.com/Gguardiola/goodgifts-rest-api)
- [GoodGifts Web Application](https://github.com/Gguardiola/goodgifts-nextjs-app)

The Nginx and Postgres projects are inside this repository because docker-compose allows a repository folder as image source.

For convenience, I have a global folder where I keep each project folder along with the Dockerfiles and compose.
```bash

├── auth-service
│   ├── Dockerfile
│   ├── README.md
│   ├── database
│   ├── index.js
│   ├── node_modules
│   ├── package-lock.json
│   ├── package.json
│   └── routes
|
├── auto_config.py
├── auto_gen_images.py
├── auto_push_config.py
├── auto_send_images.py
├── auto_setup_containers.py
├── dboira
│   ├── Dockerfile
│   └── init.sql
|
├── delete_all_microservices.sh
├── delete_invalid_tokens.py
├── docker-compose.yml
├── docker-images
|
├── goodgifts-nextjs-app
│   ├── Dockerfile
│   ├── README.md
│   ├── config.ts
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
├── goodgifts-rest-api
│   ├── Dockerfile
│   ├── README.md
│   ├── database
│   ├── index.js
│   ├── middleware
│   ├── node_modules
│   ├── package-lock.json
│   ├── package.json
│   ├── routes
│   └── utils
├── nginx
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── snippets
│   └── ssl
|
└── remote-docker-compose.yml
```

As we can see, each folder has a **Dockerfile**. This file stores the configuration that Docker will automatically run once the image is built. They are simple and easy to understand, so there is no need to change anything.

### Step 2 - Docker-Compose configuration

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
    build: https://github.com/Gguardiola/Boira-Microservices-v1.git#main:nginx
    restart: unless-stopped
    container_name: nginx_reverse_proxy
    volumes:
      - ./ssl:/etc/nginx/ssl
    ports:
      - 80:80
      - 443:443
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
    build: https://github.com/Gguardiola/goodgifts-nextjs-app.git#main
    restart: unless-stopped
    container_name: goodgifts-nextjs-app
    env_file:
      - ./goodgifts-nextjs-app/.env
    ports:
      - "3000:3000"
    networks:
      - next-network
    
  goodgifts-rest-api:
    build: https://github.com/Gguardiola/goodgifts-rest-api.git#main
    restart: unless-stopped
    container_name: goodgifts-rest-api
    env_file:
      - ./goodgifts-rest-api/.env
    ports:
      - "5000:5000"
    depends_on:
      - dboira
      - auth-service
    networks:
      - api-network
      - db-network
  dboira:
    build:
      context: ./dboira
    restart: unless-stopped
    container_name: dboira
    volumes:
      - postgres_data:/var/lib/postgresql/data
    env_file:
      - .env
    ports:
      - "5432:5432"
    networks:
      - db-network

  auth-service:
    build: https://github.com/Gguardiola/auth-service.git#main
    restart: unless-stopped
    container_name: auth-service
    env_file:
      - ./auth-service/.env
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

volumes:
  postgres_data:  
```
Each service has a **name** (that will be the hostname), the **ports** that will listen, **dependencies** (the containers that needs to be up to run correctly), **networks** (this is like VirtualBox NAT adapter. The networks defined are the ones that the docker will be able to communicate) and finally the **build**, that in our case is pulled from GitHub.


We can also highlight **volumes**, which will save the database persistently in case the Postgres image is deleted or altered, and also say that the **Nginx** build is pulled from the folder of this repo.



### Step 3 - Delivering to production server and deployment

- Dependencies

Install Docker and docker-compose on both servers (development/local and production/remote).

```
  apt-get install docker
  apt-get install docker-compose
```

Next, I wrote some scripts to make it easier to send the files to the production server. First, we have the **auto_config.py**. This script is used to determine the paths of the environment files, the names of the images and the folders where they will be located.

```
MS_NAME = "boira-microservices"
IMG_TAG = "latest"
IMG_SERVICES = ["nginx", "dboira", "auth-service", "goodgifts-rest-api", "goodgifts-nextjs-app"]
TARGET_DIR = "docker-images"
SOURCE_DIR = "docker-images"
COMPOSER_FILENAME = "remote-docker-compose.yml"
REMOTE_TARGET_DIR = "boira-stuff/"
REMOTE_SERVER = "root@REMOTE_IP"
CONFIG_FILES = ["auto_config.py", ".env","auto_setup_containers.py", "delete_invalid_tokens.py", 
                "remote-docker-compose.yml", "goodgifts-rest-api/.env", "auth-service/.env", 
                "dboira/init.sql", "goodgifts-nextjs-app/.env"]
```

Moving to the next point, we have these scripts: 

- **auto_push_config.py:** used to send the environment and private files.

**NOTE:** It is possible that you have to create first the folder structure on the server (maybe the scripts are a bit bugged hehe).

My folder structure looks like this:

```bash
/root
├── /boira-stuff
│   ├── .env
│   ├── DOCKER-COMMANDS.md
│   ├── __pycache__
│   │   └── auto_config.cpython-311.pyc
│   ├── auth-service
│   │   └── .env
│   ├── auto_config.py
│   ├── auto_setup_containers.py
│   ├── dboira
│   │   ├── Dockerfile
│   │   └── init.sql
│   ├── delete_all_microservices.sh
│   ├── delete_invalid_tokens.py
│   ├── docker-images
│   │   └── .env
│   ├── goodgifts-nextjs-app
│   │   └── .env
│   ├── goodgifts-rest-api
│   │   └── .env
│   ├── remote-docker-compose.yml
│   └── ssl
│       ├── _.gabodev.com_private_key.key
│       ├── _.gabodev.com_ssl_certificate_INTERMEDIATE.cer
│       ├── fullchain.pem
│       └── gabodev.com_ssl_certificate.cer

```
(The SSL files are sended manually via SCP)

- **auto_setup_containers.py:** to build the docker-compose and build the containers (run the important stuff). **USE ON PRODUCTION/REMOTE HOST!**

The Modus operandi is like this:

- Run auto_push_config.py

- Send SSL files (if necessary)

- On the server, run auto_setup_containers.py

**Congratulations! Now you have Boira-Microservices running!**

In the following steps I will explain how to change this configuration for different subdomains via https.

### Step 4 - SSL Encryption (HTTPS)

For this type of service, it is important to have secure communications. 


To do this, we have the **reverse proxy as the only entry and exit gate**, where we will add a redirection to port 443. Since this is not enough, we will have to add certain headers to the requests and add the SSL certificate (either autogenerated with Let's Encrypt or by our domain provider)

We will need:

- Private key (example.key)
- certificate (example.cer)
- fullchain.pem (private key + certificate in one file)

Now we can adapt the **nginx.conf** to only allow https requests through the declared subdomains:

```

    server {
        #redirect http to https
        listen 80;
        listen [::]:80;
        server_name *.gabodev.com;

        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl;
        listen [::]:443 ssl;

        server_name api.gabodev.com;

        # SSL
        #add_header Access-Control-Allow-Origin "*";
        add_header Access-Control-Allow-Methods "GET, POST, DELETE, PATCH, OPTIONS";
        add_header Access-Control-Allow-Headers "Authorization, Content-Type";
        add_header Access-Control-Allow-Credentials "true";

        #include de SSL files
        include snippets/ssl-params.conf;
        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/_.gabodev.com_private_key.key;

        #the api.gabodev.com/goodgifts/* clients will be redirected to the REST API
        
        location /goodgifts/ {
            #DISCLAIMER: Authorization headers are only in my case! maybe you dont need them

            proxy_set_header Authorization $http_authorization;
            proxy_pass_header Authorization;        
            proxy_pass http://goodgifts-rest-api:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
```

#### Troubleshooting

It is possible that you have encountered CORS problems when making API calls from a client, this is because headers that are added in the nginx or in the REST API can cause conflicts. Below I attach articles that have helped me:

- https://blog.logrocket.com/using-cors-next-js-handle-cross-origin-requests/
- https://es.stackoverflow.com/questions/325136/access-to-fetch-at-url-from-origin-localhost-has-been-blocked-by-cors
- https://stackoverflow.com/questions/48499693/cors-errors-only-with-400-bad-request-react-fetch-request

### Step 5 - Securing the server (Firewall)

**WIP**

## Authors

- [@gguardiola](https://www.github.com/gguardiola)

