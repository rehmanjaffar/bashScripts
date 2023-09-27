#!/bin/bash

# Variables
DOMAIN_NAME="k8-master"
IP_ADDRESS="192.168.100.1"

if ! grep -q "$DOMAIN_NAME" /etc/hosts; then
   echo "$IP_ADDRESS $DOMAIN_NAME" | sudo tee -a /etc/hosts > /dev/null
   echo "Added $IP_ADDRESS and $DOMAIN_NAME to /etc/hosts"
else
   echo "$DOMAIN_NAME already exists in /etc/hosts"
fi
