# Minicom Tool

> *This is a simple minicom environment with a textual user interface
> around it.  It serves as a demonstration of the "mkroot" environment,
> and should at some point run over a variety of boot options.*

This rootfs contains the following components:

  * [BusyBox](https://busybox.net) as an alternative shell environment;
    the shell scripts use the `ash` language, which is sufficiently
    different from everyday `sh` or `bash` scripts that they cause
    trouble when mixed.  BusyBox also cares for `init` functions and
    other basic functions.

  * [TWIN](https://github.com/cosmos72/twin) is a "graphical" user
    environment, but drawn on a text console.  It can run on the
    Linux console and Xterminals.  It is neat and small, and has to
    be built from source code by the "mkhere" package.

  * [Minicom](https://en.wikipedia.org/wiki/Minicom) is a widely used
    modem-control and text-interaction program.  It usually connects
    to a device such as a modem over a serial port, but it might also
    connect to another Minicom machine over a so-call null modem cable.

If you need to interact with hardware, this can be really useful.  And
the ability to boot in a variety of ways is helpful too.  But otherwise
it is just a small demo that you can boot in a variety of ways.  When
you see the interface pop up, you will have a somewhat graphical way
of learning that you brought up your boot option over yet another
boot mechanism.


## Building the Minicom Tool rootfs

You will need to override the default, which is not to build `contrib`
targets like the Minicom Tool.  Please use your favourite CMake cache
editor, or simply run the following sequence:

```
git clone https://github.com/arpa2/mkroot mkroot.git
cd mkroot.git
mkdir build
cd build
ln -s YOUR/FAVOURITE/BUILDROOT/mkhere .
cmake -DCONTRIB_MINICOM_TOOL=ON ..
make
```

There will be a lot of output, and it may pause for long periods.  Please
be patient; the long waits are there to verify that all libraries needed
are included alongside partial binary extractions from the build root.
The output of this process will be cached for each program (and requested
version) independently, so you will not have to suffer on every build.

*(Having called for your patience, it appears that we are doing the same
work many times over, and patches on that are quite welcome!)*

**TODO**


## Booting from GRUB

**TODO**


## Booting over PXE

**TODO**


## Booting from CDROM

**TODO**


## Booting from USB Disk

**TODO**


## Booting under RunC

**TODO**

