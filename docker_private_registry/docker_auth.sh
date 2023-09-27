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
if docker ps -a | grep -q "local.hub"; then
    docker stop local.hub
    docker rm local.hub
fi

# Step 4: Run the Docker registry with SSL certificates and basic authentication
docker run -d \
  -p 443:443 \
  --name local.hub \
  -v $CERTS_PATH:/certs \
  -v $REGISTRY_STORAGE_PATH:/var/lib/registry \
  -v $AUTH_PATH:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/localhub.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/localhub.key \
  registry

# Step 5: Ensure the registry container is up and running
docker container ls | grep local.hub

# Step 6: Login to the private registry
docker login $DOMAIN_NAME

# Note: At this point, you'll be prompted to enter the username and password. After successful authentication, you can push and
# pull images from the registry.
docker pull $IMAGE_TO_PULL
# Step 7: Tag the Alpine image for the local registry
docker tag $IMAGE_TO_PULL $LOCAL_IMAGE_NAME
# Step 8: Push the image to the local registry
docker push $LOCAL_IMAGE_NAME
# Step 9: Remove containers using the Alpine image
docker ps -a | grep $IMAGE_TO_PULL | awk '{print $1}' | xargs docker rm -f
# Step 10: Remove the Alpine and its tagged version
docker rmi $LOCAL_IMAGE_NAME
docker rmi $IMAGE_TO_PULL
# Step 11: Pull the image from the local registry
docker pull $LOCAL_IMAGE_NAME
# Step 12: Run a container with the pulled image
docker run $LOCAL_IMAGE_NAME ls


echo "Setup and verification complete!"
