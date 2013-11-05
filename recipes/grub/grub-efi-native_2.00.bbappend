FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"
SRC_URI += "\
    file://grub-centos5-drop-incompat-warnings.patch \
    file://fix-no-asynchronous-unwind-tables-test.patch \
"

EXTRA_OECONF += "--disable-werror"
