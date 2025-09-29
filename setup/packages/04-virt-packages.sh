#!/usr/bin/env bash
# 04-virt-packages.sh - Install virtualization packages (QEMU/KVM/libvirt)

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_virtualization_support() {
    log_info "Checking CPU virtualization support..."
    
    if ! grep -E '(vmx|svm)' /proc/cpuinfo > /dev/null; then
        log_error "CPU virtualization not supported or not enabled in BIOS"
        log_error "Please enable VT-x (Intel) or AMD-V (AMD) in your BIOS settings"
        return 1
    fi
    
    if grep -q "vmx" /proc/cpuinfo; then
        log_success "Intel VT-x detected"
    elif grep -q "svm" /proc/cpuinfo; then
        log_success "AMD-V detected"
    fi
}

install_virt_packages() {
    log_info "Installing QEMU/KVM and libvirt packages..."
    
    # Handle iptables/iptables-nft conflict
    # libvirt requires iptables-nft for network filtering
    log_info "Ensuring iptables-nft is installed..."
    if ! sudo pacman -S --noconfirm --needed iptables-nft 2>&1 | grep -q "conflicting"; then
        log_success "iptables-nft is ready"
    else
        log_warning "Replacing legacy iptables with iptables-nft (required for libvirt)..."
        # Remove iptables and install iptables-nft
        if sudo pacman -Rdd --noconfirm iptables 2>/dev/null; then
            log_info "Removed legacy iptables"
        fi
        if sudo pacman -S --noconfirm iptables-nft; then
            log_success "iptables-nft installed successfully"
        else
            log_error "Failed to install iptables-nft"
            return 1
        fi
    fi
    
    local packages=(
        # Core virtualization
        qemu-full              # Full QEMU system emulation
        libvirt                # Virtualization API
        virt-manager           # GUI for managing VMs
        virt-viewer            # VM display viewer
        dnsmasq                # DHCP/DNS for virtual networks
        bridge-utils           # Network bridge utilities
        openbsd-netcat         # Networking for libvirt
        
        # Storage and networking
        dmidecode              # DMI table decoder
        ebtables               # Ethernet bridge frame table administration
        
        # Additional tools
        libguestfs             # Tools for accessing VM disk images
        virt-install           # CLI tool for creating VMs
        
        # UEFI/BIOS firmware
        edk2-ovmf              # UEFI firmware for VMs
        swtpm                  # TPM emulator for Windows 11
    )
    
    if ! sudo pacman -S --needed --noconfirm "${packages[@]}"; then
        log_error "Failed to install virtualization packages"
        return 1
    fi
    
    log_success "Virtualization packages installed successfully"
}

configure_libvirt_service() {
    log_info "Configuring libvirt service..."
    
    # Enable and start libvirtd service
    if ! sudo systemctl enable libvirtd.service; then
        log_error "Failed to enable libvirtd service"
        return 1
    fi
    
    if ! sudo systemctl start libvirtd.service; then
        log_error "Failed to start libvirtd service"
        return 1
    fi
    
    # Enable and start virtlogd socket
    sudo systemctl enable virtlogd.socket 2>/dev/null || true
    sudo systemctl start virtlogd.socket 2>/dev/null || true
    
    log_success "Libvirt service configured and started"
}

configure_user_permissions() {
    log_info "Configuring user permissions for libvirt..."
    
    local username="${SUDO_USER:-$USER}"
    
    # Add user to libvirt group
    if ! sudo usermod -aG libvirt "$username"; then
        log_error "Failed to add user to libvirt group"
        return 1
    fi
    
    # Add user to kvm group
    if ! sudo usermod -aG kvm "$username"; then
        log_error "Failed to add user to kvm group"
        return 1
    fi
    
    log_success "User '$username' added to libvirt and kvm groups"
    log_warning "You need to log out and back in for group changes to take effect"
}

configure_default_network() {
    log_info "Configuring default libvirt network..."
    
    # Define and start default network if not already active
    if ! sudo virsh net-info default &>/dev/null; then
        sudo virsh net-define /usr/share/libvirt/networks/default.xml 2>/dev/null || true
    fi
    
    sudo virsh net-start default 2>/dev/null || true
    sudo virsh net-autostart default 2>/dev/null || true
    
    log_success "Default network configured"
}

enable_nested_virtualization() {
    log_info "Enabling nested virtualization (if supported)..."
    
    if grep -q "vmx" /proc/cpuinfo; then
        # Intel CPU
        if [[ -f /sys/module/kvm_intel/parameters/nested ]]; then
            if [[ "$(cat /sys/module/kvm_intel/parameters/nested)" == "N" ]]; then
                echo "options kvm_intel nested=1" | sudo tee /etc/modprobe.d/kvm.conf > /dev/null
                log_warning "Nested virtualization enabled. Reboot required for changes to take effect."
            else
                log_success "Nested virtualization already enabled (Intel)"
            fi
        fi
    elif grep -q "svm" /proc/cpuinfo; then
        # AMD CPU
        if [[ -f /sys/module/kvm_amd/parameters/nested ]]; then
            if [[ "$(cat /sys/module/kvm_amd/parameters/nested)" == "0" ]]; then
                echo "options kvm_amd nested=1" | sudo tee /etc/modprobe.d/kvm.conf > /dev/null
                log_warning "Nested virtualization enabled. Reboot required for changes to take effect."
            else
                log_success "Nested virtualization already enabled (AMD)"
            fi
        fi
    fi
}

create_vm_storage_pool() {
    log_info "Creating default VM storage pool..."
    
    local pool_dir="$HOME/VMs"
    
    # Create storage directory
    mkdir -p "$pool_dir"
    
    # Define storage pool if not exists
    if ! sudo virsh pool-info default &>/dev/null; then
        sudo virsh pool-define-as default dir --target "$pool_dir" 2>/dev/null || true
        sudo virsh pool-build default 2>/dev/null || true
        sudo virsh pool-start default 2>/dev/null || true
        sudo virsh pool-autostart default 2>/dev/null || true
        
        log_success "Default storage pool created at $pool_dir"
    else
        log_success "Default storage pool already exists"
    fi
}

verify_installation() {
    log_info "Verifying installation..."
    
    local all_good=true
    
    # Check if libvirtd is running
    if sudo systemctl is-active --quiet libvirtd.service; then
        log_success "✓ libvirtd service is running"
    else
        log_error "✗ libvirtd service is not running"
        all_good=false
    fi
    
    # Check if default network exists
    if sudo virsh net-info default &>/dev/null; then
        log_success "✓ Default network configured"
    else
        log_warning "⚠ Default network not configured"
    fi
    
    # Check KVM module
    if lsmod | grep -q kvm; then
        log_success "✓ KVM kernel module loaded"
    else
        log_error "✗ KVM kernel module not loaded"
        all_good=false
    fi
    
    # Check if user is in groups (needs re-login to take effect)
    if groups "${SUDO_USER:-$USER}" | grep -q libvirt; then
        log_success "✓ User in libvirt group"
    else
        log_warning "⚠ User not in libvirt group (may need to re-login)"
    fi
    
    if $all_good; then
        log_success "Virtualization setup complete!"
    else
        log_error "Some issues detected. Please review the errors above."
        return 1
    fi
}

print_next_steps() {
    echo ""
    echo -e "${GREEN}=== Next Steps ===${NC}"
    echo "1. Log out and back in for group permissions to take effect"
    echo "2. Deploy virtualization configs: ${BLUE}stow -t ~ virt${NC}"
    echo "3. Create your first VM: ${BLUE}vm-create${NC} or use ${BLUE}virt-manager${NC}"
    echo "4. List VMs: ${BLUE}vm-list${NC}"
    echo ""
    echo -e "${YELLOW}Useful commands:${NC}"
    echo "  - ${BLUE}virt-manager${NC}        - Open GUI management tool"
    echo "  - ${BLUE}virsh list --all${NC}    - List all VMs"
    echo "  - ${BLUE}vm-create${NC}            - Interactive VM creation"
    echo "  - ${BLUE}vm-start <name>${NC}     - Start a VM"
    echo "  - ${BLUE}vm-stop <name>${NC}      - Stop a VM"
    echo ""
}

main() {
    log_info "Starting virtualization setup..."
    echo ""
    
    check_virtualization_support || exit 1
    echo ""
    
    install_virt_packages || exit 1
    echo ""
    
    configure_libvirt_service || exit 1
    echo ""
    
    configure_user_permissions || exit 1
    echo ""
    
    configure_default_network || exit 1
    echo ""
    
    enable_nested_virtualization || true
    echo ""
    
    create_vm_storage_pool || exit 1
    echo ""
    
    verify_installation || exit 1
    echo ""
    
    print_next_steps
}

main "$@"