#!/bin/bash

set -ex

# Note: Workaround for "arm-xilinx-eabi-gcc: fatal error: -fuse-linker-plugin, but liblto_plugin.so not found" problem:
#  cd /opt/Xilinx/SDK/2014.3/gnu/arm/lin/libexec/gcc/arm-xilinx-eabi/4.8.3
#  ln -s liblto_plugin.so.0.0.0 liblto_plugin.so

. /opt/Xilinx/SDK/2014.3/settings64.sh
run_xsdk() { /opt/Xilinx/SDK/2014.3/bin/loader -exec ../../../eclipse/lnx64.o/eclipse -nosplash -data firmware.sdk -application "$@"; }

rm -rf firmware.sdk
run_xsdk org.eclipse.ant.core.antRunner -buildfile firmware_scr.xml

rm firmware.sdk/app/src/helloworld.c
cp firmware.c firmware.sdk/app/src/main.c

run_xsdk org.eclipse.cdt.managedbuilder.core.headlessbuild -build all
cp firmware.sdk/app/Release/app.elf firmware.elf
