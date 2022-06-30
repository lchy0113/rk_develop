# BUILD
Rockchip rk3567의 build.sh에 의해 생성된 파일은 아래와 같습니다. 

```bash
▾ Image-rk3568_r/
    baseparameter.img*
    boot-debug.img*
    boot.img*
    config.cfg*
    dtbo.img*
    MiniLoaderAll.bin*
    misc.img*
    parameter.txt*
    pcba_small_misc.img*
    pcba_whole_misc.img*
    recovery.img*
    resource.img*
    super.img*
    uboot.img*
    vbmeta.img*
```

- dtbo.img
```bash
BOARD_DTBO_IMG=$OUT/rebuild-dtbo.img
cp -a $BOARD_DTBO_IMG $IMAGE_PATH/dtbo.img

```
