if !SERVER then return end
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( "models/shield_gen/gen.mdl")
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_NONE)
	self:PhysicsInit( SOLID_VPHYSICS )
	
	self:SetAngles( Angle(0,90,0) )
	self:SetUseType(SIMPLE_USE)
	
	self.maxenergy = 1000
	self.energy = 1000
	self.radius = 128
	self.heat = 0
	self.lastEff = CurTime()
	self.warnTime = CurTime()
	self.failTime = CurTime()
	self.coolTime = CurTime()
	self.shieldOn = false
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end
	
	self:SpawnShield()
		
end

function ENT:SpawnShield()
	if !ValidEntity(self.shield) then
		self.shield = ents.Create("shield")
		self.shield:SetPos(self:LocalToWorld(self:OBBCenter()))
		self.shield:Spawn()
		self.shield.gen = self
		self.shield.owner = self.owner
		self.shield.radius = self.radius
		self.shield:InitShield()
		self:EmitSound("shield_activated.wav", 120, 100)
		self.shieldOn = true
	end
end

function ENT:Think()
	
	if !(self.shield.owner == self.owner) then 
		self.shield.owner = self.owner
		self.shield.gen = self
	else
		if !(self.shield.radius == self.radius) then
			self.shield.radius = self.radius
			print("Correcting Radius -- Shield_Gen")
		end
		
	end
	
	if self.energy < 0 then
		SafeRemoveEntityDelayed(self.shield, 0)
		self:EmitSound("shield_deactivated.wav", 120, 100)
		self.shieldOn = false
	end
	if ((self.energy / self.maxenergy) < 0.2) and (CurTime() > self.warnTime) then
			self:EmitSound("low_energy.wav", 140, 100)
			self.warnTime = CurTime() + 20
	end 
	
	if self.heat > 100 then
		self:Ignite(3, 0)
		if CurTime() > self.coolTime then
			self:EmitSound("cooling_failure.wav", 120, 100)
			self.coolTime = CurTime() + 4
		end
		
	elseif self.heat < 50 and
		   self:IsOnFire() then
			 self:Extinguish()
	end
	
	if (self:Health() / self:GetMaxHealth()) < 0.25 then
		if math.random(1, 100) == 42 then
			SafeRemoveEntityDelayed(self.shield, 0)
			self.shieldOn = false
		end
		if CurTime() > self.failTime then
			self:EmitSound("shield_failure.wav", 120, 100)
			self.failTime = CurTime() + 5
		end
	end
	
	if ValidEntity(self.shield) then
		self.energy = self.energy - 0.1
		self.heat = self.heat - math.Rand(0, 0.5)
	else
		self.heat = self.heat - math.Rand(0.85, 2)
		if self.energy < self.maxenergy then
			self.energy = self.energy + (self.maxenergy / 1000)
			if CurTime() > self.lastEff + 1.5 then
				self.lastEff = CurTime()
				local chargeEff = EffectData()
				chargeEff:SetEntity(self)
				util.Effect("propspawn", chargeEff)
			end
		end
	end
	
	if self.heat < 0 then self.heat = 0 end
	self.energy = math.Clamp(self.energy, 0, self.maxenergy)
	
	self:NextThink( CurTime() + 1 )
	
end

function ENT:OnRemove()
	SafeRemoveEntityDelayed(self.shield, 0)
	self.shieldOn = false
end

function ENT:Use(activator, caller)
	
	--[[print("\nShield Gen Use")
	print("---------------")
	print("Activator: " .. tostring(activator))
	print("Caller : " .. tostring(caller))
	print("self.shieldOn : " .. tostring(self.shieldOn))
	print("Shield Valid : " .. tostring(ValidEntity(self.shield)))
	print("self.owner : " .. tostring(self.owner)) --]]
	if self.owner == activator then 
		if !self.shieldOn then
			self:SpawnShield()
		else
			SafeRemoveEntityDelayed(self.shield, 0)
			self:EmitSound("shield_deactivated.wav", 120, 100)
			self.shieldOn = false
		end
	end
	
end