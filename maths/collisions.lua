-- returns the segment that contains all of those points (points are aligned)
local function getSegment(pointsTable)
	local p1 = pointsTable[1]
	local p2 = pointsTable[2]
	local p3 = pointsTable[3]
	local p4 = pointsTable[4]

	if p1:getX() == p2:getX() then
		-- all 4 are aligned
		local seg = getSegment(newPoint(p1:getY(), p1:getX()),
				   newPoint(p2:getY(), p2:getX()),
				   newPoint(p3:getY(), p3:getX()),
				   newPoint(p4:getY(), p4:getX()),
		)
		return newSegment(seg:getY(), seg:getX())
	end

	-- we keep the min and max points related to their X composant
	local pmax = p1
	local pmin = p1
	
	pmax = p2:max(pmax)
	pmax = p3:max(pmax)
	pmax = p4:max(pmax)

	pmin = p2:min(pmin)
	pmin = p3:min(pmin)
	pmin = p4:min(pmin)

	return newSegment(pmin, pmax)
end

local function getMiddlePoint(p1, p2)
	return {x = (p1.x - p2.x) / 2 + p1.x,
			y = (p1.y - p2.y) / 2 + p1.y}
end

function rectCollision(quad1, quad2)
	local axes1 = rectGetAxes(quad1)
	local axes2 = rectGetAxes(quad2)
	local origins = {axes1["origin"], axes2["origin"]}
	local axes = {axes1["axis1"], axes1["axis2"], axes2["axis1"], axes2["axis2"]}

	--local q1points = {}
	--local q2points = {}

	--for _, p in ipairs(quad1) do
	--	q1points[#q1points + 1] = newPoint(p.x, p.y)
	--end

	--for _, p in ipairs(quad2) do
	--	q2points[#q2points + 1] = newPoint(p.x, p.y)
	--end

	for i, axis in ipairs(axes) do
		local origin = nil
		if (i <= 2) then
			origin = origins[1]
		else
			origin = origins[2]
		end

		-- fisrt quad
		local q1projs = {}
		for j, p in quad1 do
			q1projs[j] = newPoint(p.x, p.y):projectOnLone(origin, axis)
		end

		--we get the related segment
		local seg1 = getSegment(q1projs)

		-- second quad
		local q2projs = {}
		for j, p in quad2 do
			q2projs[j] = newPoint(p.x, p.y):projectOnLine(origin, axis)
		end

		--we get the second segment
		local seg2 = getSegment(q2projs)

		--we test if they overlaps. If not, there's no collision
		if not seg1:overlaps(seg2) then
			return false
	end

	--they all overlaps, there is a collision
	return true
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
