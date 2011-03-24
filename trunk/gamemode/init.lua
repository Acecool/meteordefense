DeriveGamemode("sandbox")
include("round_code.lua")
include("shared_data.lua")
include("shared_code.lua")
include("server_code.lua")
include("sunrise.lua")
include("pdmg_exclusions.lua")
include("pdmg.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared_data.lua")
AddCSLuaFile("shared_code.lua")
AddCSLuaFile("cl_menus.lua")
AddCSLuaFile("client_code.lua")
AddCSLuaFile("sunrise.lua")
AddCSLuaFile("pdmg.lua")
AddCSLuaFile("pdmg_exclusions.lua")

-- Map
resource.AddFile( "maps/" .. game.GetMap() .. ".bsp" );

-- Models
resource.AddFile( "models/meteors/meteor_5.mdl")
resource.AddFile( "models/meteors/meteor_4.mdl")
resource.AddFile( "models/meteors/meteor_3.mdl")
resource.AddFile( "models/meteors/meteor_2.mdl")
resource.AddFile( "models/meteors/meteor_1.mdl")
resource.AddFile( "models/laser_turret.mdl")
resource.AddFile( "models/shield_gen/gen.mdl")

-- Materials
resource.AddFile( "materials/models/laser_turret/dev_corrugatedmetal.vmt")
resource.AddFile( "materials/models/laser_turret/metalfloor005a.vmt")
resource.AddFile( "materials/models/meteors/rockslide01a.vmt" )
resource.AddFile( "materials/models/shield_gen/citadel_metalwall078a.vmt" )
resource.AddFile( "materials/models/shield_gen/dev_lowerwallmetal01d.vmt" )
resource.AddFile( "materials/models/shield_gen/glasswindow018a_cracked.vmt" )
resource.AddFile( "materials/models/shield_gen/metalwall048a.vmt" )

-- Sound
resource.AddFile( "sound/low_energy.wav" )
resource.AddFile( "sound/shield_activated.wav" )
resource.AddFile( "sound/shield_deactivated.wav" )
resource.AddFile( "sound/shield_failure.wav" )
resource.AddFile( "sound/cooling_failure.wav" )
resource.AddFile( "sound/incoming_detected.wav" )