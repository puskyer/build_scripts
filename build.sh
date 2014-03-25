#!/bin/bash

build=atrix
device=olympus

dobuildlog=/tmp/dobuild$build$device`date +%d%m%Y`.log
boardolympuspanel=./kernel/motorola/olympus/arch/arm/mach-tegra/board-olympus-panel.c
boardolympuspanel_tmp=/tmp/board-olympus-panel.c

testfile=`grep "\.h_sync_width = 4" $boardolympuspanel | tr -s '\t' ' '`
testrespusky=" .h_sync_width = 4,"
testreszaner=" .h_sync_width = 16,"
#
#  added ability to build for zaner or myself
#
#
#
#

echo "Start do repo sync & build $build $device  `date`">>$dobuildlog
.repo/repo/repo sync -j2  >>$dobuildlog 2>&1

if [ "$build" == "atrix" ] ; then

   if [ "$1" = "zaner" ] ; then
      echo "doing Zaner's"
      if [ "$testrespusky" == "$testfile" ] ; then
         sed -e 's/\.h_sync_width = 4/\.h_sync_width = 16/'  -e 's/\.h_back_porch = 52/\.h_back_porch = 32/'  -e 's/\.h_front_porch = 52/\.h_front_porch = 32/' $boardolympuspanel  >$boardolympuspanel_tmp
         cp $boardolympuspanel_tmp  $boardolympuspanel
      fi
   else
      echo "doing Pusky's"
      if [ "$testreszaner" == "$testfile" -o "" ==  "$testfile" ] ; then
         sed -e 's/\.h_sync_width = 16/\.h_sync_width = 4/'  -e 's/\.h_back_porch = 32/\.h_back_porch = 52/'  -e 's/\.h_front_porch = 32/\.h_front_porch = 52/' $boardolympuspanel >$boardolympuspanel_tmp
         cp $boardolympuspanel_tmp  $boardolympuspanel
      fi
   fi
if

source build/envsetup.sh    >>$dobuildlog 2>&1
breakfast $device  >>$dobuildlog 2>&1     # for atrix
time make -j3 bacon   >>$dobuildlog 2>&1  # j3 is number of cores
##. build/envsetup.sh && brunch model_name

echo "End do repo sync & build $build $device  `date`">>$dobuildlog
