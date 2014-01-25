love.filesystem.load("level.lua")()
love.filesystem.load("arena.lua")()
love.filesystem.load("controllers/controller.lua")()
love.filesystem.load("controllers/controllersManager.lua")()
love.filesystem.load("players/player.lua")()
love.filesystem.load("gameManager.lua")()

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

function love.update(dt)
    
    if (love.keyboard.isDown("escape")) then
        love.event.quit()
    end
    
	gameManager:update(dt)
end

function love.draw()
    gameManager:draw()
end
