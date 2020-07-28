Zombie = {
	id = "zombie",
	texture = love.graphics.newImage("assets/entities/zombie/zombie-front.png"),
	textures = {
		front = love.graphics.newImage("assets/entities/zombie/zombie-front.png"),
		back = love.graphics.newImage("assets/entities/zombie/zombie-back.png"),
		side = love.graphics.newImage("assets/entities/zombie/zombie-side.png")
	},
	height = 25,
	width = 25,
	scaleX = 2,
	scaleY = 2,
	health = 10,
	attack = 5,
	isEnemy = true
}

function Zombie.draw(this)
	-- This if statement is a bit of code I'm not proud of. Basically
	-- I "hide" unseen enemies by setting their scaleX/Y to zero
	-- So without this, they'd become visible instantly thanks to forwardFace
	-- I may just add an isVisible flag to Heartbeat and do it automatically
	if (this.scaleX ~= 0) then
		if (not this.forwardFace) then
			this.scaleX = -2
			this.offsetX = 11
		else
			this.scaleX = 2
			this.offsetX = 0
		end
		this.scaleY = 2
		--love.graphics.rectangle("fill", Camera.convert("x", this.x), Camera.convert("y", this.y), this.width, this.height)
		Heartbeat.draw(this)
	end
end

function Zombie.behaivor(this)
	local diffX = Heartbeat.player.x - this.x
	local diffY = Heartbeat.player.y - this.y
	-- Attack the player if adjaecent
	if (isAdjacent(this, Heartbeat.player)) then
		Zombie.attack(this)
	-- If not, move
	elseif (math.abs(diffX) > math.abs(diffY)) then
		-- Decide between left/right
		if (diffX < 0) then
			moveEntity(this, "left")
		else
			moveEntity(this, "right")
		end
	else
		-- Decide between up/down
		if (diffY < 0) then
			moveEntity(this, "up")
		else
			moveEntity(this, "down")
		end
	end
end

function Zombie.attack(this)
	Heartbeat.updateEntityHealth(Heartbeat.player, Heartbeat.player.health - 5)
end

function Zombie.onHit(this)
	-- Add a hurt animation here
end

function Zombie.onDeath(this)
	-- Make it drop something, grant exp, inflict a debuff, etc
end

