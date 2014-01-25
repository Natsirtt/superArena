local mt = {}
mt.__index = mt

local SHAKE_LIMIT = 0.2
local SHAKE_AMPLITUDE = 20.0
local SHAKE_PER_SECOND = 20.0

local BLINK_LIMIT = 0.2
local BLINK_PER_SECOND = 20.0

function newCamera()
    local this = {}
	
	this.shakeSound = love.audio.newSource("shake.wav", "static")
	this.shakeSound:setLooping(true)
	this.shakeTimer = 0.0
	this.blinkTimer = 0.0
	this.blinkColor = {r = 255, g = 0, b = 255}
	
    return setmetatable(this, mt)
end


function mt:update(dt)
	self.shakeTimer = math.max(self.shakeTimer - dt, 0.0)
	self.blinkTimer = math.max(self.blinkTimer - dt, 0.0)
end

function mt:draw()
	if (self.shakeTimer ~= 0) then
		local dx = math.sin(math.rad((SHAKE_LIMIT - self.shakeTimer * SHAKE_PER_SECOND * 360.0))) * SHAKE_AMPLITUDE
		local dy = math.cos(math.rad((SHAKE_LIMIT - self.shakeTimer * SHAKE_PER_SECOND * 360.0))) * SHAKE_AMPLITUDE
		love.graphics.translate(dx, dy)
	else
		love.audio.stop(self.shakeSound)
	end
	
	local percent = math.sin(math.rad((BLINK_LIMIT - self.blinkTimer * SHAKE_PER_SECOND * 360.0)))
	if (blinkTimer ~= 0) then
		percent = math.abs(percent)
		local r = self.blinkColor.r + (255 - self.blinkColor.r) * (1 - percent)
		local g = self.blinkColor.g + (255 - self.blinkColor.g) * (1 - percent)
		local b = self.blinkColor.b + (255 - self.blinkColor.b) * (1 - percent)
		love.graphics.setColor(r, g, b)
	else
		love.graphics.setColor(255, 255, 255)
	end
end


function mt:shake()
	self.shakeTimer = SHAKE_LIMIT
	love.audio.play(self.shakeSound)
end

function mt:blink(color)
	self.blinkTimer = BLINK_LIMIT
	self.blinkColor = color
end