love.graphics.setDefaultFilter("nearest", "nearest")
require("lib/heartbeat")
require("player")
require("tiles")
require("entities/skeleton")
require("items/coin")

function love.load()
	-- Basic setup for love/Heartbeat
	love.window.setTitle("Dylexinomicon")
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
end

-- moveLeft: Moves the entity left assuming the space is unoccupied
function moveLeft(this)
	if (Heartbeat.getTile(this.x - 10, this.y) == nil) then
		this.x = this.x - 25
	end
	this.texture = this.textures.side
	this.forwardFace = false
end

-- moveRight: Moves the entity right assuming the space is unoccupied
function moveRight(this)
	if (Heartbeat.getTile(this.x + this.width + 10, this.y) == nil) then
		this.x = this.x + 25
	end
	this.texture = this.textures.side
	this.forwardFace = true
end

-- moveUp: Moves the entity up assuming the space is unoccupied
function moveUp(this)
	if (Heartbeat.getTile(this.x, this.y - 10) == nil) then
		this.y = this.y - 25
	end
	this.texture = this.textures.back
	this.forwardFace = true
end

-- moveDown: Moves the entity down assuming the space is unoccupied
function moveDown(this)
	if (Heartbeat.getTile(this.x, this.y + this.height + 10) == nil) then
		this.y = this.y + 25
	end
	this.texture = this.textures.front
	this.forwardFace = true
end

function love.keypressed(key, scancode, isrepeat)
	-- Toggle editor
	if (key == "e") then
		Heartbeat.editor.isActive = not Heartbeat.editor.isActive
	end
	if (Heartbeat.editor.isActive) then
		Heartbeat.editor.handleInput(key)
	end

	if (not Heartbeat.editor.isActive) then
		-- Handle movement
		if (key == "left") then
			moveLeft(Heartbeat.player)
		end
		if (key == "right") then
			moveRight(Heartbeat.player)
		end
		if (key == "up") then
			moveUp(Heartbeat.player)
		end
		if (key == "down") then
			moveDown(Heartbeat.player)
		end
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if (Heartbeat.editor.isActive) then
		Heartbeat.editor.handleInput(button)
	end
end

function love.draw()
	Heartbeat.beat()
end

