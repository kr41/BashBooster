Changes
-------

### 0.1beta4

*   Added properties module


### 0.1beta3

*   When package is installed by function `bb-apt-install` or `bb-yum-install`,
    an event `bb-package-installed` will be fired with the package name as
    an argument.  So that you will be able to make some post installation
    actions.
*   If package is unable to be installed, `bb-apt-install` or `bb-yum-install`,
    will terminate script with error.


### 0.1beta2

*   Added ability to pass arguments to event handlers


### 0.1beta

*   Intial release
