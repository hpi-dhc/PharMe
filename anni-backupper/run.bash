#!/bin/bash

ROOT_DIR=$(dirname $(realpath $0))

source $ROOT_DIR/.env

BACKUP_DIR=$ROOT_DIR/backups
test -d $BACKUP_DIR || git clone $GIT_REMOTE $BACKUP_DIR

curl -s $ANNI_URL/api/backup | jq '.data' > $BACKUP_DIR/backup.json

git -C $BACKUP_DIR add --all
git -C $BACKUP_DIR commit --message="$(date '+%y-%m-%d')"
git -C $BACKUP_DIR push
