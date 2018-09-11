# Based on https://blog.christophersmart.com/2016/10/27/building-and-booting-upstream-linux-and-u-boot-for-raspberry-pi-23-arm-boards/

# 1. Environment variables: 
    export CLFS_DIR=armv6_clfs
    export LFS=/mnt/$CLFS_DIR 
    export CORE_COUNT=$(nproc)
	export PATH=$PATH:$LFS/sources/u-boot
	export CLFS_TARGET="arm-szilv-linux-gnueabihf"
	export CROSS_COMPILE=${CLFS_TARGET}-
	export ARCH=arm


cd $LFS/sources

# 2. U-boot for raspberry pi zero w - make sure CROSS_COMPILE and other enviroment variables are set (test with echo $CROSS_COMPILE)
git clone --depth 1 -b v2016.09.01 git://git.denx.de/u-boot.git
cd u-boot
#defconfig for raspberry pi zero w, it can change for any other supported board (see in u-boot's config folder)
make rpi_0_w_defconfig
make -j$CORE_COUNT
# Now, copy the u-boot.bin file onto the SD card's /boot drirectory, and call it kernel.img (this is what the bootloader(first stage bootloader, bootcode.bin from Broadcom) looks for).
rsync u-boot.bin root@192.168.1.7:/run/media/szilveszter/BOOT/kernel.img


# 3. Proprietary bootloader files
# - you can also copy them from an existing raspbian sd card
git clone --depth 1 https://github.com/raspberrypi/firmware
rsync firmware/boot/{bootcode.bin,fixup.dat,start.elf} root@192.168.1.7:/run/media/szilveszter/BOOT/

# 4. test if the bootloader works - try to boot

# 5. compile linux
# download linux kernel, extract it and change the current directory to it
cd $LFS/sources
tar -xf linux-4.18.5.tar.xz
cd linux-4.18.5/

make bcm2835_defconfig
# inspect and edit .config file if it is neccessary
nano .config
make -j$CORE_COUNT zImage dtbs
rsync arch/arm/boot/zImage root@192.168.1.7:/run/media/szilveszter/BOOT/
rsync arch/arm/boot/dts/bcm2835-rpi-zero-w.dtb root@192.168.1.7:/run/media/szilveszter/BOOT/

# 6. Bootloader config
cat > boot.cmd << EOF
echo ***Szilveszter***
fatload mmc 0 ${kernel_addr_r} zImage
fatload mmc 0 ${fdt_addr_r} bcm2835-rpi-zero-w.dtb
setenv bootargs earlyprintk console=tty1 root=/dev/mmcblk0p2 rw rootwait panic=10
bootz ${kernel_addr_r} - ${fdt_addr_r}
EOF
./u-boot/tools/mkimage -C none -A arm -T script -d boot.cmd boot.scr

rsync boot.scr root@192.168.1.7:/run/media/szilveszter/BOOT/
rsync boot.cmd root@192.168.1.7:/run/media/szilveszter/BOOT/