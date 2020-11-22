--------------------------------------------------------------------------------------------
--      ____________     | Copyright (C) 2020 - Electgon - www.electgon.com
--     /            \    | This source file is free: you can redistribute it and/or  
--    /    ______    \   | modify it under the terms of the GNU General Public License 
--   /    /      \    \  | as published by the Free Software Foundation, either 
--  /    /________\    \ | version 3 of the License, or any later version.
-- (     _______________)| This program is distributed in the hope that it will be 
--  \    \        ,----, | useful, but WITHOUT ANY WARRANTY; without even the implied
--   \    \______/    /  | warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
--    \              /   | PURPOSE. See the GNU General Public License for more details.
--     \____________/    |              -------------------------
--                       | Design: VHDL Testbench for CRC modules
--                       | Author: Electgon
--                       | Version:
--                       | Build Date: 03.10.2020
--------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.crc_pkg.all;

entity tb_crc_top is

end entity tb_crc_top;

architecture tb of tb_crc_top is

------------- Testbench Configuration ----------
alias crc_func is work.crc_pkg.CRC_32_8[std_logic_vector, std_logic_vector return std_logic_vector];
constant DATA_WIDTH    : integer := 8;
constant CRC_WIDTH     : integer := 32;
constant CRC_INIT      : std_logic_vector(CRC_WIDTH-1 downto 0) := (others => '1');
constant CRC_RESIDUAL  : std_logic_vector(CRC_WIDTH-1 downto 0) := x"C7_04_DD_7B";
constant CRC_msb_first : boolean := crc_func'msb_first;
constant STIM_FILE_TX  : string := "tx_crc_stimulus.txt";
constant STIM_FILE_RX  : string := "rx_crc_stimulus.txt";
constant clk_period    : time := 8 ns;
------------------------------------------------

file tx_file : text open read_mode is STIM_FILE_TX;
file rx_file : text;  

signal init_val_tb    : std_logic_vector(CRC_WIDTH-1 downto 0) := CRC_INIT;
signal tx_init_val_tb : std_logic_vector(CRC_WIDTH-1 downto 0) := CRC_INIT;
signal rx_init_val_tb : std_logic_vector(CRC_WIDTH-1 downto 0) := CRC_INIT;
signal data_tb        : std_logic_vector(DATA_WIDTH-1 downto 0);
signal tx_data_tb     : std_logic_vector(DATA_WIDTH-1 downto 0);
signal rx_data_tb     : std_logic_vector(DATA_WIDTH-1 downto 0);

signal stop_condition : std_logic;
signal rx_in_stimulus : boolean := false;
signal tx_in_stimulus : boolean := false;

-- Reverse the input vector.
function REVERSED(slv : std_logic_vector) return std_logic_vector is
  variable result : std_logic_vector(slv'reverse_range);
begin
  for i in slv'range loop
    result(i) := slv(i);
  end loop;
  return result;
end REVERSED;


begin

data_tb <= tx_data_tb when tx_in_stimulus else rx_data_tb;
init_val_tb <= tx_init_val_tb when tx_in_stimulus else rx_init_val_tb;

  -- simulation termination
  -------------------------
  simEnd : process
  begin
     
	stop_condition <= '0';
    wait for clk_period*50;
    wait until rx_in_stimulus = false;
    wait for clk_period*50;
    stop_condition <= '1';
	wait;
  
  end process simEnd;


  -- transmitting stimulus
  -------------------------
tx_input_stimulus : process
    variable readfile_line : line;
    variable writefile_line : line;
	variable temp_vec  : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable tx_crc    : std_logic_vector(CRC_WIDTH-1 downto 0);
    variable int_crc   : std_logic_vector(CRC_WIDTH-1 downto 0);
    variable temp_init : std_logic_vector(CRC_WIDTH-1 downto 0) := CRC_INIT;
begin
    file_open(rx_file, STIM_FILE_RX, write_mode);
    tx_in_stimulus <= true;
    
    wait for clk_period * 10;

    while (not endfile(tx_file)) loop
	    readline (tx_file, readfile_line);
        hread(readfile_line, temp_vec);
        if (CRC_msb_first) then
            int_crc := crc_func(REVERSED(temp_vec), temp_init);
        else
            int_crc := crc_func(temp_vec, temp_init);
        end if;
        hwrite(writefile_line, temp_vec);
        writeline(rx_file, writefile_line);
		tx_data_tb <= temp_vec;
		tx_init_val_tb <= int_crc;
        wait for clk_period;
        if (endfile(tx_file)) then
            exit;
        else
            temp_init := int_crc;
        end if;

	end loop;

    wait for clk_period*10;

    reverse_crc : for idx in (CRC_WIDTH/DATA_WIDTH)-1 downto 0 loop
            tx_crc(DATA_WIDTH*(idx+1) - 1 downto DATA_WIDTH*idx)   :=  not REVERSED(int_crc(DATA_WIDTH*(idx+1) - 1 downto DATA_WIDTH*idx));
        hwrite(writefile_line, tx_crc(DATA_WIDTH*(idx+1) - 1 downto DATA_WIDTH*idx));
        writeline(rx_file, writefile_line);
    end loop reverse_crc;

    file_close(rx_file);
    wait for clk_period*10;
    tx_in_stimulus <= false;
     
    wait;

end process tx_input_stimulus;


  -- receiving stimulus
  ----------------------
rx_input_stimulus : process
    variable readfile_line : line;
	variable temp_vec : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable int_crc   : std_logic_vector(CRC_WIDTH-1 downto 0);
    variable temp_crc    : std_logic_vector(CRC_WIDTH-1 downto 0);
    variable temp_init   : std_logic_vector(CRC_WIDTH-1 downto 0) := CRC_INIT;
begin

    wait until tx_in_stimulus = false;
    rx_in_stimulus <= true;
    file_open(rx_file, STIM_FILE_RX, read_mode);
    
    wait for clk_period * 10;
    
    while (not endfile(rx_file)) loop
	    readline (rx_file, readfile_line);
		hread(readfile_line, temp_vec);
        if (CRC_msb_first) then
            int_crc := crc_func(REVERSED(temp_vec), temp_init);
        else
            int_crc := crc_func(temp_vec, temp_init);
        end if;
		rx_data_tb <= temp_vec;
        rx_init_val_tb <= int_crc;
        wait for clk_period;
        if (endfile(rx_file)) then
            exit;
        else
            temp_init := int_crc;
        end if;
	end loop;

    assert (int_crc = CRC_RESIDUAL)
            report "Wrong Residual Value" & LF & "    correct value should be: " & to_hstring(CRC_RESIDUAL)
            severity error;

    wait for clk_period*10;
    file_close(rx_file);
    wait for clk_period*10;
    rx_in_stimulus <= false;

    wait;
end process rx_input_stimulus;  


end architecture tb;