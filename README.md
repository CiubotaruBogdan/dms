# Ubuntu Initializer

A shell script for configuring and optimizing Ubuntu systems, providing users with a simple command-line tool for system management.

## Features

- System updates and package installation
- Screen resolution configuration (especially useful for Hyper-V)
- Docker installation and setup
- System logs viewer
- Progress bars with color output
- Root privileges management

## Quick Start

Run the script with a single command:

```bash
curl -sSL https://ciubotarubogdan.work/ubuntu_initializer.sh | sudo bash
```

## Options

0. **View System Logs**: Display the last 50 system logs
1. **Update System**: Update and upgrade system packages
2. **Configure Screen Resolution**: Set custom screen resolution (especially for Hyper-V environments)
3. **Install Docker**: Complete Docker installation with all required components
4. **Exit (q)**: Exit the program

## Requirements

- Ubuntu Linux system
- Root privileges (sudo access)
- Internet connection for updates and installations
- curl (for downloading the script)

## Author

Created by Bogdan Ciubotaru

## Notes

- The script requires root privileges and will prompt for sudo password if not run with sudo
- For Hyper-V users, the resolution configuration will provide the necessary PowerShell command to set on the host machine
- All operations are logged to `/var/log/ubuntu_initializer.log`
