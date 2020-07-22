Menu = {
	-- Menu selection bounds
	selection = 1,
	maxSelection = 3,
	-- Use dialog selection bounds
	useSelection = 1,
	maxUseSelection = 2,
	menuElements = {
		"Spells",
		"Inventory",
		"Quit"
	},
	-- Tracking which menu is open for up/down key movement
	currentMenu = "Main",
	-- Tracking which pages are to be combined together
	combinedPages = {
		pattern = nil,
		element = nil
	}
}

-- Main menu, this displays the options like the inventory
local mainMenu = {
	x = 80,
	y = 25,
	width = 150,
	height = 200,
	text = nil
}

-- The spell menu, this currently doubles as the inventory one. Lists all the items in the inventory
local spellMenu = {
	x = mainMenu.x + mainMenu.width + 10,
	y = mainMenu.y,
	width = 150,
	height = 300
}

-- The "use" dialog. This is for when an item is selected, as a prompt of what to do (use/discard)
local useDialog = {
	x = spellMenu.x + spellMenu.width + 10,
	y = spellMenu.y,
	width = 100,
	height = 100
}

function Menu.handleKey(key)
	-- Move the cursor up or down
	if (key == "down") then
		if (Menu.currentMenu == "Main" and Menu.selection < Menu.maxSelection) then
			Menu.selection = Menu.selection + 1
		elseif (Menu.currentMenu == "Inventory" and Menu.itemSelection < Menu.itemMaxSelection) then
			Menu.itemSelection = Menu.itemSelection + 1
		end
	end
	if (key == "up") then
		if (Menu.currentMenu == "Main" and Menu.selection > 1) then
			Menu.selection = Menu.selection - 1
		elseif (Menu.currentMenu == "Inventory" and Menu.itemSelection > 1) then
			Menu.itemSelection = Menu.itemSelection - 1
		end
	end

	-- Confirm
	if (key == "z") then
		if (Menu.currentMenu == "Main") then
			Menu.currentMenu = Menu.menuElements[Menu.selection]
		elseif (Menu.currentMenu == "Inventory") then
			if (Menu.promptUsage) then
				Menu.useItem(Heartbeat.player.inventory[Menu.itemSelection])
				Menu.promptUsage = false
			else
				Menu.promptUsage = true
			end
		end
	end

	-- Back
	if (key == "x") then
		if (Menu.promptUsage) then
			Menu.promptUsage = false
		elseif (Menu.currentMenu == "Main") then
			isPaused = false
		else
			Menu.currentMenu = "Main"
		end
	end
end

-- useItem: Triggers usage of an item
function Menu.useItem(item)
	if (Menu.currentMenu == "Inventory") then
		print("Using " .. item.name)
		-- Checking if it's a page
		if (split(item.name, " ")[2] == "pattern"
			or split(item.name, " ")[2] == "element") then
			local spellData = split(item.name, " ")
			if (Menu.combineSpells(spellData[1], spellData[2])) then
				Heartbeat.player.removeInventoryItem(item)
			end
		end
	end
end

function Menu.combineSpells(spellName, spellType)
	-- Checking the parts of the spell
	-- I could possibly rewrite this to be more clever later
	if (Menu.combinedPages.pattern == nil and spellType == "pattern") then
		Menu.combinedPages.pattern = spellName
	elseif(Menu.combinedPages.element == nil and spellType == "element") then
		Menu.combinedPages.element = spellName
	else
		print("Spell not used!")
		return false
	end

	-- If they're all set, combine the spells
	if (Menu.combinedPages.element ~= nil and
		Menu.combinedPages.pattern ~= nil) then
		Player.spell.element = Menu.combinedPages.element
		Player.spell.pattern = Menu.combinedPages.pattern
		Menu.combinedPages.element = nil
		Menu.combinedPages.pattern = nil
		print("Spell created!")
	else
		print("Still needs more data!")
	end
	return true
end

function Menu.drawMenu()
	local menuText
	-- Draw the main window
	love.graphics.setColor(0, 0, 1, .5)
	love.graphics.rectangle('fill', mainMenu.x, mainMenu.y, mainMenu.width, mainMenu.y + mainMenu.height)

	-- Draw the menu elements
	love.graphics.setColor(1, 1, 1, 1)
	for i=1,#Menu.menuElements do
		if (i == Menu.selection) then
			menuText = "> " .. Menu.menuElements[i]
		else
			menuText = Menu.menuElements[i]
		end
		love.graphics.print(menuText, mainMenu.x + 10, mainMenu.y + (i * 25))
	end

	-- Draw the secondary window
	if (Menu.currentMenu == "Spells") then
		Menu.drawSpells()
	elseif (Menu.currentMenu == "Inventory") then
		Menu.drawItems()
	end

	-- Draw the usage menu if it's open
	if (Menu.promptUsage) then
		Menu.drawUsage()
	end
end

function Menu.drawSpells()
	love.graphics.setColor(0, 0, 1, .5)
	love.graphics.rectangle('fill', spellMenu.x, spellMenu.y, spellMenu.width, spellMenu.height)
end

function Menu.drawItems()
	-- For now we'll steal the spell ui
	Menu.drawSpells()
	-- Set the selection bounds
	if (Menu.itemSelection == nil) then
		Menu.itemSelection = 1
	end
	Menu.itemMaxSelection = #Heartbeat.player.inventory

	-- Draw the items to the screen
	for i=1,#Heartbeat.player.inventory do
		local itemName = Heartbeat.player.inventory[i].name .. " (" .. Heartbeat.player.inventory[i].count .. ")"

		-- Stick an arrow by the current position
		if (i == Menu.itemSelection) then
			itemName = "> " .. itemName		end

		--if (Menu.combinationActive or Menu.combinedPages[1] == Heartbeat.player.inventory[i]) then
			--love.graphics.setColor(0, 1, 0, 1)
			--Menu.combinationActive = false
			--if (Menu.combinedPages[1] == nil) then
				--Menu.combinedPages[1] = Heartbeat.player.inventory[i]
			--else
				--Menu.combinedPages[2] = Heartbeat.player.inventory[i]
				--combineSpells(Menu.combinedPages[1], Menu.combinedPages[2])
			--end
		--else
			--love.graphics.setColor(1, 1, 1, 1)
		--end
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(itemName, spellMenu.x + 10, spellMenu.y + (i * 25))
	end
end

-- drawUsage: Draws the usage prompt
function Menu.drawUsage()
	if (Heartbeat.player.inventory[Menu.itemSelection] == nil) then return end
	local isSpell = false
	local useContext = "Use"
	local discardContext = "Discard"
	love.graphics.setColor(0, 0, 1, .5)
	love.graphics.rectangle('fill', useDialog.x, useDialog.y, useDialog.width, useDialog.height)

	-- Quickly check if the item is a spell or pattern
	local itemName = Heartbeat.player.inventory[Menu.itemSelection].name
	if (split(itemName, " ")[2] == "pattern"
		or split(itemName, " ")[2] == "element") then
		isSpell = true
		useContext = "Combine"
	end

	-- Prepend the arrow
	if (Menu.useSelection == 1) then
		useContext = "> " .. useContext
	else
		discardContext = "> " .. discardContext
	end

	-- Draw the options
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(useContext, useDialog.x + 10, useDialog.y + 10)
	love.graphics.print(discardContext, useDialog.x + 10, useDialog.y + 30)
end

--function combineSpells(scroll1, scroll2)
	--print(scroll1.name)
	--print(scroll2.name)
	--local scroll1Type = split(Heartbeat.player.inventory[scroll1].name, " ")[2]
	--local scroll2Type = split(Heartbeat.player.inventory[scroll2].name, " ")[2]
	--if (scroll1Type == "element") then
		--Player.spell.element = Heartbeat.player.inventory[scroll1].id
		--Player.spell.pattern = Heartbeat.player.inventory[scroll2].id
	--else
		--Player.spell.pattern = Heartbeat.player.inventory[scroll1].id
		--Player.spell.element = Heartbeat.player.inventory[scroll2].id
	--end
	--print(Player.spell.element)
	--print(Player.spell.pattern)
--end

