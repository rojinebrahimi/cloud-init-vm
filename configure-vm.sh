#! /bin/bash
#set -x

# Define variables -------------------------------------------------------
HOST_IP_ADDRESS=192.168.122.150
CLOUD_CONFIG_FILE=user-data.cfg
NETWORK_CONFIG_FILE=network-config.cfg
SNAPSHOT=snapshot-bionic-server-cloudimg.qcow2
IMG=cloudy.img
UBUNTU_CLOUD_IMG=bionic-server-cloudimg-amd64.img
META_DATA_FILE=meta-data.cfg
HD_SIZE=10G
SSH_KEY_HOST=cloudy

# Download Ubuntu bionic image -------------------------------------------
if [ ! -f "/var/lib/libvirt/boot/$UBUNTU_CLOUD_IMG" ]; then
    echo "\n------------------ Download Ubuntu cloud image ------------------"
    curl -O https://cloud-images.ubuntu.com/bionic/current/$UBUNTU_CLOUD_IMG
    sudo mv $UBUNTU_CLOUD_IMG /var/lib/libvirt/boot/

    # In case original image needs to be downloaded, new snapshot will be created based on that 
    if [ -f "snapshot*" ]; then
        rm -f snapshot*
    fi
fi

# SSH-KEY ----------------------------------------------------------------
echo "\n------------------ Generate SSH-KEY ------------------"
if [ -f "id_rsa.pub" ]; then
    echo "Key already generated."

elif [ ! -f "id_rsa.pub" ]; then
    ssh-keygen -R $HOST_IP_ADDRESS
    ssh-keygen -t rsa -b 4096 -f id_rsa -C $SSH_KEY_HOST -N "" -q
    cp id_rsa /home/$USER/.ssh/
    generated_key=$(cat id_rsa.pub)

    echo "\n------------------ Substitue SSH-KEY to Cloud-init configuration ------------------"
    if grep -q "SSH_HERE" "$CLOUD_CONFIG_FILE"; then
        sed -i "s@SSH_HERE@${generated_key}@" $CLOUD_CONFIG_FILE
    elif grep -q "ssh-rsa" "$CLOUD_CONFIG_FILE"; then
        sed -i "s@ssh-rsa.*@${generated_key}@" $CLOUD_CONFIG_FILE
    fi
fi

# Initialize VM ----------------------------------------------------------
if [ ! -f "$SNAPSHOT" ]; then
    echo "\n------------------ Create snapshot, increase size ------------------"
    qemu-img create -b /var/lib/libvirt/boot/$UBUNTU_CLOUD_IMG -f qcow2 -F qcow2 $SNAPSHOT $HD_SIZE
else
    echo "Snapshot already exists."
fi

echo "\n------------------ Show snapshot info ------------------"
qemu-img info $SNAPSHOT

if [ ! -f "$IMG" ]; then
    echo "\n------------------ Generate image ------------------"
    cloud-localds -v --network-config=$NETWORK_CONFIG_FILE $IMG $CLOUD_CONFIG_FILE $META_DATA_FILE
else
    echo "Image already generated."
fi

echo "\n------------------ Show generated image info ------------------"
qemu-img info $IMG
