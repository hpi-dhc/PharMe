# Note: this docker file is meant to be run from the project root as we need to
# add local modules You can build this image by running `docker build -t
# annotation-server -f ./annotation-server/Dockerfile .` from the project root.
FROM node:16

WORKDIR /usr/src/app

RUN apt-get update || : && apt-get install python -y
RUN apt-get install python3-pip -y

# Copy top-level package json (needed to register workspaces)
COPY ./package.json .
COPY ./yarn.lock .

# Copy common module
COPY ./common ./common

# Copy annotation server
COPY ./annotation-server ./annotation-server

# Install dependencies and build annotation server
RUN yarn
RUN pip3 install -r annotation-server/requirements.txt
RUN yarn workspace annotation-server run build

CMD [ "yarn", "workspace", "annotation-server", "run", "start:prod" ]
