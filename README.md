# crc4hdl
----------

CRC4HDL is a free tool to generate CRC calculation logic to be used in HDL designs (VHDL).

Usage:
 crc4hdl [options] ...
options are:
 -p value             define the generator polynomial <>
 -d value             define width of the crc <>
 -w value             define width of input data <>
 -msb                 choose it if input data has msb first
 -lsb                 choose it if input data has lsb first
 --                   Forcibly stop option processing
 -help                Print this message
 -?                   Print this message

Example: 
```
crc4hdl -p 104C11DB7 -w 1 -msb -d 32
```
this will generate CRC for the polynomial 104C11DB7 which of degree 32 (CRC width), The Input data is 1 bit with msb first.

The tool binary is provided for:
- Windows: crc4hdl.exe
