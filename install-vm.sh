# Define variables -------------------------------------------------------
HOST_NAME=cloudy
HOST_MEMORY=2048
HOST_CPUS=2
HOST_OS_DIST=ubuntu18.04
IMG=cloudy.img

echo "------------------ Install and start the configured VM ------------------\n"
virt-install \
  --connect qemu:///system \
  --name $HOST_NAME \
  --virt-type kvm --memory $HOST_MEMORY --vcpus $HOST_CPUS \
  --boot hd \
  --disk path=$IMG,device=cdrom \
  --disk path=snapshot-bionic-server-cloudimg.qcow2,device=disk \
  --graphics vnc \
  --os-type Linux --os-variant $HOST_OS_DIST \
  --network network:default \
  --console pty,target_type=serial

