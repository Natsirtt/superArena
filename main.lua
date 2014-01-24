love.filesystem.load("arena.lua")()
love.filesystem.load("controllers/controller.lua")()
love.filesystem.load("controllers/controllersManager.lua")()

function love.load(arg)    
	love.window.setTitle("Bugfree Happiness")
    love.window.setMode(800, 800, {
        fullscreen = false,
        fsaa = 4,
    })
	arena = newArena()
end


function love.update(dt)
    if (love.keyboard.isDown("escape")) then
        love.event.quit()
    end
    if (love.keyboard.isDown("a")) then
        arena:destroyLeftDoor()
    end
end

function love.draw()
	arena:draw()
end
