if !SERVER then return end
ENT.Type = "brush"

local KeyValueInfo = { 
						spawnflags = 2, 
						price = 2,
						model = 3,
						origin = 3,
						targetname = 3
					 }
local OutputInfo = { 
					 OnStartTouch = false,
					 OnEndTouch = false, 
					 OnStartTouchAll = false,
					 OnEndTouchAll = false
					}
					

if !SERVER then return end

function ENT:Initialize()

	self:SetModel( self.model )
	
	local Min = self:LocalToWorld(self:OBBMins())
	local Max = self:LocalToWorld(self:OBBMaxs())
	
	if (self.spawnflags & 1) == 1 then
		AddPropertyBox( Min , Max, tostring(self), Color(255,255,0,255))
		self.Owner = ents.GetAll()[1]
		self.IsSpawn = function() return false end
		--print("Adding A Public Property " .. tostring(self) .. " With a Max of " .. tostring(Max) .. " and a Min of " .. tostring(Min))
	elseif (self.spawnflags & 2) == 2 then
		--AddPropertyBox( Min , Max, tostring(self), Color(255,255,0,255))
		--print("Adding Spawn")
		self.IsSpawn = function() return true end
		self.Owner = self.Entity
	else
		AddPropertyBox( self:LocalToWorld(self:OBBMins()), self:LocalToWorld(self:OBBMaxs()), tostring(self), Color(0,255,0,255))
		--print("Adding An Ownable Property " .. tostring(self) .. " With a Max of " .. tostring(Max) .. " and a Min of " .. tostring(Min))
		self.Owner = nil
		self.IsSpawn = function() return false end
	end
	
	self:SetTrigger(true)
	
	if self.price == 0 then

		self.price = Max.x - Min.x 
		self.price = self.price * (Max.y - Min.y) 
		self.price = self.price * (Max.z - Min.z) 
		self.price = math.Round(self.price / 1000420)
		
	end

	--print("Property Price: " .. tostring(self.price))
	
	timer.Simple(360, self.DoUpkeep, self)	
end

function ENT:DoUpkeep()

	if self.Owner == nil then return end
	if !self.Owner:IsPlayer() then return end

	if self.Owner.Credits - math.Round(self.price / 3) < 0 then
		self.Owner:ChatPrint("Not Enough Credits, Releasing Property.")
		self.Owner = nil
		return
	end
	self.Owner.Credits = self.Owner.Credits - math.Round(self.price / 3)
	self.Owner:ChatPrint(tostring(math.Round(self.price / 3)) .. " credits have been deducted for property upkeep.")
	UpdateCredits(self.Owner)
	timer.Simple(360, self.DoUpkeep, self)
end


function ENT:StartTouch(  ent )

	if IsClass(ent, "meteor") then return end
	
	--print(tostring(ent) .. " entered " .. tostring(self))
	
	ent.CurrentArea = self.Entity
	
	if ent:IsPlayer() then
		--print(tostring(ent) .. " is in " .. tostring(ent.CurrentArea))
		if self.Owner == nil then
			ent:ChatPrint("This Property is for sale for only " .. tostring(self.price) .. " credits.")
			ent:ChatPrint("Upkeep is " .. tostring(math.Round(self.price / 3)) .. " credits every 6 minutes.")
		elseif self.Owner == ents.GetAll()[1] then
			ent:ChatPrint("This Property is Public, Please be nice.")
		elseif self.Owner == self.Entity then
			ent.InSpawn = true
		else
			if self.Owner == ent then
				ent:ChatPrint("You Own This Property.")
			else
				ent:ChatPrint("This Property Is Owned By " .. self.Owner:Nick() .. ".")
			end
		end
	end

end

function ENT:EndTouch( ent )
	
	ent.CurrentArea = nil
	ent.InSpawn = false
	
end

function ENT:KeyValue( key, value )

	--print( tostring( self ) .. " with -- Key: " .. key .. "\tValue: " .. tostring( value ) )
     
    local typ = KeyValueInfo[key]
    if ( typ ) then
        if ( typ == 1 ) then
            self[key] = tobool( value )
        elseif ( typ == 2 ) then
            self[key] = tonumber( value )
        elseif ( typ == 3 ) then
            self[key] = value
        end
    elseif ( OutputInfo[key] ) then
        self:StoreOutput( key, value )
    end
	
end