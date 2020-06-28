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

