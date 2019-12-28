#!/bin/bash

#=================================================
# https://github.com/tete1030/openwrt-fastbuild-actions
# Description: FAST building OpenWrt with Github Actions and Docker!
# Lisence: MIT
# Author: Texot
#=================================================

set -eo pipefail

[ -e "${CONFIG_FILE}" ] && cp "${CONFIG_FILE}" openwrt/.config
sudo rm -rf openwrt/package/lean/luci-theme-argon
# cd openwrt
# mk openwrt
cd openwrt
rm -f ./.config*
touch ./.config
# 编译x64固件:
cat >> .config <<EOF
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_Generic=y
EOF
# 固件压缩:
# cat >> .config <<EOF
# CONFIG_TARGET_IMAGES_GZIP=y
# EOF
# 编译UEFI固件:
# cat >> .config <<EOF
# CONFIG_EFI_IMAGES=y
# EOF
# IPv6支持:
cat >> .config <<EOF
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_ipv6helper=y
EOF
# 多文件系统支持:
cat >> .config <<EOF
CONFIG_PACKAGE_kmod-fs-nfs=y
CONFIG_PACKAGE_kmod-fs-nfs-common=y
CONFIG_PACKAGE_kmod-fs-nfs-v3=y
CONFIG_PACKAGE_kmod-fs-nfs-v4=y
CONFIG_PACKAGE_kmod-fs-ntfs=y
CONFIG_PACKAGE_kmod-fs-squashfs=y
EOF
# USB3.0支持:
cat >> .config <<EOF
CONFIG_PACKAGE_kmod-usb-ohci=y
CONFIG_PACKAGE_kmod-usb-ohci-pci=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_kmod-usb2-pci=y
CONFIG_PACKAGE_kmod-usb3=y
EOF
# 常用LuCI插件选择:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-smartdns=y
CONFIG_PACKAGE_luci-app-adbyby-plus=y
CONFIG_PACKAGE_luci-app-aria2=y
# CONFIG_PACKAGE_luci-app-baidupcs-web=y
# CONFIG_PACKAGE_luci-app-docker=y
CONFIG_PACKAGE_luci-app-frpc=y
# CONFIG_PACKAGE_luci-app-kodexplorer=y
CONFIG_PACKAGE_luci-app-minidlna=y
# CONFIG_PACKAGE_luci-app-openvpn=y
# CONFIG_PACKAGE_luci-app-openvpn-server=y
# CONFIG_PACKAGE_luci-app-qbittorrent=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Kcptun=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Socks=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-v2ray-server=y
CONFIG_PACKAGE_luci-app-verysync=y
CONFIG_PACKAGE_luci-app-webadmin=y
CONFIG_PACKAGE_luci-app-wireguard=y
CONFIG_PACKAGE_luci-app-wrtbwmon=y
EOF
# Caiyy定制插件
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-statistics=y
CONFIG_PACKAGE_luci-app-vnstat=y
CONFIG_PACKAGE_luci-app-arpbind=y
# CONFIG_PACKAGE_luci-app-attendedsysupgrade=y
CONFIG_PACKAGE_luci-app-dnspod=y
CONFIG_PACKAGE_luci-app-nlbwmon=y
CONFIG_PACKAGE_luci-app-serverchan=y
CONFIG_PACKAGE_luci-app-adguardhome=y
EOF
# LuCI主题:
cat >> .config <<EOF
# CONFIG_PACKAGE_luci-theme-netgear=y
CONFIG_PACKAGE_luci-theme-argon=y
EOF
# 常用软件包:
cat >> .config <<EOF
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_nano=y
CONFIG_PACKAGE_screen=y
CONFIG_PACKAGE_tree=y
CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_wget=y
EOF
# 取消编译VMware镜像以及镜像填充 (不要删除被缩进的注释符号):
cat >> .config <<EOF
# CONFIG_TARGET_IMAGES_PAD is not set
# CONFIG_VMDK_IMAGES is not set
EOF
# 
# ========================固件定制部分结束========================
# 
sed -i 's/^[ \t]*//g' .config
make defconfig
(
    if [ "x${NONSTRICT_PATCH}" = "x1" ]; then
        set +eo pipefail
    fi

    find ../patches -type f -name '*.patch' -print0 | sort -z | xargs -t -0 -n 1 patch -p0 --forward -i
    # To set final status of the subprocess to 0, because outside the parentheses the '-eo pipefail' is still on
    true
)

make defconfig
make oldconfig
