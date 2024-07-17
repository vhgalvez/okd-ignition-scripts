# OKD Ignition Scripts

Este repositorio contiene scripts y configuraciones necesarias para la instalación y configuración de un clúster OKD utilizando archivos Ignition.

## Prerrequisitos

- Acceso SSH a los nodos del clúster (bootstrap, master, worker).
- Archivos Ignition generados (`bootstrap.ign`, `master.ign`, `worker.ign`) utilizando `openshift-install`.
- Terraform instalado y configurado para gestionar la infraestructura.

## Generar Archivos Ignition

1. Moverse al directorio de instalación:
   ```bash
   cd /home/core/okd-install
   ```

Generar los manifiestos:

```bash
openshift-install create manifests --dir=/home/core/okd-install
```
Generar los archivos Ignition:

```bash
openshift-install create ignition-configs --dir=/home/core/okd-install
```
Verificar que se hayan creado los archivos Ignition:

```bash
ls /home/core/okd-install/
```

# Deberías ver los archivos: bootstrap.ign, master.ign, worker.ign, etc.

Copiar Archivos Ignition a los Nodos
Script de Copia
Este script copia los archivos Ignition generados a los nodos correspondientes:

```bash
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
SSH_KEY="/root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift"

# Path to the Ignition files
IGNITION_DIR="/home/core/okd-install"

# Iterate over the array and copy the corresponding ignition files
for host in "${!hosts[@]}"; do
  ip=${hosts[$host]}
  if [[ $host == master* ]]; then
    ignition_file="master.ign"
  else
    ignition_file="worker.ign"
  fi
  echo "Copying $ignition_file to $host ($ip)..."
  scp -i "$SSH_KEY" "$IGNITION_DIR/$ignition_file" core@$ip:/opt/openshift/$ignition_file
done
```

Uso del Script
Asegúrate de que el directorio /opt/openshift/ exista en cada nodo. Si no existe, créalo con el siguiente comando en cada nodo:

```bash
sudo mkdir -p /opt/openshift/
```

Ejecuta el script para copiar los archivos

Ignition a los nodos:

```bash
./nombre_del_script.sh
```

Comenzar la Instalación del Clúster
Una vez que los archivos Ignition estén en su lugar, comienza la instalación del clúster desde el nodo bootstrap:

```bash
openshift-install create cluster --dir=/home/core/okd-install --log-level=debug
```

Verificar los Archivos Ignition en los Nodos
Después de copiar los archivos, verifica que estén en el directorio correcto en cada nodo:

```bash
ls /opt/openshift/
```

# Deberías ver los archivos Ignition correspondientes

Contribuir

Si deseas contribuir a este proyecto, por favor haz un fork del repositorio y envía un pull request con tus cambios.

Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.