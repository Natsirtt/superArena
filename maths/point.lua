local mt = {}
mt.__index = mt

function newPoint(x, y)
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

function mt:projectOnLine(point, vector)
    local bc = vector:copy()
    local ba = newVector(self:getX() - p:getX(), self:getY() - p:getY())
    local baPrimeNorme = ba:scalar(bc) / bc:norme()
    bc:normalize()
    return newPoint(p:getX() + bc:getX() * baPrimeNorme,
                    p:getY() + bc:getY() * baPrimeNorme)
end
