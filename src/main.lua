love.graphics.setDefaultFilter("nearest", "nearest")
require("lib/heartbeat")
require("player")
require("tiles")
require("level")
require("spells")
require("menu")
require("entities/skeleton")
require("entities/zombie")
require("items/coin")
require("items/scroll")
require("items/ladder")

function love.load()
	-- Basic setup for love/Heartbeat
	love.window.setTitle("Dyshexia")
	love.keyboard.setKeyRepeat(true)
	love.filesystem.setIdentity("dyslexia")
	windowWidth = love.graphics.getWidth()
	windowHeight = love.graphics.getHeight()
	Heartbeat.levelWidth = 9001
	Heartbeat.levelHeight = 9001
	-- Making gravity 0 as this is top-down
	Heartbeat.gravity = 0
	-- Make Heartbeat snap to grid for entities/items
	Heartbeat.editor.snapToGrid = true
	-- Adding the player/entities to Heartbeat
	Heartbeat.createPlayer(Player, 300, 300)
	Heartbeat.player.direction = "down"
	Heartbeat.tilesList = {Wall, Ground}
	Heartbeat.entitiesList = {Zombie, Skeleton}
	Heartbeat.itemsList = {Coin, Scroll, Ladder}
	-- A cheap way to make tiles "invisible" before the player sees them
	for i=1,#Heartbeat.tilesList do
		Heartbeat.tilesList[i].scaleX = 0
		Heartbeat.tilesList[i].scaleY = 0
	end

	Level.generateLevel()

	isPaused = false
end

-- moveEntity: Moves an entity in a given direction assuming there's no obstruction
function moveEntity(this, direction)
	-- I'd like to make this more clever at some point, for example by not having tile/entity be defined in different ways four different times
	-- Perhaps have the dimensions to check entity/tile in the if statements, then do the checks all in the same line?
	-- For now, this will do, despite not being DRY
	local tile
	local entity
	if (direction == "left") then
		tile = Heartbeat.getTile(this.x - 10, this.y)
		entity = Heartbeat.getEntity(this.x - 10, this.y)
		if ((tile == nil or not tile.isSolid) and entity == nil) then
			this.x = this.x - 25
		end
		this.texture = this.textures.side
		this.forwardFace = false
	elseif (direction == "right") then
		tile = Heartbeat.getTile(this.x + this.width + 10, this.y)
		entity = Heartbeat.getEntity(this.x + this.width + 10, this.y)
		if ((tile == nil or not tile.isSolid) and entity == nil) then
			this.x = this.x + 25
		end
		this.texture = this.textures.side
		this.forwardFace = true
	elseif (direction == "up") then
		tile = Heartbeat.getTile(this.x, this.y - 10)
		entity = Heartbeat.getEntity(this.x, this.y - 10)
		if ((tile == nil or not tile.isSolid) and entity == nil) then
			this.y = this.y - 25
		end
		this.texture = this.textures.back
		this.forwardFace = true
	elseif (direction == "down") then
		tile = Heartbeat.getTile(this.x, this.y + this.height + 10)
		entity = Heartbeat.getEntity(this.x, this.y + this.height + 10)
		if ((tile == nil or not tile.isSolid) and entity == nil) then
			this.y = this.y + 25
		end
		this.texture = this.textures.front
		this.forwardFace = true
	end

	-- Store the direction away for later usage
	this.direction = direction

	-- My turn your turn and update vision
	if (this == Heartbeat.player) then
		Player.checkVision()
		Heartbeat.doEntities()
	end
end

function isAdjacent(entity, target)
	if (((entity.y + 25) == target.y and entity.x == target.x) or
		((entity.y - 25) == target.y and entity.x == target.x) or
		((entity.x - 25) == target.x and entity.y == target.y) or
		((entity.x + 25) == target.x and entity.y == target.y)
		) then
		return true
	end
end

function love.keypressed(key, scancode, isrepeat)
	--if (key == "g") then
		--Level.generateLevel()
	--end
	-- Toggle editor
	if (key == "e" and not Heartbeat.editor.commandMode) then
		Heartbeat.editor.isActive = not Heartbeat.editor.isActive
	end
	if (Heartbeat.editor.isActive) then
		Heartbeat.editor.handleInput(key)
	end

	if (not Heartbeat.editor.isActive and not isPaused) then
		-- Handle movement
		if (key == "left" or key == "right" or key == "up" or key == "down") then
			moveEntity(Heartbeat.player, key)
		end
		-- Skip turn
		if (key == "z") then
			Player.cast()
			Heartbeat.doEntities()
		end
	end

	if (key == "return") then
		isPaused = not isPaused
	end

	if (isPaused) then
		Menu.handleKey(key)
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if (Heartbeat.editor.isActive) then
		Heartbeat.editor.handleInput(button)
	end
end

function love.update(dt)
	if (Heartbeat.editor.isActive) then
		if (love.mouse.isDown(1) and Heartbeat.editor.mode == "tile") then
			Heartbeat.editor.handleInput(1)
		end
		if (love.mouse.isDown(2)) then
			Heartbeat.editor.handleInput(2)
		end
	end
end

function love.draw()
	Heartbeat.beat()
	-- Do spell animations
	if (Spells.animationActive) then
		Spells.animationTimer = Spells.animationTimer - 1
		if (Spells.animationTimer == 0) then
			Spells.animationActive = false
		else
			Spells.animationTarget()
		end
	end
	
	-- Draw menu
	if (isPaused) then
		Menu.drawMenu()
	end
end

