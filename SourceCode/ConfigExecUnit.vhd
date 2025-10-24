library IEEE;
use IEEE.std_logic_1164.all;

configuration baselineConfig of TBExecUnit is
	for TB
		for DUT : TestUnit use entity
						work.ExecUnit(structural);
		end for;
	end for;
end configuration baselineConfig;

configuration structureConfig of TBExecUnit is
	for TB
		for DUT : TestUnit use entity
						work.ExecUnit(structure);
		end for;
	end for;
end configuration structureConfig;