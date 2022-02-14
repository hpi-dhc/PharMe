const core = require('@actions/core');
const github = require('@actions/github');
const moment = require('moment');

async function run() {
  try {
    // Get input
    const GITHUB_TOKEN = core.getInput('GITHUB_TOKEN');
    const USERS_INPUT = core.getInput('users', { required: true });
    const ISSUE_NUMBER = core.getInput('issue-number', { required: true });

    // Select user
    const users = JSON.parse(USERS_INPUT);
    const selectedUser = users[moment().week() % users.length];

    // Assign user to issue
    const octokit = github.getOctokit(GITHUB_TOKEN);
    await octokit.rest.issues.addAssignees({
      repo: github.context.repo.repo,
      owner: github.context.repo.owner,
      issue_number: ISSUE_NUMBER,
      assignees: [selectedUser.github],
    });

    // Set output
    core.setOutput('telegram', selectedUser.telegram);
  } catch (error) {
    core.setFailed(error.message);
  }
}
run();
