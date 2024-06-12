
MultiMedia


## Frequency

 rk3568x vepu 및 rkvenc IP는 H264 encoding 을 지원하므로, rkvenc를 선택.

```bash
 # cat /d/clk/clk_summary | grep rkvenc
          clk_rkvenc_core             1        2        0   297000000          0     0  50000
          aclk_rkvenc_pre             2        2        0   297000000          0     0  50000
             aclk_rkvenc              1        4        0   297000000          0     0  50000
             hclk_rkvenc_pre          1        2        0    99000000          0     0  50000
                hclk_rkvenc           1        4        0    99000000          0     0  50000

```

kernel 4.19/5.10 (>= android 10.0) frequency 구성은 devicetree에 정의(rkvdec) 되어 있음. 

 - rockchip,normal-rates : 해상도가 1920x1088 미만인 경우, 동작
 - rockchip,advanced-rates : 해상도가1920x1088 이상인 경우,

```dtb
	rkvdec: rkvdec@fdf80200 {
		compatible = "rockchip,rkv-decoder-rk3568", "rockchip,rkv-decoder-v2";
		reg = <0x0 0xfdf80200 0x0 0x400>, <0x0 0xfdf80100 0x0 0x100>;
		reg-names = "regs", "link";
		interrupts = <GIC_SPI 91 IRQ_TYPE_LEVEL_HIGH>;
		interrupt-names = "irq_dec";
		clocks = <&cru ACLK_RKVDEC>, <&cru HCLK_RKVDEC>,
			 <&cru CLK_RKVDEC_CA>, <&cru CLK_RKVDEC_CORE>,
			 <&cru CLK_RKVDEC_HEVC_CA>;
		clock-names = "aclk_vcodec", "hclk_vcodec","clk_cabac",
			      "clk_core", "clk_hevc_cabac";
		rockchip,normal-rates = <297000000>, <0>, <297000000>,
					<297000000>, <600000000>;
		rockchip,advanced-rates = <396000000>, <0>, <396000000>,
					<396000000>, <600000000>;
```

<br/>
<br/>
<br/>
<br/>
<hr>

## codec input and output capture

 video 이슈 문제의 경우, 코덱 입력 및 출력 데이터 캡처를 통해 디버깅.

 1. MediaCodec API 사용
   - encoding.

   - decoding.

<br/>
<br/>
<br/>
<br/>
<hr>

## debugging

 아래 명령어 입력으로 debug 활성화

```bash
$ echo 0x0100 > /sys/module/rk_vcodec/parameters/mpp_dev_debug
$ cat /proc/kmsg
```
