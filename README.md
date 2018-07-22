# TES3MP/server-docker

Docker image for the TES3MP server

[ARM version](https://github.com/TES3MP/server-docker-armhf)

## Docker Hub

https://hub.docker.com/r/tes3mp/server/

## Getting the image

### Pulling from Docker Hub

#### Pull the latest stable version

```bash
docker pull tes3mp/server
```

#### Pull a specific version

```bash
docker pull tes3mp/server:0.6.3
```

### Building

```bash
git clone https://github.com/GrimKriegor/TES3MP-docker.git
cd TES3MP-docker
git checkout <TES3MP version> # optional
docker build -t tes3mp/server:<TES3MP version> .
```

## Running

There is no need to pull the image when running the container through one of the methods described below.

Replace the path described at the `-v` (volume) argument to a directory on your machine you already have, or wish to have compatible server data and scripts. Keep the path that comes after the colon, as its the internal container path to where server data should be.

#### Run the latest stable version

```bash
docker run -it \
    --name TES3MP-server \
    -v "$HOME/TES3MP/data:/server/data" \
    -p "25565:25565/udp" \
    tes3mp/server
```

#### Run a specific version

```bash
docker run -it \
    --name TES3MP-server \
    -v "$HOME/TES3MP/data:/server/data" \
    -p "25565:25565/udp" \
    tes3mp/server:0.6.3
```

#### Run in the background

Same as above, but removing the `-it` arguments.

And to later attach the console:

```bash
docker attach TES3MP-server
```

## Compose file

Alternatively you can use a compose file to deploy one or more servers as a stack.

Create a file titled **docker-compose.yml** with the following contents:

```yml
version: '3'
services:
  server:
    image: "tes3mp/server:0.6.3"
    volumes:
      - "./data:/server/data"
    ports:
      - "25565:25565/udp"
# Optional extra servers:
  server-legacy:
    image: "tes3mp/server:0.5.2"
    volumes:
      - "./data-legacy:/server/data"
    ports:
      - "25566:25565/udp"
```

### Deploy it locally

```bash
docker-compose up
```

### Deploy it on a swarm cluster

```bash
docker stack deploy -c docker-compose.yml tes3mp-server-stack
```
