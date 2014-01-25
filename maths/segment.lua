local mt = {}
mt.__index = mt

function newSegment(p1, p2)
    local self = {}

    self.p1 = {p1.x, p1.y}
    self.p2 = {p2.x, p2.y}

    if (p1.x > p2.x) then
    	local p = self.p2
    	self.p2 = self.p1
    	self.p1 = p
    end
    
    return setmetatable(this, mt)
end

function mt:getX()
	return self.x
end

function mt:getY()
	return self.y
end

function mt:min(seg)
	if self:getX() < seg:getX() then
		return self
	end
	return seg
end

function mt:max(seg)
	if self:getX() > seg:getX() then
		return self
	end
	return seg

function mt:overlap(segment)
	local minX = maths.min(segment:getX(), self:getX())
	local minY = maths.min(segment:getY(), self:getY())

	if (self:getX() == segment:getX()) then
		-- we use fake segments to verify
		return newSegment(self:getY(), self:getX()):overlap(newSegment(segment:getY(), segment:getX()))
	end

	-- first case : one segment totally eat the other
	if ((minX == self:getX()) and (minY == segment:getY())) or
	   ((minX == segment:getX())  and (mint y == self:getY())) then
		return true
	end

	-- now one segment is partially over the other
	if ((minX == self:getX()) and (segment:getX() <= self:getY())) or
		 ((minX == segment:getX()) and (self:getX() <= segment:getY())) then
		return true
	end

	return false
end
