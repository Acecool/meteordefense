 include('shared.lua')
 
function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:Initialize()

	self.Created = CurTime()
	self.emitter = ParticleEmitter(self.Entity:GetPos())
	
end

function ENT:OnRemove()
	
	if !(self.emitter == nil) then
		self.emitter:Finish()
	end
	
end

function ENT:Think()
	
	if CurTime() > self.Created + 20 then self.emitter:Finish() end
	
	self.SmokeTimer = self.SmokeTimer or 0
	if self.SmokeTimer > CurTime() then return end

	self.SmokeTimer = CurTime() + 0.0125

	local vOffset = self:GetPos() + Vector(math.Rand(-3, 3), math.Rand(-3, 3), math.Rand(-3, 3))
	local vNormal = (vOffset - self:GetPos()):GetNormalized()

	self.emitter:SetPos(vOffset)
	local particle = self.emitter:Add("particles/smokey", vOffset)
	particle:SetVelocity(vNormal * math.Rand(10, 30))
	particle:SetDieTime(0.6)
	particle:SetStartAlpha(math.Rand(50, 150))
	particle:SetStartSize(math.Rand(16, 32))
	particle:SetEndSize(math.Rand(64, 128))
	particle:SetRoll(math.Rand(-0.2, 0.2))
	particle:SetColor(200, 200, 210)
	
end