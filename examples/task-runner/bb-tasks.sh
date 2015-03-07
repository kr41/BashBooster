bb-task-def 'install'
install() {
    if [[ ! -d "venv" ]]
    then
        virtualenv venv
    fi
    venv/bin/python setup.py develop
}

bb-task-def 'reinstall'
reinstall() {
    rm -rf venv
    bb-task-depends 'install'
}

bb-task-def 'serve'
serve() {
    bb-task-depends 'install'
    venv/bin/pserve --reload config.ini
}
