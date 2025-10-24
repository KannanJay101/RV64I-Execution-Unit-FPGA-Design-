library IEEE;
use IEEE.std_logic_1164.all;

configuration baselineConfig of TBLogicUnit is
	for TB
		for DUT : TestUnit use entity
						work.LogicUnit(structural);
		end for;
	end for;
end configuration baselineConfig;

configuration structureConfig of TBLogicUnit is
	for TB
		for DUT : TestUnit use entity
						work.LogicUnit(structure);
		end for;
	end for;
end configuration structureConfig;