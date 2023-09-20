#!/bin/bash

# Variables
DOMAIN_NAME="hub.docker.local"
IMAGE_TO_PULL="alpine"
LOCAL_IMAGE_NAME="$DOMAIN_NAME/alpine"
REGISTRY_STORAGE_PATH="/home/localhub/registry"
CERTS_PATH="/home/localhub/certs"
AUTH_PATH="/home/localhub/auth"
USERNAME="rehman"
PASSWORD="rehman123"

# Step 1: Navigate to the localhub directory and create the auth folder
mkdir -p $REGISTRY_STORAGE_PATH
mkdir -p $CERTS_PATH
mkdir -p $AUTH_PATH


# Step 2: Pull the Docker registry image
docker pull registry

# Step 3: Add domain name to /etc/hosts
if ! grep -q "$DOMAIN_NAME" /etc/hosts; then
   echo "127.0.0.1 $DOMAIN_NAME" | sudo tee -a /etc/hosts > /dev/null
   echo "Added $DOMAIN_NAME to /etc/hosts" else
   echo "$DOMAIN_NAME already exists in /etc/hosts"
fi


# Step 2: Generate the htpasswd file for authentication
docker run --rm --entrypoint htpasswd httpd:2.4 -Bbn $USERNAME $PASSWORD > $AUTH_PATH/htpasswd
# Step 3: Stop and remove the existing registry container if it's running
