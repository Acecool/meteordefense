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

WeaponsShop = {
				{"weapon_pistol", 100},
				{"weapon_crowbar",50},
				{"weapon_357", 200}, 
				{"weapon_smg1",300},
				{"weapon_ar2",500},
				{"weapon_frag", 250}				
			}

AmmoShop = {
			 {"AR2", 20, 30},			 
			 {"Pistol", 20, 10},
			 {"SMG1", 20, 20},
			 {"357", 10, 15},
			 {"XBowBolt", 5, 100},
			 {"Buckshot", 8, 5},
			 {"RPG_Round", 1, 300},
			 {"SMG1_Grenade", 1, 150},
			 {"Grenade", 1, 250},
			 {"AR2AltFire", 1, 600}			 
			}
			
ItemShop = {
			 {"weapon_healthkit", 30}
		    }


function purchWeapon( ply, cmd, args )
	
	ItemClass = args[1]
	ItemIndex = IndexByValue(WeaponsShop, ItemClass, 1)
	if ItemIndex == nil then 
		print("Invaid Item!")
		return 
	end
	ItemCost = WeaponsShop[ItemIndex][2]
	print("Player " .. tostring(ply) .. " wants to buy a " .. ItemClass .. ". A " .. ItemClass .. " Costs " .. ItemCost .. " Credits.")

	if ply.Credits >= ItemCost then
		if !(ply:HasWeapon(ItemClass)) then
			ply:Give(ItemClass)
			ply.Credits = ply.Credits - ItemCost
			print("Item Purchased!!")
		elseif ItemClass == "weapon_frag" then
			purchAmmo(ply, "purchAmmo", {"Grenade"})
		else
			print("You already have one!")
		end
	else
		print("Sorry not enough credits!")
	end
	
	
end
concommand.Add("purchWeapon", purchWeapon)

function purchAmmo( ply, cmd, args )
	
	ItemClass = args[1]
	ItemIndex = IndexByValue(AmmoShop, ItemClass, 1)
	if ItemIndex == nil then 
		print("Invaid Item!")
		return 
	end
	ItemCost = AmmoShop[ItemIndex][3]
	print("Player " .. tostring(ply) .. " wants to buy a " .. ItemClass .. ". A " .. ItemClass .. " Costs " .. ItemCost .. " Credits.")

	if ply.Credits >= ItemCost then
		ply:GiveAmmo( AmmoShop[ItemIndex][2], ItemClass )
		ply.Credits = ply.Credits - ItemCost
		print("Item Purchased!!")
	else
		print("Sorry not enough credits!")
	end
	
	
end
concommand.Add("purchAmmo", purchAmmo)

function purchItem( ply, cmd, args )
	
	ItemClass = args[1]
	ItemIndex = IndexByValue(ItemShop, ItemClass, 1)
	if ItemIndex == nil then 
		print("Invaid Item!")
		return 
	end
	ItemCost = ItemShop[ItemIndex][2]
	print("Player " .. tostring(ply) .. " wants to buy a " .. ItemClass .. ". A " .. ItemClass .. " Costs " .. ItemCost .. " Credits.")

	if ply.Credits >= ItemCost then
		
		if ItemClass == "weapon_healthkit" then
			print(tostring(ply:HasWeapon("weapon_healthkit")))
			if ply:HasWeapon("weapon_healthkit") then
				ply:GiveAmmo("GaussEnergy",1)
			else
				ply:Give( ItemShop[ItemIndex][1], ItemClass )
			end
		else
			ply:Give( ItemShop[ItemIndex][1], ItemClass )
		end
		
		ply.Credits = ply.Credits - ItemCost
		print("Item Purchased!!")
	else
		print("Sorry not enough credits!")
	end
	
	
end
concommand.Add("purchItem", purchItem)


					  
function ENT:Initialize()
 
    self.model = self.model or "models/humans/group02/female_03.mdl"
	
	self:SetModel( self.model )
     
    self:SetHullSizeNormal()
    self:SetHullType( HULL_HUMAN )
	
    --[[
		NPC_STATE_INVALID = -1
		NPC_STATE_NONE = 0
		NPC_STATE_IDLE = 1
		NPC_STATE_ALERT = 2
		NPC_STATE_COMBAT = 3
		NPC_STATE_SCRIPT= 4
		NPC_STATE_PLAYDEAD= 5
		NPC_STATE_PRONE= 6
		NPC_STATE_DEAD= 7
	--]]
	
	self:SetNPCState( NPC_STATE_IDLE )
 
    self:SetSolid( SOLID_BBOX ) 
    self:SetMoveType( MOVETYPE_NONE )
    self:CapabilitiesAdd( CAP_ANIMATEDFACE | 
	                      CAP_TURN_HEAD )
						 
    self:SetUseType( SIMPLE_USE )
	
	self:AddRelationship("player D_LI 99")
	
	
    self:DropToFloor()
	self:SetHealth(420)
	self:SetMaxHealth(420)
	self.shop_type = self.shop_type or 0
	self.LastRndAct =  CurTime()
	
end
 
function ENT:Think()
	
	if CurTime() > (self.LastRndAct + 2) then
		rndVal = math.random(1, 100)
		if rndVal > 25 and rndVal < 75 then
		
			rndVal2 = math.random(1, 5)

			if rndVal2 == 1 then	self:SetSchedule(SCHED_SMALL_FLINCH) end
			if rndVal2 == 2 then	self:SetSchedule(SCHED_COMBAT_SWEEP) end
			if rndVal2 == 3 then	self:SetSchedule(SCHED_FEAR_FACE) end
			if rndVal2 == 4 then	self:SetSchedule(SCHED_ALERT_FACE_BESTSOUND) end
			if rndVal2 == 5 then
				plyTable = ents.FindInSphere( self:GetPos(), 512 )
				rndVal3 = math.random(1, table.Count(plyTable))
				self:SetTarget(plyTable[rndVal3])
				self:SetSchedule(SCHED_TARGET_FACE)
			end
				
		
		end
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

function ENT:OnTakeDamage( dmginfo)
	
	print("this is being called")
	dmginfo:SetDamage(0)

end
 

 
function ENT:AcceptInput( Name, Activator, Caller ) 
    
	if( Name == "Use" ) and CurTime() >= (Activator.LastUse or 0) + 3 then
        Activator.LastUse = CurTime()

		print("Welcome To The Shop")
		
		self:SetTarget(Activator)
		self:SetSchedule(SCHED_TARGET_FACE)
		
		umsg.Start ("ShowShop", Activator)
			umsg.Long(1)
		umsg.End()
		
		
        
	else
		umsg.Start ("ShowHint", Activator)
			umsg.String("Please Wait!")
		umsg.End()
    end
	
end

