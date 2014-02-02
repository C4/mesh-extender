#!/bin/bash
# installer.sh - Serval Mesh Extender
# Author / Modified by: Carl Krauss
# servalproject.org
# Date 2/1/2014

set -e # abort script on any failures

function usage {
  echo ""
  echo "Usage: $0 OPTIONS"
  echo "Required Arguments:"
  echo "-d      - The device you would like to install the Serval Mesh Extender software on. (Options: wr703n, mr3020, mr3040)"
  echo ""
  echo "Optional Arguments:"
  echo "-t      - Choose which install type you would like. (Options: full, install-openwrt, updagrade-openwrt, install-sme) (Default: full)"
  echo "            - full : Assumes you have a factory default device and would like to install the Serval Mesh Extender software."
  echo "            - install-openwrt : Assumes you have a factory default device and would only like to install openwrt."
  echo "            - updagrade-openwrt : Assumes you have a device with openwrt already installed and would like to upgrade the version."
  echo "            - install-sme : Assumes you already have openwrt install on the device and would like to install the Serval Mesh Extender software."  
  echo ""
  exit 1
}

function install-openwrt {
    # Notes from openwrt.org:
    # The second curl call will time out, but it's expected. Once the
    # script exits you can unplug the ethernet cable and proceed to the
    # next router, but KEEP each router ON POWER until the new image is
    # fully written! When flashing is done the router automatically
    # reboots (as shown by all the leds flashing once).

    firmware=${FIRMWARE}
    ip=192.168.0.254 # This is a big assumption. This should be an optional arg.
    echo "Using firmware file \"$firmware\""

    curl \
      --user admin:admin \
      --user-agent 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0' \
      --referer 'http://${ip}/userRpm/SoftwareUpgradeRpm.htm' \
      --form "Filename=@$firmware" -F 'Upgrade=Upgrade' \
      http://${ip}/incoming/Firmware.htm >/dev/null

    sleep 1

    curl \
      --max-time 2 \
      --user admin:admin \
      --user-agent 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0' \
      --referer 'http://${ip}/incoming/Firmware.htm' \
      http://${ip}/userRpm/FirmwareUpdateTemp.htm >/dev/null

}

while getopts "d:t:" OPT
do
   case ${OPT} in
      d)
        DEVICE=${OPTARG} >&2
        ;;
      b)
        INSTALLTYPE=${OPTARG} >&2
        ;;
      \?)
        echo "Invalid option: -${OPTARG}" >&2
        usage
        ;;
    esac
done

if [ -z ${DEVICE} ]; then
   echo "Missing Required Arguments."
   usage
   exit 1
fi

# Adding additional device options.
FIRMWARE_DIR="firmware"
if [ "${DEVICE}" == "wr703n" ] || [ "${DEVICE}" == "mr3020" ] || [ "${DEVICE}" == "mr3040" ]; then
    if [ "${DEVICE}" == "wr703n" ];then
    echo "Starting the install process on the ${DEVICE}"
    FIRMWARE="${FIRMWARE_DIR}/openwrt-ar71xx-generic-tl-wr703n-v1-squashfs-factory.bin"
    fi
    if [ "${DEVICE}" == "mr3020" ];then
    echo "Starting the install process on the ${DEVICE}"
    FIRMWARE="${FIRMWARE_DIR}/openwrt-ar71xx-generic-tl-mr3020-v1-squashfs-factory.bin"
    fi
    if [ "${DEVICE}" == "mr3040" ];then
    echo "Starting the install process on the ${DEVICE}"
    FIRMWARE="${FIRMWARE_DIR}/openwrt-ar71xx-generic-tl-mr3040-v1-squashfs-factory.bin"
    fi
else
    echo "No device match was found. Please use a supported device."
    usage
    exit 1
fi

INSTALLTYPE=${INSTALLTYPE:-full}

if [ "${INSTALLTYPE}" == "full" ] || [ "${INSTALLTYPE}" == "install-openwrt" ];then
    install-openwrt
fi

