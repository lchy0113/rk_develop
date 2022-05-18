# RK3568 Boot introduce

# packages 
## The Pre-bootloader(IDBLoader)
### IDBLoader 란 
IDBLoader.img는 SoC start up시 동작하며, 아래 기능을 포함하는 Rockchip 형식의 pre-loader 입니다.
 - Rockchip BootRom에 의해 알려진 IDBlock header.
 - MaskRom에 의해 load되고, 내부 SRAM에서 실행되는 DRAM 초기화 프로그램.
 - MaskRom에 의해 load되고, DRAM에서 다음 loader를 실행시킵니다.

아래 방법으로 IDBLoader를 얻을 수 있습니다. 

### Rockchip release loader에서 eMMC용 IDBLoader 패키징.
Rockchip release loader를 사용하는 경우, eMMC IDBLoader.img를 패키징할 필요가 없습니다. 아래 명령어를 사용하여 eMMC IDBLoader를 얻을 수 있습니다.
```bash
rkdeveloptool db rkxx_loader_vx.xx.bin
rkdeveloptool ul rkxx_loader_vx.xx.bin
```

### Rockchip binary 에서 IDBLoader.img를 패키징 합니다.
SD boot 또는 eMMC의 경우, IDBLoader가 필요 합니다. 
```bash
tools/mkimage -n rkxxxx -T rksd -d rkxx_ddr_vx.xx.bin idbloader.img
cat rkxx_miniloader_vx.xx.bin >> idbloader.img
```


### U-boot TPL/SPL(which is fully open source) 에서 IDBLoader.img를 패키징 합니다.
```bash
tools/mkimage -n rkxxxx -T rksd -d tpl/u-boot-tpl.bin idbloader.img
cat spl/u-boot-spl.bin >> idbloader.img
```
stage 2를 포함하여 offset 0x40으로 IDBLoader.img를 writing하면 u-boot.img 가 로드 됩니다.(stage 3)


