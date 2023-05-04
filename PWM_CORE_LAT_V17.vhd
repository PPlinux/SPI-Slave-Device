----------------------------------------------------------------------------------
-- Company: 		Emsys Embedded Systems Thomas More Mechelen Antwerpen
-- Research:		MICAS ESAT KU Leuven
-- Engineer:		Nick Destrycker 
-- Researcher:		Patrick Pelgrims 
-- Create Date:     
-- Design Name: 	SPI Slave 
-- Module Name:    	PWM_CORE_LAT_V17 - Behavioral 
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
entity PWM_CORE_LAT_V17 is
    Port (clk : in std_logic;
	  rst : in std_logic;
	   en : in std_logic;
    pwm_reg_a : in std_logic_vector(15 downto 0);
    pwm_reg_b : in std_logic_vector(15 downto 0);
    pwm_out_1 : out std_logic;
    pwm_out_2 : out std_logic );
end PWM_CORE_LAT_V17;

architecture Behavioral of PWM_CORE_LAT_V17 is

component REGISTER_16BIT
    Port ( clk : in  std_logic;
	   rst : in std_logic;
	    en : in  std_logic;
           din : in  std_logic_vector(15 downto 0);
          dout : out  std_logic_vector(15 downto 0) );
end component;

component COUNTER_16BIT
    Port ( clk : in  std_logic;
            en : in  std_logic;
           rst : in  std_logic;
       overflow: out std_logic;
	  dout : out std_logic_vector(15 downto 0);
	 ndout : out  std_logic_vector (15 downto 0) );
end component;

component COMPARATOR_16BIT
    Port ( clk : in std_logic;
	   din : in  std_logic_vector(15 downto 0);
	   sel : in std_logic;
      comp_val : in std_logic_vector(15 downto 0);
         pwm_o : out  std_logic );
end component;

signal n_counter_val: std_logic_vector(15 downto 0);
signal p_counter_val: std_logic_vector(15 downto 0);
signal reg_a_out: std_logic_vector(15 downto 0);
signal reg_b_out: std_logic_vector(15 downto 0);
signal counter_overflow: std_logic;

begin
	REG_A: REGISTER_16BIT
	port map( clk => clk,
		  rst => rst,
		   en => counter_overflow,
		  din => pwm_reg_a,
		 dout => reg_a_out );
			  
	REG_B: REGISTER_16BIT
	port map( clk => clk,
		  rst => rst,
		   en => counter_overflow,
		  din => pwm_reg_b,
		  dout => reg_b_out );
	  			  
	COUNTER: COUNTER_16BIT
    	port map( clk => clk,
		   en => en,
	          rst => rst,
	     overflow => counter_overflow,
	         dout => p_counter_val,
	        ndout => n_counter_val );
	 
	P_COMPARATOR: COMPARATOR_16BIT
   	port map( clk => clk,
	    	  din => p_counter_val(15 downto 0),
	  	  sel => '0',
	     comp_val => reg_a_out,
	        pwm_o => pwm_out_1 );

    	N_COMPARATOR: COMPARATOR_16BIT
    	port map( clk => clk,
	          din => n_counter_val(15 downto 0),
	          sel => '1',
             comp_val => reg_b_out,
	        pwm_o => pwm_out_2 );

end Behavioral;