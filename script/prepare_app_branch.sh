#!/bin/bash
#cd vendor/kdiwin/apps/

unset kd_apps
unset branch_name
for kd_apps in $( find . -maxdepth 1 -name "wallpad-*" -print )
do
	echo $kd_apps
	cd $kd_apps
    branch_name=`git branch | head -1 | awk '{print $NF}'`
	cd -
	git -C $kd_apps checkout $branch_name;
	git -C $kd_apps branch --set-upstream-to=product/$branch_name $branch_name;
	git -C $kd_apps pull ; 
	git -C $kd_apps submodule init ; 
	git -C $kd_apps submodule update ; 
	git -C $kd_apps submodule sync ; 
done
