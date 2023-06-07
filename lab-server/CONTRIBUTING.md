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
- Create an `.env` file with required variables (see `.env.example`)

## Setup for local development

- Open a terminal in the `lab-server` directory
- Run `yarn` to install the project dependencies
- Start the server using `yarn start:dev` (uses `docker compose up -d`)
- To test the application, send a GET request to
  `http://localhost:3001/api/v1/health` in order to verify that the lab server
  is up and running
- Complete the [Keycloak setup (local)](#keycloak-setup-local) and
  [MinIO and test user setup (local)](#minio-and-test-user-setup-local)
- If everything was setup correctly you can (1) get an access token from
  Keycloak and (2) use this token to make a request to the lab server under the
  route `http://localhost:3001/api/v1/star-alleles`

### Keycloak setup (local)

- Open `http://localhost:28080` in your browser to access the keycloak admin
  console (or different port, if changed in `.env`; make sure to also adapt the
  port in `KEYCLOAK_AUTH_SERVER_URL` accordingly)
- Login using the credentials `KEYCLOAK_USER` and `KEYCLOAK_PASS`
  configured in the `.env` file
- Create a realm called `KEYCLOAK_REALM` (see `.env`)
- Create clients (one for the backend and one for the frontend)
  - For the backend with name `KEYCLOAK_CLIENT_ID` (see `.env`) and
    `access-type` "bearer only"; in the credentials tab create a secret and
    update the `.env` value `KEYCLOAK_SECRET` accordingly
  - For the frontend with the name `pharme-app` (as `clientId` in
    `app/lib/login/pages/cubit.dart`) and `access-type` "public";
    set the redirect URI to `*` (note that this is bad practice security-wise
    and should only be done in a local testing environment!)
- Create a user for testing (you can choose username and password freely, no
  roles are required); when setting the password, set "Temporary" to "OFF"
- For more information see
  [this guide](https://medium.com/devops-dudes/secure-nestjs-rest-api-with-keycloak-745ef32a2370)
  (the important steps are described above; most of the steps described in
  the guide, including the application configuration in NestJS, are
      irrelevant for this setup)

To check all endpoints of your local Keycloak instance, send a GET request to
(for example with Postman):
`http://localhost:28080/auth/realms/pharme/.well-known/openid-configuration`

In order to check the admin console, send a GET request to:
`http://localhost:28080/auth/`

To receive authentication tokens, send a POST request to:
`http://localhost:28080/auth/realms/pharme/protocol/openid-connect/token` with
the following body (x-www-form-urlencoded):

| Type       | Value                     |
| ---------- | ------------------------- |
| grant_type | password                  |
| username   | \<username-of-your-user\> |
| password   | \<password-of-your-user\> |
| client_id  | pharme-app                |

Please make sure that if using `localhost` to get the token, the host configured
in `.env` also needs to be `localhost`, not `127.0.0.1`. Otherwise, requesting
data with the will result in an `wrong ISS` error.

### MinIO and test user setup (local)

- Open `http://localhost:9001` (or different port, if changed in `.env`) in
  your browser
- Open the administration console. Login with the credentials `MINIO_ROOT_USER`
  and `MINIO_ROOT_PASSWORD` set in the `.env` file.
- Create a bucket called `alleles`
- Add an alleles file to the `alleles` bucket using the MinIO admin console
- Adapt the test user data in `seeder/users.json` (if not present, create based
  on `seeder/users.example.json`) to include a user with the `sub` of the
  Keycloak user created earlier; adapt the `allelesFile` name to the file name
  you uploaded
- Run the seeder with `yarn seed:run`

## Deployment

_Whole Docker compose setup is currently not working; unable to connect to the_
_database. Instead, run the following commands:_

- `docker compose up -d`
- `yarn install --frozen-lockfile`
- `yarn run build`
- `yarn run start:prod`

~From the project root, run~
~`docker compose --file lab-server/docker-compose.yml --profile production up`~
~to start all components.~

~_Note: removed the .env file from the Dockerfile to fix workflow; should set_~
~_variables in `docker-compose.yml` when attemting to fix this whole setup._~

~The API and other components will be available under the ports specified in~
~the `.env` file.~

~Make sure that all mentions of `localhost` (including `0.0.0.0` or~
~`127.0.0.1`) point to the respective service name in the~
~`docker-compose.yml`:~

- ~`localhost` in `KEYCLOAK_AUTH_SERVER_URL` to `keycloak`~
- ~`DB_HOST` to `lab-server-db`~
- ~`MINIO_ENDPOINT` to `minio`~
