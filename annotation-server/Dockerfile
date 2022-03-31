FROM node:16

RUN apt-get update || : && apt-get install python -y
RUN apt-get install python3-pip -y

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json ./
COPY yarn.lock ./
COPY requirements.txt ./

RUN yarn
RUN pip3 install -r requirements.txt

# Bundle app source
COPY . .

RUN yarn build

ENV NODE_ENV production

CMD [ "yarn", "start:prod" ]
