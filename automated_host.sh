#!/bin/bash

my_ip=$(hostname -i)

# Print the IP address stored in the variable
echo "IP address is: $my_ip"
read -p "Enter the domain name: " DOMAIN_NAME

if ! grep -q "$DOMAIN_NAME" /etc/hosts; then
   echo "$IP_ADDRESS $DOMAIN_NAME" | sudo tee -a /etc/hosts > /dev/null
   echo "Added $IP_ADDRESS and $DOMAIN_NAME to /etc/hosts"
else
   echo "$DOMAIN_NAME already exists in /etc/hosts"
fi
