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

	-- A cheap way to make everything "invisible" before the player sees them
	for i=1,#Heartbeat.tilesList do
		Heartbeat.tilesList[i].scaleX = 0
		Heartbeat.tilesList[i].scaleY = 0
	end
	for i=1,#Heartbeat.entitiesList do
		Heartbeat.entitiesList[i].scaleX = 0
		Heartbeat.entitiesList[i].scaleY = 0
	end
	for i=1,#Heartbeat.itemsList do
		Heartbeat.itemsList[i].scaleX = 0
		Heartbeat.itemsList[i].scaleY = 0
	end

	Level.generateLevel()

	isPaused = false
end

-- moveEntity: Moves an entity in a given direction assuming there's no obstruction
function moveEntity(this, direction)
	local attemptedX = this.x
	local attemptedY = this.y
	this.forwardFace = true

	-- Directional checking and setting proper textures
	if (direction == "left") then
		attemptedX = this.x - 25
		this.texture = this.textures.side
		this.forwardFace = false
	elseif (direction == "right") then
		attemptedX = this.x + 25
		this.texture = this.textures.side
	elseif (direction == "up") then
		attemptedY = this.y - 25
		this.texture = this.textures.back
	elseif (direction == "down") then
		attemptedY = this.y + 25
		this.texture = this.textures.front
	end

	-- Making sure no collisions in the attempted movement
	local tile = Heartbeat.getTile(attemptedX, attemptedY)
	local entity = Heartbeat.getEntity(attemptedX, attemptedY)
	if ((tile == nil or not tile.isSolid) and entity == nil) then
		--if (this.movementX ~= nil and this.movementY ~= nil) then
			--this.x = this.movementX
			--this.y = this.movementY
			--print("SKIPPING ANIMATION: " .. this.x .. " " .. this.y)
		--end
		this.movementX = attemptedX
		this.movementY = attemptedY
		--animateMovement(this, attemptedX, attemptedY)
		--this.x = attemptedX
		--this.y = attemptedY
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

function animateMovement(this)
	-- A nil check in case it's the "first" turn
	if (this.movementX == nil or this.movementY == nil) then return end

	-- Easing the player
	if (this.x ~= this.movementX) then
		-- This is a really clever way I came up with to move the entity 1 pixel over, without knowing if it's negative/positive
		local diffX = this.movementX - this.x
		this.x = this.x + (math.abs(diffX)/diffX)
	end
	if (this.y ~= this.movementY) then
		local diffY = this.movementY - this.y
		this.y = this.y + (math.abs(diffY)/diffY)
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
		-- Cast
		if (key == "z") then
			Player.cast()
			Heartbeat.doEntities()
		end
	end

	-- Pause the game
	if (key == "return") then
		isPaused = not isPaused
	end

	-- Handle keys if the menu is open
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
	else
		if ((Heartbeat.player.movementX ~= Heartbeat.player.x) or (Heartbeat.player.movementY ~= Heartbeat.player.y)) then
			animateMovement(Heartbeat.player)
		end
		-- Perform animation checks
		for i=1,#Heartbeat.entities do
			if ((Heartbeat.entities[i].movementX ~= Heartbeat.entities[i].x) or
				(Heartbeat.entities[i].movementY ~= Heartbeat.entities[i].y)) then
				animateMovement(Heartbeat.entities[i])
			end
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

