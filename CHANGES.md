Changes
-------

### 0.4beta (2016-09-20)

*   Added `iptables` module (Erik Stephens)
*   Added `augeas` module (Jocelyn Le Sage)
*   Added some shortcuts to `assert` module (Jocelyn Le Sage)
*   Added support of `upgrade` comand to `apt` module (Jocelyn Le Sage)
*   Fixed and improved `sync` module (Jocelyn Le Sage)
*   Fixed `bb-event-delay` function (Jocelyn Le Sage)
*   Fixed `task` module


### 0.3beta (2015-03-07)

*   Added `task` module and task runner utility
*   Added `brew` module (Trevor Bekolay)
*   Added helper functions `bb-error?` and `bb-exit-on-error`
*   Updated `download` module to be more error-proof and flexible
*   Fixed `bb-template` function
*   Fixed cleanup process
*   Fixed behavior on shared workspace.  Several scripts can now use single
    workspace directory at the same time.


### 0.2beta (2014-10-11)

*   Changed license to GNU GPL version 3
*   Added `bb-log-deprecated` function to `log` module
*   Added `assert` module
*   Added `ext` module
*   Added `exe` module
*   Added `read` module
*   Added `wait` module
*   Marked `properites` module as deprecated in favor of `read` one
*   Rewrote unit tests


### 0.1beta5 (2014-10-10)

*   Fixed #3 OS X support (Mike Kolganov)
*   Fixed #1 Ubuntu 14.04 support


### 0.1beta4 (2014-09-08)

*   Added `properties` module (Denis Nelubin)


### 0.1beta3 (2014-08-20)

*   When package is installed by function `bb-apt-install` or `bb-yum-install`,
    an event `bb-package-installed` will be fired with the package name as
    an argument.  So that you will be able to make some post installation
    actions.
*   If package is unable to be installed, `bb-apt-install` or `bb-yum-install`,
    will terminate script with error.


### 0.1beta2 (2014-07-23)

*   Added ability to pass arguments to event handlers


### 0.1beta (2014-07-16)

*   Intial release
