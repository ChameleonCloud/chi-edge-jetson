#!/bin/sh

modprobe udp_tunnel
modprobe ip6_udp_tunnel

OS_VERSION=$(echo "$BALENA_HOST_OS_VERSION" | cut -d " " -f 2)
echo "OS Version is $OS_VERSION"

cd output
mod_dir="wireguard-linux-compat_${BALENA_DEVICE_TYPE}_${OS_VERSION}*"
for each in $mod_dir; do
	echo Loading module from "$each"
	insmod "$each/wireguard.ko" || true
done

exec "$@"
