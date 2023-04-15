# Builder for epsonscan2

This allows building the epsonscan2 software https://support.epson.net/linux/en/epsonscan2.php as a Debian package.

## Why
I wanted to run an EPSON DS-310 on my headless Raspberry PI (a scanserver for paperless-ngx).

There are no official arm64 images and the deb files require an X server installation which I really like to avoid.

### Other sane backends
There are other backends that "support" this printer.

* epson
* epson2
* epsonds
* utsushi

I'm really not sure which one to actually use, I had success with utsushi but all in all it feels that the backends (apart from utsushi) are all pretty dated.

I finally decided to go with epsonscan2 over utsushi as the build does not consume so much memory.

## How
I found that the epsonscan2 code already contain a define to exclude the UI component and just build the command line tooling.

The `patch_cmake.diff` contains a patch to the cmake files that ensure that only the correct files are compiled and linked together. Further it adds `cpack` to allow easy packaging.

## What else

The Makefile will download epsonscan2, untar it and patch it.
The Dockerfile is used by the docker-* make targets. The dockerfile contains all build requirements. I've run this from a M1 Macbook natively (i.e., also ARM64) which works fine. Should also work from a Raspberry Pi (probably slow).

More work is required to cross compile this from x86_64.

## Usage

Scanning can be done with sane-compatible software or directly via epsonscan2.

To use the latter, one requires a config that is not too easy to get right (e.g., it epsonscan2 just segfaults if certain JPEG quality settings are zero).

I ended up using the UI version to create a config as the UI checks the scanner's capabilities and shows you what you can configure.

I also found that the linux version of epsonscan2 is not as powerfull on my scanner as the MacOS counterpart, e.g., that is better at cropping a picture and e.g., allows to remove punch holes. The latter is even a setting but is not functional for me.