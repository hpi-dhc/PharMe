const core = require('@actions/core');
const {
  isJestCoverageReportAvailable,
  doBadgesExist,
  hasCoverageEvolved,
  moveBadges,
  setGitConfig,
  pushBadges,
} = require('./helpers');
const { generateBadges } = require('node-jest-badges');

async function run() {
  try {
    const jestSummaryPath = core.getInput('jest-summary-path', {
      required: true,
    });
    const badgeOutputDir = core.getInput('badge-output-dir', {
      required: true,
    });

    const isReportAvailable = await isJestCoverageReportAvailable(
      jestSummaryPath
    );
    if (!isReportAvailable) {
      return core.setFailed('⛔ Coverage report is missing');
    }

    const badgesExist = await doBadgesExist(badgeOutputDir);

    core.info('💡 Generating badges');
    await generateBadges();

    const hasEvolved = await hasCoverageEvolved(badgesExist);
    if (!hasEvolved) {
      return core.info('⚠️ Coverage has not evolved, no action required.');
    }

    core.info('💡 Pushing badges to the repo');
    await moveBadges(badgeOutputDir);

    core.info('💡 Pushing badges to the repo');
    await setGitConfig();
    await pushBadges(badgeOutputDir);

    core.info('👌 Done!');
  } catch (error) {
    if (error instanceof Error) {
      return core.setFailed(`⛔ An error occured: ${error.message}`);
    }

    return core.setFailed(`⛔ An unknown error occured`);
  }
}
run();
