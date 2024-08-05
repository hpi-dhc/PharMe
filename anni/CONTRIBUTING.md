# Contributing

Please also see the [contribution guide in the root folder](../CONTRIBUTING.md).

## Prerequisites

- Install [<img
  alt="docker-logo"
  src="https://user-images.githubusercontent.com/58258541/143049489-668aea70-bb2c-420d-b3e8-e0edc42a4e92.png"
  width="16" height="16"> Docker](https://docs.docker.com/get-docker/)
- Install [<img
  alt="node-logo"
  src="https://user-images.githubusercontent.com/58258541/143050266-4a2030d1-c319-447d-812b-2ad8a4020d48.png"
  width="16" height="16"> NodeJS](https://nodejs.org)
- Install [<img
  alt="yarn-logo"
  src="https://user-images.githubusercontent.com/58258541/143050227-b374b1f7-e28e-4b90-b7f0-b9112521d3b1.png"
  width="16" height="16"> Yarn](https://yarnpkg.com/)
- Within this directory, create a file with the name `.env` according to the
  [`.env.example`](.env.example)

## Setup for local development

- Start the database by running `docker compose up` in this directory
  - You can use `docker compose --profile dev up` if you want to start the
    testing database as well
- Start the development server with `yarn dev`
- You can now access the annotation interface app on `localhost:3002`

If you use [kitty](https://sw.kovidgoyal.net/kitty/), you can conveniently run
the [dev](/.kitty/dev) script from this directory to start the database (&
testing database), and the development server in split windows and open Anni in
your browser.

## Deploying

To deploy Anni, first ensure you have all environment variables set up. See
[`.env.example`](.env.example) for help. Then, run the following command from
the repo's root:

```sh
docker compose --file anni/docker-compose.yaml --profile production up -d
```

This will run Anni without the Backupper. To run the Backupper as well, see the
*Deploying with Backupper* section in its [README](backupper/README.md).

The `-d` option will start Docker compose in the background.
