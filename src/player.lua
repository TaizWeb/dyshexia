Player = {
	texture = love.graphics.newImage("assets/sathy/sathy-front.png"),
	textures = {
		front = love.graphics.newImage("assets/sathy/sathy-front.png"),
		side = love.graphics.newImage("assets/sathy/sathy-side.png"),
		back = love.graphics.newImage("assets/sathy/sathy-back.png")
	},
	height = 25,
	width = 25,
	maxHealth = 200,
	maxMana = 200,
	health = 200,
	mana = 200,
	spell = {
		element = "fire",
		pattern = "ball"
	},
	money = 0,
	currentLevel = 1
}

function Player.draw(this)
	-- Figure out offsets depending on the direction the player is facing
	if (not this.forwardFace) then
		this.scaleX = -2
		this.scaleY = 2
		this.offsetX = 11
	else
		this.scaleX = 2
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
	Player.drawHealthBar()
	Player.drawManaBar()
	--love.graphics.print("Health: " .. Heartbeat.player.health)
	love.graphics.print("\n\n\n\n/G/old: " .. Player.money)
	love.graphics.print("\n\n\n\n\nLevel: " .. Player.currentLevel)
end

function Player.drawHealthBar()
	local barX = 0
	local barY = 0
	local barWidth = 100
	local barHeight = 20
	local healthFraction = barWidth * (Heartbeat.player.health / Player.maxHealth)
	-- Drawing the background
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
	-- Drawing the bar itself
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.rectangle("fill", barX + 1, barY + 1, healthFraction - 1, barHeight - 1)
	-- Drawing the text
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(Heartbeat.player.health .. " / " .. Player.maxHealth, barX, barY)
end

function Player.drawManaBar()
	local barX = 0
	local barY = 25
	local barWidth = 100
	local barHeight = 20
	local manaFraction = barWidth * (Player.mana / Player.maxMana)
	-- Drawing the background
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
	-- Drawing the bar itself
	love.graphics.setColor(0, 0, 1, 1)
	love.graphics.rectangle("fill", barX + 1, barY + 1, manaFraction - 1, barHeight - 1)
	-- Drawing the text
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(Player.mana .. " / " .. Player.maxMana, barX, barY)
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
			local entity = Heartbeat.getEntity(startX, startY)
			local item = Heartbeat.getItem(startX, startY)
			if (tile ~= nil) then
				tile.scaleX = 25/16
				tile.scaleY = 25/16
			end
			if (entity ~= nil) then
				entity.scaleX = 2
				entity.scaleY = 2
			end
			if (item ~= nil) then
				item.scaleX = 25/16
				item.scaleY = 25/16
			end

			startY = startY + 25
		end
		startX = startX + 25
	end
end

function Player.cast()
	-- Ensuring the player has magic equipped and enough mana to use it
	if (Player.spell.element ~= nil and Player.spell.pattern ~= nil and Player.mana >= Spells.pattern[Player.spell.pattern].cost) then
		Spells.x = Heartbeat.player.x
		Spells.y = Heartbeat.player.y
		-- Giving Spells the "origin" of the spell
		if (Heartbeat.player.direction == "up") then
			Spells.y = Spells.y - 25
		elseif (Heartbeat.player.direction == "down") then
			Spells.y = Spells.y + 25
		elseif (Heartbeat.player.direction == "right") then
			Spells.x = Spells.x + 25
		else
			Spells.x = Spells.x - 25
		end
		-- Cast the spell, calling the pattern the player currently has
		Spells.direction = Heartbeat.player.direction
		Spells.pattern[Player.spell.pattern].use()
		-- Use mana
		Player.mana = Player.mana - Spells.pattern[Player.spell.pattern].cost
	end
end

-- regenMana: Regens mana, will later depend on buffs
function Player.regenMana()
	if (Player.mana < Player.maxMana) then
		Player.mana = Player.mana + 1
	end
end

function Player.onDeath()
	-- Yolo
	love.event.quit()
end
