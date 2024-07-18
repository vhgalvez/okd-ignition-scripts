#!/bin/bash

# Define an array with the hostnames and their corresponding IP addresses
declare -A hosts
hosts=(
  ["master1"]="10.17.4.21"
  ["master2"]="10.17.4.22"
  ["master3"]="10.17.4.23"
  ["worker1"]="10.17.4.24"
  ["worker2"]="10.17.4.25"
  ["worker3"]="10.17.4.26"
)

# Path to the SSH key
SSH_KEY="/home/core/.ssh/id_rsa_key_cluster_openshift"

# Path to the Ignition files
IGNITION_DIR="/home/core/okd-install"

# Iterate over the array and create the directory and copy the corresponding ignition files
for host in "${!hosts[@]}"; do
  ip=${hosts[$host]}
  if [[ $host == master* ]]; then
    ignition_file="master.ign"
  else
    ignition_file="worker.ign"
  fi
  echo "Creating directory and copying $ignition_file to $host ($ip)..."
  sudo ssh -i "$SSH_KEY" core@$ip "sudo mkdir -p /opt/openshift/ && sudo chown core:core /opt/openshift/"
  sudo scp -i "$SSH_KEY" "$IGNITION_DIR/$ignition_file" core@$ip:/opt/openshift/$ignition_file
  sudo ssh -i "$SSH_KEY" core@$ip "sudo chown root:root /opt/openshift/$ignition_file"
done