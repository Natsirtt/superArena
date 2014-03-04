


function newQuad(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y)
	return {
		{x = p1x, y = p1y},
		{x = p2x, y = p2y},
		{x = p3x, y = p3y},
		{x = p4x, y = p4y}
	}
end

-- Inutile ?
function interpQuads(lastQuad, newQuad)
	return {
		{x = (lastQuad[1].x + newQuad[1].x) / 2, y = (lastQuad[1].y + newQuad[1].y) / 2},
		{x = (lastQuad[2].x + newQuad[2].x) / 2, y = (lastQuad[2].y + newQuad[2].y) / 2},
		{x = (lastQuad[3].x + newQuad[3].x) / 2, y = (lastQuad[3].y + newQuad[3].y) / 2},
		{x = (lastQuad[4].x + newQuad[4].x) / 2, y = (lastQuad[4].y + newQuad[4].y) / 2}
	}
end

function getQuadCenter(quad)
	local pm1 = getMiddlePoint(quad[1], quad[3])
	local pm2 = getMiddlePoint(quad[2], quad[4])
	
	local middle = getMiddlePoint(pm1, pm2)
	
	return middle
end

-- Ne marche qu'avec les box alignées
function getQuadWidth(quad)
	return math.abs(quad[2].x - quad[1].x)
end

-- Ne marche qu'avec les box alignées
function getQuadHeight(quad)
	return math.abs(quad[3].y - quad[1].y)
end

function getTranslatedQuad(quad, dx, dy)
	return {
		{x = quad[1].x + dx, y = quad[1].y + dy},
		{x = quad[2].x + dx, y = quad[2].y + dy},
		{x = quad[3].x + dx, y = quad[3].y + dy},
		{x = quad[4].x + dx, y = quad[4].y + dy}
	}
end
