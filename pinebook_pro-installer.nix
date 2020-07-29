{ config, lib, pkgs, ... }:

# Things that are too opinionated for defaults.
{
  boot.kernelParams = [
    "cma=32M"

    "console=ttyS2,1500000n8"
    "earlycon=uart8250,mmio32,0xff1a0000" "earlyprintk"

    # The last console parameter will be where the boot process will print
    # its messages. Comment or move above ttyS2 for better serial debugging.
    "console=tty0"
  ];

  services.mingetty.serialSpeed = [ 1500000 115200 57600 38400 9600 ];

  boot.initrd.availableKernelModules = [
  ];

  boot.consoleLogLevel = lib.mkDefault 7;
}
