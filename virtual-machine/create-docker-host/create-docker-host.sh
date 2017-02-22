#!/bin/bash

# Create a resource group.
az group create --name myResourceGroup --location westeurope

# Create a virtual machine. 
az vm create \
  --image UbuntuLTS \
  --admin-username azureuser \
  --ssh-key-value ~/.ssh/id_rsa.pub \
  --resource-group myResourceGroup \
  --location westeurope \
  --name myVM

# Get network security group name.
nsg=$(az network nsg list --query "[?contains(resourceGroup,'myResourceGroup')].{name:name}" -o tsv)

# Create an inbound network security group rule for port 80.
az network nsg rule create --resource-group myResourceGroup \
  --nsg-name $nsg --name myNetworkSecurityGroupRuleHTTP \
  --protocol tcp --direction inbound --priority 2000 --source-address-prefix '*' \
  --source-port-range '*' --destination-address-prefix '*' --destination-port-range 80 \
  --access allow

# Install Docker and start container.
az vm extension set \
  --resource-group myResourceGroup \
  --vm-name myVM --name DockerExtension \
  --publisher Microsoft.Azure.Extensions \
  --version 1.1 \
  --settings '{"docker": {"port": "2375"},"compose": {"web": {"image": "nginx","ports": ["80:80"]}}}'