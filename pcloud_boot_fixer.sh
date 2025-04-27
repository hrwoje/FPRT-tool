#!/bin/bash

# Pcloud Boot Fixer
# A script to automate fixing pCloud startup issues

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Icons
CHECK="✓"
CROSS="✗"
INFO="ℹ"
WARN="⚠"
GEAR="⚙"
SPINNER=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

# Function to show spinner
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}${CROSS} This script needs to be run as root. Please use sudo.${NC}"
        exit 1
    fi
}

# Function to check if pCloud AppImage exists
check_pcloud_exists() {
    if [ ! -f "/home/$SUDO_USER/AppImages/pcloud.AppImage" ]; then
        echo -e "${RED}${CROSS} pCloud AppImage not found in /home/$SUDO_USER/AppImages/${NC}"
        echo -e "${YELLOW}${INFO} Please download pCloud AppImage and place it in /home/$SUDO_USER/AppImages/${NC}"
        exit 1
    fi
}

# Function to handle errors
handle_error() {
    local error_code=$1
    local error_message=$2
    local fix_command=$3
    
    echo -e "${RED}${CROSS} Error: $error_message${NC}"
    echo -e "${YELLOW}${INFO} Attempting to fix automatically...${NC}"
    
    if [ -n "$fix_command" ]; then
        eval "$fix_command" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}${CHECK} Fixed successfully!${NC}"
        else
            echo -e "${RED}${CROSS} Automatic fix failed. Please try manual fix.${NC}"
        fi
    fi
}

# Function to create autostart entry
create_autostart() {
    echo -e "${YELLOW}${GEAR} Creating pCloud autostart entry...${NC}"
    mkdir -p ~/.config/autostart 2>/dev/null || handle_error $? "Failed to create autostart directory" "mkdir -p ~/.config/autostart"
    
    cat > ~/.config/autostart/pcloud.desktop << EOF
[Desktop Entry]
Type=Application
Name=pCloud
Exec=/home/$SUDO_USER/AppImages/pcloud.AppImage
Terminal=false
Comment=pCloud Drive
EOF
    
    if [ $? -ne 0 ]; then
        handle_error $? "Failed to create desktop entry" "chown $SUDO_USER:$SUDO_USER ~/.config/autostart"
    fi
    
    chmod +x ~/.config/autostart/pcloud.desktop 2>/dev/null || handle_error $? "Failed to set executable permissions" "chmod +x ~/.config/autostart/pcloud.desktop"
    echo -e "${GREEN}${CHECK} Autostart entry created successfully!${NC}"
}

# Function to create systemd service
create_systemd_service() {
    echo -e "${YELLOW}${GEAR} Creating systemd service...${NC}"
    
    cat > /etc/systemd/system/pcloud.service << EOF
[Unit]
Description=pCloud Drive
After=network.target

[Service]
Type=simple
User=$SUDO_USER
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/$SUDO_USER/.Xauthority
ExecStart=/home/$SUDO_USER/AppImages/pcloud.AppImage
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    
    if [ $? -ne 0 ]; then
        handle_error $? "Failed to create systemd service" "chown root:root /etc/systemd/system/pcloud.service"
    fi
    
    systemctl daemon-reload 2>/dev/null || handle_error $? "Failed to reload systemd daemon" "systemctl daemon-reload"
    systemctl enable pcloud 2>/dev/null || handle_error $? "Failed to enable pcloud service" "systemctl enable pcloud"
    echo -e "${GREEN}${CHECK} Systemd service created and enabled!${NC}"
}

# Function to fix SELinux context
fix_selinux() {
    echo -e "${YELLOW}${GEAR} Fixing SELinux context...${NC}"
    restorecon -Rv ~/.config/autostart/ 2>/dev/null || handle_error $? "Failed to fix SELinux context for autostart" "restorecon -Rv ~/.config/autostart/"
    restorecon -Rv /home/$SUDO_USER/AppImages/ 2>/dev/null || handle_error $? "Failed to fix SELinux context for AppImages" "restorecon -Rv /home/$SUDO_USER/AppImages/"
    echo -e "${GREEN}${CHECK} SELinux context fixed!${NC}"
}

# Function to check pCloud status
check_status() {
    echo -e "${YELLOW}${INFO} Checking pCloud status...${NC}"
    
    # Check systemd service
    if systemctl is-active --quiet pcloud; then
        echo -e "${GREEN}${CHECK} pCloud service is running${NC}"
    else
        echo -e "${RED}${CROSS} pCloud service is not running${NC}"
        echo -e "${YELLOW}${INFO} Attempting to start service...${NC}"
        systemctl start pcloud 2>/dev/null && echo -e "${GREEN}${CHECK} Service started successfully!${NC}" || echo -e "${RED}${CROSS} Failed to start service${NC}"
    fi
    
    # Check autostart entry
    if [ -f ~/.config/autostart/pcloud.desktop ]; then
        echo -e "${GREEN}${CHECK} Autostart entry exists${NC}"
    else
        echo -e "${RED}${CROSS} Autostart entry does not exist${NC}"
        echo -e "${YELLOW}${INFO} Attempting to create autostart entry...${NC}"
        create_autostart
    fi
    
    # Check AppImage permissions
    if [ -f "/home/$SUDO_USER/AppImages/pcloud.AppImage" ]; then
        if [ ! -x "/home/$SUDO_USER/AppImages/pcloud.AppImage" ]; then
            echo -e "${RED}${CROSS} pCloud AppImage is not executable${NC}"
            echo -e "${YELLOW}${INFO} Fixing permissions...${NC}"
            chmod +x "/home/$SUDO_USER/AppImages/pcloud.AppImage" 2>/dev/null && echo -e "${GREEN}${CHECK} Permissions fixed!${NC}" || echo -e "${RED}${CROSS} Failed to fix permissions${NC}"
        else
            echo -e "${GREEN}${CHECK} pCloud AppImage is executable${NC}"
        fi
    else
        echo -e "${RED}${CROSS} pCloud AppImage not found${NC}"
    fi
}

# Function to start pCloud
start_pcloud() {
    echo -e "${YELLOW}${GEAR} Starting pCloud...${NC}"
    systemctl start pcloud 2>/dev/null || handle_error $? "Failed to start pCloud service" "systemctl start pcloud"
    echo -e "${GREEN}${CHECK} pCloud started!${NC}"
}

# Function to stop pCloud
stop_pcloud() {
    echo -e "${YELLOW}${GEAR} Stopping pCloud...${NC}"
    systemctl stop pcloud 2>/dev/null || handle_error $? "Failed to stop pCloud service" "systemctl stop pcloud"
    echo -e "${GREEN}${CHECK} pCloud stopped!${NC}"
}

# Function to restart pCloud
restart_pcloud() {
    echo -e "${YELLOW}${GEAR} Restarting pCloud...${NC}"
    systemctl restart pcloud 2>/dev/null || handle_error $? "Failed to restart pCloud service" "systemctl restart pcloud"
    echo -e "${GREEN}${CHECK} pCloud restarted!${NC}"
}

# Function to perform automatic fixes
auto_fix() {
    echo -e "${BLUE}${INFO} Starting automatic fixes...${NC}"
    check_pcloud_exists
    create_autostart
    create_systemd_service
    fix_selinux
    start_pcloud
    check_status
    echo -e "${GREEN}${CHECK} Automatic fixes completed!${NC}"
}

# Main menu
show_menu() {
    clear
    echo -e "${GREEN}=== Pcloud Boot Fixer ===${NC}"
    echo -e "${BLUE}${INFO} Choose an option:${NC}"
    echo "1. ${GEAR} Create autostart entry"
    echo "2. ${GEAR} Create systemd service"
    echo "3. ${GEAR} Fix SELinux context"
    echo "4. ${INFO} Check pCloud status"
    echo "5. ${GEAR} Start pCloud"
    echo "6. ${GEAR} Stop pCloud"
    echo "7. ${GEAR} Restart pCloud"
    echo "8. ${GEAR} Apply all fixes"
    echo "9. ${CROSS} Exit"
    echo -e "${YELLOW}Please choose an option:${NC}"
}

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)
            check_root
            create_autostart
            ;;
        2)
            check_root
            create_systemd_service
            ;;
        3)
            check_root
            fix_selinux
            ;;
        4)
            check_status
            ;;
        5)
            check_root
            start_pcloud
            ;;
        6)
            check_root
            stop_pcloud
            ;;
        7)
            check_root
            restart_pcloud
            ;;
        8)
            check_root
            auto_fix
            ;;
        9)
            echo -e "${GREEN}${CHECK} Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}${CROSS} Invalid option. Please try again.${NC}"
            ;;
    esac
    
    echo -e "${YELLOW}${INFO} Press Enter to continue...${NC}"
    read -r
done 