#!/usr/bin/env bash
shopt -s expand_aliases

source ./kenv.sh

(cd .. && ./docker-build.sh)
(cd ../Infrastructure/mosquitto && ./build-dtc-mosquitto.sh)
docker tag dapr-trafficcontrol/mosquitto:1.0  localhost:20444/dapr-trafficcontrol/mosquitto:1.0
docker push localhost:20444/dapr-trafficcontrol/mosquitto:1.0 

function deployApp() {
    local appName=$1
    local lowercaseName=$(echo $appName | tr "[:upper:]" "[:lower:]")
    echo "Deploying $appName..."
    kd apply -f ./deployments/$lowercaseName.yaml
}

function uninstallApp() {
    local appName=$1
    local lowercaseName=$(echo $appName | tr "[:upper:]" "[:lower:]")
    echo "Uninstalling $appName..."
    kd delete deployment $lowercaseName
}

if [ ! -z "$FORCE" ]; then
    echo "Deleting exisitng deployments..."
    kd delete deployment finecollectionservice
    kd delete deployment trafficcontrolservice
    kd delete deployment vehicleregistrationservice
    kd delete deployment externalinfrastructure

    echo "Deleting existing components..."
    kd delete -f ../dapr/components/secrets-kubernetes.yaml
    kd delete -f ../dapr/components/email.yaml
    kd delete -f ../dapr/components/entrycam.yaml
    kd delete -f ../dapr/components/exitcam.yaml
    kd delete -f ../dapr/components/pubsub.yaml
    kd delete -f ../dapr/components/statestore.yaml
fi

kd create namespace $KUBERNETES_NAMESPACE

(./create-secrets.sh)

deployApp ExternalInfrastructure
deployApp VehicleRegistrationService
deployApp FineCollectionService
deployApp TrafficControlService
deployApp SecretsRBAC

kd apply -f ../dapr/components/secrets-kubernetes.yaml
kd apply -f ../dapr/components/email.yaml
kd apply -f ../dapr/components/entrycam.yaml
kd apply -f ../dapr/components/exitcam.yaml
kd apply -f ../dapr/components/pubsub.yaml
kd apply -f ../dapr/components/statestore.yaml
#kd apply -f ../dapr/components/subscription.yaml
