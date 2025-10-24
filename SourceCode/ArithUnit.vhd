library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity ArithUnit is
  generic (
    N : natural := 64
  );
  port (
    A, B              : in  std_logic_vector(N-1 downto 0);
    AddnSub, ExtWord  : in  std_logic := '0';
    Y                 : out std_logic_vector(N-1 downto 0);
    Cout, Ovfl        : out std_logic;
    Zero              : out std_logic;
    AltB, AltBu       : out std_logic
  );
end entity ArithUnit;


----------------------------Baseline Design---------------------------------------
--
architecture baseline of ArithUnit is

  signal operand_B     : std_logic_vector(N-1 downto 0);
  signal sum_result    : std_logic_vector(N-1 downto 0);
  signal temp_Cout     : std_logic := '0';
  signal temp_Ovfl     : std_logic := '0';
  signal all_zero      : std_logic_vector(N-1 downto 0) := (others => '0');

begin

  -- Decide whether to use B or ~B based on AddnSub
  operand_B <= B when AddnSub = '1' else NOT(B);

  -- Instantiate the ripple adder
  AdderInst : entity work.Adder(ripple)
    generic map (N => N)
    port map (
      A    => A,
      B    => operand_B,
      S    => sum_result,
      Cin  => AddnSub,       -- Cin = 1 for subtraction (2's complement)
      Cout => temp_Cout,
      Ovfl => temp_Ovfl
    );

  -- Assign outputs
  Y     <= sum_result;
  Cout  <= temp_Cout;
  Ovfl  <= temp_Cout xor temp_Ovfl;
  Zero  <= '1' when sum_result = all_zero else '0';
  AltB  <= sum_result(N-1) xor temp_Ovfl; -- Signed compare
  AltBu <= not temp_Cout;                -- Unsigned compare

end architecture baseline;


---------------- Ripple Adder with Plus Operator Design------------------

--architecture rippleOP of ArithUnit is
--
--  signal operand_B     : std_logic_vector(N-1 downto 0);
--  signal sum_result    : std_logic_vector(N-1 downto 0);
--  signal temp_Cout     : std_logic := '0';
--  signal temp_Ovfl     : std_logic := '0';
--  signal all_zero      : std_logic_vector(N-1 downto 0) := (others => '0');
--
--begin
--
--  -- Decide whether to use B or ~B based on AddnSub
--  operand_B <= B when AddnSub = '1' else NOT(B);
--
--  -- Instantiate the ripple adder
--  AdderInst : entity work.Adder(ripple_plusOP)
--    generic map (N => N)
--    port map (
--      A    => A,
--      B    => operand_B,
--      S    => sum_result,
--      Cin  => AddnSub,       -- Cin = 1 for subtraction (2's complement)
--      Cout => temp_Cout,
--      Ovfl => temp_Ovfl
--    );
--
--  -- Assign outputs
--  Y     <= sum_result;
--  Cout  <= temp_Cout;
--  Ovfl  <= temp_Cout xor temp_Ovfl;
--  Zero  <= '1' when sum_result = all_zero else '0';
--  AltB  <= sum_result(N-1) xor temp_Ovfl; -- Signed compare
--  AltBu <= not temp_Cout;                -- Unsigned compare
--
--end architecture rippleOP;


