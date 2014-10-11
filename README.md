Bash Booster
============


Bash Booster is a single file library, which provides various features useful
during setup environment and preparing servers.  It is inspired by [Chef][]
and was developed to be used with [Vagrant][].  When Chef is too heavy,
use Bash Booster, because it has been written using Bash only and
**requires nothing**.

[Chef]: http://www.getchef.com/
[Vagrant]: http://vagrantup.com/


Quick Start
-----------

1.  Get the source code:

        :::bash
        $ hg clone ssh://hg@bitbucket.org/kr41/bash-booster bash-booster
        $ cd bash-booster

2.  Build the library file `bashbooster.sh`:

        :::bash
        $ ./build.sh

3.  Use it!

A traditional “Hello World” script looks like this (you can find it
in `helloworld.sh`):

    #!/usr/bin/env bash

    # Remove undesirable side effects of CDPATH variable
    unset CDPATH
    # Change current working directory to the directory contains this script
    cd "$( dirname "${BASH_SOURCE[0]}" )"

    # Initialize Bash Booster
    source bashbooster.sh

    # Log message with log level "INFO"
    bb-log-info "Hello World"

It just prints a line to `stderr`:

    helloworld.sh [INFO] Hello world

More interesting example, which demonstrates almost all features of
Bash Booster you can find at `example/bootstrap.sh`.  This script is used
for provisioning virtual machines managed by Vagrant.  A `Vagrantfile` placed
at the root of sources sets up three virtual machines: ubuntu, centos, and
debian.  Bootstrap script installs Nginx web-server, builds Bash Booster
documentation, and places compiled HTML into web-root directory. Just run:

    :::bash
    $ vagrant up

...and have some coffee, then visit:

*   <http://localhost:8081> — Ubuntu machine
*   <http://localhost:8082> — CentOS machine
*   <http://localhost:8083> — Debian machine

If you run `vagrant provision` again, script will finish almost immediately.
It happens, because it does not do unnecessary job: all packages installed,
web-server configured, HTML compiled.


Support
-------

Visit our [discussion group] if any support is required.  It is a good place
for proposals too.

[discussion group]: https://groups.google.com/forum/#!forum/bash-booster
