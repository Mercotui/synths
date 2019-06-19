library ieee;
use ieee.std_logic_1164.all;

entity pulselength_test is
end pulselength_test;

architecture test of pulselength_test is
  signal tb_reset : std_logic := '0';
  signal tb_pulselength : INTEGER RANGE 0 TO 15000;
  signal tb_key : std_logic_vector(7 downto 0);
  signal tb_dig0, tb_dig1 : std_logic_vector(7 downto 0);
  signal tb_finished : boolean := false;
begin
  DUT: entity work.pulselength port map (
    reset => tb_reset,
    key => tb_key,
    pulselength => tb_pulselength,
    dig0 => tb_dig0,
    dig1 => tb_dig1
  );

  testinput:process
  begin
    tb_reset <= '0';
    wait for 20 ns;
    tb_reset <= '1';
    wait for 500 ns;

    tb_key <= X"00"; -- Press nothing
    wait for 500 ns;

    tb_key <= X"1C"; -- Press A
    wait for 500 ns;

    tb_key <= X"1A"; -- Press Z
    wait for 500 ns;

    tb_key <= X"0D"; -- Press TAB = A
    wait for 500 ns;

    tb_key <= X"26"; -- Press 3 = C#
    wait for 500 ns;

    tb_key <= X"3C"; -- Press U = A
    wait for 500 ns;

    tb_key <= X"00"; -- Press nothing
    wait for 500 ns;

    tb_key <= X"54"; -- Press [ = E
    wait for 500 ns;


    tb_key <= X"55"; -- Press = = F#
    wait for 500 ns;

    tb_key <= X"00"; -- Press nothing
    wait for 500 ns;

    -- end simulation by stopping clock and waiting forever
    tb_finished <= true;
    wait;
  end process testinput;
end test;
