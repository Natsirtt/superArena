local function getMiddlePoint(p1, p2)
	return {x = (p1.x - p2.x) / 2 + p1.x,
			y = (p1.y - p2.y) / 2 + p1.y}
end

function rectCollision(quad1, quad2)
	
end

-- returns two tables, one for each axis, with a point (the origin of the vector) and a vector
function rectGetAxes(quad)
	local res = {}
	local m1 = getMiddlePoint(quad.p1, quad.p3)
	local m2 = getMiddlePoint(quad.p2, quad.p4)

	local origin = getMiddlePoint(m1, m2)
	res["origin"] = newPoint(origin.x, origin.y)
	res["axis1"] = newVector(m1.x, m1.y)
	res["axis2"] = newVector(m1.y, -m1.x) -- simplified vectoriel product
	return res
end
