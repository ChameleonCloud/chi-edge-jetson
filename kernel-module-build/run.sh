#!/bin/bash

OS_VERSION=$(echo "$BALENA_HOST_OS_VERSION" | cut -d " " -f 2)
echo "OS Version is $OS_VERSION"

cd output
mod_dir="wireguard-linux-compat_${BALENA_DEVICE_TYPE}_${OS_VERSION}*"
for each in $mod_dir; do
	echo Loading module from "$each"
	insmod "$each/wireguard.ko"
	lsmod | grep wireguard
done


set -x
wg_up() {
  local iface="$1"
  local suffix="${iface##wg-}"
  local wg_conf=/etc/wireguard/"$iface".conf
  if [[ ! -f "$wg_conf" ]]; then
    abort "No wireguard configuration found."
  fi
  ip link del dev "$iface" 2>/dev/null || true
  ip link add dev "$iface" type wireguard

  read wg_ipv4 </etc/wireguard/"$iface".ipv4 || true
  wg syncconf "$iface" "$wg_conf"
  ip address add "$wg_ipv4" dev "$iface"
  ip link set up dev "$iface"
}

wg_up wg-calico

set +x

exec balena-idle
