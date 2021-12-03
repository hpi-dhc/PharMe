# Contributing

Please also see the [contribution guide in the root folder](../CONTRIBUTING.md).

## Prerequisites

- Install [<img src="https://user-images.githubusercontent.com/58258541/143049489-668aea70-bb2c-420d-b3e8-e0edc42a4e92.png" width="16" height="16"> Docker](https://docs.docker.com/get-docker/)
- Install [<img src="https://user-images.githubusercontent.com/58258541/143050266-4a2030d1-c319-447d-812b-2ad8a4020d48.png" width="16" height="16"> NodeJS](https://nodejs.org)
- Install [<img src="https://user-images.githubusercontent.com/58258541/143050227-b374b1f7-e28e-4b90-b7f0-b9112521d3b1.png" width="16" height="16"> Yarn](https://yarnpkg.com/)

## Setup for local development

- Open a terminal in VSCode in the `lab-server` directory
  - Run `docker build run -t lab-server .` to build the necessary image from `Dockerfile`
  - Run `docker run -p 8081:3000 -t lab-server` to start the server
