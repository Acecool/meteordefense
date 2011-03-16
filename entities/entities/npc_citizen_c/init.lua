if !SERVER then return end
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')



ENT.MaleModelList = {
						"models/humans/group01/male_01.mdl",
						"models/humans/group01/male_02.mdl",
						"models/humans/group01/male_03.mdl",
						"models/humans/group01/male_04.mdl",
						"models/humans/group01/male_05.mdl",
						"models/humans/group01/male_06.mdl",
						"models/humans/group01/male_07.mdl",
						"models/humans/group01/male_08.mdl",
						"models/humans/group01/male_09.mdl" 
					}

ENT.FemaleModelList = {						
						"models/humans/group01/female_01.mdl",
						"models/humans/group01/female_02.mdl",
						"models/humans/group01/female_03.mdl",
						"models/humans/group01/female_04.mdl",
						"models/humans/group01/female_06.mdl",
						"models/humans/group01/female_07.mdl"
					  }


function ENT:rndModel()
	
	local mOrF = math.random(1,2)
	
	self.mOrF = mOrF
	
	if mOrF == 1 then
		local tBound = table.Count(self.FemaleModelList)
		return self.FemaleModelList[math.random(1,tBound)]
	else
		local tBound = table.Count(self.MaleModelList)
		return self.MaleModelList[math.random(1,tBound)]
	end

end
					  
function ENT:Initialize()
 
    self.model = self:rndModel()
	
	self:SetModel( self.model )
     
    self:SetHullSizeNormal()
    self:SetHullType( HULL_HUMAN )
	
	self:SetNPCState( NPC_STATE_IDLE )
 
    self:SetSolid( SOLID_BBOX ) 
    self:SetMoveType( MOVETYPE_STEP )
    self:CapabilitiesAdd( CAP_ANIMATEDFACE | 
	                      CAP_TURN_HEAD |
						  CAP_MOVE_GROUND |
						  CAP_MOVE_JUMP |
						  CAP_MOVE_CLIMB |
						  CAP_MOVE_CRAWL |
						  CAP_MOVE_SHOOT |
						  CAP_SKIP_NAV_GROUND_CHECK |
						  CAP_USE |
						  CAP_AUTO_DOORS |
						  CAP_OPEN_DOORS |
						  CAP_SQUAD |
						  CAP_DUCK )
						 
    self:SetUseType( SIMPLE_USE )
	
	self:AddRelationship("player D_LI 99")
	
	
    self:DropToFloor()
	self:SetHealth(math.random(100,120))
	self:SetMaxHealth(self:Health())
	self.LastRndAct =  CurTime()
	self.value = math.random(500,5000)
	self.owner = nil
	self:SetSchedule(SCHED_IDLE_WANDER)
	
end
 
function ENT:Think()
	
	if CurTime() > (self.LastRndAct + 2) then
		self.LastRndAct = CurTime()
	end
	
end

function ENT:KeyValue(key, value)

	print(tostring(self) .. " with -- Key : " .. key .. "     Value : " .. value)
	
	if key == "shop_type" then self.shop_type = tonumber(value) end
	if key == "origin" then self.origin = value end
	if key == "targetname" then self.targetname = tostring(value) end
	if key == "spawnflags" then self.spawnflags = tonumber(value) end
	if key == "model" then self.model = tostring(value) end
	if key == "citizentype" then self.citizentype = tonumber(value) end
	
	
	--[[
	
	[NPC 32/sent_ai] with -- Key : ScriptName     Value : npc_shop
	[NPC 32/npc_shop] with -- Key : origin     Value : 908 13232 -513
	[NPC 32/npc_shop] with -- Key : targetname     Value : Shop_Left
	[NPC 32/npc_shop] with -- Key : spawnflags     Value : 262660
	[NPC 32/npc_shop] with -- Key : rendercolor     Value : 255 255 255
	[NPC 32/npc_shop] with -- Key : renderamt     Value : 255
	[NPC 32/npc_shop] with -- Key : physdamagescale     Value : 1.0
	[NPC 32/npc_shop] with -- Key : model     Value : models/humans/group01/male_07.mdl
	[NPC 32/npc_shop] with -- Key : GameEndAlly     Value : No
	[NPC 32/npc_shop] with -- Key : DontPickupWeapons     Value : No
	[NPC 32/npc_shop] with -- Key : citizentype     Value : 4
	[NPC 32/npc_shop] with -- Key : angles     Value : 0 215 0
	[NPC 32/npc_shop] with -- Key : AlwaysTransition     Value : No
	[NPC 32/npc_shop] with -- Key : classname     Value : npc_shop
	[NPC 32/npc_shop] with -- Key : hammerid     Value : 3886


	--]]
end

function ENT:OnTakeDamage( dmginfo )

	print("NPC Taking" .. dmginfo:GetDamage() .. " DAMAGE!!")
	self:SetHealth(self:Health() - dmginfo:GetDamage())
	self:SetSchedule(SCHED_SMALL_FLINCH)
	if dmginfo:GetDamage() > (self:GetMaxHealth() / 3) then
		self:SetSchedule(SCHED_BIG_FLINCH)
	end
	if self:Health() < 0 then 
		print("NPC DIE!!")
		--self:SetSchedule(SCHED_DIE)
		self:SetSchedule(SCHED_DIE_RAGDOLL)
	end

end
 
function ENT:SelectSchedule()
	
	if !(self.target == nil) then

		if !self.target:IsValid() then self.target = nil return end
		
		if self:GetPos():Distance(self.target:GetPos()) > 256 then
			self:SetTarget(self.target)
			self:SetSchedule(SCHED_TARGET_CHASE)
		else
			self:SetTarget(self.target)
			self:SetSchedule(SCHED_TARGET_FACE)
		end
	else
		self:SetSchedule(SCHED_IDLE_WANDER)
	end
	
end
 
function ENT:AcceptInput( Name, Activator, Caller ) 
    
	if( Name == "Use" ) and CurTime() >= (Activator.LastUse or 0) + 1 then
        Activator.LastUse = CurTime()

		if self.target == nil and
		   self.owner == nil then
			self.target = Activator
			self.owner = Activator
			self:SetTarget(self.target)
			self:SetSchedule(SCHED_TARGET_CHASE)
		elseif self.owner == Activator then
			if self.target == nil then
				self.target = Activator
				self:SetTarget(self.target)
				self:SetSchedule(SCHED_TARGET_CHASE)
			else
				self.target = nil
			end
		end
		
        	
    end
	
end

