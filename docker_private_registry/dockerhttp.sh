#!/bin/bash
# Variables
DOMAIN_NAME="hub.docker.local"
IMAGE_TO_PULL="alpine"
LOCAL_IMAGE_NAME="$DOMAIN_NAME:5000/my-alpine"
REGISTRY_STORAGE_PATH="/home/localhub/registry"

# Step 1: Create necessary directories
mkdir -p $REGISTRY_STORAGE_PATH

# Step 2: Pull the Docker registry image
docker pull registry

# Step 3: Add domain name to /etc/hosts
if ! grep -q "$DOMAIN_NAME" /etc/hosts; then
    echo "127.0.0.1 $DOMAIN_NAME" | sudo tee -a /etc/hosts > /dev/null
    echo "Added $DOMAIN_NAME to /etc/hosts"
else
    echo "$DOMAIN_NAME already exists in /etc/hosts"
fi

# Step 4: Check if the container is already running and stop it
if docker ps -a | grep -q "hub.local"; then
    docker stop hub.local
    docker rm hub.local
fi

# Step 5: Run the Docker registry
docker run -d \
  -p 5000:5000 \
  -v $REGISTRY_STORAGE_PATH:/var/lib/registry \
  --restart=always \
  --name hub.local \
  registry
  
# Step 6: Pull the Alpine image
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
