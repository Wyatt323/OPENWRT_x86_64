#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

set -Eeuo pipefail
trap 'echo "::error file=diy-part1.sh,line=$LINENO::添加软件源失败"' ERR

# 2026-11-17 的 feeds 把网络菜单、PCI 数据库等包移到了 QWRT 核心。
# 当前 LEDE 核心不提供这些包，固定为移除前的兼容提交。
sed -i -E \
    -e 's@^src-git(-full)? packages .*@src-git packages https://github.com/coolsnowwolf/packages.git^bdb45ca0f4b1cb38605098021012967425dcf95d@' \
    -e 's@^src-git(-full)? luci .*@src-git luci https://github.com/coolsnowwolf/luci.git^e881fed794a36dd18f282a4e227b7a1ced5679e5@' \
    feeds.conf.default
grep -Fxq 'src-git packages https://github.com/coolsnowwolf/packages.git^bdb45ca0f4b1cb38605098021012967425dcf95d' feeds.conf.default
grep -Fxq 'src-git luci https://github.com/coolsnowwolf/luci.git^e881fed794a36dd18f282a4e227b7a1ced5679e5' feeds.conf.default

# Uncomment a feed source
sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default

#加入mcat主题
#echo 'src-git mcat https://github.com/Wyatt323/luci-theme-mcat' >>feeds.conf.default、

echo 'src-git mcat https://github.com/thinktip/luci-theme-neobird' >>feeds.conf.default


#加入kenzok8大佬的软件包
echo 'src-git kenzok8 https://github.com/kenzok8/openwrt-packages' >>feeds.conf.default
#echo 'src-git small https://github.com/kenzok8/small' >>feeds.conf.default

#加入MosDNS软件
echo 'src-git mosdns https://github.com/sbwml/luci-app-mosdns' >>feeds.conf.default

#加入 DDNSTO到feeds配置文件里
echo 'src-git nas https://github.com/linkease/nas-packages.git;master' >> feeds.conf.default
echo 'src-git nas_luci https://github.com/linkease/nas-packages-luci.git;main' >> feeds.conf.default
