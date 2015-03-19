Bash Booster
============


Bash Booster is a single file library, which provides various features useful
during setup environment and preparing servers.  It is inspired by [Chef][]
and was developed to be used with [Vagrant][].  When Chef is too heavy,
use Bash Booster, because it has been written using Bash only and
**requires nothing**.

See full documentation at [the project homepage][].

[Chef]: http://www.chef.io/
[Vagrant]: http://vagrantup.com/
[the project homepage]: http://www.bashbooster.net/


Quick Start
-----------

Download [ready to use library archive][] or...

1.  Get the source code:

        :::bash
        $ hg clone https://bitbucket.org/kr41/bash-booster bash-booster
        $ cd bash-booster

2.  Build the library:

        :::bash
        $ ./build.sh

3.  Get the library at `build/bashbooster.sh` and use it!

Note for OS X users. OS X is shipped with an old version of Bash, so you need
to get a new one using [Homebrew][].

    :::bash
    $ brew install bash

A traditional “Hello World” script looks like this (you can find it
at `examples/helloworld.sh`):

    #!/usr/bin/env bash

    # Remove undesirable side effects of CDPATH variable
    unset CDPATH
    # Change current working directory to the directory contains this script
    cd "$( dirname "${BASH_SOURCE[0]}" )"

    # Initialize Bash Booster
    source build/bashbooster.sh

    # Log message with log level "INFO"
    bb-log-info "Hello World"

It just prints a line to `stderr`:

    helloworld.sh [INFO] Hello world

More interesting example, which demonstrates almost all features of
Bash Booster you can find at `examples/vagrant/bootstrap.sh`.  This script
is used for provisioning virtual machines managed by [Vagrant][].  A `Vagrantfile`
placed at `examples/vagrant` sets up three virtual machines: ubuntu, centos,
and debian.  Bootstrap script installs Nginx web-server, builds Bash Booster
documentation, and places compiled HTML into web-root directory. Just run:

    :::bash
    $ cd examples/vagrant
    $ vagrant up

...and have some coffee, then visit:

*   <http://localhost:8081>—Ubuntu machine
*   <http://localhost:8082>—CentOS machine
*   <http://localhost:8083>—Debian machine

If you run `vagrant provision` again, script will finish almost immediately.
It happens, because it does not do unnecessary job: all packages installed,
web-server configured, HTML compiled.

[ready to use library archive]: https://bitbucket.org/kr41/bash-booster/downloads
[Homebrew]: http://brew.sh/
[Vagrant]: http://vagrantup.com/


Support & Feedback
------------------

Visit our [discussion group] if any support is required.  It is a good place
for proposals too.  And of course, any feedback will be highly appreciated,
either good and bad.

[discussion group]: https://groups.google.com/forum/#!forum/bash-booster


License
-------

The code is licensed under the terms of GNU GPL version 3 license.
The full text of the license can be found at the root of the sources
or at [GNU website][].

[GNU website]: http://www.gnu.org/licenses/licenses.html
