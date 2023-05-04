----------------------------------------------------------------------------------
-- Company: 		Emsys Embedded Systems Thomas More Mechelen Antwerpen
-- Research:		MICAS ESAT KU Leuven
-- Engineer:		Nick Destrycker 
-- Researcher:		Patrick Pelgrims 
-- Create Date:     
-- Design Name: 	SPI Slave
-- Module Name:   	FREQCOUNT_CORE_V4 System - Behavioral 
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
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
------------------------------------------------------------------------------------
entity FREQCOUNT_CORE_V4 is
    Port ( clk : in  std_logic;  
	   rst : in  std_logic;
	   en  : in  std_logic;
       cnt_clk : in  std_logic;
	   int : out std_logic;
       int_ack : in  std_logic;
	  freq : out std_logic_vector(31 downto 0);
  interval_time: in  std_logic_vector(31 downto 0) );	  
end FREQCOUNT_CORE_V4;
------------------------------------------------------------------------------------
architecture Behavioral of FREQCOUNT_CORE_V4 is
------------------------------------------------------------------------------------

signal flipflop_delay : std_logic_vector(3 downto 0);
signal cnt_en	      : std_logic;
signal cnt_rst	      : std_logic;
signal interval	      : integer range 0 to 100000000 :=0;
signal interrupt      : std_logic;
signal CNT_REG	      : unsigned(31 downto 0);

------------------------------------------------------------------------------------				    

begin
interrupt_handler: process(clk, rst, en) begin
	if(rst = '1') then
		interrupt <= '0';
		interval <= 0;
	elsif (rising_edge(clk) and (en = '1')) then
		
		if interval=conv_integer(interval_time) then  
			interrupt <= '1';
			freq <= std_logic_vector(CNT_REG);-- latch the counted freq ONLY if there is an interrupt/done with counting
		else
        	interval <= interval + 1;
        	interrupt <= interrupt;
        end if;
		
		if int_ack = '1' then
			interrupt <= '0';
			interval <= 0;
			cnt_rst <= '1';
		else
			cnt_rst <= '0';
		end if;

	end if;
end process;

freq_count: process(cnt_clk, en, rst, cnt_rst) begin
	if(cnt_rst = '1' or rst = '1') then
		CNT_REG <= X"00000000";
	elsif(rising_edge(cnt_clk) and (en = '1')) then
		if(cnt_en = '1') then
			CNT_REG <= CNT_REG + 1;
		end if;
	end if;
end process;

counter_switch_control: process(cnt_clk, en)
  begin
    if (rising_edge(cnt_clk) and (en = '1')) then
		flipflop_delay <= flipflop_delay(2 downto 0) & interrupt;
			case flipflop_delay(3 downto 1) is
				when "000" => cnt_en <= '1';
				when "111" => cnt_en <= '0';
				when others => cnt_en <= cnt_en;
			end case;
    end if;
end process counter_switch_control;
  
int <= interrupt;
------------------------------------------------------------------------------------------------------------------------------------
end Behavioral;
------------------------------------------------------------------------------------------------------------------------------------