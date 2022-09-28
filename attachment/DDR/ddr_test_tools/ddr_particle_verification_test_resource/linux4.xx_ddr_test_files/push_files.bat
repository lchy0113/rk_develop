@echo start push

set/p option1=当前机器固件操作系统位数 1:是32位, 2:是64位,请选择:

adb\adb.exe root
adb\adb.exe shell sleep 5
adb\adb.exe install fishingjoy1.apk

@echo push memtester
if "%option1%"=="1" (
adb\adb.exe push ../static_memtester/memtester_32bit /data/memtester
adb\adb.exe push ../static_stressapptest/stressapptest_32bit /data/stressapptest
)
if "%option1%"=="2" (
adb\adb.exe push ../static_memtester/memtester_64bit /data/memtester
adb\adb.exe push ../static_stressapptest/stressapptest_64bit /data/stressapptest
)
adb\adb.exe shell chmod 0777 /data/memtester
adb\adb.exe shell chmod 0777 /data/stressapptest

adb\adb.exe push ddr_freq_scan.sh /data/ddr_freq_scan.sh
adb\adb.exe shell chmod 0777 /data/ddr_freq_scan.sh

adb\adb.exe shell sync

@echo Important!
@echo Important! please check if have report error each item above
@echo Important!
PAUSE