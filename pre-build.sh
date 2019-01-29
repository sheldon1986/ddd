#!/bin/bash

LIST=`cat $1`

for list in ${LIST[*]}
       do
		git branch $list
		git checkout $list
		git pull origin master
		sed 's/developer/'$list'/g' ./ci/pipeline.yml > ./ci/$list.yml
		sed 's/developer/'$list'/g' ./ci/tasks/merge-stg-branch.sh > ./ci/tasks/$list.sh
		chmod 755 ./ci/tasks/$list.sh
		git add ./ci/tasks/$list*
		git commit -m "update"
		git push origin $list
		fly -t cc sp -p $list -c ./ci/$list.yml -l ./ci/credentials.yml -n
		fly -t cc up -p $list
done
