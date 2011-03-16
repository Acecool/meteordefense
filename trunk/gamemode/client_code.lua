if !CLIENT then return end

language.Add("func_door", "Main Door")
language.Add("func_door_rotating", "Spawn Door")
language.Add("worldspawn", "Something")
language.Add("entityflame", "Fire!")
language.Add("item_healthvial", "Health Vial")
language.Add("Battery_ammo", "Prop Heal Ammo")

DrawBoxes = {}
credits = 500
ShowInfo = false
infoIsPlayer = false
inRound = false

playerInfo = {}
playerInfo.name = ""
playerInfo.credits = 0
playerInfo.streak = 0
playerInfo.pos = Vector(0,0,0)

propInfo = {}
propInfo.owner = ""
propInfo.worth = 0
propInfo.age = 0
propInfo.pos = Vector(0,0,0)


usermessage.Hook("roundStatus", function( msgData) 
									local newStatus = msgData:ReadBool()
									if !(newStatus == nil) then
										inRound = newStatus
									end
									
								end)
								
function UpdateCredits( msgData )
	
	local newCredits = msgData:ReadLong()
	if !(newCredits == nil) then
		credits = newCredits
	end

end
usermessage.Hook("UpdateCredits", UpdateCredits)

function fanShowHelp( msgData )

	fanWelcome()

end
usermessage.Hook("ShowHelp", fanShowHelp)

function CreditHud()
	draw.WordBox( 15, 0, 0, "   Credits: " .. AddComma(credits) .. "   ", "ScoreboardText", Color(0,0,0,128), Color(255,255,0,227) )
end
hook.Add("HUDPaint", "fanCreditHud", CreditHud)

function setBoxColor( strBoxID, clr)

	if table.HasValue(DrawBoxes, strID) then
		DrawBoxes[strID][3] = clr
	end

end

function getBoxColor( strBoxID )

	if table.HasValue(DrawBoxes, strID) then
		return DrawBoxes[strID][3]
	end

end


function FadeBoxes( alphaStart, alphaEnd, fadeTime )
	
	--print("Fade Out Boxes")
	local alphaStep = (alphaEnd - alphaStart) / fadeTime
	--if alphaStart > alphaEnd then alphaStep = -alphaStep end
	--print("Alpha Step: " .. tostring(alphaStep))
	local curAlpha = alphaStart
	
	for k,v in pairs(DrawBoxes) do
		--print("Fading Box " .. tostring(k))
		curAlpha = alphaStart
		--print("Starting Alpha: " .. tostring(alphaStart))
		for i = 1, fadeTime do
			
			timer.Simple(i, function() 
								curColor = v[3]
								v[3] = Color(curColor.r, curColor.g, curColor.b, curAlpha)
							end )
							
			curAlpha = curAlpha + alphaStep
			--print("New Alpha : " .. tostring(curAlpha))
			
		end
	end
	
	
end

function FadeBox( msgData )
	
	local strID = msgData:ReadString()
	local alphaStart = msgData:ReadLong()
	local alphaEnd = msgData:ReadLong()
	local fadeTime = msgData:ReadLong()
	
	
	local alphaStep = (alphaStart - alphaEnd) / fadeTime
	local curAlpha = alphaStart
	
	for i = 1, fadeTime do
	
		timer.Simple(i, function() 
							curColor = getBoxColor(strID)
							setBoxColor(Color(curColor.r, curColor.g, curColor.b, curAlpha))
						end )
						
		curAlpha = curAlpha + alphaStep
		
	end
	
	
end
usermessage.Hook("FadeBox", FadeBox)

-- Draws A Box!
function AddDrawBox( msgData )

	local strID = msgData:ReadString()
	local Min = msgData:ReadVector()
	local Max = msgData:ReadVector()
	local clr = msgData:ReadString()
	
	--print("Color: " .. clr )
	clr = StringToColor(clr)
	--print("Color: " .. tostring(clr))

	if !table.HasValue(DrawBoxes, strID) then
		table.Add(DrawBoxes, strID)
		DrawBoxes[strID] = { Min, Max, clr }
	else
		DrawBoxes[strID] = { Min, Max, clr }
	end
	
	--print("BoxID: " .. strID)
	--PrintTable(DrawBoxes[strID])
	
end
usermessage.Hook("AddDrawBox", AddDrawBox)

function RemoveDrawBox( msgData )

	local strID = msgData:ReadString()
	
	if DrawBoxes[strID] == nil then return end

	--print("Box Found Removing " .. strID .. " From Draw Table.")		
	DrawBoxes[strID] = nil
			
end
usermessage.Hook("RemoveDrawBox", RemoveDrawBox)

function RenderBoxes( )	
	
	if inRound then return end
	if DrawBoxes == nil then return end
	if DrawBoxes == {} then return end
	if table.Count(DrawBoxes) < 1 then return end
	
	local matBeam = Material( "cable/new_cable_lit")
		
	render.SetMaterial( matBeam )
	
	for k, v in pairs(DrawBoxes) do 
		
		Min = v[1]
		Max = v[2]
		boxColor = v[3]
		
		-- Top of the box
		render.DrawBeam( Vector(Max.x, Max.y, Max.z), Vector(Max.x, Max.y, Min.z), 5, 0, 0, boxColor)
		render.DrawBeam( Vector(Max.x, Max.y, Min.z), Vector(Min.x, Max.y, Min.z), 5, 0, 0, boxColor)
		render.DrawBeam( Vector(Min.x, Max.y, Min.z), Vector(Min.x, Max.y, Max.z), 5, 0, 0, boxColor)
		render.DrawBeam( Vector(Min.x, Max.y, Max.z), Vector(Max.x, Max.y, Max.z), 5, 0, 0, boxColor)
		
		--Bottom of the box
		render.DrawBeam( Vector(Max.x, Min.y, Max.z), Vector(Max.x, Min.y, Min.z), 5, 0, 0, boxColor)
		render.DrawBeam( Vector(Max.x, Min.y, Min.z), Vector(Min.x, Min.y, Min.z), 5, 0, 0, boxColor)
		render.DrawBeam( Vector(Min.x, Min.y, Min.z), Vector(Min.x, Min.y, Max.z), 5, 0, 0, boxColor)
		render.DrawBeam( Vector(Min.x, Min.y, Max.z), Vector(Max.x, Min.y, Max.z), 5, 0, 0, boxColor)
		
		-- Uprights of the box
		render.DrawBeam( Vector(Max.x, Max.y, Max.z), Vector(Max.x, Min.y, Max.z), 5, 0, 0, boxColor)
		render.DrawBeam( Vector(Max.x, Max.y, Min.z), Vector(Max.x, Min.y, Min.z), 5, 0, 0, boxColor)
		render.DrawBeam( Vector(Min.x, Max.y, Min.z), Vector(Min.x, Min.y, Min.z), 5, 0, 0, boxColor)
		render.DrawBeam( Vector(Min.x, Max.y, Max.z), Vector(Min.x, Min.y, Max.z), 5, 0, 0, boxColor)
	end
	
end
hook.Add("PreDrawOpaqueRenderables", "fanRenderBoxes", RenderBoxes)


function fanSpawnMenuEnabled()
	return false
end
hook.Add("SpawnMenuEnabled", "fanSpawnMenuEnabled", fanSpawnMenuEnabled)

function fanSpawnMenuOpen()
	return false
end
hook.Add("SpawnMenuOpen", "fanSpawnMenuOpen", fanSpawnMenuOpen)

-- Quick Ref : LookInfo for player( showInfo, isPlayer, name,  credits, streak, pos)
-- Quick Ref : LookInfo for props ( showInfo, isPlayer, owner, worth,   age,    pos)

function LookInfo( msgData )
	
	local showInfo = msgData:ReadBool()
	ShowInfo = showInfo
	if !showInfo then return end
	local isPlayer = msgData:ReadBool()

	if isPlayer then
		showIsPlayer = true
		playerInfo.name = msgData:ReadString()
		playerInfo.credits = msgData:ReadLong()
		playerInfo.streak = msgData:ReadLong()
		playerInfo.pos = msgData:ReadVector()
		playerInfo.Num = msgData:ReadLong()
		playerInfo.Str = msgData:ReadString()
		playerInfo.Bool = msgData:ReadBool()
		playerInfo.Vec = msgData:ReadVector()
		--PrintTable(playerInfo)
	else
	    showIsPlayer = false
		propInfo.owner = msgData:ReadString()
		propInfo.worth = msgData:ReadLong()
		propInfo.age = msgData:ReadLong()
		propInfo.pos = msgData:ReadVector()
		propInfo.Num = msgData:ReadLong()
		propInfo.Str = msgData:ReadString()
		propInfo.Bool = msgData:ReadBool()
		propInfo.Vec = msgData:ReadVector()
		--PrintTable(propInfo)
	end
	
end
usermessage.Hook("LookInfo", LookInfo)

function toolContextFromFile( strName, cp )

    local file = file.Read( "settings/controls/"..strName..".txt", true )
    if (!file) then return end
    local Tab = KeyValuesToTablePreserveOrder( file )
    if (!Tab) then return end

    for k, data in pairs( Tab ) do
        if ( type( data.Value ) == "table" ) then
            local kv = table.CollapseKeyValue( data.Value )
            local ctrl = cp:AddControl( data.Key, kv )
            if ( ctrl && kv.description ) then
                ctrl:SetTooltip( kv.description );
            end
        end
        
    end

end

function drawInfo()
	
	if !ShowInfo then return end
	if (inRound and !showIsPlayer) and
	   (inRound and propInfo.Num <= 0) then
			return
	end

	
	local drawPos = Vector(0,0,0)
	local drawText = {}
	
	if showIsPlayer then
		if LocalPlayer():GetPos():Distance(playerInfo.pos) > 256 then return end
		drawPos = playerInfo.pos:ToScreen()
		table.insert(drawText, {tostring("Name: " .. playerInfo.name) , 0,0})
		table.insert(drawText, {tostring("Credits: " .. AddComma(playerInfo.credits)) , 0,0})
		table.insert(drawText, {tostring("Survival Streak: " .. tostring(playerInfo.streak)), 0,0})
	else
		if propInfo.worth < 0 then return end
		if LocalPlayer():GetPos():Distance(propInfo.pos) > 256 then return end
		drawPos = propInfo.pos:ToScreen()
		table.insert(drawText, {tostring("Owner: " .. propInfo.owner), 0,0})
		table.insert(drawText, {tostring("Worth: " .. AddComma(propInfo.worth)), 0,0})
		table.insert(drawText, {tostring("Age: " .. propInfo.age), 0,0})
		if propInfo.Num > 0 then
			table.insert(drawText, {"Energy: " .. tostring(propInfo.Num), 0,0})
		end
		if !(propInfo.Str == "") then
			table.insert(drawText, {propInfo.Str, 0,0})
		end
		
	end
	
	surface.SetFont("TargetIDSmall")
	surface.SetDrawColor(255,196,0,128)
	
	local boxWidth = 0
	local boxHeight = 0
	for _, text in pairs(drawText) do
		text[2], text[3] = surface.GetTextSize(text[1])
		if text[2] > boxWidth then boxWidth = text[2] end
		boxHeight = boxHeight + text[3]
	end
	
	boxWidth = boxWidth + 20
	boxHeight = boxHeight + 20
	
	boxX = drawPos.x - (boxWidth / 2) - 10
	boxY = drawPos.y - (boxHeight / 2) - 10
	surface.DrawRect(boxX, boxY, boxWidth + 10, boxHeight + 10)
	surface.SetTextColor( 128,0,0,255)
	runHeight = 0
	for _, text in pairs(drawText) do
		surface.SetTextPos(boxX + 10, boxY + 5 + runHeight)
		surface.DrawText(text[1])
		runHeight = runHeight + text[3]
	end
	
end
hook.Add("HUDPaint", "drawInfo", drawInfo)

function GM:HUDDrawTargetID()
     return false
end

function fanPlayerBindPress( ply, bind, pressed )
      //To block more commands, you could add another line similar to the one below, just replace the command
      --if string.find( bind, "impulse 100" ) then return true end
	  --print("Bind: \t" .. bind .. " was called and Pressed is " .. tostring(pressed))
	  
end
hook.Add("PlayerBindPress", "fanPlayerBindPress", fanPlayerBindPress)