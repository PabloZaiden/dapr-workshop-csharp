#!/usr/bin/env bash
shopt -s expand_aliases

source ./kenv.sh
kd port-forward services/externalinfrastructure 1883:1883 15672:15672 4000:4000