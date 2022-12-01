# AUDIO_CODEC

> AUDIO_CODEC 드라이버에 대한 문서.
>> AsahiKASEI 사 AK7755 를 레퍼런스 함.

 - block diagram
	![](images/AUDIO_CODEC_01.png)

 - Path and Sequence 
   * playback(digital to analog)
	   ![](images/AUDIO_CODEC_02.png)
	  + SDIN1 -> DSP -> DAC -> OUT1/OUT2


   * recoding(analog to digital)
	   ![](images/AUDIO_CODEC_03.png)
	  + IN1/IN3 -> ADC -> DSP -> SDOUT1


	
## Develop

### regmap
 regmap 메커니즘은 Linux 3.1 에 추가 된 새로운 기능입니다.
 주요 목적은 I/O 드라이버에서 반복적인 논리 코드를 줄이고 기본 하드웨어에서 레지스터를 작동 할 수 있는 범용 인터페이스를 제공하는 것 입니다.
 
 에를 들어 이전에 i2c 장치의 레지스터를 조작하려면 i2c_transfer 인터페이스를 호출해야 합니다. 
 spi 장치 인터페이스를 조작하려면 spi_write / spi_read 와 같은 인터페이스를 호출해야 합니다.
 regmap 구조체의 regmap_read / regmap_write 를 호출해 대신 사용가능합니다.

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
 디바이스 드라이버 초기화 시, device의 register 정보, bit length, address bit length, register bus 등을 정의합니다. 
 regmap을 초기화 하고 다른 bus에  해당하는 초기화 함수를 호출합니다.
 초기화가 완료된 후 regmap API를 호출하여 정상적으로 read  write 를 할수 있습니다.
 
 * interface 초기화

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
int regmap_write(struct regmap *map, unsigned int reg, unsigned int val);
int regmap_read(struct regmap *map, unsigned int reg, unsigned int *val);

```

 * 종료

```c
void regmap_exit(struct regmap *map);
```
