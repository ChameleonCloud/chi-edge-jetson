#!/bin/sh

# print OS version for sanity checking
OS_VERSION=$(echo "$BALENA_HOST_OS_VERSION" | cut -d " " -f 2)
echo "OS Version is $OS_VERSION"

# change dir to custom module location
cd output

# loop over modules matching current device and os version
mod_dir="wireguard-linux-compat_${BALENA_DEVICE_TYPE}_${OS_VERSION}*"
for each in $mod_dir; do
	echo Loading module from "$each"
	insmod "$each/wireguard.ko" 2>/dev/null || true
done

# check that wireguard is loaded
lsmod | grep wireguard || (echo "Failed to load wireguard" && exit 1)

mod_dir="ipip_${BALENA_DEVICE_TYPE}_${OS_VERSION}*"
for each in $mod_dir; do
	echo Loading module from "$each"
	insmod "$each/tunnel4.ko" 2>/dev/null || true
	insmod "$each/ipip.ko" 2>/dev/null || true
done

# check that ipip is loaded
lsmod | grep ipip || (echo "Failed to load ipip" && exit 1)


# load modules needed for calico
modprobe udp_tunnel
modprobe ip6_udp_tunnel
modprobe ip_tunnel

exec "$@"
