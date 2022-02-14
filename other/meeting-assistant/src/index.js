const core = require('@actions/core');
const github = require('@actions/github');
const moment = require('moment');

async function run() {
  try {
    // Get input
    const githubToken = core.getInput('token', { required: true });
    const usersInput = core.getInput('users', { required: true });
    const issueNumber = core.getInput('issue-number', { required: true });

    // Select user
    const users = JSON.parse(usersInput);
    const selectedUser = users[moment().week() % users.length];

    // Assign user to issue
    const octokit = github.getOctokit(githubToken);
    await octokit.rest.issues.addAssignees({
      repo: github.context.repo.repo,
      owner: github.context.repo.owner,
      issue_number: issueNumber,
      assignees: [selectedUser.github],
    });

    // Set output
    core.setOutput('telegram', selectedUser.telegram);
  } catch (error) {
    core.setFailed(error.message);
  }
}
run();
