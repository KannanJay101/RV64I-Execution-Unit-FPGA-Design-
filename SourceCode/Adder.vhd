library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Adder is
  generic(N : natural := 64);
  port(
    A, B  : in  std_logic_vector(N-1 downto 0);
    S     : out std_logic_vector(N-1 downto 0);
    Cin   : in  std_logic;
    Cout, Ovfl : out std_logic
  );
end entity Adder;

architecture ripple of Adder is
  signal carry : std_logic_vector(N downto 0);  -- includes Cin and final Cout
begin

  carry(0) <= Cin;

  adder_loop : for i in 0 to N-1 generate
    process(A(i), B(i), carry(i))
    begin
      -- Full adder logic
      S(i)     <= A(i) xor B(i) xor carry(i);
      carry(i+1) <= (A(i) and B(i)) or (A(i) and carry(i)) or (B(i) and carry(i));
    end process;
  end generate;

  Cout <= carry(N);

  -- Overflow detection
  Ovfl <= carry(N) xor carry(N-1);  -- Standard overflow logic

end architecture ripple;


----------------------------Ripple Plus Operation-----------------------------------------------

--architecture ripple_plusOP of Adder is
--
--	signal temp : std_logic_vector(N downto 0);
--
--begin
--	
--	temp <= ('0' & A) + ('0' & B) + Cin; -- Concatenate
--	S <= temp(N-1 downto 0);
--	
--	Ovfl <= (A(N-1) and B(N-1) and not temp(N-1)) or
--            (not A(N-1) and not B(N-1) and temp(N-1));
--						
--	Cout <= temp(N);
--
--end architecture ripple_plusOP;