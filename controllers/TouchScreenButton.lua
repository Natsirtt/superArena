local mt = {}
mt.__index = mt

function newTouchScreenButton(radius, x, y, icon, iconDown)
    local this = {}
    
	this.buttonRadius = radius
	this.cx = x
	this.cy = y
	
	this.down = false
	
	this.icon = icon
	this.iconDown = iconDown
	
    return setmetatable(this, mt)
end

function mt:isDown()
    return self.down
end

function mt:update(dt)
	self.down = false
	if (love.touch) then
		local count = love.touch.getTouchCount()
		for i = 1, count do
			local _, tx, ty = love.touch.getTouch(i)
			tx = tx * love.graphics.getWidth()
			ty = ty * love.graphics.getHeight()
			local xp = (tx - self.cx)
			local yp = (ty - self.cy)
			local d = math.sqrt((xp * xp) + (yp * yp))
			self.down = (d < self.buttonRadius)
			count = love.touch.getTouchCount()
		end
	end
end

function mt:draw()
	love.graphics.setColor(255, 255, 255)
	if (self.down) then
		if self.iconDown then
			love.graphics.draw(self.iconDown, self.cx - self.iconDown:getWidth() / 2, self.cy - self.iconDown:getHeight() / 2)
		end
		love.graphics.setColor(255, 0, 0)
	else
		if self.icon then
			love.graphics.draw(self.icon, self.cx - self.icon:getWidth() / 2, self.cy - self.icon:getHeight() / 2)
		end
	end
	love.graphics.circle("line", self.cx, self.cy, self.buttonRadius)

	
	love.graphics.setColor(255, 255, 255)
end
