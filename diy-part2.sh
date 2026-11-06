#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# SPDX-License-Identifier: MIT
# Custom packages and defaults, run from the LEDE source root after installing feeds.

set -Eeuo pipefail
trap 'echo "::error file=diy-part2.sh,line=$LINENO::自定义配置失败，请检查上方日志"' ERR
export GIT_TERMINAL_PROMPT=0

test -f include/toplevel.mk
test -f feeds/luci/luci.mk

# LAN 地址和网关统一使用 files/etc/config/network 中的配置。
# 当前 LuCI 已使用 JS 状态页，无需修改旧 Lua 温度显示模板。
# 系统版本日期由 LEDE default-settings 自动生成。
sed -i 's/^IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=full-$(shell date +%Y%m%d)-$(VERSION_DIST_SANITIZED)/' include/image.mk

# 统一连接跟踪上限，避免两条互相冲突的旧设置。
mkdir -p files/etc/sysctl.d
printf '%s\n' 'net.netfilter.nf_conntrack_max=165535' > files/etc/sysctl.d/99-custom-conntrack.conf
if [ -f files/etc/shadow ]; then
    chmod 0600 files/etc/shadow
fi

# 使用独立的 Argon 源，先移除 feed 安装的同名包链接。
./scripts/feeds uninstall luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

# 本固件不使用 Open vSwitch；当前 feed 的同名 PROVIDES 会生成自依赖。
./scripts/feeds uninstall openvswitch

# dnsmasq 的 IPset 子选项依赖 dnsmasq-full，不能再反向成为包本身的条件。
# 本固件供 OpenClash 使用，始终提供 IPset 内核模块。
sed -i 's/+PACKAGE_dnsmasq_full_ipset:kmod-ipt-ipset/+kmod-ipt-ipset/g' package/network/services/dnsmasq/Makefile

# 添加 MMWX 主题，首次启动默认启用。
git clone https://github.com/Wyatt323/luci-theme-mmwx.git package/luci-theme-mmwx
mkdir -p files/etc/uci-defaults
cp package/luci-theme-mmwx/examples/99-mmwx-default files/etc/uci-defaults/
chmod 0755 files/etc/uci-defaults/99-mmwx-default

# 下载实际启用的额外插件。未启用的插件可从 feeds 中另行选择。
mkdir -p package/lean
# luci-proto-minieap 已由 LuCI feed 提供，不重复拉取旧版本。
git clone --depth=1 https://github.com/BoringCat/luci-app-mentohust package/lean/luci-app-mentohust

# OpenClash 仅使用 vernesong 官方源码。VSSR 已停用。
./scripts/feeds uninstall luci-app-openclash
git clone --depth=1 https://github.com/vernesong/OpenClash package/lean/OpenClash

git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/lean/luci-app-poweroff
# 原作者当前仓库同时提供测速界面、homebox 和 Ookla 依赖。
git clone --depth=1 https://github.com/sirpdboy/NetSpeedTest.git package/lean/NetSpeedTest
# 自带 speedtest 脚本不使用 pkg_resources；当前 Python feed 已移除此子包。
sed -i 's/ +python3-pkg-resources//g' package/lean/NetSpeedTest/luci-app-netspeedtest/Makefile
git clone --depth=1 https://github.com/nickilchen/luci-app-socat package/lean/luci-app-socat
