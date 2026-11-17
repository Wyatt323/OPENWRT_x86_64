#!/bin/bash
# Build the x86 compiler and link a real program before compiling the kernel.
set -Eeuo pipefail
log_dir="${BUILD_LOG_DIR:-$PWD/build-logs}"
mkdir -p "$log_dir"
trap 'rm -f "$log_dir/toolchain-smoke"' EXIT

if ! make toolchain/install -j"$(nproc)" V=s 2>&1 | tee "$log_dir/toolchain.log"; then
    make toolchain/install -j2 V=s 2>&1 | tee -a "$log_dir/toolchain.log"
fi

compiler=
for candidate in staging_dir/toolchain-*/bin/x86_64-openwrt-linux-musl-gcc; do
    [ -x "$candidate" ] || continue
    compiler="$candidate"
    break
done
if [ -z "$compiler" ]; then
    echo '::error::交叉编译器未安装，停止构建。请检查 toolchain.log。'
    exit 1
fi

{
    "$compiler" --version | sed -n '1p'
    "$compiler" -dumpmachine
    printf 'int main(void) { return 0; }\n' | "$compiler" -x c - -o "$log_dir/toolchain-smoke"
    test -s "$log_dir/toolchain-smoke"
} 2>&1 | tee "$log_dir/toolchain-check.log"
echo '::notice::Cross toolchain compilation and program link verification passed.'
