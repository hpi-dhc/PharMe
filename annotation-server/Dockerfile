# Note: this Dockerfile is meant to be run from the project root as we need to
# add local modules which are outside of the context of the `annotation-server`
# directory. You can build this image by running `docker build -t annotation-server -f
# ./annotation-server/Dockerfile .` from the project root.

ARG BASE_IMAGE=node:16

FROM ${BASE_IMAGE} AS builder

WORKDIR /app

COPY . .
RUN yarn install
RUN yarn workspace annotation-server run build

FROM ${BASE_IMAGE}-alpine

WORKDIR /app

COPY ./package.json .
COPY ./yarn.lock .

COPY ./annotation-server/package.json ./annotation-server/package.json
COPY ./annotation-server/yarn.lock ./annotation-server/yarn.lock
RUN yarn workspace annotation-server --production=true --frozen-lockfile install && yarn cache clean
COPY --from=builder /app/annotation-server/dist ./annotation-server/dist

CMD [ "yarn", "workspace", "annotation-server", "run", "start:prod" ]
