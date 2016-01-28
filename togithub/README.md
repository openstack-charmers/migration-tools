# Github migration tools

## Overview

This part of the repo contains scripts to migrate bzr branches to git repositories on github.

## Setup

```
bzr branch lp:bzr-fastimport ~/.bazaar/plugins/fastimport
sudo apt-get install python-fastimport
```

## Grab bzr branches

```
./get-charms
```

## Migrate to git repositories

```
./import-charms
```

## Push to github.com

```
./push-charms
```
