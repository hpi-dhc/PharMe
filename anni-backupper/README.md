# Anni Backupper

This is a rudimentary solution for version control of Anni until it is
implemented natively there.

The container fetches a backup from Anni every 15 minutes and commits it to the
[PharMe-Data](https://github.com/hpi-dhc/PharMe-Data) repository.

## Setup

- Set up `.env` file
  - The Github OAUTH Token is required to allow pushing to the private backup
    repo. You can create it [here](https://github.com/settings/tokens/new); make
    sure to select the `repo` scope.
- Run `docker build -t anni-backupper .` in this directory to build the
  container
- Run `docker run anni-backupper` to run the container
  - In case you are trying things out locally on macOS with `--net=host`, note
    that you have to use `host.docker.internal` for your `.env` instead of
    `localhost`!
