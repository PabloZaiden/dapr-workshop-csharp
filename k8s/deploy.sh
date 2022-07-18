(cd .. && ./docker-build.sh)

function deployApp() {
    local appName=$1
    local lowercaseName=$(echo $appName | tr "[:upper:]" "[:lower:]")
    echo "Deploying $appName..."
    helm upgrade \
        --create-namespace --namespace $namespace \
        --install $lowercaseName ./$appName
}

function uninstallApp() {
    local appName=$1
    local lowercaseName=$(echo $appName | tr "[:upper:]" "[:lower:]")
    echo "Uninstalling $appName..."
    helm uninstall $lowercaseName --namespace $namespace
}

namespace=dapr-workshop

if [ ! -z "$FORCE" ]; then
    kubectl delete namespace $namespace
fi

deployApp ExternalInfrastructure

#deployApp VehicleRegistrationService
#deployApp FineCollectionService
#deployApp TrafficControlService
