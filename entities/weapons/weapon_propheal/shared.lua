SWEP.Author = "Fantym"
SWEP.Contact = ""
SWEP.Purpose = "Heals prop +20 Health Per Shot"
SWEP.Instructions = "Primary to heal prop +20 health, Secondary to heal prop fully or clip is emptied"
SWEP.Category = "PDMG - Heal SWEP"
 
SWEP.Spawnable = false;
SWEP.AdminSpawnable = true;
 
SWEP.ViewModel = "models/Weapons/V_Stunbaton.mdl";
SWEP.WorldModel = "models/Weapons/w_stunbaton.mdl";
 
SWEP.Primary.ClipSize = 20;
SWEP.Primary.DefaultClip = 200;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "Battery";
 
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";
 
SWEP.Sound = Sound ("HealthVial.Touch")

SWEP.Damage = -20
SWEP.Spread = 0.00
SWEP.NumBul = 1
SWEP.Delay = 0.3
SWEP.Force = 0
 
function SWEP:Deploy()
return true
end
 
function SWEP:Holster()
return true
end
 
function SWEP:Think()

	if CLIENT then return end
	--[[local eyetrace = self.Owner:GetEyeTrace();
	local traceEnt = eyetrace.Entity
	
	umsg.Start("EntityHook", self.Owner)
	umsg.Bool( traceEnt:IsValid() )
	
	if traceEnt:IsValid() and traceEnt:Health() > 0 then
	
			umsg.Long( traceEnt:Health() )
			umsg.Long( traceEnt:GetMaxHealth() )
			umsg.Vector( traceEnt:GetPos() )
	end
	
	umsg.End()--]]
	
end

local function extinguishEnt( ent )
	if math.random(1, 1000) > 500 then 
		ent:Extinguish()
	end
end
  
function SWEP:PrimaryAttack()
 
	if ( !self:CanPrimaryAttack() ) then return end
 
	local eyetrace = self.Owner:GetEyeTrace();
	local traceEnt = eyetrace.Entity
	
	if ( !traceEnt:IsValid() ) then return end
	
	if traceEnt:Health() > 0 then
		
		if traceEnt:Health() > (traceEnt:GetMaxHealth() / 2) then extinguishEnt(traceEnt) end
		
		if traceEnt:Health() == traceEnt:GetMaxHealth() then return end
		
		if traceEnt:Health() + 20 > traceEnt:GetMaxHealth() then
			traceEnt:SetHealth(traceEnt:GetMaxHealth())
		else
			traceEnt:SetHealth(traceEnt:Health() + 20)
		end

		self.Weapon:EmitSound ( self.Sound )
	
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
 
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay )
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Delay )
	 
		self:TakePrimaryAmmo(1)
	end

end 

function SWEP:SecondaryAttack() 
 

	if ( !self:CanPrimaryAttack() ) then return end
 
	local eyetrace = self.Owner:GetEyeTrace();
	local traceEnt = eyetrace.Entity
	
	if ( !traceEnt:IsValid() ) then return end
	
	if traceEnt:Health() > 0 then
	
		if traceEnt:Health() > (traceEnt:GetMaxHealth() / 2) then extinguishEnt(traceEnt) end
		
		if traceEnt:Health() == traceEnt:GetMaxHealth() then return end
		
		local HowMany = math.Round((traceEnt:GetMaxHealth() - traceEnt:Health()) / self:Clip1())
		
		
		if HowMany < self:Clip1() then
			traceEnt:SetHealth(traceEnt:GetMaxHealth())
			self:TakePrimaryAmmo(HowMany)
		else
			traceEnt:SetHealth(traceEnt:Health() + (self:Clip1() * 20))
			self:TakePrimaryAmmo(self:Clip1())
		end

		self.Weapon:EmitSound ( self.Sound )
	
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
 
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Delay )
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Delay )
	 
		
	end

end 
 
function SWEP:Reload()
	
	if ( self:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		
		--self:DefaultReload( ACT_VM_RELOAD )
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) >= self.Primary.ClipSize  then
			self:SetClip1( self.Primary.ClipSize )
			--self.Owner:SetAmmo( self.Owner:GetAmmoCount( self.Primary.Ammo ) - self.Primary.ClipSize, "Battery")
			self.Owner:RemoveAmmo( self.Primary.ClipSize, "Battery")
		else
			self:SetClip1( self.Owner:GetAmmoCount( self.Primary.Ammo ) )
			--self.Owner:SetAmmo( 0 , "Battery")
			self.Owner:RemoveAmmo( self.Owner:GetAmmoCount(self.Primary.Ammo))
		end
	end
	
end
 
 