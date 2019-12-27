# Windows "mkhere" build environment.

> *This produces Windows binaries using the "mkhere" environment.*

Most of the "mkhere" environment is generic bash scripting, and
it runs in the buildroot OS.  This is often not Windows.  Only
the actual work horses, such as GCC, are run via a wrapper in a
Wine environment.

The software run for this environment is taken from MSYS2,
https://packages.msys2.org/repos
using a locally built pacman package manager.  When it is
setup properly, pacman can install into a directory that will
serve as the Windows rootdir.  Usually, the Windows rootdir
will be on a drive (courtesy of Henri Manson of Mansoft) that
matches the current root (usually setup with chroot).

This environment could even be used (as a second stage buildroot)
in this "mkroot" package!  You simply need to bootstrap it before
you can build Windows binaries.  Bootstrapping comes down to
producing any rootfs with "mkhere" a symbolic link to the Windows
buildroot's /mkhere directory.  You could also run things by hand,
for instance ${CMAKE_CURRENT_BINARY_DIR}/rootfs/mkhere/pacman.sh
can be run with the usual calls: depend, osdepend, have, build,
list, oslibs, cpio[gz][prefix], oslibcpio[gz][prefix] and so on!

