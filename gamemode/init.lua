DeriveGamemode("sandbox")
include("round_code.lua")
include("shared_data.lua")
include("shared_code.lua")
include("server_code.lua")
--include("daytime.lua")
include("sunrise.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared_data.lua")
AddCSLuaFile("shared_code.lua")
AddCSLuaFile("cl_menus.lua")
AddCSLuaFile("client_code.lua")
AddCSLuaFile("sunrise.lua")


resource.AddFile( "maps/" .. game.GetMap() .. ".bsp" );

resource.AddFile( "models/meteors/meteor5.mdl")
resource.AddFile( "models/meteors/meteor4.mdl")
resource.AddFile( "models/meteors/meteor3.mdl")
resource.AddFile( "models/meteors/meteor2.mdl")
resource.AddFile( "models/meteors/meteor1.mdl")
resource.AddFile( "models/laser_turret.mdl")
resource.AddFile( "materials/models/laser_turret/dev_corrugatedmetal.vmt")
resource.AddFile( "materials/models/laser_turret/metalfloor005a.vmt")
resource.AddFile( "materials/models/meteors/rockfloor003a.vmt" )
--resource.AddFile( "sound/meteor_flight1.wav" )
