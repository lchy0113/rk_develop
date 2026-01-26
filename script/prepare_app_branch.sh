#!/bin/bash
#cd vendor/kdiwin/apps/

BRANCH="${1:-master}"

unset kd_apps
for kd_apps in $( find . -maxdepth 1 -type d -print )
do
    echo $kd_apps
    git -C $kd_apps checkout $BRANCH ;
	git -C $kd_apps branch --set-upstream-to=apps/$BRANCH $BRANCH 2> /dev/null ;
    git -C $kd_apps pull ;
    git -C $kd_apps submodule init ;
    git -C $kd_apps submodule update --init --recursive --force;
    git -C $kd_apps submodule sync ;
done
