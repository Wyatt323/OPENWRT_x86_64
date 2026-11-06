#!/bin/bash
# Run from the firmware source root. Bound both attempts and preserve diagnostics.
set -Eeuo pipefail

log_dir="${BUILD_LOG_DIR:-$PWD/build-logs}"
mkdir -p "$log_dir"

if timeout --signal=TERM --kill-after=30s 35m make download -j8 2>&1 | tee "$log_dir/download.log"; then
    exit 0
fi

echo '::warning::依赖下载失败或超过 35 分钟，降低并发并输出详细日志重试一次。'
if timeout --signal=TERM --kill-after=30s 25m make download -j4 V=s 2>&1 | tee -a "$log_dir/download.log"; then
    exit 0
fi

echo '::error::依赖下载仍未成功，请查看 build-logs 中的 download.log。'
exit 1
