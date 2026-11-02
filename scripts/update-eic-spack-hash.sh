#!/usr/bin/env bash
# Pin eic-spack.sh to the head of the eic-spack develop branch, and keep a
# single pull request (branch ${BRANCH}) up to date with that bump.
#
# While a pull request is open, the branch is only ever added to (a merge of
# ${BASE_BRANCH} and/or a new bump commit) and pushed without --force, so that
# commits pushed to it by hand (e.g. matching package version updates) are
# preserved. The branch is only (re)created from ${BASE_BRANCH} when there is
# no open pull request for it.
#
# Intended to run from .github/workflows/update-eic-spack.yml, with GH_TOKEN
# set and the base branch checked out. Requires: gh, git, jq.
set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-master}"
BRANCH="${BRANCH:-automation/update-eic-spack}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-develop}"
PIN_FILE="eic-spack.sh"
MAX_LISTED=100
BOT_NAME="github-actions[bot]"
BOT_EMAIL="41898282+github-actions[bot]@users.noreply.github.com"

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

git fetch origin "${BASE_BRANCH}"
if git fetch origin "+refs/heads/${BRANCH}:refs/remotes/origin/${BRANCH}" 2>/dev/null; then
  branch_exists=true
else
  branch_exists=false
fi

# Commits on the update branch not authored by this bot (and not on the base).
manual_commits() {
  ${branch_exists} || return 0
  git log --format='%h %ae %s' "origin/${BASE_BRANCH}..origin/${BRANCH}" \
    | awk -v bot="${BOT_EMAIL}" '$2 != bot'
}

pr=$(existing_pr)

if [ "${OLD}" = "${NEW}" ]; then
  echo "Already up to date."
  if [ -n "${pr}" ]; then
    manual=$(manual_commits)
    if [ -n "${manual}" ]; then
      echo "Not closing PR #${pr}: branch ${BRANCH} has manually pushed commits:"
      echo "${manual}"
    else
      gh pr close "${pr}" --delete-branch \
        --comment "eic-spack pin on \`${BASE_BRANCH}\` is already at the head of \`${UPSTREAM_BRANCH}\`; closing."
    fi
  fi
  exit 0
fi

# Changelog (relative to the base branch, i.e. what the PR brings in) -------
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
While it is open, new bumps and merges of \`${BASE_BRANCH}\` are added on top of its branch
(never force-pushed), so manual commits pushed to it are preserved.
BODY
)
title="build(deps): bump eic-spack to ${NEW:0:7}"

# Branch --------------------------------------------------------------------
git config user.name "${BOT_NAME}"
git config user.email "${BOT_EMAIL}"

if [ -n "${pr}" ] && ${branch_exists}; then
  # Append-only: build on top of the existing branch.
  git checkout -B "${BRANCH}" "origin/${BRANCH}"
  if ! git merge-base --is-ancestor "origin/${BASE_BRANCH}" HEAD; then
    if git merge --no-edit "origin/${BASE_BRANCH}"; then
      echo "Merged ${BASE_BRANCH} into ${BRANCH}."
    elif [ "$(git diff --name-only --diff-filter=U)" = "${PIN_FILE}" ]; then
      # Only the pin conflicts; it is overwritten with ${NEW} below anyway.
      git checkout --theirs -- "${PIN_FILE}"
      git add "${PIN_FILE}"
      git commit --no-edit
      echo "Merged ${BASE_BRANCH} into ${BRANCH} (resolved ${PIN_FILE} conflict)."
    else
      git merge --abort
      echo "::warning::Merging ${BASE_BRANCH} into ${BRANCH} conflicts; leaving that to a human."
    fi
  fi
  push_args=()
else
  # No open PR: (re)start the branch from the base branch. A leftover branch
  # without an open PR (e.g. after merge or close) is replaced, but only if it
  # has not moved since it was fetched.
  git checkout -B "${BRANCH}" "origin/${BASE_BRANCH}"
  if ${branch_exists}; then
    push_args=("--force-with-lease=${BRANCH}:$(git rev-parse "origin/${BRANCH}")")
  else
    push_args=()
  fi
fi

sed -i "s/^EICSPACK_VERSION=.*/EICSPACK_VERSION=\"${NEW}\"/" "${PIN_FILE}"
git add "${PIN_FILE}"
if git diff --cached --quiet; then
  echo "Branch ${BRANCH} already pins ${NEW}."
else
  git commit -m "${title}" -m "Bumps ${REPO} from ${OLD} to ${NEW}."
fi

# Only push when the branch actually changes, so that CI is not needlessly
# re-triggered on nights when neither develop nor the base branch has moved.
if ${branch_exists} && [ "$(git rev-parse HEAD)" = "$(git rev-parse "origin/${BRANCH}")" ]; then
  echo "Branch ${BRANCH} is already up to date."
else
  git push "${push_args[@]}" origin "HEAD:refs/heads/${BRANCH}"
fi

# Pull request --------------------------------------------------------------
if [ -n "${pr}" ]; then
  gh pr edit "${pr}" --title "${title}" --body "${body}"
  echo "Updated PR #${pr}"
else
  gh pr create --base "${BASE_BRANCH}" --head "${BRANCH}" \
    --title "${title}" --body "${body}"
fi
