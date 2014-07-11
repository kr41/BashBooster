Title: Bash Booster


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
machines using Ubuntu, CentOS, and Debian.  Bootstrap script and other resources
are placed in `example` directory.

Code Organization
-----------------




[Chef]: http://www.getchef.com/
[Vagrant]: http://vagrantup.com/
[Bash]: http://www.gnu.org/software/bash/

- [var](#var)
- [log](#log)
- [exit](#exit)
- [workspace](#workspace)
- [template](#template)
- [event](#event)
- [download](#download)
- [flag](#flag)
- [sync](#sync)
- [apt](#apt)
- [yum](#yum)

var
---

log
---

exit
----

workspace
---------

tmp
---

template
--------

event
-----

download
--------

flag
----

sync
----

apt
---

yum
---
