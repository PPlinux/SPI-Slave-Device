----------------------------------------------------------------------------------
-- Company: 		Emsys Embedded Systems Thomas More Mechelen Antwerpen
-- Research:		MICAS ESAT KU Leuven
-- Engineer:		Nick Destrycker 
-- Researcher:		Patrick Pelgrims 
-- Create Date:     
-- Design Name: 	SPI Slave
-- Module Name:    	COMPARATOR_16BIT System- Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity COMPARATOR_16BIT is
    Port ( clk : in std_logic;
	   din : in  std_logic_VECTOR (15 downto 0);
	   sel : in std_logic;
      comp_val : in std_logic_VECTOR (15 downto 0);
         pwm_o : out  std_logic );
				
end COMPARATOR_16BIT;

architecture Behavioral of COMPARATOR_16BIT is
begin 
	process(clk) begin
		if rising_edge(clk) then
			if(sel = '0') then
				if(din >= comp_val) then
					pwm_o <= '0';
				else
					pwm_o <= '1';
				end if;
			elsif(sel = '1') then
				if(din <= comp_val) then
					pwm_o <= '1';
				else
					pwm_o <= '0';
				end if;
			end if;
		end if;	
	end process;
end Behavioral;
