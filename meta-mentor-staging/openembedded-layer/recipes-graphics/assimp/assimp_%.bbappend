DEPENDS += "zlib"

EXTRA_OECMAKE += "\
    '-DASSIMP_LIB_INSTALL_DIR=${libdir}' \
    '-DASSIMP_INCLUDE_INSTALL_DIR=${includedir}' \
    '-DASSIMP_BIN_INSTALL_DIR=${bindir}' \
"
