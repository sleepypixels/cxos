# GNAT cross-compiler build script

The provided `build_cross_gnat` script provides a working recipe for building a GNAT cross compiler targeting `i686-elf` suitable for building the `cxos` kernel.
This script is currently configured for Ubuntu Linux, but should be easily adaptable to other systems. Feel free to extend this script to improve compatibility. This script has been tested across several Ubuntu machines.

## Prerequisites

In order to build a GNAT cross compiler, you need `gcc`, `g++`, and `gnat` to be available. It is also *highly* recommended that you have the *same* version of `gcc`/`g++` and `gnat` to keep things easy. On Ubuntu 18.04, that means installing `build-essential` and `gnat` like so:

```sh
$ sudo apt install build-essential gnat
```

While you're at it, open up `build_cross_gnat` and set `local_gcc_major_version` appropriately. In the example above, `gcc --version` will output `GCC 7.3.0`, so slap a `7` between the quotes.

The other important prerequisite is `gprbuild`. If you do not wish to make modifications to a system-installation of `gprbuild`, then `build_cross_gnat` can bootstrap and build `gprbuild` for you. At any rate, the patch files in this directory can be used to make the necessary changes to the `gprbuild` configuration files.

The script requires that you have the sources for `gcc`, `binutils` and `newlib` downloaded on your system. These are available from the GNU FTP servers ([GCC](https://ftp.gnu.org/gnu/gcc/) and [Binutils](https://ftp.gnu.org/gnu/binutils/)) and the sourceware FTP ([newlib](ftp://sourceware.org/pub/newlib/index.html)). The script will look for these archives of the versions specified in the script in the `~/Downloads` folder. Otherwise, the archives of each will be downloaded to a folder in `/tmp` automatically. By default the script will assume that you have these sources extracted in the location `${HOME}/src/`. If not, the archives will be extracted for you. The folders used as the source folders are easily configurable in the script.

## Post-setup

Before you can use the newly configured toolchain with `gprbuild`, you will firstly need to ensure that your new toolchain's install directory is properly added to your `PATH` variable.
Additionally, you will need to ensure that `gprbuild` correctly recognises our toolchain and is configured for library development. This is done by adding configuration information about our toolchain to GPRBuild's 'knowledge base'. There are multiple ways to accomplish this. Automatic and manual steps are both outlined below.

### Automatic

Using `gprconfig-linker.xml.patch` in this directory, use the `patch` command to make the necessary to your `gprbuild` linker configuration file.

```
$ patch <prefix>/share/gprconfig/linker.xml gprconfig-linker.xml.patch
```

### Manual

Open up GPRBuild's linker configuration file, typically located at `${prefix}/share/gprconfig/linker.xml`, where `${prefix}` is the location of your GNAT install directory (in the case that you have GPRBuild installed with AdaCore GNAT. Other configurations may have a different directory structure). This file instructs GPRBuild how to link executables and libraries using the various supported toolchains.
The easiest way to do this is to duplicate an existing toolchain configuration. Inside this file, search for an existing configuration such as `leon-elf`, and duplicate each entry for the existing configuration. modifying it to suit our `i686-elf` target.

For example:
```xml
  <configuration>
    <targets>
      //...
       <target name="^i686-elf$" />
    </targets>
    <config>
   for Library_Support  use "static_only";
   for Library_Builder  use "${GPRCONFIG_PREFIX}libexec/gprbuild/gprlib";
    </config>
  </configuration>

	//...

  <configuration>
    <targets>
      <target name="^i686-elf$" />
    </targets>
    <config>
   for Archive_Builder  use ("i686-elf-ar", "cr");
   for Archive_Builder_Append_Option use ("q");
   for Archive_Indexer  use ("i686-elf-ranlib");
   for Archive_Suffix   use ".a";
    </config>
  </configuration>
```

Once you have duplicated all of these toolchain entries and modified them for our toolchain, paying special attention to preserve any regex special characters, you should now be able to successfully use the newly built toolchain together with GPRBuild.

Additional documentation can be found on GPRBuild's configuration [here](http://docs.adacore.com/live/wave/gprbuild/html/gprbuild_ug/gprbuild_ug/companion_tools.html).

### Troubleshooting


`gprconfig: can't find a native toolchain for language 'ada'`

If you are running Ubuntu 18.10 with GCC and GNAT version 8.3.0, 
this error is can be fixed by appling the `gprconfig-compilers.xml.patch` patch to `<prefix>/share/gprconfig/compilers.xml`.

