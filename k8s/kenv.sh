### #!/usr/bin/env bash

if [ -f ../.env ]; then
    source ../.env
else
    echo "No .env file found. Using defaults."
fi

if [ -z $KUBERNETES_NAMESPACE ]; then
    export KUBERNETES_NAMESPACE=default
fi

if [ -z $CLUSTER_NAME ]; then
    export CLUSTER_NAME=dapr-workshop
fi

if [ -z $REGISTRY_PORT ]; then
    export REGISTRY_PORT=20444
fi

alias kd='kubectl -n $KUBERNETES_NAMESPACE'