# Pcloud Boot Fixer

![pCloud Logo](https://www.pcloud.com/img/logo.png)

A powerful bash script to automatically fix and manage pCloud startup issues on Linux systems. This tool provides a user-friendly menu interface to handle common pCloud problems and automate the setup process.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Error Handling](#error-handling)
- [Troubleshooting](#troubleshooting)
- [System Requirements](#system-requirements)
- [Supported Distributions](#supported-distributions)
- [Common Issues](#common-issues)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)
- [Support](#support)

## Features

- 🛠️ **Automatic Error Handling**: Automatically detects and fixes common pCloud issues
- 🚀 **Easy Setup**: Simple menu-driven interface for all operations
- 🔄 **Comprehensive Status Checks**: Verifies all components and their status
- 🔒 **Security**: Proper SELinux context handling and permission management
- ⚡ **Systemd Integration**: Full systemd service management
- 🎨 **Visual Feedback**: Color-coded output with icons for better user experience
- 🔍 **Detailed Logging**: Comprehensive error reporting and status information
- 🛡️ **SELinux Support**: Full SELinux context management
- 🔄 **Auto-recovery**: Automatic attempt to fix detected issues

## Prerequisites

- Linux operating system
- pCloud AppImage downloaded and placed in `~/AppImages/`
- Root/sudo access
- Systemd (for service management)
- SELinux (if enabled on your system)
- Basic knowledge of Linux command line

## System Requirements

- Minimum 512MB RAM
- 100MB free disk space
- Linux kernel 3.10 or higher
- Systemd 230 or higher
- Bash 4.0 or higher

## Supported Distributions

- Fedora
- Ubuntu/Debian
- Arch Linux
- openSUSE
- CentOS/RHEL
- Other systemd-based distributions

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/pcloud-boot-fixer.git
cd pcloud-boot-fixer
```

2. Make the script executable:
```bash
chmod +x pcloud_boot_fixer.sh
```

3. (Optional) Create a symbolic link for system-wide access:
```bash
sudo ln -s "$(pwd)/pcloud_boot_fixer.sh" /usr/local/bin/pcloud-fixer
```

## Usage

Run the script with sudo privileges:
```bash
sudo ./pcloud_boot_fixer.sh
```

### Menu Options

1. **Create autostart entry**: Creates a desktop entry for pCloud in the autostart directory
2. **Create systemd service**: Sets up a systemd service for pCloud
3. **Fix SELinux context**: Fixes SELinux security contexts for pCloud files
4. **Check pCloud status**: Shows the current status of pCloud service and components
5. **Start pCloud**: Starts the pCloud service
6. **Stop pCloud**: Stops the pCloud service
7. **Restart pCloud**: Restarts the pCloud service
8. **Apply all fixes**: Runs all fixes in sequence
9. **Exit**: Exits the script

## Error Handling

The script includes automatic error handling for common issues:
- Permission problems
- SELinux context issues
- Service management errors
- File access problems
- AppImage execution issues
- Network connectivity problems
- Systemd service failures
- Desktop environment compatibility

When an error is detected, the script will:
1. Display the error with a clear message
2. Attempt to fix the issue automatically
3. Provide feedback on the fix attempt
4. Suggest manual intervention if automatic fix fails
5. Log the error for future reference

## Common Issues

### 1. Permission Denied
```bash
sudo chmod +x ~/AppImages/pcloud.AppImage
```

### 2. SELinux Context Issues
```bash
restorecon -Rv ~/.config/autostart/
```

### 3. Service Not Starting
```bash
systemctl daemon-reload
systemctl restart pcloud
```

### 4. AppImage Not Found
```bash
mkdir -p ~/AppImages
# Download pCloud AppImage to ~/AppImages/
```

## Troubleshooting

If you encounter issues:

1. **Check pCloud AppImage**:
   - Ensure the AppImage is in `~/AppImages/`
   - Verify it has execute permissions
   - Make sure it's the correct version for your system

2. **Check Systemd Status**:
   ```bash
   systemctl status pcloud
   ```

3. **Check SELinux Context**:
   ```bash
   ls -Z ~/.config/autostart/pcloud.desktop
   ls -Z ~/AppImages/pcloud.AppImage
   ```

4. **Check Logs**:
   ```bash
   journalctl -u pcloud
   ```

5. **Check Network**:
   ```bash
   ping www.pcloud.com
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Here's how:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Setup

1. Clone the repository
2. Make your changes
3. Test thoroughly
4. Submit your PR

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- pCloud for their cloud storage service
- The Linux community for systemd and SELinux
- All contributors to this project
- The open-source community for inspiration and tools

## Support

If you need help or have suggestions:
- Open an issue on GitHub
- Check the [pCloud documentation](https://www.pcloud.com/documentation.html)
- Visit the [pCloud support page](https://www.pcloud.com/support.html)
- Join our [Discord community](https://discord.gg/your-invite-link)

---

Made with ❤️ for the Linux community 