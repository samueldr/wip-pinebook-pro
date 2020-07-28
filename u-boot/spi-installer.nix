{ pkgs
, e2fsprogs
, runCommandNoCC
, uboot
, utillinux
, ubootTools
}:

let
  board = "pinebook-pro-rk3399";

  flashscript = pkgs.writeText "${board}-flash.cmd" ''
    echo
    echo
    echo ${board} firmware installer
    echo
    echo

    if load ''${devtype} ''${devnum}:''${bootpart} ''${kernel_addr_r} ''${board_name}.spiflash.bin; then
      sf probe
      sf erase 0 +$filesize
      sf write $kernel_addr_r 0 $filesize
      echo "Flashing seems to have been successful! Resetting in 5 seconds"
      sleep 5
      reset
    fi

  '';

  bootcmd = pkgs.writeText "${board}-boot.cmd" ''
    setenv bootmenu_0 'Flash firmware to SPI=setenv script flash.scr; run boot_a_script'
    setenv bootmenu_1 'Completely erase SPI=sf probe; echo "Currently erasing..."; sf erase 0 +1000000; echo "Done!"; sleep 5; bootmenu -1'
    setenv bootmenu_2 'Reboot=reset'
    setenv bootmenu_3
    bootmenu -1
  '';

  mkScript = file: runCommandNoCC "${board}-boot.scr" {
    nativeBuildInputs = [
      ubootTools
    ];
  } ''
    mkimage -C none -A arm64 -T script -d ${file} $out
  '';

  rootfsImage = runCommandNoCC "u-boot-installer-fs.img" {
    inherit board;
    size = "8"; # in MiB
    nativeBuildInputs = [
      e2fsprogs.bin
    ];
    volumeLabel = "FIRMWARE_INSTALL";
    uuid = "666efd84-5c25-48ec-af06-e9dadbaa830f";
  } ''
    img="$out"
    (PS4=" $ "; set -x

    truncate -s "$size"M $img

    mkdir -p files
    (cd ./files
    cp -v ${mkScript bootcmd} ./boot.scr
    cp -v ${mkScript flashscript} ./flash.scr
    cp -v ${uboot}/u-boot.spiflash.bin ./"$board".spiflash.bin
    )

    mkfs.ext4 -L $volumeLabel -U $uuid -d ./files $img
    )
  '';
in

runCommandNoCC "u-boot-installer" {
  nativeBuildInputs = [
    utillinux
  ];
  # -r--r--r-- 1 root root 1012K Dec 31  1969 u-boot.itb
  # Flashed at exactly 8MiB in
  gapSize = "10"; # in MiB
} ''
(PS4=" $ "; set -x
mkdir -p $out

img=$out/firmware-installer-image.img

# Create the image file sized to fit the gap and /, plus slack.
rootSizeBlocks=$(du -B 512 --apparent-size ${rootfsImage} | awk '{ print $1 }')
gapSizeBlocks=$(($gapSize * 1024 * 1024 / 512))
imageSize=$((rootSizeBlocks * 512 + gapSizeBlocks * 512))
truncate -s $imageSize $img

# type=b is 'W95 FAT32', type=83 is 'Linux'.
# The "bootable" partition is where u-boot will look file for the bootloader
# information (dtbs, extlinux.conf file).
sfdisk $img <<EOF
    label: dos

    start=$((gapSize))M, type=83, bootable
EOF

eval $(partx $img -o START,SECTORS --nr 1 --pairs)
dd conv=notrunc if=${rootfsImage} of=$img seek=$START count=$SECTORS

dd if=${uboot}/idbloader.img of=$img bs=512 seek=64 conv=notrunc
dd if=${uboot}/u-boot.itb of=$img bs=512 seek=16384 conv=notrunc
)
''
