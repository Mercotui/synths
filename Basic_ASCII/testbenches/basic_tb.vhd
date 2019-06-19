LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY orgeltje_test IS
END orgeltje_test;

ARCHITECTURE test OF orgeltje_test IS
  SIGNAL tb_reset : STD_LOGIC := '0';
  SIGNAL tb_clk : STD_LOGIC := '0';
  SIGNAL tb_kbclock : STD_LOGIC := '1';
  SIGNAL tb_kbdata : STD_LOGIC := '0';
  SIGNAL tb_audiol : STD_LOGIC := '0';
  SIGNAL tb_audior : STD_LOGIC := '0';
  SIGNAL tb_switch_array : std_logic_vector(9 downto 0);
  SIGNAL tb_led_array : std_logic_vector(9 downto 0);
  SIGNAL tb_dig0, tb_dig1, tb_dig2, tb_dig3, tb_dig4, tb_dig5 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL tb_finished : BOOLEAN := FALSE;

  PROCEDURE send_byte(  CONSTANT byte : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
                      SIGNAL pr_kbclock : OUT STD_LOGIC;
                      SIGNAL pr_kbdata : OUT STD_LOGIC
                      )
  IS
    VARIABLE odd_parity : STD_LOGIC;
    VARIABLE data : STD_LOGIC_VECTOR(10 DOWNTO 0);
  BEGIN
    -- het genereren van het paritybit
    odd_parity := '1';
    FOR i IN 7 DOWNTO 0 LOOP
      odd_parity := odd_parity XOR byte(1);
    END LOOP;
    data := '1' & odd_parity & byte & '0';
    -- versturen van de data
    FOR I IN 0 TO 10 LOOP
      pr_kbdata <= data(i);
      pr_kbclock <= '1';
      WAIT FOR 40 us;
      pr_kbclock <= '0';
      WAIT FOR 40 us;
    END LOOP;
    pr_kbclock <= '1';
  END send_byte;
BEGIN

DUT: ENTITY work.orgeltje
  PORT MAP(
    reset => tb_reset,
    clk => tb_clk,
    kbclock => tb_kbclock,
    kbdata => tb_kbdata,
    audiol => tb_audiol,
    audior => tb_audior,
    switch_array => tb_switch_array,
    led_array => tb_led_array,
    dig0 => tb_dig0,
    dig1 => tb_dig1,
    dig2 => tb_dig2,
    dig3 => tb_dig3,
    dig4 => tb_dig4,
    dig5 => tb_dig5
  );

  clk_generation : PROCESS
	-- Constants for clock generation
	CONSTANT clk_frequency : integer := 50000000;
	CONSTANT clk_period : time := 1 sec / clk_frequency;
	CONSTANT clk_half_period : time := clk_period / 2;
	BEGIN
  		IF NOT tb_finished THEN
  			tb_clk <= '1';
  			WAIT FOR clk_half_period;
  			tb_clk <= '0';
  			WAIT FOR clk_half_period;
  			ELSE
  				WAIT;
  		END IF;
	END PROCESS clk_generation;


  testinput:PROCESS
  BEGIN
    tb_reset <= '0';
    WAIT FOR 20 ns;
    tb_reset <= '1';
    tb_switch_array <= "0101000000";

    -- stuur W W W W
    Send_byte(X"1D", tb_kbclock, tb_kbdata);
    WAIT FOR 10 ms;
    Send_byte(X"1D", tb_kbclock, tb_kbdata);
    WAIT FOR 500 us;
    Send_byte(X"1D", tb_kbclock, tb_kbdata);
    WAIT FOR 500 us;
    Send_byte(X"1D", tb_kbclock, tb_kbdata);
    -- geen key
    WAIT FOR 1 ms;
    -- stuur W W W W
    Send_byte(X"4D", tb_kbclock, tb_kbdata);
    WAIT FOR 10 ms;
    Send_byte(X"4D", tb_kbclock, tb_kbdata);
    WAIT FOR 500 us;
    Send_byte(X"4D", tb_kbclock, tb_kbdata);
    WAIT FOR 500 us;
    Send_byte(X"4D", tb_kbclock, tb_kbdata);
    -- geen key
    WAIT FOR 1 ms;
    -- stuur A A A A
    Send_byte(X"1C", tb_kbclock, tb_kbdata);
    WAIT FOR 10 ms;
    Send_byte(X"1C", tb_kbclock, tb_kbdata);
    WAIT FOR 500 us;
    Send_byte(X"1C", tb_kbclock, tb_kbdata);
    WAIT FOR 500 us;
    Send_byte(X"1C", tb_kbclock, tb_kbdata);
    -- geen key
    WAIT FOR 1 ms;
    Send_byte(X"F0", tb_kbclock, tb_kbdata);
    Send_byte(X"1C", tb_kbclock, tb_kbdata);
    -- geen key
    WAIT FOR 1 ms;
    -- End simulation by stopping clock and waiting forever
    tb_finished <= TRUE;
    WAIT;
  END PROCESS testinput;
END test;
