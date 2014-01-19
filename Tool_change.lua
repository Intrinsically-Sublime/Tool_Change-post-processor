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

-- Extrusion mode (Absolute E because Cura does not support Relative or use ABS_2_REL post processor first https://github.com/Intrinsically-Sublime/ABS_2_REL )
ABSOLUTE_E = true

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
T0_X_OFFSET = 0
T0_Y_OFFSET = 0

T1_X_OFFSET = 35
T1_Y_OFFSET = 0

T2_X_OFFSET = 0
T2_Y_OFFSET = 35

T3_X_OFFSET = 35
T3_Y_OFFSET = 35

----------------------- End machine setup -----------------------

--------------------- Start gcode settings ---------------------

-- Code for temperature increase on tool select (Marlin --- M104 = no wait, M109 = wait)
TEMP_CODE = "M109"

-- Tool change retraction speed
R_SPEED = 1800 -- In mm/m (1800mm/m = 30mm/s)

-- Travel speed
T_SPEED = 6000 -- In mm/m (6000mm/m = 100mm/s)

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

-- Prime pillar
PRIME_PILLAR = true

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

-- Create arrays to sort tool variables to section types (Lua normally index's from 1 so we have to force a 0 index)
Get_Temp = {
["interface"] = INTERFACE_TEMP,
["support"] = SUPPORT_TEMP,
["perimeter"] = PERIMETER_TEMP,
["loop"] = LOOP_TEMP,
["solid"] = SOLID_TEMP,
["infill"] = SPARSE_TEMP
}

Get_X_Offset = {
[0] = T0_X_OFFSET,
[1] = T1_X_OFFSET,
[2] = T2_X_OFFSET,
[3] = T3_X_OFFSET
}

Get_Y_Offset = {
[0] = T0_Y_OFFSET,
[1] = T1_Y_OFFSET,
[2] = T2_Y_OFFSET,
[3] = T3_Y_OFFSET
}

Get_Flow = {
[0] = T0_FLOW,
[1] = T1_FLOW,
[2] = T2_FLOW,
[3] = T3_FLOW
}

Get_Retract = {
[0] = T0_RETRACT,
[1] = T1_RETRACT,
[2] = T2_RETRACT,
[3] = T3_RETRACT
}

Get_Nozzle_D = {
[0] = T0_NOZZLE_D,
[1] = T1_NOZZLE_D,
[2] = T2_NOZZLE_D,
[3] = T3_NOZZLE_D
}

Get_F_Area = {
[0] = T0_F_AREA,
[1] = T1_F_AREA,
[2] = T2_F_AREA,
[3] = T3_F_AREA
}

if PRIME_PILLAR then
	LAST_PPL_X = PPL_X
	LAST_PPL_Y = PPL_Y
else
	LAST_PPL_X = 0
	LAST_PPL_Y = 0
end

-- Initiate a few global variables to T0 values
LAST_RETRACT = T0_RETRACT
LAST_NOZZLE = T0_NOZZLE_D
LAST_F_AREA = T0_F_AREA
LAST_X_OFFSET = T0_X_OFFSET
LAST_Y_OFFSET = T0_Y_OFFSET
-- Initiate a few more global variables with 0 values
LAST_X = 0
LAST_Y = 0
Z_COUNT = 0
LAST_TOOL = 0
LAYER = 0
LAST_LAYER = 0
FORCE_TOWER = true

function RETRACT(distance)
	if ABSOLUTE_E then
		local E = LAST_E - distance
		fout:write("G1 F" , R_SPEED , " E" , E , "\r\n")
	else
		fout:write("G1 F" , R_SPEED , " E-" , distance , "\r\n")
	end
end

function UN_RETRACT(distance)
	if ABSOLUTE_E then
		local E = LAST_E - distance
		fout:write("G92 E" , E , "\r\n")
		fout:write("G1 F" , R_SPEED , " E" , LAST_E , "\r\n")
	else
		fout:write("G1 F" , R_SPEED , " E" , distance , "\r\n")
	end
end

function COOL()
	if IDLE_TEMP > 0 then
		fout:write("M104 S" , IDLE_TEMP , "\r\n")
	end
end

function HEAT(temp)
	if INTERFACE_TEMP > 0 then
		fout:write(TEMP_CODE , " S" , temp , "\r\n")
	end
end

function LINE_OUT(line)
	fout:write(";\r\n" .. line .. "\r\n")
end

function GO_TO_PPL()	
	if PRIME_PILLAR then
		fout:write(";\r\n;Go to prime pillar location \r\n")
		fout:write("G0 F" , T_SPEED , " X" , LAST_PPL_X , " Y" , LAST_PPL_Y , "\r\n")
	end
end

function GO_TO_LAST()
	fout:write(";\r\n;Go to last print location \r\n")
	fout:write("G0 F" , T_SPEED , " X" , LAST_X , " Y" , LAST_Y , "\r\n")
end

function SELECT_TOOL(tool)
	fout:write(";\r\n;Set tool \r\n")
	fout:write("T" .. tool , "\r\n")
end

function SET_FLOW(flow)
	fout:write("M221 S" .. flow .. "\r\n")
end

function TOOL_CHANGE(X, Y, W, R, A) -- X, Y, Width, Retract, Area
	
	if PRIME_PILLAR then
		local new_X_1 = PPL_X + X
		local new_Y_1 = PPL_Y + Y
		fout:write("G92 X" , new_X_1 , " Y" , new_Y_1 , "\r\n")
		LAST_PPL_X = new_X_1
		LAST_PPL_Y = new_Y_1
		PILLAR(W,A,R)
		GO_TO_LAST()
	elseif PRIME_PILLAR == false then
		local new_X_2 = LAST_X + (X - LAST_PPL_X)
		local new_Y_2 = LAST_Y + (Y - LAST_PPL_Y)
		fout:write("G92 X" , new_X_2 , " Y" , new_Y_2 , "\r\n")
		LAST_PPL_X = X
		LAST_PPL_Y = Y
		GO_TO_LAST()
	end
end

function PILLAR(W,A,R) -- Width, Area, Retract

	if CURRENT_Z == LAST_Z then
		Z_COUNT = Z_COUNT+1
	else
		Z_COUNT = 0
	end
	
	FORCE_TOWER = false
	
	P_OFFSET = (W*Z_COUNT)
	
	local Get_PPP_X = {
	[0] = P_SIZE_X-P_OFFSET,
	[1] = (P_SIZE_X*0.125)-P_OFFSET,
	[2] = (P_SIZE_X*0.250)-P_OFFSET,
	[3] = (P_SIZE_X*0.375)-P_OFFSET,
	[4] = (P_SIZE_X*0.500)-P_OFFSET,
	[5] = (P_SIZE_X*0.625)-P_OFFSET,
	[6] = (P_SIZE_X*0.750)-P_OFFSET,
	[7] = (P_SIZE_X*0.875)-P_OFFSET
	}
	
	local Get_PPP_Y = {
	[0] = P_SIZE_Y-P_OFFSET,
	[1] = (P_SIZE_Y*0.125)-P_OFFSET,
	[2] = (P_SIZE_Y*0.250)-P_OFFSET,
	[3] = (P_SIZE_Y*0.375)-P_OFFSET,
	[4] = (P_SIZE_Y*0.500)-P_OFFSET,
	[5] = (P_SIZE_Y*0.625)-P_OFFSET,
	[6] = (P_SIZE_Y*0.750)-P_OFFSET,
	[7] = (P_SIZE_Y*0.875)-P_OFFSET
	}
	
	fout:write(";\r\n;Prime pillar \r\n")
	UN_RETRACT(R)
	ABS_E = LAST_E
	fout:write("G0 F" , T_SPEED , " X" , PPL_X , " Y" , PPL_Y , "\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X+Get_PPP_X[1]) , " E" , E_LENGTH(W,Get_PPP_X[2],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y+Get_PPP_Y[1]) , " E" , E_LENGTH(W,Get_PPP_Y[2],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X-Get_PPP_X[1]) , " E" , E_LENGTH(W,Get_PPP_X[2],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y-Get_PPP_Y[1]) , " E" , E_LENGTH(W,Get_PPP_Y[2],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X+Get_PPP_X[2]) , " E" , E_LENGTH(W,Get_PPP_X[3],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y+Get_PPP_Y[2]) , " E" , E_LENGTH(W,Get_PPP_Y[3],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X-Get_PPP_X[2]) , " E" , E_LENGTH(W,Get_PPP_X[4],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y-Get_PPP_Y[2]) , " E" , E_LENGTH(W,Get_PPP_Y[4],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X+Get_PPP_X[3]) , " E" , E_LENGTH(W,Get_PPP_X[5],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y+Get_PPP_Y[3]) , " E" , E_LENGTH(W,Get_PPP_Y[5],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X-Get_PPP_X[3]) , " E" , E_LENGTH(W,Get_PPP_X[6],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y-Get_PPP_Y[3]) , " E" , E_LENGTH(W,Get_PPP_Y[6],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X+Get_PPP_X[4]) , " E" , E_LENGTH(W,Get_PPP_X[7],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y+Get_PPP_Y[4]) , " E" , E_LENGTH(W,Get_PPP_Y[7],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X-Get_PPP_X[4]) , " E" , E_LENGTH(W,Get_PPP_X[0],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " Y" , (PPL_Y-Get_PPP_Y[4]) , " E" , E_LENGTH(W,Get_PPP_Y[0],A) ,"\r\n")
	fout:write("G1 F" , P_SPEED , " X" , (PPL_X+Get_PPP_X[4]) , " E" , E_LENGTH(W,Get_PPP_X[0],A) ,"\r\n")
	if ABSOLUTE_E then
		fout:write("G92 E" , LAST_E , "\r\n")
	end
	RETRACT(R)
	fout:write("G0 F" , T_SPEED , " X" , PPL_X , " Y" , PPL_Y , "\r\n")
	LAST_Z = CURRENT_Z
end

function E_LENGTH(W,L,A) -- Width, Length, Area

	local length = ((W*1.1)*L*LAYER_HEIGHT)/A
	local rounded_L = math.floor((length*10000)+0.5)*0.0001
	
	if ABSOLUTE_E then
		ABS_E = ABS_E + rounded_L
		return ABS_E
	else
		return rounded_L
	end
end

function FORCE_PILLAR(line)
	fout:write(";\r\n; Force prime pillar.\r\n")
	RETRACT(LAST_RETRACT)
	GO_TO_PPL()
	TOOL_CHANGE(LAST_X_OFFSET,LAST_Y_OFFSET,LAST_NOZZLE,LAST_RETRACT,LAST_F_AREA)
	UN_RETRACT(LAST_RETRACT)
	LINE_OUT(line)
end

function INSERT_BLOCK(line, tool, section)
	fout:write(";\r\n; Change tool for " .. section .. "\r\n")
	RETRACT(LAST_RETRACT)
	GO_TO_PPL()
	COOL()
	SELECT_TOOL(tool)
	HEAT(Get_Temp[section])
	TOOL_CHANGE(Get_X_Offset[tool],Get_Y_Offset[tool],Get_Nozzle_D[tool],Get_Retract[tool],Get_F_Area[tool])
	UN_RETRACT(Get_Retract[tool])
	fout:write("; Set flow rate for " .. section .. "\r\n")
	SET_FLOW(Get_Flow[tool])
	LAST_RETRACT = Get_Retract[tool]
	LAST_TOOL = tool
	LAST_X_OFFSET = Get_X_Offset[tool]
	LAST_Y_OFFSET = Get_Y_Offset[tool]
	LAST_NOZZLE = Get_Nozzle_D[tool]
	LAST_F_AREA = Get_F_Area[tool]
	LINE_OUT(line)
end

-- read lines
for line in fin:lines() do
	
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
	
	local layer = string.match(line, ";LAYER:") or string.match(line, "; BEGIN_LAYER")
	if layer then
		LAYER = LAYER + 1
	end
	
	-- Record E value for ABSOLUTE_E
	if  ABSOLUTE_E then
		local E = string.match(line, "E%d+%.%d+")
		if E then
			LAST_E = string.match(E, "%d+%.%d+")
		end
	end
	
	local g92_E0 = line.match(line, "G92 E0")
	if g92_E0 then
		LAST_E = 0
	end
	
	local inter = line:match( "; 'Support Interface',") -- Find start of support interface
	local sup = line:match( "; 'Support (may Stack)',") or line:match(";TYPE:SUPPORT") -- Find start of support
	local perim = line:match( "; 'Perimeter',") or line:match(";TYPE:WALL\--OUTER") -- Find start of perimeter
	local loop = line:match( "; 'Loop',") or line:match(";TYPE:WALL\--INNER") -- Find start of loops
	local solid = line:match( "; 'Solid',") -- Find start of solid infill
	local sparse = line:match( "; 'Stacked Sparse Infill',") or line:match(";TYPE:FILL") -- Find start of sparse infill

	-- Force prime pillar on layer without tool change.
	if LAYER ~= LAST_LAYER and FORCE_TOWER and PRIME_PILLAR and LAYER > 1 then
		FORCE_PILLAR(line)
	
	-- Set new tool for support interface (Kisslicer)
	elseif inter and LAST_TOOL ~= INTERFACE_TOOL then
		INSERT_BLOCK(line,INTERFACE_TOOL,"interface")

	-- Set tool for support (Kisslicer)
	elseif sup and LAST_TOOL ~= SUPPORT_TOOL then
		INSERT_BLOCK(line,SUPPORT_TOOL,"support")

	-- Set tool for perimeter (Kisslicer)
	elseif perim and LAST_TOOL ~= PERIMETER_TOOL then
		INSERT_BLOCK(line,PERIMETER_TOOL,"perimeter")

	-- Set tool for loops (Kisslicer)
	elseif loop and LAST_TOOL ~= LOOP_TOOL then
		INSERT_BLOCK(line,LOOP_TOOL,"loop")

	-- Set tool for solid infill (Kisslicer)
	elseif solid and LAST_TOOL ~= SOLID_TOOL then
		INSERT_BLOCK(line,SOLID_TOOL,"solid")

	-- Set tool for sparse infill (Kisslicer)
	elseif sparse and LAST_TOOL ~= SPARSE_TOOL then
		INSERT_BLOCK(line,SPARSE_TOOL,"infill")
	
	else
	        fout:write(line .. "\n" )
	end
	
	if LAYER ~= LAST_LAYER and FORCE_TOWER == false then
		FORCE_TOWER = true
	end
	
	LAST_LAYER = LAYER
end

-- done
fin:close()
fout:close()
print "done"
