Documentación Completa para la Instalación de OKD en un Nodo Bootstrap
Esta guía detalla los pasos necesarios para instalar OKD en un nodo bootstrap, asumiendo que las máquinas virtuales y los archivos Ignition necesarios ya han sido configurados y generados.

Prerrequisitos
Acceso SSH: Debes tener acceso SSH a los nodos del clúster (bootstrap, master, worker).
Archivos Ignition Generados: Asegúrate de haber generado los archivos Ignition necesarios (bootstrap.ign, master.ign, worker.ign) utilizando openshift-install.
Terraform y KVM: Instala y configura Terraform para gestionar la infraestructura, y KVM para las máquinas virtuales.
1. Configuración del archivo install-config.yaml
El archivo install-config.yaml debe estar configurado correctamente. A continuación se muestra un ejemplo de cómo debería verse:

yaml
Copiar código
apiVersion: v1
baseDomain: cefaslocalserver.com
metadata:
  name: okd-cluster
compute:
- name: worker
  replicas: 3
controlPlane:
  name: master
  replicas: 3
networking:
  networkType: OpenShiftSDN
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {}
fips: false
pullSecret: '<YOUR_PULL_SECRET>'
sshKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC9XqGWEd2de3Ud8TgvzFchK2/SYh+WHohA1KEuveXjCbse9aXKmNAZ369vaGFFGrxbSptMeEt41ytEFpU09gAXM6KSsQWGZxfkCJQSWIaIEAdft7QHnTpMeronSgYZIU+5P7/RJcVhHBXfjLHV6giHxFRJ9MF7n6sms38VsuF2s4smI03DWGWP6Ro7siXvd+LBu2gDqosQaZQiz5/FX5YWxvuhq0E/ACas/JE8fjIL9DQPcFrgQkNAv1kHpIWRqSLPwyTMMxGgFxGI8aCTH/Uaxbqa7Qm/aBfdG2lZBE1XU6HRjAToFmqsPJv4LkBxaC1Ag62QPXONNxAA97arICr vhgalvez@gmail.com'
Asegúrate de reemplazar <YOUR_PULL_SECRET> con tu secreto de extracción real.

2. Generación de Archivos Ignition
Si aún no has generado los archivos Ignition, sigue estos pasos:

bash
Copiar código
# Moverse al directorio de instalación
cd /home/core/okd-install

# Generar los manifiestos
openshift-install create manifests --dir=/home/core/okd-install

# Generar los archivos Ignition
openshift-install create ignition-configs --dir=/home/core/okd-install

# Verificar que se hayan creado los archivos Ignition
ls /home/core/okd-install/
# Deberías ver los archivos: bootstrap.ign, master.ign, worker.ign, etc.
3. Mover el Archivo bootstrap.ign al Directorio Correcto en el Nodo Bootstrap
El archivo bootstrap.ign debe estar en el directorio /opt/openshift/ en el nodo bootstrap:

bash
Copiar código
# Crear el directorio /opt/openshift/ si no existe
sudo mkdir -p /opt/openshift/

# Mover el archivo bootstrap.ign al directorio /opt/openshift/
sudo cp /home/core/okd-install/bootstrap.ign /opt/openshift/

# Verificar que el archivo se haya movido correctamente
ls /opt/openshift/
# Deberías ver el archivo bootstrap.ign
4. Transferir los Archivos Ignition a los Nodos Master y Worker
Puedes utilizar el siguiente script para copiar los archivos Ignition a los nodos correspondientes:

bash
Copiar código
#!/bin/bash

# Define un array con los nombres de host y sus direcciones IP correspondientes
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
  echo "Creating directory and copying $ignition_file to $host ($ip)..."
  ssh -i "$SSH_KEY" core@$ip "sudo mkdir -p /opt/openshift/"
  scp -i "$SSH_KEY" "$IGNITION_DIR/$ignition_file" core@$ip:/opt/openshift/$ignition_file
done
5. Comenzar la Instalación del Clúster
Una vez que los archivos Ignition estén en su lugar, comienza la instalación del clúster desde el nodo bootstrap:

bash
Copiar código
openshift-install create cluster --dir=/home/core/okd-install --log-level=debug
6. Verificar los Archivos Ignition en los Nodos
Después de copiar los archivos, verifica que estén en el directorio correcto en cada nodo:

bash
Copiar código
ls /opt/openshift/
# Deberías ver los archivos Ignition correspondientes
7. Esperar a que el Proceso de Bootstrap Complete
Ejecuta el siguiente comando para esperar a que el proceso de bootstrap complete:

bash
Copiar código
openshift-install wait-for bootstrap-complete --dir=/home/core/okd-install
Solución de Problemas
Si encuentras problemas durante la instalación, revisa los logs de los servicios importantes:
bash
Copiar código
journalctl -b -f -u bootkube.service
journalctl -b -f -u kubelet.service
Para obtener más detalles sobre la instalación de OKD, puedes consultar la documentación oficial de OKD y la guía de instalación en Red Hat.









Paso 1: Dar Permisos de Ejecución al Script
Otorga permisos de ejecución al script copy_ignition_files.sh:

bash
Copiar código
chmod +x copy_ignition_files.sh
Paso 2: Ejecutar el Script con Sudo
Ejecuta el script modificado para copiar los archivos de ignición a los nodos maestros y trabajadores:

bash
Copiar código
sudo ./copy_ignition_files.sh
Si el script todavía falla debido a permisos, verifica que los nodos pueden recibir archivos en los directorios especificados y que los permisos de sudo están configurados adecuadamente.