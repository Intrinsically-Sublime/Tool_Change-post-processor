-- Tool_change.lua
-- By Sublime 2013
-- Change extruder used for individual section of a print

-- Licence:  GPL v3
-- This library is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-----------------------------------------------------------------------------------

---------------------------- START USER SETTINGS ----------------------------

-- Assign which extruder is used for which extrusion type
-- Extrusion temperatures ( ZERO's will disable and the current temperature will be used)

-- Kisslicer only
INTERFACE_TOOL = 0
INTERFACE_TEMP = 200

 -- Kisslicer and Cura
SUPPORT_TOOL = 2
SUPPORT_TEMP = 210

-- Kisslicer and Cura
PERIMETER_TOOL = 0
PERIMETER_TEMP = 210

-- Kisslicer and Cura
LOOP_TOOL = 1
LOOP_TEMP = 210

-- Kisslicer only
SOLID_TOOL = 1
SOLID_TEMP = 215

-- Kisslicer (USED FOR ALL CURA INFILL)
SPARSE_TOOL = 3
SPARSE_TEMP = 215


-- Idle temperature for all extruders ( ZERO will disable and the current temperature will be used)
IDLE_TEMP = 130

-- Set offset for each extruder in mm (NO negatives)
T0_X_offset = 0
T0_Y_offset = 0

T1_X_offset = 35
T1_Y_offset = 0

T2_X_offset = 0
T2_Y_offset = 35

T3_X_offset = 35
T3_Y_offset = 35

-- Tool change location (MUST be greater than largest tool offset)
TCL_X = 50
TCL_Y = 50

-- Travel speed
SPEED = 6000 -- In mm/m = 100mm/s

-- Extrusion mode
 ABSOLUTE_E = true

---------------------------- END USER SETTINGS ----------------------------

LAST_TCL_X = TCL_X
LAST_TCL_Y = TCL_Y

-- Interface tool
if INTERFACE_TOOL == 0 then
	INTERFACE_X_OFFSET = (TCL_X - T0_X_offset)
	INTERFACE_Y_OFFSET = (TCL_Y - T0_Y_offset)
elseif INTERFACE_TOOL == 1 then
	INTERFACE_X_OFFSET = (TCL_X - T1_X_offset)
	INTERFACE_Y_OFFSET = (TCL_Y - T1_Y_offset)
elseif INTERFACE_TOOL == 2 then
	INTERFACE_X_OFFSET = (TCL_X - T2_X_offset)
	INTERFACE_Y_OFFSET = (TCL_Y - T2_Y_offset)
elseif INTERFACE_TOOL == 3 then
	INTERFACE_X_OFFSET = (TCL_X - T3_X_offset)
	INTERFACE_Y_OFFSET = (TCL_Y - T3_Y_offset)
end
	
-- Support tool
if SUPPORT_TOOL == 0 then
	SUPPORT_X_OFFSET = (TCL_X - T0_X_offset)
	SUPPORT_Y_OFFSET = (TCL_Y - T0_Y_offset)
elseif SUPPORT_TOOL == 1 then
	SUPPORT_X_OFFSET = (TCL_X - T1_X_offset)
	SUPPORT_Y_OFFSET = (TCL_Y - T1_Y_offset)
elseif SUPPORT_TOOL == 2 then
	SUPPORT_X_OFFSET = (TCL_X - T2_X_offset)
	SUPPORT_Y_OFFSET = (TCL_Y - T2_Y_offset)
elseif SUPPORT_TOOL == 3 then
	SUPPORT_X_OFFSET = (TCL_X - T3_X_offset)
	SUPPORT_Y_OFFSET = (TCL_Y - T3_Y_offset)
end
	
-- Perimeter tool
if PERIMETER_TOOL == 0 then
	PERIMETER_X_OFFSET = (TCL_X - T0_X_offset)
	PERIMETER_Y_OFFSET = (TCL_Y - T0_Y_offset)
elseif PERIMETER_TOOL == 1 then
	PERIMETER_X_OFFSET = (TCL_X - T1_X_offset)
	PERIMETER_Y_OFFSET = (TCL_Y - T1_Y_offset)
elseif PERIMETER_TOOL == 2 then
	PERIMETER_X_OFFSET = (TCL_X - T2_X_offset)
	PERIMETER_Y_OFFSET = (TCL_Y - T2_Y_offset)
elseif PERIMETER_TOOL == 3 then
	PERIMETER_X_OFFSET = (TCL_X - T3_X_offset)
	PERIMETER_Y_OFFSET = (TCL_Y - T3_Y_offset)
end
	
-- Loop tool
if LOOP_TOOL == 0 then
	LOOP_X_OFFSET = (TCL_X - T0_X_offset)
	LOOP_Y_OFFSET = (TCL_Y - T0_Y_offset)
elseif LOOP_TOOL == 1 then
	LOOP_X_OFFSET = (TCL_X - T1_X_offset)
	LOOP_Y_OFFSET = (TCL_Y - T1_Y_offset)
elseif LOOP_TOOL == 2 then
	LOOP_X_OFFSET = (TCL_X - T2_X_offset)
	LOOP_Y_OFFSET = (TCL_Y - T2_Y_offset)
elseif LOOP_TOOL == 3 then
	LOOP_X_OFFSET = (TCL_X - T3_X_offset)
	LOOP_Y_OFFSET = (TCL_Y - T3_Y_offset)
end

-- Solid tool
if SOLID_TOOL == 0 then
	SOLID_X_OFFSET = (TCL_X - T0_X_offset)
	SOLID_Y_OFFSET = (TCL_Y - T0_Y_offset)
elseif SOLID_TOOL == 1 then
	SOLID_X_OFFSET = (TCL_X - T1_X_offset)
	SOLID_Y_OFFSET = (TCL_Y - T1_Y_offset)
elseif SOLID_TOOL == 2 then
	SOLID_X_OFFSET = (TCL_X - T2_X_offset)
	SOLID_Y_OFFSET = (TCL_Y - T2_Y_offset)
elseif SOLID_TOOL == 3 then
	SOLID_X_OFFSET = (TCL_X - T3_X_offset)
	SOLID_Y_OFFSET = (TCL_Y - T3_Y_offset)
end
	
-- Sparse tool
if SPARSE_TOOL == 0 then
	SPARSE_X_OFFSET = (TCL_X - T0_X_offset)
	SPARSE_Y_OFFSET = (TCL_Y - T0_Y_offset)
elseif SPARSE_TOOL == 1 then
	SPARSE_X_OFFSET = (TCL_X - T1_X_offset)
	SPARSE_Y_OFFSET = (TCL_Y - T1_Y_offset)
elseif SPARSE_TOOL == 2 then
	SPARSE_X_OFFSET = (TCL_X - T2_X_offset)
	SPARSE_Y_OFFSET = (TCL_Y - T2_Y_offset)
elseif SPARSE_TOOL == 3 then
	SPARSE_X_OFFSET = (TCL_X - T3_X_offset)
	SPARSE_Y_OFFSET = (TCL_Y - T3_Y_offset)
end

-- open files
collectgarbage()  -- ensure unused files are closed
local fin = assert( io.open( arg[1] ) ) -- reading
local fout = assert( io.open( arg[1] .. ".processed", "wb" ) ) -- writing must be binary

-- read lines
for line in fin:lines() do

		if  ABSOLUTE_E then
			E_value = string.match(line, "E%d+%.%d+") -- Record E value for ABSOLUTE_E
			if E_value then
				last_E_value = E_value
			end
		end
		
		-- Kisslicer
		local inter_k = line:match( "; 'Support Interface',") -- Find start of support interface
		local sup_k = line:match( "; 'Support (may Stack)',") -- Find start of support
		local perim_k = line:match( "; 'Perimeter',") -- Find start of perimeter
		local loop_k = line:match( "; 'Loop',") -- Find start of loops
		local solid_k = line:match( "; 'Solid',") -- Find start of solid infill
		local sparse_k = line:match( "; 'Stacked Sparse Infill',") -- Find start of sparse infill
	
		-- Cura
		local sup_c = line:match(";TYPE:SUPPORT") -- Find start of support
		local perim_c = line:match(";TYPE:WALL\--OUTER") -- Find start of perimeter
		local loop_c = line:match(";TYPE:WALL\--INNER") -- Find start of loops
		local infill_c = line:match(";TYPE:FILL") -- Find start of sparse infill

	
	-- Set new flow rate of support interface (Kisslicer)
	if inter_k then
		fout:write(";\r\n")
		fout:write("; Change tool for support interface.\r\n")
		fout:write("G1 X" , LAST_TCL_X , " Y" , LAST_TCL_Y , " F" , SPEED , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. INTERFACE_TOOL , "\r\n")
		fout:write("G92 X" , INTERFACE_X_OFFSET , " Y" , INTERFACE_Y_OFFSET , "\r\n")
		if INTERFACE_TEMP > 0 then
			fout:write("M109 S" , INTERFACE_TEMP , "\r\n")
		end
		if  ABSOLUTE_E then
			fout:write("G92 " , last_E_value , "\r\n")
		end
		LAST_TCL_X = INTERFACE_X_OFFSET
		LAST_TCL_Y = INTERFACE_Y_OFFSET
		fout:write(";\r\n" .. line)

	-- Set new flow rate of support (Kisslicer)
	elseif sup_k then
		fout:write(";\r\n")
		fout:write("; Change tool for support.\r\n")
		fout:write("G1 X" , LAST_TCL_X , " Y" , LAST_TCL_Y , " F" , SPEED , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SUPPORT_TOOL , "\r\n")
		fout:write("G92 X" , SUPPORT_X_OFFSET , " Y" , SUPPORT_Y_OFFSET , "\r\n")
		if SUPPORT_TEMP > 0 then
			fout:write("M109 S" , SUPPORT_TEMP , "\r\n")
		end
		if  ABSOLUTE_E then
			fout:write("G92 " , last_E_value , "\r\n")
		end
		LAST_TCL_X = SUPPORT_X_OFFSET
		LAST_TCL_Y = SUPPORT_Y_OFFSET
		fout:write(";\r\n" .. line)

	-- Set new flow rate of outer perimeter (Kisslicer)
	elseif perim_k then
		fout:write(";\r\n")
		fout:write("; Change tool for perimeter.\r\n")
		fout:write("G1 X" , LAST_TCL_X , " Y" , LAST_TCL_Y , " F" , SPEED , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. PERIMETER_TOOL , "\r\n")
		fout:write("G92 X" , PERIMETER_X_OFFSET , " Y" , PERIMETER_Y_OFFSET , "\r\n")
		if PERIMETER_TEMP > 0 then
			fout:write("M109 S" , PERIMETER_TEMP , "\r\n")
		end
		if  ABSOLUTE_E then
			fout:write("G92 " , last_E_value , "\r\n")
		end
		LAST_TCL_X = PERIMETER_X_OFFSET
		LAST_TCL_Y = PERIMETER_Y_OFFSET
		fout:write(";\r\n" .. line)

	-- Set new flow rate of loops (Kisslicer)
	elseif loop_k then
		fout:write(";\r\n")
		fout:write("; Change tool for loops.\r\n")
		fout:write("G1 X" , LAST_TCL_X , " Y" , LAST_TCL_Y , " F" , SPEED , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. LOOP_TOOL , "\r\n")
		fout:write("G92 X" , LOOP_X_OFFSET , " Y" , LOOP_Y_OFFSET , "\r\n")
		if LOOP_TEMP > 0 then
			fout:write("M109 S" , LOOP_TEMP , "\r\n")
		end
		if  ABSOLUTE_E then
			fout:write("G92 " , last_E_value , "\r\n")
		end
		LAST_TCL_X = LOOP_X_OFFSET
		LAST_TCL_Y = LOOP_Y_OFFSET
		fout:write(";\r\n" .. line)

	-- Set new flow rate of solid infill (Kisslicer)
	elseif solid_k then
		fout:write(";\r\n")
		fout:write("; Change tool for solid infill.\r\n")
		fout:write("G1 X" , LAST_TCL_X , " Y" , LAST_TCL_Y , " F" , SPEED , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SOLID_TOOL , "\r\n")
		fout:write("G92 X" , SOLID_X_OFFSET , " Y" , SOLID_Y_OFFSET , "\r\n")
		if SOLID_TEMP > 0 then
			fout:write("M109 S" , SOLID_TEMP , "\r\n")
		end
		if  ABSOLUTE_E then
			fout:write("G92 " , last_E_value , "\r\n")
		end
		LAST_TCL_X = SOLID_X_OFFSET
		LAST_TCL_Y = SOLID_Y_OFFSET
		fout:write(";\r\n" .. line)

	-- Set new flow rate of sparse infill (Kisslicer)
	elseif sparse_k then
		fout:write(";\r\n")
		fout:write("; Change tool for sparse infill.\r\n")
		fout:write("G1 X" , LAST_TCL_X , " Y" , LAST_TCL_Y , " F" , SPEED , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SPARSE_TOOL , "\r\n")
		fout:write("G92 X" , SPARSE_X_OFFSET , " Y" , SPARSE_Y_OFFSET , "\r\n")
		if SPARSE_TEMP > 0 then
			fout:write("M109 S" , SPARSE_TEMP , "\r\n;\r\n")
		end
		if  ABSOLUTE_E then
			fout:write("G92 " , last_E_value , "\r\n")
		end
		LAST_TCL_X = SPARSE_X_OFFSET
		LAST_TCL_Y = SPARSE_Y_OFFSET
		fout:write(";\r\n" .. line)


	-- Cura only
	-- Set new flow rate of support (Cura)
	elseif sup_c then
		fout:write(";\r\n")
		fout:write("; Change tool for support.\r\n")
		fout:write("G1 X" , LAST_TCL_X , " Y" , LAST_TCL_Y , " F" , SPEED , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SUPPORT_TOOL , "\r\n")
		fout:write("G92 X" , SUPPORT_X_OFFSET , " Y" , SUPPORT_Y_OFFSET , "\r\n")
		if SUPPORT_TEMP > 0 then
			fout:write("M109 S" , SUPPORT_TEMP , "\r\n")
		end
		if  ABSOLUTE_E then
			fout:write("G92 " , last_E_value , "\r\n")
		end
		LAST_TCL_X = SUPPORT_X_OFFSET
		LAST_TCL_Y = SUPPORT_Y_OFFSET
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set new flow rate of outer perimeter (Cura)
	elseif perim_c then
		fout:write(";\r\n")
		fout:write("; Change tool for perimeter.\r\n")
		fout:write("G1 X" , LAST_TCL_X , " Y" , LAST_TCL_Y , " F" , SPEED , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. PERIMETER_TOOL , "\r\n")
		fout:write("G92 X" , PERIMETER_X_OFFSET , " Y" , PERIMETER_Y_OFFSET , "\r\n")
		if PERIMETER_TEMP > 0 then
			fout:write("M109 S" , PERIMETER_TEMP , "\r\n")
		end
		if  ABSOLUTE_E then
			fout:write("G92 " , last_E_value , "\r\n")
		end
		LAST_TCL_X = PERIMETER_X_OFFSET
		LAST_TCL_Y = PERIMETER_Y_OFFSET
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set new flow rate of loops (Cura)
	elseif loop_c then
		fout:write(";\r\n")
		fout:write("; Change tool for loops.\r\n")
		fout:write("G1 X" , LAST_TCL_X , " Y" , LAST_TCL_Y , " F" , SPEED , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. LOOP_TOOL , "\r\n")
		fout:write("G92 X" , LOOP_X_OFFSET , " Y" , LOOP_Y_OFFSET , "\r\n")
		if LOOP_TEMP > 0 then
			fout:write("M109 S" , LOOP_TEMP , "\r\n")
		end
		if  ABSOLUTE_E then
			fout:write("G92 " , last_E_value , "\r\n")
		end
		LAST_TCL_X = LOOP_X_OFFSET
		LAST_TCL_Y = LOOP_Y_OFFSET
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set new flow rate of infill (Cura)
	elseif infill then
		fout:write(";\r\n")
		fout:write("; Change tool for infill.\r\n")
		fout:write("G1 X" , LAST_TCL_X , " Y" , LAST_TCL_Y , " F" , SPEED , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SPARSE_TOOL , "\r\n")
		fout:write("G92 X" , SPARSE_X_OFFSET , " Y" , SPARSE_Y_OFFSET , "\r\n")
		if SPARSE_TEMP > 0 then
			fout:write("M109 S" , SPARSE_TEMP , "\r\n")
		end
		if  ABSOLUTE_E then
			fout:write("G92 " , last_E_value , "\r\n")
		end
		LAST_TCL_X = SPARSE_X_OFFSET
		LAST_TCL_Y = SPARSE_Y_OFFSET
		fout:write(";\r\n" .. line .. "\r\n")
		
	else
	fout:write( line .. "\n" )
	

  end
end

-- done
fin:close()
fout:close()
print "done"
