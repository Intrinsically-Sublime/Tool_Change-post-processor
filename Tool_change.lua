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
-- First layer Z value (Z-offset set in slicer will effect this)
-- Extrusion width set in the slicer (will be used for the prime pillar)
SLICE_DIAMETER = 3
LAYER_HEIGHT = 0.1
FIRST_L_HEIGHT = 0.1
EXTRUSION_WIDTH = 0.52

--------------------- End slicer settings ---------------------

--------------------- Start machine setup ---------------------

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
PPL_X = 16
PPL_Y = 16

-- Prime pillar size (Will be centred at the prime pillar location)(Minimum size is 4mm per extruder being used)
P_SIZE_X = 16
P_SIZE_Y = 16

-- Prime pillar print speed
P_SPEED = 1800

-- Pillar Z roof (stop pillar after this many layers)
PILLAR_ROOF = 999

-- Prime pillar raft inflation (Raft will be this many mm larger on each side than the prime pillar)
RAFT_INFLATE = 2

-- Raft extrusion in percent of pillar extrusion
RAFT_GAIN = 110

-- Raft line spacing
RAFT_SPACING = 2

-- Raft thickness (layer count)
RAFT_THICKNESS = 3

---------------------- End prime pillar settings ----------------------


-----------------------------------------------------------------------------
-->>>>>>>>>>>>>>>>>>>>>>>>>>> END USER SETTINGS <<<<<<<<<<<<<<<<<<<<<<<<<<<--
-----------------------------------------------------------------------------

-- open files
collectgarbage()  -- ensure unused files are closed
local fin = assert( io.open( arg[1] ) ) -- reading
local fout = assert( io.open( arg[1] .. ".processed", "wb" ) ) -- writing must be binary

slice_Area = (3.14159*((SLICE_DIAMETER*0.5)*(SLICE_DIAMETER*0.5)))

T0_F_area = (3.14159*((T0_DIAMETER*0.5)*(T0_DIAMETER*0.5)))
T1_F_area = (3.14159*((T1_DIAMETER*0.5)*(T1_DIAMETER*0.5)))
T2_F_area = (3.14159*((T2_DIAMETER*0.5)*(T2_DIAMETER*0.5)))
T3_F_area = (3.14159*((T3_DIAMETER*0.5)*(T3_DIAMETER*0.5)))

T0_Flow = math.floor((((slice_Area/T0_F_area)*T0_GAIN)*100)+0.5)
T1_Flow = math.floor((((slice_Area/T1_F_area)*T1_GAIN)*100)+0.5)
T2_Flow = math.floor((((slice_Area/T2_F_area)*T2_GAIN)*100)+0.5)
T3_Flow = math.floor((((slice_Area/T3_F_area)*T3_GAIN)*100)+0.5)

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
[0] = T0_Flow,
[1] = T1_Flow,
[2] = T2_Flow,
[3] = T3_Flow
}

Get_Retract = {
[0] = T0_RETRACT,
[1] = T1_RETRACT,
[2] = T2_RETRACT,
[3] = T3_RETRACT
}

Get_F_Area = {
[0] = T0_F_area,
[1] = T1_F_area,
[2] = T2_F_area,
[3] = T3_F_area
}

if PRIME_PILLAR then
	last_PPL_X = PPL_X
	last_PPL_Y = PPL_Y
else
	last_PPL_X = 0
	last_PPL_Y = 0
end

-- Initiate a few global variables to T0 values
tool_X_offset = Get_X_Offset[0]
tool_Y_offset = Get_Y_Offset[0]
tool_Retract = Get_Retract[0]
tool_Area = Get_F_Area[0]
tool_Flow = Get_Flow[0]
-- Initiate a few more global variables with 0 values
last_X = 0
last_Y = 0
Z_Count = 0
last_Tool = 0
Layer = 0
last_Layer = 0
force_Tower = true
last_Raft = false
ABS_E = 0
first_pillar = RAFT_THICKNESS

function retract()
	if ABSOLUTE_E == true then
		local E = current_E - tool_Retract
		fout:write("G1 F" , R_SPEED , " E" , E , "\r\n")
	else
		fout:write("G1 F" , R_SPEED , " E-" , tool_Retract , "\r\n")
	end
end

function un_Retract()
	if ABSOLUTE_E == true then
		local E = current_E - tool_Retract
		fout:write("G92 E" , E , "\r\n")
		fout:write("G1 F" , R_SPEED , " E" , current_E , "\r\n")
	else
		fout:write("G1 F" , R_SPEED , " E" , tool_Retract , "\r\n")
	end
end

function cool()
	if IDLE_TEMP > 0 then
		fout:write("M104 S" , IDLE_TEMP , "\r\n")
	end
end

function heat(temp)
	if INTERFACE_TEMP > 0 then
		fout:write(TEMP_CODE , " S" , temp , "\r\n")
	end
end

function line_Out(line)
	fout:write(";\r\n" .. line .. "\r\n")
end

function go_To_PPL()
	fout:write(";\r\n;Go to prime pillar location \r\n")
	travel(last_PPL_X,last_PPL_Y)
end

function go_To_Last()
	fout:write(";\r\n;Go to last print location \r\n")
	travel(last_X,last_Y)
end

function travel(X,Y)
	fout:write("G0 F" , T_SPEED , " X" , X , " Y" , Y , "\r\n")
	draw_X = X
	draw_Y = Y
end

function draw_Line(X,Y)
	E = E_Length(path_Length(X,Y))
	fout:write("G1 F" , P_SPEED , " X" , X , " Y" , Y , " E" , E , "\r\n")
	draw_X = X
	draw_Y = Y
end
-- Calculate path length
function path_Length(X,Y)
	X = X-draw_X
	Y = Y-draw_Y
	return math.sqrt((X*X)+(Y*Y))
end

-- Calculate Raft size
R_Size_X = P_SIZE_X+(RAFT_INFLATE*2)
R_Size_Y = P_SIZE_Y+(RAFT_INFLATE*2)
-- Calculate Raft min and max locations on X and Y
R_Min_X = PPL_X-(R_Size_X/2)
R_Max_X = R_Min_X+R_Size_X
R_Min_Y = PPL_Y-(R_Size_Y/2)
R_Max_Y = R_Min_Y+R_Size_Y
-- Calculate the distance between perimeter points
R_Spaces = EXTRUSION_WIDTH*RAFT_SPACING
R_X_Step = R_Size_X/(math.floor(R_Size_X/R_Spaces))
R_Y_Step = R_Size_Y/(math.floor(R_Size_Y/R_Spaces))
R_X_Count = R_Size_X/R_X_Step
R_Y_Count = R_Size_Y/R_Y_Step
RP_Count = (R_X_Count+R_Y_Count)*2

-- Creates arrays of Raft Points (X and Y coordinates)
Get_RP_X = {}
Get_RP_Y = {}
for i=1, RP_Count do
	if i <= R_Y_Count then 
		value_1 = R_Min_X
		value_2 = R_Min_Y+(R_Y_Step*i)
	elseif i > R_Y_Count and i <= (R_Y_Count+R_X_Count) then
		value_1 = R_Min_X+(R_X_Step*(i-R_Y_Count))
		value_2 = R_Max_Y
	elseif i > (R_Y_Count+R_X_Count) and i <= ((R_Y_Count*2)+R_X_Count) then
		value_1 = R_Max_X
		value_2 = R_Max_Y-(R_Y_Step*(i-(R_X_Count+R_Y_Count)))
	else 
		value_1 = R_Max_X-(R_X_Step*(i-((R_Y_Count*2)+R_X_Count)))
		value_2 = R_Min_Y
	end
	Get_RP_X[i] = math.floor((value_1*10000)+0.5)*0.0001
	Get_RP_Y[i] = math.floor((value_2*10000)+0.5)*0.0001
end
-- Turn previous Raft points 90 degrees
Get_RP_X_90 = {}
Get_RP_Y_90 = {}
for i=1, RP_Count do
	if i <= RP_Count-R_Y_Count then
		Get_RP_X_90[i] = Get_RP_X[R_Y_Count+i]
		Get_RP_Y_90[i] = Get_RP_Y[R_Y_Count+i]
	end
	if i <= R_Y_Count then
		Get_RP_X_90[(RP_Count-R_Y_Count)+i] = Get_RP_X[i]
		Get_RP_Y_90[(RP_Count-R_Y_Count)+i] = Get_RP_Y[i]
	end
end

function draw_R_Skirt()

	fout:write(";\r\n;Pillar raft skirt \r\n")
	ABS_E = current_E
	set_Flow(RAFT_GAIN)
	local overlap = EXTRUSION_WIDTH*0.5
	local x_min = R_Min_X-overlap
	local x_max = R_Max_X+overlap
	local y_min = R_Min_Y-overlap
	local y_max = R_Max_Y+overlap
	travel(x_min,y_min)
	draw_Line(x_min,y_max)
	draw_Line(x_max,y_max)
	draw_Line(x_max,y_min)
	draw_Line(x_min,y_min)
	set_Flow(100)
	if ABSOLUTE_E == true then
		fout:write("G92 E" , current_E , "\r\n")
	end
end

function draw_Raft()

	fout:write(";\r\n;Prime pillar raft \r\n")
	un_Retract()
	set_Flow(RAFT_GAIN)
	draw_R_Skirt()
	ABS_E = current_E
	if Layer % 2 == 0 then
		for i=1, RP_Count/2, 2 do
			draw_Line(Get_RP_X_90[RP_Count-(i-1)],Get_RP_Y_90[RP_Count-(i-1)])
			draw_Line(Get_RP_X_90[RP_Count-(i-1)-1],Get_RP_Y_90[RP_Count-(i-1)-1])
			draw_Line(Get_RP_X_90[i],Get_RP_Y_90[i])
			draw_Line(Get_RP_X_90[i+1],Get_RP_Y_90[i+1])
		end
	else
		for i=1, RP_Count/2, 2 do
			draw_Line(Get_RP_X[RP_Count-(i-1)],Get_RP_Y[RP_Count-(i-1)])
			draw_Line(Get_RP_X[RP_Count-(i-1)-1],Get_RP_Y[RP_Count-(i-1)-1])
			draw_Line(Get_RP_X[i],Get_RP_Y[i])
			draw_Line(Get_RP_X[i+1],Get_RP_Y[i+1])
		end
	end
	
	if ABSOLUTE_E == true then
		fout:write("G92 E" , current_E , "\r\n")
	end
	set_Flow(100)
	retract()
end

function select_Tool(tool)
	tool_X_offset = Get_X_Offset[tool]
	tool_Y_offset = Get_Y_Offset[tool]
	tool_Retract = Get_Retract[tool]
	tool_Area = Get_F_Area[tool]
	tool_Temp = Get_Temp[tool]
	tool_Flow = Get_Flow[tool]
	fout:write(";\r\n;Set tool \r\n")
	fout:write("T" .. tool , "\r\n")
end

function set_Flow()
	fout:write("M221 S" .. tool_Flow .. "\r\n")
end

function tool_Change()
	
	if PRIME_PILLAR and Layer <= PILLAR_ROOF then
		local new_X_1 = PPL_X + tool_X_offset
		local new_Y_1 = PPL_Y + tool_Y_offset
		fout:write("G92 X" , new_X_1 , " Y" , new_Y_1 , "\r\n")
		last_PPL_X = new_X_1
		last_PPL_Y = new_Y_1
		if Layer ~= last_Layer and Layer > raft_start and Layer <= RAFT_THICKNESS then
			if last_Raft == false then
				if Layer == raft_start+1 then
					fout:write("G1 F" .. T_SPEED .. " Z" .. FIRST_L_HEIGHT .. "\r\n")
				end
				travel(R_Min_X,R_Min_Y)
				draw_Raft()
				last_Raft = true
			end
		elseif Layer > first_pillar then
			travel(PPL_X,PPL_Y)
			draw_Pillar()
		end
		go_To_Last()
	else
		local new_X_2 = last_X + (tool_X_offset - last_PPL_X)
		local new_Y_2 = last_Y + (tool_Y_offset - last_PPL_Y)
		fout:write("G92 X" , new_X_2 , " Y" , new_Y_2 , "\r\n")
		last_PPL_X = tool_X_offset
		last_PPL_Y = tool_Y_offset
		go_To_Last()
	end
end

function draw_Pillar()

	if Layer > first_pillar then
		if current_Z == last_Z then
			Z_Count = Z_Count+1
		else
			Z_Count = 0
		end
		
		force_Tower = false
		
		P_Offset = (EXTRUSION_WIDTH*Z_Count)
	
		-- Creates arrays of Prime Pillar Points (X and Y coordinates)
		local Get_PPP_X = {[0]=P_Offset}
		local Get_PPP_Y = {[0]=P_Offset}
		for i=1, 7 do
			Get_PPP_X[i] = (P_SIZE_X*(i*0.125))-P_Offset
			Get_PPP_Y[i] = (P_SIZE_Y*(i*0.125))-P_Offset
		end
		
		fout:write(";\r\n;Prime pillar \r\n")
		un_Retract()
		ABS_E = current_E
		draw_Line(PPL_X+Get_PPP_X[1],PPL_Y+Get_PPP_Y[0])
		draw_Line(PPL_X+Get_PPP_X[1],PPL_Y+Get_PPP_Y[1])
		draw_Line(PPL_X-Get_PPP_X[1],PPL_Y+Get_PPP_Y[1])
		draw_Line(PPL_X-Get_PPP_X[1],PPL_Y-Get_PPP_Y[1])
		draw_Line(PPL_X+Get_PPP_X[2],PPL_Y-Get_PPP_Y[1])
		draw_Line(PPL_X+Get_PPP_X[2],PPL_Y+Get_PPP_Y[2])
		draw_Line(PPL_X-Get_PPP_X[2],PPL_Y+Get_PPP_Y[2])
		draw_Line(PPL_X-Get_PPP_X[2],PPL_Y-Get_PPP_Y[2])
		draw_Line(PPL_X+Get_PPP_X[3],PPL_Y-Get_PPP_Y[2])
		draw_Line(PPL_X+Get_PPP_X[3],PPL_Y+Get_PPP_Y[3])
		draw_Line(PPL_X-Get_PPP_X[3],PPL_Y+Get_PPP_Y[3])
		draw_Line(PPL_X-Get_PPP_X[3],PPL_Y-Get_PPP_Y[3])
		draw_Line(PPL_X+Get_PPP_X[4],PPL_Y-Get_PPP_Y[3])
		draw_Line(PPL_X+Get_PPP_X[4],PPL_Y+Get_PPP_Y[4])
		draw_Line(PPL_X-Get_PPP_X[4],PPL_Y+Get_PPP_Y[4])
		draw_Line(PPL_X-Get_PPP_X[4],PPL_Y-Get_PPP_Y[4])
		draw_Line(PPL_X+Get_PPP_X[4],PPL_Y-Get_PPP_Y[4])
		draw_Line(PPL_X+Get_PPP_X[4],PPL_Y-Get_PPP_Y[3]-P_Offset)
		if ABSOLUTE_E == true then
			fout:write("G92 E" , current_E , "\r\n")
		end
		retract()
		fout:write("G0 F" , T_SPEED , " X" , PPL_X , " Y" , PPL_Y , "\r\n")
		last_Z = current_Z
	end
end	

function E_Length(L) -- Length

	local length = (EXTRUSION_WIDTH*L*LAYER_HEIGHT)/tool_Area
	local rounded_L = math.floor((length*10000)+0.5)*0.0001
	
	if ABSOLUTE_E == true then
		ABS_E = ABS_E + rounded_L
		return ABS_E
	else
		return rounded_L
	end
end

function force_Pillar(line)
	fout:write(";\r\n; Force prime pillar.\r\n")
	retract()
	go_To_PPL()
	tool_Change()
	un_Retract()
	line_Out(line)
end

function raft(line)
	line_Out(line)
	retract()
	if Layer == raft_start+1 then
		fout:write("G1 F" .. T_SPEED .. " Z" .. FIRST_L_HEIGHT .. "\r\n")
	end
	travel(R_Min_X,R_Min_Y)
	un_Retract()
	draw_R_Skirt()
	draw_Raft()
	retract()
	if Layer ~= 1 then
		go_To_Last()
		un_Retract()
	end
end

function insert_Block(line, tool, section)
	fout:write(";\r\n; Change tool for " .. section .. "\r\n")
	retract()
	go_To_PPL()
	cool()
	select_Tool(tool)
	heat(Get_Temp[section])
	tool_Change()
	un_Retract(T)
	fout:write("; Set flow rate for " .. section .. "\r\n")
	set_Flow()
	last_Tool = tool
	line_Out(line)
end

-- read lines
for line in fin:lines() do
	
	local abs = string.match(line, "M82")
	local rel = string.match(line, "M83")
	if abs then
		ABSOLUTE_E = true
	elseif rel then
		ABSOLUTE_E = false
	end
	
	local cura = string.match(line, "Cura")
	local kiss = string.match(line, "KISSlicer")
	if cura then
		raft_start = 1
		RAFT_THICKNESS = RAFT_THICKNESS+1
		PILLAR_ROOF = PILLAR_ROOF+1
		first_pillar = RAFT_THICKNESS
	elseif kiss then
		raft_start = 1
		first_pillar = RAFT_THICKNESS
	end
	
	-- Record X position
	local X = string.match(line, "X%d+%.%d+")
	if X then
		last_X = string.match(X, "%d+%.%d+")
	end
	
	-- Record Y position
	local Y = string.match(line, "Y%d+%.%d+")
	if Y then
		last_Y = string.match(Y, "%d+%.%d+")
	end
	
	-- Record Z position
	local Z = string.match(line, "Z%d+%.%d+")
	if Z then
		current_Z = string.match(Z, "%d+%.%d+")
	end
	
	local layer = string.match(line, ";LAYER:") or string.match(line, "; BEGIN_LAYER")
	if layer then
		Layer = Layer + 1
	end
	
	-- Record E value for ABSOLUTE_E
	if  ABSOLUTE_E then
		local E = string.match(line, "E%d+%.%d+")
		if E then
			current_E = string.match(E, "%d+%.%d+")
		end
	end
	
	local g92_E0 = string.match(line, "G92 E0")
	if g92_E0 then
		current_E = 0
	end
	
	local inter = line:match( "; 'Support Interface',") -- Find start of support interface
	local sup = line:match( "; 'Support (may Stack)',") or line:match(";TYPE:SUPPORT") -- Find start of support
	local perim = line:match( "; 'Perimeter',") or line:match(";TYPE:WALL\--OUTER") -- Find start of perimeter
	local loop = line:match( "; 'Loop',") or line:match(";TYPE:WALL\--INNER") -- Find start of loops
	local solid = line:match( "; 'Solid',") -- Find start of solid infill
	local sparse = line:match( "; 'Stacked Sparse Infill',") or line:match(";TYPE:FILL") -- Find start of sparse infill

	-- Force prime pillar on layer without tool change.
        if Layer ~= last_Layer and force_Tower and PRIME_PILLAR and Layer > raft_start then
                force_Pillar(line)
	
	-- Set new tool for support interface (Kisslicer)
	elseif inter and last_Tool ~= INTERFACE_TOOL then
		insert_Block(line,INTERFACE_TOOL,"interface")

	-- Set tool for support (Kisslicer)
	elseif sup and last_Tool ~= SUPPORT_TOOL then
		insert_Block(line,SUPPORT_TOOL,"support")

	-- Set tool for perimeter (Kisslicer)
	elseif perim and last_Tool ~= PERIMETER_TOOL then
		insert_Block(line,PERIMETER_TOOL,"perimeter")

	-- Set tool for loops (Kisslicer)
	elseif loop and last_Tool ~= LOOP_TOOL then
		insert_Block(line,LOOP_TOOL,"loop")

	-- Set tool for solid infill (Kisslicer)
	elseif solid and last_Tool ~= SOLID_TOOL then
		insert_Block(line,SOLID_TOOL,"solid")

	-- Set tool for sparse infill (Kisslicer)
	elseif sparse and last_Tool ~= SPARSE_TOOL then
		insert_Block(line,SPARSE_TOOL,"infill")
	
	else
	        fout:write(line .. "\n" )
	end
	
	if Layer ~= last_Layer and force_Tower == false then
		force_Tower = true
	end
	
	if Layer ~= last_Layer and last_Raft == true then
		last_Raft = false
	end
	
	last_Layer = Layer
end

-- done
fin:close()
fout:close()
print "done"
