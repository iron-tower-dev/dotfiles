# Virtualization Configuration

This directory contains QEMU/KVM and libvirt configuration for managing virtual machines on your Arch Linux system.

## Features

- **QEMU/KVM**: Full hardware virtualization support
- **libvirt**: Advanced VM management API
- **virt-manager**: GUI for managing VMs
- **Helper Scripts**: Convenient CLI tools for VM operations
- **Pre-configured Templates**: Quick VM creation for common OSes

## Installation

### Full Installation
```bash
# Install all virtualization packages and setup
./bootstrap.sh --virt

# Deploy virtualization configurations
stow -t ~ virt
```

### Manual Installation
```bash
# Install packages only
./setup/packages/04-virt-packages.sh

# Deploy configurations
cd ~/dotfiles && stow -t ~ virt
```

**Important**: After installation, log out and back in for group permissions to take effect.

## Usage

### VM Management Commands

The `vm` command provides a unified interface for managing virtual machines:

```bash
# List all VMs
vm list

# Start a VM
vm start ubuntu-vm

# Stop a VM (graceful shutdown)
vm stop ubuntu-vm

# Force stop a VM
vm force-stop ubuntu-vm

# Restart a VM
vm restart ubuntu-vm

# Show VM status
vm status ubuntu-vm

# Show detailed VM information
vm info ubuntu-vm

# Connect to VM console
vm console ubuntu-vm

# Delete a VM (with confirmation)
vm delete ubuntu-vm

# Clone a VM
vm clone ubuntu-vm ubuntu-vm-clone

# List virtual networks
vm networks

# List storage pools
vm pools
```

### Creating VMs

#### Quick Creation with Templates
```bash
# Interactive VM creation with predefined templates
vm-quick-create

# Available templates:
# 1. Ubuntu Desktop (4GB RAM, 2 CPUs, 30GB disk)
# 2. Ubuntu Server (2GB RAM, 2 CPUs, 20GB disk)
# 3. Fedora Workstation (4GB RAM, 2 CPUs, 30GB disk)
# 4. Arch Linux (2GB RAM, 2 CPUs, 25GB disk)
# 5. Windows 11 (8GB RAM, 4 CPUs, 60GB disk, UEFI + TPM)
# 6. Debian (2GB RAM, 2 CPUs, 20GB disk)
# 7. Custom (specify your own parameters)
```

#### Interactive Creation
```bash
# Create VM with interactive prompts
vm create
```

#### Using virt-install Directly
```bash
# Create a VM from command line
virt-install \
    --name my-vm \
    --memory 2048 \
    --vcpus 2 \
    --disk size=20 \
    --cdrom /path/to/iso \
    --os-variant detect=on \
    --graphics spice \
    --network network=default
```

### GUI Management

```bash
# Open virt-manager GUI
virt-manager

# Open VM viewer for specific VM
virt-viewer ubuntu-vm
```

### Advanced Operations

#### Working with Snapshots
```bash
# Create a snapshot
virsh snapshot-create-as ubuntu-vm snapshot1 "My snapshot description"

# List snapshots
virsh snapshot-list ubuntu-vm

# Restore a snapshot
virsh snapshot-revert ubuntu-vm snapshot1

# Delete a snapshot
virsh snapshot-delete ubuntu-vm snapshot1
```

#### Networking
```bash
# List networks
virsh net-list --all

# Start a network
virsh net-start default

# Create a new network
virsh net-define /path/to/network.xml
virsh net-start my-network
virsh net-autostart my-network
```

#### Storage Pools
```bash
# List storage pools
virsh pool-list --all

# Create a new storage pool
virsh pool-define-as my-pool dir --target /path/to/pool
virsh pool-build my-pool
virsh pool-start my-pool
virsh pool-autostart my-pool

# List volumes in a pool
virsh vol-list default
```

## Configuration Files

- `~/.config/libvirt/libvirt.conf` - Libvirt client configuration
- `~/.local/bin/vm` - Main VM management script
- `~/.local/bin/vm-quick-create` - Quick VM creation with templates

## VM Storage

By default, VMs are stored in:
- **Disk Images**: `~/VMs/`
- **ISO Files**: You can store them anywhere, commonly in `~/VMs/ISOs/`

## Troubleshooting

### Check Virtualization Support
```bash
# Check if CPU supports virtualization
grep -E '(vmx|svm)' /proc/cpuinfo

# Check KVM module
lsmod | grep kvm
```

### Check Service Status
```bash
# Check libvirtd service
sudo systemctl status libvirtd

# Restart libvirtd if needed
sudo systemctl restart libvirtd
```

### Permission Issues
```bash
# Check if you're in the required groups
groups $USER | grep -E '(libvirt|kvm)'

# If not, add yourself (done by setup script)
sudo usermod -aG libvirt,kvm $USER

# Log out and back in for changes to take effect
```

### Network Issues
```bash
# Check default network
virsh net-info default

# If not active, start it
sudo virsh net-start default
sudo virsh net-autostart default
```

### VM Won't Start
```bash
# Check VM status
virsh dominfo vm-name

# View VM logs
sudo journalctl -u libvirtd -f

# Check VM XML definition
virsh dumpxml vm-name
```

## Performance Tips

### Enable Nested Virtualization
```bash
# For Intel CPUs
echo "options kvm_intel nested=1" | sudo tee /etc/modprobe.d/kvm.conf

# For AMD CPUs
echo "options kvm_amd nested=1" | sudo tee /etc/modprobe.d/kvm.conf

# Reload module (or reboot)
sudo modprobe -r kvm_intel  # or kvm_amd
sudo modprobe kvm_intel     # or kvm_amd
```

### CPU Pinning
```bash
# Edit VM configuration
virsh edit vm-name

# Add CPU pinning in <vcpu> section:
# <vcpu placement='static'>2</vcpu>
# <cputune>
#   <vcpupin vcpu='0' cpuset='0'/>
#   <vcpupin vcpu='1' cpuset='1'/>
# </cputune>
```

### Memory Ballooning
VMs automatically use memory ballooning for better memory management. You can adjust this in virt-manager or by editing the VM XML.

## Common ISO Downloads

- **Ubuntu**: https://ubuntu.com/download
- **Fedora**: https://getfedora.org/
- **Arch Linux**: https://archlinux.org/download/
- **Debian**: https://www.debian.org/distrib/
- **Windows**: https://www.microsoft.com/software-download/

## Resources

- **libvirt Documentation**: https://libvirt.org/docs.html
- **QEMU Documentation**: https://www.qemu.org/docs/master/
- **virt-manager**: https://virt-manager.org/
- **Arch Wiki KVM**: https://wiki.archlinux.org/title/KVM