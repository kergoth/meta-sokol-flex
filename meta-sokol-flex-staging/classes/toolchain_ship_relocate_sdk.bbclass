# ---------------------------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: MIT
# ---------------------------------------------------------------------------------------------------------------------

RELOCATE_SDK_SH ?= "${@bb.utils.which(d.getVar('BBPATH'), 'scripts/relocate_sdk.sh')}"
RELOCATE_SDK_PY ?= "${@bb.utils.which(d.getVar('BBPATH'), 'scripts/relocate_sdk.py')}"

create_sdk_files:append () {
    install -m 0755 ${RELOCATE_SDK_SH} ${SDK_OUTPUT}/${SDKPATH}/relocate_sdk.sh
    install -m 0755 ${RELOCATE_SDK_PY} ${SDK_OUTPUT}/${SDKPATH}/relocate_sdk.py
    sed -i -e "s:@SDKPATH@:${SDKPATH}:g; s:##DEFAULT_INSTALL_DIR##:$escaped_sdkpath:" \
        ${SDK_OUTPUT}/${SDKPATH}/relocate_sdk.sh \
        ${SDK_OUTPUT}/${SDKPATH}/relocate_sdk.py
        
}

do_populate_sdk[file-checksums] += "${RELOCATE_SDK_SH}:True ${RELOCATE_SDK_PY}:True"
