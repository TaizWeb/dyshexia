Player = {
	texture = love.graphics.newImage("assets/sathy/sathy-front.png"),
	textures = {
		front = love.graphics.newImage("assets/sathy/sathy-front.png"),
		side = love.graphics.newImage("assets/sathy/sathy-side.png"),
		back = love.graphics.newImage("assets/sathy/sathy-back.png")
	},
	height = 25,
	width = 25,
	health = 50,
	spell = {
		element = "fire",
		pattern = "burst"
	},
	money = 0
}

function Player.draw(this)
	-- Figure out offsets depending on the direction the player is facing
	if (not this.forwardFace) then
		this.scaleX = -3
		this.scaleY = 3
		this.offsetX = 11
	else
		this.scaleX = 3
		this.offsetX = 5
		this.offsetY = 5
	end

	-- Draw the player to the screen
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(this.texture, Camera.convert("x", this.x), Camera.convert("y", this.y), this.rotation, this.scaleX, this.scaleY, this.offsetX, this.offsetY)
	--love.graphics.rectangle("fill", Camera.convert("x", this.x), Camera.convert("y", this.y), this.width, this.height)

	-- Draw the UI after
	Player.drawUI()
end

function Player.drawUI()
	love.graphics.print("Health: " .. Heartbeat.player.health)
	love.graphics.print("\n/G/old:" .. Player.money)
end

function Player.checkVision()
	local radius = 5
	-- Defining the ends of the row/col
	local endX = Heartbeat.player.x + Heartbeat.player.width + (25 * radius)
	local endY = Heartbeat.player.y + Heartbeat.player.height + (25 * radius)

	-- Start the row loop
	local startX = Heartbeat.player.x - (25 * radius)
	while (startX < endX) do
		-- Start the col loop
		local startY = Heartbeat.player.y - (25 * radius)
		while (startY < endY) do
			-- If the tile is in the radius, make it visible
			local tile = Heartbeat.getTile(startX, startY)
			if (tile ~= nil) then
				tile.scaleX = 25/16
				tile.scaleY = 25/16
			end
			startY = startY + 25
		end
		startX = startX + 25
	end
end

function Player.cast()
	if (Heartbeat.player.direction == "up") then
		Spells.pattern[Player.spell.pattern](Heartbeat.player.x, Heartbeat.player.y - 25)
	elseif (Heartbeat.player.direction == "down") then
		Spells.pattern[Player.spell.pattern](Heartbeat.player.x, Heartbeat.player.y + 25)
	elseif (Heartbeat.player.direction == "right") then
		Spells.pattern[Player.spell.pattern](Heartbeat.player.x + 25, Heartbeat.player.y)
	else 
		Spells.pattern[Player.spell.pattern](Heartbeat.player.x - 25, Heartbeat.player.y)
	end
end

function Player.onDeath()
	-- Yolo
	love.event.quit()
end
