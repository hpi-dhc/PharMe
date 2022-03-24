const exec = require('@actions/exec');
const { pathExists, readJson } = require('fs-extra');

const isUndefined = (element) => element?.pct === undefined;
const files = [
  'coverage-branches.svg',
  'coverage-functions.svg',
  'coverage-jest coverage.svg',
  'coverage-lines.svg',
  'coverage-statements.svg',
];

export const isJestCoverageReportAvailable = async (jestSummaryPath) => {
  const coverageExists = await pathExists(jestSummaryPath);
  if (!coverageExists) return false;

  const data = await readJson(jestSummaryPath);
  if (!data || !data.total) return false;

  if (
    isUndefined(data.total.branches) ||
    isUndefined(data.total.functions) ||
    isUndefined(data.total.lines) ||
    isUndefined(data.total.statements)
  ) {
    return false;
  }

  return true;
};

export const doBadgesExist = async (badgeOutputDir) => {
  const exist = await Promise.all(
    files.map((file) => pathExists(`${badgeOutputDir}/${file}`))
  );

  return exist.every((el) => el === true);
};

export const hasCoverageEvolved = async (badgesExist, badgeOutputDir) => {
  if (!badgesExist) return true;

  const code = await exec.exec('git diff', ['--quiet', `${badgeOutputDir}/*`], {
    ignoreReturnCode: true,
  });

  const hasChanged = code === 1;
  return hasChanged;
};

export const moveBadges = async (badgeOutputDir) => {
  // Library outputs into badges, we want to move it to badgeOutputDir
  await exec.exec(`mkdir ${badgeOutputDir}`);
  files.forEach(async (file) => {
    await exec.exec(`mv "./badges/${file}" "${badgeOutputDir}/${file}"`);
  });
};

export const setGitConfig = async () => {
  await exec.exec('git config user.name github-actions[bot]');
  await exec.exec(
    'git config user.email github-actions[bot]@users.noreply.github.com'
  );
};

export const pushBadges = async (branchName, badgeOutputDir) => {
  await exec.exec(`git branch -m ${branchName}`);
  await exec.exec('git add', [badgeOutputDir]);
  // Discard all changes that were not just staged
  await exec.exec('git restore .');
  await exec.exec('git commit', ['-m', 'docs: updating coverage badges']);
  await exec.exec('git push');
};
