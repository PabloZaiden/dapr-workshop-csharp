#!/usr/bin/env bash

REGISTRY_PORT=20444

function buildAndPush() {
    local appName=$1
    local imageName=$(echo $appName | tr "[:upper:]" "[:lower:]")
    docker build -t localhost:$REGISTRY_PORT/$imageName -f ./Dockerfile --build-arg appName=$appName .
    docker push localhost:$REGISTRY_PORT/$imageName
}

buildAndPush "FineCollectionService"
buildAndPush "TrafficControlService"
buildAndPush "VehicleRegistrationService"