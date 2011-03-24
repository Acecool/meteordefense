if !SERVER then return end
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.FlightSound = ""

--[[
ENT.MeteorList = {}
					
ENT.MeteorList[5] =	{
					 "models/props_wasteland/rockgranite01a.mdl",
					 "models/props_wasteland/rockgranite01b.mdl"
					}

ENT.MeteorList[4] =	{
					 "models/props_wasteland/rockgranite02a.mdl",
					 "models/props_wasteland/rockgranite02b.mdl"
					}

ENT.MeteorList[3] =	{
					 "models/props_wasteland/rockgranite03a.mdl",
					 "models/props_wasteland/rockgranite03c.mdl"
					}					

ENT.MeteorList[2] =	{
			 	     "models/props_wasteland/rockgranite03b.mdl"
					}										

ENT.MeteorList[1] =	{
					 "models/props_debris/physics_debris_rock1.mdl",
					 "models/props_debris/physics_debris_rock11.mdl",
					 "models/props_debris/physics_debris_rock6.mdl"
					}										
--]]

ENT.MeteorList = {}
					
ENT.MeteorList[5] =	{
					 "models/meteors/meteor_5.mdl"
					}

ENT.MeteorList[4] =	{
					 "models/meteors/meteor_4.mdl"					 
					}

ENT.MeteorList[3] =	{
					 "models/meteors/meteor_3.mdl"
					}					

ENT.MeteorList[2] =	{
			 	     "models/meteors/meteor_2.mdl"
					}										

ENT.MeteorList[1] =	{
					 "models/meteors/meteor_1.mdl"
					}										
				

ENT.MeteorPieces = {}
ENT.MeteorPieces[5] = { "1,1,1,1,1", "1,1,1,2", "1,1,3", "1,4", "2,3", "2,2,1" }
ENT.MeteorPieces[4] = { "1,1,1,1", "1,1,2", "1,3", "2,2"}
ENT.MeteorPieces[3] = { "1,1,1", "1,2"}
ENT.MeteorPieces[2] = { "1,1"}

					
function ENT:Initialize()

	local rndSize = math.random(3,5)
	self.size = rndSize
	self:SetModel( self.MeteorList[rndSize][math.random(1,table.Count(self.MeteorList[rndSize]))])
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_NONE)
	self:PhysicsInit( SOLID_VPHYSICS )
	
	--self:SetAngles( Angle(math.random(1,360),math.random(1,360),math.random(1,360) ) )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass( tonumber(phys:GetVolume()) / math.random(72,120) )
		phys:SetMaterial("boulder")
		
	end
		
end

function ENT:Think()
	
	if (self:GetVelocity():Length() < 20) or
	   (self:GetVelocity() == Vector(0,0,0)) or
		!(self:IsInWorld()) then
		if !SERVER then
			self:NextThink( CurTime() + 3)
			return
		else
			SafeRemoveEntityDelayed(self,0)
		end
	end
	self:NextThink( CurTime() + 3)

end

function ENT:PhysicsCollide( data, physobj )

	if data.DeltaTime >= 0.9 then
		WorldSound("Boulder.ImpactHard",data.HitPos, 328, 100)
		
		self:Fragment( self:GetVelocity() )
		
		if data.HitEntity:IsWorld() then return end
		data.HitEntity:TakeDamage((data.Speed / 8) * math.Rand(1,1.5678), self, self)
		if math.random(1,100) > 75 then data.HitEntity:Ignite(math.random(10,20),128) end
	
	end
	
end

function ENT:Fragment( newVel )

	if self.fragged then return end
	self.fragged = true
	
	local szPieces = {}

	if self.size > 1 then

		local fragPos = self:GetPos()
		self:EmitSound("Breakable.Concrete", 250, 100)	
		SafeRemoveEntityDelayed(self, 0)
		szPieces = string.Explode(",", self.MeteorPieces[self.size][math.random(1,table.Count(self.MeteorPieces[self.size]))])
		for k, v in pairs(szPieces) do
		local fragment = ents.Create("meteor")
			fragment:SetPos(fragPos)
			fragment:Spawn()
			fragment:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
			fragment.size = tonumber(v)
			fragment:ChangeSize()
			local rndDir = Vector(math.Rand(-1,1),math.Rand(-1,1), 0)
			fragment:GetPhysicsObject():SetVelocity(rndDir * (newVel:Length() * 0.65) ) -- speed)
			fragment:EmitSound("Weapon_Mortar.Incomming", 150, 50) 
		end
		
	else

		self:EmitSound("Breakable.Concrete", 250, 100)	
		SafeRemoveEntityDelayed(self, 0)
		
	end
	

end

function ENT:OnRemove()
	self:Extinguish()
end

function ENT:ChangeSize()

	self.Entity:SetModel( self.MeteorList[self.size][math.random(1,table.Count(self.MeteorList[self.size]))])

end

function ENT:Shoot( targPos, startPos, vel )
	
	--print("Shooting Meteor")
	--print("targPos: " .. tostring(targPos) )
	--print("startPos: " .. tostring(startPos) )
	--print("velocity: " .. tostring(vel) )
	local sPhys = self:GetPhysicsObject()
	local velDir = (targPos - startPos):GetNormal()
	--print("velDir: " .. tostring(velDir))
	self:SetAngles(self:AlignAngles(self:GetUp():Angle(),  velDir:Angle()))
	sPhys:SetVelocity(velDir * vel)
	
end
