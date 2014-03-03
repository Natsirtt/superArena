love.filesystem.load("maths/point.lua")()
love.filesystem.load("maths/vector.lua")()
love.filesystem.load("maths/segment.lua")()
love.filesystem.load("maths/collisions.lua")()
love.filesystem.load("controllers/gamepadController.lua")()
love.filesystem.load("controllers/keyboardController.lua")()
love.filesystem.load("controllers/TouchScreenController.lua")()
love.filesystem.load("controllers/controllersManager.lua")()
love.filesystem.load("controllers/iaController.lua")()
love.filesystem.load("level.lua")()
love.filesystem.load("arena.lua")()
love.filesystem.load("players/player.lua")()
love.filesystem.load("menuManager.lua")()
love.filesystem.load("gameManager.lua")()
love.filesystem.load("assets/assetsManager.lua")()
love.filesystem.load("assets/UI.lua")()
love.filesystem.load("gui/playerConnectionGui.lua")()

thread = love.thread.newThread("server.lua")

local manager = nil
world = nil

function love.load(arg)
	thread:start()
    io.stdout:setvbuf("no") -- useful for live print() in the console on Windows
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	love.window.setTitle("Super ARENA ultimate frenzy saga deluxe - GOTY edition")

    local _, _, flags = love.window.getMode()
    local w, h = love.window.getDesktopDimensions(flags.display)
    love.window.setMode(w / 3, h / 3, {
        fullscreen = false,
        fsaa = 4,
        borderless = true
    })
    manager = newMenuManager()
end

function love.update(dt)
    
    if (love.keyboard.isDown("escape")) then
        love.event.quit()
    end
    
	manager:update(dt)
end

function love.draw()
    manager:draw()
end

-- function tableString(table)
    -- local res = "{"
    -- for i,v in ipairs(table) do
        -- res = res .. i.."= {"..v:debugInfo().."}, "
    -- end
    -- return res .. "}"
-- end
