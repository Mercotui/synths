library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tone is
  Port (
    clk : in std_logic;
    reset : in std_logic;
    key : in std_logic_vector(7 downto 0);
    audiol : out std_logic;
    audior : out std_logic;
    dig2 : out std_logic_vector(7 downto 0);
    dig3 : out std_logic_vector(7 downto 0);
    dig4 : out std_logic_vector(7 downto 0);
    dig5 : out std_logic_vector(7 downto 0)
  );
end tone;

architecture tone_struct of tone is
  signal C_clk_div : std_logic;
  signal C_pulse_length : integer range 0 to 30000;
begin
  L_clock_generator: entity work.clock_generator port map(
    clk => clk,
    reset => reset,
    key => key,
    clk_div => C_clk_div,
    octave_digit_0 => dig2,
    octave_digit_1 => dig3
  );

  L_pulselength: entity work.pulselength port map(
    reset => reset,
    key => key,
    pulselength => C_pulse_length,
    dig0 => dig4,
    dig1 => dig5
  );

  L_audio_generator: entity work.audio_generator port map(
    reset => reset,
    clk_div => C_clk_div,
    pulselength => C_pulse_length,
    audiol => audiol,
    audior => audior
  );
end tone_struct;
