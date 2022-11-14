# AUDIO

-----
## 1. hardware

 * pin connected

| **pin**                   	| **name**      	| **connected**  	| **device** 	|
|---------------------------	|---------------	|----------------	|------------	|
| GPIO4_C3 (I2S3_SCLK_M1)     	| I2S_BCLK      	| BICK           	| -          	|
| GPIO4_C4 (I2S3_LRCK_M1)     	| I2S_LRCK      	| LRCK           	| -          	|
| GPIO4_C5 (I2S3_SDO_M1)     	| I2S_DAO       	| SDIN1/JX0      	| -           	|
| GPIO4_C6 (I2S3_SDI_M1)     	| I2S_DAI       	| SDOUT1/EEST    	| -          	|
| GPIO4_B2 (I2C4_SDA)       	| I2C_SDA_EC_DE 	| SO/SDA         	| -          	|
| GPIO4_B3 (I2C4_SCL)       	| I2C_SCL_EC_DE 	| SCLK/SCL       	| -          	|
| GPIO0_A6                   	| I2S_RESET     	| PDN            	| -          	|
| GPIO4_D1                  	| NMUTE_SPK     	| -              	| -          	|
| -                         	| -             	| IN1/NP1/DMDAT1 	| MIC        	|
| -                         	| -             	| OUT1           	| SPK        	|



-----


🖋 ***Note***

 * reference : RK3568_AIoT_REF_SCH
   - I2S1 : connected audio codec(rk809-5; PMIC+Codec)(I2S1, I2C0)
   - I2S3 : connected bt

   - boot log
```bash

[2022-11-11 12:08:08] [    2.430173] mali fde60000.gpu: l=-2147483648 h=2147483647 hyst=0 l_limit=0 h_limit=0 h_table=0
[2022-11-11 12:08:08] [    2.430175] rockchip-dmc dmc: failed to get vop pn to msch rl
[2022-11-11 12:08:08] [    2.430286] rockchip-dmc dmc: l=0 h=2147483647 hyst=5000 l_limit=0 h_limit=0 h_table=0
[2022-11-11 12:08:08] [    2.430340] rockchip-dmc dmc: could not find power_model node
[2022-11-11 12:08:08] [    2.430930] mali fde60000.gpu: Probed as mali0
[2022-11-11 12:08:08] [    2.441247] rk817-codec rk817-codec: rk817_probe: chip_name:0x80, chip_ver:0x94
[2022-11-11 12:08:08] [    2.446364] asoc-simple-card rk809-sound: rk817-hifi <-> fe410000.i2s mapping ok
[2022-11-11 12:08:08] [    2.448548] asoc-simple-card spdif-sound: dit-hifi <-> fe460000.spdif mapping ok
[2022-11-11 12:08:08] [    2.450110] rk-hdmi-sound hdmi-sound: i2s-hifi <-> fe400000.i2s mapping ok
[2022-11-11 12:08:08] [    2.453399] It doesn't contain Rogue gpu
[2022-11-11 12:08:08] [    2.454126] rockchip_headset rk-headset: Can not read property hook_gpio
[2022-11-11 12:08:08] [    2.454152] rockchip_headset rk-headset: have not set adc chan
[2022-11-11 12:08:08] [    2.454164] rockchip_headset rk-headset: headset have no hook mode
[2022-11-11 12:08:08] [    2.454353] input: rk-headset as /devices/platform/rk-headset/input/input5
[2022-11-11 12:08:08] [    2.454997] iommu: Adding device fde40000.npu to group 0
[2022-11-11 12:08:08] [    2.455022] RKNPU fde40000.npu: Linked as a consumer to fde4b000.iommu
[2022-11-11 12:08:08] [    2.455612] RKNPU fde40000.npu: RKNPU: rknpu iommu is enabled, using iommu mode
[2022-11-11 12:08:08] [    2.455767] RKNPU fde40000.npu: Linked as a consumer to regulator.20
[2022-11-11 12:08:08] [    2.455794] RKNPU fde40000.npu: can't request region for resource [mem 0xfde40000-0xfde4ffff]
[2022-11-11 12:08:08] [    2.456247] [drm] Initialized rknpu 0.4.2 20210701 for fde40000.npu on minor 1
[2022-11-11 12:08:08] [    2.456621] RKNPU fde40000.npu: leakage=5
[2022-11-11 12:08:08] [    2.456666] RKNPU fde40000.npu: pvtm = 92241, form pvtm_value
[2022-11-11 12:08:08] [    2.456682] RKNPU fde40000.npu: pvtm-volt-sel=2
[2022-11-11 12:08:08] [    2.457139] RKNPU fde40000.npu: avs=0
[2022-11-11 12:08:08] [    2.457738] RKNPU fde40000.npu: l=0 h=2147483647 hyst=5000 l_limit=0 h_limit=0 h_table=0
[2022-11-11 12:08:08] [    2.457771] RKNPU fde40000.npu: failed to find power_model node
[2022-11-11 12:08:08] [    2.457782] RKNPU fde40000.npu: RKNPU: failed to initialize power model
[2022-11-11 12:08:08] [    2.457792] RKNPU fde40000.npu: RKNPU: failed to get dynamic-coefficient
[2022-11-11 12:08:08] [    2.458407] cfg80211: Loading compiled-in X.509 certificates for regulatory database
[2022-11-11 12:08:08] [    2.459281] cfg80211: Loaded X.509 cert 'sforshee: 00b28ddf47aef9cea7'
[2022-11-11 12:08:08] [    2.460468] rockchip-pm rockchip-suspend: not set pwm-regulator-config
[2022-11-11 12:08:08] [    2.461206] I : [File] : drivers/gpu/arm/mali400/mali/linux/mali_kernel_linux.c; [Line] : 417; [Func] : mali_module_init(); svn_rev_string_from_arm of this mali_ko is '', rk_ko_ver is '5
', built at '02:33:24', on 'Nov 11 2022'.
[2022-11-11 12:08:08] [    2.461574] Mali:
[2022-11-11 12:08:08] [    2.461575] Mali device driver loaded
[2022-11-11 12:08:08] [    2.461598] rkisp rkisp-vir0: clear unready subdev num: 2
[2022-11-11 12:08:08] [    2.461839] platform regulatory.0: Direct firmware load for regulatory.db failed with error -2
[2022-11-11 12:08:08] [    2.461855] cfg80211: failed to load regulatory.db
[2022-11-11 12:08:08] [    2.462205] rkisp-vir0: Async subdev notifier completed
[2022-11-11 12:08:08] [    2.462442] ALSA device list:
[2022-11-11 12:08:08] [    2.462453]   #0: rockchip,rk809-codec
[2022-11-11 12:08:08] [    2.462462]   #1: ROCKCHIP,SPDIF
[2022-11-11 12:08:08] [    2.462470]   #2: rockchip,hdmi
[2022-11-11 12:08:08] [    2.463764] Freeing unused kernel memory: 1280K

```

 * asahi-kasei device in rk3568
   - [ ] ak4458  sound/soc/codecs/ak4458.c : playback only
   - [x] ak4613  sound/soc/codecs/ak4613.c : best(2nd)
   - [x] ak4642  sound/soc/codecs/ak4642.c : best(1st)
   - [ ] ak4554  sound/soc/codecs/ak4554.c : simple..
   - [ ] ak5386  sound/soc/codecs/ak5386.c : capture only
   - [ ] ak4104  sound/soc/codecs/ak4104.c : playback only 
   - [ ] ak5558  sound/soc/codecs/ak5558.c : capture only
