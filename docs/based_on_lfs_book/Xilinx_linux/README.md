
## Szilveszter's Xilinx-Digilent Zybo 7000 Board
# add this to one of dts files
&usb0 {
	dr_mode = "host";
	usb-phy = <&usb_phy0>;
};
/{
	usb_phy0: phy0 {
		compatible = "usb-nop-xceiv";
		#phy-cells = <0>;
		reset-gpios = <&gpio0 46 1>;
	};
};
### compile device tree
dtc -I dts -O dtb -o devicetree.dtb system-top.dts


## compile Xilinx's or Mainline linux kernel with Szilveszter's my own self built chaintool
### Dependencies
1. Cross compilation build tool

2. u-boot bootloader and tools

3. Environment variables: (some of them are not neccessary for the kernel compilation)
	export LFS=/mnt/lfs_test/
	export CLFS_TARGET=arm-szilv-linux-gnueabihf
	/bin/ln -svf /mnt/lfs_test/tools /tools
	export PATH=$PATH:/mnt/lfs_test/sources/dtc:/mnt/lfs_test/ctools/bin:/mnt/lfs_test/sources/uboot_digilen$
	export CLFS_TARGET="arm-szilv-linux-gnueabihf"
	export CROSS_COMPILE=${CLFS_TARGET}-
	export ARCH=arm

4. Compilation:
# clean git repository, git commit
	make mrproper
# in the case of a Xilinx FPGA SOC: make xilinx_zynq_defconfig
	make menuconfig (or copy in a preconfigured .config file)
# inspect and edit .config file
	make -j3 UIMAGE_LOADADDR=0x8000 uImage
	make INSTALL_MOD_PATH=xy modules
	make INSTALL_MOD_PATH=xy modules_install

# archive the build
	copy the .config and UImage to a backupfolder
	