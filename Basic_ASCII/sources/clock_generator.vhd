library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity clock_generator is
  port (
    clk : in std_logic;
    reset : in std_logic;
    key : in std_logic_vector(7 downto 0);
    clk_div : out std_logic;
    octave_digit_0 : out std_logic_vector(7 downto 0);
    octave_digit_1 : out std_logic_vector(7 downto 0)
  );
end entity;

architecture arch of clock_generator is
  -- key signals
  signal octave_change_keys : std_logic;
  signal octave_high_select : std_logic;
  -- Octaves
  type octaves is (oct_0, oct_1, oct_2, oct_3, oct_4, oct_5, oct_6);
  -- Register to hold the current octave
  signal current_base_octave, next_base_octave : octaves;
  -- Clock lines
  signal clk_50_MHz : std_logic;
  signal clk_25_MHz : std_logic;
  signal clk_12_5_MHz : std_logic;
  signal clk_6_25_MHz : std_logic;
  signal clk_3_125_MHz : std_logic;
  signal clk_1_5625_MHz : std_logic;
  signal clk_0_78125_MHz : std_logic;
begin
  octave_state : process(clk, reset, next_base_octave)
    variable octave_change_keys_buffer : std_logic_vector(1 downto 0);
  begin
    if reset = '0' then
      octave_change_keys_buffer := "00";
      current_base_octave <= oct_2;
    elsif rising_edge (clk) then
      -- Keep last sample of up and down key
      octave_change_keys_buffer := octave_change_keys_buffer(0) & octave_change_keys;

      -- Transition states if either up or down key is had rising edge
      if octave_change_keys_buffer = "01" then
        current_base_octave <= next_base_octave;
      end if;
    end if;
  end process;

  key_interpreter : process(key, current_base_octave)
  begin
    case(key) is
      when X"55" | X"38" | X"69" | X"6F" | X"30" | X"70" | X"2D" | X"5B" | X"5D" | X"3D" | X"0A" | X"08" =>
      -- U, 8, I, O, 0, P, -, [, ], =, ENTR, BKSP
      octave_change_keys <= '0';
      octave_high_select <= '1';
      next_base_octave <= current_base_octave;
      when X"61" => -- A
        octave_change_keys <= '1';
        octave_high_select <= '0';
        case(current_base_octave) is
          when oct_0 => next_base_octave <= oct_1;
          when oct_1 => next_base_octave <= oct_2;
          when oct_2 => next_base_octave <= oct_3;
          when oct_3 => next_base_octave <= oct_4;
          when oct_4 => next_base_octave <= oct_5;
          when oct_5 => next_base_octave <= oct_5;
          when oct_6 => next_base_octave <= oct_5;
        end case;
      when X"7A" => -- Z
          octave_change_keys <= '1';
          octave_high_select <= '0';
          case(current_base_octave) is
            when oct_0 => next_base_octave <= oct_0;
            when oct_1 => next_base_octave <= oct_0;
            when oct_2 => next_base_octave <= oct_1;
            when oct_3 => next_base_octave <= oct_2;
            when oct_4 => next_base_octave <= oct_3;
            when oct_5 => next_base_octave <= oct_4;
            when oct_6 => next_base_octave <= oct_5;
          end case;
      when others => -- All other keys
        octave_change_keys <= '0';
        octave_high_select <= '0';
        next_base_octave <= current_base_octave;
    end case;
  end process key_interpreter;

  clock_selector : process(current_base_octave, octave_high_select,
    clk_50_MHz, clk_25_MHz, clk_12_5_MHz, clk_6_25_MHz, clk_3_125_MHz, clk_1_5625_MHz, clk_0_78125_MHz)
  begin
    if octave_high_select = '1' then
      case (current_base_octave) is
        when oct_0 => clk_div <= clk_1_5625_MHz;
        when oct_1 => clk_div <= clk_3_125_MHz;
        when oct_2 => clk_div <= clk_6_25_MHz;
        when oct_3 => clk_div <= clk_12_5_MHz;
        when oct_4 => clk_div <= clk_25_MHz;
        when oct_5 => clk_div <= clk_50_MHz;
        when oct_6 => clk_div <= clk_50_MHz;
      end case;
    else
      case (current_base_octave) is
        when oct_0 => clk_div <= clk_0_78125_MHz;
        when oct_1 => clk_div <= clk_1_5625_MHz;
        when oct_2 => clk_div <= clk_3_125_MHz;
        when oct_3 => clk_div <= clk_6_25_MHz;
        when oct_4 => clk_div <= clk_12_5_MHz;
        when oct_5 => clk_div <= clk_25_MHz;
        when oct_6 => clk_div <= clk_50_MHz;
      end case;
    end if;

    -- Also show current octave numbers on 7-Segment
    case (current_base_octave) is
      when oct_0 =>
        octave_digit_0 <= "11000000"; -- "0"
        octave_digit_1 <= "11111001"; -- "1"
      when oct_1 =>
        octave_digit_0 <= "11111001"; -- "1"
        octave_digit_1 <= "10100100"; -- "2"
      when oct_2 =>
        octave_digit_0 <= "10100100"; -- "2"
        octave_digit_1 <= "10110000"; -- "3"
      when oct_3 =>
        octave_digit_0 <= "10110000"; -- "3"
        octave_digit_1 <= "10011001"; -- "4"
      when oct_4 =>
        octave_digit_0 <= "10011001"; -- "4"
        octave_digit_1 <= "10010010"; -- "5"
      when oct_5 =>
        octave_digit_0 <= "10010010"; -- "5"
        octave_digit_1 <= "10000010"; -- "6"
      when oct_6 =>
        octave_digit_0 <= "10000110"; -- "E"
        octave_digit_1 <= "10101111"; -- "R"
    end case;
  end process clock_selector;

  -- Divides the 50 MHz clock into 1, 1/2, 1/4, 1/8, 1/16, 1/32 and 1/64
  clock_divider : process(clk, reset)
  -- Remember the counts only need to reach half the clock cycle,
  -- as this is when the clock lines are inverted.
  variable cnt_12_5 : integer range 0 to 2;
  variable cnt_6_25 : integer range 0 to 4;
  variable cnt_3_125 : integer range 0 to 8;
  variable cnt_1_5625 : integer range 0 to 16;
  variable cnt_0_78125 : integer range 0 to 32;
  begin
    if reset = '0' then
      -- Init Counters
      cnt_12_5 := 0;
      cnt_6_25 := 0;
      cnt_3_125 := 0;
      cnt_1_5625 := 0;
      cnt_0_78125 := 0;
      -- Init Clock Lines
      clk_25_MHz <= '0';
      clk_12_5_MHz <= '0';
      clk_6_25_MHz <= '0';
      clk_3_125_MHz <= '0';
      clk_1_5625_MHz <= '0';
      clk_0_78125_MHz <= '0';
    elsif rising_edge(clk) then
      -- 25 MHz
      clk_25_MHz <= not clk_25_MHz;
      -- 12.5 MHz
      if cnt_12_5 = 1 then
        clk_12_5_MHz <= not clk_12_5_MHz;
        cnt_12_5 := 0;
      else
        cnt_12_5 := cnt_12_5 + 1;
      end if;
      -- 6.25MHz
      if cnt_6_25 = 3 then
        clk_6_25_MHz <= not clk_6_25_MHz;
        cnt_6_25 := 0;
      else
        cnt_6_25 := cnt_6_25 + 1;
      end if;
      -- 3.125 MHz
      if cnt_3_125 = 7 then
        clk_3_125_MHz <= not clk_3_125_MHz;
        cnt_3_125 := 0;
      else
        cnt_3_125 := cnt_3_125 + 1;
      end if;
      -- 1.5625 MHz
      if cnt_1_5625 = 15 then
        clk_1_5625_MHz <= not clk_1_5625_MHz;
        cnt_1_5625 := 0;
      else
        cnt_1_5625 := cnt_1_5625 + 1;
      end if;
      -- 0.78125 MHz
      if cnt_0_78125 = 31 then
        clk_0_78125_MHz <= not clk_0_78125_MHz;
        cnt_0_78125 := 0;
      else
        cnt_0_78125 := cnt_0_78125 + 1;
      end if;
    end if;
    -- 50 Mhz
    clk_50_MHz <= clk;
  end process clock_divider;
end architecture;
