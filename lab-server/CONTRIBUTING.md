# Contributing

Please also see the [contribution guide in the root folder](../CONTRIBUTING.md).

## Prerequisites

- Install [<img src="https://user-images.githubusercontent.com/58258541/143049489-668aea70-bb2c-420d-b3e8-e0edc42a4e92.png" width="16" height="16"> Docker](https://docs.docker.com/get-docker/)
- Install [<img src="https://user-images.githubusercontent.com/58258541/143050266-4a2030d1-c319-447d-812b-2ad8a4020d48.png" width="16" height="16"> NodeJS](https://nodejs.org)
- Install [<img src="https://user-images.githubusercontent.com/58258541/143050227-b374b1f7-e28e-4b90-b7f0-b9112521d3b1.png" width="16" height="16"> Yarn](https://yarnpkg.com/)

## Setup for local development

- Create an `.env` file according to the the `.env.example`
- Open a terminal in VSCode in the `lab-server` directory
  - Run `docker compose up` to build and start the necessary containers (e.g. database)
- Open another terminal in VSCode in the `lab-server` directory
  - Run `yarn` to install the project dependencies
  - You can now start the server using `yarn start:dev`

## Local set-up for Keycloak (for debugging)

For local debugging set up your Keycloak by uncommenting the relevant part in the `docker-compose.yml`

### Keycloak set-up

- Open `http://localhost:28080` in your browser
- Open the administration console
- For username and password use the credentials from your `.env` file
- Follow [this](https://medium.com/devops-dudes/secure-nestjs-rest-api-with-keycloak-745ef32a2370) guide to set up your local Keycloak. A lot of the steps including the application configuration in NestJS are irrelevant.
  - The important steps are
    - Create a REALM
    - Create clients (one for the backend and one for the frontend)
      - For the backend the name should be "pharme-lab-server" and the "access-type" should be "bearer only" and under credentials you need to create a secret and copy-paste it into you `.env` file
      - For the frontend the name should be "pharme-app" and the "access-type" should be "public"
    - Create a user for testing (you can choose username and password freely, no roles are required)

To check all endpoints of your local Keycloak instance, send a GET request to (for example with Postman): `http://localhost:28080/auth/realms/pharme/.well-known/openid-configuration`

In order to check the administrative console, send a GET request to: `http://localhost:28080/auth/`

To receive authentication tokens, send a POST request to: `http://localhost:28080/auth/realms/pharme/protocol/openid-connect/token`
with body (x-www-form-unlencoded):

| Type | Value |
|---|---|
| grant_type | password |
| username | \<username-of-your-user\> |
| password | \<password-of-your-user\> |
| client_id | pharme-app |

To test the application, send a GET request to `http://localhost:3000` with the received bearer token as a header, you should receive "Hello World!" as an answer
