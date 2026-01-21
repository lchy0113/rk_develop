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
