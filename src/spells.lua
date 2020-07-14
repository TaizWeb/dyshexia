Spells = {
	element = {},
	pattern = {},
	animationTarget = {},
	animationTimer = 0,
	animationActive = false
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

Spells.pattern.burst = {
	id = "burst"
}

function Spells.pattern.burst.use(x, y)
	Spells.x = x
	Spells.y = y
	Spells.animationTarget = burstAnimation
	Spells.animationTimer = 60
	Spells.animationActive = true
	-- TODO: Add weakness/resist and a helper function for HP
	local entity = Heartbeat.getEntity(x, y)
	if (entity ~= nil) then
		Heartbeat.updateEntityHealth(entity, entity.health - 5)
	end
	--Heartbeat.getEntity(x, y).health = 0
end

-- TODO: Add a generic spell drawing function
-- Animations are a bitch in love. I'll try to make a general-purpose function for it but for now it'll just be hacks
function burstAnimation()
	love.graphics.draw(Spells.element[Player.spell.element].texture, Camera.convert("x", Spells.x), Camera.convert("y", Spells.y), 0, Spells.element[Player.spell.element].scaleX, Spells.element[Player.spell.element].scaleY, Spells.element[Player.spell.element].offsetX, Spells.element[Player.spell.element].offsetY)
end
