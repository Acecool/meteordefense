if !SERVER then return end
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

				
function ENT:Initialize()

	self:SetModel( "models/laser_turret.mdl" )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_NONE)
	self:PhysicsInit( SOLID_VPHYSICS )
	
	self:SetMaxHealth(math.random(50,80))
	self:SetHealth(self.Entity:GetMaxHealth())
	
	self.energy = 100
	self.attached = false
	self.attachedEnt = false
	self.attachTime = CurTime()
	self.lastEff = CurTime()
	self.radius = 512
	self.maxenergy = 100
	self.lastShot = CurTime()
	self.heat = 0
	self.returnTime = CurTime()
	--local phys = self.Entity:GetPhysicsObject()
	self.nextPosThink = CurTime() + 0.25
	self:SetUseType(SIMPLE_USE)
	hook.Add("Think", tostring(self) .. "posThink", function()
		
		if self:GetPhysicsObject():IsAsleep() then return end
		self:GetPhysicsObject():AddAngleVelocity(self:GetPhysicsObject():GetAngleVelocity() * -1)
		if !(CurTime() > self.nextPosThink) then return end
		if !(self.attached) then return end
		self.nextPosThink = CurTime() + 0.25
		if (CurTime() / self.returnTime) < 1 then
			self:SetAngles(LerpAngle((CurTime() / self.returnTime), self:GetUp():Angle(), Vector(0,90,0)))
		else
			if !(self:GetUp():Angle().y < 85 or
				 self:GetUp():Angle().y > 95) and
				 CurTime() > self.returnTime then
					self.returnTime = CurTime() + 10
			else
				self:SetAngles(Angle(0,90,0))
				self:GetPhysicsObject():Sleep()
				self.nextPosThink = CurTime() + 0.25
			end
		end
	end)
	
	
end

upAnimSpeed = CurTime()
startAngle = Angle(0,0,0)

function ENT:Think()
	
	local threatEnts = ents.FindByClass('meteor') --ents.FindInSphere(self:GetPos(), 1280)
	
	local winner = self.radius + 1
	local winSize = 1
	local winEnt = "not"
	
	if self.attached then
		for _, ent in pairs(threatEnts) do
			local dist = self:GetPos():Distance(ent:GetPos())
			if dist < self.radius + 1 then
				if dist < winner then
					if ent.size >= winSize then
						if ent:GetPos().z > (self:GetPos().z + 100) then
							winner = dist
							winEnt = ent
							winSize = ent.size
						end
					end
				end
			end
		end
	end
	
	if !(winEnt == "not") then
		self:Attack(winEnt)
		self.returnTime = CurTime() + 12
	end
	
	if self.energy < self.maxenergy then
		self.energy = self.energy + 0.75
		if CurTime() > self.lastEff + 1.75 then
			self.lastEff = CurTime()
			local chargeEff = EffectData()
			chargeEff:SetEntity(self)
			util.Effect("propspawn", chargeEff)
		end
	end
	
	if !ValidEntity(self.attachedEnt) or
		!self:IsConstrained() then
		self.attached = false
		self.attachedEnt = nil
		--print("Detached")
	end
	if self.heat > 0 then self.heat = self.heat - 0.2 end
	self:NextThink( CurTime() + ( 0.5 + ((2560 - self.radius) / 2048 ))) --+ math.Rand(1, 2) )
	
end

function ENT:Attack( target )
	if !self.attached then return end
	if self.owner == nil then return end
	if self.energy > 12 then
		if !(target.targeted == nil) then 
			if target.targeted then 
				self:NextThink(CurTime())
				return 
			end 
		end
		target.targeted = true
		self:SetAngles(self:AlignAngles(self:GetUp():Angle(), (target:GetPos() - self:GetPos()):Angle()))
		local firePos = self:GetAttachment(self:LookupAttachment("muzzle_end")).Pos
		local effect = EffectData()
		effect:SetStart(firePos)
		effect:SetEntity(self)
		effect:SetAttachment(self:LookupAttachment("muzzle_end"))
		effect:SetOrigin(target:GetPos())
		util.Effect( "ToolTracer", effect)
		self:EmitSound("weapons/gauss/fire1.wav", 125, 200)
		target:Fragment( target:GetVelocity() )
		self.energy = self.energy - 12
		self.value = self.value + 1
		if CurTime() - self.lastShot < 0.2 then
			self.heat = self.heat + 1
		end
		self.lastShot = CurTime()
	else
		--print("Low Energy!! " .. tostring(self.energy))
		self:EmitSound("buttons/button16.wav", 160, 100)
		self.heat = self.heat + 1
	end
	if self.heat > 24 then
		self:Ignite(2, 0)
	end
end

function ENT:PhysicsCollide( data, physobj )

	if !ValidEntity(data.HitEntity) then return end
	if data.HitEntity:IsWorld() then return end
	
	if !self.attached and
	    CurTime() > self.attachTime then
		if data.HitEntity:GetClass() == "prop_physics" then
			if !(data.HitEntity.owner == nil) then
				if data.HitEntity.owner == self.owner then
					self.basePoint = data.HitPos
					self:SetPos(self.basePoint)
					self.attached = true
					self.attachedEnt = data.HitEntity
					timer.Simple(0, 
						function() 
							--[[constraint.AdvBallsocket( self, 
												   data.HitEntity, 
												   0, 
												   0, 
												   self:WorldToLocal(self.basePoint), 
												   data.HitEntity:WorldToLocal(self.basePoint),
												   0,
												   0,
												   -90,
												   -90,
												   -90,
												   90,
												   90,
												   90,
												   1,
												   1,
												   1,
												   0,
												   1) --]]
								--constraint.Weld(self, data.HitEntity, 0, 0, 0, true)
								constraint.Ballsocket(self, data.HitEntity, 0,0, data.HitEntity:WorldToLocal(self.basePoint), 0,0,1)
						end 
					)
				end
			end
		end
	end
	

end


function ENT:Use( activator, caller)
	if self.owner then
		if activator == self.owner then
			constraint.RemoveAll(self)
			self.attached = false
			self.attachedEnt = nil
			self.attachTime  = CurTime() + 2
		end
	end
end

function ENT:OnRemove()

	hook.Remove(tostring(self) .. "posThink")

end