 ALSA
=====

> ALSA 모듈에 대한 문서


# 1. DAPM 

-----

# 2. Kcontrol

## 2.1 Kcontrol 이란?

 - audio codec의 기능(register)을 user space application에서 제어할 수 있도록 ALSA kernel driver 에서 제공하는 인터페이스 중 핵심이 되는 중요 요소.

 user space application은 audio codec을 문자열을 통하여 제어한다. 

 ex>
```bash
Mixer name: 'rockchip,ak7755'
Number of controls: 76
ctl     type    num     name                                     value

0       INT     1       MIC Input Volume L                       0
1       INT     1       MIC Input Volume R                       0
2       INT     1       Line Out Volume 1                        15
3       INT     1       Line Out Volume 2                        15
4       INT     1       Line Out Volume 3                        15
5       ENUM    1       Line Input Volume                        0dB
6       INT     1       ADC Digital Volume L                     207
7       INT     1       ADC Digital Volume R                     207
8       INT     1       ADC2 Digital Volume L                    207
9       INT     1       ADC2 Digital Volume R                    207
10      INT     1       DAC Digital Volume L                     231
11      INT     1       DAC Digital Volume R                     231
12      BOOL    1       ADC Mute                                 Off
13      BOOL    1       ADC2 Mute                                Off
14      BOOL    1       DAC Mute                                 On
15      BOOL    1       Analog DRC Lch                           Off
16      BOOL    1       Analog DRC Rch                           Off
17      BOOL    1       MICGAIN Lch Zero-cross                   Off
18      BOOL    1       MICGAIN Rch Zero-cross                   Off
19      ENUM    1       DAC De-emphasis                          Off
20      BOOL    1       JX0 Enable                               Off
21      BOOL    1       JX1 Enable                               Off
22      BOOL    1       JX2 Enable                               Off
23      BOOL    1       JX3 Enable                               Off
24      ENUM    1       DLRAM Mode(Bank1:Bank0)                  0:8192
25      ENUM    1       DRAM Size(Bank1:Bank0)                   512:1536
26      ENUM    1       DRAM Addressing Mode(Bank1:Bank0)        Ring:Ring
27      ENUM    1       POMODE DLRAM Pointer 0                   DBUS Immediate
28      ENUM    1       CRAM Memory Assignment                   33 word
29      ENUM    1       FIRMODE1 Accelerator Ch1                 Adaptive Filter
30      ENUM    1       FIRMODE2 Accelerator Ch2                 Adaptive Filter
31      ENUM    1       SUBMODE1 Accelerator Ch1                 Fullband
32      ENUM    1       SUBMODE2 Accelerator Ch2                 Fullband
33      ENUM    1       Accelerator Memory(ch1:ch2)              2048:-
34      ENUM    1       CLKO pin                                 CLKO=L
35      ENUM    1       CLKO Output Clock                        XTI or BICK
36      ENUM    1       BICK fs                                  48fs
37      ENUM    1       DSP Firmware PRAM                        basic
38      ENUM    1       DSP Firmware CRAM                        basic
39      ENUM    1       DSP Firmware OFREG                       basic
40      ENUM    1       DSP Firmware ACRAM                       basic
41      ENUM    1       Set CRAM Address H                       00
42      ENUM    1       Set CRAM Address L                       00
43      ENUM    1       Set CRAM Data H                          00
44      ENUM    1       Set CRAM Data M                          00
45      ENUM    1       Set CRAM Data L                          00
46      INT     1       Read MIR                                 0
47      ENUM    1       CRAM EQ1 Level                           0dB
48      ENUM    1       CRAM EQ2 Level                           0dB
49      ENUM    1       CRAM EQ3 Level                           0dB
50      ENUM    1       CRAM EQ4 Level                           0dB
51      ENUM    1       CRAM EQ5 Level                           0dB
52      ENUM    1       CRAM HPF1 fc                             Off
53      ENUM    1       CRAM HPF2 fc                             Off
54      ENUM    1       CRAM Limiter Release Time                128ms
55      ENUM    1       CRAM Limiter Volume                      Off
56      ENUM    1       SELMIX2-0                                SDOUTAD
57      BOOL    1       LineOut Amp3 Mixer LOSW1                 Off
58      BOOL    1       LineOut Amp3 Mixer LOSW2                 Off
59      BOOL    1       LineOut Amp3 Mixer LOSW3                 Off
60      ENUM    1       LineOut Amp2                             Off
61      ENUM    1       LineOut Amp1                             Off
62      ENUM    1       RIN MUX                                  IN3
63      ENUM    1       LIN MUX                                  IN1
64      ENUM    1       DSPIN SDOUTAD2                           Off
65      ENUM    1       DSPIN SDOUTAD                            Off
66      BOOL    1       SDOUT3 Enable Switch                     Off
67      BOOL    1       SDOUT2 Enable Switch                     Off
68      BOOL    1       SDOUT1 Enable Switch                     Off
69      ENUM    1       SDOUT3 MUX                               DSP DOUT3
70      ENUM    1       SDOUT2 MUX                               DSP
71      ENUM    1       SDOUT1 MUX                               DSP
72      ENUM    1       DAC MUX                                  DSP
73      ENUM    1       SELMIX DSP                               Off
74      ENUM    1       SELMIX AD2                               Off
75      ENUM    1       SELMIX AD                                Off

rk3568_poc:/ # tinymix  35
CLKO Output Clock: 12.288MHz 6.144MHz 3.072MHz 8.192MHz 4.096MHz 2.048MHz 256fs >XTI or BICK
```
 - widget 이나 path 에 독립적인 kcontrol 도 있으며, widget과 path 와 깊이 연관된 kcontrol도 있다.

 - kcontrol 은 구조체 이름을 말하며 종류가 두가지 있다.
 > snd_kcontrol_new 구조체와 snd_kcontrol 구조체가 있다.
   * snd_kcontrol_new 구조체는 선언 및 kcontrol 등록 함수에 매개 변수로 사용되는 구조체.
   * snd_kcontrol 구조체는 운용되기 위해 사용되는 구조체.
   * snd_soc_add_controls 함수에서 snd_kcontrol_new 가 snd_kcontrol로 변환되어 등록 됨.


## 2.2 Kcontrol 구조체

 - snd_kcontrol_new 구조체와 snd_kcontrol 구조체. 

```c
struct snd_kcontrol_new {
	snd_ctl_elem_iface_t iface;	/* interface identifier */
	// kcontrol 의 interface 종류를 나타낸다. 명시적인 것이라 제어에 영향을 미치지 않는다
	unsigned int device;		/* device/client number */
	// 사용하지 않는다.(미확인)
	unsigned int subdevice;		/* subdevice (substream) number */
	// 사용하지 않는다.(미확인)
	const unsigned char *name;	/* ASCII name of item */
	// kcontrol 의 이름
	unsigned int index;		/* index of item */
	// 사용처 없음(확인 필요)
	unsigned int access;		/* access rights */
	// kcontrol 접근 권한에 대해 설정한다.(RW)
	unsigned int count;		/* count of same elements */
	// 사용처 없음 (확인 필요), 대부분 0 이기 때문에 1로 세팅 된다.
	snd_kcontrol_info_t *info;
	// User Space 에서 Kcontrol 에 대한 정보 요청시 수행 할 함수 포인터
	snd_kcontrol_get_t *get;
	// User Space 에서 Kcontrol 에 대한 현재 값 요청시 수행 할 함수 포인터
	snd_kcontrol_put_t *put;
	// User Space 에서 Kcontrol 에 대한 값 수정시 수행 할 함수 포인터
	union {
		snd_kcontrol_tlv_rw_t *c;
		// 사용처 없음 (확인 필요)
		const unsigned int *p;
		// 종류에 따라 soc_enum 구조체의 첫 주소나, dB 범위를 지정한 int 형 배열의 첫 주소가 들어 간다.
	} tlv;
	unsigned long private_value;
	// 대부분 soc_mixer_control 구조체의 첫 주소가 들어간다.
};

struct snd_kcontrol_volatile {
	struct snd_ctl_file *owner;	/* locked */
	unsigned int access;	/* access rights */
};

struct snd_kcontrol {
	struct list_head list;		/* list of controls */
	struct snd_ctl_elem_id id;
	unsigned int count;		/* count of same elements */
	snd_kcontrol_info_t *info;
	snd_kcontrol_get_t *get;
	snd_kcontrol_put_t *put;
	union {
		snd_kcontrol_tlv_rw_t *c;
		const unsigned int *p;
	} tlv;
	unsigned long private_value;
	void *private_data;
	void (*private_free)(struct snd_kcontrol *kcontrol);
	struct snd_kcontrol_volatile vd[0];	/* volatile data */
};
```

## 2.3 Kcontrol 선언

 - ALSA driver 에서는 kcontrol 을 쉽게 선언하기 위해서 MACRO를 제공한다.
	 MACRO를 통하여 snd_kcontrol_new을 생성한다.

```c
#define AK7755_C1_CLOCK_SETTING2			0xC1

static const char *ak7755_bank_select_texts[] = 
		{"0:8192", "1024:7168","2048:6144","3072:5120","4096:4096",
			"5120:3072","6144:2048","7168:1024","8192:0"};
static const char *ak7755_drms_select_texts[] = 
		{"512:1536", "1024:1024", "1536:512"};
static const char *ak7755_dram_select_texts[] = 
		{"Ring:Ring", "Ring:Linear", "Linear:Ring", "Linear:Linear"};
static const char *ak7755_pomode_select_texts[] = {"DBUS Immediate", "OFREG"};
static const char *ak7755_wavp_select_texts[] = 
		{"33 word", "65 word", "129 word", "257 word"};
static const char *ak7755_filmode1_select_texts[] = {"Adaptive Filter", "FIR Filter"};
static const char *ak7755_filmode2_select_texts[] = {"Adaptive Filter", "FIR Filter"};
static const char *ak7755_submode1_select_texts[] = {"Fullband", "Subband"};
static const char *ak7755_submode2_select_texts[] = {"Fullband", "Subband"};
static const char *ak7755_memdiv_select_texts[] = 
		{"2048:-", "1792:256", "1536:512", "1024:1024"};
static const char *ak7755_dem_select_texts[] = {"Off", "48kHz", "44.1kHz", "32kHz"};
static const char *ak7755_clkoe_select_texts[] = {"CLKO=L", "CLKO Out Enable"};
static const char *ak7755_clks_select_texts[] = 			// CLKO Output Clock
		{"12.288MHz", "6.144MHz", "3.072MHz", "8.192MHz",
			"4.096MHz", "2.048MHz", "256fs", "XTI or BICK"};

static const struct soc_enum ak7755_set_enum[] = {
	SOC_ENUM_SINGLE(AK7755_C3_DELAY_RAM_DSP_IO, 0,
			ARRAY_SIZE(ak7755_bank_select_texts), ak7755_bank_select_texts),
	SOC_ENUM_SINGLE(AK7755_C4_DATARAM_CRAM_SETTING, 6,
			ARRAY_SIZE(ak7755_drms_select_texts), ak7755_drms_select_texts),
	SOC_ENUM_SINGLE(AK7755_C4_DATARAM_CRAM_SETTING, 4,
			ARRAY_SIZE(ak7755_dram_select_texts), ak7755_dram_select_texts),
	SOC_ENUM_SINGLE(AK7755_C4_DATARAM_CRAM_SETTING, 3,
			ARRAY_SIZE(ak7755_pomode_select_texts), ak7755_pomode_select_texts),
	SOC_ENUM_SINGLE(AK7755_C4_DATARAM_CRAM_SETTING, 0,
			ARRAY_SIZE(ak7755_wavp_select_texts), ak7755_wavp_select_texts),
	SOC_ENUM_SINGLE(AK7755_C5_ACCELARETOR_SETTING, 5,
			ARRAY_SIZE(ak7755_filmode1_select_texts), ak7755_filmode1_select_texts),
	SOC_ENUM_SINGLE(AK7755_C5_ACCELARETOR_SETTING, 4,
			ARRAY_SIZE(ak7755_filmode2_select_texts), ak7755_filmode2_select_texts),
	SOC_ENUM_SINGLE(AK7755_C5_ACCELARETOR_SETTING, 3,
			ARRAY_SIZE(ak7755_submode1_select_texts), ak7755_submode1_select_texts),
	SOC_ENUM_SINGLE(AK7755_C5_ACCELARETOR_SETTING, 2,
			ARRAY_SIZE(ak7755_submode2_select_texts), ak7755_submode2_select_texts),
	SOC_ENUM_SINGLE(AK7755_C5_ACCELARETOR_SETTING, 0,
			ARRAY_SIZE(ak7755_memdiv_select_texts), ak7755_memdiv_select_texts),
	SOC_ENUM_SINGLE(AK7755_C6_DAC_DEM_SETTING, 6,
			ARRAY_SIZE(ak7755_dem_select_texts), ak7755_dem_select_texts),
	SOC_ENUM_SINGLE(AK7755_CA_CLK_SDOUT_SETTING, 7,
			ARRAY_SIZE(ak7755_clkoe_select_texts), ak7755_clkoe_select_texts),
	SOC_ENUM_SINGLE(AK7755_C1_CLOCK_SETTING2, 1,			// CLKO Output Clock
			ARRAY_SIZE(ak7755_clks_select_texts), ak7755_clks_select_texts),
};

#define SOC_ENUM(xname, xenum) \
{	.iface = SNDRV_CTL_ELEM_IFACE_MIXER, .name = xname,\
	.info = snd_soc_info_enum_double, \
	.get = snd_soc_get_enum_double, .put = snd_soc_put_enum_double, \
	.private_value = (unsigned long)&(struct soc_mixer_control)
									{
										.reg = reg_left, 
										.rreg = reg_right, 
										.shift = xshift,
										.max = xmax,
										.platform_max = xmax,
										.invert = xinvert
									}

static const struct snd_kcontrol_new ak7755_snd_controls[] = {
	(...)
	SOC_ENUM("CLKO Output Clock", ak7755_set_enum[12]), 
	(...)
}	

```

 - MACRO를 모두 해석하면 아래와 같은 snd_kcontrol_new 구조체가 나온다.

```c
static const struct snd_kcontrol_new ak7755_snd_controls[] = {
	.iface = SNDRV_CTL_ELEM_IFACE_MIXER,
	.device = 0,
	.subdevice = 0,
	.name = "CLKO Output Clock",
	.index = 0,
	.access = SNDRV_CTL_ELEM_ACCESS_TLV_READ | SNDRV_CTL_ELEM_ACCESS_READWRITE,
	.count = 0,
	.info = snd_soc_info_enum_double,
	.get = snd_soc_get_enum_double, 
	.put = snd_soc_put_enum_double, 
	.tlv.p , 
	.private_value = (unsigned long)&(struct soc_mixer_control)
									{
										.reg = AK7755_C1_CLOCK_SETTING2, 
										.items = 8, 
										.texts =  {"12.288MHz", "6.144MHz", "3.072MHz", "8.192MHz",
										"4.096MHz", "2.048MHz", "256fs", "XTI or BICK"};
									}
};
```
![](images/ALSA_01.png)

 - User Space 에서 "CLKO Output Clock" 대한 값을 요청 했을 경우, 수행되는 함수.
 "CLKO Output Clock" snd_kcontrol_new  선언 시, 멤버 변수 get 포인트 함수를 수행하여 읽어온다.
 get 에는 snd_soc_get_enum_double 이 연결되어 있다. 
 put 에는 snd_soc_put_enum_double 이 연결되어 있다.

```c
int snd_soc_get_enum_double(struct snd_kcontrol *kcontrol,
	struct snd_ctl_elem_value *ucontrol)
{
	struct snd_soc_component *component = snd_kcontrol_chip(kcontrol);
	struct soc_enum *e = (struct soc_enum *)kcontrol->private_value;
	unsigned int val, item;
	unsigned int reg_val;
	int ret;

	ret = snd_soc_component_read(component, e->reg, &reg_val);
	if (ret)
		return ret;
	val = (reg_val >> e->shift_l) & e->mask;
	item = snd_soc_enum_val_to_item(e, val);
	ucontrol->value.enumerated.item[0] = item;
	if (e->shift_l != e->shift_r) {
		val = (reg_val >> e->shift_r) & e->mask;
		item = snd_soc_enum_val_to_item(e, val);
		ucontrol->value.enumerated.item[1] = item;
	}

	return 0;
}
```


 - Linux kernel source의 audio codec device drier 의 source code안에 MACRO를 통하여 많은 snd_kcontrol_new가 선언되어 있다.

```c
static const struct snd_kcontrol_new ak7755_snd_controls[] = {
	SOC_SINGLE_TLV("MIC Input Volume L",
			AK7755_D2_MIC_GAIN_SETTING, 0, 0x0F, 0, mgnl_tlv),
	SOC_SINGLE_TLV("MIC Input Volume R",
			AK7755_D2_MIC_GAIN_SETTING, 4, 0x0F, 0, mgnr_tlv),
	SOC_SINGLE_TLV("Line Out Volume 1",
			AK7755_D4_LO1_LO2_VOLUME_SETTING, 0, 0x0F, 0, lovol1_tlv),
	SOC_SINGLE_TLV("Line Out Volume 2",
			AK7755_D4_LO1_LO2_VOLUME_SETTING, 4, 0x0F, 0, lovol2_tlv),
	SOC_SINGLE_TLV("Line Out Volume 3",
			AK7755_D3_LIN_LO3_VOLUME_SETTING, 0, 0x0F, 0, lovol3_tlv),
	SOC_ENUM_EXT("Line Input Volume", ak7755_linein_enum, get_linein, set_linein),  // 16/03/25 ak7755_linein_enum[0] => ak7755_linein_enum
	SOC_SINGLE_TLV("ADC Digital Volume L",
			AK7755_D5_ADC_DVOLUME_SETTING1, 0, 0xFF, 1, voladl_tlv),
	SOC_SINGLE_TLV("ADC Digital Volume R",
			AK7755_D6_ADC_DVOLUME_SETTING2, 0, 0xFF, 1, voladr_tlv),
	SOC_SINGLE_TLV("ADC2 Digital Volume L",
			AK7755_D7_ADC2_DVOLUME_SETTING1, 0, 0xFF, 1, volad2l_tlv),
	SOC_SINGLE_TLV("ADC2 Digital Volume R",
			AK7755_DD_ADC2_DVOLUME_SETTING2, 0, 0xFF, 1, volad2r_tlv),
	SOC_SINGLE_TLV("DAC Digital Volume L",
			AK7755_D8_DAC_DVOLUME_SETTING1, 0, 0xFF, 1, voldal_tlv),
	SOC_SINGLE_TLV("DAC Digital Volume R",
			AK7755_D9_DAC_DVOLUME_SETTING2, 0, 0xFF, 1, voldar_tlv),

	SOC_SINGLE("ADC Mute", AK7755_DA_MUTE_ADRC_ZEROCROSS_SET, 7, 1, 0),
	SOC_SINGLE("ADC2 Mute", AK7755_DA_MUTE_ADRC_ZEROCROSS_SET, 6, 1, 0), 
	SOC_SINGLE("DAC Mute", AK7755_DA_MUTE_ADRC_ZEROCROSS_SET, 5, 1, 0), 
	SOC_SINGLE("Analog DRC Lch", AK7755_DA_MUTE_ADRC_ZEROCROSS_SET, 2, 1, 0), 
	SOC_SINGLE("Analog DRC Rch", AK7755_DA_MUTE_ADRC_ZEROCROSS_SET, 3, 1, 0), 
	SOC_SINGLE("MICGAIN Lch Zero-cross", AK7755_DA_MUTE_ADRC_ZEROCROSS_SET, 0, 1, 0), 
	SOC_SINGLE("MICGAIN Rch Zero-cross", AK7755_DA_MUTE_ADRC_ZEROCROSS_SET, 1, 1, 0), 

	SOC_ENUM("DAC De-emphasis", ak7755_set_enum[10]), 

	SOC_SINGLE("JX0 Enable", AK7755_C2_SERIAL_DATA_FORMAT, 0, 1, 0),
	SOC_SINGLE("JX1 Enable", AK7755_C2_SERIAL_DATA_FORMAT, 1, 1, 0),
	SOC_SINGLE("JX2 Enable", AK7755_C1_CLOCK_SETTING2, 7, 1, 0),
	SOC_SINGLE("JX3 Enable", AK7755_C5_ACCELARETOR_SETTING, 6, 1, 0),

	SOC_ENUM("DLRAM Mode(Bank1:Bank0)", ak7755_set_enum[0]), 
	SOC_ENUM("DRAM Size(Bank1:Bank0)", ak7755_set_enum[1]), 
	SOC_ENUM("DRAM Addressing Mode(Bank1:Bank0)", ak7755_set_enum[2]), 
	SOC_ENUM("POMODE DLRAM Pointer 0", ak7755_set_enum[3]), 
	SOC_ENUM("CRAM Memory Assignment", ak7755_set_enum[4]), 
	SOC_ENUM("FIRMODE1 Accelerator Ch1", ak7755_set_enum[5]), 
	SOC_ENUM("FIRMODE2 Accelerator Ch2", ak7755_set_enum[6]), 
	SOC_ENUM("SUBMODE1 Accelerator Ch1", ak7755_set_enum[7]), 
	SOC_ENUM("SUBMODE2 Accelerator Ch2", ak7755_set_enum[8]), 
	SOC_ENUM("Accelerator Memory(ch1:ch2)", ak7755_set_enum[9]), 
	SOC_ENUM("CLKO pin", ak7755_set_enum[11]), 
	SOC_ENUM("CLKO Output Clock", ak7755_set_enum[12]), 
```

## 2.4 Kcontrol 등록 

 - 대부분 같은 audio codec device driver 안에서 MACRO를 통해 선언된 snd_kcontrol_new가 snd_soc_add_controls 함수를 통하여 snd_kcontrol 구조체로 변환되어 snd_card의 controls에 연결된다.
   * snd_soc_cnew 함수를 통해 snd_kcontrol_new 구조체가 snd_kcontrol 구조체로 변환.
   * snd_ctl_add 함수는 snd_card의 controls에 snd_kcontrol을 NUmbering하며 링크드리스트로 연결하고, kcontrol 총 개수를 관리.
```c

static int snd_soc_add_controls(struct snd_card *card, struct device *dev,
	const struct snd_kcontrol_new *controls, int num_controls,
	const char *prefix, void *data)
{
	int err, i;

	for (i = 0; i < num_controls; i++) {
		const struct snd_kcontrol_new *control = &controls[i];
		err = snd_ctl_add(card, snd_soc_cnew(control, data,
						     control->name, prefix));
		if (err < 0) {
			dev_err(dev, "ASoC: Failed to add %s: %d\n",
				control->name, err);
			return err;
		}
	}

	return 0;
}
```

 - kcontrol이 등록되면 snd_card 구조체의 controls에 다음과 같이 연결된다.

![](images/ALSA_02.png)


## 2.5 Kcontrol 운용

 - user space application에서는 ALSA Library를 이용하여 Kcontrol들을 access 접근 제한(대부분R/W)에 따라 제어할수 있다.
 - ALSA Library를 이용한 amixer(not alsamixer!)라는 program으로 console command 형식으로 사용 가능하다. 
 > amixer는 ALSA project(http://www.alsa-project.org)에서 alsa-utils packages를 통해 제공
 - Android platform의 경우는 tinyalsa 패키지를 통해 ALSA Library를 이용한다.
    * 아래와 같이 tinymix 명령을 내려 현재 sound card의 모든 kcontrol을 확인 할 수 있다.

```bash
# tinymix
```

## 2.6 Kcontrol 정리
 - tinymix는 test 용으로 사용하는 것이며, User space application(HAL) 작성 시에는 ALSA Library를 이용한다. 
 - amixer를 보면 scontrol(mixer controls) 및 scontents(mixer controls with contents)도 있다. 
   * 이 scontrol은 비슷한 kcontrol을 묶어서 ALSA Library에서 제공하는 것이다. 
   (ex> DAC1 Switch 와 DAC1 Volume 를 묶어서 DAC1 으로 제공)


-----

# 3. Widget

## 3.1 Widget 이란?

 - Audio Codec 내부의 DAC, ADC, Mixer, Mux 등을 각각 하나의 가상 장치로 표현 한 것이며 종류는 다음과 같다.

		o Mixer
		 - Mixes several analog signals into a single analog signal.
		o Mux
		 - An analog switch that outputs only one of many inputs.
		o PGA
		 - A programmable gain amplifier or attenuation widget.
		o ADC
		 - Analog to Digital Converter
		o DAC
		 - Digital to Analog Converter
		o Switch
		 - An analog switch
		o Input
		 - A codec input pin
		o Output
		 - A codec output pin
		o Headphone
		 - Headphone (and optional Jack)
		o Mic
		 - Mic (and optional Jack)
		o Line
		 - Line Input/Output (and optional Jack)
		o Speaker
		 - Speaker
		o Supply
		 - Power or clock supply widget used by other widgets.
		o Pre
		 - Special PRE widget (exec before all others)
		o Post
		 - Special POST widget (exec after all others)

 - 프로그래머가 직접 작성하여 등록하는 것이며, codec driver와 machine driver에서 등록된다.
 - widget은 이름을 필수로 가져야 한다. 몇몇 widget은 register, kcontrol을 가진다.
 - user space application은 전혀 신경을 쓰지 않아도 되는 부분이다.

 - 실제 audio codec의 block diagram을 가상의 장치로 표현한 것이라 볼 수 있다.
	![](images/ALSA_03.png)


## 3.2 Widget 구조체

 - struct snd_soc_dapm_widget 구조체

```c
/* dapm widget */
struct snd_soc_dapm_widget {
	enum snd_soc_dapm_type id;
	const char *name;		/* widget name */
	const char *sname;	/* stream name */
	struct list_head list;
	struct snd_soc_dapm_context *dapm;

	void *priv;				/* widget specific data */
	struct regulator *regulator;		/* attached regulator */
	struct pinctrl *pinctrl;		/* attached pinctrl */
	const struct snd_soc_pcm_stream *params; /* params for dai links */
	unsigned int num_params; /* number of params for dai links */
	unsigned int params_select; /* currently selected param for dai link */

	/* dapm control */
	int reg;				/* negative reg = no direct dapm */
	unsigned char shift;			/* bits to shift */
	unsigned int mask;			/* non-shifted mask */
	unsigned int on_val;			/* on state value */
	unsigned int off_val;			/* off state value */
	unsigned char power:1;			/* block power status */
	unsigned char active:1;			/* active stream on DAC, ADC's */
	unsigned char connected:1;		/* connected codec pin */
	unsigned char new:1;			/* cnew complete */
	unsigned char force:1;			/* force state */
	unsigned char ignore_suspend:1;         /* kept enabled over suspend */
	unsigned char new_power:1;		/* power from this run */
	unsigned char power_checked:1;		/* power checked this run */
	unsigned char is_supply:1;		/* Widget is a supply type widget */
	unsigned char is_ep:2;			/* Widget is a endpoint type widget */
	int subseq;				/* sort within widget type */

	int (*power_check)(struct snd_soc_dapm_widget *w);

	/* external events */
	unsigned short event_flags;		/* flags to specify event types */
	int (*event)(struct snd_soc_dapm_widget*, struct snd_kcontrol *, int);

	/* kcontrols that relate to this widget */
	int num_kcontrols;
	const struct snd_kcontrol_new *kcontrol_news;
	struct snd_kcontrol **kcontrols;
	struct snd_soc_dobj dobj;

	/* widget input and output edges */
	struct list_head edges[2];

	/* used during DAPM updates */
	struct list_head work_list;
	struct list_head power_list;
	struct list_head dirty;
	int endpoints[2];

	struct clk *clk;
};

/* dapm widget types */
enum snd_soc_dapm_type {
	snd_soc_dapm_input = 0,		/* input pin */
	snd_soc_dapm_output,		/* output pin */
	snd_soc_dapm_mux,			/* selects 1 analog signal from many inputs */
	snd_soc_dapm_demux,			/* connects the input to one of multiple outputs */
	snd_soc_dapm_mixer,			/* mixes several analog signals together */
	snd_soc_dapm_mixer_named_ctl,		/* mixer with named controls */
	snd_soc_dapm_pga,			/* programmable gain/attenuation (volume) */
	snd_soc_dapm_out_drv,			/* output driver */
	snd_soc_dapm_adc,			/* analog to digital converter */
	snd_soc_dapm_dac,			/* digital to analog converter */
	snd_soc_dapm_micbias,		/* microphone bias (power) - DEPRECATED: use snd_soc_dapm_supply */
	snd_soc_dapm_mic,			/* microphone */
	snd_soc_dapm_hp,			/* headphones */
	snd_soc_dapm_spk,			/* speaker */
	snd_soc_dapm_line,			/* line input/output */
	snd_soc_dapm_switch,		/* analog switch */
	snd_soc_dapm_vmid,			/* codec bias/vmid - to minimise pops */
	snd_soc_dapm_pre,			/* machine specific pre widget - exec first */
	snd_soc_dapm_post,			/* machine specific post widget - exec last */
	snd_soc_dapm_supply,		/* power/clock supply */
	snd_soc_dapm_pinctrl,		/* pinctrl */
	snd_soc_dapm_regulator_supply,	/* external regulator */
	snd_soc_dapm_clock_supply,	/* external clock */
	snd_soc_dapm_aif_in,		/* audio interface input */
	snd_soc_dapm_aif_out,		/* audio interface output */
	snd_soc_dapm_siggen,		/* signal generator */
	snd_soc_dapm_sink,
	snd_soc_dapm_dai_in,		/* link to DAI structure */
	snd_soc_dapm_dai_out,
	snd_soc_dapm_dai_link,		/* link between two DAI structures */
	snd_soc_dapm_kcontrol,		/* Auto-disabled kcontrol */
	snd_soc_dapm_buffer,		/* DSP/CODEC internal buffer */
	snd_soc_dapm_scheduler,		/* DSP/CODEC internal scheduler */
	snd_soc_dapm_effect,		/* DSP/CODEC effect component */
	snd_soc_dapm_src,		/* DSP/CODEC SRC component */
	snd_soc_dapm_asrc,		/* DSP/CODEC ASRC component */
	snd_soc_dapm_encoder,		/* FW/SW audio encoder component */
	snd_soc_dapm_decoder,		/* FW/SW audio decoder component */
};
```

 - snd_soc_dapm_widget의 중요 멤버 변수 설명

```c
struct snd_soc_dapm_widget {
	enum snd_soc_dapm_type id;		// 현재 widget 의 type 을 나타 낸다.
	char *name;						// widget name
	char *sname;					// play 나 capture 시 비교 된다. 이름이 같을 경우 power check한다.
	struct snd_soc_codec *codec;	// widget 이 소속된 codec 을 가르킨다.
	struct list_head list;			// snd_soc_card 의 widgets 에 연결 되는 point

	short reg;						// widget 도 Audio Codec 의 Reg 정보를 가진다. 대부분 Power 관련 된 Register 이다.
	unsigned char shift;			// Register 의 몇 번째 bit 에 해당하는지 나타낸다.
	unsigned char power:1;			// widget 의 power status이다. 1이면 ON 0이면 OFF,
	unsigned char active:1;			// DAC, ADC, AIFIN, AIFOUT widget 만 해당 되며 Power Check 시 중요한 flag 이다.
									// Play나 Capture 시 sname, stream_name 비교 후 set 된다.
	unsigned char connected:1; 		// widget 생성 될 때 무조건 1로 set 된다. snd_soc_dapm_enable_pin, snd_soc_dapm_disable_pin 함수를
									// 통하여 set, clear 된다. 대부분 외부 단자 widget ( input , output ,mic ,line , hp, spk ) 에 enable,
									// disable 시켜서 DAPM power 를 제어 하도록 한다.
	unsigned char ext:1;			// Audio codec 외부에 붙는 widget 에 연결 되었는지 설정 한다.
									// output widget 에 hp,spk widget 이 연결 되면 ouput widget 의 ext 가 1로 set
									// input widget 에 mic widget 이 연결 되었다면 input widget 의 ext 는 1로 set
	unsigned char force:1;			// widget 의 power 를 강제로 ON 하는 flag.
	
	int (*power_check)(struct snd_soc_dapm_widget *w); // widget 의 power check 함수 포인터
	
	int num_kcontrols;				// widget 에 연결 된 kcontrol 개수
	const struct snd_kcontrol_new *kcontrol_news; // widget 에 연결 할 정적으로 작성된 kcontrol 주소를 가르킨다.
	struct snd_kcontrol **kcontrols;// widget 에 연결 된 kcontrol 가르키는 포인터
	struct list_head sources; 		// widget 에 연결된 path 중 widget 을 sink(목적지)로 하고 있는 path list
	struct list_head sinks;			// widget 에 연결된 path 중 widget 에서 sources(출발지)로 하고 있는 path list
}

```

 - snd_soc_dapm_widget 의 중요 멤버 변수 중 sources와 sinks 개념. 
 - 향후 route(path)에 대해서 나오는데 widget을 중심으로 연결된 path들의 링크드 리스트이다.
 - widget을 중심으로 widget을 목적지로 하고 있는 path들은 sources에 연결되고 
 - widget을 중심으로 widget에서 출발하는 path들은 sinks에 연결된다. 


	![](images/ALSA_04.png)
	 
-----

# 4. Route(path)

-----

# 5. DAPM Operation

-----