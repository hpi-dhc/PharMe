#!/bin/sh

ROOT_DIR=$(dirname $(realpath $0))

. $ROOT_DIR/.env

test -d $BACKUP_DIR || git clone https://oauth2:$GITHUB_OAUTH@github.com/hpi-dhc/PharMe-Data $BACKUP_DIR

curl -s $ANNI_URL/api/backup | jq '.data' > $BACKUP_DIR/backup.json

git -C $BACKUP_DIR add --all
git -C $BACKUP_DIR commit --message="Backup from $(date +%y-%m-%d) at $(date +%T) ($(date +%Z))"
git -C $BACKUP_DIR push
