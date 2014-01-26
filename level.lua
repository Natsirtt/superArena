local level_mt = {}
level_mt.__index = level_mt


local LEVEL_MAP = {
{-1, -1, 12, 04, 04, 04, 12, 12, 11},
{-1, 09, 12, 04, 04, 04, 12, 12, 13},
{-1, 12, 04, 04, 04, 04, 04, 04, 13},
{-1, 12, 12, 04, 04, 04, 12, 12, 13},
{-1, 12, 12, 04, 04, 04, 12, 12, 13},
{-1, 12, 04, 04, 04, 04, 04, 04, 13},
{-1, 12, 04, 04, 04, 04, 04, 04, 13},
{-1, 12, 12, 04, 04, 04, 12, 12, 13},
{-1, 12, 12, 04, 04, 04, 12, 12, 13, 11},
{-1, 12, 04, 04, 04, 04, 04, 04, 04, 13},
{-1, 12, 04, 04, 04, 04, 04, 04, 04, 13},
{-1, 12, 12, 12, 12, 12, 04, 04, 04, 13},
{-1, 12, 12, 12, 12, 12, 04, 04, 04, 13},
{-1, 12, 04, 04, 04, 04, 04, 04, 13, 16},
{09, 12, 04, 04, 04, 04, 04, 04, 13},
{12, 04, 04, 04, 04, 04, 04, 04, 13},
{12, 04, 04, 04, 12, 12, 12, 12, 13},
{12, 04, 04, 04, 04, 04, 12, 12, 13},
{11, 12, 12, 04, 04, 04, 04, 04, 13},
{-1, 12, 12, 04, 04, 04, 04, 04, 13},
{-1, 12, 12, 12, 12, 12, 04, 04, 13},
{-1, 12, 12, 04, 04, 04, 04, 04, 13},
{-1, 12, 12, 04, 04, 04, 04, 04, 13},
{-1, 12, 12, 04, 04, 04, 12, 12, 13},
{-1, 12, 12, 04, 04, 04, 12, 12, 13}
}

local LEVEL_WIDTH = 10
local LEVEL_HEIGHT = 25

local TILE_SIZE = 50

function newLevel()
	local level = {}
	
	level.tileSet = love.graphics.newImage("assets/tileset.png")
	
	local dx = TILE_SIZE * LEVEL_WIDTH / 2
	local dy = -TILE_SIZE * LEVEL_HEIGHT
	
	level.boxes = {}
	for j, t in ipairs(LEVEL_MAP) do
		level.boxes[j] = {}
		for i, tileID in ipairs(t) do
			if (tileID ~= 4) then
				-- level.boxes[j][i] = {
					-- {x = (i - 1) * TILE_SIZE + dx,             y = (j - 1) * TILE_SIZE + dy},
					-- {x = (i - 1) * TILE_SIZE + dx + TILE_SIZE, y = (j - 1) * TILE_SIZE + dy},
					-- {x = (i - 1) * TILE_SIZE + dx + TILE_SIZE, y = (j - 1) * TILE_SIZE + dy + TILE_SIZE},
					-- {x = (i - 1) * TILE_SIZE + dx,             y = (j - 1) * TILE_SIZE + dy + TILE_SIZE}
				-- }
				local body = love.physics.newBody(world, 0, 0, "static")
				body:setMassData(0, 0, 10, 0)
				local shape = love.physics.newPolygonShape(-TILE_SIZE / 2, -TILE_SIZE / 2,
														TILE_SIZE / 2, -TILE_SIZE / 2,
														TILE_SIZE / 2, TILE_SIZE / 2,
														-TILE_SIZE / 2, TILE_SIZE / 2)
				local fixture = love.physics.newFixture(body, shape, 1)
				fixture:setFriction(10000)
				level.boxes[j][i] = fixture
				body:setPosition((i - 1) * TILE_SIZE + dx + TILE_SIZE / 2, (j - 1) * TILE_SIZE + dy + TILE_SIZE / 2)
			end
		end
	end

	return setmetatable(level, level_mt)
end

function level_mt:update(dt)
	
end

function level_mt:draw()
	for j, t in ipairs(LEVEL_MAP) do
		for i, tileID in ipairs(t) do
			if (tileID ~= nil) and (tileID ~= -1) then
				drawAsset(tileID, (i) * TILE_SIZE + TILE_SIZE / 2, (j) * TILE_SIZE + TILE_SIZE / 2)
			end
		end
	end
	-- Debug
	-- for j, t in ipairs(self.boxes) do
		-- for i, box in ipairs(t) do
			-- local topLeftX, topLeftY, bottomRightX, bottomRightY = self.boxes[j][i]:getBoundingBox()
			-- love.graphics.rectangle("line", topLeftX, topLeftY, bottomRightX - topLeftX, bottomRightY - topLeftY)
		-- end
	-- end
end

function level_mt:getWidth()
	return TILE_SIZE * LEVEL_WIDTH
end

function level_mt:getHeight()
	return TILE_SIZE * LEVEL_HEIGHT
end

-- Renvoie une position valide pour un deplacement de lastQuad vers newQuad (lastQuad est supposé valide)
-- MARCHE PAS
-- function level_mt:getValidQuad(lastQuad, newQuad, dx, dy)
	-- local quad = newQuad
	-- for j, t in ipairs(self.boxes) do
		-- for i, box in ipairs(t) do
			-- if (box ~= nil) and (quad ~= nil) then
				-- if (rectCollision(box, quad)) then
					-- local c1 = getQuadCenter(quad)
					-- local oldC = getQuadCenter(lastQuad)
					-- local c2 = getQuadCenter(box)
					-- local boundX = false
					-- local boundY = false
					-- local newDX = dx
					-- local newDY = dy
					-- if (rectCollision(box, getTranslatedQuad(lastQuad, dx, 0))) then
						-- boundX = true
					-- end
					-- if (rectCollision(box, getTranslatedQuad(lastQuad, 0, dy))) then
						-- boundY = true
					-- end
					-- local w = getQuadWidth(quad) / 2
					-- local h = getQuadHeight(quad) / 2
					
					-- if (oldC.x < c2.x) and boundX then
						-- c1.x = box[1].x - w - 10
					-- elseif (oldC.x > c2.x) and boundX then
						-- c1.x = box[2].x + w + 10
					-- end
					-- if (oldC.y < c2.y) and boundY then
						-- c1.y = box[1].y - h - 10
					-- elseif (oldC.y < c2.y) and boundY then
						-- c1.y = box[3].y + h + 10
					-- end
					-- quad = {
						-- {x = c1.x - w, y = c1.y - h},
						-- {x = c1.x + w, y = c1.y - h},
						-- {x = c1.x + w, y = c1.y + h},
						-- {x = c1.x - w, y = c1.y + h}
					-- }
					-- return quad
				-- end
			-- end
		-- end
	-- end
	-- return quad
-- end



