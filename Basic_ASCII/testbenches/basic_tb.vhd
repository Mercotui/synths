LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY basic_test IS
END basic_test;

ARCHITECTURE test OF basic_test IS
  SIGNAL tb_reset : STD_LOGIC := '0';
  SIGNAL tb_clk : STD_LOGIC := '0';
  SIGNAL tb_uart_rx : STD_LOGIC := '1';
  SIGNAL tb_audiol : STD_LOGIC := '0';
  SIGNAL tb_audior : STD_LOGIC := '0';
  SIGNAL tb_dig0, tb_dig1, tb_dig2, tb_dig3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL tb_finished : BOOLEAN := FALSE;

  PROCEDURE send_byte(  CONSTANT byte : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
                        SIGNAL uart_tx : OUT STD_LOGIC)
  IS
    constant uart_period : time := 8680.56 ns;
  BEGIN
  uart_tx <= '0'; -- start bit
  wait for uart_period;

  for i in 0 to (byte'LENGTH-1) loop
      uart_tx <= byte(i); -- data bits
      wait for uart_period;
  end loop;

  uart_tx <= '1'; -- stop bit
  wait for uart_period;
  END send_byte;
BEGIN

DUT: ENTITY work.basic
  PORT MAP(

    reset => tb_reset,
    clk => tb_clk,
    uart_rx => tb_uart_rx,
    audiol => tb_audiol,
    audior => tb_audior,
    dig0 => tb_dig0,
    dig1 => tb_dig1,
    dig2 => tb_dig2,
    dig3 => tb_dig3
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
    -- Reset DUT
    tb_reset <= '0';
    WAIT FOR 20 ns;
    tb_reset <= '1';

    -- Start test

    send_byte(X"09", tb_uart_rx); -- press TAB
    wait for 10 ms;

    -- End simulation by stopping clock and waiting forever
    tb_finished <= TRUE;
    WAIT;
  END PROCESS testinput;
END test;
