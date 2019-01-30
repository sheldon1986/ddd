#
#cd out
#shopt -s dotglob
#mv -f ../repo/* ./
#git config --global user.email "${GIT_EMAIL}"
#git config --global user.name "${GIT_NAME}"
#git remote add -f dev-v0.08_peter ../dev-v0.08_peter
#git merge --no-edit dev-v0.08_peter/dev-v0.08_peter
#
#
#
#!/bin/bash
if [ "$DEBUG" = "true" ]; then
  set -x
fi

# repo-target: merge target
# repo: current branch
# out: output for push

git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_NAME}"

cd repo-stg
TARGET_BRANCH=$(git branch --contains | grep -v '('| sed 's/^\**[[:blank:]]*//g'| head -n 1)
echo "merge target branch:${TARGET_BRANCH}"
cd ..

cd out
shopt -s dotglob
rm -rf *
mv -f ../repo/* ./
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git remote add -f repo-stg ../repo-stg

CURRENT_BRANCH=$(git branch --contains | grep -v '('| sed 's/^\**[[:blank:]]*//g'| head -n 1)
echo "current branch:${CURRENT_BRANCH}"

MESSAGE="${MESSAGE:-[Concourse CI] Merge branch ${TARGET_BRANCH} into ${CURRENT_BRANCH}}"

if [ "${CI_SKIP}" = "true" ]; then
  MESSAGE="[ci skip]${MESSAGE}"
fi

if [ "${NO_FF}" = "true" ]; then
  MERGE_MODE="--no-ff"
else
  MERGE_MODE="--ff"
fi

echo "MESSAGE=${MESSAGE}"
echo "MERGE_MODE=${MERGE_MODE}"
git merge ${MERGE_MODE} "repo-stg/${TARGET_BRANCH}" -m "${MESSAGE}"
