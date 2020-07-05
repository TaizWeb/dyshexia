Menu = {
	selection = 1,
	maxSelection = 3,
	menuElements = {
		"Spells",
		"Inventory",
		"Quit"
	},
	currentMenu = "Main",
	combinationActive = false,
	combinedPages = {}
}

local mainMenu = {
	x = 80,
	y = 25,
	width = 150,
	height = 300,
	text = nil
}

local spellMenu = {
	x = mainMenu.x + mainMenu.width + 10,
	y = mainMenu.y,
	width = 100,
	height = 200
}

local useDialog = {
	x = spellMenu.x + spellMenu.width + 10,
	y = spellMenu.y,
	width = 50,
	height = 50
}

function Menu.handleKey(key)
	if (key == "down") then
		if (Menu.currentMenu == "Main" and Menu.selection < Menu.maxSelection) then
			Menu.selection = Menu.selection + 1
		elseif (Menu.currentMenu == "Inventory") then
			Menu.itemSelection = Menu.itemSelection + 1
		end
	end
	if (key == "up") then
		if (Menu.currentMenu == "Main" and Menu.selection > 1) then
			Menu.selection = Menu.selection - 1
		elseif (Menu.currentMenu == "Inventory") then
			Menu.itemSelection = Menu.itemSelection - 1
		end
	end
	if (key == "z") then
		if (Menu.currentMenu == "Main") then
			Menu.currentMenu = Menu.menuElements[Menu.selection]
		elseif (Menu.currentMenu == "Inventory") then
			Menu.combinationActive = true
		end

		--if (Menu.selection == 1) then
			--Menu.spellsOpen = true
		--elseif (Menu.selection == 2) then
			--Menu.inventoryOpen = true
		--end
	end
end

function Menu.drawMenu()
	love.graphics.setColor(0, 0, 1, .5)
	love.graphics.rectangle('fill', mainMenu.x, mainMenu.y, mainMenu.width, mainMenu.y + mainMenu.height)
	love.graphics.setColor(1, 1, 1, 1)
	local menuText
	for i=1,#Menu.menuElements do
		if (i == Menu.selection) then
			menuText = "> " .. Menu.menuElements[i]
		else
			menuText = Menu.menuElements[i]
		end

		love.graphics.print(menuText, mainMenu.x + 10, mainMenu.y + (i * 25))
	end
	if (Menu.currentMenu == "Spells") then
		Menu.drawSpells()
	elseif (Menu.currentMenu == "Inventory") then
		Menu.drawItems()
	end
end

function Menu.drawSpells()
	love.graphics.setColor(0, 0, 1, .5)
	love.graphics.rectangle('fill', spellMenu.x, spellMenu.y, spellMenu.x + spellMenu.width, spellMenu.y + spellMenu.height)
end

function Menu.drawItems()
	-- For now we'll steal the spell ui
	Menu.drawSpells()
	-- Set the selection bounds
	if (Menu.itemSelection == nil) then
		Menu.itemSelection = 1
	end
	Menu.itemMaxSelection = #Heartbeat.player.inventory
	-- For now we'll steal the spell ui
	for i=1,#Heartbeat.player.inventory do
		local itemName = Heartbeat.player.inventory[i].name
		if (i == Menu.itemSelection) then
			itemName = "> " .. itemName
		end
		if (Menu.combinationActive or Menu.combinedPages[1] == Heartbeat.player.inventory[i]) then
			love.graphics.setColor(0, 1, 0, 1)
			Menu.combinationActive = false
			if (Menu.combinedPages[1] == nil) then
				Menu.combinedPages[1] = i
			else
				Menu.combinedPages[2] = i
				combineSpells(Menu.combinedPages[1], Menu.combinedPages[2])
			end
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print(itemName, spellMenu.x + 10, spellMenu.y + (i * 25))
	end
end

function combineSpells(scroll1, scroll2)
	print(Heartbeat.player.inventory[scroll1].name)
	print(Heartbeat.player.inventory[scroll2].name)
	local scroll1Type = split(Heartbeat.player.inventory[scroll1].name, " ")[2]
	local scroll2Type = split(Heartbeat.player.inventory[scroll2].name, " ")[2]
	if (scroll1Type == "element") then
		Player.spell.element = Heartbeat.player.inventory[scroll1].id
		Player.spell.pattern = Heartbeat.player.inventory[scroll2].id
	else
		Player.spell.pattern = Heartbeat.player.inventory[scroll1].id
		Player.spell.element = Heartbeat.player.inventory[scroll2].id
	end
	print(Player.spell.element)
	print(Player.spell.pattern)
	
end
	
