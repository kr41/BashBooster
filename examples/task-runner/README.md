This example demonstrates usage of task runner utility `bb-task`.  Run:

    $ vagrant up

It will prepare demo virtual machine, i.e.:

*   setup virtual machine with Ubuntu 14.04;
*   install [Mercurial][] source control management tool;
*   clone [TraversalKit example application][] into
    `/home/vagrant/Projects/TraversalKitExampleApp`;
*   place `bb-tasks.sh` file into the same directory.

After that execute:

    $ vagrant ssh
    $ cd Projects/TraversalKitExampleApp
    $ bb-task serve

And visit <http://localhost:6543> in your browser.
If you see "Welcome to TraversalKit!" page, everything went correct.
So, you can fiddle with `bb-tasks.sh` file to learn more about `bb-task` utility.

Note, TraversalKit example application is not a part of Bash Booster project,
it is independent project and is used here as an example only.

[Mercurial]: http://mercurial.selenic.com/
[TraversalKit example application]: https://bitbucket.org/kr41/traversalkitexampleapp
