love.graphics.setDefaultFilter("nearest", "nearest")
require("lib/heartbeat")
require("player")
require("tiles")
require("level")
require("spells")
require("menu")
require("animation")
require("entities/skeleton")
require("entities/zombie")
require("items/coin")
require("items/scroll")
require("items/ladder")
require("items/health_potion")

function love.load()
	-- Basic setup for love/Heartbeat
	love.window.setTitle("Dyshexia")
	love.filesystem.setIdentity("dyslexia")
	love.keyboard.setKeyRepeat(true)
	windowWidth = love.graphics.getWidth()
	windowHeight = love.graphics.getHeight()
	-- Global scales, this is for different screen resolutions
	-- I do this by round numbers otherwise the graphics get choppy and uneven
	globalScaleX = math.floor(windowWidth / 800)
	globalScaleY = math.floor(windowHeight / 600)
	-- Setting level dimensions
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
	Heartbeat.itemsList = {Coin, Scroll, Ladder, HealthPotion}

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
	if (direction == Keybinds.left) then
		attemptedX = this.x - 25
		this.texture = this.textures.side
		this.forwardFace = false
		this.direction = "left"
	elseif (direction == Keybinds.right) then
		attemptedX = this.x + 25
		this.texture = this.textures.side
		this.direction = "right"
	elseif (direction == Keybinds.up) then
		attemptedY = this.y - 25
		this.texture = this.textures.back
		this.direction = "up"
	elseif (direction == Keybinds.down) then
		attemptedY = this.y + 25
		this.texture = this.textures.front
		this.direction = "down"
	end

	-- Making sure no collisions in the attempted movement
	local tile = Heartbeat.getTile(attemptedX, attemptedY)
	local entity = Heartbeat.getEntity(attemptedX, attemptedY)
	if ((tile == nil or not tile.isSolid) and entity == nil) then
		this.x = attemptedX
		this.y = attemptedY
	end

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
		if (key == Keybinds.left or key == Keybinds.right or key == Keybinds.up or key == Keybinds.down) then
			moveEntity(Heartbeat.player, key)
		end
		-- Skip turn
		if (key == Keybinds.action) then
			Player.cast()
			Heartbeat.doEntities()
		end
	end

	if (key == Keybinds.pause) then
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
	-- Scale the graphics to accomodate larger screens
	love.graphics.scale(globalScaleX, globalScaleY)
	-- Get heartbeat running
	Heartbeat.beat()
	-- Do spell animations
	Animation.doAnimations()

	-- Draw menu
	if (isPaused) then
		Menu.drawMenu()
	end
end

