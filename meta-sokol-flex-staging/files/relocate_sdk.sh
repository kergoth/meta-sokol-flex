#!/bin/bash

relocate="${1:-1}"
default_sdk_dir="@SDKPATH@"
target_sdk_dir="$(cd "$(dirname "$0")" && pwd -P)"

if ! xargs --version > /dev/null 2>&1; then
	echo "xargs is required by the relocation script, please install it first. Abort!"
	exit 1
fi

# fix environment paths
real_env_setup_script=""
for env_setup_script in `ls $target_sdk_dir/environment-setup-*`; do
	if grep -q 'OECORE_NATIVE_SYSROOT=' $env_setup_script; then
		# Handle custom env setup scripts that are only named
		# environment-setup-* so that they have relocation
		# applied - what we want beyond here is the main one
		# rather than the one that simply sorts last
		real_env_setup_script="$env_setup_script"
	fi
	$SUDO_EXEC sed -e "s:$default_sdk_dir:$target_sdk_dir:g" -i $env_setup_script
done
if [ -n "$real_env_setup_script" ] ; then
	env_setup_script="$real_env_setup_script"
fi

# fix dynamic loader paths in all ELF SDK binaries
native_sysroot=$(cat $env_setup_script |grep 'OECORE_NATIVE_SYSROOT='|cut -d'=' -f2|tr -d '"')
dl_path=$(find $native_sysroot/lib -maxdepth 1 -name "ld-linux*")
if [ "$dl_path" = "" ] ; then
	echo "SDK could not be set up. Relocate script unable to find ld-linux.so. Abort!"
	exit 1
fi
executable_files=$(find $native_sysroot -type f \
	\( -perm -0100 -o -perm -0010 -o -perm -0001 \) -printf "'%h/%f' ")
if [ "x$executable_files" = "x" ]; then
   echo "SDK relocate failed, could not get executalbe files"
   exit 1
fi

if [ $relocate = 1 ] ; then
    for py in python python2 python3
    do
        PYTHON=`which ${py} 2>/dev/null`
        if [ $? -eq 0 ]; then
            break;
        fi
    done

    if [ x${PYTHON} = "x"  ]; then
        echo "SDK could not be relocated.  No python found."
        exit 1
    fi
    ${PYTHON} $target_sdk_dir/relocate_sdk.py $target_sdk_dir $dl_path $executable_files
	if [ $? -ne 0 ]; then
		echo "SDK could not be set up. Relocate script failed. Abort!"
		exit 1
	fi
fi

# replace @SDKPATH@ with the new prefix in all text files: configs/scripts/etc.
# replace the host perl with SDK perl.
for replace in "$target_sdk_dir -maxdepth 1" "$native_sysroot"; do
	find $replace -type f
done | xargs -n100 file | grep ":.*\(ASCII\|script\|source\).*text" | \
    awk -F': ' '{printf "\"%s\"\n", $1}' | \
    grep -Fv -e "$target_sdk_dir/environment-setup-" \
             -e "$target_sdk_dir/relocate_sdk" \
             -e "$target_sdk_dir/post-relocate-setup" \
             -e "$target_sdk_dir/${0##*/}" | \
    xargs -n100 sed -i \
        -e "s:$SDK_BUILD_PATH:$target_sdk_dir:g" \
        -e "s:^#! */usr/bin/perl.*:#! /usr/bin/env perl:g" \
        -e "s: /usr/bin/perl: /usr/bin/env perl:g"

if [ $? -ne 0 ]; then
	echo "Failed to replace perl. Relocate script failed. Abort!"
	exit 1
fi

# change all symlinks pointing to @SDKPATH@
for l in $(find $native_sysroot -type l); do
	ln -sfn $(readlink $l|sed -e "s:$SDK_BUILD_PATH:$target_sdk_dir:") $l
	if [ $? -ne 0 ]; then
		echo "Failed to setup symlinks. Relocate script failed. Abort!"
		exit 1
    fi
done

echo done
