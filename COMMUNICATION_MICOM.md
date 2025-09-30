SoC↔Micom I²C 통신 
=====

- 버스: I²C1, 7-bit ~~주소 0x28~~, 속도 10 kHz, SoC=Master / Micom=Slave
- 레지스터 폭: 주소 8-bit, 데이터 8-bit ~~(필요 시 16-bit Little-Endian)~~
- IRQ: MCU_INT (Active-Low, Level, Open-Drain) — 이벤트 존재 시 Low 유지, 비면 High
