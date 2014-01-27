local level_mt = {}
level_mt.__index = level_mt


local LEVEL_MAP = {
{-1, -1, 19, 42, 42, 42, 42, 42, 05},
{-1, 03, 178, 65, 65, 65, 42, 42, 21},
{-1, 19, 65, 65, 65, 65, 65, 65, 21},
{-1, 19, 42, 65, 65, 65, 75, 42, 21},
{-1, 19, 42, 65, 65, 65, 42, 75, 21},
{-1, 19, 65, 65, 65, 65, 65, 65, 21},
{-1, 19, 65, 65, 65, 65, 65, 65, 21},
{-1, 19, 19, 65, 65, 65, 58, 43, 21},
{-1, 19, 19, 65, 65, 76, 75, 27, 176, 05},
{-1, 19, 65, 65, 65, 65, 65, 65, 65, 21},
{-1, 19, 65, 65, 65, 65, 65, 65, 65, 21},
{-1, 35, 36, 36, 36, 146, 65, 65, 65, 21},
{-1, 03, 04, 04, 04, 178, 65, 65, 65, 21},
{-1, 19, 65, 65, 65, 65, 65, 65, 144, 37},
{03, 178, 65, 65, 65, 65, 65, 65, 21},
{19, 65, 65, 65, 65, 65, 65, 65, 21},
{19, 65, 65, 65, 19, 19, 19, 19, 21},
{19, 65, 65, 65, 65, 65, 19, 19, 21},
{35, 146, 19, 65, 65, 65, 65, 65, 21},
{-1, 19, 19, 65, 65, 65, 65, 65, 21},
{-1, 19, 19, 19, 19, 19, 65, 65, 21},
{-1, 19, 19, 65, 65, 65, 65, 65, 21},
{-1, 19, 19, 65, 65, 65, 65, 65, 21},
{-1, 19, 19, 65, 65, 65, 19, 19, 21},
{-1, 19, 19, 65, 65, 65, 19, 19, 21}
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
			if (tileID ~= 65) then
				local body = love.physics.newBody(world, 0, 0, "static")
				body:setMassData(0, 0, 10, 0)
				local shape = love.physics.newPolygonShape(-TILE_SIZE / 2, -TILE_SIZE / 2,
														TILE_SIZE / 2, -TILE_SIZE / 2,
														TILE_SIZE / 2, TILE_SIZE / 2,
														-TILE_SIZE / 2, TILE_SIZE / 2)
				local fixture = love.physics.newFixture(body, shape, 1)
				fixture:setFriction(10000)
				level.boxes[j][i] = fixture
				body:setPosition((i - 1) * TILE_SIZE + dx + TILE_SIZE / 2, (j - 1) * TILE_SIZE + dy + TILE_SIZE / 2 + TILE_SIZE)
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
				drawAsset(tileID, (i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE + TILE_SIZE / 2)
			end
		end
	end
	-- Debug
	-- love.graphics.push()
	-- love.graphics.origin()
	-- love.graphics.setColor(255, 255, 255)
	-- for j, t in ipairs(self.boxes) do
		-- for i, box in ipairs(t) do
			-- local topLeftX, topLeftY, bottomRightX, bottomRightY = self.boxes[j][i]:getBoundingBox()
			-- love.graphics.rectangle("line", topLeftX, topLeftY, bottomRightX - topLeftX, bottomRightY - topLeftY)
		-- end
	-- end
	-- love.graphics.pop()
end

function level_mt:getWidth()
	return TILE_SIZE * LEVEL_WIDTH
end

function level_mt:getHeight()
	return TILE_SIZE * LEVEL_HEIGHT
end

