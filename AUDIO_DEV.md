# AUDIO_DEV

## wallpad - door

- SEL_DC : GPIO0_A6
  * High(Active)  
```bash
// set gpio
# io -4 -w 0xfdc20004 0x07000000

// set directiron to out
# io -4 -w 0xfdd60008 0x00400040 

// set value to high
# io -4 -w 0xfdd60000 0x00400040 

// set value to low
# io -4 -w 0xfdd60000 0x00400000 
```


	



