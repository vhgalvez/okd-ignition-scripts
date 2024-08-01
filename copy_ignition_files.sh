#!/bin/bash

# Verificar la existencia de los archivos Ignition
IGNITION_DIR="/home/core/okd-install"
FILES=("bootstrap.ign" "master.ign" "worker.ign")

for file in "${FILES[@]}"; do
  if [[ ! -f "$IGNITION_DIR/$file" ]]; then
    echo "Error: $IGNITION_DIR/$file no existe. Asegúrate de que los archivos Ignition se hayan generado correctamente."
    exit 1
  fi
done

# Define un array con los nombres de los hosts y sus direcciones IP correspondientes
declare -A hosts
hosts=(
  ["master1"]="10.17.4.21"
  ["master2"]="10.17.4.22"
  ["master3"]="10.17.4.23"
  ["worker1"]="10.17.4.24"
  ["worker2"]="10.17.4.25"
  ["worker3"]="10.17.4.26"
)

# Ruta a la clave SSH
SSH_KEY="/home/core/.ssh/id_rsa_key_cluster_openshift"

# Ruta a los archivos Ignition
IGNITION_DIR="/home/core/okd-install"

# Iterar sobre el array y copiar los archivos Ignition correspondientes
for host in "${!hosts[@]}"; do
  ip=${hosts[$host]}
  if [[ $host == master* ]]; then
    ignition_file="master.ign"
  else
    ignition_file="worker.ign"
  fi
  echo "Creando directorio y copiando $ignition_file a $host ($ip)..."
  ssh -i "$SSH_KEY" core@$ip "sudo mkdir -p /opt/openshift/ && sudo rm -f /opt/openshift/$ignition_file"
  scp -i "$SSH_KEY" "$IGNITION_DIR/$ignition_file" core@$ip:/tmp/$ignition_file
  ssh -i "$SSH_KEY" core@$ip "sudo mv /tmp/$ignition_file /opt/openshift/$ignition_file"
done

# Copiar el archivo bootstrap.ign al directorio adecuado en el nodo bootstrap
echo "Copiando bootstrap.ign a /opt/openshift/ en el nodo bootstrap..."
sudo mkdir -p /opt/openshift/
sudo cp /home/core/okd-install/bootstrap.ign /opt/openshift/
