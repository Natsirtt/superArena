love.filesystem.load("level.lua")()
love.filesystem.load("arena.lua")()
love.filesystem.load("controllers/controller.lua")()
love.filesystem.load("controllers/controllersManager.lua")()
love.filesystem.load("players/player.lua")()
love.filesystem.load("gameManager.lua")()
love.filesystem.load("maths/point.lua")()
love.filesystem.load("maths/vector.lua")()
love.filesystem.load("maths/segment.lua")()
love.filesystem.load("maths/collisions.lua")()
love.filesystem.load("assets/assetsManager.lua")()
love.filesystem.load("assets/UI.lua")()

local gameManager

function love.load(arg)
	love.graphics.setDefaultFilter("linear", "linear", 1)
	love.window.setTitle("Super ARENA ultimate frenzy saga deluxe - GOTY edition")
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
    --local quad1 = {{x = 10, y = 10}, {x = 10, y = 12}, {x = 12, y = 12}, {x = 12, y = 10},}
    --local quad2 = {{x = 90, y = 90}, {x = 90, y = 120}, {x = 120, y = 120}, {x = 120, y = 90},}
    --print("DEBUG : " .. tostring(rectCollision(quad1, quad2)))
end

-- function tableString(table)
    -- local res = "{"
    -- for i,v in ipairs(table) do
        -- res = res .. i.."= {"..v:debugInfo().."}, "
    -- end
    -- return res .. "}"
-- end
