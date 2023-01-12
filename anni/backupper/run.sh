#!/bin/sh

ROOT_DIR=$(dirname $(realpath $0))

. $ROOT_DIR/.env

test -d $BACKUP_DIR || git clone https://oauth2:$GITHUB_OAUTH@github.com/hpi-dhc/PharMe-Data $BACKUP_DIR

cd $BACKUP_DIR

curl -s $ANNI_URL/api/backup | jq '.data' > backup.json

git add --all
git commit --message="Backup from $(date +%y-%m-%d) at $(date +%T) ($(date +%Z))" \
    && git push
