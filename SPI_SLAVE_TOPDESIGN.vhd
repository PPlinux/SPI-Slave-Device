----------------------------------------------------------------------------------
-- Company: 		Emsys Embedded Systems Thomas More Mechelen Antwerpen
-- Research:		MICAS ESAT KU Leuven
-- Engineer:		Nick Destrycker 
-- Researcher:		Patrick Pelgrims 
-- Create Date:     
-- Design Name: 	SPI Slave 
-- Module Name:   	Top Level System - Behavioral 
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
-- SPI STATUS REG BIT ORDER:
--   7: RST_ALL
--   6: PWM_EN
--   5: FREQ_EN
--   4: FREQ INTERRUPT FLAG
--   3: FREQ MODE SELECT FLAG
--	- '0': one shot sample(count once after reading freq))
--	- '1': continuous sample(continiously read frequency)
--   2: 
--   1: 
--   0: 
--
------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

--library synplify;
--use synplify.attributes.all;

------------------------------------------------------------------------------------

entity bionic_eye_spi_slave is
	port ( CLK      : in  std_logic;
	       SCK      : in  std_logic;
	       CS	: in  std_logic;
	       MOSI     : in  std_logic;
	       MISO	: out std_logic;
	       FREQ_IN	: in  std_logic;
	       PWM_OUT_1: out std_logic;
	       PWM_OUT_2: out std_logic );
end bionic_eye_spi_slave;

------------------------------------------------------------------------------------
architecture Behavioral of bionic_eye_spi_slave is
------------------------------------------------------------------------------------

	component PWM_CORE_LAT_V17 is
		Port ( clk      : in  std_logic;
		       rst      : in  std_logic;
		       en       : in  std_logic;
		       pwm_reg_a: in  std_logic_vector(15 downto 0);
		       pwm_reg_b: in  std_logic_vector(15 downto 0);
		       pwm_out_1: out std_logic;
		       pwm_out_2: out std_logic );
	end component;

	component FREQCOUNT_CORE_V4 is
		Port ( clk	: in  std_logic;  
		       rst	: in  std_logic;
		       en	: in  std_logic;
		       cnt_clk	: in  std_logic;
		       int	: out std_logic;
		       int_ack	: in  std_logic;
		       freq     : out std_logic_vector(31 downto 0);
		       interval_time: in  std_logic_vector(31 downto 0) );
	end component;
	
------------------------------------------------------------------------------------

	-- SPI PROTOCOL SIGNALS
	signal SCK_latched	: std_logic:='0';
	signal SCK_old		: std_logic:='0';
	signal CS_latched 	: std_logic:='0';
	signal CS_old		: std_logic:='0';
	signal MOSI_latched	: std_logic:='0';
	signal spi_done		: std_logic:='0';
	signal msg_bit_index 	: integer range 0 to 7:=0;
	signal msg_cnt		: integer range 0 to 3:=0;
	
	-- SPI REGISTERS
	signal miso_reg   : std_logic_vector(7 downto 0);
	signal mosi_reg   : std_logic_vector(7 downto 0);
	signal status_reg : std_logic_vector(7 downto 0):=X"00";
	
	-- COMMAND SIGNALS
	signal W_STATUS_CMD 	: std_logic:='0';
	signal W_PWM_CMD	: std_logic:='0';
	signal R_PWM_CMD	: std_logic:='0';
	signal R_FREQ_CMD	: std_logic:='0';
	signal W_FREQ_CMD	: std_logic:='0';

	
	-- PWM CORE PERIPHERAL SIGNALS
	signal pwm_reg: std_logic_vector(15 downto 0):=X"0000";
	
	-- FREQ CORE PERIPHERAL SIGNALS
	signal freq_cnt		: std_logic_vector(31 downto 0);
	signal interrupt	: std_logic:='0';
	signal interrupt_ack 	: std_logic:='0';
	signal int_ack_pulse 	: std_logic_vector(2 downto 0):="000";
	signal freq_gen_int	: std_logic:='0';
	signal interval_time 	: std_logic_vector(31 downto 0):=X"00000000";
	
	--attribute syn_keep of FREQ_CORE: label is true;
	
------------------------------------------------------------------------------------
begin
------------------------------------------------------------------------------------

	PWM_CORE: PWM_CORE_LAT_V17
	port map( clk => CLK,
		  rst => status_reg(7),
		   en => status_reg(6),
	    pwm_reg_a => pwm_reg,
	    pwm_reg_b => pwm_reg,
	    pwm_out_1 => PWM_OUT_1,
	    pwm_out_2 => PWM_OUT_2 );

	FREQ_CORE: FREQCOUNT_CORE_V4
	port map( clk => CLK,
		  rst => status_reg(7),
		   en => status_reg(5),
	      cnt_clk => FREQ_IN,
		  int => interrupt,
	      int_ack => interrupt_ack,
		 freq => freq_cnt,
	interval_time => interval_time );	
	
------------------------------------------------------------------------------------

	process(CLK) begin
		if( rising_edge(CLK) ) then
			SCK_latched <= SCK;
			    SCK_old <= SCK_latched;
			 CS_latched <= CS;
			     CS_old <= CS_latched;
			   --spi_done <= '0';
		   MOSI_latched <= MOSI;
		   status_reg(4) <= interrupt;

			if (CS_old = '1' and CS_latched = '0') then
				msg_bit_index <= 7;
			end if;

			if( CS_latched = '0' ) then
				if(SCK_old = '0' and SCK_latched = '1') then
					mosi_reg <= mosi_reg(6 downto 0) & MOSI_latched;
					miso_reg <= miso_reg(6 downto 0) & '0';
					if(msg_bit_index = 0) then -- cycle ended
						msg_bit_index <= 7;
					else
						msg_bit_index <= msg_bit_index-1;
					end if;
				elsif(SCK_old = '1' and SCK_latched = '0') then
					if( msg_bit_index = 7 ) then
						spi_done <= '1';
					end if;
				end if;
			end if;
			
			-- SPI BYTE RECEIVED
			if(spi_done = '1') then
			spi_done <= '0';
				if(W_PWM_CMD = '1') then
					case msg_cnt is
						when 1 => pwm_reg(15 downto 8) <= mosi_reg;
						when 0 => pwm_reg(7 downto 0) <= mosi_reg;
								  W_PWM_CMD <= '0';
						when others => null;
					end case;
					msg_cnt <= msg_cnt - 1;
				elsif(R_PWM_CMD = '1') then
					miso_reg <= pwm_reg(7 downto 0);
					R_PWM_CMD <= '0';
				elsif(W_STATUS_CMD = '1') then
					status_reg <= mosi_reg;
					W_STATUS_CMD <= '0';
				elsif(R_FREQ_CMD = '1') then
						case msg_cnt is
							when 2 => miso_reg <= freq_cnt(23 downto 16);
							when 1 => miso_reg <= freq_cnt(15 downto 8);
							when 0 => miso_reg <= freq_cnt(7 downto 0);
									  R_FREQ_CMD <= '0';
									  freq_gen_int <= '1'; -- restart counting (one shot) after reading the freq
							when others => null;
						end case;
						msg_cnt <= msg_cnt - 1;
				elsif(W_FREQ_CMD = '1') then
					case msg_cnt is
						when 3 => interval_time(31 downto 24) <= mosi_reg;
						when 2 => interval_time(23 downto 16) <= mosi_reg;
						when 1 => interval_time(15 downto 8) <= mosi_reg;
						when 0 => interval_time(7 downto 0) <= mosi_reg;
							W_FREQ_CMD <= '0';
							freq_gen_int <= '1'; -- restart counting (one shot) after setting a new interval
						when others => null;
					end case;
					msg_cnt <= msg_cnt - 1;
				-- WRITE TO REGISTERS
				elsif(mosi_reg(7) = '1') then
					case mosi_reg(6 downto 0) is
						when "0000001" => W_STATUS_CMD <= '1';
						when "0000010" => W_PWM_CMD <= '1';
								  msg_cnt <= 1;
						when "0000011" => W_FREQ_CMD <= '1';
								  msg_cnt <= 3;
						when others => null;
					end case;
				-- READ FROM REGISTERS
				elsif(mosi_reg(7) = '0') then
					case mosi_reg(6 downto 0) is
						when "0000001" => miso_reg <= status_reg;
						when "0000010" => R_PWM_CMD <= '1';
								  miso_reg <= pwm_reg(15 downto 8);
						when "0000011" => miso_reg <= freq_cnt(31 downto 24);
								  R_FREQ_CMD <= '1';
								  msg_cnt <= 2;
						when others => null;
					end case;
				end if;
			end if;
			
			-- generate interrupt_ack pulse for 3 klokcycles
			-- only if FREQ MODE SELECT FLAG = 0 !
			if( (freq_gen_int = '1') and (status_reg(3) = '0') ) then
				interrupt_ack <= '1';
				int_ack_pulse <= int_ack_pulse(1 downto 0) & interrupt_ack;
				if(int_ack_pulse = "111") then
					interrupt_ack <= '0';
					freq_gen_int <= '0';
				end if;
			elsif(status_reg(3) = '1') then
				int_ack_pulse <= int_ack_pulse(1 downto 0) & interrupt;
					if(int_ack_pulse = "111") then
						interrupt_ack <= '1';
					elsif(int_ack_pulse = "000") then
						interrupt_ack <= '0';
					end if;	
			end if;

						
		end if;
	end process;

------------------------------------------------------------------------------------

MISO <= miso_reg(7);

------------------------------------------------------------------------------------
end Behavioral;
------------------------------------------------------------------------------------