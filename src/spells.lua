Spells = {
	element = {},
	pattern = {},
}

Spells.element.fire = {
	id = "fire",
	damageType = "fire",
	texture = love.graphics.newImage("assets/spells/fire.png"),
	scaleX = 2,
	scaleY = 2,
	offsetX = 0,
	offsetY = 0
}

Spells.element.pepper = {
	id = "pepper",
	damageType = "pepper",
	texture = love.graphics.newImage("assets/spells/pepper.png"),
	scaleX = 2,
	scaleY = 2,
	offsetX = 0,
	offsetY = 0
}

Spells.element.thunder = {
	id = "thunder",
	damageType = "thunder",
	texture = love.graphics.newImage("assets/spells/thunder.png"),
	scaleX = 2,
	scaleY = 2,
	offsetX = 0,
	offsetY = 0
}

Spells.pattern.burst = {
	id = "burst",
	cost = 5
}

Spells.pattern.ball = {
	id = "ball",
	cost = 10
}

Spells.pattern.strike = {
	id = "strike",
	cost = 15
}

function Spells.pattern.burst.use()
	Animation.newAnimation(burstAnimation, 60)
	-- TODO: Add weakness/resist and a helper function for HP
	local entity = Heartbeat.getEntity(Spells.x, Spells.y)
	if (entity ~= nil) then
		Dyshexia.updateEntityHealth(entity, -5)
	end
end

function Spells.pattern.ball.use()
	-- These are the "initial" values, used to calculate how far the projet traveled later
	local x = Spells.x
	local y = Spells.y
	local entity

	-- Doing a raycast on the entities facing the player
	while (entity == nil and not Heartbeat.getTile(x, y).isSolid) do
		-- This is to prevent the game from softlocking if the blast doesn't hit anything. Possibly just add a ttl in the future
		if (x < 0 or x > Heartbeat.levelWidth or y < 0 or y > Heartbeat.levelHeight) then
			return
		end
		entity = Heartbeat.getEntity(x, y)
		if (entity ~= nil) then
			-- Strike them if they collide
			Dyshexia.updateEntityHealth(entity, -5)
		end
		-- I want to do this better too
		if (Heartbeat.player.direction == "up") then
			y = y - 25
		elseif (Heartbeat.player.direction == "down") then
			y = y + 25
		elseif (Heartbeat.player.direction == "left") then
			x = x - 25
		else
			x = x + 25
		end
	end

	if (Heartbeat.player.direction == "up") then
		Animation.newAnimation(ballAnimation, (Spells.y - y) / 5)
	elseif (Heartbeat.player.direction == "down") then
		Animation.newAnimation(ballAnimation, -1 * (Spells.y - y) / 5)
	elseif (Heartbeat.player.direction == "left") then
		Animation.newAnimation(ballAnimation, (Spells.x - x) / 5)
	else
		Animation.newAnimation(ballAnimation, -1 * (Spells.x - x) / 5)
	end
end

function Spells.pattern.strike.use()
	-- TODO: Potentially add a way to "choose" the closest entity to the player
	-- Where the radius check will start
	local startX = Heartbeat.player.x - 50
	local startY = Heartbeat.player.y - 50

	-- Checking all around the player in a two tile radius
	for i=0,4 do
		for j=0,4 do
			local entity = Heartbeat.getEntity(startX + (i * 25), startY + (j * 25))
			if (entity ~= nil) then
				Dyshexia.updateEntityHealth(entity, -5)
				-- Since strike doesn't currently do anything fancy
				-- We can simply reuse the burst animation
				Spells.x = entity.x
				Spells.y = entity.y
				Animation.newAnimation(burstAnimation, 30)
				return
			end
		end
	end
end

function ballAnimation(frame)
	local changeX = 0
	local changeY = 0

	-- Make the ball fire in the right direciton
	-- I know I'm sinning here checking direction again but I haven't figured out a better way to do this
	-- I could just stick it in Spells in the cast functions later to save one more computation
	if (Spells.direction == "up") then
		changeY = frame * -5
	elseif (Spells.direction == "down") then
		changeY = frame * 5
	elseif (Spells.direction == "left") then
		changeX = frame * -5
	else
		changeX = frame * 5
	end

	Spells.draw(Spells.x + changeX, Spells.y + changeY)
end

function burstAnimation()
	Spells.draw(Spells.x, Spells.y)
end

function Spells.draw(x, y)
	love.graphics.draw(Spells.element[Player.spell.element].texture, Camera.convert("x", x), Camera.convert("y", y), 0, Spells.element[Player.spell.element].scaleX, Spells.element[Player.spell.element].scaleY, Spells.element[Player.spell.element].offsetX, Spells.element[Player.spell.element].offsetY)
end

