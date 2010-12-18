#!/bin/sh
# compile_kern.sh version 12.1 (Fri Mar  7 18:39:15 CST 2008) pjv
#
# Rebuild a tree of directories containing a System.map, .config (renamed
# config), and kernel (zImage or bzImage).  The input is a tree of
# directories beneath the current one with names matching the wildcard *.?
# (in Slackware, these will typically be *.i for IDE kernels and *.s for
# IDE/SCSI kernels).  At the minimum, each directory must contain the file
# 'config', which is the .config to start with when building the kernel.

CWD=`pwd`
KERNEL=2.6.24.5
KERNELSRC=$CWD/../slackware/k/kernel-source-${KERNEL}-noarch-2.tgz
TMP=/tmp
OUTPUT=$TMP/output
JOBS=-j3

# Use the source from Slackware's K series.
if [ ! -d $TMP/linux-${KERNEL} ]; then
  ( cd $TMP
    rm -rf krntmp
    mkdir krntmp
    explodepkg $KERNELSRC
    sh install/doinst.sh
    mv usr/src/linux-${KERNEL} $TMP
    rm -rf krntmp
  )
fi
if [ ! -d $OUTPUT ]; then
  mkdir -p $OUTPUT
fi

for dir in *.? ; do
  if [ ! -r $dir/config ]; then
    continue
  fi
  if [ -r $OUTPUT/$dir/zImage \
       -o -r $OUTPUT/$dir/bzImage ]; then
    echo "kernel found in $OUTPUT/$dir... skipping."
  #  sleep 1
    continue
  fi
  echo
  echo "------------------------------------------"
  echo " BUILDING: $dir"
  echo "------------------------------------------"
  echo
  sleep 1
  cp $dir/config $TMP/linux-${KERNEL}/.config
  cd $TMP/linux-${KERNEL}
  make oldconfig ; make clean
  make $JOBS zImage
  if [ $? = 0 ]; then # good build
    echo
    echo "------------------------------------------"
    echo "Saving output in $OUTPUT/$dir"
    echo "------------------------------------------"
    echo
    mkdir -p $OUTPUT/$dir
    cp arch/i386/boot/zImage $OUTPUT/$dir
    cp System.map $OUTPUT/$dir
    cp .config $OUTPUT/$dir/config
    echo "Cleaning up..."
    make clean
  else
    # If building a zImage didn't fit, we'll try building a bzImage.
    make $JOBS bzImage
    if [ $? = 0 ]; then # good build
      echo
      echo "------------------------------------------"
      echo "Saving output in $OUTPUT/$dir"
      echo "------------------------------------------"
      echo
      mkdir -p $OUTPUT/$dir
      cp arch/i386/boot/bzImage $OUTPUT/$dir
      cp System.map $OUTPUT/$dir
      cp .config $OUTPUT/$dir/config
      echo "Cleaning up..."
      make clean
    fi
  fi
  cd $CWD
done
