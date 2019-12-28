# InternetWide Architecture Component Builders

*Or, if you like, ARPA2 Root File System Makers.*

> *This is a set of scripts that we propose to build root file systems
> for ARPA2 components.  They should be seen as guidance towards a
> personalised hosting environment, rather than as complete solutions.*

The directories in this project each represent a component as we
envision it in the
[InternetWide Architecture](http://internetwide.org/tag/architecture.html)
which allows maximum control of
[online identity](http://internetwide.org/tag/identity.html)
and use of it throughout the Internet through
[realm crossover](http://internetwide.org/blog/2015/04/22/id-2-byoid.html)
techniques.


## Subsystems for Hosting Providers

The various ARPA2 subsystems are designed to integrate into an
implementation of the InternetWide Architecture, without
blocking alternative implementations.
It's all about protocols, not software.
We do suggest a
[split of hosting providers](http://internetwide.org/blog/2014/11/19/back-to-hosting.html)
into domain identity providers and plugin service providers, and
allow each to customise and specialise on a market segment.
There is nothing stopping hosting providers from taking on
both roles, but we always advise customers to insist on an open
exchange between any identity provider and any hosting
provider, for maximum flexibility.

Aside from hosting providers, customers may want to host their
own components for some or all parts of a hosting role.  This
is possible thanks to the
[dynamic backbone](http://www.internetwide.org/blog/2018/11/22/backbone-innovations.html)
built on authenticated AMQP.
Again, we advise customers to choose only hosting providers
who open up their backend for such individual overrides.


## Components are Root File Systems

This project builds standalone components that were identified
in the InternetWide Architecture as tactical components to have,
and which should interconnect to form the whole.  Each component
might run on bare metal, as an open container instance, in a BSD jail,
on your Raspberry Pi at home, from a CDROM or PXE network boot
and so on.  In short, it needs to build as flexibly as possible.

All these technologies seem to converge on the same thing, namely the
use of a root file system and some added information on what resources
may peek through its perimeter.  This general form is supported in this
project through subdirectories that each build a component as a
standalone root file system.

The individual components welcome additional contributions of configuration
files and so on that make them work on one of the many possible runtime
environments.  Please consider every such extension as a guiding example,
rather than a ready-made script.  We aim for a good level of documentation
in each such script, to guide you through the process of running it in your
personalised setup.


## Quickstart on Linux

**Simplest start:**
You can have a "mkhere" setup bootstrapped by the "mkroot" system:

```
git clone https://github.com/arpa2/mkroot
mkdir build4debian
cd build4debian
cmake -D BOOTSTRAP_DEBIAN_MKHERE=ON \
      -D BUILDROOT_MKHERE="$(pwd)/bootstrap/debian/stable/rootfs/mkhere" \
      ../mkroot
make
ls -d */*/rootfs
```

**Bring your own:**
If you already have a build OS with `/mkhere` installed in its root dir
`$BUILDROOT`, you might use

```
git clone https://github.com/arpa2/mkroot
mkdir build4linux
cd build4linux
ln -s "$BUILDROOT/mkhere" mkhere
cmake ../mkroot
make
ls -d */*/rootfs
```

## General Usage

When not specified otherwise in the individual component directories,
the following build mechanism is assumed.

 1. There is a need for a build root file system.  This can be a
    simple directory into which an operating system is installed,
    like with `debootstrap`, it may be a local or NFS mount from
    a target environment.  It may be using a target operating
    system for the system that will run the components to be built
    with it.  Below, we refer to this directory as buildroot.

 2. A checkout or clone of the `mkhere` project
    [arpa2/mkhere](https://github.com/arpa2/mkhere)
    must be stored in a directory by the name `mkhere` under the
    buildroot.  This directory will be accessed by component
    build scripts, and after a `chroot` to the buildroot the
    various bits of software can be built in that file system.
    In certain special environments, we may rely on `qemu` or
    `wine` or similar for running the build.

 3. Create a build target directory, anywhere you like.
    You should not do this anywhere in your `mkhere` project
    and not in any of the source directories of the
    `mkroot` project, but you might create a subdirectory under
    the `mkroot` project if you like.  This directory will
    contain any derived works, so we retain a pristine `mkroot`
    source tree.  This implies that you might repeat this step
    for different types of build.

 4. Make a symbolic link from the `mkhere` subdirectory of the
    buildroot to your build target directory of this `mkroot` project
    directory.  The individual build scripts for components will
    reference that directory.

 5. Now setup the build target with `cmake "$BUILDDIR"` where you
    replace `$BUILDDIR` with the build directory.  If instead you
    would like to configure special options first, you may instead
    run `ccmake "$BUILDDIR"` first.  If you do not make such a choice,
    you are building open container bundles.

 6. You should now have a build system suited for your local setup.
    The `cmake` system used a generator to produce build code that
    is normal to you; on POSIX systems, you would expect to have a
    `Makefile` so you can use `make` to build components by name.

 7. Use the build system to create the components you like.  The
    components bear the names of the subdirectories from this
    project.  After running your local component build command
    (for instance `make arpa2dns` for the `arpa2dns` component if
    `cmake` generated for the `make` system)
    you should find the result in a subdirectory `rootfs` under
    the component's target build subdirectory
    (in the given example, `arpa2dns/rootfs`).

 8. For deployment, you may find initial contributed files for some
    components and for some runtimes in the component-named
    subdirectories under `contrib`, named by the contributing
    element and a possible variant (like `arpa2dns/config.json` for
    an `arpa2dns` component for the `OCI_bundle` runtime kind).


## Flavouring what you Cook

There are several places where you can override defaults and put in
your own ideas.  Surprises may be lurking anywhere, but we welcome
your pull requests to immortalise and share your clever solutions.

  * You can setup your favourite build root, using your favourite
    operating system and version.  There are basic requirements
    that you must meet, as documented in the `mkhere` project,
    but you can easily write your own wrapper scripts for `gcc`
    and such tools.  We do this too when we want to build for
    Windows and need `wine` to wrap `gcc` and other commands.

  * Instead of our `mkhere` repository, you might have your own
    variations, and/or you might edit or patch what we supply.
    As long as you setup the `mkhere` link in the build target
    directory to point to your version, the `mkroot` scripts
    will follow your wishes.

  * Packages built using `mkhere` can have variants and flavours,
    where variants influence package configuration and variants
    influence what from a package is used.  You can set these
    with `ccmake` before `cmake` is run, as described above;
    look for `component_VARIANT` and `component_FLAVOUR`
    variables.

  * Components can be targeted at a diversity of runtime kinds,
    the current default being `none` for nothing to be added,
    but contributions for others such as `OCI_bundle`
    may be added at any time.  You can configure what
    each component's target is by using `ccmake` before `cmake`
    is run, as described above; look for `component_RUNKIND`
    variables.

  * Instead of our `mkroot` respository, you might have your own
    variations, and/or you might edit or patch what we supply.
    For instance, you might have a variation on the `contrib`
    scripts supplied next to the `rootfs` for a component.
    If it adds new facilitation, please make it general, add
    documentation and use CMake's generic path names so we may
    configure them specifically for the build target directory,
    and then send us a pull request!

