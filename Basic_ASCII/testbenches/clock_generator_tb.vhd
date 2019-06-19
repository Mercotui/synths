library ieee;
use ieee.std_logic_1164.all;

entity clock_generator_test is
end clock_generator_test;

architecture test of clock_generator_test is
  signal tb_reset : std_logic := '0';
  signal tb_clk : std_logic := '0';
  signal tb_clk_div : std_logic := '0';
  signal tb_key : std_logic_vector(7 downto 0);
  signal tb_dig0, tb_dig1 : std_logic_vector(7 downto 0);
  signal tb_finished : boolean := false;
begin
  DUT: entity work.clock_generator port map (
    clk => tb_clk,
    reset => tb_reset,
    key => tb_key,
    clk_div => tb_clk_div,
    octave_digit_0 => tb_dig0,
    octave_digit_1 => tb_dig1
  );

  clk_generation : process
	-- constants for clock generation
	constant clk_frequency : integer := 50000000;
	constant clk_period : time := 1 sec / clk_frequency;
	constant clk_half_period : time := clk_period / 2;
	begin
  		if not tb_finished then
  			tb_clk <= '1';
  			wait for clk_half_period;
  			tb_clk <= '0';
  			wait for clk_half_period;
  			else
  				wait;
  		end if;
	end process clk_generation;


  testinput:process
  begin
    tb_reset <= '0';
    wait for 20 ns;
    tb_reset <= '1';
    wait for 500 ns;

    tb_key <= X"1C"; -- Press A
    wait for 500 ns;

    tb_key <= X"43"; -- Press I
    wait for 500 ns;

    tb_key <= X"1A"; -- Press Z
    wait for 500 ns;

    tb_key <= X"15"; -- Press Q
    wait for 500 ns;

    tb_key <= X"1A"; -- Press Z
    wait for 500 ns;

    tb_key <= X"15"; -- Press Q
    wait for 500 ns;

    tb_key <= X"00"; -- Press nothing
    wait for 500 ns;

    tb_key <= X"3A"; -- Press M
    wait for 500 ns;

    -- end simulation by stopping clock and waiting forever
    tb_finished <= true;
    wait;
  end process testinput;
end test;
