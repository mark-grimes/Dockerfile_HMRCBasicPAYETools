# HMRC Basic PAYE Tools in a docker container

**I am not affiliated to HMRC in any way. I have not developed this software. This is completely
unofficial.**

**I am not qualified to give tax advice. You are responsible for all your financial affairs.**

**You are responsible for persisting your data.**

## TL;DR
```
docker run --rm -d -v /some/directory/:/home/paye_user/HMRC markgrimes/payetools-rti
```
Will run an ephemeral container that saves all data to `/some/directory/` on your host system. If
you start the container again with that command it will read the previously saved data from that
directory.

## About
HMRC is the UK government's tax office. They provide software for reporting PAYE (Pay As You Earn)
employee income tax. All I've done is packaged it up in a docker container for easy use. HMRC provide
builds for Windows, Mac and Linux so you might prefer to just install directly on your system, see
[their instructions](https://www.gov.uk/basic-paye-tools) for instructions.

The Basic PAYE Tools are pretty basic, make sure this is what you want before using it. There are
plenty of other software packages you can use (free and paid). There is a link from the tools'
homepage (above) to other options.

## Using X11 in a docker container

The tools use a Qt interface over X11. To use this in a docker container you must have an X server
running on your host machine.

The container has `DISPLAY` set to `host.docker.internal:0` which should make the connection appear
as though it is coming from `localhost`.

### Mac OS X

Install XQuartz. Start it, go to Preferences->Security and make sure "Allow connections from network
clients" is checked.

By default all network clients are blocked, so you need to whitelist the ones you want. Open a terminal
and type `xhost +localhost` to allow connections from docker containers. You will have to do this
every time you start XQuartz.

### Linux

It's generally easier to just share the X11 socket directly into the container. When you start the
container add `-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix`.

### Windows

You need an X server, e.g. [Xming](http://www.straightrunning.com/XmingNotes/). I haven't connected
up to a docker container in a very long time, but I think it should be straight forward. Instructions
to come when I've tested it.

## Persisting your data

The container runs as the user `paye_user`, and saves data into the home directory of that user. This
means all data go will be saved in `/home/paye_user/HMRC`. It is a good idea to mount this to a host
directory or a docker volume so that your data will persist across containers. The software also has
import and export functions which you can use.
