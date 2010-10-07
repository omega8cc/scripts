#!/bin/bash

# Example duplicity backup script using Rackspace Cloud Files
#
# Written by Miguel Jacq October 2010
#
# miguel.jacq@gmail.com
# http://www.migueljacq.com

SERVER=`uname -n`

export CLOUDFILES_USERNAME=johndoe

export CLOUDFILES_APIKEY=123456789012345678901234567890

export PASSPHRASE=secretpassphrasetoencryptbackups

options="--full-if-older-than 1M --exclude-other-filesystems" 


DIRS=(
  bin
  boot
  etc
  home
  lib
  root
  sbin
  usr
)

for dir in ${DIRS[@]}; do
  # Name of the container
  CLOUD_CONTAINER=${SERVER}_$dir

  echo "Backing up /$dir..."

  # A special clause for /root. We don't want the local duplicity cache data
  if [ $dir = "root" ]; then
    extra_options="--exclude /root/.cache"
  fi

  # Do the backup
  duplicity $options $extra_options /$dir cf+http://${CLOUD_CONTAINER}

  unset extra_options

  # Do some maintenance on the remote end to clean up old backups
  post_options="remove-older-than 3M --force"
  duplicity $post_options cf+http://${CLOUD_CONTAINER}
done
