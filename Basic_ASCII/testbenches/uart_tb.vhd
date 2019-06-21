LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY uart_test IS
Generic (
    tb_clk_freq      : integer := 50e6;   -- set system clock frequency in hz
    tb_baud_rate     : integer := 31250; -- baud rate value
    tb_parity_bit    : string  := "none"; -- legal values: "none", "even", "odd", "mark", "space"
    tb_use_debouncer : boolean := false    -- enable/disable debouncer
);
END uart_test;

ARCHITECTURE test OF uart_test IS
  SIGNAL tb_reset : STD_LOGIC := '0';
  SIGNAL tb_not_reset : STD_LOGIC := '1';
  SIGNAL tb_clk : STD_LOGIC := '0';
  SIGNAL tb_uart_rx : STD_LOGIC := '1';
  SIGNAL tb_uart_tx : STD_LOGIC := '1';
  SIGNAL tb_key : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
  SIGNAL tb_key_ready : STD_LOGIC := '0';
  SIGNAL tb_key_valid : STD_LOGIC := '0';
  SIGNAL tb_frame_error : STD_LOGIC := '0';
  SIGNAL tb_finished : BOOLEAN := FALSE;

  PROCEDURE send_byte(  CONSTANT byte : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
                        SIGNAL uart_tx : OUT STD_LOGIC)
  IS
    constant uart_period : time := 32000 ns;
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

tb_not_reset <= not tb_reset;

DUT: ENTITY work.uart
  generic map (
    CLK_FREQ => tb_clk_freq,
    BAUD_RATE => tb_baud_rate,
    PARITY_BIT => tb_parity_bit,
    USE_DEBOUNCER => tb_use_debouncer
  )
  PORT MAP(
    CLK         => tb_clk,
    RST         => tb_not_reset,
    -- UART INTERFACE
    UART_TXD    => tb_uart_tx,
    UART_RXD    => tb_uart_rx,
    -- USER DATA OUTPUT INTERFACE
    DOUT        => tb_key,
    DOUT_VLD    => tb_key_ready,
    FRAME_ERROR => tb_frame_error,
    -- USER DATA INPUT INTERFACE
    DIN         => tb_key,
    DIN_VLD     => tb_key_valid,
    DIN_RDY     => tb_key_ready
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
    WAIT FOR 100 ns;
    tb_reset <= '1';

    WAIT FOR 1 ms;

    -- Start test

    send_byte(X"09", tb_uart_rx); -- press TAB
    wait for 10 ms;

    -- End simulation by stopping clock and waiting forever
    tb_finished <= TRUE;
    WAIT;
  END PROCESS testinput;
END test;
