local mt = {}
mt.__index = mt

function newVector(x, y)
    local self = {}

    self.x = x
    self.y = y
    
    return setmetatable(self, mt)
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
	return math.sqrt(self.x * self.x + self.y * self.y)
end

function mt:normalize()
	local n = self:norme()
	self.x = self.x / n
	self.y = self.y / n
end

function mt:scalar(vector)
	return self.x * vector.x + self.y * vector.y
end
