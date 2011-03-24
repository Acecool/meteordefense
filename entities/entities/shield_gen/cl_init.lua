 include('shared.lua')
 
function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:Initialize()

	self.Created = CurTime()
	
end

function ENT:OnRemove()
	
end

function ENT:Think()
	
	
end