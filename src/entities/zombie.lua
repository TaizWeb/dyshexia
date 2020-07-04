Zombie = {
	id = "zombie",
	--texture = love.graphics.newImage("assets/entities/zombie/zombie-front.png"),
	textures = {
		--front = love.graphics.newImage("assets/entities/zombie/zombie-front.png"),
		--back = love.graphics.newImage("assets/entities/zombie/zombie-back.png"),
		--side = love.graphics.newImage("assets/entities/zombie/zombie-side.png")
	},
	height = 25,
	width = 25,
	scaleX = 3,
	scaleY = 3,
	health = 10,
	attack = 5,
	isEnemy = true
}

function Zombie.draw(this)
	if (not this.forwardFace) then
		this.scaleX = -3
	else
		this.scaleX = 3
	end
	Heartbeat.draw(this)
end

function Zombie.behaivor(this)
	-- Later I'll do a thing where it checks the player's x/y and moves depending on that
	local diffX = Heartbeat.player.x - this.x
	local diffY = Heartbeat.player.y - this.y
	if (isAdjacent(this, Heartbeat.player)) then
		Zombie.attack(this)
	elseif (math.abs(diffX) > math.abs(diffY)) then
		if (diffX < 0) then
			moveEntity(this, "left")
		else
			moveEntity(this, "right")
		end
	else
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

function Zombie.onDeath(this)
	-- Make it drop something, grant exp, inflict a debuff, etc
end

