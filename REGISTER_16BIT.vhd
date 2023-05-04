----------------------------------------------------------------------------------
-- Company: 		Emsys Embedded Systems Thomas More Mechelen Antwerpen
-- Research:		MICAS ESAT KU Leuven
-- Engineer:		Nick Destrycker 
-- Researcher:		Patrick Pelgrims 
-- Create Date:     
-- Design Name: 	SPI Slave
-- Module Name:    	REGISTER_16BIT - Behavioral 
-- Project Name: 	Bionic Eye SPI Slave Design
-- Target Devices: 	FPGA & ASIC
-- Tool versions: 	Lattice ICECube & ...
-- Description: 	SPI Slave with Status Register, Frequency Counter and PWM Generator
--
-- Dependencies: 
--
-- Revision: 		0.01 - File Created
-- Additional Comments: None
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
----------------------------------------------------------------------------------
entity REGISTER_16BIT is
    Port ( clk : in  std_logic;
	   rst : in std_logic;
	    en : in  std_logic;
           din : in  std_logic_vector(15 downto 0);
          dout : out  std_logic_vector(15 downto 0) );
end REGISTER_16BIT;
----------------------------------------------------------------------------------
architecture Behavioral of REGISTER_16BIT is

signal REG: std_logic_vector(15 downto 0);

begin
	process(clk, rst) begin
        if rst = '1' then
            REG <= X"0000";
        elsif (rising_edge(clk)) then
            if (en = '1') then
		REG <= din;
            end if;
        end if;
    end process;
	dout <= REG;
	 
end Behavioral;
----------------------------------------------------------------------------------