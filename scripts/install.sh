#!/usr/bin/env bash

ARCH=$(uname -m)

if [[("${ARCH}" != "x86_64") && ("${ARCH}" != "amd64") && ("${ARCH}" != "aarch64") &&  ("${ARCH}" != "arm64") ]]; then
    echo " > Unsupported architecture: ${ARCH}"
    exit 1
fi

install_script_service() {
    echo "
    [Unit]
    Wants=network-online.target
    After=network-online.target
    Wants=docker.service
    After=docker.service
    
    StartLimitInterval=0

    [Service]
    Type=forking
    TimeoutStartSec=infinity
    TimeoutStopSec=16min
    ExecStart=${UMBREL_INSTALL_PATH}/scripts/start
    ExecStop=${UMBREL_INSTALL_PATH}/scripts/stop
    User=root
    Group=root
    StandardOutput=syslog
    StandardError=syslog
    SyslogIdentifier=crypto-startup
    RemainAfterExit=yes
    Restart=always
    RestartSec=10

    [Install]
    WantedBy=multi-user.target" | sudo tee "/etc/systemd/system/crypto-startup.service"
    sudo chmod 644 "/etc/systemd/system/crypto-startup.service"
    sudo systemctl enable "crypto-startup.service"
}

echo "   Welcome to the Bitcoin Node Stack installer"
echo "   -------------------------------------------"
echo

PS3=" > Choose an option using the list above: "
options=("Run complete install + wipe drive" "Check and install system updates" "Reboot" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Run complete install + wipe drive")
            echo " >> Checking for updates..."
            sudo apt update
            echo " >> Installing updates..."
            sudo apt upgrade --yes
            echo " >> Update check completed."
            echo " >> Installing docker..."
            sudo apt install git python3 docker docker-compose --yes
            echo " >> Setting docker permissions..."
            sudo usermod -aG docker $USER
            echo " >> Listing external storage devices..."
            sync
            (ls -d /sys/block/sd* 2>/dev/null || true) | sed 's!.*/!!'
            echo " >> Getting external storage device model..."
            device="${1}"
            vendor=$(cat "/sys/block/${device}/device/vendor")
            model=$(cat "/sys/block/${device}/device/model")
            echo "$(echo $vendor) $(echo $model)"
            echo " >> Checking external storage device partition type..."
            sync
            blkid -o value -s TYPE "${device}" | grep --quiet '^ext4$'
            echo " >> Formatting external storage device..."
            device_path="/dev/${device}"
            partition_path="${device_path}1"
            wipefs -a "${device_path}"
            parted --script "${device_path}" mklabel gpt
            parted --script "${device_path}" mkpart primary ext4 0% 100%
            sync
            mkfs.ext4 -F -L external-storage "${partition_path}"
            echo " >> Installing system service..."
            install_script_service
            # Make drive mountable ? on the service
            echo " >> Mount drive..."
            # Download clone of project to mounted drive with proper permissions
            echo " >> Cloning git repo..."
            echo " >> Task completed. Rebooting system. Please run script again if needed."
            sudo reboot
            ;;
        "Check and install system updates")
            echo " >> Checking for updates..."
            sudo apt update
            echo " >> Installing updates..."
            sudo apt upgrade --yes
            echo " >> Task completed."
            ;;
        "Reboot")
            echo " >> Rebooting system. Please run script again if needed."
            sudo reboot
            ;;
        "Quit")
            echo " >> Quitting option selection."
            break
            ;;
        *) echo " >> Option $REPLY is invalid. Please try again.";;
    esac
done