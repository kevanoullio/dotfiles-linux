# Arch Linux Install Guide

## Prior to Installing Arch Linux

1. **Download Arch Linux ISO**

    Download Arch Linux ISO file from https://archlinux.org/download/

2. **Write Ventoy to USB Drive**

    Write/install Ventoy to a USB drive using Ventoy guide: https://www.ventoy.net/en/doc_start.html

3. **Copy ISO To USB Drive**

    Copy the Arch Lonux ISO file to USB drive that has Ventoy installed

## Installing Arch Linux

1. **Boot Arch Linux via the ISO file**

2. **Connect to internet**

    If using WiFi, use `iwctl`

    While inside "iwctl":

        ```
        device list
        station <your_wifi_device> scan
        station <your_wifi_device> get-networks
        station <your_wifi_device> connect <your_wifi_name>
        exit
        ```

    Replace <your_wifi_device> with your wireless device name (e.g., wlan0) and <your_wifi_name> with your network SSID

    After connecting, verify with `ping archlinux.org`

    When running archinstall, for "Network configuration" choose "Copy ISO configuration"

3. **Install "archinstall"**

    `pacman -Sy archinstall`

4. **Run "archinstall"**

    `archinstall`

5. **Fix reflector if needed**

    Test the automatic mirrors selection, if it doesn't work then run the following command at root: `systemctl mask reflector.service`

    If it failed, don't worry and just skip the "Mirrors and repositories" section

6. **Finish setting up all the following:**
    - Locales
    - Disk configuration
    - Swap
    - Bootloader --> [preferably systemd-boot, less bloat than Grub]
    - Hostname
    - Authentication
        - Root password --> [can leave blank but need one sudo user]
        - set a User account
    - Profile --> [minimal]
    - Applications --> [can configure Bluetooth and audio]
    - Kernels --> [preferably LTS only]
    - Network configuration --> [choose "Copy ISO configuration"]
    - Timezone

7. **Select "Install"**

8. **Run any of the Arch setup scripts and/or other scripts to automate installing and configuring to the desired setup**
