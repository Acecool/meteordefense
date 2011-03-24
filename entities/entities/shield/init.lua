if !SERVER then return end
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local oldRadius = 0

function ENT:Initialize()
	print("Shield Initialize")
	self:SetModel("models/props_junk/PopCan01a.mdl")
	self:SetSolid( SOLID_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
	
end

function ENT:KeyValue(key, value)
	print( tostring( self ) .. " with -- Key: " .. key .. "\tValue: " .. tostring( value ) )
end

function ENT:InitShield()
	self:PhysicsInitSphere( self.radius)
	self:SetCollisionBounds(Vector(-self.radius,-self.radius,-self.radius), Vector(self.radius,self.radius,self.radius))
	self:SetNWInt("radius", self.radius)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
		phys:SetMaterial("gmod_bouncy")
	end
	self:MakePhysicsObjectAShadow()
	self:NextThink( CurTime() + 1)	
end

function ENT:Think()
	
	local phys = self:GetPhysicsObject()
	
	if !(self.radius == self:GetNWInt("radius", 10)) then
		print("Correcting Radius -- Shield")
		self:PhysicsInitSphere( self.radius)
		self:SetCollisionBounds(Vector(-self.radius,-self.radius,-self.radius), Vector(self.radius,self.radius,self.radius))
		self:SetNWInt("radius", self.radius)
	end
	
	if ValidEntity(self.gen) then 
		self:SetPos(self.gen:LocalToWorld(self.gen:OBBCenter())) 
		--if !self:IsConstrained() then
			--constraint.Weld(self, GetWorldEntity(), 0, 0, 0, true)
		--end
	else
		SafeRemoveEntityDelayed(self, 0)
	end
	
	if self:GetCollisionGroup() == COLLISION_GROUP_NONE then
		self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
	end
	
	if ( self:IsOnFire() ) then
		self:Extinguish();
	end		
		
	self:NextThink( CurTime() + 1)

end


function ENT:PhysicsCollide( data, physobj )
		
		--print("Hit by " .. tostring(data.HitEntity))
		if !(data.HitEntity:GetClass() == "meteor") then 
			data.HitEntity:GetPhysicsObject():SetVelocity(data.TheirOldVelocity)
			return false
		end
		
		data.HitEntity:Fragment( data.TheirOldVelocity )
		
		if self.gen then
			self.gen.energy = self.gen.energy - (data.Speed / 10)
			self.gen.heat = self.gen.heat + (data.Speed / 1269)
		end
		--QuickEffect(data.HitEntity, data.HitPos,  "cball_bounce")
		if ( self:IsOnFire() ) then
			self:Extinguish();
		end
		
end

function ENT:OnRemove()

end

function ENT:Use(activator, caller)
	
	if self.owner == activator then 
		if ValidEntity(self.gen) then
			self.gen.shieldOn = false
		end
		SafeRemoveEntityDelayed(self, 0)
	end
	
end