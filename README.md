WIP stuff to get started on the pinebook pro.

## `u-boot`

Assuming `/dev/mmcblk0` is an SD card.

```
$ nix-build -A pkgs.u-boot-pinebookpro
$ lsblk /dev/mmcblk0 && sudo dd if=result/idbloader.img of=/dev/mmcblk0 bs=512 seek=64 oflag=direct,sync && sudo dd if=result/u-boot.itb of=/dev/mmcblk0 bs=512 seek=16384 oflag=direct,sync
```

The eMMC has to be zeroed (in the relevant sectors) or else the RK3399 will use
the eMMC as a boot device first.

Alternatively, this u-boot can be installed to the eMMC.

Installing to SPI has yet to be investigated.
