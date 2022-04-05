# Note: this docker file is meant to be run from the project root as we need to
# add local modules You can build this image by running `docker build -t
# lab-server -f ./lab-server/Dockerfile .` from the project root.

FROM node:16

# Create app directory
WORKDIR /usr/src/app

# Copy top-level package json (needed to register workspaces)
COPY ./package.json .
COPY ./yarn.lock .

# Copy common module
COPY ./common ./common

# Copy lab server
COPY ./lab-server ./lab-server

# Install dependencies and build lab server
RUN yarn
RUN yarn workspace lab-server run build

CMD [ "yarn", "workspace", "lab-server", "run", "start:prod" ]
