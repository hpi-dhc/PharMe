# Contributing

> **Note:** every project (i.e., subdirectories) also contains additional contribution information relevant to the specific sub-project.

## Local setup

This repository contains a handy `bootstrap` script which will install all necessary dependencies for the various sub-projects, making the local setup as simple as executing one command. Before you begin though, make sure that you have the following tools installed:

- An editor, we **strongly recommend** [<img src="https://user-images.githubusercontent.com/82543715/142914400-49d5815b-71a7-4198-9501-157fc3aa40a2.png" width="16" height="16"> Visual Studio Code](https://code.visualstudio.com)
- [<img src="https://user-images.githubusercontent.com/82543715/142914382-5be71efd-9e34-46c2-aad6-04255c430594.png" width="16" height="16"> Git](https://git-scm.com/downloads)
- [<img src="https://user-images.githubusercontent.com/58258541/143049489-668aea70-bb2c-420d-b3e8-e0edc42a4e92.png" width="16" height="16"> Docker](https://docs.docker.com/get-docker/)
- [<img src="https://user-images.githubusercontent.com/58258541/143050266-4a2030d1-c319-447d-812b-2ad8a4020d48.png" width="16" height="16"> NodeJS](https://nodejs.org)
- [<img src="https://user-images.githubusercontent.com/58258541/143050227-b374b1f7-e28e-4b90-b7f0-b9112521d3b1.png" width="16" height="16"> Yarn](https://yarnpkg.com/)

After making sure that you have all the required dependencies take the following steps to setup your local environment:

1. Clone this repository by running `git clone https://github.com/hpi-dhc/PharMe.git` in your terminal
1. If you use VSCode, Open the workspace `./pharme.code-workspace` in VSCode
  - You'll probably see notifications asking you to install some extensions and get packages. Please confirm these two actions
1. From the root of the project, run `yarn bootstrap`. This will do the following:
    - Setup Husky project-wide in order to enforce the [conventional-commit](https://www.conventionalcommits.org/en/v1.0.0/) style

## Selecting an issue

Visit the [issues page](https://github.com/hpi-dhc/PharMe/issues) and look for an interesting problem you want to solve.

Once you have selected an issue to work on, assign yourself to that issue so we don't end up with two people doing the same thing.

## Working on stuff

> **Note:** This project enforces a [conventional commit style](https://www.conventionalcommits.org/en/v1.0.0/). We highly encourage you to familiarize yourself with this format of commit messaging in order to result in more readable, meaningful commit messages (not only for tools such as auto-changelog-generators, but also your fellow contributors!)

To avoid conflicts with other contributors, create a new branch and switch to that branch. You could name your branch according to this pattern: `issue/<id>-<lowercase-issue-title-with-dashes>` (e.g., `issue/3-contribution-guide`).

Work on your code. Repeat:

- Implement your changes
- Commit your changes
- Push to the repo

## Debugging

If you wish to debug the annotation server, lab server or the app, simply go to the 'Run and Debug' section of the vscode activity bar (Ctrl+Shift+D),
select the project you would like to debug and hit the green play button.

## It's working!

When you're done, file a pull request. We will take a look at your code and once all checks pass, your code can get merged 🥳
