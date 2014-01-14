-- Tool_change.lua
-- By Sublime 2014
-- Change extruder used for individual section of a print

-- Licence:  GPL v3
-- This library is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-------->>>>>>>>>>>>>>>>>>>> START USER SETTINGS <<<<<<<<<<<<<<<<<<<<--------
-----------------------------------------------------------------------------

-- Filament diameter set in the slicer
SLICE_DIAMETER = 3

-- Filament diameter for each extruder
-- Retraction distance for each extruder
-- Extruder gain to compensate for mechanical differences 
T0_DIAMETER = 3
T0_RETRACT = 1
T0_GAIN = 1

T1_DIAMETER = 3
T1_RETRACT = 1
T1_GAIN = 1

T2_DIAMETER = 3
T2_RETRACT = 1
T2_GAIN = 1

T3_DIAMETER = 3
T3_RETRACT = 1
T3_GAIN = 1

-- Tool change retraction speed
R_SPEED = 1800 -- In mm/m (1800mm/m = 30mm/s)

-- Code for temperature increase on tool select (Marlin --- M104 = no wait, M109 = wait)
TEMP_CODE = "M109"

-- Assign which extruder is used for which extrusion type
-- Extrusion temperatures ( ZERO's will disable and the current temperature will be used)

-- Kisslicer only
INTERFACE_TOOL = 0
INTERFACE_TEMP = 200

-- Kisslicer (USED FOR ALL CURA SUPPORT)
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


-- Idle temperature for all extruders ( ZERO will disable and the current temperature will be maintained)
IDLE_TEMP = 130

-- Set offset for each extruder in mm (NO negatives)(The hotend closest to X0,Y0 should have its offset set to 0,0)
T0_X_offset = 0
T0_Y_offset = 0

T1_X_offset = 35
T1_Y_offset = 0

T2_X_offset = 0
T2_Y_offset = 35

T3_X_offset = 35
T3_Y_offset = 35

-- Tool change location
TCL_X = 50
TCL_Y = 50

-- Travel speed
T_SPEED = 6000 -- In mm/m (6000mm/m = 100mm/s)

-- Extrusion mode (Absolute E because Cura does not support Relative so we have no choice)
ABSOLUTE_E = true

-----------------------------------------------------------------------------
--------->>>>>>>>>>>>>>>>>>>> END USER SETTINGS <<<<<<<<<<<<<<<<<<<<---------
-----------------------------------------------------------------------------

-- open files
collectgarbage()  -- ensure unused files are closed
local fin = assert( io.open( arg[1] ) ) -- reading
local fout = assert( io.open( arg[1] .. ".processed", "wb" ) ) -- writing must be binary

SLICE_AREA = (3.14159*((SLICE_DIAMETER*0.5)*(SLICE_DIAMETER*0.5)))
T0_AREA = (3.14159*((T0_DIAMETER*0.5)*(T0_DIAMETER*0.5)))
T1_AREA = (3.14159*((T1_DIAMETER*0.5)*(T1_DIAMETER*0.5)))
T2_AREA = (3.14159*((T2_DIAMETER*0.5)*(T2_DIAMETER*0.5)))
T3_AREA = (3.14159*((T3_DIAMETER*0.5)*(T3_DIAMETER*0.5)))

T0_FLOW = math.floor((((SLICE_AREA/T0_AREA)*T0_GAIN)*100)+0.5)
T1_FLOW = math.floor((((SLICE_AREA/T1_AREA)*T1_GAIN)*100)+0.5)
T2_FLOW = math.floor((((SLICE_AREA/T2_AREA)*T2_GAIN)*100)+0.5)
T3_FLOW = math.floor((((SLICE_AREA/T3_AREA)*T3_GAIN)*100)+0.5)

-- Interface tool
if INTERFACE_TOOL == 0 then
	INTERFACE_X_OFFSET = (TCL_X + T0_X_offset)
	INTERFACE_Y_OFFSET = (TCL_Y + T0_Y_offset)
	INTERFACE_FLOW = T0_FLOW
	INTERFACE_RETRACT = T0_RETRACT
elseif INTERFACE_TOOL == 1 then
	INTERFACE_X_OFFSET = (TCL_X + T1_X_offset)
	INTERFACE_Y_OFFSET = (TCL_Y + T1_Y_offset)
	INTERFACE_FLOW = T1_FLOW
	INTERFACE_RETRACT = T1_RETRACT
elseif INTERFACE_TOOL == 2 then
	INTERFACE_X_OFFSET = (TCL_X + T2_X_offset)
	INTERFACE_Y_OFFSET = (TCL_Y + T2_Y_offset)
	INTERFACE_FLOW = T2_FLOW
	INTERFACE_RETRACT = T2_RETRACT
elseif INTERFACE_TOOL == 3 then
	INTERFACE_X_OFFSET = (TCL_X + T3_X_offset)
	INTERFACE_Y_OFFSET = (TCL_Y + T3_Y_offset)
	INTERFACE_FLOW = T3_FLOW
	INTERFACE_RETRACT = T3_RETRACT
end
	
-- Support tool
if SUPPORT_TOOL == 0 then
	SUPPORT_X_OFFSET = (TCL_X + T0_X_offset)
	SUPPORT_Y_OFFSET = (TCL_Y + T0_Y_offset)
	SUPPORT_FLOW = T0_FLOW
	SUPPORT_RETRACT = T0_RETRACT
elseif SUPPORT_TOOL == 1 then
	SUPPORT_X_OFFSET = (TCL_X + T1_X_offset)
	SUPPORT_Y_OFFSET = (TCL_Y + T1_Y_offset)
	SUPPORT_FLOW = T1_FLOW
	SUPPORT_RETRACT = T1_RETRACT
elseif SUPPORT_TOOL == 2 then
	SUPPORT_X_OFFSET = (TCL_X + T2_X_offset)
	SUPPORT_Y_OFFSET = (TCL_Y + T2_Y_offset)
	SUPPORT_FLOW = T2_FLOW
	SUPPORT_RETRACT = T2_RETRACT
elseif SUPPORT_TOOL == 3 then
	SUPPORT_X_OFFSET = (TCL_X + T3_X_offset)
	SUPPORT_Y_OFFSET = (TCL_Y + T3_Y_offset)
	SUPPORT_FLOW = T3_FLOW
	SUPPORT_RETRACT = T3_RETRACT
end
	
-- Perimeter tool
if PERIMETER_TOOL == 0 then
	PERIMETER_X_OFFSET = (TCL_X + T0_X_offset)
	PERIMETER_Y_OFFSET = (TCL_Y + T0_Y_offset)
	PERIMETER_FLOW = T0_FLOW
	PERIMETER_RETRACT = T0_RETRACT
elseif PERIMETER_TOOL == 1 then
	PERIMETER_X_OFFSET = (TCL_X + T1_X_offset)
	PERIMETER_Y_OFFSET = (TCL_Y + T1_Y_offset)
	PERIMETER_FLOW = T1_FLOW
	PERIMETER_RETRACT = T1_RETRACT
elseif PERIMETER_TOOL == 2 then
	PERIMETER_X_OFFSET = (TCL_X + T2_X_offset)
	PERIMETER_Y_OFFSET = (TCL_Y + T2_Y_offset)
	PERIMETER_FLOW = T2_FLOW
	PERIMETER_RETRACT = T2_RETRACT
elseif PERIMETER_TOOL == 3 then
	PERIMETER_X_OFFSET = (TCL_X + T3_X_offset)
	PERIMETER_Y_OFFSET = (TCL_Y + T3_Y_offset)
	PERIMETER_FLOW = T3_FLOW
	PERIMETER_RETRACT = T3_RETRACT
end
	
-- Loop tool
if LOOP_TOOL == 0 then
	LOOP_X_OFFSET = (TCL_X + T0_X_offset)
	LOOP_Y_OFFSET = (TCL_Y + T0_Y_offset)
	LOOP_FLOW = T0_FLOW
	LOOP_RETRACT = T0_RETRACT
elseif LOOP_TOOL == 1 then
	LOOP_X_OFFSET = (TCL_X + T1_X_offset)
	LOOP_Y_OFFSET = (TCL_Y + T1_Y_offset)
	LOOP_FLOW = T1_FLOW
	LOOP_RETRACT = T1_RETRACT
elseif LOOP_TOOL == 2 then
	LOOP_X_OFFSET = (TCL_X + T2_X_offset)
	LOOP_Y_OFFSET = (TCL_Y + T2_Y_offset)
	LOOP_FLOW = T2_FLOW
	LOOP_RETRACT = T2_RETRACT
elseif LOOP_TOOL == 3 then
	LOOP_X_OFFSET = (TCL_X + T3_X_offset)
	LOOP_Y_OFFSET = (TCL_Y + T3_Y_offset)
	LOOP_FLOW = T3_FLOW
	LOOP_RETRACT = T3_RETRACT
end

-- Solid tool
if SOLID_TOOL == 0 then
	SOLID_X_OFFSET = (TCL_X + T0_X_offset)
	SOLID_Y_OFFSET = (TCL_Y + T0_Y_offset)
	SOLID_FLOW = T0_FLOW
	SOLID_RETRACT = T0_RETRACT
elseif SOLID_TOOL == 1 then
	SOLID_X_OFFSET = (TCL_X + T1_X_offset)
	SOLID_Y_OFFSET = (TCL_Y + T1_Y_offset)
	SOLID_FLOW = T1_FLOW
	SOLID_RETRACT = T1_RETRACT
elseif SOLID_TOOL == 2 then
	SOLID_X_OFFSET = (TCL_X + T2_X_offset)
	SOLID_Y_OFFSET = (TCL_Y + T2_Y_offset)
	SOLID_FLOW = T2_FLOW
	SOLID_RETRACT = T2_RETRACT
elseif SOLID_TOOL == 3 then
	SOLID_X_OFFSET = (TCL_X + T3_X_offset)
	SOLID_Y_OFFSET = (TCL_Y + T3_Y_offset)
	SOLID_FLOW = T3_FLOW
	SOLID_RETRACT = T3_RETRACT
end
	
-- Sparse tool
if SPARSE_TOOL == 0 then
	SPARSE_X_OFFSET = (TCL_X + T0_X_offset)
	SPARSE_Y_OFFSET = (TCL_Y + T0_Y_offset)
	SPARSE_FLOW = T0_FLOW
	SPARSE_RETRACT = T0_RETRACT
elseif SPARSE_TOOL == 1 then
	SPARSE_X_OFFSET = (TCL_X + T1_X_offset)
	SPARSE_Y_OFFSET = (TCL_Y + T1_Y_offset)
	SPARSE_FLOW = T1_FLOW
	SPARSE_RETRACT = T1_RETRACT
elseif SPARSE_TOOL == 2 then
	SPARSE_X_OFFSET = (TCL_X + T2_X_offset)
	SPARSE_Y_OFFSET = (TCL_Y + T2_Y_offset)
	SPARSE_FLOW = T2_FLOW
	SPARSE_RETRACT = T2_RETRACT
elseif SPARSE_TOOL == 3 then
	SPARSE_X_OFFSET = (TCL_X + T3_X_offset)
	SPARSE_Y_OFFSET = (TCL_Y + T3_Y_offset)
	SPARSE_FLOW = T3_FLOW
	SPARSE_RETRACT = T3_RETRACT
end

LAST_TCL_X = TCL_X
LAST_TCL_Y = TCL_Y
LAST_RETRACT = T0_RETRACT

function RETRACT(distance)
	if ABSOLUTE_E then
		local value = last_E_value - distance
		fout:write("G1 F" , R_SPEED , " E" , value , "\r\n")
	else
		fout:write("G1 F" , R_SPEED , " E" , distance , "\r\n")
	end
end

function UN_RETRACT(distance)
	if ABSOLUTE_E then
		local value = last_E_value - distance
		fout:write("G92 E" , value , "\r\n")
		fout:write("G1 F" , R_SPEED , " E" , last_E_value , "\r\n")
	else
		fout:write("G1 F" , R_SPEED , " E" , distance , "\r\n")
	end
end

-- read lines
for line in fin:lines() do

		-- Record E value for ABSOLUTE_E
		if  ABSOLUTE_E then
			local E_value = string.match(line, "E%d+%.%d+")
			if E_value then
				last_E_value = string.match(E_value, "%d+%.%d+")
			end
		end
		
		-- Record X position
		local X = string.match(line, "X%d+%.%d+")
		if X then
			last_X = string.match(X, "%d+%.%d+")
		end
		
		-- Record Y position
		local Y = string.match(line, "X%d+%.%d+")
		if Y then
			last_Y = string.match(Y, "%d+%.%d+")
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

	
	-- Set new tool for support interface (Kisslicer)
	if inter_k and LAST_TOOL ~= INTERFACE_TOOL then
		fout:write(";\r\n")
		fout:write("; Change tool for support interface.\r\n")
		RETRACT(LAST_RETRACT)
		fout:write("G1 F" , T_SPEED , " X" , LAST_TCL_X , " Y" , LAST_TCL_Y , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. INTERFACE_TOOL , "\r\n")
		fout:write("G92 X" , INTERFACE_X_OFFSET , " Y" , INTERFACE_Y_OFFSET , "\r\n")
		if INTERFACE_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , INTERFACE_TEMP , "\r\n")
		end
		fout:write("G1 F" , T_SPEED , " X" , last_X , " Y" , last_Y , "\r\n")
		UN_RETRACT(INTERFACE_RETRACT)
		fout:write("; Set support interface flow rate.\r\n")
		fout:write("M221 S" .. INTERFACE_FLOW .. "\r\n")
		LAST_TCL_X = INTERFACE_X_OFFSET
		LAST_TCL_Y = INTERFACE_Y_OFFSET
		LAST_RETRACT = INTERFACE_RETRACT
		LAST_TOOL = INTERFACE_TOOL
		fout:write(";\r\n" .. line)

	-- Set tool for support (Kisslicer)
	elseif sup_k and LAST_TOOL ~= SUPPORT_TOOL then
		fout:write(";\r\n")
		fout:write("; Change tool for support.\r\n")
		RETRACT(LAST_RETRACT)
		fout:write("G1 F" , T_SPEED , " X" , LAST_TCL_X , " Y" , LAST_TCL_Y , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SUPPORT_TOOL , "\r\n")
		fout:write("G92 X" , SUPPORT_X_OFFSET , " Y" , SUPPORT_Y_OFFSET , "\r\n")
		if SUPPORT_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , SUPPORT_TEMP , "\r\n")
		end
		fout:write("G1 F" , T_SPEED , " X" , last_X , " Y" , last_Y , "\r\n")
		UN_RETRACT(SUPPORT_RETRACT)
		fout:write("; Set support flow rate.\r\n")
		fout:write("M221 S" .. SUPPORT_FLOW .. "\r\n")
		LAST_TCL_X = SUPPORT_X_OFFSET
		LAST_TCL_Y = SUPPORT_Y_OFFSET
		LAST_RETRACT = SUPPORT_RETRACT
		LAST_TOOL = SUPPORT_TOOL
		fout:write(";\r\n" .. line)

	-- Set tool for perimeter (Kisslicer)
	elseif perim_k and LAST_TOOL ~= PERIMETER_TOOL then
		fout:write(";\r\n")
		fout:write("; Change tool for perimeter.\r\n")
		RETRACT(LAST_RETRACT)
		fout:write("G1 F" , T_SPEED , " X" , LAST_TCL_X , " Y" , LAST_TCL_Y , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. PERIMETER_TOOL , "\r\n")
		fout:write("G92 X" , PERIMETER_X_OFFSET , " Y" , PERIMETER_Y_OFFSET , "\r\n")
		if PERIMETER_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , PERIMETER_TEMP , "\r\n")
		end
		fout:write("G1 F" , T_SPEED , " X" , last_X , " Y" , last_Y , "\r\n")
		UN_RETRACT(PERIMETER_RETRACT)
		fout:write("; Set perimeter flow rate.\r\n")
		fout:write("M221 S" .. PERIMETER_FLOW .. "\r\n")
		LAST_TCL_X = PERIMETER_X_OFFSET
		LAST_TCL_Y = PERIMETER_Y_OFFSET
		LAST_RETRACT = PERIMETER_RETRACT
		LAST_TOOL = PERIMETER_TOOL
		fout:write(";\r\n" .. line)

	-- Set tool for loops (Kisslicer)
	elseif loop_k and LAST_TOOL ~= LOOP_TOOL then
		fout:write(";\r\n")
		fout:write("; Change tool for loops.\r\n")
		RETRACT(LAST_RETRACT)
		fout:write("G1 F" , T_SPEED , " X" , LAST_TCL_X , " Y" , LAST_TCL_Y , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. LOOP_TOOL , "\r\n")
		fout:write("G92 X" , LOOP_X_OFFSET , " Y" , LOOP_Y_OFFSET , "\r\n")
		if LOOP_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , LOOP_TEMP , "\r\n")
		end
		fout:write("G1 F" , T_SPEED , " X" , last_X , " Y" , last_Y , "\r\n")
		UN_RETRACT(LOOP_RETRACT)
		fout:write("; Set loop flow rate.\r\n")
		fout:write("M221 S" .. LOOP_FLOW .. "\r\n")
		LAST_TCL_X = LOOP_X_OFFSET
		LAST_TCL_Y = LOOP_Y_OFFSET
		LAST_RETRACT = LOOP_RETRACT
		LAST_TOOL = LOOP_TOOL
		fout:write(";\r\n" .. line)

	-- Set tool for solid infill (Kisslicer)
	elseif solid_k and LAST_TOOL ~= SOLID_TOOL then
		fout:write(";\r\n")
		fout:write("; Change tool for solid infill.\r\n")
		RETRACT(LAST_RETRACT)
		fout:write("G1 F" , T_SPEED , " X" , LAST_TCL_X , " Y" , LAST_TCL_Y , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SOLID_TOOL , "\r\n")
		fout:write("G92 X" , SOLID_X_OFFSET , " Y" , SOLID_Y_OFFSET , "\r\n")
		if SOLID_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , SOLID_TEMP , "\r\n")
		end
		fout:write("G1 F" , T_SPEED , " X" , last_X , " Y" , last_Y , "\r\n")
		UN_RETRACT(SOLID_RETRACT)
		fout:write("; Set solid infill flow rate.\r\n")
		fout:write("M221 S" .. SOLID_FLOW .. "\r\n")
		LAST_TCL_X = SOLID_X_OFFSET
		LAST_TCL_Y = SOLID_Y_OFFSET
		LAST_RETRACT = SOLID_RETRACT
		LAST_TOOL = SOLID_TOOL
		fout:write(";\r\n" .. line)

	-- Set tool for sparse infill (Kisslicer)
	elseif sparse_k and LAST_TOOL ~= SPARSE_TOOL then
		fout:write(";\r\n")
		fout:write("; Change tool for sparse infill.\r\n")
		RETRACT(LAST_RETRACT)
		fout:write("G1 F" , T_SPEED , " X" , LAST_TCL_X , " Y" , LAST_TCL_Y , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SPARSE_TOOL , "\r\n")
		fout:write("G92 X" , SPARSE_X_OFFSET , " Y" , SPARSE_Y_OFFSET , "\r\n")
		if SPARSE_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , SPARSE_TEMP , "\r\n;\r\n")
		end
		fout:write("G1 F" , T_SPEED , " X" , last_X , " Y" , last_Y , "\r\n")
		UN_RETRACT(SPARSE_RETRACT)
		fout:write("; Set sparse infill flow rate.\r\n")
		fout:write("M221 S" .. SPARSE_FLOW .. "\r\n")
		LAST_TCL_X = SPARSE_X_OFFSET
		LAST_TCL_Y = SPARSE_Y_OFFSET
		LAST_RETRACT = SPARSE_RETRACT
		LAST_TOOL = SPARSE_TOOL
		fout:write(";\r\n" .. line)


	-- Cura only
	-- Set tool for support (Cura)
	elseif sup_c and LAST_TOOL ~= SUPPORT_TOOL then
		fout:write(";\r\n")
		fout:write("; Change tool for support.\r\n")
		RETRACT(LAST_RETRACT)
		fout:write("G1 F" , T_SPEED , " X" , LAST_TCL_X , " Y" , LAST_TCL_Y , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SUPPORT_TOOL , "\r\n")
		fout:write("G92 X" , SUPPORT_X_OFFSET , " Y" , SUPPORT_Y_OFFSET , "\r\n")
		if SUPPORT_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , SUPPORT_TEMP , "\r\n")
		end
		fout:write("G1 F" , T_SPEED , " X" , last_X , " Y" , last_Y , "\r\n")
		UN_RETRACT(SUPPORT_RETRACT)
		fout:write("; Set support flow rate.\r\n")
		fout:write("M221 S" .. SUPPORT_FLOW .. "\r\n")
		LAST_TCL_X = SUPPORT_X_OFFSET
		LAST_TCL_Y = SUPPORT_Y_OFFSET
		LAST_RETRACT = SUPPORT_RETRACT
		LAST_TOOL = SUPPORT_TOOL
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set tool for perimeter (Cura)
	elseif perim_c and LAST_TOOL ~= PERIMETER_TOOL then
		fout:write(";\r\n")
		fout:write("; Change tool for perimeter.\r\n")
		RETRACT(LAST_RETRACT)
		fout:write("G1 F" , T_SPEED , " X" , LAST_TCL_X , " Y" , LAST_TCL_Y , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. PERIMETER_TOOL , "\r\n")
		fout:write("G92 X" , PERIMETER_X_OFFSET , " Y" , PERIMETER_Y_OFFSET , "\r\n")
		if PERIMETER_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , PERIMETER_TEMP , "\r\n")
		end
		fout:write("G1 F" , T_SPEED , " X" , last_X , " Y" , last_Y , "\r\n")
		UN_RETRACT(PERIMETER_RETRACT)
		fout:write("; Set perimeter flow rate.\r\n")
		fout:write("M221 S" .. PERIMETER_FLOW .. "\r\n")
		LAST_TCL_X = PERIMETER_X_OFFSET
		LAST_TCL_Y = PERIMETER_Y_OFFSET
		LAST_RETRACT = PERIMETER_RETRACT
		LAST_TOOL = PERIMETER_TOOL
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set tool for loops (Cura)
	elseif loop_c and LAST_TOOL ~= LOOP_TOOL then
		fout:write(";\r\n")
		fout:write("; Change tool for loops.\r\n")
		RETRACT(LAST_RETRACT)
		fout:write("G1 F" , T_SPEED , " X" , LAST_TCL_X , " Y" , LAST_TCL_Y , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. LOOP_TOOL , "\r\n")
		fout:write("G92 X" , LOOP_X_OFFSET , " Y" , LOOP_Y_OFFSET , "\r\n")
		if LOOP_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , LOOP_TEMP , "\r\n")
		end
		fout:write("G1 F" , T_SPEED , " X" , last_X , " Y" , last_Y , "\r\n")
		UN_RETRACT(LOOP_RETRACT)
		fout:write("; Set loop flow rate.\r\n")
		fout:write("M221 S" .. LOOP_FLOW .. "\r\n")
		LAST_TCL_X = LOOP_X_OFFSET
		LAST_TCL_Y = LOOP_Y_OFFSET
		LAST_RETRACT = LOOP_RETRACT
		LAST_TOOL = LOOP_TOOL
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set tool for infill (Cura)
	elseif infill_c and LAST_TOOL ~= SPARSE_TOOL then
		fout:write(";\r\n")
		fout:write("; Change tool for infill.\r\n")
		RETRACT(LAST_RETRACT)
		fout:write("G1 F" , T_SPEED , " X" , LAST_TCL_X , " Y" , LAST_TCL_Y , "\r\n")
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SPARSE_TOOL , "\r\n")
		fout:write("G92 X" , SPARSE_X_OFFSET , " Y" , SPARSE_Y_OFFSET , "\r\n")
		if SPARSE_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , SPARSE_TEMP , "\r\n")
		end
		fout:write("G1 F" , T_SPEED , " X" , last_X , " Y" , last_Y , "\r\n")
		UN_RETRACT(SPARSE_RETRACT)
		fout:write("; Set sparse infill flow rate.\r\n")
		fout:write("M221 S" .. SPARSE_FLOW .. "\r\n")
		LAST_TCL_X = SPARSE_X_OFFSET
		LAST_TCL_Y = SPARSE_Y_OFFSET
		LAST_RETRACT = SPARSE_RETRACT
		LAST_TOOL = SPARSE_TOOL
		fout:write(";\r\n" .. line .. "\r\n")
		
	else
	fout:write( line .. "\n" )
	

  end
end

-- done
fin:close()
fout:close()
print "done"
