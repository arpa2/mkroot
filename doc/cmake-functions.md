# CMake Functions for mkroot

> *The mkroot package builds root file systems for
> use in Open Containers, as well as PXE (network)
> and ISO (CDROM/USB) boot environments.  Each of
> the targets can use a set of CMake functions.*

The general structure of the `mkroot` tree is into sections that deliver for a different purpose:

  * `internetwide` comprises of components for the [InternetWide Architecture](http://internetwide.org/tag/architecture.html).  Since they usually build on concrete ARPA2 work packages, their names often look like `arpa2dns` and so on.
  * `contrib` comprises of components that may be useful in addition to the `internetwide` core.  They are not included by default, but define an option for each.  This is usually the place where external additions would land.
  * `local` comprises of components that are locally useful, but not (yet) intended for sharing.  This is used to insert components for your own use.  When they evolve into something generally useful, they may be proposed as part of the `contrib` hierarchy.  The general repository has no components in this directory.

Every build target has its own description in a file like `internetwide/arpa2dns/README.MD` that indicates its purpose and perhaps some build hints.

The default build target builds all `internetwide` and `local` components.  They may also be built independently.  For `make`, the incarnation would be like `make internetwide/arpa2dns` to retrieve a built file system in `internetwide/arpa2dns/rootfs/` and, next to it, optional extra facilities for use with Open Containers, PXE and so on.

The assumption below is that you have setup a `mkhere` link in your build directory, or that you pointed to one in the `BUILDROOT_MKHERE` cache variable.  This will serve as a source of information.

## Adding a Component

```
add_component(arpa2dns)
```

This defines a component of the given name, in this case `arpa2dns`.  This is usually the start of a component's `CMakeLists.txt` file.  It is a good habit to use the directory name as the component name.

The component name is setup in a variable `CURRENT_COMPONENT`, referenced by most of the following calls.

## Setup for Runtime Environments

Runtime environments are the places where the root file system is run, usually under some description of what resources should be made available and how.  We briefly refer to those as a "runkind".  By default, the runkind is `none`, calling for no extra work.

You can create any runkind that you like, and configure it in a cache variable `${CURRENT_COMPONENT}_RUNKIND`.  Multiple runkinds can be defined.

```
component_runkind(OCI_bundle
	config.json
)
```

This introduces files to be configured to a resource-descriptive file.  The first argument names the supported runkind, any further arguments list file names to add when configuring for that runkind.  The directory should have a template bearing that name plus a `.in` extension.  CMake variables surrounded with `@` symbols will be expanded from this template to form the targeted file.

## Adding Directories and Files

```
component_directories(
	/etc
	/dev
	/bin /sbin /usr/bin /usr/sbin
	/lib /usr/lib
	/proc /sys
)
```

This creates the listed directories in the component root file system.  Directories will be empty and owned by root.

```
component_files(
	/etc/nsswitch.conf
	/etc/ld.so.conf
	/etc/ld.so.conf.d/*
)
```

**TODO:** Might add a slash-less name for local files.

This retrieves files from the `mkhere` environment, and passes them into the component root file system in the same location.

## Downloading Files

```
component_downloads(
	"http://internetwide.org/index.html"
	"http://internetwide.org/tag/identity.html"
)
```

Download files from a given URL, and install in the root directory of the component's root file system for later processing in fixup scripts or other functions that we may add to this list.  When a URL ends in a slash, no file name can be inferred.  Downloads are cached in a `FetchedFiles` subdirectory under CMake's binary directory for the component.

## Adding OS Packages

```
component_ospackages(
        bash
        python3.7-minimal
        libpython3.7-stdlib
        knot knot-dnsutils
)
```

Import packages from the `mkhere` environment.  These packages will be installed when needed.  In addition to the packages, any links and libraries from binary executables will be added to come to self-contained packages in spite of dependencies.

## Building Packages from Source

```
component_packages(
        twin
)
```

**TODO:** Control over FLAVOUR and VARIANT is missing.

Build a `mkhere` package from source, possibly after retrieving it first.  Extract the package, along with any libraries from the build environment that its executable binaries need.

## Fixup Scripts

```
component_fixups(
	testfix
	otherfix
)
```

This defines fixup scripts that are run to tweak the target file system as desired.  Some tweaks may become a standard facility, but mostly the script names are expected to reference a shell executable with an added `.sh` extension in the component's source directory.
