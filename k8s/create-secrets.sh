#!/usr/bin/env bash
shopt -s expand_aliases

source ./kenv.sh

kd create secret generic smtp \
    --from-literal=user=_username \
    --from-literal=password=_password

kd create secret generic finecalculator \
    --from-literal=licensekey=HX783-K2L7V-CRJ4A-5PN1G
