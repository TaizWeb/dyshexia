Scroll = {
	id = "scroll",
	desc = "Part of a spell! I can\ncombine it with\nother pages!",
	texture = love.graphics.newImage("assets/items/scroll.png"),
	width = 16,
	height = 16,
	scaleX = 1.5,
	scaleY = 1.5
}

function Scroll.onPickup(this)
	math.randomseed(os.time())
	local scrollType = math.random(2)
	local scrollName
	if (scrollType == 1) then
		scrollName = "element"
	-- This will later be extended to support modifiers, hence checking both for 1 and 2
	elseif (scrollType == 2) then
		scrollName = "pattern"
	end
	Heartbeat.player.addInventoryItem(generateRandomScroll(scrollName))
	Heartbeat.removeItem(this)
end

-- TODO: Uppercase the name
-- Okay so this is going to get very fucky very fast. Lua has NO length operator aside from #foo and that ONLY works if the table isn't a hashmap. So to get a random thing from Spells.element is impossible without doing pair traversal. Sometimes I hate lua.
-- Also type is a reserveword (sweet) so I'm just using class to specify if it's a pattern/element
function generateRandomScroll(class)
	local spellList = {}
	for k,v in pairs(Spells[class]) do
		spellList[#spellList+1] = k
	end

	local spellIndex = math.random(#spellList)
	local spellId = Spells[class][spellList[spellIndex]].id
	return {
		name = (spellId .. " " .. class),
		id = spellId
	}
end

