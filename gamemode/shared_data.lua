-- Buyable Props

props = {}

--By Cost Cheap To Expensive
table.insert(props, { "Wood Door", "models/props_doors/door03_slotted_left.mdl", 100 } )
table.insert(props, { "Metal Door", "models/props_c17/door01_left.mdl", 200 } )
table.insert(props, { "Metal Ship's Door", "models/props_borealis/borealis_door001a.mdl", 250 } )
table.insert(props, { "RT Screen", "models/props_phx/rt_screen.mdl", 250 } )
table.insert(props, { "Metal Panel", "models/props_debris/metal_panel02a.mdl", 300 } )
table.insert(props, { "Dumpster Lid", "models/props_junk/TrashDumpster02b.mdl", 350 } )
table.insert(props, { "Small Blast Door", "models/props_lab/blastdoor001a.mdl", 450 } )
table.insert(props, { "PHX 4x4 Metal Plate", "models/props_phx/construct/metal_plate4x4.mdl", 500 } )
table.insert(props, { "Large Blast Door", "models/props_lab/blastdoor001c.mdl", 550 } )
table.insert(props, { "PHX 4x4x0.5", "models/hunter/blocks/cube4x4x05.mdl", 1100 } )
table.insert(props, { "PHX 4x6x0.5", "models/hunter/blocks/cube4x6x05.mdl", 2300 } )
table.insert(props, { "Lockers", "models/props_c17/Lockers001a.mdl", 5250 } )
table.insert(props, { "PHX 8x8x0.5", "models/hunter/blocks/cube8x8x05.mdl", 7450 } )
table.insert(props, { "Cargo Container", "models/props_wasteland/cargo_container01b.mdl", 23850 } )

entities = {}
table.insert(entities, { "Laser Turret Lvl 1", "models/laser_turret.mdl", "laser_turret", 512, 70, 10000 })
table.insert(entities, { "Laser Turret Lvl 2", "models/laser_turret.mdl", "laser_turret", 640, 85, 14000 })
table.insert(entities, { "Laser Turret Lvl 3", "models/laser_turret.mdl", "laser_turret", 768, 100, 18000 })
table.insert(entities, { "Laser Turret Lvl 4", "models/laser_turret.mdl", "laser_turret", 896, 115, 22000 })
table.insert(entities, { "Laser Turret Lvl 5", "models/laser_turret.mdl", "laser_turret", 1024, 130, 26000 })
table.insert(entities, { "Laser Turret Lvl 6(Max)", "models/laser_turret.mdl", "laser_turret", 2048, 260, 52000 })


tools = {}
table.insert(tools, { "Axis" , "axis" } )
table.insert(tools, { "Weld" , "weld" } )
table.insert(tools, { "EZ Weld" , "weld_ez" } )
table.insert(tools, { "Smart Weld", "smartwelder" } )
table.insert(tools, { "Rope" , "rope" } )
table.insert(tools, { "Elastic" , "elastic" } )
table.insert(tools, { "Hydraulic", "hydraulic" } )
table.insert(tools, { "Winch" , "winch" } )
table.insert(tools, { "No Collide" , "nocollide" } )
table.insert(tools, { "Ballsocket" , "ballsocket" } )
table.insert(tools, { "EZ Ballsocket" , "ballsocket_ez" } )
table.insert(tools, { "Physical Properties" , "physprop" } )
table.insert(tools, { "Color" , "colour" } )
table.insert(tools, { "Material" , "material" } )
table.insert(tools, { "Camera" , "camera" } )
table.insert(tools, { "RT Camera" , "rtcamera" } )

toolAll = { "camera", "rtcamera" }

toolAllowed = {}
for k,v in pairs(tools) do
	table.insert(toolAllowed, v[2])
end