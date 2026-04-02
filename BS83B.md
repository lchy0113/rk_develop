BS83B Module

====

bs83b_get_keydatascan
```
// READ length 4
[0x00] [0x00] [0x40]
```

bs83b_set_key_sensitivity
```
// WRITE 0xf0 register + value
[0xf0][0x31][0x31][0x31][0x31][0x31][0x31][0x31][0x31]
```


debug_sensitivity
```
=== BS83B Threshold Data ===
Slide Data:    0x00
Key 16~9:      0x00
Key 8~1:       0x00
FW Version:    0x1970
Thresholds:
  Key  1: 0x31 (HEATING)
  Key  2: 0x31 (VENTILATION)
  Key  3: 0x31 (ELEVATOR)
  Key  4: 0x31 (OUTING)
  Key  5: 0x31 (GUARD)
  Key  6: 0x31 (EMERGENCY)
  Key  7: 0x31 (DOOROPEN)
  Key  8: 0x31 (CALL)
  Key  9: 0x10
  Key 10: 0x10
  Key 11: 0x10
Cached: 0x31
```


bs83b_dimming_cmd

- 한번에 전체 LED를 각각의 data로 제어 :
```
0x21 + [LED1 value] + [LED2 value] + ... [LED9 value]
```

ex>
```
+(LED_index)+-----------+
| LED1(0)   | DOOROPEN  |
| LED2(1)   | OUTING    |
| LED3(2)   |           |
| LED4(3)   |           |
| LED5(4)   | CALL      |
| LED6(5)   | EMERGENCY |
| LED7(6)   | GUARD     |
| LED8(7)   | ELEVATOR  |
| LED9(8)   |           |
+-----------+-----------+

+(KEY index)+-----------+
| KEY1(0)   |           |
| KEY2(1)   |           |
| KEY3(2)   | ELEVATOR  |
| KEY4(3)   | OUTING    |
| KEY5(4)   | GUARD     |
| KEY6(5)   | EMERGENCY |
| KEY7(6)   | DOOROPEN  |
| KEY8(7)   | CALL      |
| KEY9(8)   |           |
| KEY10(9)  |           |
+-----------+-----------+


```
