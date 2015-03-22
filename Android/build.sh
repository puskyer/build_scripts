#!/bin/bash




if [ -d kernel/motorola/olympus ] ; then 
build=atrix
fi

if [ -d kernel/samsung/aries ] ; then 
build=stg7
fi

dobuildlog=/tmp/dobuild$build$device`date +%d%m%Y`.log

#
#  added ability to build for zaner or myself with atrix
#
#
#
#

echo "Start do repo sync & build $build $device  `date`" >>$dobuildlog

if [ "$1" == "R" ] ; then
.repo/repo/repo sync -j4  >>$dobuildlog 2>&1
fi

if [ "$build" == "atrix" ] ; then

device=olympus

#  for user in pusky zaner; do

#  boardolympuspanel=./kernel/motorola/olympus/arch/arm/mach-tegra/board-olympus-panel.c
#  boardolympuspanel_tmp=/tmp/board-olympus-panel.c
#  testfile=`grep "\.h_sync_width = 4" $boardolympuspanel | tr -s '\t' ' '`
#  testrespusky=" .h_sync_width = 4,"
#  testreszaner=" .h_sync_width = 16,"

 #  if [ "$user" = "zaner" ] ; then
 #     echo "doing Zaner's"
 #     if [ "$testrespusky" == "$testfile" ] ; then
 #        sed -e 's/\.h_sync_width = 4/\.h_sync_width = 16/'  -e 's/\.h_back_porch = 52/\.h_back_porch = 32/'  -e 's/\.h_front_porch = 52/\.h_front_porch = 32/' $boardolympuspanel  >$boardolympuspanel_tmp
 #        cp $boardolympuspanel_tmp  $boardolympuspanel
 #     fi
 #  else
 #     echo "doing Pusky's"
 #     if [ "$testreszaner" == "$testfile" -o "" ==  "$testfile" ] ; then
 #        sed -e 's/\.h_sync_width = 16/\.h_sync_width = 4/'  -e 's/\.h_back_porch = 32/\.h_back_porch = 52/'  -e 's/\.h_front_porch = 32/\.h_front_porch = 52/' $boardolympuspanel >$boardolympuspanel_tmp
 #        cp $boardolympuspanel_tmp  $boardolympuspanel
 #     fi
 #  fi

source build/envsetup.sh    >>$dobuildlog 2>&1
breakfast $device  >>$dobuildlog 2>&1     # for atrix
time make -j3 bacon   >>$dobuildlog 2>&1  # j3 is number of cores

#if grep -q "Package Complete:"  $dobuildlog ; then
#  if [ -e out/target/product/$device/cm-10.1-`date +%Y%m%d`-UNOFFICIAL-$device.zip ]; then 
#   mv out/target/product/$device/cm-10.1-`date +%Y%m%d`-UNOFFICIAL-$device.zip     out/target/product/$device/cm-10.1-`date +%Y%m%d`-UNOFFICIAL-$device-$user.zip
#  else
#   mv out/target/product/$device/cm-10.1-`date +%Y%m%d -d "+1 day"`-UNOFFICIAL-$device.zip     out/target/product/$device/cm-10.1-`date +%Y%m%d`-UNOFFICIAL-$device-$user.zip
#  fi
#fi
#  done

else

for device in p1 p1c; do

source build/envsetup.sh    >>$dobuildlog 2>&1
breakfast $device  >>$dobuildlog  2>&1    # for p1 & p1c
time make -j3 bacon   >>$dobuildlog 2>&1  # j3 is number of cores

done

fi

##. build/envsetup.sh && brunch model_name

echo "End do repo sync & build $build $device  `date`" >>$dobuildlog
