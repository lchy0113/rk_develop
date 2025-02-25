#!/bin/bash
#cd vendor/kdiwin/apps/

unset kd_apps
for kd_apps in $( find . -maxdepth 1 -type d -print )
do
	echo $kd_apps
	git -C $kd_apps checkout master ; 
	git -C $kd_apps branch --set-upstream-to=apps/master master;
	git -C $kd_apps pull ; 
	git -C $kd_apps submodule init ; 
	git -C $kd_apps submodule update --init --recursive --force; 
	git -C $kd_apps submodule sync ; 
done
