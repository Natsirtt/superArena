local mt = {}
mt.__index = mt

function newPoint(x, y)
    local self = {}

    self.x = x
    self.y = y
    
    return setmetatable(self, mt)
end

function mt:copy()
    return newPoint(self.x, self.y)
end


function mt:min(p)
    if self.x < p.x then
        return self
    end
    return p
end

function mt:max(p)
    if self.x > p.x then
        return self
    end
    return p
end

function mt:projectOnLine(p, vector)
    local bc = vector:copy()
    local ba = newVector(self.x - p.x, self.y - p.y)
    local baPrimeNorme = ba:scalar(bc) / bc:norme()
    bc:normalize()

    return newPoint(p.x + bc.x * baPrimeNorme,
                    p.y + bc.y * baPrimeNorme)
end

function mt:debugInfo()
    return "x = " .. self.x .. " - y = " .. self.y
end
