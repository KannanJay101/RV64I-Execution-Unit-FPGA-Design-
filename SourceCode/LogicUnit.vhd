library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity LogicUnit is
  generic (
    N : natural := 64
  );
  port (
    A, B     : in  std_logic_vector(N-1 downto 0);
    LogicFN  : in  std_logic_vector(1 downto 0);
    Y        : out std_logic_vector(N-1 downto 0)
  );
end entity LogicUnit;

architecture structural of LogicUnit is

  signal AND_out  : std_logic_vector(N-1 downto 0);
  signal OR_out   : std_logic_vector(N-1 downto 0);
  signal XOR_out  : std_logic_vector(N-1 downto 0);
  signal LUI_out  : std_logic_vector(N-1 downto 0);
  signal MUX1_out : std_logic_vector(N-1 downto 0);
  signal MUX2_out : std_logic_vector(N-1 downto 0);

begin

  -- Perform logic operations
  AND_out <= A and B;
  OR_out  <= A or B;
  XOR_out <= A xor B;
  LUI_out <= B;

  -- First multiplexer: choose between LUI and XOR
  MUX1_out <= LUI_out when LogicFN(1) = '0' else XOR_out;

  -- Second multiplexer: choose between OR and AND
  MUX2_out <= OR_out when LogicFN(1) = '0' else AND_out;

  -- Final multiplexer: choose between MUX1 and MUX2
  Y <= MUX1_out when LogicFN(0) = '0' else MUX2_out;

end architecture structural;
