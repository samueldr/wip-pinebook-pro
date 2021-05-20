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

`CONFIG_FB_EFI` has been disabled in the customized kernel as `rockchipdrm`
will not render the VT if `efifb` is present.

Be careful if using the mainline kernel instead, as it will have
`CONFIG_FB_EFI` set to `y`.

#### *EFI* and poweroff

When booted using EFI, the system will not power off. It will stay seemingly
stuck with the LED and display turned off.

Power it off by holding the power button for a while (10-15 seconds).

Otherwise you might have a surprise and find the battery is flat!


## Image build

> **NOTE**: These images will be built without an *Initial Boot Firmware*.

### SD image

```
 $ nix-build -A sdImage
```

### ISO image

```
 $ nix-build -A isoImage
```

## Note about cross-compilation

This will automatically detect the need for cross-compiling or not.

When cross-compiled, all caveats apply. Here this mainly means that the kernel
will need to be re-compiled on the device on the first nixos-rebuild switch,
while most other packages can be fetched from the cache.

For cross-compilation, you might have to provide a path to a known-good Nixpkgs
checkout. *(Left as an exercis to the reader.)*

```
 $ NIX_PATH=nixpkgs=/path/to/known/working/cross-compilation-friendly/nixpkgs
```

## *Initial Boot Firmware*

> **NOTE**: The previously available customized *U-Boot* from this repository
> are not available anymore.

### *Tow-Boot*

I highly suggest installing *Tow-Boot* to the SPI Flash.

 - https://github.com/Tow-Boot/Tow-Boot

Having the firmware installed to SPI makes the device act basically like a
normal computer. No need for weird incantations to setup the initial boot
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
