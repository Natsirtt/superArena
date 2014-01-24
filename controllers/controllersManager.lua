local mt = {}
mt.__index = mt

local init = false
local instance = {}

function getControllersManager()
    if not init then
        local this = {}
        
        this.unbindedControllers = {}
        this.bindedControllers = {}
        
        for i, j in ipairs(love.joystick.getJoysticks()) do
            this.unbindedControllers[#this.unbindedControllers + 1] = newController(j)
        end
    
        instance = setmetatable(this, mt)
        init = true
    end
    return instance
end

function mt:getFirstNewController()
    local controller = nil
    local pos = -1
    for i, c in ipairs(self.unbindedControllers) do
        if c:isDown(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22) then --ugh, what?
            controller = c
            pos = i
            break
        end
    end
    return controller, pos
end

function mt:tryBindingControllerToNextPlayer()
    local c, pos = self:getFirstNewController()
    if c ~= nil then
        self.bindedControllers[#self.bindedControllers +1] = c
        table.remove(self.unbindedControllers, pos)
    end
end

function mt:getControllerForPlayer(playerNo)
    return self.bindedControllers[playerNo]
end

function mt:getUnbindedControllers()
    return self.unbindedControllers
end

function mt:getBindedControllers()
    return self.bindedControllers
end

function mt:debugInfo()
    local res = "unbinded = { "
    for i, c in ipairs(self.unbindedControllers) do
        res = res .. c:getID() .. ", "
    end
    res = res .. "} - binded = { "
    for i, c in ipairs(self.bindedControllers) do
        res = res .. i .. " = " .. c:getID() .. ", "
    end
    res = res .. "}"
    return res
end
