-- PDMG - Prop Damage by Fantym
-- List of conVars:
-- 
-- "pdmg_enabled" = "1"
--      - Enable(1)/Diable(0) Prop_Damage Addon
--
-- "pdmg_death_effect" = "cball_explode"
--      - Effect Played when Props are Destroyed, '' Disables
-- 
-- "pdmg_ragdoll_health" = "5000"
--      - Ragdoll Health Fix (They Die Too Easy), 0 Disables
-- 	 
-- "pdmg_override_health" = "0" ( def. "0" )
--      - Override Health Calculations Completely and Just use x Health for all new Props, 0 Disables
-- 	 
-- "pdmg_use_volume" = "1"
--      - Enable(1)/Disable(0) Using Volume in Prop_Damage Calculations
--  
-- "pdmg_use_mass" = "1"
--      - Enable(1)/Disable(0) Using Mass in Prop_Damage Calculations
--  
-- "pdmg_autoheal" = "0"
--      - Disable(0) All other values heal props every x seconds where x = pdmg_autoheal_interval
--  
-- "pdmg_autoheal_interval" = "1"
--      - Interval for prop autohealing 0 is constant
--  
-- "pdmg_autoheal_players" = "0"
--      - Disable(0) All other values heal players every x seconds where x = pdmg_autoheal_players_interval
--  
-- "pdmg_autoheal_players_interval" = "1"
--      - Interval for players autohealing 0 is constant
--  
-- "pdmg_autoheal_npcs" = "0"
--      - Disable(0) All other values heal npcs every x seconds where x = pdmg_autoheal_npcs_interval
--  
-- "pdmg_autoheal_npcs_interval" = "1"
--      - Interval for npc autohealing 0 is constant
--  
-- "pdmg_breakconstraints" = "0"
--      - Enable(1)/Disable(0) Break Constraints on low health
--  
-- "pdmg_breakconstraints_percent" = "0.1"
--      - Percent at which constraints break in decimal.
--  
-- "pdmg_unfreeze" = "0"
--      - Enable(1)/Disable(0) Unfreeze prop on low health
--  
-- "pdmg_unfreeze_percent" = "0.2"
--      - Percent at which to unfreeze
--  
-- "pdmg_color_damage" = "0"
--      - Color's props red based on damage.
--  
-- "pdmg_health_multiplier" = "0"
--      - Multiplies all props health by this amount 0 - 1000
-- "pdmg_props_only" = "0"
--      - If set to 1 this disables health for all non prop_physics
-- "pdmg_ex_wire" = 0
--      - If set to 1 this disables health for wire classes
-- "pdmg_ex_stargate" = 1
--	    - If set to 1 this disables health for stargate classes
-- "pdmg_ex_gmod" = 0 
--      - If set to 1 this disables health for gmod classes
-- "pdmg_ex_phx_exp" = 1
--      - If set to 1 this disables health for phx explosives
-- "pdmg_ex_hl2_exp" = 1
--      - If set to 1 this disables health for hl2 explosives

if (SERVER) then
	
	--Include the exclusions tables
	include("pdmg_exclusions.lua")
	
	-- Function for adding our tag to the servers
	local function AddServerTag(  tag )
		
		local sTags = GetConVarString("sv_tags")	
		
		if sTags == nil then
			RunConsoleCommand("sv_tags", tag)
		elseif  !(string.find(sTags, tag)) then
			RunConsoleCommand("sv_tags", sTags .. "," .. tag)
		end
		
	end
	
	local function tblEqual( tbl1, tbl2 )
	
		local idxTbl1 = table.Count(tbl1)
		local idxTbl2 = table.Count(tbl2)
		
		if !(idxTbl1 == idxTbl2) then return false end
		
		for i = 1, idxTbl1 do
		
			if !( tbl1[i] == tbl2[i]) then return false end
		
		end
		
		return true
	
	end
	
	print("PDMG - Starting Server Side...")
	
	print("PDMG - Checking ConVars...")
	
	-- Delay tag setting or it will fail
	timer.Simple(10, AddServerTag, "pdmg")

	-- Create Con Var to handle Options
	if !ConVarExists("pdmg_enabled") then
		CreateConVar("pdmg_enabled", '1', FCVAR_ARCHIVE, "Enable(1)/Disable(0) Prop_Damage Addon")
	end

	if !ConVarExists("pdmg_use_mass") then
		CreateConVar("pdmg_use_mass", '1',  FCVAR_ARCHIVE, "Enable(1)/Disable(0) Using Mass in Prop_Damage Calculations")
	end
	
	if !ConVarExists("pdmg_use_volume") then
		CreateConVar("pdmg_use_volume", '1',  FCVAR_ARCHIVE, "Enable(1)/Disable(0) Using Volume in Prop_Damage Calculations")
	end
	
	if !ConVarExists("pdmg_override_health") then
		CreateConVar("pdmg_override_health", '0',  FCVAR_ARCHIVE, "Override Health Calculations Completely and Just use x Health for all new Props, 0 Disables")
	end
	
	if !ConVarExists("pdmg_ragdoll_health") then
		CreateConVar("pdmg_ragdoll_health", '5000',  FCVAR_ARCHIVE, "Ragdoll Health Fix (They Die Too Easy), 0 Disables")
	end
	
	if !ConVarExists("pdmg_death_effect") then
		CreateConVar("pdmg_death_effect", 'cball_explode',  FCVAR_ARCHIVE, "Effect Played when Props are Destroyed, '' Disables")
	end
	
	if !ConVarExists("pdmg_autoheal") then
		CreateConVar("pdmg_autoheal", '0',  FCVAR_ARCHIVE, "Amount to Autoheal props every pdmg_autoheal_interval seconds. 0 Disables")
	end
	
	if !ConVarExists("pdmg_autoheal_interval") then
		CreateConVar("pdmg_autoheal_interval", '0',  FCVAR_ARCHIVE, "Autoheal Interval, 0 is constant")
	end
	
	if !ConVarExists("pdmg_autoheal_players") then
		CreateConVar("pdmg_autoheal_players", '0',  FCVAR_ARCHIVE, "Amount to Autoheal players every pdmg_autoheal_players_interval seconds. 0 Disables")
	end
	
	if !ConVarExists("pdmg_autoheal_players_interval") then
		CreateConVar("pdmg_autoheal_players_interval", '0',  FCVAR_ARCHIVE, "Autoheal players interval, 0 is constant")
	end
	
	if !ConVarExists("pdmg_autoheal_npcs") then
		CreateConVar("pdmg_autoheal_npcs", '0',  FCVAR_ARCHIVE, "Amount to Autoheal NPCs every pdmg_autoheal_players_interval seconds. 0 Disables")
	end
	
	if !ConVarExists("pdmg_autoheal_npcs_interval") then
		CreateConVar("pdmg_autoheal_npcs_interval", '0',  FCVAR_ARCHIVE, "Autoheal NPCs interval, 0 is constant")
	end
	
	if !ConVarExists("pdmg_showhealth") then
		CreateConVar("pdmg_showhealth", '1',  FCVAR_ARCHIVE, "0 Disables, 1 All the Time, 2 Only with SWEP")
	end
	
	if !ConVarExists("pdmg_breakconstraints") then
		CreateConVar("pdmg_breakconstraints", '1',  FCVAR_ARCHIVE, "Break Constraints when Health is Low, 1 Activates, 0 Disables")
	end
	
	if !ConVarExists("pdmg_breakconstraints_percent") then
		CreateConVar("pdmg_breakconstraints_percent", '0.10',  FCVAR_ARCHIVE, "Break Constraints when heath is x percent, in decimal form.")
	end
	
	if !ConVarExists("pdmg_unfreeze") then
		CreateConVar("pdmg_unfreeze", '1',  FCVAR_ARCHIVE, "Unfreeze Prop when Health is Low, 1 Activates, 0 Disables")
	end
	
	if !ConVarExists("pdmg_unfreeze_percent") then
		CreateConVar("pdmg_unfreeze_percent", '0.20',  FCVAR_ARCHIVE, "Unfreeze Prop when heath is x percent, in decimal form.")
	end
	
	if !ConVarExists("pdmg_color_damage") then
		CreateConVar("pdmg_color_damage", '0',  FCVAR_ARCHIVE, "Enables or Disable Coloring the Prop when it's damaged.")
	end

	if !ConVarExists("pdmg_health_multiplier") then
		CreateConVar("pdmg_health_multiplier", '0',  FCVAR_ARCHIVE, "Enables or Disable Coloring the Prop when it's damaged.")
	end

	if !ConVarExists("pdmg_props_only") then
		CreateConVar("pdmg_props_only", '0',  FCVAR_ARCHIVE, "Enables damage for prop_physics only")
	end
	if !ConVarExists("pdmg_ex_wire") then
		CreateConVar("pdmg_ex_wire", '0',  FCVAR_ARCHIVE, "Disables Damage for wire addon stuff")
	end
	if !ConVarExists("pdmg_ex_stargate") then
		CreateConVar("pdmg_ex_stargate", '1',  FCVAR_ARCHIVE, "Disables Damage for Stargate addon stuff")
	end
	if !ConVarExists("pdmg_ex_gmod") then
		CreateConVar("pdmg_ex_gmod", '0',  FCVAR_ARCHIVE, "Disables Damage for GMOD classes")
	end
	if !ConVarExists("pdmg_ex_phx_exp") then
		CreateConVar("pdmg_ex_phx_exp", '1',  FCVAR_ARCHIVE, "Disables Damage for PHX Explosives")
	end
	if !ConVarExists("pdmg_ex_hl2_exp") then
		CreateConVar("pdmg_ex_hl2_exp", '1',  FCVAR_ARCHIVE, "Disables Damage for HL2 explosives")
	end
	
	--Load the ConVars into variables here so they are global without polling the value each time.
	 pdmgLoaded = false
	 cvEnabled = GetConVarNumber("pdmg_enabled")
	 cvAutoHeal = GetConVarNumber("pdmg_autoheal")
	 cvAutoHealInterval = GetConVarNumber("pdmg_autoheal_interval")
	 cvAutoHealPlayers = GetConVarNumber("pdmg_autoheal_players")
	 cvAutoHealPlayersInterval = GetConVarNumber("pdmg_autoheal_players_interval")
	 cvAutoHealNPCs = GetConVarNumber("pdmg_autoheal_npcs")
	 cvAutoHealNPCsInterval = GetConVarNumber("pdmg_autoheal_npcs_interval")
	 cvHealthOverride = GetConVarNumber("pdmg_override_health") 
	 cvUseMass = GetConVarNumber("pdmg_use_mass")
	 cvUseVolume = GetConVarNumber("pdmg_use_volume")
	 cvHealthRagdoll = GetConVarNumber("pdmg_ragdoll_health")
	 cvConstraintRemove = GetConVarNumber("pdmg_breakconstraints")
	 cvConstraintPercent = GetConVarNumber("pdmg_breakconstraints_percent")
	 cvUnfreeze = GetConVarNumber("pdmg_unfreeze")
	 cvUnfreezePercent = GetConVarNumber("pdmg_unfreeze_percent")
	 cvColorDamage = GetConVarNumber("pdmg_color_damage")
	 cvPropsOnly = GetConVarNumber("pdmg_props_only")
	 cvHealthMultiplier = GetConVarNumber("pdmg_health_multiplier")
	 cvExWire = GetConVarNumber("pdmg_ex_wire")
	 cvExStargate = GetConVarNumber("pdmg_ex_stargate")
	 cvExGmod = GetConVarNumber("pdmg_ex_gmod")
	 cvExPhxExp = GetConVarNumber("pdmg_ex_phx_exp")
	 cvExHl2Exp = GetConVarNumber("pdmg_ex_hl2_exp")
	
	--Timer Counter for Entity Spawning
	local timerTicker = 0
	
	--Initialize Ent Table
	local pdmgEnts = {}
	
	--Function To Check Partial Class names
	--ex. IsClass( ent, "npc_" ) would return all ents with classes starting with npc_
	-- if you want all the antlions IsClass(ent, "npc_a")
	local function IsClass( ent, class )
		if (string.find(ent:GetClass(), class) == nil) then return false else return true end
	end
	
	--Function for Health Creation
	local function DoHealth( v )
		
		if (GetConVarNumber("pdmg_enabled") == 0) then return end
		
		--If we've done this then exit
		if !(v.HealthMade == nil) then return end
		
		-- Don't do health on map elements
		if IsClass( v, "func_") then return end
		
		-- Prop_physics only option
		if cvPropsOnly == 1 then
			if !(IsClass(v, "prop_physics")) then return end
		end
		
		-- If it doesn't have a model we can't kill it
		if v:GetModel() == nil then return end
		
		--Class and Model Exclusion Code
		PrintTable(pdmgExclusions)
		if table.HasValue(pdmgExclusions, tostring(v:GetClass())) then return end
		if table.HasValue(pdmgExclusions, tostring(v:GetModel())) then return end
		
		local vPhys = v:GetPhysicsObject()
		
		-- Get Color of ent for possible reset later
		v.orgColor = {}
		v.orgColor.r, v.orgColor.g, v.orgColor.b, v.orgColor.a = v:GetColor()
		
		
		-- Somethings are breakable to start with.
		if ((v:Health() > 0) and ( cvHealthOverride == 0)) or
		   (v:IsNPC()) then
			
			if cvHealthMultiplier > 0 and !v:IsPlayer() then 
				v:SetMaxHealth(v:Health() * cvHealthMultiplier)
			else
				v:SetMaxHealth(v:Health())
			end
			v:SetHealth(v:GetMaxHealth())
			
			v.HealthMade = 1

			--Add Entity to Table for healing / other stuff
			table.insert(pdmgEnts, v)
		
		elseif (v:IsValid()) and 
		       (vPhys:IsValid()) and 
		      !(v:IsWorld()) and 
		      !(v:IsPlayer()) and
		      !(v.HealthMade == 1) and
		       ((v:Health() < 1) or (cvHealthOverride > 0)) then

			if !(vPhys == nil) and 
			   !(vPhys:GetMass() == nil) and
			   !(vPhys:GetVolume() == nil) then
				
				--Multiplyer based off physical materials
				--     See Function SetHealthMult
				local Mult = SetHealthMult(vPhys)
				local Mass = 0
				local Vol = 0
					
				--Use mass in health calc? if no set mass = 1
				if cvUseMass == 1 then
					Mass = vPhys:GetMass()
				else
					Mass = 1
				end
					
				--Use volume in health calc? if no set volume = 1
				if cvUseVolume == 1 then
					Vol = vPhys:GetVolume()
				else
					Vol = 1
				end
					
				if Mass == 1 and Vol == 1 then 
					-- If we aren't using mass and we're  not using volume, then we must be random
					-- Set the "Mass" to a random number roughly based around the object's mass
					Mass = (math.random() * (math.random()+1.269 * vPhys:GetMass())) / (math.random() * 4)
				end 
					
					
				if cvHealthOverride == 0 then 
					--Standard Health calculation if we are not overriding the health.
					-- With Health Multiplier code
					if cvHealthMultiplier > 0 then 
						v:SetHealth(((Mass + (Vol * 0.002)) * Mult) * cvHealthMultiplier)
					else
						v:SetHealth((Mass + (Vol * 0.002)) * Mult)
					end
				else
					v:SetHealth(cvHealthOverride)
				end 
				
				-- Ragdolls die too easy (Beat them selves up), should we override?
				if (cvHealthRagdoll > 0) then
					if (v:GetClass() == "prop_ragdoll") then v:SetHealth(cvHealthRagdoll) end
				end
					
				--Set the entities max health and the variable that let's us know we've already done all this
				v:SetMaxHealth(v:Health())
				
				v.HealthMade = 1
				
				--Add Entity to Table for healing / other stuff
				table.insert(pdmgEnts, v)
				
			end
		end
	end
	
	print("PDMG - Setting Up Ents...")
	
	-- Get all currently spawned entities
	local allEnts = ents.GetAll()
	
	--See if any qualify for health
	for k, v in pairs(allEnts) do

		DoHealth(v)
			
	end
	
	local retardThink = 1
	local nextThink = CurTime() + retardThink
	
	--Main Think Function
	local function PropDamage( )
		
		if CurTime() <= nextThink then return end
		
		if pdmgLoaded ==  false then return end
		
		-- Check for a change in the enabled convar
		
		if !(cvEnabled == GetConVarNumber("pdmg_enabled")) then
			-- If we are going from disabled to enabled we need to set health on anything we haven't yet.
			if cvEnabled == 0 and GetConVarNumber("pdmg_enabled") == 1 then
				for k, v in pairs(ents.GetAll()) do
					DoHealth( v ) 
				end
			end
			-- Need to fix color on props if we are disabling the damage
			if cvEnabled == 1 and GetConVarNumber("pdmg_enabled") == 0 then
				for k, v in pairs(pdmgEnts) do
					if !(v.orgColor == nil) then
						v:SetColor(v.orgColor.r,v.orgColor.g,v.orgColor.b,v.orgColor.a)
					end
				end
			end
			cvEnabled = GetConVarNumber("pdmg_enabled")
		end
		
		
		
		-- If Not Enabled, then exit
		if (GetConVarNumber("pdmg_enabled") == 0) then return end
		
		cvAutoHeal = GetConVarNumber("pdmg_autoheal")
		cvAutoHealInterval = GetConVarNumber("pdmg_autoheal_interval")
		cvAutoHealPlayers = GetConVarNumber("pdmg_autoheal_players")
		cvAutoHealPlayersInterval = GetConVarNumber("pdmg_autoheal_players_interval")
		cvAutoHealNPCs = GetConVarNumber("pdmg_autoheal_npcs")
		cvAutoHealNPCsInterval = GetConVarNumber("pdmg_autoheal_npcs_interval")
		cvHealthOverride = GetConVarNumber("pdmg_override_health") 
		cvUseMass = GetConVarNumber("pdmg_use_mass")
		cvUseVolume = GetConVarNumber("pdmg_use_volume")
		cvHealthRagdoll = GetConVarNumber("pdmg_ragdoll_health")
		cvConstraintRemove = GetConVarNumber("pdmg_breakconstraints")
		cvConstraintPercent = GetConVarNumber("pdmg_breakconstraints_percent")
		cvUnfreeze = GetConVarNumber("pdmg_unfreeze")
		cvUnfreezePercent = GetConVarNumber("pdmg_unfreeze_percent")
		cvPropsOnly = GetConVarNumber("pdmg_props_only")
		cvHealthMultiplier = GetConVarNumber("pdmg_health_multiplier")
		
		
		-- Check Exclusions
		local updateEx = false
		local updatePo = false
		
		if !(cvPropsOnly == GetConVarNumber("pdmg_props_only")) then updatePo = true end 
		
		if !(cvExWire == GetConVarNumber("pdmg_ex_wire")) then updateEx = true end
		if !(cvExStargate == GetConVarNumber("pdmg_ex_stargate")) then updateEx = true end
		if !(cvExGmod == GetConVarNumber("pdmg_ex_gmod")) then updateEx = true end
		if !(cvExPhxExp == GetConVarNumber("pdmg_ex_phx_exp")) then updateEx = true end
		if !(cvExHl2Exp == GetConVarNumber("pdmg_ex_hl2_exp")) then updateEx = true end
		
		cvExWire = GetConVarNumber("pdmg_ex_wire")
		cvExStargate = GetConVarNumber("pdmg_ex_stargate")
		cvExGmod = GetConVarNumber("pdmg_ex_gmod")
		cvExPhxExp = GetConVarNumber("pdmg_ex_phx_exp")
		cvExHl2Exp = GetConVarNumber("pdmg_ex_hl2_exp")
		
		if updateEx then 
			--print("Rebuilding Exclusion Table") 
			BuildExTable() 
			-- Get all currently spawned entities
		end
		if updateEx or UpdatePo then
			local allEnts = ents.GetAll()
	
			--See if any qualify for health
			for k, v in pairs(allEnts) do
				DoHealth(v)
			end
		end
		
		
		-- Run through Entity table to see if anything needs to be done
		for k, v in pairs(pdmgEnts) do
			
			--Does the entity still exist? no, then remove
			if !(v:IsValid()) then 
			
				table.remove(pdmgEnts, k)
			
			else 
			
				local vClass = v:GetClass()
				local vPhys = v:GetPhysicsObject()
				
				--Auto Heal Code
				if (v.HealthMade == 1) and (v:Health() < v:GetMaxHealth()) then
									
					--AutoHeal Props
					if (cvAutoHeal > 0) and (!(v:IsNPC()) and !(v:IsPlayer())) then
						
						if !(v.LastHeal == nil) and
						   ((CurTime() - v.LastHeal) > cvAutoHealInterval) then
							v:SetHealth(v:Health() + cvAutoHeal)
							v.LastHeal = CurTime()
						elseif v.LastHeal == nil then
							v.LastHeal = CurTime()
						end
						
					end 
					
					--AutoHeal Players
					if (cvAutoHealPlayers > 0) and (v:IsPlayer()) then
						
						if !(v.LastHeal == nil) and
						   ((CurTime() - v.LastHeal) > cvAutoHealPlayersInterval) then
							v:SetHealth(v:Health() + cvAutoHealPlayers)
							v.LastHeal = CurTime()
						elseif v.LastHeal == nil then
							v.LastHeal = CurTime()
						end
						
					end
					
					--AutoHeal NPCs
					if (cvAutoHealNPCs) > 0 and (v:IsNPC()) then
						
						if !(v.LastHeal == nil) and
						   ((CurTime() - v.LastHeal) > cvAutoHealNPCsInterval) then
							v:SetHealth(v:Health() + cvAutoHealNPCs)
							v.LastHeal = CurTime()
						elseif v.LastHeal == nil then
							v.LastHeal = CurTime()
						end
						
					end
				end	

				--Color code
				
				cvColorDamage = GetConVarNumber("pdmg_color_damage")
				
				if !(v:IsNPC() or v:IsPlayer()) and ( cvColorDamage == 1 ) then
					
					local clrPercent = 1 - (v:Health() / v:GetMaxHealth())

					local curColor = {}
					curColor.r, curColor.g, curColor.b, curColor.a = v:GetColor()
					
					if v.LastHealth == nil then v.LastHealth = v:Health() end
					
					if !(v.LastHealth == v:Health()) then
						local newColor = {}
						newColor.r = v.orgColor.r - (v.orgColor.r - curColor.r)
						newColor.g = v.orgColor.g - (v.orgColor.g * clrPercent)
						newColor.b = v.orgColor.b - (v.orgColor.b * clrPercent)
						newColor.a = v.orgColor.a - (v.orgColor.a - curColor.a)
						
						v:SetColor( newColor.r, newColor.g, newColor.b, newColor.a )
						v.LastHealth = v:Health()
					end
				end
				
				if (cvColorDamage == 0) then
				
					v:SetColor( v.orgColor.r, v.orgColor.g, v.orgColor.b, v.orgColor.a)
					
				end
				
				--Health Cap -- No Cheating
				if (v:Health() > v:GetMaxHealth()) then v:SetHealth(v:GetMaxHealth()) end 
		
				-- Constraint Removal Code
				if (cvConstraintRemove) and 
				   ((v:Health() / v:GetMaxHealth()) <= cvConstraintPercent) then
					--print("Removing Constraints")
					if v:Health() > 0 then 
						if v:IsConstrained() then constraint.RemoveAll(v) end
					end 
				end
				
				-- Unfreeze Code
				if (cvUnfreeze) and
				   ((v:Health() / v:GetMaxHealth()) <= cvUnfreezePercent) then
					if vPhys:IsValid() then
						vPhys:EnableMotion(true)
						vPhys:Wake()
					end
				end
				
				--Uncomment the code below to get a running display of prop status'	
				--[[
				if (v.HealthMade == 1) and
				   !(v:IsWorld()) and
				   !(v:IsPlayer()) and
					(vPhys:IsValid()) then 		
					print(tostring(v) .." is " ..(vPhys:GetMaterial()) .." and has " ..(v:Health()) .." out of " ..(v:GetMaxHealth()) .." Health. ")	
				end 
				--]]
			
			end
		end
	end
	hook.Add( "Tick", "PropDamageTick", PropDamage )
	
	-- Checks Entities as they spawn to see if they need Health added.
	function ObjectSpawned( ent )
		
		if (GetConVarNumber("pdmg_enabled") == 0) then return end
		
		--Counter for Unique timer names.
		timerTicker = timerTicker + 1
		
		--Delay health creation, object doesn't fully exist yet.
		timer.Create("timer" .. tostring(timerTicker), 0.05 , 1, function() if (ent:IsValid()) then DoHealth(ent) end end )
		
		-- guess this doesn't go over 9000
		if timerTicker > 9000 then timerTicker = 0 end
		
	end
	hook.Add( "OnEntityCreated", "pdmgObjectSpawned", ObjectSpawned )
	
	--Function to gather and send prop Information
	function PropDamageHud()
		
		if (GetConVarNumber("pdmg_enabled") == 0) then return end
		
		--Grab Convar
		local cvShowHealth = GetConVarNumber("pdmg_showhealth")
		
		-- If shoing health is not enabled don't show health
		if cvShowHealth == 0 then 
			umsg.Start("EntityHook", j)
				umsg.Bool( false )
			umsg.End()
			return 
		end
		
		local ShowHud = false
		-- Get all the people
		local people = player.GetHumans()

		-- Loop and trace
		for i, j in pairs(people) do
			ShowHud = false
			
			--Show Only when using healing swep
			if ValidEntity(j:GetActiveWeapon())then
				--print(tostring(j:GetActiveWeapon()))
				if (j:GetActiveWeapon():GetClass() == "weapon_propheal" and
					cvShowHealth == 2 )  then
					ShowHud = true
				end
			end
			
			--Show when looking at
			if cvShowHealth == 1 then
			   ShowHud = true		
			   -- No Show
			end
			
			
			if !ShowHud then
			   umsg.Start("EntityHook", j)
					umsg.Bool( false )
			   umsg.End()
			end
			
			-- Ok So if we should show it, then get the rest of the info
			if ShowHud then

				--Trace from player
				local eyetrace = j:GetEyeTrace();
				local traceEnt = eyetrace.Entity
				
				--Send The trace result to the Client, and if it was send Health, maxhealth, and OBBCenter
				umsg.Start("EntityHook", j)
					umsg.Bool( traceEnt:IsValid() and !(traceEnt:IsWorld()) and (traceEnt:GetPos():Distance(j:GetPos()) < 1024 ))
			
					if traceEnt:IsValid() and 
					   traceEnt:Health() > 0 and
					   !(traceEnt:IsWorld()) then
			
						umsg.Long( traceEnt:Health() )
						umsg.Long( traceEnt:GetMaxHealth() )
						umsg.Vector( traceEnt:LocalToWorld(traceEnt:OBBCenter()) )
						
					end
				
				umsg.End()
			end		

			
		end
	end
	hook.Add( "Tick", "PropDamageHudTick", PropDamageHud )
	
	--Function To try and offset health based on physics material type
	function SetHealthMult(vPhys)
		
		local MaterialType = vPhys:GetMaterial()
		
		-- Values are made up, but seem to simulate different material strenth and weakness.
		if (MaterialType == "metal") then
			return 3
		elseif (MaterialType == "metalpanel") then
			return 2.25
		elseif (MaterialType == "concrete") then
			return 2
		elseif (MaterialType == "tile") then
			return 1
		elseif (MaterialType == "wood") then
			return 0.75
		elseif (MaterialType == "plastic") then
			return 1.75
		elseif (MaterialType == "plastic_barrel") then
			return 2.5
		elseif (MaterialType == "canister") then
			return 0.1
		else
			return 1
		end 
	
	end
	
	
	
	local function EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
	
		if (GetConVarNumber("pdmg_enabled") == 0) then return end
		
		--if it was the player or the world, don't bother just exit
		if (ent:IsNPC()) or (ent:IsPlayer()) or (ent:IsWorld()) then return end
		
		if ent.HealthMade == 1 then	
			--Apply physics damage
			ent:TakePhysicsDamage(dmginfo) -- React physically when getting shot/blown
			--Get Total Damage
			local TotalDamage = dmginfo:GetDamage()
			
			-- uncomment below to multiply explosion damage
			--if dmginfo:IsExplosionDamage() then TotalDamage = (TotalDamage + (dmginfo:GetDamageForce():Length() * 0.01)) end
			
			--Apply the hurt.
			ent:SetHealth(ent:Health() - TotalDamage) -- Damage Entity Accordingly
			
			-- if it's one of ours then see if we killed it.
			if(ent:Health() <= 0) then
				
				ent.Gibbed = ent.Gibbed or false
				--If it has gib animations, call the break code, if not this doesn't do anything
				if !ent.Gibbed then
					ent:GibBreakClient(ent:GetPos())
					ent.Gibbed = true
				end
				
				-- Is there an effect set for destruction?
				cvDeathEffect = GetConVarString("pdmg_death_effect")
				
				if !(cvDeathEffect == "") then
					local effect = EffectData()
				
					--setup and do effect
					effect:SetStart(ent:GetPos())
					effect:SetRadius(ent:BoundingRadius())
					effect:SetOrigin(ent:GetPos())
					effect:SetScale(ent:GetMaxHealth())
					effect:SetMagnitude(ent:GetMaxHealth())
					util.Effect(cvDeathEffect, effect)
				
				end
				
				--Destroy the ent.
				SafeRemoveEntityDelayed(ent, 0.1)
				
				
			end

		end
		--return false
	end
	hook.Add( "EntityTakeDamage", "PropDamageTakeDamage", EntityTakeDamage )
	
	print("PDMG - Building Exclusions Table...")
	BuildExTable()
			
	print("PDMG - Finished Loading Server!")
	pdmgLoaded = true
end

if CLIENT then
	
	
	print("PDMG - Starting Client Side ...")
	
	local traceEntMaxHealth = 0;
	local traceEntHealth = 0;
	local traceEntPos = Vector( 0, 0, 0) 
	local traceValid = false
	
	print("PDMG - Creating Menu...")
	
	local function OnPopulateToolPanel(panel)

		panel:AddControl("CheckBox", {
			Label = "Enable Prop Damage ?",
			Command = "pdmg_enabled",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("Label", {
			Text = "Prop Destruction Effect (Visual Only)"
		})
		
		local combobox = {}
		combobox.Label = ""
		combobox.MenuButton = 0
		combobox.Options = {}
		combobox.Options["none"] = {pdmg_death_effect = ""}
		combobox.Options["Combine Ball Explosion"] = {pdmg_death_effect = "cball_explode"}
		combobox.Options["Antlion Gib Puff"] = {pdmg_death_effect = "AntlionGib"}
		combobox.Options["AR2Explosion"] = {pdmg_death_effect = "AR2Explosion"}
		combobox.Options["Blood Impact"] = {pdmg_death_effect = "BloodImpact"}
		combobox.Options["Combine Ball Bounce"] = {pdmg_death_effect = "cball_bounce"}
		combobox.Options["Explosion"] = {pdmg_death_effect = "Explosion"}
		combobox.Options["Water Splash"] = {pdmg_death_effect = "gunshotsplash"}
		combobox.Options["Gas Type Explosion"] = {pdmg_death_effect = "HelicopterMegaBomb"}
		combobox.Options["Manhack Sparks"] = {pdmg_death_effect = "ManhackSparks"}
		combobox.Options["Stunstick Impact"] = {pdmg_death_effect = "StunstickImpact"}
		combobox.Options["Thumper Dust"] = {pdmg_death_effect = "ThumperDust"}
		combobox.Options["Water Surface Explosion"] = {pdmg_death_effect = "WaterSurfaceExplosion"}
		combobox.Options["Balloon Pop (Confetti)"] = {pdmg_death_effect = "balloon_pop"}
		combobox.Options["Small Sparks"] = {pdmg_death_effect = "inflator_magic"}
		panel:AddControl("ComboBox", combobox)
			
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("Slider", {
			Label = "Ragdoll Health Override",
			Command = "pdmg_ragdoll_health",
			Type = "Long",
			Min = "0",
			Max = "50000",
		})
		
		panel:AddControl("Label", {
			Text = "Ragdoll health Override. Ragdolls have a low calculated health. Enter a number in the box to override or enter 0 to use calclulated."
		})		
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("Slider", {
			Label = "Prop Health Override",
			Command = "pdmg_override_health",
			Type = "Long",
			Min = "0",
			Max = "50000",
		})
		
		panel:AddControl("Label", {
			Text = "Prop Health Override will set all newly spawned props to specified Health, 0 Disables."
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
			
		panel:AddControl("CheckBox", {
			Label = "Use Volume in Health Calculations?",
			Command = "pdmg_use_volume",
		})
		
		panel:AddControl("CheckBox", {
			Label = "Use Mass in Health Calculations?",
			Command = "pdmg_use_mass",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("Label", {
			Text = "NOTE: If you don't select either mass, volume or both, Prop Health will be a random fraction of the Prop's Mass."
		})
		
		panel:AddControl("Slider", {
			Label = "Prop Auto Heal",
			Command = "pdmg_autoheal",
			Type = "Long",
			Min = "0",
			Max = "10",
		})
		
		panel:AddControl("Label", {
			Text = "Automatically Heal Props by this much based on the set interval below, 0 Disables Auto Heal Props."
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("Slider", {
			Label = "Prop Auto Heal Interval",
			Command = "pdmg_autoheal_interval",
			Type = "Float",
			Min = "0.0",
			Max = "10.0",
		})
		
		panel:AddControl("Label", {
			Text = "Interval at which props are auto healed in seconds. 0 is constant"
		})
		
		panel:AddControl("Label", {
			Text = ""
		})

		panel:AddControl("Slider", {
			Label = "Players Auto Heal",
			Command = "pdmg_autoheal_players",
			Type = "Long",
			Min = "0",
			Max = "10",
		})
		
		panel:AddControl("Label", {
			Text = "Automatically Heal Players by this much based on the set interval below, 0 Disables Auto Heal Players."
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("Slider", {
			Label = "Players Auto Heal Interval",
			Command = "pdmg_autoheal_players_interval",
			Type = "Float",
			Min = "0.0",
			Max = "10.0",
		})
		
		panel:AddControl("Label", {
			Text = "Interval at which players are auto healed in seconds. 0 is constant"
		})
				
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("Slider", {
			Label = "NPC Auto Heal",
			Command = "pdmg_autoheal_npcs",
			Type = "Long",
			Min = "0",
			Max = "10",
		})
		
		panel:AddControl("Label", {
			Text = "Automatically Heal NPCs by this much based on the set interval below, 0 Disables Auto Heal NPCs."
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("Slider", {
			Label = "NPCs Auto Heal Interval",
			Command = "pdmg_autoheal_npcs_interval",
			Type = "Float",
			Min = "0.0",
			Max = "10.0",
		})
		
		panel:AddControl("Label", {
			Text = "Interval at which NPCs are auto healed in seconds. 0 is constant"
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("Label", {
			Text = "When to show Prop Health on Screen:"
		})
		
		combobox = {}
		combobox.Label = ""
		combobox.MenuButton = 0
		combobox.Options = {}
		combobox.Options["Never"] = {pdmg_showhealth = "0"}
		combobox.Options["When Looking at it"] = {pdmg_showhealth = "1"}
		combobox.Options["Only When Using SWEP"] = {pdmg_showhealth = "2"}
		panel:AddControl("ComboBox", combobox)
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("CheckBox", {
			Label = "Break Constraints on Low Health?",
			Command = "pdmg_breakconstraints",
		})
		
		panel:AddControl("Slider", {
			Label = "Constraint Break Percent (in Decimal)",
			Command = "pdmg_breakconstraints_percent",
			Type = "Float",
			Min = "0.0",
			Max = "1.0",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("CheckBox", {
			Label = "Unfreeze Prop on Low Health?",
			Command = "pdmg_unfreeze",
		})
		
		panel:AddControl("Slider", {
			Label = "Unfreeze Percent (in Decimal)",
			Command = "pdmg_unfreeze_percent",
			Type = "Float",
			Min = "0.0",
			Max = "1.0",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("CheckBox", {
			Label = "Color Props Red With Damage?",
			Command = "pdmg_color_damage",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("Slider", {
			Label = "Health Multiplier",
			Command = "pdmg_health_multiplier",
			Type = "Float",
			Min = "0.0",
			Max = "1000.0",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("CheckBox", {
			Label = "Only Make prop_physics breakable.",
			Command = "pdmg_props_only",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("CheckBox", {
			Label = "Disable Damage On Wire Addon Stuff",
			Command = "pdmg_ex_wire",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("CheckBox", {
			Label = "Disable Damage On GMOD Base Stuff",
			Command = "pdmg_ex_gmod",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("CheckBox", {
			Label = "Disable Damage On Stargate Addon Stuff",
			Command = "pdmg_ex_stargate",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
	
		panel:AddControl("CheckBox", {
			Label = "Disable Damage On PHX Explosives",
			Command = "pdmg_ex_phx_exp",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
		panel:AddControl("CheckBox", {
			Label = "Disable Damage on HL2 Explosives",
			Command = "pdmg_ex_hl2_exp",
		})
		
		panel:AddControl("Label", {
			Text = ""
		})
		
	end

	local function OnPopulateToolMenu()
		spawnmenu.AddToolMenuOption("Options", "Player", "PDMGSettings", "PDMG - Prop Damage", "", "", OnPopulateToolPanel, {SwitchConVar = 'pdmg_enabled'})
	end

	hook.Add("PopulateToolMenu", "PDMGToolMenu", OnPopulateToolMenu)
	
	local function DrawHUD()
		--print(traceValid)
		if (traceValid) and (traceEntHealth > 0) then
			local percentCalc = 255 * (traceEntHealth / traceEntMaxHealth)
			draw.SimpleTextOutlined(tostring(traceEntHealth) .." / " ..tostring(traceEntMaxHealth), "MenuLarge", traceEntPos.x, traceEntPos.y, Color(255-percentCalc,percentCalc,0,255), 1, 1, 1, Color(0,0,0,255))
		end
		
	end
	hook.Add("HUDPaint", "PdmgHud", DrawHUD)

	--Umsg Hook
	local function entityInfo( data )

		traceValid = data:ReadBool()
		if !traceValid then return end
		traceEntHealth = data:ReadLong()
		traceEntMaxHealth = data:ReadLong()
		traceEntPos = data:ReadVector():ToScreen()
	 
	end
	usermessage.Hook( "EntityHook", entityInfo );
	
	print("PDMG - Finished Loading Client!")

end
	
print("... -=- ...")
