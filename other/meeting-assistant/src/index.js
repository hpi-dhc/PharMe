const core = require('@actions/core');
const moment = require('moment');

async function run() {
  try {
    // Get input
    const usersInput = core.getInput('users', { required: true });

    // Select user
    const users = JSON.parse(usersInput);
    const selectedUser = users[moment().week() % users.length];

    // Set output
    core.setOutput('telegram', selectedUser);
  } catch (error) {
    core.setFailed(error.message);
  }
}
run();
