#!/bin/bash

set -e

export arch=$(uname -m)

if [ "$arch" = "armv7l" ] ; then
    echo "Build not supported on $arch, use cross-build."
    exit 1
fi

if [ "$arch" = "armv6l" ] ; then
    # Todo: remove later, only for testing arm32v6
    echo "Building only armv6 watchdog."
    docker build -f Dockerfile.armv6 -t buildoutput .
    docker run --name buildoutput --rm -d buildoutput:latest sh -c "sleep 10"
    docker cp buildoutput:/go/src/github.com/openfaas/faas/watchdog/watchdog-armv6 ./fwatchdog-armv6
    exit 1
fi

cd ..
GIT_COMMIT=$(git rev-list -1 HEAD)
VERSION=$(git describe --all --exact-match `git rev-parse HEAD` | grep tags | sed 's/tags\///')
cd watchdog

if [ ! $http_proxy == "" ] 
then
    docker build --no-cache --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy \
        --build-arg GIT_COMMIT=$GIT_COMMIT --build-arg VERSION=$VERSION -t openfaas/watchdog:build .
else
    docker build --no-cache --build-arg VERSION=$VERSION --build-arg GIT_COMMIT=$GIT_COMMIT -t openfaas/watchdog:build .
fi

docker create --name buildoutput openfaas/watchdog:build echo

docker cp buildoutput:/go/src/github.com/openfaas/faas/watchdog/watchdog ./fwatchdog
docker cp buildoutput:/go/src/github.com/openfaas/faas/watchdog/watchdog-armhf ./fwatchdog-armhf
docker cp buildoutput:/go/src/github.com/openfaas/faas/watchdog/watchdog-arm64 ./fwatchdog-arm64
docker cp buildoutput:/go/src/github.com/openfaas/faas/watchdog/watchdog.exe ./fwatchdog.exe

docker rm buildoutput

