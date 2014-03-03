local mt = {}
mt.__index = mt

-- global array (to use like a buttons enum)
buttons = {
    A = 0,
    B = 1,
    X = 2,
    Y = 3,
    UP = 4,
    DOWN = 5,
    LEFT = 6,
    RIGHT = 7,
    JOYSTICK_LEFT = 8,
    JOYSTICK_RIGHT = 9,
    LB = 10,
    RB = 11,
    START = 14,
    SELECT = 15
}

local buttonsMap = {}

buttonsMap["Windows"] = {}
buttonsMap["Linux"] = {}
buttonsMap["OS X"] = {}
buttonsMap["Android"] = {}

-- Initializing all arrays manually to have cross-platforme coherence in inputs
buttonsMap["Windows"][buttons.A] = 10
buttonsMap["Windows"][buttons.B] = 11
buttonsMap["Windows"][buttons.X] = 12
buttonsMap["Windows"][buttons.Y] = 13
buttonsMap["Windows"][buttons.JOYSTICK_LEFT] = 6
buttonsMap["Windows"][buttons.JOYSTICK_RIGHT] = 7
buttonsMap["Windows"][buttons.UP] = 0
buttonsMap["Windows"][buttons.DOWN] = 1
buttonsMap["Windows"][buttons.LEFT] = 2
buttonsMap["Windows"][buttons.RIGHT] = 3
buttonsMap["Windows"][buttons.START] = 4
buttonsMap["Windows"][buttons.SELECT] = 5
buttonsMap["Windows"][buttons.LB] = 8
buttonsMap["Windows"][buttons.RB] = 9

buttonsMap["Linux"][buttons.A] = 10
buttonsMap["Linux"][buttons.B] = 11
buttonsMap["Linux"][buttons.X] = 12
buttonsMap["Linux"][buttons.Y] = 13
buttonsMap["Linux"][buttons.JOYSTICK_LEFT] = 6
buttonsMap["Linux"][buttons.JOYSTICK_RIGHT] = 7
buttonsMap["Linux"][buttons.UP] = 0
buttonsMap["Linux"][buttons.DOWN] = 1
buttonsMap["Linux"][buttons.LEFT] = 2
buttonsMap["Linux"][buttons.RIGHT] = 3
buttonsMap["Linux"][buttons.START] = 4
buttonsMap["Linux"][buttons.SELECT] = 5
buttonsMap["Linux"][buttons.LB] = 8
buttonsMap["Linux"][buttons.RB] = 9

buttonsMap["OS X"][buttons.A] = 10
buttonsMap["OS X"][buttons.B] = 11
buttonsMap["OS X"][buttons.X] = 12
buttonsMap["OS X"][buttons.Y] = 13
buttonsMap["OS X"][buttons.JOYSTICK_LEFT] = 6
buttonsMap["OS X"][buttons.JOYSTICK_RIGHT] = 7
buttonsMap["OS X"][buttons.UP] = 0
buttonsMap["OS X"][buttons.DOWN] = 1
buttonsMap["OS X"][buttons.LEFT] = 2
buttonsMap["OS X"][buttons.RIGHT] = 3
buttonsMap["OS X"][buttons.START] = 4
buttonsMap["OS X"][buttons.SELECT] = 5
buttonsMap["OS X"][buttons.LB] = 8
buttonsMap["OS X"][buttons.RB] = 9

buttonsMap["Android"][buttons.A] = 10
buttonsMap["Android"][buttons.B] = 11
buttonsMap["Android"][buttons.X] = 12
buttonsMap["Android"][buttons.Y] = 13
buttonsMap["Android"][buttons.JOYSTICK_LEFT] = 6
buttonsMap["Android"][buttons.JOYSTICK_RIGHT] = 7
buttonsMap["Android"][buttons.UP] = 0
buttonsMap["Android"][buttons.DOWN] = 1
buttonsMap["Android"][buttons.LEFT] = 2
buttonsMap["Android"][buttons.RIGHT] = 3
buttonsMap["Android"][buttons.START] = 4
buttonsMap["Android"][buttons.SELECT] = 5
buttonsMap["Android"][buttons.LB] = 8
buttonsMap["Android"][buttons.RB] = 9

function newGamepadController(joystick)
    local this = {}
    
	this.isGamePad = true
    this.joystick = joystick
	this.player = nil
    this.buttons = buttons[love.system.getOS()]
    
    return setmetatable(this, mt)
end

function mt:getStartButton()
	return 4
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

function mt:isAnyDown()
    if self:isDown(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22) then --ugh, what?
        return true
    end
    return false
end

function mt:isAttackButtonDown()
    
end

function mt:rumble(f)
	if (self.joystick:isVibrationSupported()) then
		self.joystick:setVibration(f, f)
	end
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
    local _, y = self:getAxes()
    return y
end

function mt:bind(player)
	self.player = player
end

function mt:update(dt)
	if (self.player ~= nil) and (self.joystick:isConnected()) then
		local dx, dy = self:getAxes()
		local oldDX, oldDY = self.player:getDirection()
		if (dx ~= oldDX) or (dy ~= oldDY) then
			self.player:setDirection(dx, dy)
		end
		
		if (self:isDown(11)) then
			self.player:setDefending(true)
		else
			self.player:setDefending(false)
			if (self:isDown(10)) then
				self.player:attack()
			end
		end
		if (self:isDown(12)) then
			self.player:dash()
		end
		if (self:isDown(13)) then
			self.player:hit(self.player.life)
		end
	end
end

function mt:draw()
    for i = 0, 20 do
        if self:isDown(i) then
            love.graphics.print(i, 20, 20)
            break
        end
    end
end
