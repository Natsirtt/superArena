-- returns the segment that contains all of those points (points are aligned)
--function getSegment(pointsTable)
--	local p1 = pointsTable[1]
--	local p2 = pointsTable[2]
--	local p3 = pointsTable[3]
--	local p4 = pointsTable[4]
--
--	if p1:getX() == p2:getX() then
--		-- all 4 are aligned
--		local seg = getSegment(newPoint(p1:getY(), p1:getX()),
--				   newPoint(p2:getY(), p2:getX()),
--				   newPoint(p3:getY(), p3:getX()),
--				   newPoint(p4:getY(), p4:getX()))
--		return newSegment(seg:getY(), seg:getX())
--	end
--
--	-- we keep the min and max points related to their X composant
--	local pmax = p1
--	local pmin = p1
--	
--	pmax = p2:max(pmax)
--	pmax = p3:max(pmax)
--	pmax = p4:max(pmax)
--
--	pmin = p2:min(pmin)
--	pmin = p3:min(pmin)
--	pmin = p4:min(pmin)
--
--	return newSegment(pmin, pmax)
--end

function getMiddlePoint(p1, p2)
	return {x = (p1.x + p2.x) / 2,
			y = (p1.y + p2.y) / 2}
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

		-- second quad
		
		--for j, p in ipairs(quad2) do
		--	q2projs[k] = newPoint(p.x, p.y):projectOnLine(origin, axis)
		--end

		local pointsTable = {
			newPoint(quad2[1].x, quad2[1].y):projectOnLine(origin, axis),
			newPoint(quad2[2].x, quad2[2].y):projectOnLine(origin, axis),
			newPoint(quad2[3].x, quad2[3].y):projectOnLine(origin, axis),
			newPoint(quad2[4].x, quad2[4].y):projectOnLine(origin, axis),
		}

		--if true then
		--	return q2projs
		--end

		--we get the second segment
		-- we keep the min and max points related to their X composant
		local pmax = pointsTable[1]
		local pmin = pointsTable[1]
		
		for _, p in ipairs(pointsTable) do
			pmax = p:max(pmax)
			pmin = p:min(pmin)
		end

		local seg2 = newSegment(pmin, pmax)

		-- first quad
		--local q1projs = {}
		
		--for _, p in ipairs(quad1) do
		--	table.insert(q1projs, newPoint(p.x, p.y):projectOnLine(origin, axis))
		--end

		pointsTable = {
			newPoint(quad1[1].x, quad1[1].y):projectOnLine(origin, axis),
			newPoint(quad1[2].x, quad1[2].y):projectOnLine(origin, axis),
			newPoint(quad1[3].x, quad1[3].y):projectOnLine(origin, axis),
			newPoint(quad1[4].x, quad1[4].y):projectOnLine(origin, axis),
		}

		--we get the related segment
		-- we keep the min and max points related to their X composant
		local pmax = pointsTable[1]
		local pmin = pointsTable[1]
		
		for _, p in ipairs(pointsTable) do
			pmax = p:max(pmax)
			pmin = p:min(pmin)
		end

		local seg1 = newSegment(pmin, pmax)

		--we test if they overlaps. If not, there's no collision
		if not seg1:overlaps(seg2) then
			return false
		end
	end

	--they all overlaps, there is a collision
	return true
end

-- returns two tables, one for each axis, with a point (the origin of the vector) and a vector
function rectGetAxes(quad)
	local res = {}
	local m1 = getMiddlePoint(quad[1], quad[2])
	local m2 = getMiddlePoint(quad[3], quad[4])

	local origin = getMiddlePoint(m1, m2)
	res["origin"] = newPoint(origin.x, origin.y)
	res["axis1"] = newVector(m1.x, m1.y)
	res["axis2"] = newVector(m1.y, -m1.x) -- simplified vectoriel product
	return res
end

