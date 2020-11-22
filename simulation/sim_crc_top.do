
quit -sim

## Delete library "work" if it exists
if {[file exists ./work]} {file delete -force -- work}
  
vlib work

vcom -2008 ../crc_pkg.vhd

vcom -2008 tb_crc_top.vhd

vsim work.tb_crc_top -t ns

view wave 
add wave -r tb_crc_top/*


when -label end_of_simulation {stop_condition == '1'} {echo "End of Simulation" ; stop ;}
run -all
