if !CLIENT then return end

cInside = "amd"
MeteorMenu = "bah"

showCMenu = false
showQMenu = false
allowMenu = true
allowTime = CurTime()
keyNextThink = CurTime()

function checkAllKeys()
	for i = 0, 159 do 
		if input.IsKeyDown(i) then
			print("Key " .. tostring(i) .. " is pressed.")
		end
	end
end

function GM:StartChat(TeamSay)
	--return true -- Return true to hide the chatbox
	allowMenu = false
end
--hook.Add("StartChat", "fanStartChatBox", StartChat)

function GM:FinishChat(TeamSay)
	--return true -- Return true to hide the chatbox
	allowMenu = true
end
hook.Add("FinishChat", "fanFinishChat", FinishChat)

function fanKeyPressed()
	
	--checkAllKeys()
	--[[if (input.IsKeyDown(KEY_BACKQUOTE) or 
	   input.IsKeyDown(KEY_U)or
	   input.IsKeyDown(KEY_Y)) and
	   CurTime() - allowTime > 0.3 then
		allowMenu = !allowMenu
		allowTime = CurTime()
		
	end--]]
		
	if allowMenu and (CurTime() > keyNextThink) then
		if input.IsKeyDown(KEY_C) and
			!showCMenu and 
			!inRound then 
			if LocalPlayer():GetActiveWeapon():IsValid() then
				if LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool" then
					--print("Context Menu Open")

					local curMode = LocalPlayer():GetActiveWeapon().current_mode
					if curMode == nil then return end
					spawnmenu.AddContext("Options", "ToolsOptions_" .. curMode, "Tools Options", "Tools Options Menu")
					cInside = GetControlPanel("ToolsOptions_" .. curMode)
					cInside:ClearControls()
					cInside.VertPos = 5
					
					cInside:SetSize(275, 800)
					cInside:SetPos(ScrW() - 290, 0)
					
					--print(tostring(LocalPlayer():GetActiveWeapon().Tool[curMode].BuildCPanel))
					
					if !(LocalPlayer():GetActiveWeapon():GetTable()['Tool'][curMode].BuildCPanel == nil) then
						LocalPlayer():GetActiveWeapon():GetTable()['Tool'][curMode].BuildCPanel(cInside)
					else
						--print("curMode: " .. tostring(curMode))
						toolContextFromFile(curMode, cInside)
					end
					cInside:SetText(curMode)
					cInside:PerformLayout()				
					cInside:SetVisible(true)
					if cInside.once == nil then
						cInside.once = true
						cInside:MakePopup()
					end
					showCMenu = true
				end
			end
		elseif showCMenu and
			!input.IsKeyDown(KEY_C) then
			--print("Context Menu Closed")
			--print(cInside)
			cInside:SetVisible(false)
			--cInside:Close()
			showCMenu = false
		end
		
		if allowMenu and (CurTime() > keyNextThink) and
		   input.IsKeyDown(KEY_Q) and
			!showQMenu and
			!inRound then 
				--print("Spawn Menu Open")
				RestoreCursorPosition( )			
				local claimPropButton
				local sellPropertyButton
				local buyPropertyButton
				local sellPropButton
				local actionPanel
				local DButton1
				local toolLabel
				local actionLabel
				local toolPanel
				local propLabel
				local propPanel
				
				
				MeteorMenu = vgui.Create('DFrame')
				MeteorMenu:SetSize(513, 408)
				MeteorMenu:Center()
				MeteorMenu:SetTitle('Meteor Defense Menu')
				MeteorMenu:SetDeleteOnClose(false)
				
		
				--Panel's	
				propPanel = vgui.Create('DPanel')
				--propPanel:SetParent(MeteorMenu)
				propPanel:SetSize(208, 335)
				--propPanel:SetPos(10, 55)
				--propPanel:SetPos(0, 0)
				
				entityPanel = vgui.Create('DPanel')
				entityPanel:SetSize(208,335)
				
				toolPanel = vgui.Create('DPanel')
				toolPanel:SetParent(MeteorMenu)
				toolPanel:SetSize(135, 335)
				toolPanel:SetPos(223, 55)

				actionPanel = vgui.Create('DPanel')
				actionPanel:SetParent(MeteorMenu)
				actionPanel:SetSize(140, 335)
				actionPanel:SetPos(363, 55)
				
				--Labels
				--[[propLabel = vgui.Create('DLabel')
				propLabel:SetParent(MeteorMenu)
				propLabel:SetPos(10, 38)
				propLabel:SetText('Props')
				propLabel:SizeToContents()	
				--]]
				
				iconSheet = vgui.Create('DPropertySheet', MeteorMenu)
				iconSheet:SetPos(10,34)
				iconSheet:SetSize(210,356)
				
				toolLabel = vgui.Create('DLabel')
				toolLabel:SetParent(MeteorMenu)
				toolLabel:SetPos(223, 38)
				toolLabel:SetText('Tools')
				toolLabel:SizeToContents()

				actionLabel = vgui.Create('DLabel')
				actionLabel:SetParent(MeteorMenu)
				actionLabel:SetPos(363, 38)
				actionLabel:SetText('Actions')
				actionLabel:SizeToContents()
				
				-- Spawn Icons
				local rowCount = 0
				local rowOffset = 10
				local perCol = 3
				local colCount = 0
				local colOffset = 10
				local spawnIconWidth = 62
				local spawnIconHeight = 62
				
				for k,v in pairs(props) do
				
					local spawnIcon = vgui.Create('SpawnIcon')
					spawnIcon:SetModel(v[2])
					spawnIcon:SetParent(propPanel)
					spawnIcon:SetPos((colOffset + ( colCount * spawnIconWidth)), (rowOffset + ( rowCount * spawnIconHeight)))
					local toolTip = v[1] .. " \n " .. "Cost: " .. tostring(v[3])
					spawnIcon:SetToolTip( toolTip )
					spawnIcon.OnMousePressed = function() RunConsoleCommand("fan_buy", k) end
					spawnIcon.OnMouseReleased = function() RememberCursorPosition( ) MeteorMenu:Close() end
					
					colCount = colCount + 1
					if colCount == perCol then
						colCount = 0
						rowCount = rowCount +1
					end
					
				end	
				
				rowCount = 0
				colCount = 0
				
				for k,v in pairs(entities) do
				
					local spawnIcon = vgui.Create('SpawnIcon')
					spawnIcon:SetModel(v[2])
					spawnIcon:SetParent(entityPanel)
					spawnIcon:SetPos((colOffset + ( colCount * spawnIconWidth)), (rowOffset + ( rowCount * spawnIconHeight)))
					local toolTip = v[1] .. " \n " 
										 .. "Radius: " .. tostring(v[4]) .. "\n"
										 .. "Energy: " .. tostring(v[5]) .. "\n"
										 .. "Cost: " .. tostring(v[6]) .. "\n"
					spawnIcon:SetToolTip( toolTip )
					spawnIcon.OnMousePressed = function() RunConsoleCommand("fan_buy", v[3], k ) end
					spawnIcon.OnMouseReleased = function() RememberCursorPosition( ) MeteorMenu:Close() end
					
					colCount = colCount + 1
					if colCount == perCol then
						colCount = 0
						rowCount = rowCount +1
					end
					
				end	
				
				iconSheet:AddSheet("Props", propPanel, "gui/silkicons/toybox", false, false, "Things to build with.")
				iconSheet:AddSheet("Entities", entityPanel, "gui/silkicons/shield", false, false, "Things to help defend.")
				
				-- Tools
				local toolCount = 0
				local sidePad = 5
				local topPad = 5
				
				for k, v in pairs(tools) do
				
					local toolButton = vgui.Create('DButton')
					toolButton:SetParent(toolPanel)
					toolButton:SetSize(125, 19)
					toolButton:SetPos(sidePad, topPad + (toolCount * 19))
					toolButton:SetText(v[1])
					toolButton.DoClick = function() RunConsoleCommand("gmod_tool", v[2]) RememberCursorPosition( ) MeteorMenu:Close() end
					toolCount = toolCount + 1
				
				end

				-- Action Buttons
				buyPropertyButton = vgui.Create('DButton')
				buyPropertyButton:SetParent(actionPanel)
				buyPropertyButton:SetSize(130, 25)
				buyPropertyButton:SetPos(5, 5)
				buyPropertyButton:SetText('Buy Property')
				buyPropertyButton.DoClick = function() RunConsoleCommand("fan_buy", "property") RememberCursorPosition( ) MeteorMenu:Close() end

				sellPropertyButton = vgui.Create('DButton')
				sellPropertyButton:SetParent(actionPanel)
				sellPropertyButton:SetSize(130, 25)
				sellPropertyButton:SetPos(5, 35)
				sellPropertyButton:SetText('Sell Property')
				sellPropertyButton.DoClick = function() RunConsoleCommand("fan_sell", "property") RememberCursorPosition( ) MeteorMenu:Close() end

				claimPropButton = vgui.Create('DButton')
				claimPropButton:SetParent(actionPanel)
				claimPropButton:SetSize(130, 25)
				claimPropButton:SetPos(5, 65)
				claimPropButton:SetText('Claim Un-Owned Prop')
				claimPropButton.DoClick = function() RememberCursorPosition( ) MeteorMenu:Close() RunConsoleCommand("claim_prop") end
				
				unClaimPropButton = vgui.Create('DButton')
				unClaimPropButton:SetParent(actionPanel)
				unClaimPropButton:SetSize(130, 25)
				unClaimPropButton:SetPos(5, 95)
				unClaimPropButton:SetText('Un-own Prop')
				unClaimPropButton.DoClick = function() RememberCursorPosition( ) MeteorMenu:Close() RunConsoleCommand("unclaim_prop") end
				
				sellPropButton = vgui.Create('DButton')
				sellPropButton:SetParent(actionPanel)
				sellPropButton:SetSize(130, 25)
				sellPropButton:SetPos(5, 125)
				sellPropButton:SetText('Sell Prop')
				sellPropButton.DoClick = function() RememberCursorPosition( ) MeteorMenu:Close() RunConsoleCommand("fan_sell", "prop") end
				
				healAmmoButton = vgui.Create('DButton')
				healAmmoButton:SetParent(actionPanel)
				healAmmoButton:SetSize(130, 25)
				healAmmoButton:SetPos(5, 155)
				healAmmoButton:SetToolTip("200 Heal Ammo for 300 Credits")
				healAmmoButton:SetText('Buy Heal Ammo')
				healAmmoButton.DoClick = function() RememberCursorPosition( ) MeteorMenu:Close() RunConsoleCommand("fan_buy", "ha") end
				
				sellAllButton = vgui.Create('DButton')
				sellAllButton:SetParent(actionPanel)
				sellAllButton:SetSize(130, 25)
				sellAllButton:SetPos(5, 185)
				sellAllButton:SetToolTip("Careful! This sells *ALL* your props")
				sellAllButton:SetText('Sell All Props')
				sellAllButton.DoClick = function() RememberCursorPosition( ) MeteorMenu:Close() RunConsoleCommand("fan_sell", "allprops") end
				
				transCreditsButton = vgui.Create('DButton')
				transCreditsButton:SetParent(actionPanel)
				transCreditsButton:SetSize(130, 25)
				transCreditsButton:SetPos(5, 215)
				transCreditsButton:SetToolTip("Transfer Credits to Aimed at player")
				transCreditsButton:SetText('Transfer Credits')
				transCreditsButton.DoClick = function() RememberCursorPosition( ) MeteorMenu:Close() RunConsoleCommand("fan_cred", "trans", transCreditsSlider:GetValue() ) end
				
				transCreditsSlider = vgui.Create('DNumSlider')
				transCreditsSlider:SetParent(actionPanel)
				transCreditsSlider:SetPos(5,260)
				transCreditsSlider:SetSize(130,35)
				transCreditsSlider:SetMin(1)
				transCreditsSlider:SetMax(credits)
				transCreditsSlider:SetDecimals(0)
				transCreditsSlider:SetText('Trans. Amt.')
				
				MeteorMenu:SetVisible(true)
				if MeteorMenu.once == nil then
					MeteorMenu.once = true
					MeteorMenu:MakePopup()
				end
				showQMenu = true

			
		elseif showQMenu and
			!input.IsKeyDown(KEY_Q) then
			--print("Spawn Menu Closed")
			RememberCursorPosition()
			MeteorMenu:SetVisible(false)
			MeteorMenu:Close()
			showQMenu = false
		end
	keyNextThink = CurTime() + 0.25
	end
end
hook.Add( "Think", "fanKeyPressed", fanKeyPressed )


function fanWelcome()

	local dlWelcomeHTML
	local dbPlay
	local dfWelcome

	dfWelcome = vgui.Create('DFrame')
	dfWelcome:SetSize(ScrW(), ScrH() - (ScrH() * 0.25))
	dfWelcome:Center()
	dfWelcome:SetTitle('Welcome To Meteor Defense')
	dfWelcome:SetSizable(false)
	dfWelcome:SetDeleteOnClose(false)
	--dfWelcome:SetBackgroundBlur(true)
	dfWelcome:MakePopup()

	dlWelcomeHTML = vgui.Create('HTML')
	dlWelcomeHTML:SetParent(dfWelcome)
	dlWelcomeHTML:SetPos(5, 25)
	dlWelcomeHTML:SetSize(dfWelcome:GetWide() - 5, dfWelcome:GetTall() - (dfWelcome:GetTall() * 0.1))
	dlWelcomeHTML:SetHTML([[
    <html>
    <body>	
	<pre>
	This is a work in progress, things change and restarts are needed.

	If you'd like to help type <strong>!bug</strong> in the chat and then what you think is wrong, or
	if you have a suggestion you can leave it here too.
	
	Examples: !bug I think you should add lasers!
	          !bug I got a lua error on line 93, myBalls is nil
			  
	<strong>I also added a !stuck command if you get stuck in something</strong>
	<strong>Basic Gameplay</strong>
	--------
	You start in a protected spawn, and the game has 2 phases
	  Phase 1 - Build/Buy/Manage - This is when you build and repair your shelter
	  Phase 2 - Meteor Attack - Take Cover and try not to die.
	
	Phase 1 Equipment - Physgun, Tool Gun, and Prop Heal SWEP
	1. Physgun - Very helpful in building things
	2. Tool Gun - Also helpful in building things
	3. Prop Heal SWEP - Primary fire heals a small amount taking 1 ammo
	                    Secondary fire heals a larger amount taking the rest of the current clip.
	
	Phase 2 Equipment - NONE

	<strong>Areas</strong>
	-----
	The Yellow Areas are public build area's anyone can build here.
	The Green Areas are Ownable, explained more below.
	
	<strong>Prop Buying and other functions</strong>
	-------------------------------
	You can press your normal spawnmenu bind key usually Q to bring up the menu.
	Props are on the left, tools in the middle and actions on the right.
	Props have the cost in the tool tip, and tools are free.
	
	<strong>Actions</strong>
	-------
	1. Buy Property --  If you are in a green area box the price and upkeep are
	                    displayed in your chat.  Clicking this button will purchase 
					    the property you are currently in. After buying property you
					    and you alone may build on it. Upkeep is taken every 6 min.
	2. Sell Property -- If you are in an area you own clicking this button will sell
	                    the property back to the world and you'll recieve half it's 
						value.  If you sell a property with props still on it they will
						be garbage collected. If you disconnect property you own is 
						automatically sold.
	3. Claim Un-onwed prop --  When you disconnect not all of you're props will disappear
							   some will become un-owned.  If you see an un-owned prop you
							   may use this button to take ownership.
	4. Sell Prop -- Sells the prop you are looking at if you own it.
	                You get a percentage of 1/2 the purchase price, based on the props current
					health out of total health.
					   
	<strong>Scoring</strong>
	-------
	You get credit at the end of each attack for props of yours that are still alive.
	The credits for each prop come from how long it has survived, and what condition it's in.
	Earnings for each prop are capped at 1/2 cost, so a 500 credit prop that survived 100 seconds
	at 100% health is worth 100 credits at the end of the round. It will max out at 250 credits 
	for full heath at 250 seconds alive, but at 50% health you'd get 125 credit for that same prop.

	<strong>Map Sweep</strong>
	---------
	*ANY* prop not in either your area or a public area will be destroyed for no credits, 
	every 10 seconds. So no... there is no stairway to heaven.
	
	<strong>Other</strong>
	------
	If you are broke you can camp spawn to get you're health credit bonus.
	
	Might add a trivia for cash game for people stuck in spawn to earn some credits.
	
	If you have any Ideas or comments I have a thread for this game mode on Facepunch.
	http://www.facepunch.com/threads/1063854-Meteor-Defense
	
	</pre>
	</body>
	</html>
	]])
	
	dbPlay = vgui.Create('DButton')
	dbPlay:SetParent(dfWelcome)
	dbPlay:SetSize(dfWelcome:GetWide() - 20, 25)
	dbPlay:SetPos(5, dfWelcome:GetTall() - 35)
	dbPlay:SetText('Play!')
	dbPlay.DoClick = function() dfWelcome:Close() end
	
end
usermessage.Hook("ShowWelcome", fanWelcome)