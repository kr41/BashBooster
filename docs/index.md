Title: Bash Booster

<header>Bash Booster</header>


Bash Booster is a single file library, which provides various features useful
during setup environment and preparing servers.  It is inspired by [Chef][]
and was developed to be used with [Vagrant][].  When Chef is too heavy,
use Bash Booster, because it has been written using Bash only and
**requires nothing**.

[Chef]: http://www.getchef.com/
[Vagrant]: http://vagrantup.com/

**Contents**

[TOC]

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


Philosophy
----------

The main goal of Bash Booster is ability to write [idempotent][Idempotence]
scripts.  For instance, you have to manage developer´s virtual machine using
Ubuntu.  At the start of your project you just need a web-server installed
and nothing more.  But requirements may be changed in future.  So you place
`bootstrap.sh` script at the root of your project sources:

    #!/bin/bash

    apt-get update
    apt-get install nginx

Each time you pull the code from repository, you have to run this script
on the virtual machine, because someone from you team might update the
requirements and add some other packages to install.  I think, you will
automate this, so the script will run at VM start up time.  And at most of the
time it will just make you to wait for `apt-get update` command.
It is annoying.

Once you will think about replacing the tool.  You may think about Chef.
To run it you will have to install Ruby.  But Ruby at the Ubuntu repositories
has an ancient version, which does not support Chef.  So you need to install
RVM and...

Wait, what the heck? You was just going to install Nginx, why do you need all
this stuff?  The answer is: you don´t.  You need a set of handy Bash functions,
which requires nothing, but only Bash, which already included into each Linux
distribution.  So Bash Booster is such set.  The script above can look like
this:

    #!/bin/bash

    unset CDPATH
    cd "$( dirname "${BASH_SOURCE[0]}" )"

    source bashbooster.sh

    # The command bellow will check whether "nginx" package already installed.
    # If it doesn't, it will install it.
    # And it will also update Apt cache, before installation.
    # If Nginx already installed, it will do nothing.
    bb-apt-install nginx

[Idempotence]: http://en.wikipedia.org/wiki/Idempotence


Code Organization
-----------------

Bash Booster comes with a set of modules.  These modules are merged to a single
file (by `build.sh` script) to be easy to use.  But their sources are placed at
`source` directory to be easy to read, because source code is the best
documentation.  Each module has a numeric index, which indicates inclusion
order.  For instance, workspace management module
[`10_workspace.sh`](#workspace){: .code } will be included before events
management one [`20_event.sh`](#event){: .code }.

Each function has the following name format: `bb-module-func`, where `bb` is
a common function prefix (means “Bash Booster”), `module` is module name,
`func` is function name.  For example, function
[`bb-event-on`](#bb-event-on){: .code } (subscribes handler on event) from
[`event`](#event){: .code } module. Some functions does not contain `func` part
of the name.  For example, [`bb-exit`](#bb-exit){: .code } function (terminates
script with specified exit code and logs exit message) from module
[`exit`](#exit){: .code }.  Boolean functions end in Ruby style by question mark.
For example, [`bb-yum?`](#bb-yum){: .code } function returns `0` if Yum
(the default package manager used in CentOS) is available and `1` otherwise.

There is special function names: `init` and `cleanup`.  They are used for module
initialization and cleaning up its resources.  You do not need to use these
functions in your scripts.  They are called automatically.  So their description
are not included into this document.

Each variable has a format, which is the similar to the function names:
`BB_MODULE_VAR`.

There is also a special module `init`, which initialize Bash Booster
and sets up a trap on `EXIT` signal.  So **do not use** in your script:

    :::bash
    trap my-cleanup-command EXIT

It will break cleanup process.  [Subscribe](#bb-event-on) on `bb-cleanup` event
instead, it will be fired just before exit:

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

The module contains a single function for management undefined variables

**bb-var** VAR_NAME DEFAULT_VALUE {: #bb-var }
:   The function will set up variable `VAR_NAME` to `DEFAULT_VALUE`, if variable
    is undefined.  It is used for configurable variables.  For example:

        #!/bin/bash

        unset CDPATH
        cd "$( dirname "${BASH_SOURCE[0]}" )"

        # Change default location of workspace directory
        BB_WORKSPACE="/var/myworkspace"
        source bashbooster.sh

    You can use this function to configure your own scripts using environment
    variables.  For instance:

        $ export MY_VAR="Special Value"
        $ ./my_script.sh

    Script `my_script.sh`:

        #!/bin/bash

        unset CDPATH
        cd "$( dirname "${BASH_SOURCE[0]}" )"

        source bashbooster.sh
        bb-var MY_VAR "Default Value"

        # Do something useful


### log

The module provides functions to log messages to `stderr`.

**BB_LOG_LEVEL** {: #BB_LOG_LEVEL }
:   Log verbosity level, default is `INFO`.  This variable can be set to
    numeric or string values, i.e. 1–4, `DEBUG`, `INFO`, `WARNING`, or `ERROR`.
    Current log level can be gotten using functions
    [`bb-log-level-code`](#bb-log-level-code){: .code } and
    [`bb-log-level-name`](#bb-log-level-name){: .code }.

** BB_LOG_PREFIX ** {: #BB_LOG_PREFIX }
:   Log prefix, default is `"$( basename "$0" )"`, i.e. script name.

**BB_LOG_TIME** {: #BB_LOG_TIME }
:   Command to get date and time of log message, default is
    `date --rfc-3339=seconds`.

**BB_LOG_FORMAT** {: #BB_LOG_FORMAT }
:   Log string format, default is `'${PREFIX} [${LEVEL}] ${MESSAGE}'`.
    The following variables can be used in log format:

    *   `LEVEL_CODE` — Log level numeric value
    *   `LEVEL` — Log level text value
    *   `MESSAGE` — Message to log
    *   `PREFIX` — Log message prefix, usually is
        [`BB_LOG_PREFIX`](#BB_LOG_PREFIX){: .code}.  If logger is called within
        Bash Booster function, prefix will be equal to its module name.
    *   `TIME` — Log time, the output of [`BB_LOG_TIME`](#BB_LOG_TIME){: .code}
        command.
    *   `COLOR` — Escape code to start colored output
    *   `NOCOLOR` — Escape code to stop colored output

**BB_LOG_USE_COLOR** {: #BB_USE_COLOR }
:   Boolean value, default is `false`.  If set to `true` before Bash Booster
    initialization, [`BB_LOG_FORMAT`](#BB_LOG_FORMAT){: .code } will be wrapped
    by `COLOR` and `NOCOLOR` values, so that log output will be colored according
    to log level:

    *   `DEBUG` — gray
    *   `INFO` — green
    *   `WARNING` — orange
    *   `ERROR` — red

    Changing this variable after initialization will take no effect.

**bb-log-level-code** {: #bb-log-level-code }
:   Prints to `stdout` current log level code, i.e. 1–4.

**bb-log-level-name** {: #bb-log-level-name }
:   Prints to `stdout` current log level name, i.e. `DEBUG`, `INFO`, `WARNING`,
    or `ERROR`.

**bb-log-debug** MESSAGE {: #bb-log-debug }
:   Logs `MESSAGE` with `DEBUG` level.

**bb-log-info** MESSAGE {: #bb-log-info }
:   Logs `MESSAGE` with `INFO` level.

**bb-log-warning** MESSAGE {: #bb-log-warning }
:   Logs `MESSAGE` with `WARNING` level.

**bb-log-error** MESSAGE {: #bb-log-error }
:   Logs `MESSAGE` with `ERROR` level.


### exit

**bb-exit** CODE MSG {: #bb-exit }
:   Terminates script with status `CODE` and logs the message `MSG`.
    If `CODE` is equal to `0`, message will be logged with `INFO` level.
    If `CODE` is non-zero, message will be logged with `ERROR` level.
    Additionally, it will log call stack with `DEBUG` level.  Usage:

        :::bash
        bb-exit 1 "Something went wrong"

    or:

        :::bash
        bb-exit 0 "Success"

### workspace

The module manages workspace directory.  It provides single variable for
your scripts.

**BB_WORKSPACE** {: #BB_WORKSPACE }
:   The variable stores full path to the workspace directory.  The workspace
    directory is created on startup and deleted (if it is empty) on cleanup
    automatically.

    The default value is `.bb-workspace`, which means the workspace will be
    created in the same directory, where caller script is stored.  To override
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
    Bash Booster itself uses this directory to store: [temp files](#tmp) at
    `$BB_WORKSPACE/tmp/`, [downloads](#download) at `$BB_WORKSPACE/download/`,
    and [flags](#flag) at `$BB_WORKSPACE/flag/`.


### tmp

The module manages temporary files and directories.  All files and directories
created by the following functions will be automatically deleted on exiting
script.

**bb-tmp-file** {: #bb-tmp-file }
:   Creates temporary file:

        :::bash
        MY_TMP_FILE=`bb-tmp-file`
        echo "Some stuff" > "$MY_TMP_FILE"

**bb-tmp-dir** {: #bb-tmp-dir }
:   Creates temporary directory:

        :::bash
        MY_TMP_DIR=`bb-tmp-dir`
        touch "$MY_TMP_DIR/file1"
        touch "$MY_TMP_DIR/file2"


### template

Provides stupid and simple Bash-based templates handling.  It is useful for
variable substitution only, but in the most cases it is enough.  If you are
looking for something more powerful, you will have to install it by your own.

**bb-template** TEMPLATE_FILE {: bb-template }
:   Renders template from `TEMPLATE_FILE` to `stdout` using all defined
    variables.

    Template file `$BB_WORSPACE/example.bbt`:

        x=$(( A + B ))
        msg='${MESSAGE}'

    Script:

        :::bash
        A=1
        B=2
        MESSAGE='Hello World'
        bb-template "$BB_WORSPACE/example.bbt" > "$BB_WORSPACE/example.txt"

    Result output file `$BB_WORKSPACE/example.txt`:

        x=3
        msg='Hello World'


### event

The module provides functions to work with events.  Typical use case is to
make some job conditionally.  For example, the following code pulls application
sources from repository, rebuilds one, and reloads application server:

    :::bash

    reload-server-handler() {
        bb-log-info "Reloading server"
        # ...
    }
    rebuild-app-handler() {
        bb-log-info "Rebuilding application"
        # ...
        bb-event-delay reload-server
    }

    bb-event-on reload-server reload-server-handler
    bb-event-on rebuild-app rebuild-app-handler

    cd "$PATH_TO_REPOSITORY"
    git pull
    bb-sync-dir "$BB_WORKSPACE/sources" "$PATH_TO_REPOSITORY/sources" rebuild-app
    bb-sync-file "/etc/server/config" "$PATH_TO_REPOSITORY/conf/server" reload-server

If source code of application is changed, it will rebuild application and
reload server.  If server configuration is changed, it will just reload server.
Learn mode about functions [`bb-sync-dir`](#bb-sync-dir){: .code } and
[`bb-sync-file`](#bb-sync-file){: .code } in [`sync`](#sync){: .code } module
description.

**bb-event-on** EVENT HANDLER {: #bb-event-on }
:   Subscribes `HANDLER` on `EVENT`.  `HANDLER` will be subscribed only once,
    so the second call with the same arguments will take no effect.

**bb-event-fire** EVENT {: #bb-event-fire }
:   Fires `EVENT`.  It will call all `EVENT` handlers immediately.
    This function is not very useful in your scripts, it is mostly for internal
    usage.

**bb-event-delay** EVENT {: #bb-event-delay }
:   Delays `EVENT` to the end of script.  It will call all `EVENT` handlers
    during the cleanup process.  Delayed event handlers can call this function
    too.


### download

The module manages download directory and its contents.

**bb-download** URL TARGET {: #bb-download }
:   Downloads file from `URL` and writes it to `$BB_WORKSPACE/download/$TARGET`.
    The second argument `TARGET` can be omitted.  In that case it will be
    detected using `basename "$URL"` command.  If `TARGET` file already exists,
    the function will not download it again.  Prints full path to downloaded
    file into `stdout`.  Usage:

        MY_FILE=`bb-download http://example.com/my_file.txt`
        # "$MY_FILE" == "$BB_WORKSPACE/download/my_file.txt"

**bb-download-clean** {: #bb-download-clean }
:   Removes all downloaded files, i.e. deletes directory
    `$BB_WORKSPACE/download`.


### flag

Some operations are not idempotent.  And you need to save information,
that some action has been done.  This module provides functions for such use
cases.

**bb-flag?** FLAG {: #bb-flag }
:   Returns `0` if `FLAG` is set, and `1` otherwise.  Usage:

        :::bash
        if ! bb-flag? somestate
        then
            # Do something useful
            bb-flag-set somestate
        fi

        if bb-flag? someotherstate
        then
            # Do something useful again
            bb-flag-unset someotherstate
        fi

**bb-flag-set** FLAG {: #bb-flag-set }
:   Sets up `FLAG`.

**bb-flag-unset** FLAG {: #bb-flag-unset }
:   Removes `FLAG`.

**bb-flag-clean**  {: #bb-flag-clean }
:   Removes all flags.


### sync

The module provides functions for synchronization files and directories.

**bb-sync-file** DST_FILE SRC_FILE EVENT {: #bb-sync-event }
:   Synchronizes contents of `DST_FILE` with `SRC_FILE`.  If `DST_FILE` is changed
    it will delay `EVENT`.  Usage:

        :::bash
        bb-event-on restart-server "service nginx restart"

        bb-sync-file "/etc/nginx/sites-available/default" "my_site.conf" restart-server

    Each time `my_site.conf` is changed, the script above will update Nginx
    configuration and restart it.

**bb-sync-dir** DST_DIR SRC_DIR EVENT {: #bb-sync-dir }
:   Synchronizes contents of `DST_DIR` with `SRC_DIR`.  If `DST_DIR` is changed
    it will delay `EVENT`.


### apt

The module provides functions to work with [Apt][] package manager.

**bb-apt?** {: #bb-apt }
:   Checks if Apt is available. Usage:

        :::bash
        if bb-apt?
        then
            bb-apt-install somepackage
        fi

**bb-apt-repo?** REPOSITORY {: #bb-apt-repo }
:   Checks if `REPOSITORY` is installed.  Usage:

        :::bash
        REPO=`http://example.com/repo/ubuntu/`
        if bb-apt-repo? $REPO
        then
            cp /etc/apt/sources.list /etc/apt/sources.list.backup
            echo "deb $REPO precise main" >> /etc/apt/sources.list
            echo "deb-src $REPO precise main" >> /etc/apt/sources.list
        fi


**bb-apt-package?** PACKAGE {: #bb-apt-package }
:   Checks if `PACKAGE` is installed.

**bb-apt-update** {: #bb-apt-update }
:   Updates Apt cache.  It sets up variable `BB_APT_UPDATED` to `true`.
    So the second call of this function does nothing.

**bb-apt-install** PACKAGE [PACKAGE...] {: #bb-apt-install }
:   Installs `PACKAGE` if it is not already installed.  It uses
    [`bb-apt-package?`](#bb-apt-package){: .code } for checking `PACKAGE`
    installation status, and [`bb-apt-update`](#bb-apt-update){: .code }
    for updating Apt cache before installation.

[Apt]: https://wiki.debian.org/Apt

### yum

The module provides functions to work with [Yum][] package manager.

**bb-yum?** {: #bb-yum }
:   Checks if Yum is available. Usage:

        :::bash
        if bb-yum?
        then
            bb-yum-install somepackage
        fi

**bb-yum-repo?** REPOSITORY {: #bb-yum-repo }
:   Checks if `REPOSITORY` repository is installed.  Usage:

        :::bash
        if bb-yum-repo? somerepo
        then
            rpm -ivh "http://example.com/repo/centos/somerepo.noarch.rpm"
        fi

**bb-yum-package?** PACKAGE {: #bb-yum-package }
:   Checks if `PACKAGE` is installed.

**bb-yum-update** {: #bb-yum-update }
:   Updates Yum cache.  It sets up variable `BB_YUM_UPDATED` to `true`.
    So the second call of this function does nothing.

**bb-yum-install** PACKAGE [PACKAGE...] {: #bb-yum-install }
:   Installs `PACKAGE` if it is not already installed.  It uses
    [`bb-yum-package?`](#bb-yum-package){: .code } for checking `PACKAGE`
    installation status, and [`bb-yum-update`](#bb-yum-update){: .code }
    for updating Yum cache before installation.

[Yum]: http://yum.baseurl.org/


Contribution
------------

Bug reports and pull requests are welcome on
[BitBucket](https://bitbucket.org/kr41/bash-booster/).

The source code is covered by unit tests where it is possible.  If you are
going to add some new features, try to keep them covered too.  Use the
following command to run tests:

    :::bash
    $ ./test.sh

Tests themselves are placed into `unit tests` directory.  Yes, with the space
char in the name.  It helps to catch stupid errors with unquoted variables.


License
-------

The code is licensed under the terms of BSD 2-Clause license.  The full text of
the license can be found at the root of the sources.
