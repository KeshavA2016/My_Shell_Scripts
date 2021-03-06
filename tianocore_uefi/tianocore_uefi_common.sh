#!/usr/bin/env bash

set -x -e

_SOURCE_CODES_DIR="${__SOURCE_CODES_PART__}/Source_Codes"

_WD="${_SOURCE_CODES_DIR}/Firmware/UEFI/TianoCore_Sourceforge"
_BACKUP_BUILDS_DIR="${_WD}/BACKUP_BUILDS"

_UDK_DIR="${_WD}/UDK_GIT"
_UDK_BUILD_TOOLS_DIR="${_WD}/buildtools-BaseTools_GIT"

export EDK_TOOLS_PATH="${_UDK_DIR}/BaseTools"

_UDK_C_SOURCE_DIR="${_UDK_BUILD_TOOLS_DIR}/Source/C"

[[ -z "${_MAIN_BRANCH}" ]] && _MAIN_BRANCH="master"

_TARGET="RELEASE"
_COMPILER="GCC48"

_UDK_TOOLS_PATH_CLEAN() {
	
	rm -rf "${EDK_TOOLS_PATH}" || true
	
}

_UDK_BUILD_CLEAN() {
	
	echo
	
	_UDK_TOOLS_PATH_CLEAN
	
	echo
	
	rm -rf "${_UDK_BUILD_OUTER_DIR}" || true
	rm -rf "${_UDK_DIR}/Build" || true
	rm -rf "${_UDK_DIR}/Conf" || true
	
	echo
	
	cd "${_UDK_DIR}/"
	git clean -x -d -f
	git reset --hard
	git checkout "${_MAIN_BRANCH}"
	
	echo
	
}

_COPY_BUILDTOOLS_BASETOOLS() {
	
	echo
	
	_UDK_TOOLS_PATH_CLEAN
	
	echo
	
	cd "${_UDK_BUILD_TOOLS_DIR}/"
	
	echo
	
	git reset --hard
	
	echo
	
	git checkout master
	
	echo
	
	git merge remotes/origin/master
	
	echo
	
	cd "${_UDK_DIR}/"
	
	echo
	
	cp -rf "${_UDK_BUILD_TOOLS_DIR}" "${EDK_TOOLS_PATH}"
	
	echo
	
}

_COMPILE_BASETOOLS_MANUAL() {
	
	echo
	
	cd "${_UDK_DIR}/"
	source "${_UDK_DIR}/edksetup.sh" BaseTools
	
	echo
	
	cd "${_UDK_DIR}/"
	make -C "${EDK_TOOLS_PATH}"
	
	echo
	
}

_SET_PYTHON2() {
	
	echo
	
	# _PYTHON_="$(which python)"
	# sudo rm -f "${_PYTHON_}"
	# sudo ln -s "$(which python2)" "${_PYTHON_}"
	# unset _PYTHON_
	
	# export PYTHON="python2"
	
	echo
	
	sed 's|python |python2 |g' -i "${EDK_TOOLS_PATH}/BinWrappers/PosixLike"/* || true
	
	# sed 's|python |python2 |g' -i "${EDK_TOOLS_PATH}/BinWrappers/PosixLike/RunToolFromSource"
	# sed 's|python |python2 |g' -i "${EDK_TOOLS_PATH}/BinWrappers/PosixLike/RunBinToolFromBuildDir"
	# sed 's|python |python2 |g' -i "${EDK_TOOLS_PATH}/BinWrappers/PosixLike/GenDepex"
	
	echo
	
	sed 's|python |python2 |g' -i "${EDK_TOOLS_PATH}/Tests/GNUmakefile"
	
	echo
	
}

_SET_PYTHON3() {
	
	echo
	
	_PYTHON_="$(which python)"
	sudo rm -f "${_PYTHON_}"
	sudo ln -s "$(which python3)" "${_PYTHON_}"
	unset _PYTHON_
	
	# export PYTHON="python3"
	
	echo
	
}

_APPLY_PATCHES() {
	
	echo
	
}

_APPLY_CHANGES() {
	
	echo
	
	sed 's|-Werror |-Wno-error -Wno-unused-but-set-variable |g' -i "${EDK_TOOLS_PATH}/Source/C/Makefiles/header.makefile" || true
	sed 's|-Werror |-Wno-error -Wno-unused-but-set-variable |g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || true
	
	echo
	
	## Fix GCC 4.7 error - gcc: error: unrecognized command line option ‘-melf_x86_64’ 
	## Fix from https://lists.gnu.org/archive/html/grub-devel/2012-03/msg00165.html
	# sed 's| -m elf_x86_64| -melf_x86_64|g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || true
	sed 's| -m64 --64 -melf_x86_64| -m64|g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || true
	sed 's|--64 | |g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || true
	sed 's| -m64 -melf_x86_64| -m64|g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || true
	# sed 's| -melf_x86_64| -Wl,-melf_x86_64|g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || true
	
	echo
	
	## Remove GCC -g debug option and add -0s -mabi=ms
	sed 's|DEFINE GCC_ALL_CC_FLAGS            = -g |DEFINE GCC_ALL_CC_FLAGS            = -Os -mabi=ms |g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || true
	sed 's|DEFINE GCC44_ALL_CC_FLAGS            = -g |DEFINE GCC44_ALL_CC_FLAGS            = -Os -mabi=ms |g' -i "${EDK_TOOLS_PATH}/Conf/tools_def.template" || true
	
	echo
	
	## DuetPkg
	# sed 's|#define EFI_PAGE_BASE_OFFSET_IN_LDR 0x70000|#define EFI_PAGE_BASE_OFFSET_IN_LDR 0x80000|g' -i "${EDK_TOOLS_PATH}/Source/C/GenPage/GenPage.c" || true
	
	## EmulatorPkg
	sed 's|export LIB_ARCH_SFX=64|export LIB_ARCH_SFX=""|g' -i "${_UDK_DIR}/EmulatorPkg/build.sh" || true
	sed 's|^UNIXPKG_TOOLS=|UNIXPKG_TOOLS=${_COMPILER}|g' -i "${_UDK_DIR}/EmulatorPkg/build.sh" || true
	
	echo
	
}
