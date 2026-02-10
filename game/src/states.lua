local states = {}

local current = "start"

local handlers = {
	start = {},
	walking = {},
	campfire = {},
	transition = {},
	center = {},
}

function states.get()
	return current
end

function states.set(name)
	assert(handlers[name], "Invalid state: " .. tostring(name))
	current = name
end

function states.register(name, fns)
	assert(handlers[name], "Invalid state: " .. tostring(name))
	handlers[name] = fns
end

function states.update(dt)
	local h = handlers[current]
	if h.update then h.update(dt) end
end

function states.draw()
	local h = handlers[current]
	if h.draw then h.draw() end
end

function states.keypressed(key)
	local h = handlers[current]
	if h.keypressed then h.keypressed(key) end
end

function states.mousepressed(x, y, button)
	local h = handlers[current]
	if h.mousepressed then h.mousepressed(x, y, button) end
end

return states
