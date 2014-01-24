love.filesystem.load("arena.lua")()
love.filesystem.load("controllers/controller.lua")()
love.filesystem.load("controllers/controllersManager.lua")()
love.filesystem.load("players/player.lua")()

local globalTimer = 60 -- En secondes (à modfier)

function love.load(arg)
	love.window.setTitle("Bugfree Happiness")
    love.window.setMode(800, 800, {
        fullscreen = false,
        fsaa = 4,
    })
    
	arena = newArena()
end

playerOK = false
function love.update(dt)
	globalTimer = math.max(0, globalTimer - dt)

    if not playerOK then
        playerOK = getControllersManager():tryBindingNewController()
        if playerOK then
            player = newPlayer()
        end
    end
    
    if (love.keyboard.isDown("escape")) then
        love.event.quit()
    end
    if (love.keyboard.isDown("a")) then
        arena:destroyLeftDoor()
    end
	love.graphics.setNewFont(24)
    
    if playerOK then
        player:update(dt)
        local quad = arena:getValidQuad(nil, player:getQuad())
        player:setPositionFromQuad(quad)
    end
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	arena:draw()
	
	love.graphics.setNewFont(24)
	love.graphics.setColor(255, 0, 0)
	love.graphics.print(string.format("%d", globalTimer).."s", 390, 10)
    
    if playerOK then
        player:draw()
    end
end
