-- AI tools used in development:
-- Claude (Anthropic) - design planning, specifications, code generation
-- All game design, architecture, and creative decisions by Jamie "AJ" Tran

-- Add src/ to require path
love.filesystem.setRequirePath("src/?.lua;src/?/init.lua;" .. love.filesystem.getRequirePath())

local states = require("states")
local player = require("player")
local campfires = require("campfires")
local symbols = require("symbols")
local glyphs = require("glyphs")
local postfx = require("postfx")
local spikes = require("spikes")
local audio = require("audio")

local GROUND_Y = 0

local function drawWorld()
	local screenW = love.graphics.getWidth()
	local screenH = love.graphics.getHeight()

	-- Sky
	love.graphics.setColor(0.15, 0.1, 0.2)
	love.graphics.rectangle("fill", 0, 0, screenW, GROUND_Y)

	-- Ground
	love.graphics.setColor(0.25, 0.2, 0.15)
	love.graphics.rectangle("fill", 0, GROUND_Y, screenW, screenH - GROUND_Y)

	-- Ground line
	love.graphics.setColor(0.4, 0.35, 0.25)
	love.graphics.line(0, GROUND_Y, screenW, GROUND_Y)
end

local cameraX = 0
local activeCampfire = nil
local transitionTimer = 0
local TRANSITION_DURATION = 1.5
local centerFade = 0
local CENTER_FADE_DURATION = 4
local titleFont = nil
local promptFont = nil
local tipFont = nil
local tipTimer = 0
local TIP_DURATION = 5
local TIP_FADE = 1.5
local currentTip = nil

local function showTip(text)
	currentTip = text
	tipTimer = TIP_DURATION
end

local function updateTip(dt)
	if tipTimer > 0 then
		tipTimer = tipTimer - dt
	end
end

local function drawTip()
	if not currentTip or tipTimer <= 0 then return end
	local alpha = tipTimer < TIP_FADE and tipTimer / TIP_FADE or 1
	local screenW = love.graphics.getWidth()
	local screenH = love.graphics.getHeight()
	love.graphics.setFont(tipFont)
	love.graphics.setColor(0.6, 0.55, 0.5, alpha * 0.8)
	local tw = tipFont:getWidth(currentTip)
	love.graphics.print(currentTip, (screenW - tw) / 2, 20)
end

local function resetGame()
	player.reset()
	campfires.reset()
	symbols.reset()
	audio.stopAll()
	cameraX = 0
	activeCampfire = nil
	centerFade = 0
end

function love.load()
	player.load()
	GROUND_Y = player.y + player.height
	campfires.load(GROUND_Y)
	glyphs.load()
	postfx.load()
	spikes.load(GROUND_Y)
	audio.load()
	titleFont = love.graphics.newFont(48)
	promptFont = love.graphics.newFont(18)
	tipFont = love.graphics.newFont(20)

	states.register("start", {
		draw = function()
			local screenW = love.graphics.getWidth()
			local screenH = love.graphics.getHeight()

			-- Background
			love.graphics.setColor(0.08, 0.06, 0.1)
			love.graphics.rectangle("fill", 0, 0, screenW, screenH)

			-- Title
			love.graphics.setFont(titleFont)
			love.graphics.setColor(0.9, 0.85, 0.7)
			local title = "The Message"
			local tw = titleFont:getWidth(title)
			love.graphics.print(title, (screenW - tw) / 2, screenH / 2 - 60)

			-- Prompt
			love.graphics.setFont(promptFont)
			love.graphics.setColor(0.5, 0.45, 0.4)
			local prompt = "Press Enter to begin"
			local pw = promptFont:getWidth(prompt)
			love.graphics.print(prompt, (screenW - pw) / 2, screenH / 2 + 20)
		end,
		keypressed = function(key)
			if key == "return" then
				resetGame()
				showTip("Arrow keys to move  |  Esc to quit")
				states.set("walking")
			end
		end,
	})

	states.register("walking", {
		update = function(dt)
			player.update(dt)
			cameraX = player.x - love.graphics.getWidth() / 3

			local movingRight = love.keyboard.isDown("right", "d")
			local movingLeft = love.keyboard.isDown("left", "a")
			audio.updateFootsteps(dt, movingRight or movingLeft, movingRight)

			local idx = campfires.checkProximity(player.x)
			if idx then
				activeCampfire = idx
				symbols.activate(activeCampfire)
				showTip("Click to swap symbols  |  Enter to confirm")
				states.set("campfire")
			end
			updateTip(dt)
		end,
		draw = function()
			drawWorld()
			spikes.draw(cameraX)
			campfires.draw(cameraX)
			player.draw(cameraX)
			drawTip()
		end,
		keypressed = function(key)
			if key == "escape" then
				resetGame()
				states.set("start")
			end
		end,
	})

	states.register("transition", {
		update = function(dt)
			updateTip(dt)
			transitionTimer = transitionTimer - dt
			if transitionTimer <= 0 then
				if activeCampfire >= 5 then
					centerFade = 0
					audio.startCenter()
					states.set("center")
				else
					activeCampfire = nil
					states.set("walking")
				end
			end
		end,
		draw = function()
			drawWorld()
			spikes.draw(cameraX)
			campfires.draw(cameraX)
			player.draw(cameraX)
		end,
	})

	states.register("center", {
		update = function(dt)
			if centerFade < 1 then
				centerFade = math.min(1, centerFade + dt / CENTER_FADE_DURATION)
			end
			audio.updateCenter(dt)
		end,
		draw = function()
			drawWorld()
			spikes.draw(cameraX)
			campfires.draw(cameraX)
			player.draw(cameraX)

			-- Fade to black overlay
			love.graphics.setColor(0, 0, 0, centerFade)
			love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		end,
		keypressed = function(key)
			if key == "escape" then
				resetGame()
				states.set("start")
			end
		end,
	})

	states.register("campfire", {
		update = function(dt)
			updateTip(dt)
		end,
		draw = function()
			drawWorld()
			spikes.draw(cameraX)
			campfires.draw(cameraX)
			player.draw(cameraX)
			glyphs.draw(symbols.getActive(), symbols.getSelected())
			drawTip()
		end,
		keypressed = function(key)
			if key == "return" then
				audio.playClick()
				symbols.confirm(activeCampfire)
				campfires.markVisited(activeCampfire)
				transitionTimer = TRANSITION_DURATION
				states.set("transition")
			elseif key == "escape" then
				states.set("start")
			end
		end,
		mousepressed = function(x, y, button)
			if button ~= 1 then return end
			local active = symbols.getActive()
			if not active then return end
			local hit = glyphs.hitTest(#active, x, y)
			if hit then
				audio.playClick()
				symbols.select(hit)
			end
		end,
	})
end

function love.update(dt)
	postfx.update(dt)
	campfires.update(dt)
	states.update(dt)
end

function love.draw()
	postfx.beginDraw()
	states.draw()
	postfx.endDraw(symbols.getProgress().shaderParams)
end

function love.keypressed(key)
	states.keypressed(key)
end

function love.mousepressed(x, y, button)
	states.mousepressed(x, y, button)
end
