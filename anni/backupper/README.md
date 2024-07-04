# Anni Backupper

This is the second degree of backups & version control for Anni to be used
alongside its own native version control.

The Backupper fetches a backup from Anni every 15 minutes and commits it to a
Git repository. This ensures that data can be restored even if Anni's database
is lost.

## Setup

- Set up `.env` file
  - The Github OAUTH Token is required to allow pushing to the private backup
    repo. You can create it [here](https://github.com/settings/tokens/new); make
    sure to select the `repo` scope.
  - If you want to deploy Anni in production with the Backupper, you can leave
    the other variables as given in the [`.env.example`](.env.example).

### Running only the Backupper container

- Run `docker build -t anni-backupper .` in this directory to build the
  image
- Run `docker run anni-backupper` to run the container
  - In case you are trying things out locally on macOS with `--net=host`, note
    that you have to use `host.docker.internal` for your `ANNI_URL` instead of
    `localhost`!

### Deploying with Backupper

To deploy Anni with the Backupper, first ensure you have all environment
variables set up. See [`.env.example`](.env.example) for help (Note that the
Backupper has its own environment file!). Then, run the following command from
the repository's root:

```sh
docker compose --file anni/docker-compose.yaml --profile production --profile with-backupper up -d
```
