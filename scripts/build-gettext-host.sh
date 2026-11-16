#!/bin/bash
# Compile the real host tools before spending time on the kernel and target packages.
set -Eeuo pipefail
log_dir="${BUILD_LOG_DIR:-$PWD/build-logs}"
mkdir -p "$log_dir"

collect_diagnostics() {
    local build file destination
    for build in build_dir/hostpkg/gettext-*; do
        [ -d "$build" ] || continue
        for file in config.log config.status libtextstyle/config.log \
                    libtextstyle/aclocal.m4 libtextstyle/lib/Makefile \
                    libtextstyle/lib/stddef.h libtextstyle/lib/stdlib.h; do
            [ -f "$build/$file" ] || continue
            destination="$log_dir/gettext-config/${build##*/}/$file"
            mkdir -p "$(dirname "$destination")"
            cp "$build/$file" "$destination"
        done
    done
}
trap collect_diagnostics EXIT

if ! make tools/install -j"$(nproc)" V=s 2>&1 | tee "$log_dir/tools.log"; then
    make tools/install -j2 V=s 2>&1 | tee -a "$log_dir/tools.log"
fi
make package/libs/gettext-full/host/compile -j2 V=s 2>&1 | tee "$log_dir/gettext-host.log"
test -x staging_dir/hostpkg/bin/msgfmt
staging_dir/hostpkg/bin/msgfmt --version | sed -n '1p'
echo '::notice::gettext host compilation and installed msgfmt verification passed.'
