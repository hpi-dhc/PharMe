FROM alpine:latest

RUN apk add --no-cache curl
RUN apk add --no-cache jq

RUN apk add --no-cache git

COPY ./run.sh /etc/periodic/15min/run-backupper.sh
RUN chmod +x /etc/periodic/15min/run-backupper.sh

COPY ./.env /etc/periodic/15min/.env

CMD crond -f -l 0 -d 0 -L /dev/stdout
