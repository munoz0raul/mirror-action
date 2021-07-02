#!/usr/bin/env bash
set -e

if [[ "${DEBUG}" -eq "true" ]]; then
    set -x
fi

REMOTE=${INPUT_REMOTE:-"$*"}
GIT_ACCESS_TOKEN=${INPUT_GIT_ACCESS_TOKEN}
GIT_PUSH_ARGS=${INPUT_GIT_PUSH_ARGS:-"--tags --force"}
HAS_CHECKED_OUT="$(git rev-parse --is-inside-work-tree 2>/dev/null || /bin/true)"


if [[ "${HAS_CHECKED_OUT}" != "true" ]]; then
    echo "WARNING: repo not checked out; attempting checkout" > /dev/stderr
    echo "WARNING: this may result in missing commits in the remote mirror" > /dev/stderr
    echo "WARNING: this behavior is deprecated and will be removed in a future release" > /dev/stderr
    echo "WARNING: to remove this warning add the following to your yml job steps:" > /dev/stderr
    echo " - uses: actions/checkout@v1" > /dev/stderr
    if [[ "${SRC_REPO}" -eq "" ]]; then
        echo "WARNING: SRC_REPO env variable not defined" > /dev/stderr
        SRC_REPO="https://github.com/${GITHUB_REPOSITORY}.git" > /dev/stderr
        echo "Assuming source repo is ${SRC_REPO}" > /dev/stderr
     fi
    git init > /dev/null
    git remote add origin "${SRC_REPO}"
    git fetch --all > /dev/null 2>&1
fi

if [[ "${GIT_ACCESS_TOKEN}" != "" ]]; then
   # Add https header as per instructions on Foundries Documentation
   git config --global http.https://source.foundries.io.extraheader "Authorization: basic ${GIT_ACCESS_TOKEN}"
else
   echo "FATAL: You must specify a GIT_ACCESS_TOKEN in order to mirror this repo" > /dev/stderr
   exit 1
fi

git remote add mirror "${REMOTE}"
if [[ "${INPUT_PUSH_ALL_REFS}" != "false" ]]; then
    eval git push ${GIT_PUSH_ARGS} mirror "\"refs/remotes/origin/*:refs/heads/*\""
else
    if [[ "${HAS_CHECKED_OUT}" != "true" ]]; then
        echo "FATAL: You must upgrade to using actions inputs instead of args: to push a single branch" > /dev/stderr
        exit 1
    else
        eval git push -u ${GIT_PUSH_ARGS} mirror "${GITHUB_REF}"
    fi
fi
