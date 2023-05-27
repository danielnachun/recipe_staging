# Build conda recipes and upload them to your personal channel

The traditional approach to building software not provided by a host package manager is to build it from source on the same system it will be run on.  For unprivileged users running in HPC environments, all software may need to be built from source.

The Conda package manager is a universal, binary package manager that works in any installation prefix in privileged and unprivileged environments.  While originally developed for distributing Python packages, Conda can now provide relocatable, precompiled packages for any language.

The workflows in this repository provide an easy way to upload Conda recipes and have the packages built and uploaded to a personal channel using GitHub Actions.  This means you don't have to build the Conda packages in an HPC environment or in a virtual machine on your personal computer (although instructions for doing this are provided in the wiki).

Building and uploading Conda packages to a personal channel should **not** be a substitute for submitting and maintaining these packages on [conda-forge](https://anaconda.org/conda-forge) and [bioconda](https://anaconda.org/bioconda).  This setup should be used when developing and testing packages with the intention of submitting them to upstream channels when they are ready.  Please see the [wiki](https://github.com/danielnachun/recipe_staging/wiki/Preparing-your-software-for-submission-to-conda-forge-or-bioconda) for more information on how you should prepare your software for public use.

## Using these workflow with your personal channel

Make a fork of this repository.

You will need to set up a personal Anaconda channel and add an API key for the channel to the repository secrets.  See the [wiki](https://github.com/danielnachun/recipe_staging/wiki/Creating-and-adding-an-Anaconda-API-token-to-the-repository-secrets) for a step-by-step walkthrough.

You will also want to modify the [default channels configuration](https://github.com/danielnachun/recipe_staging/blob/main/.github/conda_channels) to use whatever channels you want.  The order of the channels in this config file determines their precedence for dependency resolution - `mamba` will search for the dependency in the channels in the order they are given in the file.  You should usually leave the last 3 channels as `conda-forge`, `bioconda` and `nodefaults` in that order so that any custom channels you add before them are checked first, that `bioconda` is checked after `conda-forge`, and the legacy `defaults` channels are ignored.
