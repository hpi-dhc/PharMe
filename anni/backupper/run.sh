#!/bin/sh

ROOT_DIR=$(dirname $(realpath $0))

. $ROOT_DIR/.env

git config user.email $GITHUB_USER_EMAIL
git config user.name $GITHUB_USER_NAME

test -d $BACKUP_DIR \
    || git clone https://oauth2:$GITHUB_OAUTH@$GITHUB_URL $BACKUP_DIR

cd $BACKUP_DIR

curl -s $ANNI_URL/api/backup | jq -r '.data.base64' | base64 -D > backup.zip
unzip backup.zip
rm backup.zip

git add --all
git commit --message="Backup from $(date +%y-%m-%d) at $(date +%T) ($(date +%Z))" \
    && git push
