#!/bin/bash
# Variables
DOMAIN_NAME="hub.docker.local"
IMAGE_TO_PULL="alpine"
LOCAL_IMAGE_NAME="$DOMAIN_NAME/alpine"
REGISTRY_STORAGE_PATH="/home/localhub/registry"
CERTS_PATH="/home/localhub/certs"

# Step 1: Ensure OpenSSL is installed
if ! command -v openssl &> /dev/null; then
    echo "OpenSSL is not installed. Installing now..."
    sudo yum install -y openssl
fi

# Step 2: Navigate to the localhub directory and create the certs folder
mkdir -p $REGISTRY_STORAGE_PATH
mkdir -p $CERTS_PATH

# Step 2: Pull the Docker registry image
docker pull registry

# Step 3: Add domain name to /etc/hosts

if ! grep -q "$DOMAIN_NAME" /etc/hosts; then
   echo "127.0.0.1 $DOMAIN_NAME" | sudo tee -a /etc/hosts > /dev/null
   echo "Added $DOMAIN_NAME to /etc/hosts" else
   echo "$DOMAIN_NAME already exists in /etc/hosts"
fi

# Step 3: Generate a self-signed certificate
openssl req -newkey rsa:4096 -nodes -sha256 -keyout $CERTS_PATH/localhub.key -x509 -days 365 -out $CERTS_PATH/localhub.crt
# Note: You'll need to answer the questions prompted by OpenSSL. Ensure the Common Name matches the domain name
# (hub.docker.local). Step 4: Run the Docker registry with the self-signed certificate

docker run -d \
  -p 443:443 \
  --name local.hub \
  -v $CERTS_PATH:/certs \
  -v $REGISTRY_STORAGE_PATH:/var/lib/registry \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/localhub.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/localhub.key \
  registry

# Step 5: Ensure the registry container is up and running
docker container ls | grep local.hub

# Step 6: Pull, tag, push, and verify the Alpine image
docker pull $IMAGE_TO_PULL
docker tag $IMAGE_TO_PULL $LOCAL_IMAGE_NAME
docker push $LOCAL_IMAGE_NAME
docker rmi $LOCAL_IMAGE_NAME
docker rmi $IMAGE_TO_PULL
docker images
docker pull $LOCAL_IMAGE_NAME
docker images
docker run $LOCAL_IMAGE_NAME ls

# Note: At this point, you can manually check the catalog URL  https://hub.docker.local/v2/_catalog with a browser.  You'll
# likely receive a warning about the certificate being invalid.
echo "Setup and verification complete!"
