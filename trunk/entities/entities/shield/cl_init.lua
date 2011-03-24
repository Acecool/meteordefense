 include('shared.lua')

 ENT.RenderGroup     = RENDERGROUP_TRANSLUCENT
 
local beam = Material("cable/new_cable_lit")

function ENT:CreatePoints( numPoints, radius )

	self.points = {}
	
	local point = Vector(0,0,0)
	
	for z = radius, -radius, -(radius / numPoints) do
		self.points[z] = {}
		for deg = 0 , 360, 360 / numPoints do
		
			r = math.sqrt( (radius * radius ) - (z * z) )
			
			point = Vector(math.sin(math.rad(deg)) * r,
						   math.cos(math.rad(deg)) * r,
						   z)
			
			table.insert(self.points[z], point)

			end
		
	end

end

function ENT:DrawTranslucent()
	
	render.SetMaterial( beam )
    
	--[[local rad = self:GetNWInt("radius", 10) * 0.60
	local point = Vector(0,0,0)
	local pointCount = 8
		
	for z = rad, -rad, -(rad / pointCount) do
		render.StartBeam( pointCount + 1 )
		for deg = -90 , 360, 360 / pointCount do
		
			r = math.sqrt( (rad * rad ) - (z * z) )
			
			point = Vector(math.sin(math.rad(deg)) * r,
						   math.cos(math.rad(deg)) * r,
						   z)
			
			render.AddBeam( (self:GetPos() + (point)),
							 3,
							(CurTime() + deg) / 360,
							 Color(0, 255 * (z / rad) ,255, 128))
		end
		render.EndBeam()
	end--]]
							 
	if self.points then
		local zCount = table.Count(self.points)
		
		for ck, circ in pairs(self.points) do
			local cCount = table.Count(circ)
			render.StartBeam(cCount)
			for pk, point in pairs(circ) do
				render.AddBeam(self:GetPos() + point, 
							   2,
								(CurTime() / 360),
								Color( 0,
									   255 + (128 * math.sin(math.rad(self.degWheel))) , 
									   255 - (128 * math.cos(math.rad(self.degWheel))) ,
									   128 ))
			end
			render.EndBeam()
		end
	end
	
	
	local dlight = DynamicLight( self:EntIndex() )
    if ( dlight ) then
        dlight.Pos = self:GetPos()
        dlight.r = 0
        dlight.g = 255 + (128 * math.sin(math.rad(self.degWheel)))
        dlight.b = 255 - (128 * math.cos(math.rad(self.degWheel)))
        dlight.Brightness = 1024 
        dlight.Decay = 256
		dlight.Size = 256 + (256 * math.sin(math.rad(self.degWheel)))
		dlight.Style = 5
        dlight.DieTime = CurTime() + math.Rand(1,2)
    end
end

function ENT:Initialize()
	
	local rendScale = 2
	self:SetRenderBounds((Vector(self:GetNWInt("radius", 1024), self:GetNWInt("radius", 1024), self:GetNWInt("radius", 1024))) * rendScale, (Vector(-self:GetNWInt("radius", 1024), -self:GetNWInt("radius", 1024), -self:GetNWInt("radius", 1024))) * rendScale)
	self:CreatePoints(8, self:GetNWInt("radius", 10))
	self.radius = self:GetNWInt("radius", 10) 
	--self:CalcCircles(self:GetNWInt("radius", 10))
	self.degWheel = 0
	self.degUp = true
	self.Created = CurTime()
	self.emitter = ParticleEmitter(self.Entity:GetPos())
end

function ENT:OnRemove()

	if !(self.emitter == nil) then
		self.emitter:Finish()
	end	
	
end

function ENT:Think()

		if !(self.radius == self:GetNWInt("radius", 10)) then
			print("Correcting Radius -- Radius is " .. tostring(self.radius))
			print("Correcting Radius -- Radius should be " .. tostring(self:GetNWInt("radius", 10)))
			self.radius = self:GetNWInt("radius", 10)
			local rendScale = 2
			self:SetRenderBounds((Vector(self:GetNWInt("radius", 1024), self:GetNWInt("radius", 1024), self:GetNWInt("radius", 1024))) * rendScale, (Vector(-self:GetNWInt("radius", 1024), -self:GetNWInt("radius", 1024), -self:GetNWInt("radius", 1024))) * rendScale)
			self:CreatePoints(8, self:GetNWInt("radius", 10))
		end
		
		if self.degUp then
			self.degWheel = self.degWheel + 1
		else
			self.degWheel = self.degWheel - 1
		end
		
		if self.degWheel >= 360 then self.degUp = false end
		if self.degWheel <= 0 then self.degUp = true end
		
		self:ParticleThink()
		
		self:NextThink(CurTime() + 1)
end

function ENT:ParticleThink()

		if self.nextPThink == nil then self.nextPThink = CurTime() -1 end
		
		if self.emitter == nil then return end
		
		local vOffset = self:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-2, 2) + ( 2 * math.sin(math.rad(self.degWheel))))
		
		self.emitter:SetPos(vOffset)
		local particle = self.emitter:Add("particle/particle_sphere", vOffset)
		particle:SetVelocity(Vector(0,0,0))
		particle:SetDieTime(0.05)
		particle:SetStartAlpha( 0 )
		particle:SetEndAlpha( 255 )
		particle:SetStartSize( 0 )
		particle:SetEndSize( math.random(1,12) )
		particle:SetRoll(math.Rand(-0.3, 0.3))
		particle:SetColor(0,
						  255 + (128 * math.sin(math.rad(self.degWheel))), 
						  255 - (128 * math.cos(math.rad(self.degWheel))))
		self.nextPThink = CurTime() + 2
end
