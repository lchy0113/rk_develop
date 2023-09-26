# AUDIO_CODEC

>  오디오 코덱 모듈(AK7755)을 개발하며 작성하는 문서

 - Linux Sound Subsystem Documentation : https://www.kernel.org/doc/html/latest/sound/index.html

> AUDIO_CODEC 드라이버에 대한 문서.
>> AsahiKASEI 사 AK7755 를 레퍼런스 함.

 - block diagram
	![](images/AUDIO_CODEC_01.png)

 - Path and Sequence 
   * playback(digital to analog)
	  + SDIN1 -> DSP -> DAC -> OUT1/OUT2
	   ![](images/AUDIO_CODEC_02.png)


   * recoding(analog to digital)
	  + IN1/IN3 -> ADC -> DSP -> SDOUT1
	   ![](images/AUDIO_CODEC_03.png)


<br />
<br />
<br />
<br />
<br />

-----

# AK7755

## Analysis

> datasheet 분석 

 - Control Register 설정.
   * power down(PDN pin = "L" -> "H") 이 release 되었을 때, Control Register 는 초기화 됨.
   * CONT00 ~ CONT01은 clock generation과 관련이있음. 
     + clock reset 시, (CKRESETN bit (CONT01:D0) = "0")으로 변경해야 함.
   * CONT12 ~ CONT19는 동작중에 write가능함. 
   * 그외 다른 register는 error 및 noise를 방지하기 위해 clock reset 또는 system reset(CRESETN bit(CONT0F:D3) 및 DSPRESETN bit(CONT0F:D2)="0") 중에 하나를 변경해야 함. 

   * 시스템 reset중에는 CONT0D:D6, CONT1A:D4, CONT26:D0, CONT2A:D7 bit 를 "1"로 설정해야 함.
     + 한번 "1"로 설정된 경우, power down이 발생되기 전까지, 값을 유지함. 
   * CONT1F ~ CONT25, CONT27 ~ CONT29, CONT2B ~ CONT3F register 는 write 하면 안됨.


![](./images/AUDIO_CODEC_07.png)


| Addr 	| Name                                                                  	| Value 	| Func                                                                                                                                                             	|
|------	|-----------------------------------------------------------------------	|-------	|------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| C0h  	| clock setting1, analog input setting                                  	| 0x3D  	| Slave, Main Clock(BICK), Analog Input Setting                                                                                                                    	|
| C1h  	| clock setting2, JX2 setting                                           	| 0x0E  	| JX2 is disabled, LRCK sampling frequency set by DFS[2:0] bits, BITFS mode(0) BICK(64fs), CLKO output clock select(XTI or BICk)                                   	|
| C2h  	| serial data format, JX1, JX0 setting                                  	| 0x10  	| TDM interface(no), BICK Edge(falling), LRCK I/F Format(I2S), DSPDIN3&DSPDIN4 Input Source Select(no), JX1(no), JX)(no)                                           	|
| C3h  	| delay ram, dsp input / output setting                                 	| 0x05  	| DSP DIN2 Input Format Select(MSB 24bit), DSP DOUT2 Output Format Select(MSB (24bit), DLRAM mode setting(5120words,3072words)                                     	|
| C4h  	| data ram, cram setting                                                	| 0x61  	| Data RAM Size Setting(1024:1024), Data RAM Addressing mode Setting(Ring:Linear), DLRAM Pointer(OFREG), CRAM Memory Assignment(65word)                            	|
| C5h  	| accelerator setting, JX3 setting                                      	| 0x03  	| Accelator Memory Select(1024:1024)                                                                                                                               	|
| C6h  	| DAC De-emphasis, DAC and DSP Input Format Settings                    	| 0x00  	| DAC De-emphasis Setting(OFF), DAC Input Format Select(MSB Justified(24-bit)), MSB (24-bit)                                                                       	|
| C7h  	| DSP output format setting                                             	| 0x00  	| DSP DOUT4 Output Format Select(MSB justified (24-bit)), DSP DOUT3 Format Select(MSB justified (24-bit)), DSP DOUT1 Output Format Select(MSB(24-bit))             	|
| C8h  	| DAC input, SDOUT2 Output, SDOUT3 Output, Digital Mixer Input Settings 	| 0xC4  	| DAC Input Select(SDIN1), SDOUT3 pin Output Select(DSP DOUT3), SDOUT2 pint Output Select(GP1), Digital Mixer Input Select(SDOUTAD Rch)                            	|
| C9h  	| analog input / output setting                                         	| 0x02  	| INL ADC Lch Analog Input(IN1), OUT3 Mixing Select 3(LIN off), OUT3 Mixing Select 2(DAC Rch on), OUT3 Mixing Select 1(DAC Lch off), Digital Mixer Input Select(0) 	|
| CAh  	| CLK and SDOUT output setting                                          	| 0x00  	| CLKO(Low), BICK(Low), LRCK(Low), OUT3E(Low), OUT2E(Low), OUT1E(Low)                                                                                              	|
| CEh  	| ADC, DAC Lineout Power Management                                     	| 0x05  	| Lineout1 Power(normal), DAC Lch(normal) when CODEC Reset (CRESETN bit = "1")                                                                                     	|
| CFh  	| Reset Settings Lineout and Digital MIC2 Rch Power Management          	| 0x00  	| CODEC Reset N(CODEC Reset)                                                                                                                                       	|

   - C1h_D0 (CKRESETN Clock Reset) : 0 인경우, Clock Reset 을 진행합니다. 1 인경우, Clock Reset 을 release 합니다.
   - CFh_D3 (CRESETN; CODEC Reset N) : CODEC 의미는 ADC, DAC입니다.
   - CFh_D2 (DSPRESETN; DSP Reset N) : CRESETN bit = "0"이고 DSPRESETN bit = "0" 인경우, system reset 상태가 됩니다.
   - CFh_D0 (DLRDY; DSP Download Ready field) : clock reset(CKRESETN bit = "0")인 경우나 main clock이 멈춘 경우, **DLRDY** (DSP Download Ready field)를 1로 세팅하여 DSP programs과 coefficient data를 다운로드 할 수 있습니다. 다운로드 완료 후, **DSP Download Ready field** 를 0 으로 재 세팅 해야 합니다.

 - Note:
 > - Master Mode (CKM mode 0, 1: using XTI Input Clock) : input clock를 BITFS[1:0] bits에 세팅된  XTI pin 으로 받는다.
 >   * XTI에 synchronized된 internal counter는 LRCK(1fs) 및 BICK(64fs, 48fs, 32fs, 256fs)를 생성합니다. BICK frequency 는  BITFS[1:0] bits에 의해 설정된다.   
 > - Slave Mode 2 (CKM mode 3: BICK Input Clock) : CKM mode 3에서 필요한 system clock 은 BICK, LRCK이다. 
 >   * 이 모드에서 BICK는 XTI대신에 사용된다.  
 >   * BICK 와 LRCK 는 동기화되어 제공되어야 함. 
 >   * BITFS[1:0] 비트로 LRCK에 대한 BICK clock을 설정. 
 >   * sampling rate 는 DFS[2:0] 베트로 설정. XTI pin을 open해 놓는다.  
 > - BICK fs Select(BITFS[1:0]) : BICK fs Select는 슬래이브 모드와 마스터 모드에서 동작되며,
 >   * 슬래이브 모드에서는  LRCK에 대한 BICK input sampling frequcncy 를 설정합니다. 
 >   * 마스터모드에서는 LRCK에 대한 BICK output sampling frequency를 설정.  


<br />
<br />
<br />
<br />
<br />

-----

# Develop


## sound card 

 - ALSA sound card 구성  
![](images/AUDIO_CODEC_06.png)
  
   * DAI : Digital Audio Interface
   * MACHINE : Link dai and codec to be a new sound card
   * DMAENGINE : Transfer data between memory and dai's fifo

 > 일반적으로 SDK를 기반으로하여 sound card를 추가하려면 codec driver를 작성만 하면되지만, 경우에 따라서 machine driver를 추가해야 하는 경우도 있다. 


## I2S

### master / slave

 - 설정  
   master / slave설정은 machine driver를 통해 dts를 파싱 한 후, set_fmt API를 호출하여 controler 의 protocol type을 설정한다.   


## Machine driver  

 - simple card는 ASoC용 공통으로 사용되는 Machine driver로 대부분의 표준 사운드 카드 추가를 지원한다.   
 
### dts

```dtb
ak7755_sound: ak7755-sound {
	status = "okay";
	compatible = "simple-audio-card";
	simple-audio-card,format = "i2s";			// protocol; i2s, right_j, left_j, dsp_a, dsp_b, pdm
	simple-audio-card,name = "rockchip,ak7755";
	simple-audio-card,mclk-fs = <256>;			// sampling rate; by default, mclk is 256 time

	simple-audio-card,cpu {
		sound-dai = <&i2s_2ch>;
	};

	simple-audio-card,codec {
		sound-dai = <&ak7755_codec>;
	};
};


```

## regmap
 regmap 메커니즘은 Linux 3.1 에 추가 된 새로운 기능.
 주요 목적은 I/O 드라이버에서 반복적인 논리 코드를 줄이고 기본 하드웨어에서 레지스터를 작동 할 수 있는 범용 인터페이스를 제공하는 것.
 
 에를 들어 이전에 i2c 장치의 레지스터를 조작하려면 i2c_transfer 인터페이스를 호출해야 한다. 
 spi 장치 인터페이스를 조작하려면 spi_write / spi_read 와 같은 인터페이스를 호출해야 한다.

 kernel 3.8 버전으로 오면서 regmap을 사용하도록 되어 있다.

 regmap 구조체의 regmap_read / regmap_write 를 호출해 대신 사용 가능.
 아래 함수를 통해 addr_bits, data_bits 를 정해준다.

 snd_soc_codec_set_cache_io의 3번째 매개변수를 통하여 다음과 같이 구분하여 regmap_init을 한다.
 (SND_SOC_REGMAP을 처음부터 하였다면 그전에 이미 register set이 REGMAP으로 등록되어 있어야 한다.
 ex. snd_soc_codec_set_cache_io(codec, 8, 16, SND_SOC_I2S))

```c
enum snd_soc_control_type {
	SND_SOC_I2C = 1,
	SND_SOC_SPI,
	SND_SOC_REGMAP,
};

int snd_soc_codec_set_cache_io(struct snd_soc_codec *codec, 
	int addr_bits, int data_bits, 
	enum snd_soc_control_type contol)


	codec->write = hw_write;
	codec->read = hw_read;


static int hw_write(struct snd_soc_codec *codec, unsigned int reg, unsigned int value)
{
	(...)
	return regmap_write(codec->control_data, reg, value);
}

static unsigned int hw_read(struct snd_soc_codec *codec, unsigned int reg)
{
	(...)
	ret = snd_soc_cache_read(codec, reg, &val);
}

```

### Implementing regmap
 regmap 은 Linux API로 **include/linux/regmap.h**을 통해 제공되며, **drivers/base/regmap**에 구현 되어 있다.  
 struct **regmap_config**와 struct **regmap** 이 중요함.
 
 - struct regmap_config  
 	device와 통신하기 위해 regmap sub-system에서 사용하는 device별 configuration structure이다.  
	driver code에 의해 정의되며 device의 register와 관련된 모든 정보를 포함한다.  
	중요한 필드에 대한 설명은 다음과 같다.  
		  
   * reg_bits : This is the number of bits in the registers of the device, e.g., in case of 1 byte registers it will be set to the value 8.
   * val_bits : This is the number of bits in the value that will be set in the device register.
   * writeable_reg : This is a user-defined function written in driver code which is called whenever a register is to be written. Whenever the driver calls the regmap sub-system to write to a register, this driver function is called; it will return ‘false’ if this register is not writeable and the write operation will return an error to the driver. This is a ‘per register’ write operation callback and is optional.
   * wr_table : If the driver does not provide the writeable_reg callback, then wr_table is checked by regmap before doing the write operation. If the register address lies in the range provided by the wr_table, then the write operation is performed. This is also optional, and the driver can omit its definition and can set it to NULL.
   * readable_reg : This is a user defined function written in driver code, which is called whenever a register is to be read. Whenever the driver calls the regmap sub-system to read a register, this driver function is called to ensure the register is readable. The driver function will return ‘false’ if this register is not readable and the read operation will return an error to the driver. This is a ‘per register’ read operation callback and is optional.
   * rd_table : If a driver does not provide a readable_reg callback, then the rd_table is checked by regmap before doing the read operation. If the register address lies in the range provided by rd_table, then the read operation is performed. This is also optional, and the driver can omit its definition and can set it to NULL
   * volatile_reg : This is a user defined function written in driver code, which is called whenever a register is written or read through the cache. Whenever a driver reads or writes a register through the regmap cache, this function is called first, and if it returns ‘false’ only then is the cache method used; else, the registers are written or read directly, since the register is volatile and caching is not to be used. This is a ‘per register’ operation callback and is optional.
   * volatile_table : If a driver does not provide a volatile_reg callback, then the volatile_table is checked by regmap to see if the register is volatile or not. If the register address lies in the range provided by the volatile_table then the cache operation is not used. This is also optional, and the driver can omit its definition and can set it to NULL.
   * lock : This is a user defined callback written in driver code, which is called before starting any read or write operation. The function should take a lock and return it. This is an optional function—if it is not provided, regmap will provide its own locking mechanism.
   * unlock : This is user defined callback written in driver code for unlocking the lock, which is created by the lock routine. This is optional and, if it’s not provided, will be replaced by the regmap internal locking mechanism.
   * lock_arg : This is the parameter that is passed to the lock and unlock callback routine.
   * fast_io : regmap internally uses mutex to lock and unlock, if a custom lock and unlock mechanism is not provided. If the driver wants regmap to use the spinlock, then fast_io should be set to ‘true’; else, regmap will use the mutex based lock.
   * max_register : Whenever any read or write operation is to be performed, regmap checks whether the register address is less than max_register first, and only if it is, is the operation performed. max_register is ignored if it is set to 0.
   * read_flag_mask : Normally, in SPI or I2C, a write or read will have the highest bit set in the top byte to differentiate write and read operations. This mask is set in the higher byte of the register value.
   * write_flag_mask : This mask is also set in the higher byte of the register value.

 **struct regmap_config** 구조는 초기화 중에 구성해야 하는 장치의 레지스터 구성 정보를 나타냅니다.

```c
struct regmap_config {
	const char *name;				/* regmap name, 장치에 여러 레지스터 영역이 있을 때 사용 */

	int reg_bits;					/* register 주소 bit, 필수 */
	int reg_stride;					/* register 주소 스테핑 */
	int pad_bits;					/* register 와 value 사이의 padding bit 수 */
	int val_bits;					/* register value 의 bit, 필수 */

	/* register status 를 판단하는데 사용(ex. read 가능 여부, write 가능 여부)
	bool (*writeable_reg)(struct device *dev, unsigned int reg);
	bool (*readable_reg)(struct device *dev, unsigned int reg);
	bool (*volatile_reg)(struct device *dev, unsigned int reg);	
	/**
	  * volatile_reg : cache를 통해 register 를 write 하거나 read 할때마다 호출됩니다.
	  * driver가 regmap cache를 통해 레지스터를 read 하거나 write 할때마다 이 함수가 먼저 호출되고, 
	  * 'false'를 반환하면 cache method가 사용 됩니다. 
	  * 'true'를 반환하면 register 가 휘발성이고 cache를 사용하지 않기 때문에 register를 read, write 합니다.
	  */
	bool (*precious_reg)(struct device *dev, unsigned int reg);
	bool (*readable_noinc_reg)(struct device *dev, unsigned int reg);

	bool disable_locking;
	regmap_lock lock;
	regmap_unlock unlock;
	void *lock_arg;

	/* read write register call back 함수 */
	int (*reg_read)(void *context, unsigned int reg, unsigned int *val);
	int (*reg_write)(void *context, unsigned int reg, unsigned int val);

	bool fast_io;

	unsigned int max_register;		/* 최대 레지스터 주소 */
	const struct regmap_access_table *wr_table;
	const struct regmap_access_table *rd_table;
	const struct regmap_access_table *volatile_table;
	const struct regmap_access_table *precious_table;
	const struct regmap_access_table *rd_noinc_table;
	const struct reg_default *reg_defaults;	/* 초기화 후 기본 레지스터 값 */
	unsigned int num_reg_defaults;	/* 기본 레지스터 갯수 */

	/** 
	  * regmap은 caching을 지원합니다. cache_type field에 따라서 cache system 사용 여부를 판단합니다. 
	  * REGCACHE_NONE : (default) cache 비활성화
	  * cache 저장 방법을 정의합니다.
	  * REGCACHE_RBTREE  
	  * REGCACHE_COMPORESSED  
	  * REGCACHE_FLAT 
	  */
	enum regcache_type cache_type;
	const void *reg_defaults_raw;
	unsigned int num_reg_defaults_raw;

	unsigned long read_flag_mask;
	unsigned long write_flag_mask;
	bool zero_flag_mask;

	bool use_single_rw;
	bool can_multi_write;

	/* register 와 값의 끝 */
	enum regmap_endian reg_format_endian;
	enum regmap_endian val_format_endian;

	const struct regmap_range_cfg *ranges;	/* 가상 주소 범위 */
	unsigned int num_ranges;

	bool use_hwlock;
	unsigned int hwlock_id;
	unsigned int hwlock_mode;
};
```

### regmap api 
 디바이스 드라이버 초기화 시, device의 register 정보, bit length, address bit length, register bus 등을 정의한다. 
 regmap을 초기화 하고 다른 bus에  해당하는 초기화 함수를 호출한다.
 초기화가 완료된 후 regmap API를 호출하여 정상적으로 read  write 를 할수 있다.
 
 * interface 초기화
 	regmap API 는 **include/linux/regmap.h**에 정의되어 있음.
	regmap 초기화 루틴에서 regmap_config 구성이 사용된다. 
	그런 다음 regmap structure가 할당되고 configuration이 복사된다.

	각 bus의 read/write function도 regmap structure에 복사된다.
  	예를 들어 SPI bus의 경우 regmap read 및 write function pointer는 SPI read 및 write function을 가리킨다.

	regmap 초기화 후 드라이버는 다음 루틴을 사용하여 device와 통신할 수 있다.

	- regmap_write 
		+ regmap_write takes the lock.
		+ check register length. 
		 	(if it is less **max_register**, then only the write operation is performed; else -EIO(invalid I/O) is return)
		+ **writeable_reg** callback 이 **regmap_config** 에 정의된 경우, callback function가 호출된다. 
			(if that callback returns 'true', then further operations are done; if it returns 'false', then an error -EIO is returned.)
		+ cache permitted 여부를 확인한다.
			= permitted 되는 경우, hardware에 직접 write 하는 대신, register value을 cache에 저장하고 이 단계에서 작업을 마친다.
			= permitted 되지 않는 경우, 다음 단계로 넘어간다.
		+ hardware register에 value을 write하기 위해 hardware write routine이 호출된 경우, write_flag_mask를 첫번째 byte에 write한 후, value를 device에  write한다.
		+ write 이 완료되면 lock을 해제 되고 함수 returen한다.

	- regmap_read

	- caching
    	+ chching은 device에 직접 operations을 수행하지 않도록 한다. 
		+ 대신 device와 driver간에 전송되는 값을 cache에 저장하고 참조하여 사용한다.
		+ 초창기에는 flat arrays 를 사용했으나, 32-bit address 에 적합하지 않아 더 나은 cache type으로 변경되었다.
  		  = rbtree stores blocks of contiguous registers in a red/black tree
		  = Compressed stores blocks of compressed data
		  Both rely on the existing kernel library:

		  ```c
		  enum regcache_type cache_type;
		  ```
	  
```c
//i2c
#define devm_regmap_init_i2c(i2c, config)        \
  __regmap_lockdep_wrapper(__devm_regmap_init_i2c, #config,  \
        i2c, config)
//spi       
#define devm_regmap_init_spi(dev, config)        \
  __regmap_lockdep_wrapper(__devm_regmap_init_spi, #config,  \
        dev, config)

```
 * read write interface
```c

int snd_soc_component_write(struct snd_soc_component *component, unsigned reg, unsigned int val)
|	// return: 0 on success, a negative error code otherwise.
|	// component->regmap
+->	int regmap_write(struct regmap *map, unsigned int reg, unsigned int val);
	|	// drivers/base/regmap/regmap.c
	+->	int _regmap_write(struct regmap *map, unsigned int reg, unsigned int val)
		|

int regmap_read(struct regmap *map, unsigned int reg, unsigned int *val);
```



 * 종료

```c
void regmap_exit(struct regmap *map);
```

 * regmap debug log 출력
```
diff --git a/drivers/base/regmap/regmap-debugfs.c b/drivers/base/regmap/regmap-debugfs.c
index de706734b921..cf9c59a81390 100644
--- a/drivers/base/regmap/regmap-debugfs.c
+++ b/drivers/base/regmap/regmap-debugfs.c
@@ -278,6 +278,7 @@ static ssize_t regmap_map_read_file(struct file *file, char __user *user_buf,
 }
 
 #undef REGMAP_ALLOW_WRITE_DEBUGFS
+#define REGMAP_ALLOW_WRITE_DEBUGFS
 #ifdef REGMAP_ALLOW_WRITE_DEBUGFS
 /*
  * This can be dangerous especially when we have clients such as
diff --git a/drivers/base/regmap/regmap.c b/drivers/base/regmap/regmap.c
index 330ab9c85d1b..5f73c7605b61 100644
--- a/drivers/base/regmap/regmap.c
+++ b/drivers/base/regmap/regmap.c
@@ -35,6 +35,7 @@
  * register I/O on a specific device.
  */
 #undef LOG_DEVICE
+#define LOG_DEVICE "4-0018"
 
 static int _regmap_update_bits(struct regmap *map, unsigned int reg,
                               unsigned int mask, unsigned int val,

```


 * ref
 https://www.opensourceforu.com/2017/01/regmap-reducing-redundancy-linux-code/

<br />
<br />
<br />
<br />
<br />

-----


## Reference code : RK817

> rockchip evboard codec


```c
static const struct snd_soc_component_driver soc_codec_dev_rk817 = {
	.probe = rk817_probe,
	(...)
};


static int rk817_probe(struct snd_soc_component *component)
{
	(...)
	snd_soc_add_component_controls(component, rk817_snd_path_controls,
					       ARRAY_SIZE(rk817_snd_path_controls));
}


static struct snd_kcontrol_new rk817_snd_path_controls[] = {
	SOC_ENUM_EXT("Playback Path", rk817_playback_path_type,
		rk817_playback_path_get, rk817_playback_path_put),
				 	
	SOC_ENUM_EXT("Capture MIC Path", rk817_capture_path_type,
		rk817_capture_path_get, rk817_capture_path_put),
};

/* For tiny alsa playback/capture/voice call path */
static const char * const rk817_playback_path_mode[] = {
	"OFF", "RCV", "SPK", "HP", "HP_NO_MIC", "BT", "SPK_HP", /* 0-6 */
	"RING_SPK", "RING_HP", "RING_HP_NO_MIC", "RING_SPK_HP"}; /* 7-10 */

static SOC_ENUM_SINGLE_DECL(rk817_playback_path_type,
	0, 0, rk817_playback_path_mode);

static int rk817_playback_path_get(struct snd_kcontrol *kcontrol,
				   struct snd_ctl_elem_value *ucontrol)
{
	struct snd_soc_component *component = snd_soc_kcontrol_component(kcontrol);
	struct rk817_codec_priv *rk817 = snd_soc_component_get_drvdata(component);

	DBG("%s : playback_path %ld\n", __func__, rk817->playback_path);

	ucontrol->value.integer.value[0] = rk817->playback_path;

	return 0;
}

static int rk817_playback_path_put(struct snd_kcontrol *kcontrol,
				   struct snd_ctl_elem_value *ucontrol)
{
	struct snd_soc_component *component = snd_soc_kcontrol_component(kcontrol);
	struct rk817_codec_priv *rk817 = snd_soc_component_get_drvdata(component);

	if (rk817->playback_path == ucontrol->value.integer.value[0]) {
		DBG("%s : playback_path is not changed!\n",
		    __func__);
		return 0;
	}

	return rk817_playback_path_config(component, rk817->playback_path,
					  ucontrol->value.integer.value[0]);
}

```
<br />
<br />
<br />
<br />
<br />

-----



# Memo

-----


 - ak7755 MUTE pin Low 상태에서 소리 출력  
 > MUTE pin 제어   
```bash
# pdn
# set high value to gpio0_a6
rk3568_poc:/ # io -4 -w 0xfdd60000 0x40C040

# set low value to gpio0_a6
rk3568_poc:/ # io -4 -w 0xfdd60000 0x40C000
```

```bash
# mute
# set high value to gpio4_d1
rk3568_poc:/ # io -4 -w 0xfe770004 0x2000200

# set low value to gpio4_d1
rk3568_poc:/ # io -4 -w 0xfe770004 0x2000000
```

-----


 - audio codec 드라이버 개발 업무 순서(절차).
  1. 디바이스 드라이버 소스를 제공하는지 부터 확인(중요)
  2. datasheet중 spec관련 내용과 pin map 부분 정독.  나머지는 필요할때 마다 꺼내보면 됨.
  3. main clock, 전원, reset pin 상태를 확인. 오디오 코덱은 이 세가지만 잘 인가되고 있으면 별 문제 없이 동작됨.
  4. data sheet에서 analog loop-back 모드를 확인하여 analog loop-back 모드로 설정하고 loop-back 기능이 잘 동작되면 코덱 자체(HW)는 잘 구성되어 있다고 판단됨. 

  그런 다음 아래 명령을 사용하여 record, play를 진행해본다.
  ```bash
	audio device file name : /dev/dsp
	record : cat /dev/dsp > raw.wav
	play : cat raw.wav > /dev/dsp
  ```
  여기 까지 했을때 record, play가 잘되면 디바이스 드라이버 단까지는 완료된 것으로 판단해도 됨.

  디바이스 드라이버 기능 동작까지는 잘 확인했으니, 한 이삼일동안 데이터 시트 보면서 오디오 코덱의 여러 기능들을 테스트 해 보는 시간을 가져야 한다.
  시간을 버리는 것처럼 보일 수 있지만 이번에 이런걸 해보아야 Application 개발자에게 전달할 때 Application을 쉽게 짤 수 있도록 여러 준비를 할 수 있는 토대를 마련할 수 있다.

  **꼭 기억. 플랫폼 개발자는 자기 개발건만 생각하면 안된다. H/W, S/W 엔지니어가 쉽게 개발을 할 수 있도록 항상 신경써 주면서 개발해야 한다.**

  이제 디바이스 드라이버단에 대한 개발은 완료되었으니 application 개발자를 위해 library를 만들어 주자.
  요즘은 디바이스 드라이버 단독으로 동작하는 경우는 거의 없고, ALSA나 OSS같은 프레임워크에 연동되도록 디바이스 드라이버를 작성하고 잇다.
  하지만  그렇다 하더라도 '네가 알아서 ALSA, OSS 프레임워크에 맞게 Application을 작성해라' 라고 하는 것은 능력 없는 플랫폼 개발자나 하는 행동이고 뛰어난 플랫폼 개발자는 Application 개발자가 API만 호출해서 쓸수 있도록 준비해 줘야 합니다.


-----
 
 - tinymix command 

 ```bash
 tinymix 'DSP Firmware PRAM' 'basic' ; tinymix 'DSP Firmware CRAM' 'basic' ;  tinymix 'LIN MUX' 'IN1' ; tinymix 'DSPIN SDOUTAD' On ; tinymix 'SDOUT1 MUX' DSP ; tinymix 'SDOUT1 Enable Switch'  1 ; tinymix 'DAC MUX' 'DSP' ; tinymix 'LineOut Amp1' On ; tinymix 'DAC Mute' 0 ; tinymix 'Line Out Volume 1' 15 ; tinymix 'Line Out Volume 2' 15; tinymix 'Line Out Volume 3' 15
 ```

 - dsp inout mixer setting  

   - [x] normal : IN1 -> SDOUT1, SDIN2 -> OUT1  
	   basic-basic
   - [ ] echo line :   


 - Data RAM, CRAM Setting
 	> Program RAM(PRAM), Coefficient RAM (CRAM)

	* Format 
	
	**Write Operation during System Reset**

	  + Program RAM (PRAM) Write (during system reset)
	
		| Field            	| Write data                                                       	|
		|------------------	|------------------------------------------------------------------	|
		| (1) COMMAND Code 	| 0xB8                                                             	|
		| (2) ADDRESS1     	| 0 0 0 0 0 0 0                                                    	|
		| (3) ADDRESS2     	| 0 0 0 0 0 0 0                                                    	|
		| (4) DATA1        	| 0 0 0 0 D35 D34 D33 D32                                          	|
		| (5) DATA2        	| D31 ~ D24                                                        	|
		| (6) DATA3        	| D23 ~ D16                                                        	|
		| (7) DATA4        	| D15 ~ D8                                                         	|
		| (8) DATA5        	| D7 ~ D0                                                          	|
		|                  	| Five bytes of data may be written continuously for each address. 	|

	  + Coefficient RAM (CRAM) Write (during system reset)

		| **Field**        	| **Write data**                                                  	|
		|------------------	|-----------------------------------------------------------------	|
		| (1) COMMAND Code 	| 0xB4                                                            	|
		| (2) ADDRESS1     	| 0 0 0 0 A10 A9 A8                                               	|
		| (3) ADDRESS2     	| A7 A6 A5 A4 A3 A2 A1 A0                                         	|
		| (4) DATA1        	| D23 ~ D16                                                       	|
		| (5) DATA2        	| D15 ~ D8                                                        	|
		| (6) DATA3        	| D7 ~ D0                                                         	|
		|                  	| Three bytes of data may be written continuosly for each address 	|

	  + Offset REG (OFREG) Write (during sytem reset)
	
		| **Field**        	| **Write data**                                                  	|
		|------------------	|-----------------------------------------------------------------	|
		| (1) COMMAND Code 	| 0xB2                                                            	|
		| (2) ADDRESS1     	| 0 0 0 0 0 0 0 0                                                 	|
		| (3) ADDRESS2     	| 0 0 A5 A4 A3 A2 A1 A0                                           	|
		| (4) DATA1        	| 0 0 0 0 0 0 0 0                                                 	|
		| (5) DATA2        	| 0 0 0 D12 D11 D10 D9 D8                                         	|
		| (6) DATA3        	| D7 ~ D0                                                         	|
		|                  	| Three bytes of data may be written continuosly for each address 	|
		
	  + Accelerator Coefficient RAM (ACCRAM) Write (during system reset)

		| **Field**        	| **Write data**                                                  	|
		|------------------	|-----------------------------------------------------------------	|
		| (1) COMMAND Code 	| 0xBB                                                            	|
		| (2) ADDRESS1     	| 0 0 0 0 0 A10 A9 A8                                             	|
		| (3) ADDRESS2     	| A7 A6 A5 A4 A3 A2 A1 A0                                         	|
		| (4) DATA1        	| D19 ~ D12                                                       	|
		| (5) DATA2        	| D11 ~ D4                                                        	|
		| (6) DATA3        	| D3 ~ D0 0 0 0 0                                                 	|
		|                  	| Three bytes of data may be written continuosly for each address 	|


-----
 
 - firmware file 경로 :

```
    * locate firmware file : 
	 /vendor/etc/firmware/

```


-----


 - Digital Mixer
    ADC output (SDOUTAD) ADC2 output (SDOUTAD2), DSP-DOUT4 의 데이터는 single serial data 으로 mixer circuit에 의해 mixed 될 수 있다. 
	SELMIX[2:0] bit를 통해 제어 됨.

	![](./images/AUDIO_CODEC_08.png);


-----

 - 하드웨어 핀 connected table

| **pin**             	| **name**             	| **AK7755**                 	| **connected** 	|
|---------------------	|----------------------	|----------------------------	|---------------	|
| GPIO4_C3 (I2S3)     	| I2S_BCLK             	| BICK(8)(I/O)               	| -             	|
| GPIO4_C4 (I2S3)     	| I2S_LRCK             	| LRCK(7)(I/O)               	| -             	|
| GPIO4_C5 (I2S3)     	| I2S_DAO              	| SDIN1/JX0(5)(Input)        	|               	|
| GPIO4_C6 (I2S3)     	| I2S_DAI              	| SDOUT1/EEST(16)(Output)    	| -             	|
| GPIO4_B2 (I2C4_SDA) 	| I2C_SDA_EC_DE        	| SO/SDA(17)(I/O)            	| -             	|
| GPIO4_B3 (I2C4_SCL) 	| I2C_SCL_EC_DE        	| SCLK/SCL(18)(I/O)          	| -             	|
| GPIO0_A6            	| I2S_RESET            	| PDN(22)(Input)             	| -             	|
| GPIO4_D1            	| NMUTE_SPK (0_unmute) 	| -                          	| -             	|
| -                   	| -                    	| CLKO(9)(Output)            	|               	|
| -                   	| -                    	| OUT2(26)(Output)           	| BACK_CALL_OUT 	|
| -                   	| -                    	| OUT3(27)(Output)           	| ECHO_LINE_OUT 	|
| -                   	| -                    	| OUT1(28)(Output)           	| SPK           	|
| -                   	| -                    	| IN4/INN2/DMCLK2(31)(I/O)   	| -             	|
| -                   	| -                    	| IN3/INP2/DMDAT2(32)(Input) 	| ECHO_LINE_IN  	|
| -                   	| -                    	| IN2/INN1/DMCLK1(33)(I/O)   	| -             	|
| -                   	| -                    	| IN1/INP1/DMDAT1(34)(Input) 	| MIC           	|


