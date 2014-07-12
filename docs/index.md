Title: Bash Booster


Bash Booster
============

Bash Booster is steroids for bootstrap scripts.  It is a single file
library, which provides various features useful during setup environment and
preparing servers.  It is inspired by [Chef][] and was developed to be used
with [Vagrant][].  When Chef is too heavy, use Bash Booster, because it
has been written using [Bash][] only and **requires nothing**.

[Chef]: http://www.getchef.com/
[Vagrant]: http://vagrantup.com/
[Bash]: http://www.gnu.org/software/bash/


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

    #!/bin/bash

    unset CDPATH
    cd "$( dirname "${BASH_SOURCE[0]}" )"

    source bashbooster.sh

    bb-log-info "Hello world"

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
It happens, because it doesn't do unnecessary work: all packages installed,
web-server configured, HTML compiled.


Philosophy
----------

The main goal of Bash Booster is ability to write idempotent scripts.
For instance, you have to manage developer´s virtual machine using Ubuntu.
At the start of your project you just need a web-server installed and nothing
more.  But requirements may change in future.  So you place `bootstrap.sh`
script at the root of your project sources:

    #!/bin/bash

    apt-get update
    apt-get install nginx

Each time you pull the code from repository, you have to run this script
on the virtual machine, because someone from you team might update the
requirements and add some other packages to install.  I think, you will
automate this, so the script will run at VM start up time.  And at most of the
time it will just make you to wait for `apt-get update` command.  It is annoying.

Once you will think about replacing the tool.  You may think about Chef.
To run it you will have to install Ruby.  But Ruby at the Ubuntu repositories
has an ancient version, which doesn't support Chef.  So you need to install RVM
and...

Wait, what the heck? You was just going to install Nginx, why do you need all
this stuff?  The answer is: you don't.  You need a set of handy Bash functions,
which requires nothing, but only Bash, which already included into each Linux
distribution.  So Bash Booster is such set.  The script above can look like
this:

    #!/bin/bash

    unset CDPATH
    cd "$( dirname "${BASH_SOURCE[0]}" )"

    source bashbooster.sh

    # The command above will check whether nginx package already installed.
    # If it doesn't, it will install it.
    # And it will also update apt cache, before installation.
    # If nginx already installed, it will do nothing.
    bb-apt-install nginx


Code Organization
-----------------

Bash Booster comes with a set of modules.  These modules are merged to a single
file to be easy to use.  But their sources are placed at `source` directory
to be easy to read, because source code is the best documentation.  Each module
has an numeric index, which indicates inclusion order.  For instance,
workspace management module `10_workspace.sh` will be included before
events management one `20_event.sh`.

Each function has the following name format: `bb-module-func`, where `bb` is
a common function prefix (means “Bash Booster”), `module` is module name,
`func` is function name.  For example, function `bb-event-on` (subscribes
handler on event) from `event` module. Some functions doesn't
contain `func` part of the name.  For example, `bb-exit` function (terminates
script with specified exit code and logs exit message) from module `exit`.
Boolean functions end in Ruby style by question mark.  For example, `bb-yum?`
function returns `0` if Yum (the default package manager used in CentOS)
is available and `1` otherwise.

There is special function names: `init` and `cleanup`.  They are used for module
initialization and cleaning up its resources.  You don´t need to use these
functions in your scripts.  They are called automatically.

Each variable has a format, which is the similar to the function names:
`BB_MODULE_VAR`.

There is also a special module `init`, which initialize Bash Booster
and sets up a trap on `EXIT` signal.  So **don´t use** in your script:

    :::bash
    trap my-cleanup-command EXIT

It will break cleanup process.  Subscribe on `bb-cleanup` event instead,
it will be fired just before exit:

    :::bash
    bb-even-on bb-cleanup my-cleanup-command


Module Description
------------------

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


### var

The module contains a single function for management variables

**bb-var** VAR_NAME DEFAULT_VALUE
:   The function will set up variable `VAR_NAME` to `DEFAULT_VALUE`, if variable
    is undefined.  It is used for configurable variables.  For example:

        #!/bin/bash

        unset CDPATH
        cd "$( dirname "${BASH_SOURCE[0]}" )"

        # Change default location of workspace directory
        BB_WORKSPACE="/var/myworkspace"
        source bashbooster.sh


### log


### exit


### workspace

The module manages workspace directory.

**BB_WORKSPACE**
:   The variable stores full path to the workspace directory.  The workspace
    directory is created on startup and deleted (if it is empty) on cleanup
    automatically.

    The default value is `.bb-workspace`, which means the workspace will be
    created in the same directory, where caller script is stored. To override
    default value use:

        #!/bin/bash

        unset CDPATH
        cd "$( dirname "${BASH_SOURCE[0]}" )"

        # Change default location of workspace directory
        BB_WORKSPACE="/var/myworkspace"
        source bashbooster.sh

    You can use relative path also.  It will be unfolded to full one after
    initialization.

    It is an appropriate place to store files, which are used by your script.
    Bash Booster itself uses this directory to store: temp files
    `"$BB_WORKSPACE/tmp/"`, downloads `"$BB_WORKSPACE/download/"`, and flags
    `"$BB_WORKSPACE/flag/"`.


### tmp

The module manages temporary files and directories.  All files and directories
created by the following functions will be automatically deleted on exiting
script.

**bb-tmp-file**
:   Creates temporary file:

        :::bash
        MY_TMP_FILE=`bb-tmp-file`
        echo "Some stuff" > "$MY_TMP_FILE"

**bb-tmp-dir**
:   Creates temporary directory:

        :::bash
        MY_TMP_DIR=`bb-tmp-dir`
        touch "$MY_TMP_DIR/file1"
        touch "$MY_TMP_DIR/file2"


### template

Provides stupid and simple Bash-based templates handling.  It is useful for
variable substitution only, but in most cases it is enough.  If you are looking
for something more powerful, you will have to install it manually.

**bb-template** TEMPLATE_FILE
:   Renders template from `TEMPLATE_FILE` to `stdout` using all defined
    variables.

    Template file `$BB_WORSPACE/templates/example.bbt`:

        :::bash
        x=$(( A + B ))
        msg='${MESSAGE}'

    Script:

        :::bash
        A=1
        B=2
        MESSAGE='Hello World'
        bb-template "$BB_WORSPACE/templates/example.bbt" > "$BB_WORSPACE/results/example.txt"

    Result output file `$BB_WORKSPACE/results/example.txt`:

        :::bash
        x=3
        msg='Hello World'


### event


### download


### flag


### sync


### apt


### yum
