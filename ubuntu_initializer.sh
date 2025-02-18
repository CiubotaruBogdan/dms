#!/bin/bash

# Ubuntu Initializer
# Author: Bogdan Ciubotaru
# Script for Ubuntu system configuration

# Add text at the beginning to show how to run
echo -e "To run this script, use the following command:\n"
echo -e "\033[1;33mcurl -sSL https://ciubotarubogdan.work/ubuntu_initializer.sh | sudo bash\033[0m\n"
echo -e "Or copy this command from the website.\n"

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display progress bar
show_progress() {
    local duration=$1
    local prefix=$2
    for i in {0..100..10}; do
        echo -ne "${BLUE}${prefix} [${i}%] ["
        for ((j=0; j<i/2; j+=1)); do echo -ne "#"; done
        for ((j=i/2; j<50; j+=1)); do echo -ne " "; done
        echo -ne "]\r${NC}"
        sleep $(bc <<< "scale=2; $duration/10")
    done
    echo -e "${GREEN}${prefix} [100%] [##################################################]${NC}"
}

# Check root privileges
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}This script requires root privileges to run.${NC}"
        echo -e "${YELLOW}Please run with sudo.${NC}"
        exit 1
    fi
}

# Function for logging
log_message() {
    local message=$1
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $message" >> /var/log/ubuntu_initializer.log
}

# Function for system update
update_system() {
    echo -e "${BLUE}System update in progress...${NC}"
    log_message "Started system update"

    apt-get update 2>/var/log/ubuntu_initializer.log
    show_progress 2 "Updating package lists"

    apt-get upgrade -y 2>/var/log/ubuntu_initializer.log
    show_progress 3 "Installing updates"

    echo -e "${GREEN}System successfully updated!${NC}"
    log_message "System update completed"
}

# Function for resolution configuration
configure_resolution() {
    echo -e "${YELLOW}Screen resolution configuration${NC}"
    read -p "Enter horizontal resolution (default 1920): " horizontal
    read -p "Enter vertical resolution (default 1080): " vertical

    horizontal=${horizontal:-1920}
    vertical=${vertical:-1080}

    echo -e "${BLUE}Configuring resolution ${horizontal}x${vertical}${NC}"

    # Modify GRUB configuration
    sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash video=hyperv_fb:${horizontal}*${vertical}\"/" /etc/default/grub
    update-grub
    apt install linux-image-extra-virtual -y

    show_progress 2 "Configuring resolution"

    echo -e "${GREEN}Resolution configured. PowerShell command for Hyper-V host:${NC}"
    echo -e "${YELLOW}set-vmvideo -vmname ubuntu -horizontalresolution:${horizontal} -verticalresolution:${vertical} -resolutiontype single${NC}"

    log_message "Resolution configured to ${horizontal}x${vertical}"
}

# Function for Docker installation
install_docker() {
    echo -e "${BLUE}Installing Docker...${NC}"
    log_message "Started Docker installation"

    apt-get update
    show_progress 1 "Updating system"

    apt-get install -y ca-certificates curl
    show_progress 1 "Installing certificates"

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
    show_progress 1 "Configuring repository"

    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    show_progress 2 "Installing Docker"

    echo -e "${GREEN}Docker successfully installed!${NC}"
    log_message "Docker installation completed"
}

# Function to display logs
show_logs() {
    echo -e "${YELLOW}Latest system logs:${NC}"
    tail -n 50 /var/log/ubuntu_initializer.log
}

# Start screen
clear
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}Ubuntu Initializer${NC}"
echo -e "${YELLOW}Author: Bogdan Ciubotaru${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "\nThis script helps you configure Ubuntu system with the following options:"
echo -e "${YELLOW}0${NC} - Show system logs"
echo -e "${YELLOW}1${NC} - Update system"
echo -e "${YELLOW}2${NC} - Configure screen resolution"
echo -e "${YELLOW}3${NC} - Install Docker"
echo -e "${YELLOW}q${NC} - Exit"
echo -e "${BLUE}================================${NC}"

# Check root
check_root

# Main loop
while true; do
    read -p "Choose an option (0-3 or q to exit): " option
    case $option in
        0)
            show_logs
            ;;
        1)
            update_system
            ;;
        2)
            configure_resolution
            ;;
        3)
            install_docker
            ;;
        q|Q)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please choose between 0-3 or q to exit.${NC}"
            ;;
    esac
done