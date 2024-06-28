# REGMAP

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


