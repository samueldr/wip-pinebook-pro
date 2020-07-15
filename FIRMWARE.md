# Firmware notes

## Early July update

Starting early July 2020, this project provides a **beta** quality
graphics-and-USB enabled U-Boot for the Pinebook Pro. This is made possible by
using a preview of upcoming patches to U-Boot. See the *Acknowledgements*
section of this document.

This will be called the **opinionated firmware**. It deviates from some U-Boot
defaults, while keeping in the spirit of the original defaults.

> **TIP**: Look at the *Known issues* section to know about the known issues!

This U-Boot build should be usable by users from other distributions, though
has been customized a bit visually for NixOS users.

The boot order is, with the default build, the upstream boot order from U-Boot.
Which means that it will first try to boot from eMMC, then from SD, then from
USB.

Our opinionated changes, though, make it trivial to select an alternative boot
option for one boot. You can cancel the default boot by mashing CTRL+C when
prompted (and a bit later too).

Once canceled, you will be presented with a menu depicting the boot options
that are normally tried in order.

```

  *** U-Boot Boot Menu ***

     Default U-Boot boot
     Boot from eMMC
  => [Boot from SD]
     Boot from USB
     Boot PXE
     Boot DHCP
     Reboot
     U-Boot console


  Press UP/DOWN to move, ENTER to select

```

By selecting another option, the firmware will try to boot once from the given
storage using the default *U-Boot distro commands*.

At the time of writing, the default boot sources on a device are:

 * Bootable partition with an extlinux.conf compatible boot under `/` or `/boot` (`scan_dev_for_extlinux`)
 * Bootable partition with boot scripts `boot.scr.uimg` or `boot.scr` under `/` or `/boot` (`scan_dev_for_scripts`)
 * UEFI program `efi/boot/bootaa64.efi` (`scan_dev_for_efi`)

### Building

If you're building on x86_64, it will automatically use cross-compilation. In
that case the build should work assuming cross-compilation is working fine on
current unstable.

Otherwise, on-device or on any other AArch64 system, the build should be
trivial.

```
 $ nix-build -I nixpkgs=channel:nixos-unstable -A pkgs.pinebookpro-firmware-installer
```

### Installing to SPI flash

This is not mandatory. The opinionated firmware still works just as well
installed to SD or to eMMC.

These instructions assume the use of the opinionated U-Boot we are providing.
You can also install to SPI using any other documented method.

Before starting, you will need an SD card on which you can write the Firmware
installer image. This will overwrite the contents of that SD card.

```
 # Replace sdX with the correct block device for your SD card.
 # /dev/disk/by-path/platform-fe320000.dwmmc is the SD card on the Pinebook Pro
 $ sudo dd if=firmware-installer-image.img of=/dev/sdX bs=512 oflag=direct,sync
```

With your SD card ready, you will need to boot our U-Boot build. My
recommendation is to either install the updated U-Boot to your eMMC, or
render your eMMC unbootable and boot from the firmware installer SD image.

To render the eMMC unbootable, from a booted system:

```
 # This will prevent the U-Boot installed to eMMC from running.
 $ sudo dd if=/dev/zero of=/dev/disk/by-path/platform-fe330000.sdhci bs=512 count=1 seek=64 oflag=direct,sync
 $ sudo dd if=/dev/zero of=/dev/disk/by-path/platform-fe330000.sdhci bs=512 count=1 seek=16384 oflag=direct,sync
```

Once booted in our opinionated U-Boot build, you will need to *then* boot the
SD image's installer scripts. From this U-Boot, you can cancel the boot process
by mashing CTRL+C. Once canceled, select **Boot from SD**.

```

  *** U-Boot Boot Menu ***

     Default U-Boot boot
     Boot from eMMC
  => [Boot from SD]
     Boot from USB
     Boot PXE
     Boot DHCP
     Reboot
     U-Boot console


  Press UP/DOWN to move, ENTER to select

```

This will present you with another menu.

```

  *** U-Boot Boot Menu ***

  => [Flash firmware to SPI]
     Completely erase SPI
     Reboot
     U-Boot console


  Press UP/DOWN to move, ENTER to select

```

The options are self-explanatory. You shouldn't need to erase the SPI, unless
you want to completely remove any traces of an installation.

Note that there are no further confirmation prompts. Selecting the **Flash
firmware to SPI** option will install to the SPI flash.

```
395 bytes read in 4 ms (95.7 KiB/s)
## Executing script at 00500000


pinebook-pro-rk3399 firmware installer


1560028 bytes read in 188 ms (7.9 MiB/s)
SF: Detected gd25q128 with page size 256 Bytes, erase size 4 KiB, total 16 MiB
SF: 1560576 bytes @ 0x0 Erased: OK
device 0 offset 0x0, size 0x17cddc
SF: 1560028 bytes @ 0x0 Written: OK
Flashing seems to have been successful! Resetting in 5 seconds
```

Once this is done, the Pinebook Pro will reboot automatically. From this point
on you do not need U-Boot to be installed to the eMMC or to an SD card.

#### From other U-Boot builds

For non-opinionated U-Boot, you can run the command `run bootcmd_mmc1` from
its CLI. Note that the U-Boot build will need to support boot menus, which is
not a default option, in addition to be configured with the ability to write to
the SPI flash. This will start the menu-based install.

You can also use the `sf` command to install it manually. Explaining this is
out of scope of this document.

* * *

## Known issues

These are the current issues that makes this a **beta** release.

As far as the testing done goes, they do not cause any harm to the normal
operation of the booted system, while being a net upgrade over the previous
firmware which had no way for the user to select boot options via the device.

### Keyboard input is *wonky*

I do not know how to better describe it. Sometimes the input is immediate,
sometimes it will take a hot second before it happens. I recommend pressing
an arrow key once and waiting up to 5 seconds (usually 2) when navigating the
menu. Otherwise you may overshoot if you are impatient.

It may also be worsened by mixing serial input and keyboard input, but has not
been conclusively validated.

### Saving settings to SPI

While there is a patch upstream to do so, it seems to cause issues with USB
input. This is to be investigated.

### Hangs with kernel 5.6+

Using the patchset from tsys, which I believe is the gold standard, the
graphics-enabled U-Boot will not boot kernels 5.6, 5.7 and the wip 5.8.

 - https://gitlab.manjaro.org/tsys/linux-pinebook-pro

For the three kernel versions, the boot hangs at the what seems to be the same
location.

For the time being, use the 5.4 LTS (or 5.5 if you don't mind an unmaintained
kernel.)

* * *

## FAQ

### Why install to SPI flash?

This makes the Pinebook Pro act just like any other laptop. You can erase all
the storage devices (SPI is not a storage device exactly) and still get a
useful, albeit limited boot.

This also means that *the user is fully in control of the storage*. There is no
special offset where they are required to install a program for the computer to
boot successfully.

Finally, with the minimal UEFI support of the Pinebook Pro, and USB support, it
is possible to boot a generic UEFI iso installer, just like you would on any
other normal and sensible laptop. Once the upstream Linux kernel fully supports
the Pinebook Pro, **there will be no need for device-specific image or
installation instructions**. You will be able to install just like you would
any other dumb laptop.

### My machine does not boot after rendering the eMMC U-Boot unbootable

If you accidentally boot your machine without a firmware installed,
your Pinebook Pro may look like it doesn't want to boot anymore. In fact it is
likely booted into maskrom mode. Hold power for 15 *real* seconds, then try
powering on with a known good SD card.

### My machine does not boot after installing to SPI and is not in maskrom mode

Oof, first of all, sorry. In testing I have never had a flashing render my
device unbootable.

Rescuing your device is not specific to this project. You can follow [the
instructions from the Pine64 forums](https://forum.pine64.org/showthread.php?tid=9059)
to recover from a broken SPI flash.

* * *

## Acknowledgements

Without access to a nearly final revision of the Graphics fixes for the
Pinebook Pro, this wouldn't have been possible. Thank you Arnaud Patard from
Hupstream for allowing me to release the preview build to the benefit of Pine
users all around the world.
