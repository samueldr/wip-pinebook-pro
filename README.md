WIP stuff to get started on the pinebook pro.

## Using in your configuration

Clone this repository somwhere, and in your configuration.nix

```
{
  imports = [
    .../pinebook-pro/pinebook_pro.nix
  ];
}
```

That entry point will try to stay unopinionated, while maximizing the hardware
compatibility.


## Current state

*A whole lot of untested*.

You can look at the previous state to see that the basic stuff works. But I
find listing everything as working is hard.

What's untested and not working will be listed here at some point. Maybe.

### Known issues

#### `rockchipdrm` and `efifb`

This can be worked around by booting with the `efifb=off` kernel command-line.

This is already handled for you by this configuration. If using the generic
UEFI AArch64 iso, you will need to add the option yourself to the command-line
using GRUB.

#### *EFI* and poweroff

When booted using EFI, the system will not power off. It will stay seemingly
stuck with the LED and display turned off.

A [workaround exists](https://github.com/Tow-Boot/Tow-Boot/commit/818cae1b84a7702f2a509927f2819900c2881979#diff-20f50d9d8d5d6c059b87ad66fbc5df26d9fc46251763547ca9bdcc75564a4368),
and is built in recent Tow-Boot (make sure your release is 2021.10-004 or more recent).


## *Platform Firmware*

> **NOTE**: The previously available customized *U-Boot* from this repository
> are not available anymore.

### *Tow-Boot*

I highly suggest installing *Tow-Boot* to the SPI Flash.

 - https://github.com/Tow-Boot/Tow-Boot

Having the firmware installed to SPI makes the device act basically like a
normal computer. No need for weird incantations to setup the platform boot
firmware.

Alternatively, starting from the *Tow-Boot* disk image on eMMC is easier to
deal with and understand than having to deal with *U-Boot* manually.


### Mainline *U-Boot*

Mainline U-Boot has full support for graphics since 2021.04. The current
unstable relases of Nixpkgs are at 2021.04 at least.

```
 $ nix-build -A pkgs.ubootPinebookPro
```

Note that the default U-Boot build does not do anything with LED on startup.


## Keyboard firmware

> **WARNING**: Some hardware batches for the Pinebook Pro ship with the
> wrong chip for the keyboard controller. While it will work with the
> firmware it ships with, it *may brick* while flashing the updated
> firmware. [See this comment on the firmware repository](https://github.com/jackhumbert/pinebook-pro-keyboard-updater/issues/33#issuecomment-850889285).
>
> It is unclear how to identify said hardware from a running system.

To determine which keyboard controller you have, you will need to disassemble
the Pinebook Pro as per [the Pine64
wiki](https://wiki.pine64.org/wiki/Pinebook_Pro#Keyboard), and make sure that
the IC next to the U23 marking on the main board is an **SH68F83**.

```
 $ nix-build -A pkgs.pinebookpro-keyboard-updater
 $ sudo ./result/bin/updater step-1 <iso|ansi>
 $ sudo poweroff
 # ...
 $ sudo ./result/bin/updater step-2 <iso|ansi>
 $ sudo poweroff
 # ...
 $ sudo ./result/bin/updater flash-kb-revised <iso|ansi>
```

Note: poweroff must be used, reboot does not turn the hardware "off" enough.
