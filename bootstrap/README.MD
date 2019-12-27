# Bootstrapping "mkhere" for "mkroot"

> *The "mkhere" tool is most useful with "mkroot", and it is even possible
> to bootstrap by constructing a "mkhere" in the form of a "mkroot" rootfs.*

Bootstrapping is pulling yourself out of the swamp with the straps of your
boots, like baron Von Munchaussen once claimed to have done.  Well, he
claimed more... we are actually doing it here.

You are now on a host OS, but you may desire another target system to use
for your rootfs.  That is no problem, as long as you can run CMake and bash
on your host OS.  The steps are:

 1. Install this "mkroot" tree on your host OS
 2. Select one or more bootstrap systems to serve as your build OS
 3. Into each build OS, bootstrapping installs "mkhere" and build OS packages
 4. Now you can build any target rootfs, referencing any "mkhere"

You can create as many independent build directories as you need, for
instance one for every build OS whose "mkhere" you intend to use.  You
setup the "mkhere", either bootstrapped or your own manual work, by
setting a symbolic link to the build OS's `/mkhere` directory.

In each of your build directories, you can now run `cmake <mkrootdir>`
and edit the settings as you like, and subsequently build the target rootfs
in the linked "mkhere" environment.  It's like one giant switchboard, really.

We provide bootstrapping directories for environments that can be setup
from CMake.  This involves:

  * Debian, along with Ubuntu, Kali and Tanglu
  * Raspbian, in support of the popular Raspberry Pi
  * Multiarch Debian for foreign architectures such as ARM
  * Windows, through wrappers around Wine and MSYS2

We are looking for other platforms that we might add too;

  * RedHat and SuSe
  * FreeBSD, OpenBSD, NetBSD
  * Mac OS X (or Darwin)
  * OpenWRT and variations

Note that not all platforms may be equally capable of running a rootfs in
the various modes of execution, but it is likely that they will all be
viable boot options for (real or emulated) hardware: PXE, CDROM/USB,
GRUB, LILO, RedBoot, U-Boot, CoreBoot, Windows Boot Loader, LOADLIN.

For use with the InternetWide Architecture, we generally want to produce
more limited formats, fit for running as a virtual machine.  This is
possible with the Open Container format, though KVM/Qemu is an option
for the aforementioned hardware-assuming formats.

