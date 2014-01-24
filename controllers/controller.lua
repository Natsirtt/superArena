local mt = {}
mt.__index = mt

function newController(joystick)
    local this = {}
    
    this.joystick = joystick
    
    return setmetatable(this, mt)
end

function mt:getID()
    return self.joystick:getID()
end

function mt:isConnected()
    return self.joystick:isConnected()
end

function mt:isDown(buttonN, ...)
    return self.joystick:isDown(buttonN, ...)
end

function mt:getAxes()
    local x, y = self.joystick:getAxes()
    
    if x <= -0.5 then
        x = -1
    elseif x >= 0.5 then
        x = 1
    else
        x = 0
    end
    
    if y <= -0.5 then
        y = -1
    elseif y >= 0.5 then
        y = 1
    else
        y = 0
    end
    
    return x, y
end

function mt:getX()
    local x = self:getAxes()
    return x
end

function mt:getY()
    local x, y = self:getAxes()
    return y
end
