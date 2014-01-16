-- Tool_change.lua
-- By Sublime 2014 https://github.com/Intrinsically-Sublime
-- Change extruder used for individual section of a print

-- Licence:  GPL v3
-- This library is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-->>>>>>>>>>>>>>>>>>>>>>>>>> START USER SETTINGS <<<<<<<<<<<<<<<<<<<<<<<<<<--
-----------------------------------------------------------------------------

--------------------- Start slicer settings ---------------------

-- Filament diameter set in the slicer
-- Layer height used to slice
SLICE_DIAMETER = 3
LAYER_HEIGHT = 0.2

--------------------- End slicer settings ---------------------

--------------------- Start machine setup ---------------------

-- Filament diameter for each extruder
-- Retraction distance for each extruder
-- Extruder gain to compensate for mechanical differences
-- Nozzle size used in wipe tower generation
T0_DIAMETER = 3
T0_RETRACT = 1
T0_GAIN = 1
T0_NOZZLE_D = 0.5

T1_DIAMETER = 3
T1_RETRACT = 1
T1_GAIN = 1
T1_NOZZLE_D = 0.45

T2_DIAMETER = 3
T2_RETRACT = 1
T2_GAIN = 1
T2_NOZZLE_D = 0.4

T3_DIAMETER = 3
T3_RETRACT = 1
T3_GAIN = 1
T3_NOZZLE_D = 0.35

-- Set offset for each extruder in mm (NO negatives)(The hotend closest to X0,Y0 should have its offset set to 0,0 and preferably be T0)
T0_X_offset = 0
T0_Y_offset = 0

T1_X_offset = 35
T1_Y_offset = 0

T2_X_offset = 0
T2_Y_offset = 35

T3_X_offset = 35
T3_Y_offset = 35

----------------------- End machine setup -----------------------

--------------------- Start gcode settings ---------------------

-- Code for temperature increase on tool select (Marlin --- M104 = no wait, M109 = wait)
TEMP_CODE = "M109"

-- Tool change retraction speed
R_SPEED = 1800 -- In mm/m (1800mm/m = 30mm/s)

-- Travel speed
T_SPEED = 6000 -- In mm/m (6000mm/m = 100mm/s)

-- Extrusion mode (Absolute E because Cura does not support Relative or use ABS_2_REL post processor first https://github.com/Intrinsically-Sublime/ABS_2_REL )
ABSOLUTE_E = true

-- Assign which extruder is used for which extrusion type
-- Extrusion temperatures ( ZERO's will disable and the current temperature will be used)

-- Kisslicer only
INTERFACE_TOOL = 3
INTERFACE_TEMP = 200

-- Kisslicer (USED FOR ALL CURA SUPPORT)
SUPPORT_TOOL = 3
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
SPARSE_TOOL = 2
SPARSE_TEMP = 215

-- Idle temperature for all extruders ( ZERO will disable and the current temperature will be maintained)
IDLE_TEMP = 130

------------------------ End gcode settings ------------------------

-------------------- Start prime pillar settings --------------------

-- ****************** ONLY USE IF THERE IS A TOOL CHANGE ON EVERY LAYER OTHERWISE IT WILL TRY AND START IN MID-AIR****** Working on solution
-- Prime pillar
PRIME_PILLAR = false
-- ************************************************

-- Prime pillar location
PPL_X = 10
PPL_Y = 10

-- Prime pillar size (Will be centred at the prime pillar location)(Minimum size is 4mm per extruder being used)
P_SIZE_X = 16
P_SIZE_Y = 16

-- Prime pillar print speed
P_SPEED = 1800

---------------------- End prime pillar settings ----------------------


-----------------------------------------------------------------------------
-->>>>>>>>>>>>>>>>>>>>>>>>>>> END USER SETTINGS <<<<<<<<<<<<<<<<<<<<<<<<<<<--
-----------------------------------------------------------------------------

-- open files
collectgarbage()  -- ensure unused files are closed
local fin = assert( io.open( arg[1] ) ) -- reading
local fout = assert( io.open( arg[1] .. ".processed", "wb" ) ) -- writing must be binary

SLICE_AREA = (3.14159*((SLICE_DIAMETER*0.5)*(SLICE_DIAMETER*0.5)))

T0_F_AREA = (3.14159*((T0_DIAMETER*0.5)*(T0_DIAMETER*0.5)))
T1_F_AREA = (3.14159*((T1_DIAMETER*0.5)*(T1_DIAMETER*0.5)))
T2_F_AREA = (3.14159*((T2_DIAMETER*0.5)*(T2_DIAMETER*0.5)))
T3_F_AREA = (3.14159*((T3_DIAMETER*0.5)*(T3_DIAMETER*0.5)))

T0_FLOW = math.floor((((SLICE_AREA/T0_F_AREA)*T0_GAIN)*100)+0.5)
T1_FLOW = math.floor((((SLICE_AREA/T1_F_AREA)*T1_GAIN)*100)+0.5)
T2_FLOW = math.floor((((SLICE_AREA/T2_F_AREA)*T2_GAIN)*100)+0.5)
T3_FLOW = math.floor((((SLICE_AREA/T3_F_AREA)*T3_GAIN)*100)+0.5)

-- Interface tool
if INTERFACE_TOOL == 0 then
	INTERFACE_X_OFFSET = T0_X_offset
	INTERFACE_Y_OFFSET = T0_Y_offset
	INTERFACE_FLOW = T0_FLOW
	INTERFACE_RETRACT = T0_RETRACT
	INTERFACE_NOZZLE = T0_NOZZLE_D
	INTERFACE_F_AREA = T0_F_AREA
elseif INTERFACE_TOOL == 1 then
	INTERFACE_X_OFFSET = T1_X_offset
	INTERFACE_Y_OFFSET = T1_Y_offset
	INTERFACE_FLOW = T1_FLOW
	INTERFACE_RETRACT = T1_RETRACT
	INTERFACE_NOZZLE = T1_NOZZLE_D
	INTERFACE_F_AREA = T1_F_AREA
elseif INTERFACE_TOOL == 2 then
	INTERFACE_X_OFFSET = T2_X_offset
	INTERFACE_Y_OFFSET = T2_Y_offset
	INTERFACE_FLOW = T2_FLOW
	INTERFACE_RETRACT = T2_RETRACT
	INTERFACE_NOZZLE = T2_NOZZLE_D
	INTERFACE_F_AREA = T2_F_AREA
elseif INTERFACE_TOOL == 3 then
	INTERFACE_X_OFFSET = T3_X_offset
	INTERFACE_Y_OFFSET = T3_Y_offset
	INTERFACE_FLOW = T3_FLOW
	INTERFACE_RETRACT = T3_RETRACT
	INTERFACE_NOZZLE = T3_NOZZLE_D
	INTERFACE_F_AREA = T3_F_AREA
end
	
-- Support tool
if SUPPORT_TOOL == 0 then
	SUPPORT_X_OFFSET = T0_X_offset
	SUPPORT_Y_OFFSET = T0_Y_offset
	SUPPORT_FLOW = T0_FLOW
	SUPPORT_RETRACT = T0_RETRACT
	SUPPORT_NOZZLE = T0_NOZZLE_D
	SUPPORT_F_AREA = T0_F_AREA
elseif SUPPORT_TOOL == 1 then
	SUPPORT_X_OFFSET = T1_X_offset
	SUPPORT_Y_OFFSET = T1_Y_offset
	SUPPORT_FLOW = T1_FLOW
	SUPPORT_RETRACT = T1_RETRACT
	SUPPORT_NOZZLE = T1_NOZZLE_D
	SUPPORT_F_AREA = T1_F_AREA
elseif SUPPORT_TOOL == 2 then
	SUPPORT_X_OFFSET = T2_X_offset
	SUPPORT_Y_OFFSET = T2_Y_offset
	SUPPORT_FLOW = T2_FLOW
	SUPPORT_RETRACT = T2_RETRACT
	SUPPORT_NOZZLE = T2_NOZZLE_D
	SUPPORT_F_AREA = T2_F_AREA
elseif SUPPORT_TOOL == 3 then
	SUPPORT_X_OFFSET = T3_X_offset
	SUPPORT_Y_OFFSET = T3_Y_offset
	SUPPORT_FLOW = T3_FLOW
	SUPPORT_RETRACT = T3_RETRACT
	SUPPORT_NOZZLE = T3_NOZZLE_D
	SUPPORT_F_AREA = T3_F_AREA
end
	
-- Perimeter tool
if PERIMETER_TOOL == 0 then
	PERIMETER_X_OFFSET = T0_X_offset
	PERIMETER_Y_OFFSET = T0_Y_offset
	PERIMETER_FLOW = T0_FLOW
	PERIMETER_RETRACT = T0_RETRACT
	PERIMETER_NOZZLE = T0_NOZZLE_D
	PERIMETER_F_AREA = T0_F_AREA
elseif PERIMETER_TOOL == 1 then
	PERIMETER_X_OFFSET = T1_X_offset
	PERIMETER_Y_OFFSET = T1_Y_offset
	PERIMETER_FLOW = T1_FLOW
	PERIMETER_RETRACT = T1_RETRACT
	PERIMETER_NOZZLE = T1_NOZZLE_D
	PERIMETER_F_AREA = T1_F_AREA
elseif PERIMETER_TOOL == 2 then
	PERIMETER_X_OFFSET = T2_X_offset
	PERIMETER_Y_OFFSET = T2_Y_offset
	PERIMETER_FLOW = T2_FLOW
	PERIMETER_RETRACT = T2_RETRACT
	PERIMETER_NOZZLE = T2_NOZZLE_D
	PERIMETER_F_AREA = T2_F_AREA
elseif PERIMETER_TOOL == 3 then
	PERIMETER_X_OFFSET = T3_X_offset
	PERIMETER_Y_OFFSET = T3_Y_offset
	PERIMETER_FLOW = T3_FLOW
	PERIMETER_RETRACT = T3_RETRACT
	PERIMETER_NOZZLE = T3_NOZZLE_D
	PERIMETER_F_AREA = T3_F_AREA
end
	
-- Loop tool
if LOOP_TOOL == 0 then
	LOOP_X_OFFSET = T0_X_offset
	LOOP_Y_OFFSET = T0_Y_offset
	LOOP_FLOW = T0_FLOW
	LOOP_RETRACT = T0_RETRACT
	LOOP_NOZZLE = T0_NOZZLE_D
	LOOP_F_AREA = T0_F_AREA
elseif LOOP_TOOL == 1 then
	LOOP_X_OFFSET = T1_X_offset
	LOOP_Y_OFFSET = T1_Y_offset
	LOOP_FLOW = T1_FLOW
	LOOP_RETRACT = T1_RETRACT
	LOOP_NOZZLE = T1_NOZZLE_D
	LOOP_F_AREA = T1_F_AREA
elseif LOOP_TOOL == 2 then
	LOOP_X_OFFSET = T2_X_offset
	LOOP_Y_OFFSET = T2_Y_offset
	LOOP_FLOW = T2_FLOW
	LOOP_RETRACT = T2_RETRACT
	LOOP_NOZZLE = T2_NOZZLE_D
	LOOP_F_AREA = T2_F_AREA
elseif LOOP_TOOL == 3 then
	LOOP_X_OFFSET = T3_X_offset
	LOOP_Y_OFFSET = T3_Y_offset
	LOOP_FLOW = T3_FLOW
	LOOP_RETRACT = T3_RETRACT
	LOOP_NOZZLE = T3_NOZZLE_D
	LOOP_F_AREA = T3_F_AREA
end

-- Solid tool
if SOLID_TOOL == 0 then
	SOLID_X_OFFSET = T0_X_offset
	SOLID_Y_OFFSET = T0_Y_offset
	SOLID_FLOW = T0_FLOW
	SOLID_RETRACT = T0_RETRACT
	SOLID_NOZZLE = T0_NOZZLE_D
	SOLID_F_AREA = T0_F_AREA
elseif SOLID_TOOL == 1 then
	SOLID_X_OFFSET = T1_X_offset
	SOLID_Y_OFFSET = T1_Y_offset
	SOLID_FLOW = T1_FLOW
	SOLID_RETRACT = T1_RETRACT
	SOLID_NOZZLE = T1_NOZZLE_D
	SOLID_F_AREA = T1_F_AREA
elseif SOLID_TOOL == 2 then
	SOLID_X_OFFSET = T2_X_offset
	SOLID_Y_OFFSET = T2_Y_offset
	SOLID_FLOW = T2_FLOW
	SOLID_RETRACT = T2_RETRACT
	SOLID_NOZZLE = T2_NOZZLE_D
	SOLID_F_AREA = T2_F_AREA
elseif SOLID_TOOL == 3 then
	SOLID_X_OFFSET = T3_X_offset
	SOLID_Y_OFFSET = T3_Y_offset
	SOLID_FLOW = T3_FLOW
	SOLID_RETRACT = T3_RETRACT
	SOLID_NOZZLE = T3_NOZZLE_D
	SOLID_F_AREA = T3_F_AREA
end
	
-- Sparse tool
if SPARSE_TOOL == 0 then
	SPARSE_X_OFFSET = T0_X_offset
	SPARSE_Y_OFFSET = T0_Y_offset
	SPARSE_FLOW = T0_FLOW
	SPARSE_RETRACT = T0_RETRACT
	SPARSE_NOZZLE = T0_NOZZLE_D
	SPARSE_F_AREA = T0_F_AREA
elseif SPARSE_TOOL == 1 then
	SPARSE_X_OFFSET = T1_X_offset
	SPARSE_Y_OFFSET = T1_Y_offset
	SPARSE_FLOW = T1_FLOW
	SPARSE_RETRACT = T1_RETRACT
	SPARSE_NOZZLE = T1_NOZZLE_D
	SPARSE_F_AREA = T1_F_AREA
elseif SPARSE_TOOL == 2 then
	SPARSE_X_OFFSET = T2_X_offset
	SPARSE_Y_OFFSET = T2_Y_offset
	SPARSE_FLOW = T2_FLOW
	SPARSE_RETRACT = T2_RETRACT
	SPARSE_NOZZLE = T2_NOZZLE_D
	SPARSE_F_AREA = T2_F_AREA
elseif SPARSE_TOOL == 3 then
	SPARSE_X_OFFSET = T3_X_offset
	SPARSE_Y_OFFSET = T3_Y_offset
	SPARSE_FLOW = T3_FLOW
	SPARSE_RETRACT = T3_RETRACT
	SPARSE_NOZZLE = T3_NOZZLE_D
	SPARSE_F_AREA = T3_F_AREA
end

if PRIME_PILLAR then
	LAST_PPL_X = PPL_X
	LAST_PPL_Y = PPL_Y
else
	LAST_PPL_X = 0
	LAST_PPL_Y = 0
end

-- Initiate a few global variables to T0 values
LAST_RETRACT = T0_RETRACT
Z_COUNT = 0
LAST_TOOL = 0

function RETRACT(distance)
	if ABSOLUTE_E then
		local value = last_E_value - distance
		fout:write("G1 F" , R_SPEED , " E" , value , "\r\n")
	else
		fout:write("G1 F" , R_SPEED , " E-" , distance , "\r\n")
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

function TOOL_CHANGE_1()	

	if PRIME_PILLAR then
		fout:write("G0 F" , T_SPEED , " X" , LAST_PPL_X , " Y" , LAST_PPL_Y , "\r\n")
	end
end

function TOOL_CHANGE_2(X, Y, W, R, A)	
	
	if PRIME_PILLAR then
		local new_X_1 = PPL_X + X
		local new_Y_1 = PPL_Y + Y
		fout:write("G92 X" , new_X_1 , " Y" , new_Y_1 , "\r\n")
		LAST_PPL_X = new_X_1
		LAST_PPL_Y = new_Y_1
		TOOL_CHANGE_1()
		PILLAR(W,A,R)
		fout:write("G0 F" , T_SPEED , " X" , LAST_X , " Y" , LAST_Y , "\r\n")
	elseif PRIME_PILLAR == false then
		local new_X_2 = LAST_X + (X - LAST_PPL_X)
		local new_Y_2 = LAST_Y + (Y - LAST_PPL_Y)
		fout:write("G92 X" , new_X_2 , " Y" , new_Y_2 , "\r\n")
		LAST_PPL_X = X
		LAST_PPL_Y = Y
		fout:write("G0 F" , T_SPEED , " X" , LAST_X , " Y" , LAST_Y , "\r\n")
	end
end

function PILLAR(W,A,R)
	if CURRENT_Z == LAST_Z then
		Z_COUNT = Z_COUNT+1
	else
		Z_COUNT = 0
	end
	
	P_OFFSET = (W*Z_COUNT)
	
	fout:write(";\r\n;Prime pillar \r\n")
	UN_RETRACT(R)
	ABS_E = last_E_value
	fout:write("G0 F" , T_SPEED , " X" , PPL_X - P_OFFSET , " Y" , PPL_Y - P_OFFSET , "\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X + (P_SIZE_X*0.125 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_X*0.250 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y + (P_SIZE_Y*0.125 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_Y*0.250 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X - (P_SIZE_X*0.125 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_X*0.250 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y - (P_SIZE_Y*0.125 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_Y*0.250 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X + (P_SIZE_X*0.250 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_X*0.375 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y + (P_SIZE_Y*0.250 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_Y*0.375 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X - (P_SIZE_X*0.250 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_X*0.500 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y - (P_SIZE_Y*0.250 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_Y*0.500 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X + (P_SIZE_X*0.375 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_X*0.625 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y + (P_SIZE_Y*0.375 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_Y*0.625 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X - (P_SIZE_X*0.375 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_X*0.750 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y - (P_SIZE_Y*0.375 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_Y*0.750 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X + (P_SIZE_X*0.500 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_X*0.875 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y + (P_SIZE_Y*0.500 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_Y*0.875 - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X - (P_SIZE_X*0.500 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_X - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y - (P_SIZE_Y*0.500 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_Y - P_OFFSET,A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X + (P_SIZE_X*0.500 - P_OFFSET)) , " E" , E_LENGTH(W, P_SIZE_X - P_OFFSET,A) ,"\r\n")
	if ABSOLUTE_E then
		fout:write("G92 E" , last_E_value , "\r\n")
	end
	RETRACT(R)
	fout:write("G0 F" , T_SPEED , " X" , PPL_X , " Y" , PPL_Y , "\r\n")
	fout:write(";\r\n")
	LAST_Z = CURRENT_Z
end

function E_LENGTH(W,L,A)

	local length = ((W*1.1)*L*LAYER_HEIGHT)/A
	local rounded_L = math.floor((length*10000)+0.5)*0.0001
	
	if ABSOLUTE_E then
		ABS_E = ABS_E + rounded_L
		return ABS_E
	else
		return rounded_L
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
			LAST_X = string.match(X, "%d+%.%d+")
		end
		
		-- Record Y position
		local Y = string.match(line, "Y%d+%.%d+")
		if Y then
			LAST_Y = string.match(Y, "%d+%.%d+")
		end
		
		-- Record Z position
		local Z = string.match(line, "Z%d+%.%d+")
		if Z then
			CURRENT_Z = string.match(Z, "%d+%.%d+")
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
		fout:write(";\r\n; Change tool for support interface.\r\n")
		RETRACT(LAST_RETRACT)
		TOOL_CHANGE_1(INTERFACE_X_OFFSET,INTERFACE_Y_OFFSET)
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. INTERFACE_TOOL , "\r\n")
		if INTERFACE_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , INTERFACE_TEMP , "\r\n")
		end
		TOOL_CHANGE_2(INTERFACE_X_OFFSET,INTERFACE_Y_OFFSET,INTERFACE_NOZZLE,INTERFACE_RETRACT,INTERFACE_F_AREA)
		UN_RETRACT(INTERFACE_RETRACT)
		fout:write("; Set support interface flow rate.\r\n")
		fout:write("M221 S" .. INTERFACE_FLOW .. "\r\n")
		LAST_RETRACT = INTERFACE_RETRACT
		LAST_TOOL = INTERFACE_TOOL
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set tool for support (Kisslicer)
	elseif sup_k and LAST_TOOL ~= SUPPORT_TOOL then
		fout:write(";\r\n; Change tool for support.\r\n")
		RETRACT(LAST_RETRACT)
		TOOL_CHANGE_1(SUPPORT_X_OFFSET,SUPPORT_Y_OFFSET)
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SUPPORT_TOOL , "\r\n")
		if SUPPORT_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , SUPPORT_TEMP , "\r\n")
		end
		TOOL_CHANGE_2(SUPPORT_X_OFFSET,SUPPORT_Y_OFFSET,SUPPORT_NOZZLE,SUPPORT_RETRACT,SUPPORT_F_AREA)
		UN_RETRACT(SUPPORT_RETRACT)
		fout:write("; Set support flow rate.\r\n")
		fout:write("M221 S" .. SUPPORT_FLOW .. "\r\n")
		LAST_RETRACT = SUPPORT_RETRACT
		LAST_TOOL = SUPPORT_TOOL
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set tool for perimeter (Kisslicer)
	elseif perim_k and LAST_TOOL ~= PERIMETER_TOOL then
		fout:write(";\r\n; Change tool for perimeter.\r\n")
		RETRACT(LAST_RETRACT)
		TOOL_CHANGE_1(PERIMETER_X_OFFSET,PERIMETER_Y_OFFSET)
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. PERIMETER_TOOL , "\r\n")
		if PERIMETER_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , PERIMETER_TEMP , "\r\n")
		end
		TOOL_CHANGE_2(PERIMETER_X_OFFSET,PERIMETER_Y_OFFSET,PERIMETER_NOZZLE,PERIMETER_RETRACT,PERIMETER_F_AREA)
		UN_RETRACT(PERIMETER_RETRACT)
		fout:write("; Set perimeter flow rate.\r\n")
		fout:write("M221 S" .. PERIMETER_FLOW .. "\r\n")
		LAST_RETRACT = PERIMETER_RETRACT
		LAST_TOOL = PERIMETER_TOOL
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set tool for loops (Kisslicer)
	elseif loop_k and LAST_TOOL ~= LOOP_TOOL then
		fout:write(";\r\n; Change tool for loops.\r\n")
		RETRACT(LAST_RETRACT)
		TOOL_CHANGE_1(LOOP_X_OFFSET,LOOP_Y_OFFSET)
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. LOOP_TOOL , "\r\n")
		if LOOP_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , LOOP_TEMP , "\r\n")
		end
		TOOL_CHANGE_2(LOOP_X_OFFSET,LOOP_Y_OFFSET,LOOP_NOZZLE,LOOP_RETRACT,LOOP_F_AREA)
		UN_RETRACT(LOOP_RETRACT)
		fout:write("; Set loop flow rate.\r\n")
		fout:write("M221 S" .. LOOP_FLOW .. "\r\n")
		LAST_RETRACT = LOOP_RETRACT
		LAST_TOOL = LOOP_TOOL
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set tool for solid infill (Kisslicer)
	elseif solid_k and LAST_TOOL ~= SOLID_TOOL then
		fout:write(";\r\n; Change tool for solid infill.\r\n")
		RETRACT(LAST_RETRACT)
		TOOL_CHANGE_1(SOLID_X_OFFSET,SOLID_Y_OFFSET)
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SOLID_TOOL , "\r\n")
		if SOLID_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , SOLID_TEMP , "\r\n")
		end
		TOOL_CHANGE_2(SOLID_X_OFFSET,SOLID_Y_OFFSET,SOLID_NOZZLE,SOLID_RETRACT,SOLID_F_AREA)
		UN_RETRACT(SOLID_RETRACT)
		fout:write("; Set solid infill flow rate.\r\n")
		fout:write("M221 S" .. SOLID_FLOW .. "\r\n")
		LAST_RETRACT = SOLID_RETRACT
		LAST_TOOL = SOLID_TOOL
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set tool for sparse infill (Kisslicer)
	elseif sparse_k and LAST_TOOL ~= SPARSE_TOOL then
		fout:write(";\r\n; Change tool for sparse infill.\r\n")
		RETRACT(LAST_RETRACT)
		TOOL_CHANGE_1(SPARSE_X_OFFSET,SPARSE_Y_OFFSET)
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SPARSE_TOOL , "\r\n")
		if SPARSE_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , SPARSE_TEMP , "\r\n;\r\n")
		end
		TOOL_CHANGE_2(SPARSE_X_OFFSET,SPARSE_Y_OFFSET,SPARSE_NOZZLE,SPARSE_RETRACT,SPARSE_F_AREA)
		UN_RETRACT(SPARSE_RETRACT)
		fout:write("; Set sparse infill flow rate.\r\n")
		fout:write("M221 S" .. SPARSE_FLOW .. "\r\n")
		LAST_RETRACT = SPARSE_RETRACT
		LAST_TOOL = SPARSE_TOOL
		fout:write(";\r\n" .. line .. "\r\n")


	-- Cura only
	-- Set tool for support (Cura)
	elseif sup_c and LAST_TOOL ~= SUPPORT_TOOL then
		fout:write(";\r\n; Change tool for support.\r\n")
		RETRACT(LAST_RETRACT)
		TOOL_CHANGE_1(SUPPORT_X_OFFSET,SUPPORT_Y_OFFSET)
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SUPPORT_TOOL , "\r\n")
		if SUPPORT_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , SUPPORT_TEMP , "\r\n")
		end
		TOOL_CHANGE_2(SUPPORT_X_OFFSET,SUPPORT_Y_OFFSET,SUPPORT_NOZZLE,SUPPORT_RETRACT,SUPPORT_F_AREA)
		UN_RETRACT(SUPPORT_RETRACT)
		fout:write("; Set support flow rate.\r\n")
		fout:write("M221 S" .. SUPPORT_FLOW .. "\r\n")
		LAST_RETRACT = SUPPORT_RETRACT
		LAST_TOOL = SUPPORT_TOOL
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set tool for perimeter (Cura)
	elseif perim_c and LAST_TOOL ~= PERIMETER_TOOL then
		fout:write(";\r\n; Change tool for perimeter.\r\n")
		RETRACT(LAST_RETRACT)
		TOOL_CHANGE_1(PERIMETER_X_OFFSET,PERIMETER_Y_OFFSET)
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. PERIMETER_TOOL , "\r\n")
		if PERIMETER_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , PERIMETER_TEMP , "\r\n")
		end
		TOOL_CHANGE_2(PERIMETER_X_OFFSET,PERIMETER_Y_OFFSET,PERIMETER_NOZZLE,PERIMETER_RETRACT,PERIMETER_F_AREA)
		UN_RETRACT(PERIMETER_RETRACT)
		fout:write("; Set perimeter flow rate.\r\n")
		fout:write("M221 S" .. PERIMETER_FLOW .. "\r\n")
		LAST_RETRACT = PERIMETER_RETRACT
		LAST_TOOL = PERIMETER_TOOL
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set tool for loops (Cura)
	elseif loop_c and LAST_TOOL ~= LOOP_TOOL then
		fout:write(";\r\n; Change tool for loops.\r\n")
		RETRACT(LAST_RETRACT)
		TOOL_CHANGE_1(LOOP_X_OFFSET,LOOP_Y_OFFSET)
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. LOOP_TOOL , "\r\n")
		if LOOP_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , LOOP_TEMP , "\r\n")
		end
		TOOL_CHANGE_2(LOOP_X_OFFSET,LOOP_Y_OFFSET,LOOP_NOZZLE,LOOP_RETRACT,LOOP_F_AREA)
		UN_RETRACT(LOOP_RETRACT)
		fout:write("; Set loop flow rate.\r\n")
		fout:write("M221 S" .. LOOP_FLOW .. "\r\n")
		LAST_RETRACT = LOOP_RETRACT
		LAST_TOOL = LOOP_TOOL
		fout:write(";\r\n" .. line .. "\r\n")

	-- Set tool for infill (Cura)
	elseif infill_c and LAST_TOOL ~= SPARSE_TOOL then
		fout:write(";\r\n; Change tool for infill.\r\n")
		RETRACT(LAST_RETRACT)
		TOOL_CHANGE_1(SPARSE_X_OFFSET,SPARSE_Y_OFFSET)
		if IDLE_TEMP > 0 then
			fout:write("M104 S" , IDLE_TEMP , "\r\n")
		end
		fout:write("T" .. SPARSE_TOOL , "\r\n")
		if SPARSE_TEMP > 0 then
			fout:write(TEMP_CODE , " S" , SPARSE_TEMP , "\r\n")
		end
		TOOL_CHANGE_2(SPARSE_X_OFFSET,SPARSE_Y_OFFSET,SPARSE_NOZZLE,SPARSE_RETRACT,SPARSE_F_AREA)
		UN_RETRACT(LOOP_RETRACT)
		fout:write("; Set sparse infill flow rate.\r\n")
		fout:write("M221 S" .. SPARSE_FLOW .. "\r\n")
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
