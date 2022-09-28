#!/system/bin/sh

echo "start:"
mount -o rw,remount /system
cp /data/libstlport.so /system/lib/
chmod 644 /system/lib/libstlport.so
chmod 777 /data/memtester /data/stressapptest /data/ddr_freq_scan.sh
pm install /data/fishingjoy1.apk
sync
echo "end:"
