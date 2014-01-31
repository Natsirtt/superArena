local mt = {}
mt.__index = mt

function newSegment(p1, p2)
    local this = {}

    this.p1 = {x = p1.x, y = p1.y}
    this.p2 = {x = p2.x, y = p2.y}

    if (p1.x > p2.x) then
    	local p = this.p2
    	this.p2 = this.p1
    	this.p1 = p
    end
    
    return setmetatable(this, mt)
end

function mt:min(seg)
	if self.x < seg.x then
		return self
	end
	return seg
end

function mt:max(seg)
	if self.x > seg.x then
		return self
	end
	return seg
end

function mt:overlaps(segment)
	if (segment == nil) then
		love.event.quit()
	end
	local minX = math.min(segment.p1.x, self.p1.x)
	local minX2 = math.min(segment.p2.x, self.p2.x)

	if (self.p1.x == segment.p1.x) then
		-- we use fake segments to verify
		return newSegment(newPoint(self.p1.y, -self.p1.x), newPoint(self.p2.y, -self.p2.x)):overlaps(
						newSegment(newPoint(segment.p1.y, -segment.p1.x), newPoint(segment.p2.y, -segment.p2.x)))
	end

	-- first case : one segment totally eat the other
	if ((minX == self.p1.x) and (minX2 == segment.p2.x)) or
	   ((minX == segment.p1.x)  and (minX2 == self.p2.x)) then
		return true
	end

	-- now one segment is partially over the other
	if ((minX == self.p1.x) and (segment.p1.x <= self.p2.x)) or
		 ((minX == segment.p1.x) and (self.p1.x <= segment.p2.x)) then
		return true
	end

	return false
end
