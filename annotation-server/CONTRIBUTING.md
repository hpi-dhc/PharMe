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
- Within the `annotation-server` directory, create a file with the name `.env`
  according to the `.env.example`

## Preparing DrugBank data for deployment

Since DrugBank's XML is very big and has lots of data the Annotation Server
doesn't need, it can be minimized to preserve only necessary information to
decrease the memory footprint during data initialization.

Use `scripts/minimize-xml.py` to minimize the XML accordingly. Note that
DrugBank provides its data in zipped format, meaning it has to be unzipped
before using the script and re-zipped after.

## Setup for local development

- Make sure your `.env` and `test/.env` are configured correctly and up to date
  with the `.env.example` and `test/.env.example` files
- Open a terminal in the `annotation-server` directory
  - Run `yarn` to install the project's Node.js dependencies
  - Run `python3 -m pip install -r requirements.txt` to install
    the project's Python dependencies
    - If `python3` cannot be found, run
      `python -m pip install -r requirements.txt` instead
  - Optionally download DrugBank datasets from our Google Drive, place them in
    `data/` and adjust your `.env` accordingly
  - You can now start the server using `yarn start:dev`
- Initialize the database with the zipped data specified in `.env` by sending a
  POST-Request to `api/v1/init`
  (e.g. using `curl`: `curl -X POST http://localhost:3000/api/v1/init`)
