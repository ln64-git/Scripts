#!/bin/bash

# List all virtual machines
echo "Listing all VMs..."
pkexec virsh list --all

# Check if "kali-linux" VM is running
vm_status=$(virsh list --all | grep "kali-linux" | grep -o "running")

if [ "$vm_status" != "running" ]; then
  echo "'kali-linux' VM is not running. Attempting to start..."
  virsh start kali-linux
  # Check if the VM started successfully
  if [ $? -eq 0 ]; then
    echo "'kali-linux' VM started successfully."
  else
    echo "Failed to start 'kali-linux' VM."
    exit 1
  fi
else
  echo "'kali-linux' VM is already running."
fi

# Open virt-manager, focusing on the "kali-linux" VM
echo "Opening 'kali-linux' VM in virt-manager..."
virt-manager --connect qemu:///system --show-domain-console "kali-linux"

# virt-manager --connect qemu:///system --show-domain-console kali-linux &

# Note: The --show-domain-console option attempts to open the console of the specified domain (VM).
# If this option does not work as expected, you might need to manually select the VM in virt-manager.
