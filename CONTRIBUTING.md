# Contributing

> **Note:** every project (i.e., subdirectories) also contains additional
> contribution information relevant to the specific sub-project.

## Local setup

Before you begin with setting up your local development environment, ensure that
you have the following list of tools installed:

- An editor, we **strongly recommend** [<img
  alt="vscode-logo"
  src="https://user-images.githubusercontent.com/82543715/142914400-49d5815b-71a7-4198-9501-157fc3aa40a2.png"
  width="16" height="16"> Visual Studio Code](https://code.visualstudio.com)
- [<img
  alt="git-logo"
  src="https://user-images.githubusercontent.com/82543715/142914382-5be71efd-9e34-46c2-aad6-04255c430594.png"
  width="16" height="16"> Git](https://git-scm.com/downloads)
- [<img
  alt="docker-logo"
  src="https://user-images.githubusercontent.com/58258541/143049489-668aea70-bb2c-420d-b3e8-e0edc42a4e92.png"
  width="16" height="16"> Docker](https://docs.docker.com/get-docker/)
- [<img
  alt="nodejs-logo"
  src="https://user-images.githubusercontent.com/58258541/143050266-4a2030d1-c319-447d-812b-2ad8a4020d48.png"
  width="16" height="16"> NodeJS](https://nodejs.org)
- [<img
  alt="yarn-logo"
  src="https://user-images.githubusercontent.com/58258541/143050227-b374b1f7-e28e-4b90-b7f0-b9112521d3b1.png"
  width="16" height="16"> Yarn](https://yarnpkg.com/)

After making sure that you have all the required dependencies take the following
steps to setup your local environment:

1. Clone this repository by running `git clone
   git@github.com:hpi-dhc/PharMe.git` or `git clone
   https://github.com/hpi-dhc/PharMe.git` in your terminal
2. If you use VSCode, Open the workspace `./pharme.code-workspace` in VSCode.
You can find this workspace in the project root.
    > **Note:** You will most likely be prompted by VSCode to install some
    > extensions and get packages. Please confirm these two actions.
3. From the root of the project, run `yarn bootstrap` in order to set up
pre-commit linting via Husky. This is used primarily to enforce the
[conventional-commit](https://www.conventionalcommits.org/en/v1.0.0/) style

## Selecting an issue

Visit the [issues page](https://github.com/hpi-dhc/PharMe/issues) and look for
an interesting problem you want to solve.

Once you have selected an issue to work on, assign yourself to that issue so we
don't end up with two people doing the same thing.

## Working on stuff

> **Note:** This project enforces a [conventional commit
> style](https://www.conventionalcommits.org/en/v1.0.0/). We highly encourage
> you to familiarize yourself with this format of commit messaging in order to
> result in more readable, meaningful commit messages (not only for tools such
> as auto-changelog-generators, but also your fellow contributors!)

To avoid conflicts with other contributors, create a new branch and switch to
that branch. You could name your branch according to this pattern:
`issue/<id>-<lowercase-issue-title-with-dashes>` (e.g.,
`issue/3-contribution-guide`).

Work on your code. Repeat:

- Implement your changes
- Commit your changes
- Push to the repo

## Debugging

If you wish to debug, simply go to the 'Run and Debug' section of the vscode
activity bar (Ctrl+Shift+D), select the project you would like to debug and hit
the green play button.

## It's working

When you're done, file a pull request. We will take a look at your code and once
all checks pass, your code can get merged 🥳

## Dual remote repository setup

This repository exists in two versions: (1) the public version on
[GitHub](https://github.com/hpi-dhc/PharMe), and (2) a private ("study")
version that is being specifically adapted for a study involving PharMe on a
[privately hosted GitHub](https://github.mountsinai.org/HPIMS/pharme_project)
at Icahn School of Medicine at Mount Sinai.

The study version should always extend the public version (i.e., changes affecting
both versions should be made in the public repository and merged to the Sinai
repository). This process currently needs to be done manually.

To be able to manage changes accross versions, we keep both remotes in one
local repository. To support multipe users for the different remote repositories,
we use [`git-worktree`](https://git-scm.com/docs/git-worktree).
To setup the two remotes with `git-worktree` run the following commands:

- In your PharMe repository, add the Sinai remote:
  `git remote add sinai https://github.mountsinai.org/HPIMS/pharme_project`
- Fetch from the new remote: `git fetch sinai`
- Checkout the Sinai main branch as a working tree:
  `git worktree add --track -b Sinai-PharMe ../Sinai-PharMe sinai/main`
- Change directories to the newly created working tree: `cd ../Sinai-PharMe`
- Enable different Git configurations per worktree:
  `git config extensions.worktreeConfig true`
- Configure the Git user to match the Sinai GitHub credentials
  - `git config --worktree user.name "YOUR-USERNAME"`
  - `git config --worktree user.email "YOUR.MAIL@mssm.edu"`
- Configure the push behavior to be able to push directly to a differently named
  upstream branch: `git config --worktree push.default upstream`
