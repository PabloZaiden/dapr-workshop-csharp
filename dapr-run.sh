#!/usr/bin/env bash

dapr run --components-path ../dapr/components/ --app-id $APP_ID --app-port $APP_PORT --dapr-http-port $DAPR_HTTP_PORT --dapr-grpc-port $DAPR_GRPC_PORT dotnet run
