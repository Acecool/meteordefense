-- Gamemode Base Functions -- Rounds
-- ========================================================================================
--   Hooks:
--			PreRound : This is called every 5 seconds before the round starts (setup for a round)
--				Variables : Players (table) , TimeUntilStart (number)
--
--	          Hook Example: Will print the time till round start for every player.
--  	        	hook.Add("PreRound", "myPreRound", function ( plys, time ) for k, v in pairs(plys) do v:ChatPrint("Round Starting in " .. tostring(time)) end )
--
--			RoundStart : This is called once when the timer for the round starts 
--				Variables : Players
--
--      	    Hook Example: Will print "Round Started!" for every player.
--          		hook.Add("RoundStart", "myRoundStart", function ( plys ) for k, v in pairs(plys) do v:ChatPrint("Round Started!") end )
--
--			RoundEnd : This is called once as the round ends (timer hits)
--				Variables : Players
--
--          	Hook Example: Will print "Round Finished!" for every player.
--          		hook.Add("RoundEnd", "myRoundEnd", function ( plys ) for k, v in pairs(plys) do v:ChatPrint("Round Finished!") end )
--
--			PostRound : This is called every 5 seconds after the round has ended ( for score stuff)
--				Variables : Players, TimeUntilEnd
--
--       	   Hook Example: Will print the time till PreRound start for every player.
--          		hook.Add("PreRound", "myPreRound", function ( plys, time ) for k, v in pairs(plys) do v:ChatPrint("Pre Round Will start In " .. tostring(time)) end )

--	 Functions:
--			* All time is in seconds
--			SetPreRoundTime( time ) - Sets the Current Length of the PreRound
--			GetPreRoundTime() - Gets the Current Length of the PreRound
--
--			SetPreRoundInterval( time) -- Sets the Callback Rate on the PreRound
--			GetPreRoundInterval() -- Gets the Callback Rate on the PreRound
--
--			SetRoundTime( time ) - Sets the Length of the round (must be set before the Round starts, if set durring the round it will affect the next round)
--			GetRoundTime() - Gets the Current Round Length
--
--			SetPostRoundTime( time ) - Sets the length of the PostRound
--			GetPostRoundTime() - Gets the length of the PostRound
--
--			SetPostRoundInterval( time ) - Set the Callback Rate on the PostRound
-- 			GetPostRoundInterval() - Gets the Callback Rate on the PostRound
--
--			DidPreOnce() - Returns true if the Current PreRound has been called once
--			DidPostOnce() - Return true if the Current PostRound has been called once
--
--			StartRound() - forces round to start
--			EndRound() - forces end of round
--			
--			RoundTimeRemaining() - Returns the time left in the round, or -1 if no round is running.
--

if !SERVER then return end

-- Cleanup incase we are reloading the script
if timer.IsTimer("iPreRoundTimer") then timer.Remove("iPreRoundTimer") end
if timer.IsTimer("iRoundTimer") then timer.Remove("iRoundTimer") end
if timer.IsTimer("iPostRoundTimer") then timer.Remove("iPostRoundTimer") end

-- Internal Variables with Default Values
iPreRoundTime = 90
iPreRoundInterval = 5
iRoundTime = 120 
iRoundStarted = -1
iPostRoundTime = 90
iPostRoundInterval = 5
iPlayers = {}
iPreRan = false
iPostRan = false

-- Exposed Functions
function DidPreOnce() return iPreRan end -- Used to Check if it the first PreRound call
function DidPostOnce() return iPostRan end -- Used to Check if it's the first PostRound call
function RoundPercentComplete() return 1 - (RoundTimeRemaining() / iRoundTime) end -- Returns the percent in decimal form of the round that is completed
function RoundPercentCompleteR() return (RoundTimeRemaining() / iRoundTime) end -- Returns the percent in decimal form of the round that is completed

-- Force Round Start
function StartRound() 
	timer.Remove("iPreRoundTimer")
	iRoundStart() 
end

-- Force Round End
function EndRound() 
	timer.Remove("iRoundTimer")
	iRoundEnd() 
end

-- Set/Get the length of the PreRound
function SetPreRoundTime( time ) 
	if (time >= 0) and !(time == nil) then
		iPreRoundTime = time
	end
end
function GetPreRoundTime() return iPreRoundTime end

-- Check Time Remaining in the Round
function RoundTimeRemaining()

	if iRoundStarted == -1 then return 0 end
	return iRoundTime - (CurTime() - iRoundStarted)
	
end

-- Set/Get Pre Round Call Interval
function SetPreRoundInterval( time ) 
	if (time >= 0) and !(time == nil) then
		iPreRoundInterval = time
	end
end
function GetPreRoundInterval() return iPreRoundInterval end

-- Set/Get Round Time
function SetRoundTime( time ) 
	if (time >= 0) and !(time == nil) then
		iRoundTime = time
	end
end
function GetRoundTime() return iRoundTime end

-- Set/Get Length of the Post Round.
function SetPostRoundTime( time ) 
	if (time >= 0) and !(time == nil) then
		iPostRoundTime = time
	end
end
function GetPostRoundTime() return iPostRoundTime end

-- Set/Get PostRound Call Interval
function SetPostRoundInterval( time ) 
	if (time >= 0) and !(time == nil) then
		iPostRoundInterval = time
	end
end
function GetPostRoundInterval() return iPostRoundInterval end


-- Quick Hooks they keep track of the players playing
hook.Add( "PlayerInitialSpawn", "fanPlayerInitialSpawn", function ( ply ) table.insert( iPlayers, ply ) end )
hook.Add( "PlayerDisconnected", "fanPlayerDisconnected", function ( ply ) table.remove(iPlayers, IndexFromValue(ply)) end )

-- Internal Functions

-- Cleans Bad Entries From the player table
function iCleanTable( tbl )
	
	if table.Count(tbl) < 1 then return end
	for k, v in pairs(tbl) do
		if !v:IsValid() or
		   (v == nil) or
		   (v == NULL) then 
			table.remove(tbl, k)
		end
	end
	
end

-- Get an Index from a table by value
function IndexFromValue( tbl, value )
	for k,v in pairs(tbl) do
		if v == value then return k end
	end
	
	return nil
end

function iPreRound( time )
	
	iPostRan = false
	
	if time >= iPreRoundTime then
		time = 0
		timer.Remove("iPreRoundTimer")
		iRoundStart()
	else
		iCleanTable(iPlayers)
		hook.Call( "PreRound", nil, iPlayers, iPreRoundTime - time)
		iPreRan = true
		timer.Remove("iPreRoundTimer")
		timer.Create("iPreRoundTimer", iPreRoundInterval, 0, iPreRound, time + iPreRoundInterval )
	end
end

function iRoundStart()
	
	iPreRan = false
	
	iRoundStarted = CurTime()
	
	if !timer.IsTimer("iRoundTimer") then
		timer.Create("iRoundTimer", iRoundTime, 0, iRoundEnd )
	end
	
	iCleanTable(iPlayers)
	hook.Call( "RoundStart", nil, iPlayers )
	
end

function iRoundEnd()

	iRoundStarted = -1
	timer.Remove("iRoundTimer")
	
	iCleanTable(iPlayers)
	hook.Call( "RoundEnd", nil, iPlayers )
	
	iPostRound( 0 )
	
end

function iPostRound( time )
	
	if time >= iPostRoundTime then
		time = 0 
		timer.Stop("iPostRoundTimer")
		iPreRound( 0 )
	else
		iCleanTable(iPlayers)
		hook.Call( "PostRound", nil, iPlayers, iPostRoundTime - time)
		iPostRan = true
		timer.Remove("iPostRoundTimer")
		timer.Create("iPostRoundTimer", iPostRoundInterval, 0, iPostRound, time + iPostRoundInterval)
	end
	
end

-- After Everything is loaded start the round cycle
iPreRound( 0 )
