if !SERVER then return end
ENT.Type = "brush"


ENT.NPCTypes = {
				"npc_antlion",
				"npc_antlionguard",
				"npc_combine_s",
				"npc_fastzombie",
				"npc_headcrab",
				"npc_headcrab_black",
				"npc_headcrab_fast",
				"npc_metropolice",
				"npc_poisonzombie",
				"npc_rollermine",
				"npc_zombie",
				"npc_zombine", 
				"npc_zombie_torso"
				}
				
ENT.NPCRndTypes = {
				"npc_antlion",
				"npc_combine_s",
				"npc_fastzombie",
				"npc_headcrab",
				"npc_headcrab_black",
				"npc_headcrab_fast",
				"npc_metropolice",
				"npc_poisonzombie",
				"npc_zombie",
				"npc_zombine", 
				"npc_zombie_torso"
				}
				
ENT.NPCWeapons = { 
					"weapon_357",
					"weapon_ar2",
					"weapon_annabelle",
					"weapon_frag",				
					"weapon_pistol",
					"weapon_rpg",
					"weapon_shotgun",
					"weapon_smg1",
					"weapon_stunstick"
				 }				

ENT.NPCWeaponsRebel = { 
					"weapon_ar2",
					"weapon_pistol",
					"weapon_shotgun",
					"weapon_smg1",
					"weapon_crowbar",
					"weapon_stunstick",
					"weapon_rpg"
				 }								 
				 
ENT.NPCWeaponsCombine = { 
					"weapon_ar2",
					"weapon_shotgun",
					"weapon_smg1"
				 }
ENT.NPCWeaponsPolice = { 
					"weapon_pistol",
					"weapon_smg1",
					"weapon_stunstick",
					"weapon_shotgun"
				 }				 

function ENT:SetRelations( ent )
	
end

function ENT:PrintKeyValues()

		print(tostring(self) .. "'s Key Values and Variables")
		print("-=-=-=-=---===-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
		print("Key Values")
		print("model: " .. tostring(self.model))
		print("spawn_rate: " .. tostring(self.spawn_rate))
		print("origin: " .. tostring(self.origin))
		print("enabled: " .. tostring(self.enabled)) 
		print("spawnflags: " .. tostring(self.spawnflags)) 
		print("spawn_max: " .. tostring(self.spawn_max)) 
		print("delay_modify: " .. tostring(self.delay_modify)) 
		print("npc_class: " .. tostring(self.npc_class)) 
		print("npc_weapon: " .. tostring(self.npc_weapon)) 
		print("min_rate: " .. tostring(self.min_rate)) 
		print("max_rate: " .. tostring(self.max_rate)) 
		print("maxinplay: " .. tostring(self.maxinplay)) 
		print("npc_spawnflags: " .. tostring(self.npc_spawnflags))
		print("-----------------------------------------")
		print("Variables")
		print("def_spawn_rate: " .. tostring(self.def_spawn_rate))
		print("size: " .. tostring(self.size))
		print("dropCount: " .. tostring(self.dropCount))
		print("NextSpawn: " .. tostring(self.NextSpawn))
		print("SpawnTotal: " .. tostring(self.SpawnTotal))
		print("lvlSpawnCount: " .. tostring(self.lvlSpawnCount))
		print("entsTable: ")
		PrintTable(self.entsTable)

end

function ENT:Initialize()

        print("area_npcspawn Initialize")
		self:SetModel(self.model)
         
        self:SetAngles( Angle( 0 , 90 , 0 ) )
         
        self:SetSolid( SOLID_BBOX )
           
        self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		
		-- Set All Key Default Just encase they weren't set in hammer
		
		self.model = self.model or "models/error.mdl"
		self.spawn_rate = self.spawn_rate or 2
		self.origin = self.origin or self:GetPos()
		self.enabled = self.enabled or false 
		self.spawnflags = self.spawnflags or 0
		self.spawn_max = self.spawn_max or 0
		self.delay_modify = self.delay_modify or 0
		self.npc_class = self.npc_class or "npc_zombie"
		self.npc_weapon = self.npc_weapon or ""
		self.min_rate = self.min_rate or 0
		self.max_rate = self.max_rate or 10
		self.maxinplay = self.maxinplay or 2
		self.npc_spawnflags = self.npc_spawnflags or 0
	
		self.def_spawn_rate = self.spawn_rate
		self.size = Vector(0,0,0)
		self.dropCount = 0
		self.NextSpawn = CurTime()
		self.SpawnTotal = 0 
		self.lvlSpawnCount = 0
		self.entsTable = {}
		
		--AddPropertyBox( self:OBBMins(), self:OBBMaxs(), tostring(self), Color(255,0,255,255))
	
end
 
function ENT:AcceptInput( name, activator, caller, data)

	if !(name == nil) then print(tostring(name)) end
	if !(activator == nil) then print(tostring(activator)) end
	if !(caller == nil) then print(tostring(caller)) end
	
	if !(name == nil) then 
		
		if name == "Enable" then self.enabled = true end
		if name == "Disable" then self.enabled = false end
		if name == "Reset" then
			self:TriggerOutput("Reset", activator)
			self.SpawnTotal = 0
			self.NextSpawn = CurTime() + 1
			self.spawn_rate = self.def_spawn_rate
		end
		if name == "Spawn" then self:TriggerSpawn() end
		
	end
	data = data or " no data "
	print(tostring(self) .. " with Input : " .. tostring(name) .. " : " .. tostring(activator)  .. " : " .. tostring(caller) .. " : " .. tostring(data))
end	

function ENT:KeyValue( key, value )
		
	print(tostring(self) .. " with -- Key : " .. key .. "     Value : " .. value)
	
	if key == "model" then self.model = value end
	if key == "origin" then self.origin = value end
	if key == "enabled" then self.enabled = tobool(value) end 
	if key == "spawnflags" then self.spawnflags = tonumber(value) end 
	if key == "spawn_rate" then self.spawn_rate = tonumber(value) end
	if key == "spawn_max" then self.spawn_max = tonumber(value) end
	if key == "delay_modify" then self.delay_modify = tonumber(value) end
	if key == "npc_class" then self.npc_class = value end
	if key == "npc_weapon" then self.npc_weapon = value end
	if key == "min_rate" then self.min_rate = tonumber(value) end
	if key == "max_rate" then self.max_rate = tonumber(value) end
	if key == "maxinplay" then self.maxinplay = tonumber(value) end
	if key == "npc_spawnflags" then self.npc_spawnflags = tonumber(value) end
	
	if key == "PreSpawn" then self:StoreOutput(key, value) end
	if key == "OnSpawn" then self:StoreOutput(key, value) end
	if key == "PostSpawn" then self:StoreOutput(key, value) end
	if key == "Reset" then self:StoreOutput(key, value) end
	if key == "LimitHit" then self:StoreOutput(key, value) end
	if key == "OnUser1" then self:StoreOutput(key, value) end
	if key == "OnUser2" then self:StoreOutput(key, value) end
	if key == "OnUser3" then self:StoreOutput(key, value) end
	if key == "OnUser4" then self:StoreOutput(key, value) end
	
	--[[
	output PreSpawn(void) : "Fires just before and NPC Spawns"
	output OnSpawn(void) : "Fires as a NPC Spawns"
	output PostSpawn(void) : "Fires after a NPC Spawns"
	output Reset(void) : "Fires When Entity is Reset"
	output LimitHit(void) : "Fires When spawn_max is hit"
	--]]
	
end	

function ENT:OnRemove()
end	

function ENT:TriggerSpawn()
	
		print("TriggerSpawn-------------------------------------------area_npcspawn-----------------------------------")
		local newNPCClass = ""
		local idx = 0
		local rndIdx = 0
		local npcWeapon = ""
		
		self:TriggerOutput("PreSpawn", self)
		
		-- Pick a good spot inside the volume on the ground to spawn
		local SpawnPos = self:FindSpawn()
		print("Got Spawn loc" .. tostring(SpawnPos))
		--If we can't find a spot then  skip and spawn next time
		if !(SpawnPos == nil) then 
				
			self.SpawnTotal = self.SpawnTotal + 1
			
			if self.npc_class == "random" then
				newNPCClass = GetRandomValue(self.NPCRndTypes)
				print("Random: " .. newNPCClass)
			else
				newNPCClass = self.npc_class
				print("Set: " .. newNPCClass)
			end
			--print("Random Test: " .. GetRandomValue(self.NPCRndTypes))
			print("NPCClass: " .. newNPCClass)
			idx = table.insert( self.entsTable, ents.Create( newNPCClass ))
			print("NPC Created in Table")
			local newNPC = self.entsTable[idx]
			print("npc ref var set")
			newNPC.managed = true
			newNPC.value = math.random(1000,3000)
			newNPC.squadset = false
			newNPC:SetPos( SpawnPos )
			print("npc pos set")
			if self.npc_weapon == "random" then
				if newNPCClass == "npc_combine_s" then
					rndIdx, npcWeapon = GetRandomKeyValue(self.NPCWeaponsCombine)
				elseif newNPCClass == "npc_citizen" then
					rndIdx, npcWeapon = GetRandomKeyValue(self.NPCWeaponsRebel)
				elseif newNPCClass == "npc_metropolice" then
					rndIdx, npcWeapon = GetRandomKeyValue(self.NPCWeaponsPolice)
				else
					rndIdx, npcWeapon = GetRandomKeyValue(self.NPCWeapons)
				end
			else
				npcWeapon = self.npc_weapon
			end
			if !(npcWeapon == "none") then
				newNPC:SetKeyValue("additionalequipment", npcWeapon)
			end
			newNPC:SetKeyValue("spawnflags", self.npc_spawnflags)
			print("NPC PreSpawn")
			newNPC:Spawn()
			newNPC:CapabilitiesAdd( CAP_SQUAD | CAP_NO_HIT_SQUADMATES | CAP_AIM_GUN | CAP_DUCK | CAP_USE_WEAPONS)		
			print("NPC PostSpawn")
			self:TriggerOutput("OnSpawn", self)			
			print("Done init on npc")
			newNPC:Activate()
			print("NPC Activated!")
			--Spawn Limit Code
			if (self.SpawnTotal >= self.spawn_max) and (self.spawn_max > 0) then 
				self.enabled = false 
				self:TriggerOutput("LimitHit", self)
			end				
			
			--Rate Control Code
			self.spawn_rate = self.spawn_rate + self.delay_modify
			if self.spawn_rate < self.min_rate then self.spawn_rate = self.min_rate end
			if self.spawn_rate > self.max_rate then self.spawn_rate = self.max_rate end
		
			if math.random(1,100) > 60 then timer.Simple(0.5, npcWander, newNPC) end
		
			self:TriggerOutput("PostSpawn", newNPC)
			
		end
end

function npcWander( npc )
	npc:SetSchedule(SCHED_IDLE_WANDER,1024)
end

function ENT:Think()

	
	-- Table Cleanup
	if table.Count(self.entsTable) > 0 then
		for i, v in pairs(self.entsTable) do
			if !(v:IsValid()) or (v == NULL) then  table.remove(self.entsTable, i) end
		end
	end
	
	if !self.enabled then return end
	
	-- Spawn Stuff
	if CurTime() > self.NextSpawn then
			
			if table.Count(self.entsTable) < self.maxinplay then 
				self:TriggerSpawn()
			end
			
			self.NextSpawn = CurTime() + self.spawn_rate
	end
	
end	


function ENT:FindSpawn()
		
	if  self.size == Vector(0,0,0) then
		local X = (self:OBBMaxs().x - self:OBBMins().x)
		local Y = (self:OBBMaxs().y - self:OBBMins().y)
		local Z = (self:OBBMaxs().z - self:OBBMins().z)
		self.size = Vector(X, Y, Z)
	end
	
	local hX = self.size.x / 2
	local hY = self.size.y / 2
	local hZ = self.size.z / 2
	
	print("Spawn OBBCenter(): " .. tostring(self:LocalToWorld(self:OBBCenter())))
	print("Spawn OBBCenter() non ltw: " .. tostring(self:OBBCenter()))
	print("Spawn GetPos(): " .. tostring(self:GetPos()))
	--[[local oX = self:LocalToWorld(self:OBBCenter()).x
	local oY = self:LocalToWorld(self:OBBCenter()).y
	local oZ = self:LocalToWorld(self:OBBCenter()).z
	]]--
	
	local oX = self:OBBCenter().x
	local oY = self:OBBCenter().y
	local oZ = self:OBBCenter().z
	
	local rX = math.Rand(oX - hX, oX + hX)
	local rY = math.Rand(oY - hY, oY + hY)
	local rZ = oZ + hZ
	
	local SpawnTrace = {}
	SpawnTrace.start = Vector(rX, rY, rZ)
	SpawnTrace.endpos = Vector(rX, rY, rZ - self.size.z)
			
	local SpawnTraceRes = util.TraceLine(SpawnTrace)

	if !SpawnTraceRes.Hit or
	   SpawnTraceRes.StartSolid then
		return nil
	end
		
	fX = SpawnTraceRes.HitPos.x
	fY = SpawnTraceRes.HitPos.y
	fZ = SpawnTraceRes.HitPos.z
	
	return Vector(fX, fY, (fZ+2))
	
end
