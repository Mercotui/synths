library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity audio_generator is
  port (
    reset : in std_logic;
    clk_div : in std_logic;
    pulselength : in integer range 0 to 30000;
    audiol : out std_logic;
    audior : out std_logic
  );
end entity;

architecture arch of audio_generator is
begin
  audio_generation : process(reset, clk_div, pulselength)
    variable audio_count : integer range 0 to 30000;
    variable audiol_intermediate : std_logic;
    variable audior_intermediate : std_logic;
  begin
    if reset = '0' or pulselength = 0 then
      audiol_intermediate := '0';
      audior_intermediate := '0';
      audio_count := 0;
    elsif rising_edge(clk_div) then
      if audio_count >= pulselength then
        audio_count := 0;
        audiol_intermediate := not audiol_intermediate;
        audior_intermediate := not audior_intermediate;
      else
        audio_count := audio_count + 1;
      end if;
    end if;
    audiol <= audiol_intermediate;
    audior <= audior_intermediate;
  end process audio_generation;
end architecture;
