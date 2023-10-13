# ---------------------------------------------------------------------------------------------------------------------
# SPDX-License-Identifier: MIT
# ---------------------------------------------------------------------------------------------------------------------
#
# This works around a docker bug. When using containers, we don't want to have
# explicit expectations of the host running docker, so fix this for old docker
# versions.

FILESEXTRAPATHS:prepend := "${THISDIR}/glib-2.0:"
SRC_URI += "file://0001-fix-close_range-fails-unexpectedly-in-unprivileged-p.patch"
