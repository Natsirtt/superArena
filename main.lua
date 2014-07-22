love.filesystem.load("maths/point.lua")()
love.filesystem.load("maths/vector.lua")()
love.filesystem.load("maths/segment.lua")()
love.filesystem.load("maths/quad.lua")()
love.filesystem.load("maths/collisions.lua")()
love.filesystem.load("animation.lua")()
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
love.filesystem.load("SuperCanvas.lua")()

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
    love.window.setMode(w, h, {
    -- love.window.setMode(w / 3, h / 3, {
        fullscreen = false,
        fsaa = 4,
        borderless = true
    })
    manager = newMenuManager()
end

local updateTime = 0
local updateCount= 0
local drawTime = 0
local drawCount= 0

function love.update(dt)

    local stime = love.timer.getTime()
    
    if (love.keyboard.isDown("escape")) then
        love.event.quit()
    end
    
	manager:update(dt)
    
    local etime = love.timer.getTime()
    updateTime = updateTime + 1000 * (etime - stime)
    updateCount = updateCount + 1
end

function love.draw()

    local stime = love.timer.getTime()
    
    manager:draw()
    
    local etime = love.timer.getTime()
    drawTime = updateTime + 1000 * (etime - stime)
    drawCount = drawCount + 1
    
    love.graphics.print("update : "..string.format("%.1f", (updateTime / updateCount)).."ms, draw : "..string.format("%.1f", (updateTime / updateCount)).."ms")
end

-- function tableString(table)
    -- local res = "{"
    -- for i,v in ipairs(table) do
        -- res = res .. i.."= {"..v:debugInfo().."}, "
    -- end
    -- return res .. "}"
-- end
