mea_robot
=========

##Installation

1. clone on meabench top directory.

        $ cd [meabench dir]
        $ git clone git@github.com:maru-n/mea_robot.git robot


2. change configuration setting files

  Makefile.am

        line 20
        -  rawsrv spikesrv replay record \
        +  rawsrv spikesrv replay record robot\

  configure.in

        line 213
        +  robot/Makefile \

3. regenerate configuration files

        $ autoreconf -f

4. build

        $ ./configure
        $ make
