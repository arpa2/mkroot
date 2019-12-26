# CMake Functions for mkroot

> *The mkroot package builds root file systems for
> use in Open Containers, as well as PXE (network)
> and ISO (CDROM/USB) boot environments.  Each of
> the targets can use a set of CMake functions.*

The general structure of the `mkroot` tree is into sections that deliver for a different purpose:

  * `internetwide` comprises of rootfs's for the [InternetWide Architecture](http://internetwide.org/tag/architecture.html).  Since they usually build on concrete ARPA2 work packages, their names often look like `arpa2dns` and so on.
  * `contrib` comprises of rootfs's that may be useful in addition to the `internetwide` core.  They are not included by default, but define an option for each.  This is usually the place where external additions would land.
  * `local` comprises of rootfs's that are locally useful, but not (yet) intended for sharing.  This is used to insert rootfs's for your own use.  When they evolve into something generally useful, they may be proposed as part of the `contrib` hierarchy.  The general repository has no rootfs in this directory.

Every build target has its own description in a file like `internetwide/arpa2dns/README.MD` that indicates its purpose and perhaps some build hints.

The default build target builds all `internetwide` and `local` rootfs's.  They may also be built independently.  For `make`, the incarnation would be like `make internetwide/arpa2dns` to retrieve a built file system in `internetwide/arpa2dns/rootfs/` and, next to it, optional extra facilities for use with Open Containers, PXE and so on.

The assumption below is that you have setup a `mkhere` link in your build directory, or that you pointed to one in the `BUILDROOT_MKHERE` cache variable.  This will serve as a source of information.

## Adding a Component

```
add_rootfs(arpa2dns)
```

This defines a rootfs of the given name, in this case `arpa2dns`.  This is usually the start of a rootfs's `CMakeLists.txt` file.  It is a good habit to use the directory name as the rootfs name.

The rootfs name is setup in a variable `CURRENT_ROOTFS`, referenced by most of the following calls.

## Setup for Runtime Environments

Runtime environments are the places where the root file system is run, usually under some description of what resources should be made available and how.  We briefly refer to those as a "runkind".  By default, the runkind is `none`, calling for no extra work.

You can create any runkind that you like, and configure it in a cache variable `${CURRENT_ROOTFS}_RUNKIND`.  Multiple runkinds can be defined.

```
rootfs_runkind(OCI_bundle
	config.json
)
```

This introduces files to be configured to a resource-descriptive file.  The first argument names the supported runkind, any further arguments list file names to add when configuring for that runkind.  The directory should have a template bearing that name plus a `.in` extension.  CMake variables surrounded with `@` symbols will be expanded from this template to form the targeted file.

## Adding Directories and Files

```
rootfs_directories(
	/etc
	/dev
	/bin /sbin /usr/bin /usr/sbin
	/lib /usr/lib
	/proc /sys
)
```

This creates the listed directories in the root file system.  Directories will be empty and owned by root.

```
rootfs_files(
	/etc/nsswitch.conf
	/etc/ld.so.conf
	/etc/ld.so.conf.d/*
	README.MD
)
```

This can retrieve files from a number of places.

  * When the file starts with a slash, it is retrieved from the `mkhere` environment, and passed into the root file system in the same location.
  * When the file has no inner slash, it is retrieved from CMake's source directory for the rootfs, and placed in the root directory.


## Downloading Files

```
rootfs_downloads(
	"http://internetwide.org/index.html"
	"http://internetwide.org/tag/identity.html"
)
```

Download files from a given URL, and install in the root directory of the root file system for later processing in fixup scripts or other functions that we may add to this list.  When a URL ends in a slash, no file name can be inferred.  Downloads are cached in a `FetchedFiles` subdirectory under CMake's binary directory for the rootfs.

## Adding OS Packages

```
rootfs_ospackages(
        bash
        python3.7-minimal
        libpython3.7-stdlib
        knot knot-dnsutils
)
```

Import packages from the `mkhere` environment.  These packages will be installed when needed.  In addition to the packages, any links and libraries from binary executables will be added to come to self-contained packages in spite of dependencies.

## Building Packages from Source

```
rootfs_packages(
        twin
	arpa2shell
)
```

Build the named `mkhere` packages from source, possibly after retrieving it first.  Extract the package, along with any libraries from the build environment that its executable binaries need.

It is possible to specify the modifiers `VERSION`, `VARIANT` and `FLAVOUR` as they are used by the `mkhere` package, by postfixing it to the package name, as in

```
rootfs_packages(
	twin       VERSION=6.6.6
	arpa2shell VERSION=12.13 VARIANT=zsh FLAVOUR=zesty
)
```

## Fixup Scripts

```
rootfs_fixups(
	testfix.sh
	otherfix.csh
)
```

This defines fixup scripts that are run to tweak the target file system as desired.  The scripts run chrooted, and any files referenced are therefore part of the target file system.  Some tweaks may become a standard facility, and are part of the `fixup` directory in the project root.  The extensions to the script names help to diversify them across script interpreters on the target system, but usually the hash-bang notation will take care of that.

## Terminal Information

You can add `terminfo(5)` database entries for your selection of terminals
with a simple command

```
rootfs_terminfo(
	ansi
	linux
	xterm*
	vt*
)
```

Note how glob-styled patterns are possible, such as `vt*` that will likely
select things like `vt52`, `vt100` and `vt220` and perhaps more along the
same lines.


## Kernels and Kernel Modules

This is *early and experimental support* for retrieving a kernel with
specified modules.

Most of this is generic functionality, as all boot loader start an image
(usually a kernel) and can supply additional information (usually a rootfs).
Also, the rootfs (that we already build here) can often hold some form of
modules that can plug into the kernel.  This can be specified with this
target:

```
rootfs_kernel(
	ftdi_sio
	loop
)
```

The mere call of this function implied that the kernel should be retrieved,
in a form fit for a boot loader.  It is possible that more than one kernel
is provided.

**TODO:** Currently we install kernels in the root file system, which 

If you want to limit the output to a specific kernel version, start with
`VERSION=1.2.3` or so.  If you want to limit the output to a specific
variant, usually denoted by words in the kernel's file name, then you can
specify this with something like `VARIANT=smp` or VARIANT="smp pae"` or
such.

Note that the underlying operating system may have no kernel, or it may
not have one matching the `VERSION` and `VARIANT` constraints.  If this
is the case, you shall not have the kernel installed.  **TODO:** Error!

The named modules will be retrieved from their position in the underlying
file system, and they will be installed in the same location in the target
rootfs.  It is possible to name no modules at all.  When multiple kernels
are installed, then all these kernels will independently receive these
kernel modules.  **TODO:** Error when not found!

**TODO:** Modules may have dependencies on other modules; these should be
automatically included.  This is not done yet.

*As you can see, there are many TODO for the `rootfs_kernel()` command.*

