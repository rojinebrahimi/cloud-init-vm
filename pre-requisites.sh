#! /bin/bash

# set -x
cd /home/$USER

echo "\n--------------- Check virtualization support ---------------"
check_virtualization=$(grep -Eoc '(vmx|svm)' /proc/cpuinfo)
if ! grep -s -q 0 "$check_virtualization"; then
    echo "CPU supports hardware virtualization."
else
    echo "CPU does not support hardware virtualization."
    exit
fi

echo "\n--------------- Update APT, install CPU checker ---------------"
sudo apt update
sudo apt -y install cpu-checker

echo "\n--------------- Test if KVM can be used ---------------"
# Fails and exits if not capable of using KVM

sudo kvm-ok
if [ $? -eq 0 ]; then
    echo "KVM oK"
else
    echo "KVM cannot be used."
    exit
fi

echo "\n--------------- Installing necessary packages ---------------"
sudo apt install -y qemu-kvm qemu libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager cloud-image-utils

echo "\n--------------- Check libvirtd activation ---------------"
sudo systemctl is-active libvirtd

echo "\n--------------- Add user to libvirt ---------------"
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
sudo chmod 755 /var/lib/libvirt/boot/

echo "\n--------------- Reboot system ---------------"
read -p "The system is about to reboot in order to apply changes; would you like to proceed with that? (y to accept and any character to deny): " reboot_option
if [ "$reboot_option" = "y" ] || [ "$reboot_option" = "Y" ]; then
    reboot
else
    echo "Reboot aborted."
fi
