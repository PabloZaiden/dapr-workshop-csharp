# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
ARG appName

WORKDIR /app

# Copy csproj and restore as distinct layers
COPY ./${appName}/*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY ./${appName}/* ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
ARG appName

ENV appName ${appName}
WORKDIR /app
COPY --from=build-env /app/out .
COPY ./docker-entrypoint.sh ./

ENTRYPOINT ["/app/docker-entrypoint.sh"]