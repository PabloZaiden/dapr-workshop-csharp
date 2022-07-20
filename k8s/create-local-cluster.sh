#!/usr/bin/env bash

source ./kenv.sh


# if there is no registry, create one
if [ $(k3d registry list -o json | jq '. |  length') -eq 0 ]; then
    k3d registry create $CLUSTER_NAME-registry --port $REGISTRY_PORT
fi

k3d cluster delete $CLUSTER_NAME-cluster
k3d cluster create $CLUSTER_NAME-cluster --registry-use k3d-$CLUSTER_NAME-registry:$REGISTRY_PORT --agents 3