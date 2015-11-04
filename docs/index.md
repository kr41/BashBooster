Title: Bash Booster

<header>Bash Booster</header>


Bash Booster is a single file library, which provides various features useful
during setup environment and preparing servers.  It is inspired by [Chef][]
and was developed to be used with [Vagrant][].  When Chef is too heavy,
use Bash Booster, because it has been written using Bash only and
**requires nothing**.

It also shipped with task runner utility, so you can install
into your system and [use as an automation tool](#task-runner).

[Chef]: http://www.chef.io/
[Vagrant]: http://vagrantup.com/


[TOC]

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


Philosophy
----------

The main goal of Bash Booster is ability to write [idempotent][Idempotence]
scripts.  For instance, you have to manage developer’s virtual machine using
Ubuntu.  At the start of your project you just need a web-server installed
and nothing more.  But requirements may be changed in future.  So you place
`bootstrap.sh` script at the root of your project sources:

    #!/usr/bin/env bash

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
this stuff?  The answer is: you don’t.  You need a set of handy Bash functions,
which requires nothing, but only Bash, which already included into each Linux
distribution.  So Bash Booster is such set.  The script above can look like
this:

    #!/usr/bin/env bash

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
    bb-event-on bb-cleanup my-cleanup-command


Module Description
------------------

- [error](#error)
- [var](#var)
- [log](#log)
- [exit](#exit)
- [assert](#assert)
- [ext](#ext)
- [exe](#exe)
- [workspace](#workspace)
- [template](#template)
- [properties](#properties)
- [event](#event)
- [download](#download)
- [flag](#flag)
- [read](#read)
- [sync](#sync)
- [wait](#wait)
- [task](#task)
- [apt](#apt)
- [yum](#yum)


### error

The module contains a single function for handling errors

**bb-error?** {: #bb-error }
:   The function will return `true`, if previous operation fails, i.e. returns
    non-zero exit code.  It also saves that exit code into global variable
    `BB_ERROR`.  Example:

        :::bash
        false
        if bb-error?
        then
            bb-log-error "An error with code $BB_ERROR occured"
            return $BB_ERROR
        fi

    The example above is equal to:

        :::bash
        false
        BB_ERROR=$?
        if (( $BB_ERROR != 0 ))
        then
            bb-log-error "An error with code $BB_ERROR occured"
            return $BB_ERROR
        fi


### var

The module contains a single function for management undefined variables

**bb-var** VAR_NAME DEFAULT_VALUE {: #bb-var }
:   The function will set up variable `VAR_NAME` to `DEFAULT_VALUE`, if variable
    is undefined.  It is used for configurable variables.  For example:

        #!/usr/bin/env bash

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

        #!/usr/bin/env bash

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
    `date +"%Y-%m-%d %H:%M:%S"`.

**BB_LOG_FORMAT** {: #BB_LOG_FORMAT }
:   Log string format, default is `'${PREFIX} [${LEVEL}] ${MESSAGE}'`.
    The following variables can be used in log format:

    *   `LEVEL_CODE`—Log level numeric value
    *   `LEVEL`—Log level text value
    *   `MESSAGE`—Message to log
    *   `PREFIX`—Log message prefix, usually is
        [`BB_LOG_PREFIX`](#BB_LOG_PREFIX){: .code}.  If logger is called within
        Bash Booster function, prefix will be equal to its module name.
    *   `TIME`—Log time, the output of [`BB_LOG_TIME`](#BB_LOG_TIME){: .code}
        command.
    *   `COLOR`—Escape code to start colored output
    *   `NOCOLOR`—Escape code to stop colored output

**BB_LOG_USE_COLOR** {: #BB_USE_COLOR }
:   Boolean value, default is `false`.  If set to `true` before Bash Booster
    initialization, [`BB_LOG_FORMAT`](#BB_LOG_FORMAT){: .code } will be wrapped
    by `COLOR` and `NOCOLOR` values, so that log output will be colored according
    to log level:

    *   `DEBUG`—gray
    *   `INFO`—green
    *   `WARNING`—orange
    *   `ERROR`—red

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

**bb-log-deprecated** ALTERNATIVE [CURRENT] {: #bb-log-deprecated }
:   Logs deprecation warning message:
    `"'$CURRENT' is deprecated, use '$ALTERNATIVE' instead"`.
    If optional `CURRENT` function name is not passed, it will be detected
    using callstack.

    The function is mostly useful for Bash Booster developers.


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

**bb-exit-on-error** MSG {: #bb-exit }
:   If previous operation fails (returns non-zero exit code), the function will
    terminate script with the same code and given error message `MSG`.  Usage:

        :::bash
        false
        bb-exit-on-error "Something went wrong"

    It is equal to combination of [`bb-error?`](#bb-error){: .code } and
    [`bb-exit`](#bb-exit){: .code } functions:

        :::bash
        false
        if bb-error?
        then
            bb-exit $BB_ERROR "Something went wrong"
        fi


### assert

**bb-assert** ASSERTION [MSG] {: #bb-assert }
:   Evaluates `ASSERTION`.  If assertion returns non-zero code, it will
    exit script with code `3` and error message `MSG`.  If `MSG` is not
    passed, it will use default one: `"Assertion error '$ASSERTION'"`.

**bb-assert-root** [MSG] {: #bb-assert-root }
:   Evaluates if the script is running as root.  If assertion is false, it will
    exit script with code `3` and error message `MSG`.  If `MSG` is not passed,
    it will use default one: `"This script must be run as root!"`.

**bb-assert-file** FILE [MSG] {: #bb-assert-file }
:   Evaluates if the file `FILE` exists.  If assertion is false, it will exit
    script with code `3` and error message `MSG`.  If `MSG` is not passed, it
    will use default one: `"File '$FILE' not found"`.

**bb-assert-file-readable** FILE [MSG] {: #bb-assert-file-readable }
:   Evaluates if the file `FILE` is readable.  If assertion is false, it will
    exit script with code `3` and error message `MSG`.  If `MSG` is not passed,
    it will use default one: `"File '$FILE' is not readable"`.

**bb-assert-file-writeable** FILE [MSG] {: #bb-assert-file-writeable }
:   Evaluates if the file `FILE` is writeable.  If assertion is false, it will
    exit script with code `3` and error message `MSG`.  If `MSG` is not passed,
    it will use default one: `"File '$FILE' is not writeable"`.

**bb-assert-file-executable** FILE [MSG] {: #bb-assert-file-executable }
:   Evaluates if the file `FILE` is executable.  If assertion is false, it will
    exit script with code `3` and error message `MSG`.  If `MSG` is not passed,
    it will use default one: `"File '$FILE' is not executable"`.

**bb-assert-dir** DIR [MSG] {: #bb-assert-file-dir }
:   Evaluates if the directory `DIR` exists.  If assertion is false, it will
    exit script with code `3` and error message `MSG`.  If `MSG` is not passed,
    it will use default one: `"Directory '$DIR' not found"`.


### ext

Some tasks can be easily solved using other scripting languages.
This module provides features to add extension functions using short
non-bash scripts.  At the moment, only [Python][] is available.
However, it is good place for [adding](#contribution) other interpreters.

**bb-ext-python** NAME <BODY {: #bb-ext-python }
:   Creates new function `NAME` using [Python][] interpreter. Example:

        :::bash
        bb-ext-python 'hello' <<EOF
        import sys
        print('Hello %s' % sys.argv[1])
        EOF

        hello 'World'   # Prints: Hello World

[Python]: https://www.python.org


### exe

**bb-exe?** EXE
:   Checks whether executable `EXE` is available.  It is a shortcut for
    `type -t "$EXE" > /dev/null`.  Usage:

        :::bash
        if ! bb-exe? pip
        then
            GET_PIP="$( bb-download https://bootstrap.pypa.io/get-pip.py )"
            python "$GET_PIP"
        fi


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

        #!/usr/bin/env bash

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
        MY_TMP_FILE="$( bb-tmp-file )"
        echo "Some stuff" > "$MY_TMP_FILE"

**bb-tmp-dir** {: #bb-tmp-dir }
:   Creates temporary directory:

        :::bash
        MY_TMP_DIR="$( bb-tmp-dir )"
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


### properties

**NOTE,** the module is deprecated, use [`read`](#read){: .code } module instead.

**bb-properties-read** FILENAME [PREFIX] {: #bb-properties-read }
:   See [`bb-read-properties`](#bb-read-properties){: .code }.


### event

The module provides functions to work with events.  Typical use case is to
make some job conditionally.  For example, the following code pulls application
sources from repository, rebuilds one, and reloads application server:

    :::bash

    bb-event-on reload-server on-reload-server
    on-reload-server() {
        bb-log-info "Reloading server"
        # ...
    }

    bb-event-on rebuild-app on-rebuild-app
    on-rebuild-app() {
        bb-log-info "Rebuilding application"
        # ...
        bb-event-delay reload-server
    }

    cd "$PATH_TO_REPOSITORY"
    git pull
    bb-sync-dir "$BB_WORKSPACE/sources" "$PATH_TO_REPOSITORY/sources" rebuild-app
    bb-sync-file "/etc/server/config" "$PATH_TO_REPOSITORY/conf/server" reload-server

If source code of application is changed, it will rebuild application and
reload server.  If server configuration is changed, it will just reload server.
Learn mode about functions [`bb-sync-dir`](#bb-sync-dir){: .code } and
[`bb-sync-file`](#bb-sync-file){: .code } in [`sync`](#sync){: .code } module
description.

There is also a special event `bb-cleanup`.  This event fires automatically
just before script termination.

**bb-event-on** EVENT HANDLER {: #bb-event-on }
:   Subscribes `HANDLER` on `EVENT`.  `HANDLER` will be subscribed only once,
    so the second call with the same arguments will take no effect.

**bb-event-off** EVENT HANDLER {: #bb-event-off }
:   Removes `HANDLER` from `EVENT`.

**bb-event-fire** EVENT [ARGUMENTS...] {: #bb-event-fire }
:   Fires `EVENT`.  It will call all `EVENT` handlers with `ARGUMENTS` (if any)
    immediately.  This function is not very useful in your scripts,
    it is mostly for internal usage.

**bb-event-delay** EVENT [ARGUMENTS...] {: #bb-event-delay }
:   Delays `EVENT` to the end of script.  It will call all `EVENT` handlers
    with `ARGUMENTS` during the cleanup process.  Delayed event handlers can
    call this function too.  If event is delayed twice with the same arguments,
    its handler will be called only once.


### download

The module manages download directory and its contents.

**BB_DOWNLOAD_WGET_OPTIONS** {: #BB_DOWNLOAD_WGET_OPTIONS }
:   As the variable name says, it stores additional [Wget][] options and can
    be used to tune [`bb-download`](#bb-download){: .code } behavior.

**bb-download** URL [TARGET [FORCE]] {: #bb-download }
:   Downloads file from `URL` and writes it to `$BB_WORKSPACE/download/$TARGET`.
    The second argument `TARGET` can be omitted.  In that case it will be
    detected using `basename "$URL"` command.  If `TARGET` file already exists,
    the function will not download it again.  Pass `true` as a `FORCE` argument
    to change this behavior.  The full path to downloaded file will be
    printed into `stdout`.  Usage:

        :::bash
        MY_FILE="$( bb-download http://example.com/my_file.txt )"
        # "$MY_FILE" == "$BB_WORKSPACE/download/my_file.txt"

**bb-download-clean** {: #bb-download-clean }
:   Removes all downloaded files, i.e. deletes directory
    `$BB_WORKSPACE/download`.

[Wget]: https://www.gnu.org/software/wget/


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


### read

The module provides function to read [Java Properties][], [INI][], [JSON][],
and [YAML][] files into Bash variables.  It uses [`bb-ext-python`](#bb-ext-python){: .code }
to create read helpers.  So you need Python to be installed to use this
module.

Each reading function accepts optional `PREFIX` argument, which prepends
result variable names.  Any illegal char (which cannot be in the Bash variable
name) will be replaced by `_` underscore one.  So that keys like `dotted.key`
will be imported as `dotted_key`.

Complex objects like hashes and arrays (from JSON and YAML) are unfolded to the
flat variables.  Nulls are treated as empty strings.

If the file doesn’t exist or cannot be read, the function logs error and
returns `1`.

Each reading function has its helper one, which just prints variables to
stdout.  Such helper functions ends with `-helper` postfix. For examle,
`bb-read-json-helper` is a helper for [`bb-read-json`](#bb-read-json){: .code }.
You can use these helpers for debugging.


**bb-read-properties** FILENAME [PREFIX] {: #bb-read-properties }
:   The function reads [Java Properties][] file `FILENAME` and parses it.
    The lines like `key=value` or `key: value` or even `key := value`
    are converted into Bash variables.  For example, let `my.properties`
    file contains:

        param1 = value1
        param2 = long string

    And the script can read it as the following:

        :::bash
        bb-read-properties "my.properties" "conf_"
        echo "$conf_param1"     # prints "value1"
        echo "$conf_param2"     # prints "long string"

    If the same key appears multiple times, only the last value will be visible.

    The escapes in the key name (like `k\:e\=y`) are _not supported_,
    the first `:` or `=` is treated as the end of the key name.

    The multiline values (where the endline character is escaped by backslash)
    are _not supported_ too.

**bb-read-ini** FILENAME [SECTION [PREFIX]] {: #bb-read-ini }
:   The function reads [INI][] file `FILENAME` and parses it.  The optional
    `SECTION` can be passed to read values from only this section.
    If `SECTION` is omitted or equals to `*`, all sections will be read.
    Each key will be prepended by its section name.

        :::ini
        [section]
        param = value1

        [section:2]
        param = long string

    And the script can read it as the following:

        :::bash
        bb-read-ini "my.ini" "*" "conf_"
        echo "$conf_section_param"     # prints "value1"
        echo "$conf_section_2_param"   # prints "long string"

    The function will use [SafeConfigParser][], if Python 2.x is default Python
    interpreter, or [ConfigParser][] for Python 3.x.  See their documentation for
    details.

**bb-read-json** FILENAME [PREFIX] {: #bb-read-json }
:   The function reads [JSON][] file `FILENAME` and parses it.
    For example, let `my.json` file contains:

        :::json
        {
            "key": "value1",
            "object": { "key": "value2" },
            "array": [1, { "key": "value3" } ]
        }

    And the script can read it as the following:

        :::bash
        bb-read-json "my.json" "conf"  # NOTE, there is no "_" at the end of prefix
        echo "$conf_key"               # prints "value1"
        echo "$conf_object_key"        # prints "value2"
        echo "$conf_array_len"         # prints "2", the length of array
        echo "$conf_array_0"           # prints "1", the first element of array
        echo "$conf_array_1_key"       # prints "value3"


**bb-read-yaml** FILENAME [PREFIX] {: #bb-read-yaml }
:   The function reads [YAML][] file `FILENAME` and parses it.
    For example, let `my.yaml` file contains:

        :::yaml
        key: value1
        object:
            key: value2
        array:
            - 1
            - { "key": "value3" }

    And the script can read it as the following:

        :::bash
        bb-read-yaml "my.yaml" "conf"  # NOTE, there is no "_" at the end of prefix
        echo "$conf_key"               # prints "value1"
        echo "$conf_object_key"        # prints "value2"
        echo "$conf_array_len"         # prints "2", the length of array
        echo "$conf_array_0"           # prints "1", the first element of array
        echo "$conf_array_1_key"       # prints "value3"

    The function depends on [PyYaml][], which is not in the Python standard
    library.  Use [`bb-read-yaml?`](#bb-read-yaml_){: .code } function to check
    whether PyYaml is installed. For example:

        :::bash
        bb-read-yaml? || pip install pyyaml

**bb-read-yaml?** {: #bb-read-yaml_ }
:   Checks whether [PyYaml][] is installed, so that function
    [`bb-read-yaml`](#bb-read-yaml){: .code } can be used.

[Java Properties]: http://docs.oracle.com/javase/7/docs/api/java/util/Properties.html#load(java.io.Reader)
[INI]: http://en.wikipedia.org/wiki/INI_file
[JSON]: http://json.org/
[YAML]: http://www.yaml.org/
[SafeConfigParser]: https://docs.python.org/2/library/configparser.html#ConfigParser.SafeConfigParser
[ConfigParser]: https://docs.python.org/3/library/configparser.html#configparser.ConfigParser
[PyYaml]: http://pyyaml.org/


### sync

The module provides functions for synchronization files and directories.
The main goal is delaying [events](#event), if source and destination files
are different.  That is why it does not use [rsync][] command.

**bb-sync-file** DST_FILE SRC_FILE [EVENT [ARGUMENTS...]] {: #bb-sync-file }
:   Synchronizes contents of `DST_FILE` with `SRC_FILE`.  If `DST_FILE` is changed
    it will [delay](#bb-event-delay) `EVENT` with `ARGUMENTS`.  Usage:

        :::bash
        bb-event-on restart-server "service nginx restart"

        bb-sync-file "/etc/nginx/sites-available/default" "my_site.conf" restart-server

    Each time `my_site.conf` is changed, the script above will update Nginx
    configuration and restart it.

**bb-sync-dir** DST_DIR SRC_DIR [EVENT [ARGUMENTS...]] {: #bb-sync-dir }
:   Synchronizes contents of `DST_DIR` with `SRC_DIR`.  If `DST_DIR` is changed
    it will [delay](#bb-event-delay) `EVENT` with `ARGUMENTS`.

**bb-sync-dir-one-way** DST_DIR SRC_DIR [EVENT [ARGUMENTS...]] {: #bb-sync-dir-one-way }
:   Peforms one-way synchronization of contents of `DST_DIR` with `SRC_DIR`.
    This means that all files in `SRC_DIR` will be replicated to `DST_DIR`, but
    files from `DST_DIR` that are not in `SRC_DIR` will not be removed.  If
    `DST_DIR` is changed it will [delay](#bb-event-delay) `EVENT` with `ARGUMENTS`.

[rsync]: http://rsync.samba.org/


### wait

**bb-wait** CONDITION [TIMEOUT]
:   Freezes scripts until `CONDITION` is evaluated as `true`, i.e. expression
    returns non-zero status code.  Example:

        :::bash
        LOG="$( bb-tmp-file )"
        start-some-server 2> "$LOG"
        bb-wait 'cat "$LOG" | grep "Server ready"'
        # Do something useful using that server

    If the optional `TIMEOUT` is not passed, the function will wait for
    `CONDITION` forever.  If `TIMEOUT` has been specified and reached during
    the command execution, it will logs error and return `1`.


### task

The module provides functions to define and run tasks.  Each task can define
its dependencies (other tasks), that will run within it.  Each task will be
executed only once within the call of [`bb-task-run`](#bb-task-run){: .code },
even if it is included by several tasks as dependency.  If any of task exits
with non-zero code (i.e. fails), [`bb-exit`](#bb-exit){: .code } function will
be called with the same code.

Example:

    :::bash
    bb-task-def 'install-build-tools'
    install-build-tools() {
        # ...
    }

    bb-task-def 'build-frontend'
    build-frontend() {
        bb-task-depends 'install-build-tools'
    }

    bb-task-def 'build-backend'
    build-backend() {
        bb-task-depends 'install-build-tools'
    }

    bb-task-def 'build-app'
    build-app() {
        bb-task-depends 'build-backend' 'build-frontend'
    }

    # The following code will execute tasks:
    # * install-build-tools (only once)
    # * build-backend
    # * build-frontend
    # * build-app
    bb-task-run 'build-app'

**bb-task-def** TASK_NAME [FUNC_NAME] {: #bb-task-def }
:   Defines task `TASK_NAME` as function `FUNC_NAME`.  If `FUNC_NAME` is omitted,
    `TASK_NAME` will be used instead.  Example:

        :::bash
        bb-task-def 'test' 'run-test-suite'
        run-test-suite() {
            # Function name differ from task name to avoid conflict with
            # built-in `test` function.
        }


**bb-task-depends** TASK [TASK...] {: #bb-task-depends }
:   Runs specified tasks within the current task.  This function can be called
    only within another task.

**bb-task-run**  TASK [TASK...] {: #bb-task-run }
:   Runs specified tasks.


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
        REPO='http://example.com/repo/ubuntu/'
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

    For each installed package an event `bb-package-installed` will be fired
    by [`bb-event-fire`](#bb-event-fire){: .code } with the package name as
    an argument.  So that you will be able to make some post installation actions.
    For instance, install [MySQL on Ubuntu without asking a password](http://stackoverflow.com/a/7740393/3182064):

        :::bash

        bb-event-on 'bb-package-installed' 'post-install'
        post-install() {
            local PACKAGE="$1"
            case "$PACKAGE" in
                "mysql-server")
                    # Setup MySQL root password
                    mysqladmin -u root password 'myRooT_pa$$w0rd'
                    ;;
            esac
        }
        # Do not ask for MySQL root password during installation
        export DEBIAN_FRONTEND=noninteractive
        bb-apt-install mysql-server

    If package is unable to be installed, script will be terminated with error,
    i.e. [`bb-exit`](#bb-exit){: .code } will be called.

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

    For each installed package an event `bb-package-installed` will be fired
    by [`bb-event-fire`](#bb-event-fire){: .code } with the package name as
    an argument.  So that you will be able to make some post installation actions.
    For instance, [setup PostgreSQL on CentOS](http://www.postgresql.org/download/linux/redhat/):

        :::bash

        bb-event-on 'bb-package-installed' 'post-install'
        post-install() {
            local PACKAGE="$1"
            case "$PACKAGE" in
                "postgresql-9.3")
                    chkconfig postgresql-9.3 on
                    service postgresql-9.3 initdb
                    service postgresql-9.3 start
                    ;;
            esac
        }
        bb-yum-install postgresql93-server

    If package is unable to be installed, script will be terminated with error,
    i.e. [`bb-exit`](#bb-exit){: .code } will be called.

[Yum]: http://yum.baseurl.org/


### brew

The module provides functions to work with [Homebrew][] package manager.

**bb-brew?** {: #bb-brew }
:   Checks if Homebrew is available. Usage:

        :::bash
        if bb-brew?
        then
            bb-brew-install somepackage
        fi

**bb-brew-repo?** REPOSITORY {: #bb-brew-repo }
:   Checks if `REPOSITORY` repository (tap in Homebrew terms) is installed.

**bb-brew-package?** PACKAGE {: #bb-brew-package }
:   Checks if `PACKAGE` is installed.

**bb-brew-update** {: #bb-brew-update }
:   Updates Homebrew cache.  It sets up variable `BB_BREW_UPDATED` to `true`.
    So the second call of this function does nothing.

**bb-brew-install** PACKAGE [PACKAGE...] {: #bb-brew-install }
:   Installs `PACKAGE` if it is not already installed.  It uses
    [`bb-brew-package?`](#bb-brew-package){: .code } for checking `PACKAGE`
    installation status, and [`bb-brew-update`](#bb-brew-update){: .code }
    for updating Homebrew cache before installation.

    For each installed package an event `bb-package-installed` will be fired
    by [`bb-event-fire`](#bb-event-fire){: .code } with the package name as
    an argument.  So that you will be able to make some post installation actions.

    If package is unable to be installed, script will be terminated with error,
    i.e. [`bb-exit`](#bb-exit){: .code } will be called.

[Homebrew]: http://brew.sh/


Task Runner
-----------

It is an experimental feature.  You can find `install.sh` script at `build`
directory of the sources or within distributive archive.  This script installs
Bash Booster to your system (should be run with root privileges, of course)
with task runner utility `bb-task`.

Usage is quite simple and is similar to [Make][] and other Make-like tools.
Place file `bb-tasks.sh` into your project directory with task definitions
(see [`task`](#task){: .code } module).  And run tasks using:

    :::bash
    $ bb-task task-name

This command will:

*   read Bash Booster configuration from `/etc/bashbooster/bbrc`,
    `~/.bbrc` (home directory), and `./.bbrc` (current directory);
*   initialize Bash Booster itself;
*   read your task definitions from `./bb-tasks.sh`;
*   run specified tasks.

See `examples/task-runner` at the sources for live demo.

[Make]: https://www.gnu.org/software/make/


Support & Feedback
------------------

Visit our [discussion group] if any support is required.  It is a good place
for proposals too.  And of course, any feedback will be highly appreciated,
either good and bad.

[discussion group]: https://groups.google.com/forum/#!forum/bash-booster


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

The code is licensed under the terms of GNU GPL version 3 license.
The full text of the license can be found at the root of the sources
or at [GNU website][].

[GNU website]: http://www.gnu.org/licenses/licenses.html
