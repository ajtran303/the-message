local postfx = {}

local canvas = nil
local shader = nil
local elapsed = 0

function postfx.load()
	canvas = love.graphics.newCanvas()
	shader = love.graphics.newShader("assets/shaders/uber.glsl")
end

function postfx.beginDraw()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
end

function postfx.update(dt)
	elapsed = elapsed + dt
end

function postfx.endDraw(shaderParams)
	love.graphics.setCanvas()

	shader:send("hueShift", shaderParams[1])
	shader:send("vignette", shaderParams[2])
	shader:send("desaturate", shaderParams[3])
	shader:send("aberration", shaderParams[4])
	shader:send("wobble", shaderParams[5])
	shader:send("time", elapsed)

	love.graphics.setShader(shader)
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(canvas)
	love.graphics.setShader()
end

return postfx
