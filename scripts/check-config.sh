#!/bin/bash
# Warn when defconfig drops requested packages; require the main LuCI features.
set -Eeuo pipefail
requested="${1:?requested config is required}"
generated="${2:?generated config is required}"
test -f "$requested"
test -f "$generated"

while IFS= read -r option; do
    if ! grep -Fxq "$option" "$generated"; then
        echo "::warning::make defconfig 未保留 $option，请检查包名、依赖和目标平台。"
    fi
done < <(grep -E '^CONFIG_PACKAGE_[A-Za-z0-9_+-]+=y$' "$requested" | sort -u)

failed=0
for package in luci-theme-mmwx luci-app-openclash luci-app-netspeedtest luci-app-eqos; do
    option="CONFIG_PACKAGE_${package}=y"
    if grep -Fxq "$option" "$requested" && ! grep -Fxq "$option" "$generated"; then
        echo "::error::关键组件 $package 未进入最终配置，停止构建以避免发布缺失功能的固件。"
        failed=1
    fi
done
exit "$failed"
