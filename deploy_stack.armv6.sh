#!/bin/sh

if ! [ -x "$(command -v docker)" ]; then
  echo 'Unable to find docker command, please install Docker (https://www.docker.com/) and retry' >&2
  exit 1
fi

####################
# ToDo: remove later, building of armv6 containers
echo "Build arm containers"
faas_home=$(pwd)

# building openfaas/gateway:latest-armv6-dev
cd gateway && ./build.sh
cd $faas_home

# building arm32v6/prometheus:2.0
cd contrib/prometheus-armv6/2.0 && docker-compose build && cd $faas_home
####################

#echo "Deploying stack"
docker stack deploy func --compose-file docker-compose.armv6.yml
