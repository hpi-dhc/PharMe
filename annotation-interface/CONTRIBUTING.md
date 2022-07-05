# Contributing

Please also see the [contribution guide in the root folder](../CONTRIBUTING.md).

## Prerequisites

- Install [<img
  src="https://user-images.githubusercontent.com/58258541/143049489-668aea70-bb2c-420d-b3e8-e0edc42a4e92.png"
  width="16" height="16"> Docker](https://docs.docker.com/get-docker/)
- Install [<img
  src="https://user-images.githubusercontent.com/58258541/143050266-4a2030d1-c319-447d-812b-2ad8a4020d48.png"
  width="16" height="16"> NodeJS](https://nodejs.org)
- Install [<img
  src="https://user-images.githubusercontent.com/58258541/143050227-b374b1f7-e28e-4b90-b7f0-b9112521d3b1.png"
  width="16" height="16"> Yarn](https://yarnpkg.com/)
- Within this directory, create a file with the name `.env` according to the
  `.env.example`

## Setup for local development

- Set up and start our [Annotation Server](../annotation-server/CONTRIBUTING.md)
- Start the database by running `docker compose up` in this directory
- Start the development server with `yarn dev`
- You can now access the annotation interface app on `localhost:3001`

If you have all prerequisites (Annotation Server & Interface) met and use
[kitty](https://sw.kovidgoyal.net/kitty/), you can conveniently run the
[annotation-dev](../.kitty/annotation-dev) script from this repository's root to
start both the Annotation Server and Interface along with both databases in
split windows.
