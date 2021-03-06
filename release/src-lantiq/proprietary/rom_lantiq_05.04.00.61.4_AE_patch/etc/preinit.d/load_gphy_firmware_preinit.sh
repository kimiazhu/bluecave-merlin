#!/bin/sh


gphy_fw_load() {

	local img_hdr_size;

	[ -n "$CONFIG_UBOOT_CONFIG_LTQ_IMAGE_EXTRA_CHECKS" ] && img_hdr_size=216c || img_hdr_size=72c;

	if [ -f /proc/driver/ltq_gphy/phyfirmware ]; then
		file=/proc/driver/ltq_gphy/phyfirmware
	elif [ -f /proc/driver/ifx_gphy/phyfirmware ];then
		file=/proc/driver/ifx_gphy/phyfirmware
	fi
	if [ -n $file ]; then
		cd /tmp
		# For NOR, SPI and SLC NAND models partition name is "gphyfirmware"
		grep -qw "gphyfirmware" /proc/mtd && {
			local mtdb=`grep -w "gphyfirmware" /proc/mtd | cut -d: -f1`
			dd if=/dev/$mtdb bs=$img_hdr_size skip=1 | unlzma > /tmp/gphy_image 2>/dev/null
			[ $? -ne 0 ] && rm -f /tmp/gphy_image || true
		} || {
			# For MLC NAND models partition name is "uboot+gphyfw"
			grep -qw "uboot+gphyfw" /proc/mtd && {
				local mtdb=`grep -w "uboot+gphyfw" /proc/mtd | cut -d: -f1`
				dd if=/dev/$mtdb bs=1M skip=1 | dd bs=$img_hdr_size skip=1 | unlzma > /tmp/gphy_image 2>/dev/null
				[ $? -ne 0 ] && rm -f /tmp/gphy_image || true
			} || true
		}
		[ -f /tmp/gphy_image ] && {
			cat /tmp/gphy_image > $file
			rm -f gphy_image
		}
	fi

	if [ -r /etc/rc.d/config.sh ]; then
	  . /etc/rc.d/config.sh 2> /dev/null
	      plat_form=${CONFIG_BUILD_SUFFIX%%_*}
		      platform=`echo $plat_form |tr '[:lower:]' '[:upper:]'`
	fi
	if [ "$platform" = "GRX350" -o "$platform" = "GRX550" ]; then
		#LAN Switch Port 2 GPHY ( eth0_1 )
		switch_cli dev=0 GSW_MMD_DATA_WRITE nAddressDev=2 nAddressReg=0x1f01e2 nData=0x70
		switch_cli dev=0 GSW_MMD_DATA_WRITE nAddressDev=2 nAddressReg=0x1f01e3 nData=0x0B
		#LAN Switch Port 3 GPHY ( eth0_2 )
		switch_cli dev=0 GSW_MMD_DATA_WRITE nAddressDev=3 nAddressReg=0x1f01e2 nData=0x70
		switch_cli dev=0 GSW_MMD_DATA_WRITE nAddressDev=3 nAddressReg=0x1f01e3 nData=0x0B
		#LAN Switch Port 4 GPHY ( eth0_3 )
		switch_cli dev=0 GSW_MMD_DATA_WRITE nAddressDev=4 nAddressReg=0x1f01e2 nData=0x70
		switch_cli dev=0 GSW_MMD_DATA_WRITE nAddressDev=4 nAddressReg=0x1f01e3 nData=0x0B
		#LAN Switch Port 5 GPHY ( eeth0_4 )
		switch_cli dev=0 GSW_MMD_DATA_WRITE nAddressDev=5 nAddressReg=0x1f01e2 nData=0x70
		switch_cli dev=0 GSW_MMD_DATA_WRITE nAddressDev=5 nAddressReg=0x1f01e3 nData=0x0B
		#WAN PAE  Port 15 ( eth1 )
		switch_cli dev=1 GSW_MMD_DATA_WRITE nAddressDev=1 nAddressReg=0x1f01e2 nData=0x70
		switch_cli dev=1 GSW_MMD_DATA_WRITE nAddressDev=1 nAddressReg=0x1f01e3 nData=0x0B
		
		echo GPT > /sys/devices/16000000.ssx4/16d00000.sso/update_clock_source
		sleep 1
		echo 255 > /sys/class/leds/xrx500\:green\:1/brightness
	
		echo "Enabling GMII SSC ..."
		sleep 1
		mem -s 0x16200044 -w 0x001E -u > /dev/null;
		mem -s 0x16200048 -w 0x001E -u > /dev/null;
		mem -s 0x1620004c -w 0xFFE2 -u > /dev/null;
		mem -s 0x16200050 -w 0xFFE2 -u > /dev/null;
		mem -s 0x16200054 -w 0xFFE2 -u > /dev/null;
		mem -s 0x16200058 -w 0xFFE2 -u > /dev/null;
		mem -s 0x1620005C -w 0x001E -u > /dev/null;
		mem -s 0x16200060 -w 0x001E -u > /dev/null;
		mem -s 0x1620003C -w 0xFF1F -u > /dev/null;
		mem -s 0x1620003C -w 0xFF1C -u > /dev/null;
		mem -s 0x1620003C -w 0xFF1D -u > /dev/null;

		#echo "Enabling GPHY SSC and DDR SSC ..."
		#mem -s 0x1c00f8c4 -w 0x0000ffff -u > /dev/null;
		#mem -s 0x1c00f8e0 -w 0xff60ffff -u > /dev/null;
		#mem -s 0x1c00f8e4 -w 0xff60ffff -u > /dev/null;
		#mem -s 0x1c00f8e8 -w 0xff60ffff -u > /dev/null;
		#mem -s 0x1c00f8ec -w 0xff60ffff -u > /dev/null;
		#mem -s 0x1c00f8f0 -w 0x00a0ffff -u > /dev/null;
		#mem -s 0x1c00f8f4 -w 0x00a0ffff -u > /dev/null;
		#mem -s 0x1c00f8f4 -w 0x00a0ffff -u > /dev/null;
		#mem -s 0x1c00f8fc -w 0x00a0ffff -u > /dev/null;
		#mem -s 0x1c00f8c0 -w 0xfff3ffff -u > /dev/null;
		#mem -s 0x1c00f8c0 -w 0xfff0fff0 -u > /dev/null;
		#mem -s 0x1c00f8c0 -w 0xfff1fff0 -u > /dev/null;
fi
}

gphy_fw_load;

