#!/usr/bin/env bash

unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}" )"

source "$BASHBOOSTER"

#Mock
apt-get() {
    CMD="$1"

    case "$CMD" in
        upgrade)
            APT_UPGRADE_DONE=1
            ;;
        *)
            ;;
    esac
}

#Mock
apt-cache() {
    CMD="$1"
    PACKAGE="$2"

    bb-assert '[[ "$CMD" == "policy" ]]'

    echo "$APT_CACHE_POLICY_OUTPUT"
}

# Verify that an up-to-date package is reported correctly
APT_CACHE_POLICY_OUTPUT="bash:
  Installed: 4.3-7ubuntu1.5
  Candidate: 4.3-7ubuntu1.5
  Version table:
 *** 4.3-7ubuntu1.5 0
        500 http://archive.ubuntu.com/ubuntu/ trusty-updates/main amd64 Packages
        500 http://security.ubuntu.com/ubuntu/ trusty-security/main amd64 Packages
        100 /var/lib/dpkg/status
     4.3-6ubuntu1 0
        500 http://archive.ubuntu.com/ubuntu/ trusty/main amd64 Packages
"
bb-assert '! bb-apt-package-upgrade? "bash"'

# Verify that no upgrade is done on an up-to-date package
APT_UPGRADE_DONE=0
bb-apt-upgrade "bash"
bb-exit-on-error "Failed"
bb-assert '[[ "$APT_UPGRADE_DONE" -eq 0 ]]'

# Verify that an outdated package is reported correctly
APT_CACHE_POLICY_OUTPUT="python3.4:
  Installed: 3.4.0-2ubuntu1.1
  Candidate: 3.4.3-1ubuntu1~14.04.3
  Version table:
     3.4.3-1ubuntu1~14.04.3 0
        500 http://ca.archive.ubuntu.com/ubuntu/ trusty-updates/main amd64 Packages
 *** 3.4.0-2ubuntu1.1 0
        500 http://security.ubuntu.com/ubuntu/ trusty-security/main amd64 Packages
        100 /var/lib/dpkg/status
     3.4.0-2ubuntu1 0
        500 http://ca.archive.ubuntu.com/ubuntu/ trusty/main amd64 Packages
"
bb-assert 'bb-apt-package-upgrade? "python3.4"'

# Verify that upgrade is done on an outdated package
APT_UPGRADE_DONE=0
bb-apt-upgrade "python3.4"
bb-exit-on-error "Failed"
bb-assert '[[ "$APT_UPGRADE_DONE" -eq 1 ]]'

# Verify that an not installed package is reported correctly
APT_CACHE_POLICY_OUTPUT="exim4:
  Installed: (none)
  Candidate: 4.82-3ubuntu2
  Version table:
     4.82-3ubuntu2 0
        500 http://archive.ubuntu.com/ubuntu/ trusty/main amd64 Packages
"
bb-assert '! bb-apt-package-upgrade? "exim4"'

# Verify that upgrade is not done on an not installed package
APT_UPGRADE_DONE=0
bb-apt-upgrade "exim4"
bb-exit-on-error "Failed"
bb-assert '[[ "$APT_UPGRADE_DONE" -eq 0 ]]'

