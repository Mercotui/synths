library ieee;
use ieee.std_logic_1164.all;

entity audio_generator_test is
end audio_generator_test;

architecture test of audio_generator_test is
  signal tb_clk : std_logic := '0';
  signal tb_reset : std_logic := '0';
  signal tb_pulselength : INTEGER RANGE 0 TO 30000;
  signal tb_finished : boolean := false;
begin
  DUT: entity work.audio_generator port map (
    reset => tb_reset,
    pulselength => tb_pulselength,
    clk_div => tb_clk
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

    tb_pulselength <= 14204; -- Play A at 1760 Hz
    wait for 10 ms;

    tb_pulselength <= 0; -- Play nothing
    wait for 10 ms;

    tb_pulselength <= 8948; -- Play F at 2793 Hz
    wait for 10 ms;

    -- end simulation by stopping clock and waiting forever
    tb_finished <= true;
    wait;
  end process testinput;
end test;
