love.graphics.setDefaultFilter("nearest", "nearest")
require("lib/heartbeat")
require("player")
require("tiles")
require("entities/skeleton")
require("items/coin")

function love.load()
	-- Basic setup for love/Heartbeat
	love.window.setTitle("Dyshexia")
	love.keyboard.setKeyRepeat(true)
	love.filesystem.setIdentity("dyslexia")
	windowWidth = love.graphics.getWidth()
	windowHeight = love.graphics.getHeight()
	Heartbeat.levelWidth = windowWidth
	Heartbeat.levelHeight = windowHeight
	-- Making gravity 0 as this is top-down
	Heartbeat.gravity = 0
	-- Make Heartbeat snap to grid for entities/items
	Heartbeat.editor.snapToGrid = true
	-- Adding the player/entities to Heartbeat
	Heartbeat.createPlayer(Player, 300, 300)
	Heartbeat.tilesList = {Wall}
	Heartbeat.entitiesList = {Skeleton}
	Heartbeat.itemsList = {Coin}
	-- A cheap way to make tiles "invisible" before the player sees them
	for i=1,#Heartbeat.tilesList do
		Heartbeat.tilesList[i].scaleX = 0
		Heartbeat.tilesList[i].scaleY = 0
	end
end

-- moveEntity: Moves an entity in a given direction assuming there's no obstruction
function moveEntity(this, direction)
	if (direction == "left") then
		if (Heartbeat.getTile(this.x - 10, this.y) == nil) then
			this.x = this.x - 25
		end
		this.texture = this.textures.side
		this.forwardFace = false
	elseif (direction == "right") then
		if (Heartbeat.getTile(this.x + this.width + 10, this.y) == nil) then
			this.x = this.x + 25
		end
		this.texture = this.textures.side
		this.forwardFace = true
	elseif (direction == "up") then
		if (Heartbeat.getTile(this.x, this.y - 10) == nil) then
			this.y = this.y - 25
		end
		this.texture = this.textures.back
		this.forwardFace = true
	elseif (direction == "down") then
		if (Heartbeat.getTile(this.x, this.y + this.height + 10) == nil) then
			this.y = this.y + 25
		end
		this.texture = this.textures.front
		this.forwardFace = true
	end
	if (this == Heartbeat.player) then
		Player.checkVision()
	end
end

function love.keypressed(key, scancode, isrepeat)
	-- Toggle editor
	if (key == "e" and not Heartbeat.editor.commandMode) then
		Heartbeat.editor.isActive = not Heartbeat.editor.isActive
	end
	if (Heartbeat.editor.isActive) then
		Heartbeat.editor.handleInput(key)
	end

	if (not Heartbeat.editor.isActive) then
		-- Handle movement
		if (key == "left" or key == "right" or key == "up" or key == "down") then
			moveEntity(Heartbeat.player, key)
		end
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
end

