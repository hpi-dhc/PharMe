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

## Setup for local development

- Create an `.env` file according to the the `.env.example`
- Open a terminal in VSCode in the `lab-server` directory
  - Run `docker compose up` to build and start the necessary containers (e.g.
    database)
- Open another terminal in VSCode in the `lab-server` directory
  - Run `yarn` to install the project dependencies
  - You can now start the server using `yarn start:dev`

## Local set-up for Keycloak / Minio (for debugging)

For local debugging pass the "local" profile flag when running docker-compose
by using the following command: `docker compose --profile local up`

### Keycloak set-up (local)

- Open `http://localhost:28080` in your browser to access the keycloak admin
  console. Login using the credentials from your `.env` file
- Follow
  [this](https://medium.com/devops-dudes/secure-nestjs-rest-api-with-keycloak-745ef32a2370)
  guide to set up your local Keycloak. A lot of the steps including the
  application configuration in NestJS are irrelevant.
  - The important steps are
    - Create a REALM called `pharme`
    - Create clients (one for the backend and one for the frontend)
      - For the backend the name should be "pharme-lab-server" and the
        "access-type" should be "bearer only". In the credentials tab you need
        to create a secret and update the value `KEYCLOAK_SECRET` accordingly
      - For the frontend the name should be "pharme-app". The "access-type"
        should be set to "public" and the redirect URI should be `*`. Note that
        this is bad practice security-wise and should only be done in a local
        testing environment!
    - Create a user for testing (you can choose username and password freely, no
      roles are required)
      - When setting the password (User > Credentials), set "Temporary" to "OFF"

To check all endpoints of your local Keycloak instance, send a GET request to
(for example with Postman):
`http://localhost:28080/auth/realms/pharme/.well-known/openid-configuration`

In order to check the admin console, send a GET request to:
`http://localhost:28080/auth/`

To receive authentication tokens, send a POST request to:
`http://localhost:28080/auth/realms/pharme/protocol/openid-connect/token` with
the following body (x-www-form-urlencoded):

| Type       | Value                     |
|------------|---------------------------|
| grant_type | password                  |
| username   | \<username-of-your-user\> |
| password   | \<password-of-your-user\> |
| client_id  | pharme-app                |

To test the application, send a GET request to
`http://localhost:3000/api/v1/health` in order to verify that the lab server is
up and running. You should now be able to make an authentication request to
Keycloak and use the returned access token to make requests to the lab server.

### MinIO set-up (local)

- Open `http://localhost:9001` in your browser
- Open the administration console. Login with the credentials you have set in
  the `.env` file.
- Create a bucket called `alleles`
- Adapt the seeder to insert a `user` entry with the test user's UUID (look for
  the file `user.seeder.ts` in the lab server). This UUID can be found in the
  keycloak admin console under the "users" menu on the left.
- Add the corresponding alleles file to the `alleles` bucket using the minio
  admin console. Make sure that it is named the same as in the seeder config.

If everything was setup correctly you can now get an access token from Keycloak
and then use this token to make a request to the lab server under the route
`/api/v1/star-alleles`.

**OPTIONAL**: if you would like to add custom styling to the lab-server's
swagger api documentation (`/api/v1`) you can create a bucket with the name
supplied after the last '/' in the environment variable `ASSETS_URL` (for
example, in the example env-file this would be `pharme-assets`). Simply place
an image and css filed named `favicon.png` and `styles.css` respectively into
the bucket and the styling should be picked up by the lab-server.
