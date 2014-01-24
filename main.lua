love.filesystem.load("arena.lua")()


function love.load(arg)
	arena = newArena()
end

function love.update(dt)
	
end

function love.draw()
	arena:draw()
end
