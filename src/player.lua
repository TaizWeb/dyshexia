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
	-- You reading this is just as painful as it was for me to code it in
	local visibleTiles = {
		-- left tile
		Heartbeat.getTile(Heartbeat.player.x - 10, Heartbeat.player.y),
		-- right tile
		Heartbeat.getTile(Heartbeat.player.x + Heartbeat.player.width + 10, Heartbeat.player.y),
		-- above tile
		Heartbeat.getTile(Heartbeat.player.x, Heartbeat.player.y - 10),
		-- below tile
		Heartbeat.getTile(Heartbeat.player.x, Heartbeat.player.y + Heartbeat.player.height + 10),
		-- left above tile
		Heartbeat.getTile(Heartbeat.player.x - 10, Heartbeat.player.y - 10),
		-- right above tile
		Heartbeat.getTile(Heartbeat.player.x + Heartbeat.player.width + 10, Heartbeat.player.y - 10),
		-- left below tile
		Heartbeat.getTile(Heartbeat.player.x - 10, Heartbeat.player.y + Heartbeat.player.height + 10),
		-- right below tile
		Heartbeat.getTile(Heartbeat.player.x + Heartbeat.player.width + 10, Heartbeat.player.y + Heartbeat.player.height + 10)
	}
	-- Lua has no .length and #visibleTiles would be how many elements aren't nil
	local visibleTileCount = 8

	for i=1,visibleTileCount do
		if (visibleTiles[i] ~= nil) then
			visibleTiles[i].scaleX = 25/16
			visibleTiles[i].scaleY = 25/16
		end
	end
end

