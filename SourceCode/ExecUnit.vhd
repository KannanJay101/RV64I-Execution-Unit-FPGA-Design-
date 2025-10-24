library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity ExecUnit is
  generic (
    N : natural := 64
  );
  port (
    A, B            : in  std_logic_vector(N-1 downto 0);
    FuncClass       : in  std_logic_vector(1 downto 0);
    LogicFN         : in  std_logic_vector(1 downto 0);
    ShiftFN         : in  std_logic_vector(1 downto 0);
    AddnSub         : in  std_logic := '0';
    ExtWord         : in  std_logic := '0';
    Y               : out std_logic_vector(N-1 downto 0);
    Zero            : out std_logic;
    AltB, AltBu     : out std_logic
  );
end entity ExecUnit;

architecture structural of ExecUnit is

  -- Intermediate results from sub-units
  signal ShiftUnit_out    : std_logic_vector(N-1 downto 0);
  signal ArithUnit_out    : std_logic_vector(N-1 downto 0);
  signal LogicUnit_out    : std_logic_vector(N-1 downto 0);

  -- Unused but connected internally
  signal Cout, Ovfl       : std_logic := '0';

  -- Zero-padding for AltB/AltBu SLT outputs
  signal AltB_Ext         : std_logic_vector(N-2 downto 0) := (others => '0');
  signal AltBu_Ext        : std_logic_vector(N-2 downto 0) := (others => '0');

  -- Intermediate signals for SLT and SLTU flags
  signal AltB_sig         : std_logic := '0';
  signal AltBu_sig        : std_logic := '0';

begin

  -- Arithmetic Unit instantiation
  inst_ArithUnit : entity work.ArithUnit(baseline)
    generic map (N => N)
    port map (
      A       => A,
      B       => B,
      AddnSub => AddnSub,
      ExtWord => ExtWord,
      Y       => ArithUnit_out,
      Cout    => Cout,
      Ovfl    => Ovfl,
      Zero    => Zero,
      AltB    => AltB_sig,
      AltBu   => AltBu_sig
    );

  -- Assign SLT/SLTU outputs
  AltB  <= AltB_sig;
  AltBu <= AltBu_sig;

  -- Shift Unit instantiation
  inst_ShiftUnit : entity work.ShiftUnit(eightChannelMUX)
    generic map (N => N)
    port map (
      A        => A,
      B        => B,
      S        => ArithUnit_out,
      ShiftFN  => ShiftFN,
      ExtWord  => ExtWord,
      Y        => ShiftUnit_out
    );

  -- Logic Unit instantiation
  inst_LogicUnit : entity work.LogicUnit(structural)
    generic map (N => N)
    port map (
      A       => A,
      B       => B,
      LogicFN => LogicFN,
      Y       => LogicUnit_out
    );

  -- Main output selection based on FuncClass
  Y <= ShiftUnit_out              when FuncClass = "00" else
       LogicUnit_out              when FuncClass = "01" else
       AltB_Ext & AltB_sig        when FuncClass = "10" else
       AltBu_Ext & AltBu_sig;

end architecture structural;
