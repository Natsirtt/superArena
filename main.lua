love.filesystem.load("arena.lua")()
love.filesystem.load("controllers/controller.lua")()
love.filesystem.load("controllers/controllersManager.lua")()
love.filesystem.load("players/player.lua")()
love.filesystem.load("gameManager.lua")()

local globalTimer = 60 -- En secondes (à modfier)
local gameManager

function love.load(arg)
	love.window.setTitle("Bugfree Happiness")
    local _, _, flags = love.window.getMode()
    local w, h = love.window.getDesktopDimensions(flags.display)
    love.window.setMode(w, h, {
        fullscreen = false,
        fsaa = 4,
        borderless = true
    })
    gameManager = newGameManager()
end

playerOK = false
function love.update(dt)
	globalTimer = math.max(0, globalTimer - dt)
    
    if (love.keyboard.isDown("escape")) then
        love.event.quit()
    end
    
	gameManager:update(dt)
end

function love.draw()
	love.graphics.setColor(255, 255, 255)

    gameManager:draw()
	
	love.graphics.setNewFont(24)
	love.graphics.setColor(255, 0, 0)
	love.graphics.print(string.format("%d", globalTimer).."s", 390, 10)
    
    if playerOK then
        player:draw()
    end
end
