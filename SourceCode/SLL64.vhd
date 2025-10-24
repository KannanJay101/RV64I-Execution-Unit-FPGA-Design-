library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;

entity SLL64 is
  generic (
    N : natural := 64
  );
  port (
    X          : in  std_logic_vector(N-1 downto 0);
    ShiftCount : in  std_logic_vector(5 downto 0);
    Y          : out std_logic_vector(N-1 downto 0)
  );
end entity SLL64;

---------------------------Baseline Design (Simpleshift)------------------------------------------
Architecture simpleShift of SLL64 is
begin
	Y <= std_logic_vector( shift_left(unsigned(X), to_integer( unsigned(ShiftCount) ) ) );
	
End Architecture simpleShift;

-------------------------------2 CHANNEL MUX-----------------------------------------------------

architecture twoChannelMUX of SLL64 is

  signal MUX1_out, MUX2_out, MUX3_out, MUX4_out, MUX5_out, MUX6_out : std_logic_vector(N-1 downto 0);
begin

  -- Shift by 0 or 32
  MUX1_out <= X when ShiftCount(5) = '0' else
              std_logic_vector(shift_left(unsigned(X), 32));

  -- Shift by additional 0 or 16
  MUX2_out <= MUX1_out when ShiftCount(4) = '0' else
              std_logic_vector(shift_left(unsigned(MUX1_out), 16));

  -- Shift by additional 0 or 8
  MUX3_out <= MUX2_out when ShiftCount(3) = '0' else
              std_logic_vector(shift_left(unsigned(MUX2_out), 8));

  -- Shift by additional 0 or 4
  MUX4_out <= MUX3_out when ShiftCount(2) = '0' else
              std_logic_vector(shift_left(unsigned(MUX3_out), 4));

  -- Shift by additional 0 or 2
  MUX5_out <= MUX4_out when ShiftCount(1) = '0' else
              std_logic_vector(shift_left(unsigned(MUX4_out), 2));

  -- Shift by additional 0 or 1
  MUX6_out <= MUX5_out when ShiftCount(0) = '0' else
              std_logic_vector(shift_left(unsigned(MUX5_out), 1));

  -- Final output
  Y <= MUX6_out;

end architecture twoChannelMUX;

--------------------------------------------4 CHANNEL MUX----------------------------------------------
Architecture fourChannelMUX of SLL64 is

signal MUX1_out, MUX2_out, MUX3_out : std_logic_vector(N-1 downto 0) := (others => '0');
	signal ShiftCount1, ShiftCount2, ShiftCount3 : std_logic_vector(1 downto 0) := (others => '0');

begin

	-- Not sure if making this work for Nbit input would work, for now harcode indices
	-- Using the 3, 4-input MUXs in series strategy from the notes
	-- Going from left to right

	ShiftCount1 <= ShiftCount(5 downto 4);
	ShiftCount2 <= ShiftCount(3 downto 2);
	ShiftCount3 <= ShiftCount(1 downto 0);
	
	-- This one shifts by either 0, 16, 32, 48
	MUX1 : MUX1_out <= X(N-1 downto 0)                                when ShiftCount1 = "00" else -- 0
							 std_logic_vector(shift_left(unsigned(X), 16))  when ShiftCount1 = "01" else -- 16
							 std_logic_vector(shift_left(unsigned(X), 32))  when ShiftCount1 = "10" else -- 32 
							 std_logic_vector(shift_left(unsigned(X), 48));                              -- 48
								 
	-- This one shifts by either 0, 4, 8, 12
	MUX2 : MUX2_out <= MUX1_out(N-1 downto 0)                                when ShiftCount2 = "00" else -- 0
							 std_logic_vector(shift_left(unsigned(MUX1_out), 4))   when ShiftCount2 = "01" else -- 4
							 std_logic_vector(shift_left(unsigned(MUX1_out), 8))   when ShiftCount2 = "10" else -- 8 
							 std_logic_vector(shift_left(unsigned(MUX1_out), 12));                              -- 12
								 
	-- This one shifts by either 0, 1, 2, 3
	MUX3 : MUX3_out <= MUX2_out(N-1 downto 0)                                when ShiftCount3 = "00" else -- 0
							 std_logic_vector(shift_left(unsigned(MUX2_out), 1))   when ShiftCount3 = "01" else -- 1
							 std_logic_vector(shift_left(unsigned(MUX2_out), 2))   when ShiftCount3 = "10" else -- 2 
							 std_logic_vector(shift_left(unsigned(MUX2_out), 3));                              -- 3
	
	-- Assign final output
	Y <= MUX3_out;

End Architecture fourChannelMUX;


------------------------------------------8 CHANNEL MUX--------------------------------------------------------------------

Architecture eightChannelMUX of SLL64 is

signal MUX1_out, MUX2_out : std_logic_vector(N-1 downto 0) := (others => '0');
	signal ShiftCount1, ShiftCount2 : std_logic_vector(2 downto 0) := (others => '0');

begin

	-- Not sure if making this work for Nbit input would work, for now harcode indices
	-- Using the 3, 4-input MUXs in series strategy from the notes
	-- Going from left to right

	ShiftCount1 <= ShiftCount(5 downto 3);
	ShiftCount2 <= ShiftCount(2 downto 0);
	
	-- This one shifts by either 0, 16, 32, 48
	MUX1 : MUX1_out <= X(N-1 downto 0)                                when ShiftCount1 = "000" else -- 0
							 std_logic_vector(shift_left(unsigned(X), 8))  when ShiftCount1 = "001" else -- 8
							 std_logic_vector(shift_left(unsigned(X), 16))  when ShiftCount1 = "010" else -- 16 
							 std_logic_vector(shift_left(unsigned(X), 24))  when ShiftCount1 = "011" else -- 24 
							 std_logic_vector(shift_left(unsigned(X), 32))  when ShiftCount1 = "100" else -- 32 
							 std_logic_vector(shift_left(unsigned(X), 40))  when ShiftCount1 = "101" else -- 40 
							 std_logic_vector(shift_left(unsigned(X), 48))  when ShiftCount1 = "110" else -- 48 
							 std_logic_vector(shift_left(unsigned(X), 56));                               -- 56
								 
	-- This one shifts by either 0, 4, 8, 12
	MUX2 : MUX2_out <= MUX1_out(N-1 downto 0)                                when ShiftCount2 = "000" else -- 0
							 std_logic_vector(shift_left(unsigned(MUX1_out), 1))   when ShiftCount2 = "001" else -- 1
							 std_logic_vector(shift_left(unsigned(MUX1_out), 2))   when ShiftCount2 = "010" else -- 2
							 std_logic_vector(shift_left(unsigned(MUX1_out), 3))   when ShiftCount2 = "011" else -- 3 
							 std_logic_vector(shift_left(unsigned(MUX1_out), 4))   when ShiftCount2 = "100" else -- 4 
							 std_logic_vector(shift_left(unsigned(MUX1_out), 5))   when ShiftCount2 = "101" else -- 5 
							 std_logic_vector(shift_left(unsigned(MUX1_out), 6))   when ShiftCount2 = "110" else -- 6  
							 std_logic_vector(shift_left(unsigned(MUX1_out), 7));                               -- 7
								 

	-- Assign final output
	Y <= MUX2_out;

End Architecture eightChannelMUX;

