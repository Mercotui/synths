library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity pulselength is
  port (
    reset : in std_logic;
    key : in std_logic_vector(7 downto 0);
    pulselength : out integer RANGE 0 TO 15000;
    dig0 : out std_logic_vector(7 downto 0);
    dig1 : out std_logic_vector(7 downto 0)
  );
end entity pulselength;

architecture arch of pulselength is
begin
  Frequency_LUT : process(reset, key)
  begin
    if reset = '0' then
      pulselength <= 0;
    else
      case key is
        when X"09" | X"55" => pulselength <= 14204; -- A
        when X"31" | X"38" => pulselength <= 13407; -- A#
        when X"71" | X"69" => pulselength <= 12654; -- B
        when X"77" | X"6F" => pulselength <= 11944; -- C
        when X"33" | X"30" => pulselength <= 11274; -- C#
        when X"65" | X"70" => pulselength <= 10641; -- D
        when X"34" | X"2D" => pulselength <= 10044; -- D#
        when X"72" | X"5B" => pulselength <= 9480; -- E
        when X"74" | X"5D" => pulselength <= 8948; -- F
        when X"36" | X"3D" => pulselength <= 8446; -- F#
        when X"79" | X"0A" => pulselength <= 7972; -- G
        when X"37" | X"08" => pulselength <= 7524; -- G#
        when others =>
          pulselength <= 0;
      end case;
    end if;

    case key is
      when X"09" | X"55" =>  -- TAB u A
        dig0 <= "10001000";
        dig1 <= "11111111";
      when X"31" | X"38" =>  -- 1 8 A#
        dig0 <= "10001000";
        dig1 <= "10010010";
      when X"71" | X"69" =>  -- q i B
        dig0 <= "10000011";
        dig1 <= "11111111";
      when X"77" | X"6F" =>  -- w o C
        dig0 <= "11000110";
        dig1 <= "11111111";
      when X"33" | X"30" =>  -- 3 0 C#
        dig0 <= "11000110";
        dig1 <= "10010010";
      when X"65" | X"70" =>  -- e p D
        dig0 <= "10100001";
        dig1 <= "11111111";
      when X"34" | X"2D" =>  -- 4 - D#
        dig0 <= "10100001";
        dig1 <= "10010010";
      when X"72" | X"5B" =>  -- r [ E
        dig0 <= "10000110";
        dig1 <= "11111111";
      when X"74" | X"5D" =>  -- t ] F
        dig0 <= "10001110";
        dig1 <= "11111111";
      when X"36" | X"3D" =>  -- 6 = F#
        dig0 <= "10001110";
        dig1 <= "10010010";
      when X"79" | X"0A" =>  -- y ENTR G
        dig0 <= "11000010";
        dig1 <= "11111111";
      when X"37" | X"08" =>  -- 7 BSPC G#
        dig0 <= "11000010";
        dig1 <= "10010010";
      when others =>
        dig0 <= "11111111";
        dig1 <= "11111111";
    end case;
  end process;
end architecture;
