const core = require('@actions/core');
const github = require('@actions/github');

try {
  const users = core.getInput('users');
  if (!users) {
    throw new Error('Could not find a list of users');
  }

  console.log(users);

  core.setOutput('telegram', users[0].telegram);
  console.log(`Hello ${users[0].telegram}!`);
} catch (error) {
  core.setFailed(error.message);
}
