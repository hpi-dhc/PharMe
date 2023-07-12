# Note: this Dockerfile is meant to be run from the project root as we need to
# add local modules which are outside of the context of the `lab-server`
# directory. You can build this image by running `docker build -t lab-server -f
# ./lab-server/Dockerfile .` from the project root.

ARG BASE_IMAGE=node:16

FROM ${BASE_IMAGE} AS builder

WORKDIR /app

COPY . .
RUN yarn install --frozen-lockfile
RUN yarn workspace lab-server run build

FROM ${BASE_IMAGE}-alpine as runner

WORKDIR /app

COPY ./package.json ./yarn.lock ./

COPY ./lab-server/package.json ./lab-server/package.json
COPY ./lab-server/.env ./lab-server/.env
RUN yarn workspace lab-server --production=true --frozen-lockfile install && yarn cache clean
COPY --from=builder /app/lab-server/dist ./lab-server/dist

CMD [ "yarn", "workspace", "lab-server", "run", "start:prod" ]
