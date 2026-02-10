local spikes = {}

local list = {}
local groundY = 0

function spikes.load(playerGroundY)
	groundY = playerGroundY
	list = {}

	local screenW = love.graphics.getWidth()
	local worldEnd = screenW * 13
	local x = screenW * 0.5

	while x < worldEnd do
		-- Progress 0..1 across the world
		local t = x / worldEnd

		-- Density increases toward center: gap shrinks from 120 to 20
		local gap = 120 - 100 * t * t

		-- Height increases toward center
		local minH = 20 + 120 * t
		local maxH = 60 + 300 * t
		local h = minH + math.random() * (maxH - minH)

		-- Width narrows slightly toward center
		local w = 6 + math.random() * 10 * (1 - t * 0.5)

		-- Slight horizontal jitter
		local jitter = (math.random() - 0.5) * gap * 0.3

		list[#list + 1] = {
			x = x + jitter,
			height = h,
			width = w,
			-- Fade in: visible early, solid late
			alpha = 0.25 + 0.65 * t,
		}

		x = x + gap + math.random() * gap * 0.5
	end
end

function spikes.draw(cameraX)
	local screenW = love.graphics.getWidth()

	for _, s in ipairs(list) do
		local sx = s.x - cameraX
		-- Cull offscreen
		if sx > -s.width and sx < screenW + s.width then
			love.graphics.setColor(0.05, 0.02, 0.05, s.alpha)
			-- Triangle spike rising from ground
			love.graphics.polygon("fill",
				sx - s.width / 2, groundY,
				sx, groundY - s.height,
				sx + s.width / 2, groundY
			)
		end
	end
end

return spikes
