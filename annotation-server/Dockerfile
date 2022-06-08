# Note: this Dockerfile is meant to be run from the project root as we need to
# add local modules which are outside of the context of the `annotation-server`
# directory. You can build this image by running `docker build -t annotation-server -f
# ./annotation-server/Dockerfile .` from the project root.

ARG BASE_IMAGE=node:16

FROM ${BASE_IMAGE} AS builder

WORKDIR /app

COPY . .
RUN yarn install --frozen-lockfile
RUN yarn workspace annotation-server run build

FROM ${BASE_IMAGE}-alpine as runner

RUN apk add --no-cache python3 py3-pip

# mounting directory in docker-compose needs to match WORKDIR
WORKDIR /app

COPY ./package.json ./yarn.lock ./

COPY ./annotation-server/requirements.txt ./annotation-server/requirements.txt
RUN pip3 install -r annotation-server/requirements.txt
COPY ./annotation-server/package.json ./annotation-server/package.json
RUN yarn workspace annotation-server --production=true --frozen-lockfile install && yarn cache clean
COPY --from=builder /app/annotation-server/dist ./annotation-server/dist

CMD [ "yarn", "workspace", "annotation-server", "run", "start:prod" ]
