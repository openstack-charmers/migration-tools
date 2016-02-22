# Github migration tools

## Overview

This part of the repo contains scripts to migrate git repositories to bzr branches on launchpad.

## Setup

```
bzr branch lp:bzr-fastimport ~/.bazaar/plugins/fastimport
sudo apt-get install python-fastimport
```

## Grab git repositories

```
./get-charms
```

## Migrate to bzr branches

```
./import-charms
```

## Push to launchpad

```
./push-charms
```

## Or, just do it all
```
./tobzr.sh
```
