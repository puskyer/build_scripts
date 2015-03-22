#!/bin/bash

# from http://debblog.philkern.de/2012/10/how-to-maintain-openwrt-installation.html
# and http://wiki.openwrt.org/doc/howto/build
# If you want to update your image, just svn update (in the hope that the OpenWRT developers did not break anything in trunk),
# get the new defconfig, append your saved configuration delta (the file "my-own-config" above) to .config and run make oldconfig.
# This will keep track of feature changes in the default configuration (like shadow password support).
# Update 2013-03-18: To avoid problems with unclean trees you should call make distclean before running make defconfig again.
# Make sure you have the config diff ready, because cleaning the tree will drop the .config.

[ -d build ] && cd build/

# set an initial value for the flag
ARG_B=0
debug=""

# functions

do_distclean() {
	make distclean
	do_update
}

do_update() {
[ -d .git  ] && git pull
[ -d .svn  ] && svn up
./scripts/feeds update -a
./scripts/feeds install -a
# time save to minimise downloads during compile time.. distclean deletes all ./dl so rerun  both defclean and download.
make download
}


# read the options
TEMP=`getopt -o hDdfpuc:  -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -h)
          echo "-h Help        "
	  echo "-D debug       "
	  echo "-d defconfig   "
	  echo "-f distclean   "
          echo "-p dirclen     "
	  echo "-u update repos"
	  echo "-c copy config file - no parameter default or device name"
	  echo "  "
	  exit 0 ;;
        -D) debug="V=s" ; shift ;;
	-d)
# Run make menuconfig and select the target system type and the device profile.
	   make menuconfig
#make defconfig will now give you the default configuration for the selected profile. It is important to use this as the starting point.
# if you do not execute the make menuconfig the at least the following before doing make defconfig  "echo CONFIG_TARGET_ar71xx=y > .config"
	   make defconfig
# re link the ./dl folder so we do not need to download everthing again, just updates
	   ln -sf ../dl
# time save to minimise downloads during compile time.. distclean deletes all ./dl so rerun  both defclean and download.
           make download
	   shift ;;
#nukes everything you have compiled or configured and also deletes all downloaded feeds contents and package sources.
# CAUTION: In addition to all else, this will erase your build configuration (<buildroot_dir>/.config), your toolchain and all other sources.
        -f) do_distclean
            shift ;;
# deletes contents of the directories /bin and /build_dir and additionally /staging_dir and /toolchain (=the cross-compile tools) and /logs. 'Dirclean' is your basic "Full clean" operation.
        -p) make dirclean
	    shift ;;
#
        -u) do_update
            shift ;;
#
	-c)
	    case "$2" in
                "") cp ../config.ar71xx_generic .config ; shift 2 ;;
                *) cp ../$2.config .config ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

make package/symlinks
make prereq
# Again invoke menuconfig and select all the packages you need.
# You can get the current list of packages installed on your device with opkg list_installed.
# You can search in menuconfig as you would in a kernel build config screen. 
make menuconfig
# If you're happy with the configuration, save the difference to the default configuration to a file: scripts/diffconfig.sh > my-own-config
#time make -j6 $debug
#If you are building everything (not just packages enough to make a flashable image) and build stops on a package you don't care about 
# you can skip failed packages by using IGNORE_ERRORS=1
time ionice -c 3 nice -n 20 make -j 6 V=s CONFIG_DEBUG_SECTION_MISMATCH=y 2>&1 | tee build.log | egrep -i '(warn|error)'
