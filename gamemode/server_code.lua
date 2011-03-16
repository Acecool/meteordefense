if !SERVER then return end

SetPostRoundTime( 1 )
SetPreRoundTime(330)
PROP_LIMIT = 35

-- Global Tables
svDrawBoxes = {}	
SpawnedEnts = {}
theWorld = ents.GetAll()[1]
targets = {}
meteorSpawns = {}
spawnDoors = {}
plySpawns = {}

-- Table Init
function fanInitTables()

	--Up the PhysSpeed
	local PhysSpeed = {}
	PhysSpeed.MaxVelocity = 12000
	physenv.SetPerformanceSettings(PhysSpeed)
	
	
	--Not a table but needs done
	theWorld = ents.GetAll()[1]
	
	-- Add map ents to tables
	for k, v in pairs(ents.GetAll()) do
		if v:GetName() == "meteor_spawn" then	
			table.insert(meteorSpawns,v)
			--print("Found Meteor Spawn -- " .. tostring(v))
		end
		if v:GetClass() == "info_player_start" then	
			table.insert(plySpawns,v)
			--print("Found Player Spawn -- " .. tostring(v))
		end
		if v:GetName() == "spawn_door" or
		   v:GetClass() == "func_door_rotating" then	
			table.insert(spawnDoors,v)
			v.owner = v
			--print("Found Spawn Door-- " .. tostring(v))
		end
	end

end

-- Sweeps the map of props not in a proper area.
function fanSweepMap()

	for k,v in pairs(SpawnedEnts) do
		if ValidEntity(v) then
			if !ValidEntity(v.CurrentArea) then
				SafeRemoveEntityDelayed(v,0)
				table.remove(SpawnedEnts, k)
			else
				if !(v.CurrentArea.Owner == v.owner) and
					!(v.CurrentArea.Owner == theWorld) then
						SafeRemoveEntityDelayed(v,0)
						table.remove(SpawnedEnts, k)
				end
			end		
		else
			table.remove(SpawnedEnts, k)
		end
	end
	
end
timer.Create("fanSweepMap",  20, 0, fanSweepMap)

-- Funcitons
-------------

--Checks to see if the player is in a valid area to do things
function IsValidArea( ply )
	
	if ply.CurrentArea == nil then return false end
	if ply.CurrentArea.Owner == nil then return false end
	if ply.CurrentArea.Owner == ply then return true end
	if ply.CurrentArea.Owner:IsWorld() then return true end
	
	return false	
	
end

-- Updates A Property's box -- Probably not needed.
function UpdatePropertyBox( Min, Max, name, clr )
	if Min == nil then return end
	if Max == nil then return end
	AddPropertyBox( Min, Max, name, clr )
end

-- Sends the information to the clients to render the property boxes
function AddPropertyBox( Min, Max, name, clr)

	if Min == nil then return end
	if Max == nil then return end
	
	local boxName = name or tostring("TheBox" .. tostring(math.random(-12456, 123456)))
	
	for k, v in pairs(player.GetHumans()) do
		umsg.Start("AddDrawBox", v)
			umsg.String(boxName)
			umsg.Vector( Min )
			umsg.Vector( Max )
			umsg.String( ColorToString( clr ) )
		umsg.End()
	end
	
	if !(svDrawBoxes[boxName] == nil) then
		svDrawBoxes[boxName] = {Min, Max, clr}
	else
		table.Add(svDrawBoxes, boxName)
		svDrawBoxes[boxName] = {Min, Max, clr}
	end

end

-- Opens and Closes the spawn doors
function SpawnDoors( open )

	for k,v in pairs(spawnDoors) do
		if open then 
			v:Fire("open", "", 0) 
		else
			v:Fire("close", "", 0) 
		end
	end
				

end

-- Spawns X meteor over X seconds
function startShower( totalMeteors, duration )

	local meteorsPerCall = totalMeteors / duration
	local actNum = 0
	
	if meteorsPerCall < 1 then
		actNum = 1
	else
		actNum = meteorsPerCall
	end
	
	local curCount = 0
	local totCount = 0
	
	for n = 1 , duration do
		totCount = totCount + meteorsPerCall
		if (curCount / n) < meteorsPerCall then
			timer.Simple(n, spawnMeteors,  actNum)
			if totCount - curCount > 1 then
				timer.Simple(n, spawnMeteors,  (curCount - totCount))
				curCount = totCount
			end
			curCount = curCount + 1
		end
	end
end

-- Spawn a number of meteors at the same time
function spawnMeteors( num )

	for i = 1, num do
		spawnMeteor()
	end
	
end

-- Spawns a meteor
function gatherTargets()
	-- FindTargets
	targets = player.GetAll()
	table.Add(targets, ents.FindByClass("prop_*"))
	table.Add(targets, ents.FindByClass("laser_*"))
end

function getTarget()

	local targetsCount = table.Count(targets)
	if targetsCount < 1 then
		--print("No Targets Found!!")
		return
	end
	
	local rndTargetIndex = math.random(1,targetsCount)
	
	if targets[rndTargetIndex]:IsValid() then 
		return targets[rndTargetIndex]
	else
		return getTarget()
	end 
	

end

function spawnMeteor()

	--Grab Meteor Spawns
	local startsCount = table.Count(meteorSpawns)
	if startsCount < 1 then
		--print("No Meteor Spawns!!")
		return 
	end
	local rndSpawnIndex = math.random(1,startsCount)
	
	local targetsCount = table.Count(targets)
	if targetsCount < 1 then
		--print("No Targets Found!!")
		return
	end
		
	local rndTargetIndex = math.random(1,targetsCount)
	
	local targPos = getTarget():GetPos() 
	local targPos2 = 0
	local linDist = math.Dist(targPos.x, targPos.y,  meteorSpawns[rndSpawnIndex]:GetPos().x, meteorSpawns[rndSpawnIndex]:GetPos().y)
	local linDist2 = 99999
	--print("2D Distance to target(first try): " .. tostring(linDist))
	if linDist > 4200 then
		targPos2 = getTarget():GetPos()
		linDist2 = math.Dist(targPos2.x, targPos2.y,  meteorSpawns[rndSpawnIndex]:GetPos().x, meteorSpawns[rndSpawnIndex]:GetPos().y)
		--print("2D Distance to target(second try): " .. tostring(linDist2))
	end
	if linDist < linDist2 then
		targPos = targPos + Vector( math.random(-150, 150), math.random(-150,150), math.random(-150,150))
	else
		targPos = targPos2 + Vector( math.random(-150, 150), math.random(-150,150), math.random(-150,150))
	end
	
	local newMeteor = ents.Create("meteor")
	newMeteor:SetPos(meteorSpawns[rndSpawnIndex]:GetPos())
	newMeteor:Spawn()
	newMeteor:Shoot( targPos, newMeteor:GetPos() , math.random(6500,9500) )

end

function UpdateCredits( ply )
	umsg.Start("UpdateCredits", ply)
		umsg.Long(ply.Credits)
	umsg.End()
end
				
function QuickEffect( ent , effect_name )
		local effect = EffectData()
		--setup and do effect
		effect:SetStart(ent:GetPos())
		effect:SetRadius(ent:BoundingRadius())
		effect:SetOrigin(ent:GetPos())
		effect:SetScale(ent:GetMaxHealth())
		effect:SetMagnitude(ent:GetMaxHealth())
		
		util.Effect(effect_name, effect)
end

function InitPlayer( ply )

		if ply == nil then return end
		if ply == NULL then return end
		if !ply:IsValid() then return end
		if !ply:IsPlayer() then return end
		if ply.loaded then return end
			
		local ShouldLoad = false		
		
		-- Own thy self
		ply.owner = ply
		ply.InSpawn = false
		ply.streak = 0
		
		if !(ply:GetPData("Level") == nil) then
			ShouldLoad = true
		end
	
		if ShouldLoad then
			ply.Credits = tonumber(ply:GetPData("Credits"))
		else
			ply.Credits = 25000
		end
		if ply.initProps == nil then
			ply.props = {}
			ply.initProps = true
		end
		ply.RoundCompleted = 0
		if ply.Credits < 25000 then
			ply.Credits = 25000
		end
		ply.loaded = true
		
end

function GenerateLevelTable()
	
	if !(LevelTable == nil) then return end
	LevelTable = {}
	lvlXP = 0
	lvlHealth = 0
	maxHealth = 1
	lvlRunHealth = 3
	entry = {}
		  entry.nextXP = 2207
		  entry.healthAdd = 3
		  entry.healthTotal = 3
		  
	table.insert(LevelTable, entry)
	
	for lvl = 2, 199 do
		lvlHealth = math.Round( (maxHealth + 2) * (1.3 * lvl) )
		lvlRunHealth = lvlRunHealth + lvlHealth
		lvlXP = math.Round( LevelTable[(lvl - 1)].nextXP + (1024 * ( 1.075 ^ (lvl))))
		entry = {}
		entry.nextXP = lvlXP
		entry.healthAdd = lvlHealth
		entry.healthTotal = lvlRunHealth
		table.insert(LevelTable, entry)
	end
	
end

function ShowStats( ply )
	--print("--== Show Stats ==--")

	if !(ply.Level == nil) and 
		   (ply.Stats == nil) then
			ply:ChatPrint("=-=-=-= Stats =-=-=-=")
			ply:ChatPrint(tostring(ply:Nick()) .. " is at level " .. ply.Level .. " and has " .. math.Round(ply.XP) .. " XP.")
			ply:ChatPrint("The next level is at " .. ply.NextLevel .. " XP.")
			ply:ChatPrint(tostring(ply:Nick()) .. " needs " .. math.Round(ply.NextLevel - ply.XP) .. " XP to Level up!")
			ply:ChatPrint(tostring(ply:Nick()) .. " has " .. tostring(math.Round(ply.Credits)) .. " credits.")
		end 
	ply:ChatPrint("=-=-=-= | | | =-=-=-=")
	--end 
end
concommand.Add("show_stats", ShowStats)

function levelDiff( ent1, ent2 )

	lvlDiff = math.abs(ent1.Level - ent2.Level)
	
	if ent1.Level > ent2.Level then
		highEnt = ent1
	elseif ent2.Level > ent1.Level then
		highEnt = ent2
	elseif ent2.Level == ent1.Level then
		if math.random(1,10) > 5 then 
			highEnt = ent1 
		else 
			highEnt = ent2 
		end
	end
	
	return lvlDiff, highEnt

end

function SavePlayerData( ply )

		--print("Saving Player Data for " .. tostring(ply))
		ply:SetPData( "Credits", tonumber(ply.Credits))
		--print("Saving Complete")
		
end
concommand.Add("save_my_data", SavePlayerData)

function ResetPlayerData( ply )

		--print("Reseting Player Data for " .. tostring(ply))
		ply:Kill()
		ply:SetPData( "Credits", 25000)
		ply.loaded = nil
		InitPlayer( ply )
		ply:ChatPrint("Reset Complete")
		
		
end
concommand.Add("reset_my_data", ResetPlayerData)

-- Function to claim an unowned prop
function claimProp( ply, cmd, args)

	iCleanTable(ply.props)
	if table.Count(ply.props) >= PROP_LIMIT then 
		ply:ChatPrint("You've Hit the Prop Limit! Please Sell something before claiming more.")
		ply:ChatPrint("You have " .. tostring(table.Count(ply.props)) .. " and the limit is " .. tostring(PROP_LIMIT))
		return
	end
	
	local etEnt = ply:GetEyeTrace().Entity
	
	if etEnt == nil then return end
	
	if etEnt:IsWorld() and (etEnt.owner == nil) then
		etEnt.owner = etEnt
	elseif etEnt:IsWorld() then 
		return 
	end
	
	if etEnt:IsNPC() then return end
	
	if etEnt.owner == nil then
		etEnt.owner = ply
		ply:ChatPrint("No one owns this, You are now the owner.")
		table.insert(ply.props, etEnt)
		return
	else
		if etEnt.owner == ply then
			ply:ChatPrint("You already own this prop!")
			return
		else
			ply:ChatPrint("Someone else Already Owns This!")
			return
		end
	end
		
	
end
concommand.Add("claim_prop", claimProp)

-- Function to claim an unowned prop
function unClaimProp( ply, cmd, args)

	iCleanTable(ply.props)
		
	local etEnt = ply:GetEyeTrace().Entity
	
	if etEnt == nil then return end
	
	if etEnt:IsWorld() and (etEnt.owner == nil) then
		etEnt.owner = etEnt
	elseif etEnt:IsWorld() then 
		return 
	end
	
	if etEnt.owner == nil then
		ply:ChatPrint("No one owns this, you can not un-own it.")
		return
	else
		if etEnt.owner == ply then
			for k, v in pairs(ply.props) do
				if v == etEnt then
					etEnt.owner = nil
					table.remove(ply.props, k)
					ply:ChatPrint("Prop un-owned!")
					return
				end
			end
			ply:ChatPrint("Prop not found!")
		else
			ply:ChatPrint("Someone else owns this!")
			return
		end
	end
		
	
end
concommand.Add("unclaim_prop", unClaimProp)

function buyStuff( ply, cmd, args )

	if args[1] == nil then 
		ply:ChatPrint("Buy, What?")
		return 
	end
	
	if !(tonumber(args[1]) == nil) then
		local prop = tonumber(args[1])
		if !IsValidArea(ply) then
			ply:ChatPrint("Sorry You are not allowed to build in this area.")
			return
		end
		iCleanTable(ply.props)
		if table.Count(ply.props) >= PROP_LIMIT then 
			ply:ChatPrint("You've Hit the Prop Limit! Please Sell something to build more.")
			ply:ChatPrint("You have " .. tostring(table.Count(ply.props)) .. " and the limit is " .. tostring(PROP_LIMIT))
			return
		end
		if ply.Credits >= props[prop][3] then
			ply.Credits = ply.Credits - props[prop][3]
			local spawnSpot = ply:GetEyeTrace().HitPos
			local newThing = ents.Create("prop_physics")
			newThing:SetModel(props[prop][2])
			newThing:SetAngles(Vector(0,90,0))
			local thingCenter = newThing:LocalToWorld(newThing:OBBCenter())
			local spawnOffset = (newThing:OBBMaxs().z - newThing:OBBMins().z) / 2
			newThing:SetAngles(newThing:AlignAngles(newThing:GetForward():Angle(), (ply:GetForward() * -1):Angle()))
			newThing:SetPos(spawnSpot + thingCenter + Vector(0,0,spawnOffset)) -- + (newThing:OBBMaxs() - newThing:OBBMins()))
			newThing.owner = ply
			newThing.value = props[prop][3]
			newThing:Spawn()
			--local groundTrace = util.QuickTrace(newThing:GetPos(), spawnSpot, newThing)

			table.insert(SpawnedEnts, newThing)
			table.insert(ply.props, newThing)
			ply:ChatPrint("Thank You!")
		else
			ply:ChatPrint("You do not have enough Credits for that!")
		end
	
	end
	
	if args[1] == "laser_turret" then
		if !IsValidArea(ply) then
			ply:ChatPrint("Sorry You are not allowed to build in this area.")
			return
		end
		iCleanTable(ply.props)
		if table.Count(ply.props) >= PROP_LIMIT then 
			ply:ChatPrint("You've Hit the Prop Limit! Please Sell something to build more.")
			ply:ChatPrint("You have " .. tostring(table.Count(ply.props)) .. " and the limit is " .. tostring(PROP_LIMIT))
			return
		end
		local ltNum = tonumber(args[2])
		if ltNum == nil then return end
		
		if ply.Credits >= entities[ltNum][6] then
			ply.Credits = ply.Credits - entities[ltNum][6]
			local spawnSpot = ply:GetEyeTrace().HitPos
			local newThing = ents.Create("laser_turret")
			newThing:SetModel(entities[ltNum][2])
			newThing:SetAngles(Vector(0,90,0))
			local thingCenter = newThing:LocalToWorld(newThing:OBBCenter())
			local spawnOffset = (newThing:OBBMaxs().z - newThing:OBBMins().z) / 2
			newThing:SetAngles(newThing:AlignAngles(newThing:GetForward():Angle(), (ply:GetForward() * -1):Angle()))
			newThing:SetPos(spawnSpot + thingCenter + Vector(0,0,spawnOffset)) -- + (newThing:OBBMaxs() - newThing:OBBMins()))
			newThing.owner = ply
			newThing.value = entities[ltNum][6]
			newThing:Spawn()
			newThing.radius = entities[ltNum][4]
			newThing.maxenergy = entities[ltNum][5]
			newThing:Activate()
			newThing:GetPhysicsObject():Wake()
			
			table.insert(SpawnedEnts, newThing)
			table.insert(ply.props, newThing)
			ply:ChatPrint("Thank You!")
		else
			ply:ChatPrint("You do not have enough Credits for that!")
		end
	
	end
	
	
	if args[1] == "property" then
		if ply.CurrentArea == nil then
			ply:ChatPrint("You Are Not In a Buyable Area!")
		else
			if ply.CurrentArea.Owner == nil then
				if ply.Credits >= ply.CurrentArea.price then
					ply.Credits = ply.Credits - ply.CurrentArea.price
					ply.CurrentArea.Owner = ply
					ply:ChatPrint(tostring(ply.CurrentArea.price) .. " have been deducted from your account.")
					ply:ChatPrint("Thank you for your purchase!")
				else
					ply:ChatPrint("You Can Not Afford This Property!")
				end
			elseif ply.CurrentArea.Owner:IsWorld() then
				ply:ChatPrint("This Is A Public Area and Can Not Be Purchased!")
			else
				if ply.CurrentArea.Owner == ply then
					ply:ChatPrint("You already own this property!")
				else
					ply:ChatPrint("This Property Is Owned By " .. ply.CurrentArea.Owner:Nick() .. ".")
				end
			end
		end
	end
	if args[1] == "ha" then
		if ply.Credits >= 300 then
			ply.Credits = ply.Credits - 300
			ply:GiveAmmo(200, "Battery")
			ply:ChatPrint("Thank you! You now have 200 more heal ammo.")
		else
			ply:ChatPrint("Sorry You don't have enough.")
		end
	
	end
	
	UpdateCredits(ply)
	
end
concommand.Add("fan_buy", buyStuff)


function sellStuff( ply, cmd, args )

	if args[1] == nil then 
		ply:ChatPrint("Buy, What?")
		return 
	end
	if args[1] == "prop" then
		local targEnt = ply:GetEyeTrace().Entity
		
		if targEnt == nil then
			ply:ChatPrint("There's Nothing There!")
		else
			if targEnt:IsNPC() then
				ply:ChatPrint("No... That's just wrong.")
				return
			end
			if !(targEnt.owner == nil) then
				if !(targEnt.owner == ply) then
					ply:ChatPrint("That's Not Yours to Sell!")
				else
					if targEnt.value == nil then targEnt.value = -1 end
					salePrice = targEnt.value / 2
					salePrice = salePrice * (targEnt:Health() / targEnt:GetMaxHealth())
					salePrice = math.Round(salePrice)
					ply:ChatPrint("Prop Sold For " .. tostring(salePrice) .. " credits.")
					ply.Credits = ply.Credits + salePrice
					targEnt:Remove()
				end				
			end
		end
	end
	
	if args[1] == "allprops" then
		
		iCleanTable(ply.props)
		for k,v in pairs(ply.props) do
			if !(v.value == nil) then
				salePrice = v.value / 2
				salePrice = salePrice * (v:Health() / v:GetMaxHealth())
				salePrice = math.Round(salePrice)
				ply:ChatPrint("Prop Sold For " .. tostring(salePrice) .. " credits.")
				ply.Credits = ply.Credits + salePrice
				SafeRemoveEntityDelayed(v,0)
			end
		end
	end
	
	if args[1] == "property" then
		if ply.CurrentArea == nil then
			ply:ChatPrint("Sell... What? Property?")
		else
			if ply.CurrentArea.Owner == nil then return end
			if ply.CurrentArea.Owner == ply then
				ply.Credits = ply.Credits + (ply.CurrentArea.price / 2)
				ply.CurrentArea.Owner = nil
				ply:ChatPrint(tostring(math.Round(ply.CurrentArea.price / 2)) .. " has been credited to your account.")
			elseif ply.CurrentArea.Owner:IsWorld() then
				ply:ChatPrint("This Is A Public Area and Can Not Be Sold!")
			else
				ply:ChatPrint("You Can Not Sell, You Don't Own This Property!")
			end
		end
	end
	UpdateCredits(ply)
end
concommand.Add("fan_sell", sellStuff)

function creditStuff( ply, cmd, args )

	if args[1] == nil then 
		ply:ChatPrint("Do, What?")
		return 
	end
	if args[1] == "trans" then
		if tonumber(args[2]) == nil then 
			ply:ChatPrint("Must Specify transfer amount.")
			return
		end
		local targEnt = ply:GetEyeTrace().Entity
		if targEnt == nil then
			ply:ChatPrint("No one to transfer to.")
		else
			if !targEnt:IsPlayer() then
				ply:ChatPrint("You may only transfer to other players!")
			else
				local newCred = math.abs(tonumber(args[2]))
				targEnt.Credits = targEnt.Credits + newCred
				ply.Credits = ply.Credits - newCred
				UpdateCredits(targEnt)
			end
		end
	end
	UpdateCredits(ply)
end
concommand.Add("fan_cred", creditStuff)

function QuickKick( ply, cmd, args )

	--print(tostring(ply))
	--print(tostring(cmd))
	--PrintTable(args)
	if !ply:IsAdmin() then 
		ply:ChatPrint("You must be and Admin to use this command.")
		ply:TakeDamage(1, theWorld, theWorld)
		return 
	end
	
	if args[1] == nil then return end
	if args[1] == "list" then
		for k, v in pairs(player.GetAll()) do
			ply:ChatPrint("# " .. tostring(k) .. " -- Nick: " .. v:Nick() .. " -- Player: " .. tostring(v))
		end
	end
	if args[1] == "kick" then
		plyList = player.GetAll()
		if args[3] == nil then args[3] = "..." end
		plyList[tonumber(args[2])]:Kick(args[3])
	end
			
end
concommand.Add("qkick", QuickKick)

-- Creates or appends a log file with time stamps
function fanLog( fName, str )

	str = "[" .. tostring(os.date()) .. "] --\t" .. str .. "\n"
	if file.Exists(fName) then	
		filex.Append(fName, str)
	else
		file.Write(fName, str)
	end
		
end






















-- Hooks
----------

-- Stop normal sandbox spawning
function fanPlayerSpawnObject( ply )
	return false
end
hook.Add("PlayerSpawnObject", "fanPlayerSpawnObject", fanPlayerSpawnObject)


function fanPlayerSpawn( ply )

	-- See if they have the area boxes
	
	if ply.GotBoxes == nil then
		for k, v in pairs(svDrawBoxes) do
			umsg.Start("AddDrawBox", ply)
				umsg.String( k )
				umsg.Vector( v[1] )
				umsg.Vector( v[2] )
				umsg.String( ColorToString( v[3] ) )
			umsg.End()
		end
		ply.GotBoxes = true
	end
	-- Initialize Player Data or Load it
	InitPlayer( ply )
	
	-- If they didn't see the welcome screen then display it
	if ply.SeenWelcome == nil then -- Might be usless in this hook
		umsg.Start("ShowWelcome", ply) 
		umsg.End()
	end
	ply.SeenWelcome = true	
	
	UpdateCredits(ply)
end
hook.Add("PlayerSpawn", "fanPlayerSpawn", fanPlayerSpawn)

-- Things to do when the game loads
function fanInitPostEntity()
	
	--Initialize Tables
	fanInitTables()
	
	--starts = ents.FindByName("meteor_spawn")
	theWorld = ents.GetAll()[1]
end
hook.Add("InitPostEntity", "fanInitPostEntity", fanInitPostEntity)

-- Post Round Hook
-- Starts Autohealing
function showerPostRound( plys, time )
	if !DidPostOnce() then
		RunConsoleCommand("pdmg_autoheal", "1")
		RunConsoleCommand("pdmg_autoheal_interval", "0.5")
			for k,v in pairs(plys) do
				v:ChatPrint("Remember, This is only a break!")
			end
	end
end
hook.Add("PostRound", "fanPostRound", showerPostRound)

-- Pre Round Hook, 
-- Handles the build phase and all things leading to the meteor attack
function regularShowers( plys , time )
	print("Pre Round Time: " .. tostring(time))
	if !DidPreOnce() then
		if table.Count(plys) > 0 then
			for k,v in pairs(plys) do
				v:StripWeapons()
				v:Give("weapon_physgun")
				v:Give("weapon_propheal")
				v:Give("gmod_tool")
				--print("Giving Tools")
			end
		end
	end
	
	if math.Round(time/20) == time / 20 then
		if table.Count(plys) > 0 then
			for k, v in pairs(plys) do
				v:ChatPrint("Time to build, I don't think that's the last of 'em!")
			end
		end
	end
	
	if time <= GetPreRoundTime() / 4 then
		RunConsoleCommand("pdmg_autoheal", "0")
	end
	
	
	if time == 30 then 
		if table.Count(plys) > 0 then
			for k,v in pairs(plys) do
				v:ChatPrint("Next strike estimated time :" ..tostring(math.random(25,35)) .. " seconds.")
			end
		end
	end
	
	if time == 10 then 
		if table.Count(plys) > 0 then
			for k,v in pairs(plys) do
				v:ChatPrint("Incoming transmition... Stand By....")
			end
		end
	end
	
	if time == 5 then 
		gatherTargets()
		local rndMeteors = math.random(60,140)
		local rndDuration = math.random(30,70)
		
		if table.Count(plys) > 0 then
			--PrintTable(plys)
			for k,v in pairs(plys) do
				v:ChatPrint("Head for Cover!!")
				v:ChatPrint(tostring(rndMeteors) .. " meteors for the next " .. tostring(rndDuration) .. " seconds!")
			end
		end
		--print(tostring(rndMeteors) .. " meteors for the next " .. tostring(rndDuration) .. " seconds!")
		SetRoundTime(rndDuration + time)
		timer.Simple( time + 2, SpawnDoors, false )
		timer.Simple( time, startShower, rndMeteors, rndDuration)
	end
	
end
hook.Add("PreRound", "fanPreRound", regularShowers)

-- Round Start Hook
-- Strips players before the attack
function stripPlayers( plys )

		if table.Count(plys) > 0 then
			for k,v in pairs(plys) do
				v:StripWeapons()
				v.Died = false
				if v.InSpawn then
					v.RoundCompleted = RoundPercentComplete()
				end
				
				umsg.Start("roundStatus", v)
					umsg.Bool( true )
				umsg.End()
			end
		end

end
hook.Add("RoundStart", "fanRoundStart", stripPlayers)

-- Round End Hook
-- Takes care of scoring
function allClear( plys )

	-- Let Clients know it's over
	umsg.Start("roundStatus", v)
		umsg.Bool( false )
	umsg.End()
	-- Do Score!
	if table.Count(plys) > 0 then
		--PrintTable(plys)
		for k,v in pairs(plys) do
			v:ChatPrint("All Clear!")
			local earnings = 0
			for i, p in pairs(v.props) do
				if !p:IsValid() then
					table.remove(v.props, i)
				else
					if p.value == nil then p.value = 10 end
					if p.Created == nil then p.Created = CurTime() - 1 end
					
					ageEarn = CurTime() - p.Created
					if ageEarn > (p.value / 2 ) then ageEarn = p.value / 2 end 
					earnings = earnings + (ageEarn * (p:Health() / p:GetMaxHealth()))
				end
			end
			
			earnings = math.Round(earnings)
			
			v:ChatPrint("You earned " .. tostring(earnings) .. " credits for props that survived!")
			if !v.Died then
				earnings = earnings + v:Health()
				v.streak = v.streak + 1 
				v:ChatPrint("You earned a " .. tostring(v:Health()) .. " credit bonus for not dying!")
			end
			if v.Died or v.InSpawn then
				local OldEarnings = earnings
				earnings = earnings * v.RoundCompleted
				v:ChatPrint("You lost " .. tostring(math.Round(OldEarnings - earnings)) .. " for not completing the round.")
			end
			earnings = math.Round(earnings)
			v:ChatPrint("Total Round Earnings: " .. tostring(earnings))
			v.Credits = v.Credits + earnings
			UpdateCredits(v)
		end
	end
	SpawnDoors( true )
	--print("All Clear")

end
hook.Add("RoundEnd", "fanRoundEnd", allClear)

-- Fixes Mass on props
function fixMass( ent )
	
	--print( "Fixing Mass on " .. tostring(ent))
	
	if !ent:IsValid() then return end
	if ent:GetPhysicsObject() == nil then return end
	if ent == NULL then return end 
	if IsClass(ent, "vehicle") then return end
	if IsClass(ent, "meteor") then return end
	
	ePhys = ent:GetPhysicsObject()
	
	if ePhys:IsValid() and !(ePhys:GetMass() == nil) and !(ePhys:GetVolume() == nil) then
		--print("Valid Physics, setting mass to " .. tostring(  ePhys:GetVolume() / 200 ))
		ePhys:SetMass( tonumber(ePhys:GetVolume()) / 200 )
	end
	
end
function fixMassHook( ent )
	timer.Simple(1, fixMass, ent)
	
end
hook.Add( "OnEntityCreated", "fanFixMass", fixMassHook )

-- Player Loadout
-- Give weapons based on what were doing at the moment.
function fanLoadout( ply )

	ply:StripWeapons()
	
	if DidPreOnce() then
		ply:Give("weapon_physgun")
		ply:Give("gmod_tool")
		ply:Give("weapon_propheal")
	end
	
	if RoundTimeRemaining() > -1 then
		
	end
	
	-- Set Max health back
	--[[if !(ply.MaxHealth == nil) then
		if ply.MaxHealth > 0 then
			ply:SetMaxHealth(ply.MaxHealth)
			ply:SetHealth(ply.MaxHealth)
		end
	end--]]

	UpdateCredits(ply)
	
	return true
end
hook.Add( "PlayerLoadout", "fanLoadout", fanLoadout)

-- Player Disconnected 
-- When a player disconnects randomly remove their props some not all
-- Then sell any property they own and save their data
function fanPlayerDisconnected( ply )
	
	-- Remove Props on disconnect
	for k, v in pairs(ents.GetAll()) do
		if v.owner == nil then
		else
			if v.owner == ply then 
				if math.random(1,100) < 50 then
					v:Remove()	
--					ply.Credits = ply.Credits + (v.value * (v:Health() / v:GetMaxHealth()))
				else
					v.owner = nil
				end
			end
		end
		if IsClass(v, "property") then
			if v.Owner == ply then
				v.Owner = nil
				ply.Credits = ply.Credits + (v.price / 2)
			end
		end
	end
	
	SavePlayerData(ply)
	
end
hook.Add("PlayerDisconnected", "fanPlayerDisconnected", fanPlayerDisconnected)

-- Going to add Chat logging and soem chat commands here.
function fanPlayerSay( ply, str, teamonly)

	local logNameEnd = os.date("%m%d%y") .. ".txt"
	
	if string.lower(string.Left(str, 4)) == "!bug" then
		fanLog("buglog" .. logNameEnd, "BUG:\t" .. string.Right(str, string.len(str) - 4) .. "\t" .. "Reported By:\t" .. ply:Nick())
	elseif string.lower(string.Left(str, 4)) == "!add" then
		fanLog("addlog" .. logNameEnd, "ADD:\t" .. string.Right(str, string.len(str) - 4) .. "\t" .. "Suggested By:\t" .. ply:Nick())
	elseif string.lower(string.Left(str, 5)) == "!note" then
		fanLog("notes" .. logNameEnd, "Note from " .. ply:Nick() .. string.Right(str, string.len(str) - 4) .. "\t" .. "Reported By:\t" .. ply:Nick())
	elseif string.lower(string.Left(str, 6)) == "!stuck" then
		local spawns = {}
		for k, v in pairs(ents.GetAll()) do
			if v:GetClass() == "info_player_start" then	
				table.insert(spawns,v)
			end
		end
		ply:SetPos(spawns[math.random(1,table.Count(spawns))]:GetPos())
	else
		fanLog("chatlog" .. logNameEnd, ply:Nick() .. "(" .. tostring(ply:SteamID()) .. ") :\t" .. str)
	end
	
	
end
hook.Add("PlayerSay", "fanPlayerSay", fanPlayerSay)

-- PlayerDeath Hook
-- Handles medical expenses
function fanPlayerDeath( ply, weapon, killer )
		
		if RoundTimeRemaining() > -1 then
			ply.Died = true
			ply.streak = 0
			ply.RoundCompleted = RoundPercentComplete()
		end
		ply:ChatPrint(" 100 Credits have been taken to cover medical expenses.")
		ply.Credits = ply.Credits - 100
		ply.timeOfDeath = CurTime()
end
hook.Add( "PlayerDeath", "fanPlayerDeath", fanPlayerDeath)

function fanPlayerDeathThink( ply )

	if ply.timeOfDeath == nil then ply.timeOfDeath = CurTime() end
	
	if CurTime() > ply.timeOfDeath + 4.20 then
		ply:Spawn()
	end

end
hook.Add("PlayerDeathThink", "fanPlayerDeathThink",fanPlayerDeathThink)

-- No teams, every see it all.
function SeeChat()
	return true
end
hook.Add("PlayerCanSeePlayersChat", "fanSeeChat", SeeChat)

-- Minge Protection
-- Can't pickup anything unless you own it.
function fanPhysgunPickup( ply, ent)
	
	if ent:IsPlayer() then return false end
	if ent.owner == nil then return false end

	if !(ent.owner == ply) then
		return false
	else
		if ent:GetModel() == "models/laser_turret.mdl" then
			return true
		else
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
			return true
		end
	end

end
hook.Add( "PhysgunPickup", "fanPhysgunPickup", fanPhysgunPickup)

function fanPhysgunDrop( ply, ent)

	ent:SetCollisionGroup(COLLISION_GROUP_NONE)

end
hook.Add( "PhysgunDrop", "fanPhysgunDrop", fanPhysgunDrop)

function fanCanTool( ply, trace, toolmode )

		if table.HasValue(toolAll, toolmode) then return true end
		if trace.Entity:IsWorld() then return false end
		if !(table.HasValue(toolAllowed, toolmode)) then return false end
		
		if trace.Entity.owner == nil then return false end
		if trace.Entity.owner == ply then 
			local canTool = false
			for k,v in pairs(tools) do
				if v[2] == toolmode then
					canTool = true
				end
			end
			return canTool
		else
			return false
		end
	
end
hook.Add( "CanTool", "fanCanTool", fanCanTool )

function fanShowHelp( ply )
	umsg.Start("ShowHelp", ply)
	umsg.End()
	return true
end
hook.Add( "ShowHelp", "fanShowHelp", fanShowHelp)

nextLook = CurTime()
function lookThink()
	
	if CurTime() > nextLook then
	
		for _, p in pairs(player.GetHumans()) do
			--print("Look Trace for Player : " .. tostring(p))
			local traceEnt = p:GetEyeTrace().Entity
			--print("Trace Ent : " .. tostring(traceEnt))
			if traceEnt:IsValid() and
			   !traceEnt:IsWorld() then
			   --print("Is Valid and Not world")
-- Quick Ref : LookInfo for player( showInfo, isPlayer, name,  credits, streak, pos)
-- Quick Ref : LookInfo for props ( showInfo, isPlayer, owner, worth,   age,    pos)
				if traceEnt:IsPlayer() then
					--print("Is Player")
					umsg.Start("LookInfo", p)
						umsg.Bool(true) -- showInfo
						umsg.Bool(true) -- isPlayer
						umsg.String(traceEnt:Nick())
						umsg.Long(traceEnt.Credits)
						umsg.Long(traceEnt.streak)
						umsg.Vector(traceEnt:GetPos())
					umsg.End()
				else
					--print("Is not Player")
					if traceEnt.value == nil then traceEnt.value = 2 end
					if traceEnt.Created == nil then traceEnt.Created = CurTime() - 1 end
					local propAge = CurTime() - traceEnt.Created
					local propWorth = traceEnt.value / 2
					if propAge < propWorth then propWorth = propAge end
					propWorth = propWorth * (traceEnt:Health() / traceEnt:GetMaxHealth())
					umsg.Start("LookInfo", p)
						umsg.Bool(true) -- showInfo
						umsg.Bool(false) -- isPlayer
						if traceEnt.owner == nil then
							umsg.String("none")
						else
							if traceEnt.owner:IsPlayer() then
								umsg.String(traceEnt.owner:Nick())
							else
								umsg.String(tostring(traceEnt.owner))
							end
						end
						umsg.Long(propWorth)
						umsg.Long(propAge)
						umsg.Vector(traceEnt:GetPos())
						-- num str bool vec
						if !(traceEnt.energy == nil) then
							umsg.Long(traceEnt.energy)
							if traceEnt.energy < traceEnt.maxenergy then
								umsg.String("Charging...")
							end
						end
					umsg.End()
				end
			else
				umsg.Start("LookInfo", p)
					umsg.Bool(false) -- showInfo
				umsg.End()
			end
		
		end
		
		nextLook = CurTime() + 0.25
	end
	
end
hook.Add( "Think", "fanLookThink", lookThink)

local function serverShutdown()
    for _, ply in pairs(player.GetHumans()) do 
		fanPlayerDisconnected( ply )
	end
end
hook.Add( "ShutDown", "serverShutdown", serverShutdown )

function NetworkIDValidated( name, steamid )
	print( name .. " has vaild steam id: " .. steamid)
end
hook.Add( "NetworkIDValidated", "fanNetworkIDValidated", NetworkIDValidated)


function FirstSpawn( ply )
	print( ply:Nick() .. " is sending client info." )
end
hook.Add( "PlayerInitialSpawn", "playerInitialSpawn", FirstSpawn )


function userAuthed( ply, stid, unid )
	print("Player "..ply:Nick().." ("..stid.."|"..unid..") is authenticated")
end
hook.Add( "PlayerAuthed", "fanUserAuthed", userAuthed)

function PlayerConnect( name, address ) 
    print( "Player " .. name .. " has joined from ip " .. address )
end
hook.Add( "PlayerConnect", "fanPlayerConnect", PlayerConnect)

function fanPlayerNoClip( ply )
	if !ply:IsSuperAdmin() then
		ply:ChatPrint("No Clip is disabled, if you need to get up try doors")
		return false
	else
		ply:ChatPrint("Up, Up, and Away!!")
		return true
	end
	return false  -- Should never get this far
end
hook.Add("PlayerNoClip", "fanPlayerNoClip", fanPlayerNoClip)

function SaveAllPlayers( pl, cmd, args) 

	if !pl:IsSuperAdmin() then 
		pl:ChatPrint("You must be a Super Admin to do this!")
		return
	end
	
	local sellProps = args[1] or false
	local msg = args[2]
	
	for _, ply in pairs(player.GetHumans()) do
		if sellProps then
			iCleanTable(ply.props)
			for _, prop in pairs(ply.props) do
				if !(prop.value == nil) then
					salePrice = prop.value / 2
					salePrice = salePrice * (prop:Health() / prop:GetMaxHealth())
					salePrice = math.Round(salePrice)
					ply.Credits = ply.Credits + salePrice
					SafeRemoveEntityDelayed(prop,0)
				end
			end
		end
		
		SavePlayerData(ply)
		
		if !(msg == nil) then
			ply:ChatPrint(msg)
		end
	end

	pl:ChatPrint("Saving Complete!")
	
end
concommand.Add("save_all_players", SaveAllPlayers)


function giveCredits( ply, cmd, args)
	if !ply:IsSuperAdmin() then
		ply:ChatPrint("Must be Super Admin to use that command")
		return
	else
		if tonumber(args[1]) == nil then 
			ply:ChatPrint("You must specify the number of credits to give.")
			return
		end
		ply.Credits = ply.Credits + tonumber(args[1])
		UpdateCredits(ply)
		ply:ChatPrint("Added " .. args[1] .. " credits to your account.")
	end
end
concommand.Add("give_credits", giveCredits)

GenerateLevelTable()

--Random Attacks
function randomAttack()
	
	gatherTargets()
	
	startShower(math.random(1,5), math.random(10,15))

	timer.Simple(math.random(240,480), randomAttack)
	
end
timer.Simple(math.random(240,480), randomAttack)

timer.Create("AutoSavePlayers", 300, 0, function()
	
	local oldCredits = 0
	
	for _, ply in pairs(player.GetHumans()) do
		
		iCleanTable(ply.props)
		oldCredits = ply.Credits
		for _, prop in pairs(ply.props) do
			if !(prop.value == nil) then
				salePrice = prop.value / 2
				salePrice = salePrice * (prop:Health() / prop:GetMaxHealth())
				salePrice = math.Round(salePrice)
				ply.Credits = ply.Credits + salePrice
			end
		end
		SavePlayerData(ply)
		ply.Credits = oldCredits
		ply:ChatPrint("Autosave Complete.")
	end
end)

print("Done Loading Server!!")
