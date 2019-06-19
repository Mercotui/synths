library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity basic is
  Generic (
      CLK_FREQ      : integer := 50e6;   -- set system clock frequency in Hz
      BAUD_RATE     : integer := 31250; -- baud rate value
      PARITY_BIT    : string  := "none"; -- legal values: "none", "even", "odd", "mark", "space"
      USE_DEBOUNCER : boolean := false    -- enable/disable debouncer
  );
  Port (
    clk : in std_logic;
    reset : in std_logic;
    uart_rx : in std_logic;
    audiol : out std_logic;
    audior : out std_logic;
    dig0 : out std_logic_vector(7 downto 0);
    dig1 : out std_logic_vector(7 downto 0);
    dig2 : out std_logic_vector(7 downto 0);
    dig3 : out std_logic_vector(7 downto 0);
    dig4 : out std_logic_vector(7 downto 0);
    dig5 : out std_logic_vector(7 downto 0)
  );
end basic;

architecture basic_struct of basic is
  signal key : std_logic_vector(7 downto 0);
  signal key_valid : std_logic;
  signal key_ready : std_logic;
begin
  uart_i: entity work.UART generic map (
        CLK_FREQ      => CLK_FREQ,
        BAUD_RATE     => BAUD_RATE,
        PARITY_BIT    => PARITY_BIT,
        USE_DEBOUNCER => USE_DEBOUNCER
    )
    port map (
        CLK         => clk,
        RST         => reset,
        -- UART INTERFACE
        UART_TXD    => open,
        UART_RXD    => uart_rx,
        -- USER DATA OUTPUT INTERFACE
        DOUT        => open,
        DOUT_VLD    => open,
        FRAME_ERROR => open,
        -- USER DATA INPUT INTERFACE
        DIN         => key,
        DIN_VLD     => key_valid,
        DIN_RDY     => key_ready
  );

  L_tone: entity work.tone port map(
    reset => reset,
    clk => clk,
    key => key,
    audiol => audiol,
    audior => audior,
    dig2 => dig2,
    dig3 => dig3,
    dig4 => dig4,
    dig5 => dig5
  );
end basic_struct;
