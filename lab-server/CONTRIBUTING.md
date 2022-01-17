# Contributing

Please also see the [contribution guide in the root folder](../CONTRIBUTING.md).

## Prerequisites

- Install [<img src="https://user-images.githubusercontent.com/58258541/143049489-668aea70-bb2c-420d-b3e8-e0edc42a4e92.png" width="16" height="16"> Docker](https://docs.docker.com/get-docker/)
- Install [<img src="https://user-images.githubusercontent.com/58258541/143050266-4a2030d1-c319-447d-812b-2ad8a4020d48.png" width="16" height="16"> NodeJS](https://nodejs.org)
- Install [<img src="https://user-images.githubusercontent.com/58258541/143050227-b374b1f7-e28e-4b90-b7f0-b9112521d3b1.png" width="16" height="16"> Yarn](https://yarnpkg.com/)

## Setup for local development

- create an `.env` file according to the the `env.example`
- Open a terminal in VSCode in the `lab-server` directory
  - Run `docker compose up` to build and start the necessary containers (e.g. database and database for keycloak)
- Keyclaok set up
  - Go on `http://localhost:28080`
  - Open the administration console
  - For username and password use `admin` `admin`
  - Follow this guide to set up your local keycloak: https://medium.com/devops-dudes/secure-nestjs-rest-api-with-keycloak-745ef32a2370 (A lot of the steps including the application configuration in nest js are irrelevant)
    - The important steps are
      - create a `REALM`
      - create clients (one for the backend and one for the frontend)
        - for the backend the name should be `pharme-lab-server` and the `access-type` should be `bearer only` and under credentials you need to create a secret and copy-paste it into you `.env` file
        - for the frontend the name should be `pharme-app` and the `access-type` should be `public`
      - create a user for testing (you can pick up name and password, no roles are required)
- Open another terminal in VSCode in the `lab-server` directory
  - Run `yarn` to install the project dependencies
  - You can now start the server using `yarn start:dev`

To check all your endpoints of your keycloak client send a get request via Postman (or other application) to: `http://localhost:28080/auth/realms/pharme/.well-known/openid-configuration`

In order to check the administrative console send a GET request to `http://localhost:28080/auth/`

To receive a token send a POST request to: `http://localhost:28080/auth/realms/pharme/protocol/openid-connect/token`
with body (x-www-form-unlencoded):
| Type | Value |
|---|---|
| grant_type | password |
| username | \<username-of-your-user\> |
| password | \<password-of-your-user\> |
| client_id | pharme-app |

To test the application send a get Request to `http://localhost:3000` with the received bearer token as a header, you should receive **Hello World!** as an answer
