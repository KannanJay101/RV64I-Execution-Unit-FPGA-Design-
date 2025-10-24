library IEEE;
use IEEE.std_logic_1164.all;

---------------------------Baseline-----------------------
configuration baselineConfig of TBShiftUnit is
	for TB
		for DUT : TestUnit use entity
						work.ShiftUnit(structural);
		end for;
	end for;
end configuration baselineConfig;

---------------------------Two channel MUX-----------------------
configuration twoChannelMUXConfig of TBShiftUnit is
	for TB
		for DUT : TestUnit use entity
						work.ShiftUnit(twoChannelMUX);
		end for;
	end for;
end configuration twoChannelMUXConfig;


---------------------------Four Channel MUX-----------------------
configuration fourChannelMUXConfig of TBShiftUnit is
	for TB
		for DUT : TestUnit use entity
						work.ShiftUnit(fourChannelMUX);
		end for;
	end for;
end configuration fourChannelMUXConfig;


---------------------------Eight Channel MUX-----------------------
configuration eightChannelMUXConfig of TBShiftUnit is
	for TB
		for DUT : TestUnit use entity
						work.ShiftUnit(eightChannelMUX);
		end for;
	end for;
end configuration eightChannelMUXConfig;

-----------------------------Timing config--------------------------
configuration structureConfig of TBShiftUnit is
	for TB
		for DUT : TestUnit use entity
						work.ShiftUnit(structure);
		end for;
	end for;
end configuration structureConfig;