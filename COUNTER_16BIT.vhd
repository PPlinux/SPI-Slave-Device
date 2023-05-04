----------------------------------------------------------------------------------
-- Company: 		Emsys Embedded Systems Thomas More Mechelen Antwerpen
-- Research:		MICAS ESAT KU Leuven
-- Engineer:		Nick Destrycker 
-- Researcher:		Patrick Pelgrims 
-- Create Date:     
-- Design Name: 	SPI Slave
-- Module Name:    	COUNTER_16BIT System - Behavioral 
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

entity COUNTER_16BIT is
    Port ( clk : in  std_logic;
            en : in  std_logic;
           rst : in  std_logic;
      overflow : out std_logic;
	  dout : out std_logic_VECTOR(15 downto 0);
	  ndout : out std_logic_vector(15 downto 0) );
end COUNTER_16BIT;

architecture Behavioral of COUNTER_16BIT is

signal CNT_REG : integer range 0 to 65535:=0;

begin
	process( clk, rst ) begin
		if (rst = '1') then
			CNT_REG <= 0;
		elsif( rising_edge(clk) ) then
			if( en = '1' ) then
				CNT_REG <= CNT_REG + 1;
				if( CNT_REG = 0 ) then
					overflow <= '1';
				else
					overflow <= '0';
				end if;
			end if;
		end if;
	end process;

	dout <= std_logic_vector(to_unsigned(CNT_REG, 16));
	ndout <= not(std_logic_vector(to_unsigned(CNT_REG, 16)));
end Behavioral;