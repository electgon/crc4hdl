# crc4hdl
----------

CRC4HDL is a free tool to generate CRC calculation logic to be used in HDL designs (VHDL).

Usage:

 crc4hdl [options] ...

options are:

* [-p value]             To define the generator polynomial
* [-d value]             To define width of the crc
* [-w value]             To define width of input data
* [-msb]                 Choose it if input data has msb first
* [-lsb]                 Choose it if input data has lsb first
* -\-                    Forcibly stop option processing
* -?                     Print help message

Example: 
```
crc4hdl -p 104C11DB7 -w 1 -msb -d 32
```

this will generate CRC for the polynomial 104C11DB7 which of degree 32 (CRC width), The Input data is 1 bit with msb first.


The tool binary is provided for:
- Windows: crc4hdl.exe
- Linux: crc4hdl

-------------------------------------------
## Generated Output

Upon successful execution of crc4hdl, one package will be generated "crc_pkg". This package will have one ready function to
be called within your design. This function accepts two inputs arguments: Input data and Initial value of the CRC register.
For understanding CRC theory and what are input data and initial value, kindly visit www.electgon.com
The function will return computed CRC value for the provided segment of data. If you have long packet of data, you can either
calculate the CRC of the entire packet at once (but input data width of the function shall be set accordingly), or you can
divide this long packet into data segments (for example each of 8 bit width) then calculate the CRC for each segment but the
result CRC of one segment shall be provided as CRC initial value of the next data segment.

As an example, there is one testbench is provided in this repository in "simulation" directory to undersdtand how to
use the generated CRC function.


-------------------------------------------
## Simulation Testbench

For simulating the resulted package, a ready testbench is provided along with the executable so that you can simulate the
generated HDL file. But first you have to open the testbench source file "tb_crc_top" and adjust the testbench configuration
section:

- crc_func      : this is an alias for the generated CRC function which is named according to the parameter of the CRC scheme.
- DATA_WIDTH    : this should contain the width of input data.
- CRC_WIDTH     : this should contain the width of the CRC scheme.
- CRC_INIT      : define in that constant what should be the initial value your CRC scheme.
- CRC_RESIDUAL  : define in that constant what is the expected final residual value. This is used when receiving data packet
                  that is already appended with a CRC value. Please check www.electgon.com for more details.
- CRC_msb_first : this constant is getting its value automatically from the generated function, no need to change it.
- STIM_FILE_TX  : there is one txt file provided with the testbench to be used as an input stimulus "tx_crc_stimulus.txt".

To execute the provided testbench, there is one "do" file which is ready to be used in ModelSim/Questa simulators, to run
this "do" file, open ModelSim/Questa then use this command
```
run sim_crc_top.do
```