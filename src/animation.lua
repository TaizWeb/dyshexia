Animation = {
	animationList = {}
}

-- Format
-- func: someFunc
-- frameLimit: 60 (last for a second)
-- currentFrame: 0 (will be incremented and passed)

-- doAnimations: Executes every animation in the list
function Animation.doAnimations()
	for i=1,#Animation.animationList do
		local animation = Animation.animationList[i]
		-- Reset color
		love.graphics.setColor(1, 1, 1, 1)
		-- Base case for if an animation is removed, or none exist
		if (animation == nil) then return end
		if (animation.currentFrame < animation.frameLimit) then
			-- If the animation is still running, pass the frame to it
			animation.func(animation.currentFrame, animation.data)
			animation.currentFrame = animation.currentFrame + 1
		else
			-- Else, remove it
			table.remove(Animation.animationList, i)
		end
	end
end

-- newAnimation: Adds a new animation to the list to be executed
function Animation.newAnimation(func, frameLimit, data)
	Animation.animationList[#Animation.animationList + 1] = {
		func = func,
		data = data, -- This is an optional parameter for functions that require other data
		frameLimit = frameLimit,
		currentFrame = 0
	}
end

