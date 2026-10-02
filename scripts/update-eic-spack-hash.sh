#!/usr/bin/env bash
# Pin eic-spack.sh to the head of the eic-spack develop branch, and keep a
# single pull request (branch ${BRANCH}) up to date with that bump.
#
# Intended to run from .github/workflows/update-eic-spack.yml, with GH_TOKEN
# set and the base branch checked out. Requires: gh, git, jq.
set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-master}"
BRANCH="${BRANCH:-automation/update-eic-spack}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-develop}"
PIN_FILE="eic-spack.sh"
MAX_LISTED=100

# shellcheck source=/dev/null
source "${PIN_FILE}"
OLD="${EICSPACK_VERSION}"
REPO="${EICSPACK_ORGREPO}"
NEW=$(gh api "repos/${REPO}/commits/${UPSTREAM_BRANCH}" --jq .sha)
echo "eic-spack pin: ${OLD} -> ${NEW}"

existing_pr() {
  gh pr list --head "${BRANCH}" --base "${BASE_BRANCH}" --state open \
    --json number --jq '.[0].number // empty'
}

if [ "${OLD}" = "${NEW}" ]; then
  echo "Already up to date."
  pr=$(existing_pr)
  if [ -n "${pr}" ]; then
    gh pr close "${pr}" --delete-branch \
      --comment "eic-spack pin on \`${BASE_BRANCH}\` is already at the head of \`${UPSTREAM_BRANCH}\`; closing."
  fi
  exit 0
fi

# Changelog -----------------------------------------------------------------
compare=$(gh api "repos/${REPO}/compare/${OLD}...${NEW}")
total=$(jq .total_commits <<<"${compare}")
# Link PR/issue references to the upstream repository, not to this one.
changelog=$(jq -r --arg repo "${REPO}" --argjson max "${MAX_LISTED}" '
  .commits | reverse | .[:$max][] |
  "- [`\(.sha[0:7])`](\(.html_url)) " +
  ((.commit.message | split("\n")[0]) | gsub("#(?<n>[0-9]+)"; "\($repo)#\(.n)")) +
  " (\(.author.login // .commit.author.name))"
' <<<"${compare}")
if [ "${total}" -gt "${MAX_LISTED}" ]; then
  changelog+=$'\n'"- … and $((total - MAX_LISTED)) more, see the full comparison below."
fi

body=$(cat <<BODY
Bumps [${REPO}](https://github.com/${REPO}) from \`${OLD:0:7}\` to \`${NEW:0:7}\` (head of \`${UPSTREAM_BRANCH}\`).

<details>
<summary>Commits (${total})</summary>

${changelog}

</details>

Full comparison: https://github.com/${REPO}/compare/${OLD}...${NEW}

---

This pull request is maintained automatically by \`.github/workflows/update-eic-spack.yml\`.
It is rebuilt from \`${BASE_BRANCH}\` every night, so manual pushes to its branch will be overwritten.
BODY
)
title="build(deps): bump eic-spack to ${NEW:0:7}"

# Branch --------------------------------------------------------------------
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git checkout -B "${BRANCH}"
sed -i "s/^EICSPACK_VERSION=.*/EICSPACK_VERSION=\"${NEW}\"/" "${PIN_FILE}"
git add "${PIN_FILE}"
git commit -m "${title}" -m "Bumps ${REPO} from ${OLD} to ${NEW}."

# Only push when the branch content actually changes, so that CI is not
# needlessly re-triggered on nights when develop has not moved.
git fetch origin "${BRANCH}" 2>/dev/null || true
if git rev-parse --verify -q "origin/${BRANCH}" >/dev/null \
   && git diff --quiet HEAD "origin/${BRANCH}" \
   && [ "$(git rev-parse HEAD~)" = "$(git rev-parse "origin/${BRANCH}~")" ]; then
  echo "Branch ${BRANCH} already contains this update."
else
  git push --force origin "${BRANCH}"
fi

# Pull request --------------------------------------------------------------
pr=$(existing_pr)
if [ -n "${pr}" ]; then
  gh pr edit "${pr}" --title "${title}" --body "${body}"
  echo "Updated PR #${pr}"
else
  gh pr create --base "${BASE_BRANCH}" --head "${BRANCH}" \
    --title "${title}" --body "${body}"
fi
