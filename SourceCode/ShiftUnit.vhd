library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity ShiftUnit is
  generic (
    N : natural := 64
  );
  port (
    A, B, S       : in  std_logic_vector(N-1 downto 0);
    ShiftFN       : in  std_logic_vector(1 downto 0);
    ExtWord       : in  std_logic := '0';
    Y             : out std_logic_vector(N-1 downto 0)
  );
end entity ShiftUnit;


----------------------------------BaseLine Design (Simpleshift)----------------------------------
architecture structural of ShiftUnit is

  signal ShiftCount      : std_logic_vector(5 downto 0);
  signal SLL64_out       : std_logic_vector(N-1 downto 0);
  signal SRL64_out       : std_logic_vector(N-1 downto 0);
  signal SRA64_out       : std_logic_vector(N-1 downto 0);
  signal Y_Adder_SLL     : std_logic_vector(N-1 downto 0);
  signal Y_SRL_SRA       : std_logic_vector(N-1 downto 0);
  signal Y_ExtWord1      : std_logic_vector(N-1 downto 0);
  signal Y_ExtWord2      : std_logic_vector(N-1 downto 0);
  
  

begin

  -- Extract the 6-bit shift count from the lower bits of input B
  ShiftCount <= B(5 downto 0);

  -- Instantiate shift modules
  inst_SLL64 : entity work.SLL64(simpleShift) generic map(N => N)
    port map(A(N-1 downto 0), ShiftCount, SLL64_out);

  inst_SRL64 : entity work.SRL64(simpleShift) generic map(N => N)
    port map(A(N-1 downto 0), ShiftCount, SRL64_out);

  inst_SRA64 : entity work.SRA64(simpleShift) generic map(N => N)
    port map(A(N-1 downto 0), ShiftCount, SRA64_out);

  -- First MUX: choose between S and SLL64_out
  Y_Adder_SLL <= S when ShiftFN(0) = '0' else SLL64_out;

  -- Sign extension for Y_Adder_SLL
  Y_ExtWord1(N-1 downto N/2) <= (others => Y_Adder_SLL(N/2 - 1)) when ExtWord = '1' else Y_Adder_SLL(N-1 downto N/2);
  Y_ExtWord1((N/2 - 1) downto 0) <= Y_Adder_SLL((N/2 - 1) downto 0);

  -- Second MUX: choose between SRL64_out and SRA64_out
  Y_SRL_SRA <= SRL64_out when ShiftFN(0) = '0' else SRA64_out;

  -- Sign extension for Y_SRL_SRA
  Y_ExtWord2(N-1 downto N/2) <= (others => Y_SRL_SRA(N/2 - 1)) when ExtWord = '1' else Y_SRL_SRA(N-1 downto N/2);
  Y_ExtWord2((N/2 - 1) downto 0) <= Y_SRL_SRA((N/2 - 1) downto 0);

  -- Final MUX: choose between extended Adder/SLL or SRL/SRA result
  Y <= Y_ExtWord1 when ShiftFN(1) = '0' else Y_ExtWord2;

end architecture structural;

----------------------------------2 CHANNEL MUX----------------------------------

Architecture twoChannelMUX of ShiftUnit is 

	signal ShiftCount : std_logic_vector(5 downto 0);
	signal SwapWordSelect : std_logic := '0';
	signal ShiftInput : std_logic_vector(N-1 downto 0);
	signal SLL64_out, SRL64_out, SRA64_out : std_logic_vector(N-1 downto 0);
	
	-- MUXs
	signal Y_Adder_SLL, Y_SRL_SRA, Y_ExtWord1, Y_ExtWord2 : std_logic_vector(N-1 downto 0);
	
begin

	-- Get shift amount from ExuB input
	ShiftCount <= B(5 downto 0);
	
	
	inst_SLL64 : Entity work.SLL64(twoChannelMUX) Generic map(N => N)
						port map(A(N-1 downto 0), ShiftCount, SLL64_out);

	inst_SRL64 : Entity work.SRL64(twoChannelMUX) Generic map(N => N)
						port map(A(N-1 downto 0), ShiftCount, SRL64_out);

	inst_SRA64 : Entity work.SRA64(twoChannelMUX) Generic map(N => N)
						port map(A(N-1 downto 0), ShiftCount, SRA64_out);
						
	-- This is where it gets a bit messy, we need 3 levels of multiplexers
	
	-- MUX to choose Adder or SLL64 output
	Y_Adder_SLL <= S when ShiftFN(0) = '0' else SLL64_out;
	
	-- MUX for sign extension of previous MUX output
	-- Upper half
	Y_ExtWord1(N-1 downto N/2) <= (others => Y_Adder_SLL(N/2 - 1)) when ExtWord = '1' else Y_Adder_SLL(N-1 downto N/2);
	-- Lower half
	Y_ExtWord1((N/2 - 1) downto 0) <= Y_Adder_SLL((N/2 - 1) downto 0);
	
	
	-- MUX to choose SRL64 or SRA64 output
	Y_SRL_SRA <= SRL64_out when ShiftFN(0) = '0' else SRA64_out;
	
	-- MUX for sign extension of previous MUX output
	-- Upper half
	Y_ExtWord2(N-1 downto N/2) <= (others => Y_SRL_SRA(N/2 - 1)) when ExtWord = '1' else Y_SRL_SRA(N-1 downto N/2);
	-- Lower half
	Y_ExtWord2((N/2 - 1) downto 0) <= Y_SRL_SRA((N/2 - 1) downto 0);
	
	
	-- Final multiplexer to Choose Either Adder/SLL MUX chain output, or SRL/SRA MUX chain output	
	Y <= Y_ExtWord1 when ShiftFN(1) = '0' else Y_ExtWord2;

End Architecture;


-----------------------------------4 CHANNEL MUX-----------------------------------------

Architecture fourChannelMUX of ShiftUnit is 

	signal ShiftCount : std_logic_vector(5 downto 0);
	signal SwapWordSelect : std_logic := '0';
	signal ShiftInput : std_logic_vector(N-1 downto 0);
	signal SLL64_out, SRL64_out, SRA64_out : std_logic_vector(N-1 downto 0);
	
	-- MUXs
	signal Y_Adder_SLL, Y_SRL_SRA, Y_ExtWord1, Y_ExtWord2 : std_logic_vector(N-1 downto 0);
	
begin

	-- Get shift amount from ExuB input
	ShiftCount <= B(5 downto 0);
	
	
	inst_SLL64 : Entity work.SLL64(fourChannelMUX) Generic map(N => N)
						port map(A(N-1 downto 0), ShiftCount, SLL64_out);

	inst_SRL64 : Entity work.SRL64(fourChannelMUX) Generic map(N => N)
						port map(A(N-1 downto 0), ShiftCount, SRL64_out);

	inst_SRA64 : Entity work.SRA64(fourChannelMUX) Generic map(N => N)
						port map(A(N-1 downto 0), ShiftCount, SRA64_out);
						
	-- This is where it gets a bit messy, we need 3 levels of multiplexers
	
	-- MUX to choose Adder or SLL64 output
	Y_Adder_SLL <= S when ShiftFN(0) = '0' else SLL64_out;
	
	-- MUX for sign extension of previous MUX output
	-- Upper half
	Y_ExtWord1(N-1 downto N/2) <= (others => Y_Adder_SLL(N/2 - 1)) when ExtWord = '1' else Y_Adder_SLL(N-1 downto N/2);
	-- Lower half
	Y_ExtWord1((N/2 - 1) downto 0) <= Y_Adder_SLL((N/2 - 1) downto 0);
	
	
	-- MUX to choose SRL64 or SRA64 output
	Y_SRL_SRA <= SRL64_out when ShiftFN(0) = '0' else SRA64_out;
	
	-- MUX for sign extension of previous MUX output
	-- Upper half
	Y_ExtWord2(N-1 downto N/2) <= (others => Y_SRL_SRA(N/2 - 1)) when ExtWord = '1' else Y_SRL_SRA(N-1 downto N/2);
	-- Lower half
	Y_ExtWord2((N/2 - 1) downto 0) <= Y_SRL_SRA((N/2 - 1) downto 0);
	
	
	-- Final multiplexer to Choose Either Adder/SLL MUX chain output, or SRL/SRA MUX chain output	
	Y <= Y_ExtWord1 when ShiftFN(1) = '0' else Y_ExtWord2;

End Architecture;

--------------------------8 CHANNEL MUX------------------------------------------------

Architecture eightChannelMUX of ShiftUnit is 

	signal ShiftCount : std_logic_vector(5 downto 0);
	signal SwapWordSelect : std_logic := '0';
	signal ShiftInput : std_logic_vector(N-1 downto 0);
	signal SLL64_out, SRL64_out, SRA64_out : std_logic_vector(N-1 downto 0);
	
	-- MUXs
	signal Y_Adder_SLL, Y_SRL_SRA, Y_ExtWord1, Y_ExtWord2 : std_logic_vector(N-1 downto 0);
	
begin

	-- Get shift amount from ExuB input
	ShiftCount <= B(5 downto 0);
	
	
	inst_SLL64 : Entity work.SLL64(eightChannelMUX) Generic map(N => N)
						port map(A(N-1 downto 0), ShiftCount, SLL64_out);

	inst_SRL64 : Entity work.SRL64(eightChannelMUX) Generic map(N => N)
						port map(A(N-1 downto 0), ShiftCount, SRL64_out);

	inst_SRA64 : Entity work.SRA64(eightChannelMUX) Generic map(N => N)
						port map(A(N-1 downto 0), ShiftCount, SRA64_out);
						
	-- This is where it gets a bit messy, we need 3 levels of multiplexers
	
	-- MUX to choose Adder or SLL64 output
	Y_Adder_SLL <= S when ShiftFN(0) = '0' else SLL64_out;
	
	-- MUX for sign extension of previous MUX output
	-- Upper half
	Y_ExtWord1(N-1 downto N/2) <= (others => Y_Adder_SLL(N/2 - 1)) when ExtWord = '1' else Y_Adder_SLL(N-1 downto N/2);
	-- Lower half
	Y_ExtWord1((N/2 - 1) downto 0) <= Y_Adder_SLL((N/2 - 1) downto 0);
	
	
	-- MUX to choose SRL64 or SRA64 output
	Y_SRL_SRA <= SRL64_out when ShiftFN(0) = '0' else SRA64_out;
	
	-- MUX for sign extension of previous MUX output
	-- Upper half
	Y_ExtWord2(N-1 downto N/2) <= (others => Y_SRL_SRA(N/2 - 1)) when ExtWord = '1' else Y_SRL_SRA(N-1 downto N/2);
	-- Lower half
	Y_ExtWord2((N/2 - 1) downto 0) <= Y_SRL_SRA((N/2 - 1) downto 0);
	
	
	-- Final multiplexer to Choose Either Adder/SLL MUX chain output, or SRL/SRA MUX chain output	
	Y <= Y_ExtWord1 when ShiftFN(1) = '0' else Y_ExtWord2;

End Architecture;


