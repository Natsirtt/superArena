local mt = {}
mt.__index = mt

function newVector(x, y)
    local self = {}

    self.x = x
    self.y = y
    
    return setmetatable(this, mt)
end

function mt:copy()
    return newPoint(self.x, self.y)
end

function mt:getX()
    return self.x
end

function mt:getY()
    return self.y
end

function mt:copy()
	return newVector(self:getX(), self:getY())
end

function mt:norme()
	return math.sqrt(self:getX() * self:getX() + self:getY() * self:getY())
end

function mt:normalize()
	local oldNorme = self:norme()
	self.x = self.x / oldNorme
	self.y = self.y / oldNorme
end

function mt:scalar(vector)
	return self:getX() * vector:getX() + self:getY() * vector:getY()
end
