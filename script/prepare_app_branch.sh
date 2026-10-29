#!/bin/bash
# run from anywhere: always operates on the directory this script lives in (vendor/kdiwin/apps/)
cd "$(dirname "$(readlink -f "$0")")" || exit 1

BRANCH="${1:-master}"

unset kd_apps
for kd_apps in $( find . -mindepth 1 -maxdepth 1 -type d -print )
do
    echo $kd_apps
    git -C $kd_apps checkout $BRANCH ;
    git -C $kd_apps branch --set-upstream-to=apps/$BRANCH $BRANCH 2> /dev/null ;
    git -C $kd_apps pull ;

    [ -f $kd_apps/.gitmodules ] || continue

    # sync url first, then update
    git -C $kd_apps submodule sync --recursive ;
    if ! git -C $kd_apps submodule update --init --recursive ; then
        # broken submodule (e.g. interrupted clone, HEAD has no commits): drop it and fetch again
        echo "!! repair submodule : $kd_apps"
        git -C $kd_apps submodule deinit -f --all ;
        rm -rf "$(git -C $kd_apps rev-parse --absolute-git-dir)/modules" ;
        git -C $kd_apps submodule sync --recursive ;
        git -C $kd_apps submodule update --init --recursive || echo "XX submodule update failed : $kd_apps"
    fi
done
