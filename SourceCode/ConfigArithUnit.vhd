library IEEE;
use IEEE.std_logic_1164.all;


----------Baseline-----------
configuration baselineConfig of TBArithUnit is
	for TB
		for DUT : TestUnit use entity
						work.ArithUnit(baseline);
		end for;
	end for;
end configuration baselineConfig;


--------- Improved Zero detection-----------
configuration improvedZeroConfig of TBArithUnit is
	for TB
		for DUT : TestUnit use entity
						work.ArithUnit(improvedZero);
		end for;
	end for;
end configuration improvedZeroConfig;

------- Structure config for timing------------
configuration structureConfig of TBArithUnit is
	for TB
		for DUT : TestUnit use entity
						work.ArithUnit(structure);
		end for;
	end for;
end configuration structureConfig;