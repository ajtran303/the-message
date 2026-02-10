local glyphs = {}

local canvases = {}
local SLOT_SIZE = 64
local PADDING = 12
local SYM_SIZE = 48

local function drawSigil(id)
	local c = love.graphics.newCanvas(SYM_SIZE, SYM_SIZE)
	love.graphics.setCanvas(c)
	love.graphics.clear(0, 0, 0, 0)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(1.5)

	local cx, cy = SYM_SIZE / 2, SYM_SIZE / 2
	local r = SYM_SIZE / 2 - 4

	if id == 1 then
		-- Pentagram
		local pts = {}
		for i = 0, 4 do
			local a = math.rad(-90 + i * 72)
			pts[#pts + 1] = cx + math.cos(a) * r
			pts[#pts + 1] = cy + math.sin(a) * r
		end
		local order = {1, 3, 5, 2, 4, 1}
		for i = 1, #order - 1 do
			local a, b = order[i], order[i + 1]
			love.graphics.line(pts[a*2-1], pts[a*2], pts[b*2-1], pts[b*2])
		end

	elseif id == 2 then
		-- Concentric circles
		love.graphics.circle("line", cx, cy, r)
		love.graphics.circle("line", cx, cy, r * 0.6)
		love.graphics.circle("line", cx, cy, r * 0.25)

	elseif id == 3 then
		-- Eye of providence
		love.graphics.polygon("line", cx, cy - r * 0.6, cx - r, cy + r * 0.3, cx + r, cy + r * 0.3)
		love.graphics.circle("line", cx, cy, r * 0.3)
		love.graphics.circle("fill", cx, cy, r * 0.12)

	elseif id == 4 then
		-- Spiral
		local pts = {}
		for i = 0, 60 do
			local t = i / 60
			local a = t * math.pi * 4
			local sr = t * r
			pts[#pts + 1] = cx + math.cos(a) * sr
			pts[#pts + 1] = cy + math.sin(a) * sr
		end
		love.graphics.line(pts)

	elseif id == 5 then
		-- Cross with circle
		love.graphics.circle("line", cx, cy, r)
		love.graphics.line(cx, cy - r, cx, cy + r)
		love.graphics.line(cx - r, cy, cx + r, cy)

	elseif id == 6 then
		-- Crescent moon
		love.graphics.arc("line", "open", cx - 4, cy, r, -math.pi/2, math.pi/2)
		love.graphics.arc("line", "open", cx + 6, cy, r * 0.7, -math.pi/2, math.pi/2)

	elseif id == 7 then
		-- Triangle up
		love.graphics.polygon("line", cx, cy - r, cx - r, cy + r * 0.7, cx + r, cy + r * 0.7)
		love.graphics.line(cx - r * 0.6, cy + r * 0.1, cx + r * 0.6, cy + r * 0.1)

	elseif id == 8 then
		-- Inverted triangle
		love.graphics.polygon("line", cx, cy + r, cx - r, cy - r * 0.7, cx + r, cy - r * 0.7)
		love.graphics.line(cx - r * 0.6, cy - r * 0.1, cx + r * 0.6, cy - r * 0.1)

	elseif id == 9 then
		-- Hexagon
		local hex = {}
		for i = 0, 5 do
			local a = math.rad(-90 + i * 60)
			hex[#hex + 1] = cx + math.cos(a) * r
			hex[#hex + 1] = cy + math.sin(a) * r
		end
		love.graphics.polygon("line", hex)

	elseif id == 10 then
		-- Ankh
		love.graphics.circle("line", cx, cy - r * 0.35, r * 0.35)
		love.graphics.line(cx, cy, cx, cy + r)
		love.graphics.line(cx - r * 0.4, cy + r * 0.3, cx + r * 0.4, cy + r * 0.3)

	elseif id == 11 then
		-- Triple moon
		love.graphics.circle("line", cx, cy, r * 0.4)
		love.graphics.arc("line", "open", cx - r * 0.5, cy, r * 0.7, -math.pi/2, math.pi/2)
		love.graphics.arc("line", "open", cx + r * 0.5, cy, r * 0.7, math.pi/2, math.pi * 1.5)

	elseif id == 12 then
		-- Serpent S
		love.graphics.arc("line", "open", cx, cy - r * 0.3, r * 0.4, math.pi, 0)
		love.graphics.arc("line", "open", cx, cy + r * 0.3, r * 0.4, 0, math.pi)
		love.graphics.circle("fill", cx + r * 0.4, cy - r * 0.3, 2)

	elseif id == 13 then
		-- Radiant sun
		love.graphics.circle("line", cx, cy, r * 0.35)
		for i = 0, 7 do
			local a = i * math.pi / 4
			love.graphics.line(
				cx + math.cos(a) * r * 0.45, cy + math.sin(a) * r * 0.45,
				cx + math.cos(a) * r, cy + math.sin(a) * r
			)
		end

	elseif id == 14 then
		-- Diamond nested
		local function diamond(s)
			love.graphics.polygon("line", cx, cy - s, cx + s, cy, cx, cy + s, cx - s, cy)
		end
		diamond(r)
		diamond(r * 0.55)

	elseif id == 15 then
		-- Arrow down with crossbar
		love.graphics.line(cx, cy - r, cx, cy + r)
		love.graphics.line(cx - r * 0.5, cy + r * 0.4, cx, cy + r, cx + r * 0.5, cy + r * 0.4)
		love.graphics.line(cx - r * 0.4, cy - r * 0.2, cx + r * 0.4, cy - r * 0.2)
		love.graphics.line(cx - r * 0.3, cy + r * 0.05, cx + r * 0.3, cy + r * 0.05)

	elseif id == 16 then
		-- Infinity / lemniscate
		local pts = {}
		for i = 0, 60 do
			local t = (i / 60) * math.pi * 2
			local scale = r * 0.9 / (1 + math.sin(t) * math.sin(t))
			pts[#pts + 1] = cx + math.cos(t) * scale
			pts[#pts + 1] = cy + math.sin(t) * math.cos(t) * scale * 0.6
		end
		love.graphics.line(pts)

	elseif id == 17 then
		-- Three vertical lines with dots
		for i = -1, 1 do
			local lx = cx + i * r * 0.4
			love.graphics.line(lx, cy - r * 0.7, lx, cy + r * 0.7)
			love.graphics.circle("fill", lx, cy - r * 0.85, 2)
		end

	elseif id == 18 then
		-- Hourglass
		love.graphics.polygon("line", cx - r * 0.7, cy - r, cx + r * 0.7, cy - r, cx, cy)
		love.graphics.polygon("line", cx - r * 0.7, cy + r, cx + r * 0.7, cy + r, cx, cy)

	elseif id == 19 then
		-- Trident
		love.graphics.line(cx, cy + r, cx, cy - r * 0.5)
		love.graphics.arc("line", "open", cx - r * 0.35, cy - r * 0.3, r * 0.35, math.pi, 0)
		love.graphics.arc("line", "open", cx + r * 0.35, cy - r * 0.3, r * 0.35, math.pi, 0)
		love.graphics.line(cx - r * 0.7, cy - r * 0.3, cx - r * 0.7, cy - r)
		love.graphics.line(cx, cy - r * 0.65, cx, cy - r)
		love.graphics.line(cx + r * 0.7, cy - r * 0.3, cx + r * 0.7, cy - r)

	elseif id == 20 then
		-- Void circle with dot
		love.graphics.circle("line", cx, cy, r)
		love.graphics.circle("fill", cx, cy, 3)
	end

	love.graphics.setCanvas()
	return c
end

function glyphs.load()
	canvases = {}
	for i = 1, 20 do
		canvases[i] = drawSigil(i)
	end
end

function glyphs.getSlotSize()
	return SLOT_SIZE
end

function glyphs.getPadding()
	return PADDING
end

function glyphs.draw(symbolIds, selectedIndex)
	if not symbolIds then return end

	local count = #symbolIds
	local totalWidth = count * SLOT_SIZE + (count - 1) * PADDING
	local screenW = love.graphics.getWidth()
	local screenH = love.graphics.getHeight()
	local startX = (screenW - totalWidth) / 2
	local y = screenH / 2 - SLOT_SIZE / 2

	for i, id in ipairs(symbolIds) do
		local x = startX + (i - 1) * (SLOT_SIZE + PADDING)

		-- Slot background
		if i == selectedIndex then
			love.graphics.setColor(0.8, 0.6, 0.2)
		else
			love.graphics.setColor(0.2, 0.2, 0.2)
		end
		love.graphics.rectangle("fill", x, y, SLOT_SIZE, SLOT_SIZE, 4, 4)

		-- Slot border
		if i == selectedIndex then
			love.graphics.setColor(1, 0.85, 0.4)
		else
			love.graphics.setColor(0.5, 0.5, 0.5)
		end
		love.graphics.rectangle("line", x, y, SLOT_SIZE, SLOT_SIZE, 4, 4)

		-- Symbol canvas
		love.graphics.setColor(1, 1, 1)
		local canvas = canvases[id]
		if canvas then
			local ox = x + (SLOT_SIZE - SYM_SIZE) / 2
			local oy = y + (SLOT_SIZE - SYM_SIZE) / 2
			love.graphics.draw(canvas, ox, oy)
		end
	end
end

function glyphs.hitTest(symbolCount, mx, my)
	local totalWidth = symbolCount * SLOT_SIZE + (symbolCount - 1) * PADDING
	local screenW = love.graphics.getWidth()
	local screenH = love.graphics.getHeight()
	local startX = (screenW - totalWidth) / 2
	local y = screenH / 2 - SLOT_SIZE / 2

	for i = 1, symbolCount do
		local x = startX + (i - 1) * (SLOT_SIZE + PADDING)
		if mx >= x and mx <= x + SLOT_SIZE and my >= y and my <= y + SLOT_SIZE then
			return i
		end
	end
	return nil
end

return glyphs
