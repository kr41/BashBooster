Bash Booster
============

Bash Booster is steroids for bootstrap scripts.  It is a single file
library, which provides various features useful during setup environment and
preparing servers.  It is inspired by [Chef][] and was developed to be used
with [Vagrant][].  When Chef is too heavy, use Bash Booster, because it
has been written using [Bash][] only and **requires nothing**.

How to start:

1.  Get the source code:

        $ hg clone ssh://hg@bitbucket.org/kr41/bash-booster bash-booster
        $ cd bash-booster

2.  Build the library file `bashbooster.sh`:

        $ ./build.sh

3.  Use it!

You can find `Vagrantfile` on the root of sources.  It sets up three virtual
machines using Ubuntu, CentOS, and Debian, and uses `example/bootstrap.sh`
script for provisioning.  The script installs and configures Nginx web-server,
builds Bash Booster documentation and places it to the web root directory. Run:

    $ vagrant up

Then visit:

*   <http://localhost:8081> — Ubuntu machine
*   <http://localhost:8082> — CentOS machine
*   <http://localhost:8083> — Debian machine

[Chef]: http://www.getchef.com/
[Vagrant]: http://vagrantup.com/
[Bash]: http://www.gnu.org/software/bash/
