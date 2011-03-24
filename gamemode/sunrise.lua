-- This Code By Andy Vincent
-- I added a function to set the current minute to the real time of the server.
-- and lengthened the day to make it a little smoother.

local SUNRISE = {}
print("Loading Sunrise Code")
if (CLIENT) then

	hook.Add("Initialize", "SUNRISE:Init",
			function()
				SUNRISE.NextTimeThink = 0
				SUNRISE.LastColor = nil
			end
		)

	hook.Add("Think", "SUNRISE:Think",
			function()
				
				if ( SUNRISE.NextTimeThink > CurTime( ) ) then return; end

				SUNRISE.NextTimeThink = CurTime( ) + 0.1;
				
				if (GetGlobalString("SUNRISE:SkyName") == "") then return end
				
				if (SUNRISE.Materials == nil) then
					local skyname = GetGlobalString("SUNRISE:SkyName")
				
					SUNRISE.Materials = {}
					SUNRISE.Materials[1] = Material("skybox/" .. skyname .. "up")
					SUNRISE.Materials[2] = Material("skybox/" .. skyname .. "dn")
					SUNRISE.Materials[3] = Material("skybox/" .. skyname .. "lf")
					SUNRISE.Materials[4] = Material("skybox/" .. skyname .. "rt")
					SUNRISE.Materials[5] = Material("skybox/" .. skyname .. "bk")
					SUNRISE.Materials[6] = Material("skybox/" .. skyname .. "ft")
					
				end
				
				local skyColor = GetGlobalVector("SUNRISE:SkyMod");
				if (skyColor != SUNRISE.LastColor) then
					for k,v in pairs(SUNRISE.Materials) do
						v:SetMaterialVector("$color", skyColor)
					end
					SUNRISE.LastColor = skyColor
				end
			
			end
		)
	
	return
	
end

local DAY_LENGTH	= 120 * 24
local MORNING		= ( DAY_LENGTH / 4 );
local EVENING		= MORNING * 3;
local MIDDAY		= DAY_LENGTH / 2;
local MORNING_START	= MORNING - (MORNING / 3);
local MORNING_END	= MORNING + (MORNING / 3);
local EVENING_START	= EVENING - (MORNING / 3);
local EVENING_END	= EVENING + (MORNING / 3);
local DAY_START		= 5 * 120
local DAY_END		= 18.5 * 120
local LIGHT_LOW		= string.byte("a")
local LIGHT_HIGH	= string.byte("z")

function GetRealTime()
	local nowTimeHour     = os.date("%H", os.time()) * 120
	local nowTimeMin     = os.date("%M", os.time())
	return nowTimeHour + nowTimeMin
end


function SUNRISE.SetSunTime(minute)

	local LTE = SUNRISE.LightTable[minute]

	if (LTE.Brightness != SUNRISE.LastBrightness) then
		for _, light in pairs( SUNRISE.Lights ) do
			light:Fire( "FadeToPattern", LTE.Brightness, 0 );
			light:Activate()
		end
		SUNRISE.LastBrightness = LTE.Brightness
	end
	
	if (SUNRISE.ShadowControl) then
		SUNRISE.ShadowControl:Fire( "SetDistance", LTE.ShadowLength , 0 );
		SUNRISE.ShadowControl:Fire( "direction", LTE.ShadowAngle , 0 );
		SUNRISE.ShadowControl:Fire( "color", LTE.ShadowColour, 0 );
	end
	
	if ( SUNRISE.Sun ) then
		SUNRISE.Sun:Fire( "addoutput", LTE.SunAngle , 0 );
		SUNRISE.Sun:Activate( );
	end
	
	SetGlobalVector("SUNRISE:SkyMod", LTE.SkyColour)
end

function SUNRISE.CalculateTimeColour(dayminute)

	// default out color to white.
	local red = 1;
	local blue = 1;
	local green = 1;
	
	// golden sunrise calculations.
	if ( dayminute >= 1 && dayminute < MORNING_END ) then
	
		local frac = (dayminute) / (MORNING_END)
		
		if (dayminute < MORNING_START) then

			red = 0
			blue = 0
			green = 0
			
		else
			local frac = (dayminute - MORNING_START) / (MORNING_END - MORNING_START)

			red = frac * 1.5
			green = frac * 1.2
			blue = frac

		end
	end
	
	// red dusk.
	if ( dayminute > EVENING_START && dayminute <= DAY_LENGTH ) then
		local frac = 1 - ((dayminute - EVENING_START) / (EVENING_END - EVENING_START))
		
		if (dayminute > EVENING_END) then
		
			red = 0
			blue = 0
			green = 0
		else
		
			red = frac
			blue = frac * 0.7
			green = frac * 0.8

		end
	end

	// no overflow
	red = math.Clamp(red, 0, 1)
	blue = math.Clamp(blue, 0, 1)
	green = math.Clamp(green, 0, 1)

	return Vector(red,green,blue)
end

function SUNRISE.CalculateShadowColour(dayminute)

	// adjust the shadow color.
	local shadowcolor = 255;
	if ( dayminute > MORNING && dayminute < EVENING ) then
		local frac = 0;
		if ( dayminute < MIDDAY ) then
			local a = dayminute - MORNING;
			local b = MIDDAY - MORNING;
			local frac = ( a / b );
			shadowcolor = math.floor( 255 - ( frac * 127 ) );
		else
			local a = dayminute - MIDDAY;
			local b = EVENING - MIDDAY;
			local frac = ( a / b );
			shadowcolor = math.floor( 128 + ( frac * 127 ) );
		end
	end
	
	return shadowcolor .. " " .. shadowcolor .. " " .. shadowcolor
end
	
function SUNRISE.InitLightTable()

	print("Building Light Table")
	SUNRISE.LightTable = {}
	for n=1, DAY_LENGTH do
		SUNRISE.LightTable[n] = {}
		
		// calculate the percentage of "night sky" or in other words, the amount of
		// alpha to apply to the sky overlay.
		SUNRISE.LightTable[n].Night = math.Clamp( math.abs( ( n - MIDDAY ) / MIDDAY ) , 0 , 0.7 );
		SUNRISE.LightTable[n].SunAngle = (n / DAY_LENGTH) * 360
		SUNRISE.LightTable[n].SunAngle = SUNRISE.LightTable[n].SunAngle + 90
		if (SUNRISE.LightTable[n].SunAngle > 360) then
			SUNRISE.LightTable[n].SunAngle = SUNRISE.LightTable[n].SunAngle - 360
		end
		SUNRISE.LightTable[n].SunAngle = "pitch " .. SUNRISE.LightTable[n].SunAngle
		
		SUNRISE.LightTable[n].ShadowLength = tostring( SUNRISE.LightTable[n].Night * 300 )
		SUNRISE.LightTable[n].ShadowAngle = math.Approach( -1 , 1 , ( MIDDAY / n ) ) .. " 0 -1"
		SUNRISE.LightTable[n].ShadowColour = SUNRISE.CalculateShadowColour(n)

		SUNRISE.LightTable[n].SkyColour = SUNRISE.CalculateTimeColour(n)

		SUNRISE.LightTable[n].Brightness = string.char(LIGHT_LOW)
		if (n >= DAY_START && n < MIDDAY) then
			local progress = (MIDDAY - n) / (MIDDAY - DAY_START)
			local letter_progress = 1 - math.EaseInOut(progress, 0, 1)
						
			local letter = ((LIGHT_HIGH - LIGHT_LOW) * letter_progress) + LIGHT_LOW
			letter = math.ceil(letter)
			letter = string.char(letter)
			
			SUNRISE.LightTable[n].Brightness = letter
		end
		if (n >= MIDDAY && n < DAY_END) then
			local progress = (n - MIDDAY) / (DAY_END - MIDDAY)
			local letter_progress = 1 - math.EaseInOut(progress, 0, 1)
						
			local letter = ((LIGHT_HIGH - LIGHT_LOW) * letter_progress) + LIGHT_LOW
			letter = math.ceil(letter)
			letter = string.char(letter)
			
			SUNRISE.LightTable[n].Brightness = letter
		end
	end
end

hook.Add("EntityKeyValue", "SUNRISE:KeyValue",
		function (ent,key,val)
			if (ent:GetClass() == "light_environment" && key != "targetname") then
				ent:SetKeyValue("targetname", "sunrise_light_" .. ent:EntIndex() )
			end
			
			if (ent:GetClass() == "worldspawn" && key == "skyname") then
				SetGlobalString("SUNRISE:SkyName", val)
			end
			
			if ((ent:GetClass() == "light") or 
			   (ent:GetClass() == "light_spot")) and
			   (key == "targetname") then
					print("Found " .. ent:GetClass())
					if val == "nightlight" then
						print("It's a night light")
						table.insert(SUNRISE.nightlights, ent)
					end
			end
		end
	)

hook.Add("Initialize", "SUNRISE:Init",
		function()
			SUNRISE.InitDone = false
			SUNRISE.InitLightTable()
			SUNRISE.NextTimeThink = 0
			SUNRISE.DayMinute = 0
			SUNRISE.LastBrightness = nil
			SUNRISE.nightlights = {}
			local tempTime = GetRealTime()
			if ((tempTime < DAY_START) or
			    (tempTime > DAY_END)) then
					SUNRISE.nightLight = true
					timer.Simple(5, SUNRISE.lightsOn, SUNRISE)
					print("Lights start on")
			else
					SUNRISE.nightLight = false
					timer.Simple(5, SUNRISE.lightsOff, SUNRISE)
					print("Lights start off")
			end
		end
	)
	
hook.Add("InitPostEntity", "SUNRISE:Init",
		function()
			SUNRISE.Lights = ents.FindByName( "sunrise_light_*" )
			
			SUNRISE.ShadowControl = ents.FindByClass( "shadow_control" )[1]
			if ( !SUNRISE.ShadowControl ) then
				SUNRISE.ShadowControl = ents.Create("shadow_control")
			end
			
			SUNRISE.Sun = ents.FindByClass( "env_sun" )[1] 
			if ( SUNRISE.Sun ) then
				SUNRISE.Sun:SetKeyValue( "material" , 		"sprites/light_glow02_add_noz.vmt" );
				SUNRISE.Sun:SetKeyValue( "overlaymaterial" ,	"sprites/light_glow02_add_noz.vmt" );
			end
			
			SUNRISE.InitDone = true
		end
	)
	
hook.Add("Think", "SUNRISE:Think",
		function()
			if ( !SUNRISE.InitDone ) then return end
			if ( SUNRISE.NextTimeThink > CurTime( ) ) then return; end

			SUNRISE.NextTimeThink = CurTime( ) + 0.03;
			SUNRISE.DayMinute = GetRealTime() --SUNRISE.DayMinute + 1;
			
			if (SUNRISE.DayMinute > DAY_LENGTH) then SUNRISE.DayMinute = 1 end
			
			if ((SUNRISE.DayMinute > DAY_START) and 
			   (SUNRISE.DayMinute < DAY_END)) and SUNRISE.nightLight then
				SUNRISE:lightsOff()
				SUNRISE.nightLight = false
				print("Lights Off")
			end
			
			if ((SUNRISE.DayMinute < DAY_START) or 
			   (SUNRISE.DayMinute > DAY_END)) and 
			   !SUNRISE.nightLight then
				SUNRISE:lightsOn()
				SUNRISE.nightLight = true
				print("Lights On")
			end
			
			SUNRISE.SetSunTime( SUNRISE.DayMinute )
		end
	)
	
	// lights on bitch!
function SUNRISE:lightsOn( )
	// no lights? bail.
	if ( !self.nightlights ) then return; end
	
	// macro function for making the lights flicker.
	local function flicker( ent )
		// pattern.
		local new_pattern;
		
		// randomize it.
		if ( math.random( 1 , 2 ) == 1 ) then
			new_pattern = 'az';
		else
			new_pattern = 'za';
		end
		
		// random delay.
		local delay = math.random( 0 , 400 ) * 0.01;
		
		// flicker the light on.
		ent:Fire( 'SetPattern' , new_pattern , delay );
		ent:Fire( 'TurnOn' , '' , delay );
		
		// delay the sound.
		timer.Simple( delay , function( ) ent:EmitSound( 'buttons/button1.wav' , math.random( 70 , 80 ) , math.random( 95 , 105 ) ) end );
		
		// delay for solid pattern.
		delay = delay + math.random( 10 , 50 ) * 0.01;
		
		// set solid pattern.
		ent:Fire( 'SetPattern' , 'z' , delay );
	end
	
	// loop through lights and turn um on.
	local light;
	for _ , light in pairs( self.nightlights ) do
		flicker( light );
	end
end


// lights out!
function SUNRISE:lightsOff( )
	// no lights?
	if ( !self.nightlights ) then return; end
	
	// loop through lights and turn um off.
	local light;
	for _ , light in pairs( self.nightlights ) do
		light:Fire( 'TurnOff' , '' , 0 );
	end
end
print("Loaded Sunrise Code")