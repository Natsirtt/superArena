local mt = {}
mt.__index = mt

local init = false
local instance = {}

local TILE_SIZE = 51

function getAssetsManager()
    if not init then
        local self = {}

        local tileSet = love.graphics.newImage("assets/tileset.png")
		self.assets = {}

		local imageData = tileSet:getData()
		local nid = love.image.newImageData(150, 150)
		
		-- sable
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, TILE_SIZE * ((i - 1) % 3), 0, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, TILE_SIZE * ((i - 1) % 3), TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, TILE_SIZE * ((i - 1) % 3), 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end

		-- mur
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 3 * TILE_SIZE + TILE_SIZE * ((i - 1) % 3), 0, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end
		nid:paste(imageData, 0, 0, 3 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILE_SIZE)
		table.insert(self.assets, love.graphics.newImage(nid))
		nid:paste(imageData, 0, 0, 3 * TILE_SIZE + 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILE_SIZE)
		table.insert(self.assets, love.graphics.newImage(nid))
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 3 * TILE_SIZE + TILE_SIZE * ((i - 1) % 3), 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end

		-- public
		nid:paste(imageData, 0, 0, 6 * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE)
		table.insert(self.assets, love.graphics.newImage(nid))

		--porte et son public
		nid:paste(imageData, 0, 0, 7 * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE)
		table.insert(self.assets, love.graphics.newImage(nid))
		nid:paste(imageData, 0, 0, 7 * TILE_SIZE + 2 * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE)
		table.insert(self.assets, love.graphics.newImage(nid))

		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 7 * TILE_SIZE + ((i - 1) % 3) * TILE_SIZE, TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end

		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 7 * TILE_SIZE + ((i - 1) % 3) * TILE_SIZE, 2 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end

		-- public 2 animé
		-- état 1
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 3 * TILE_SIZE + ((i - 1) % 3) * TILE_SIZE, 3 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 3 * TILE_SIZE + ((i - 1) % 3) * TILE_SIZE, 4 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 3 * TILE_SIZE + ((i - 1) % 3) * TILE_SIZE, 5 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 3 * TILE_SIZE + ((i - 1) % 3) * TILE_SIZE, 6 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end

		-- état 2
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 7 * TILE_SIZE + ((i - 1) % 3) * TILE_SIZE, 3 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 7 * TILE_SIZE + ((i - 1) % 3) * TILE_SIZE, 4 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 7 * TILE_SIZE + ((i - 1) % 3) * TILE_SIZE, 5 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end
		for i = 1, 3 do
			nid:paste(imageData, 0, 0, 7 * TILE_SIZE + ((i - 1) % 3) * TILE_SIZE, 6 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			table.insert(self.assets, love.graphics.newImage(nid))
		end

		-- UI / HUD

		self.uiAssets = {}

		self.uiAssets["attackButton"] = love.graphics.newImage("btn_attack.png")
		self.uiAssets["attackButtonP1"] = love.graphics.newImage("P1_btn_attack_use.png")
		self.uiAssets["attackButtonP2"] = love.graphics.newImage("P2_btn_attack_use.png")
		self.uiAssets["attackButtonP3"] = love.graphics.newImage("P3_btn_attack_use.png")
		self.uiAssets["attackButtonP4"] = love.graphics.newImage("P4_btn_attack_use.png")

		self.uiAssets["defenseButton"] = love.graphics.newImage("btn_defense.png")
		self.uiAssets["defenseButtonP1"] = love.graphics.newImage("P1_btn_defense_use.png")
		self.uiAssets["defenseButtonP2"] = love.graphics.newImage("P2_btn_defense_use.png")
		self.uiAssets["defenseButtonP3"] = love.graphics.newImage("P3_btn_defense_use.png")
		self.uiAssets["defenseButtonP4"] = love.graphics.newImage("P4_btn_defense_use.png")

		self.uiAssets["life"] = love.graphics.newImage("life.png")
		self.uiAssets["hudP1"] = love.graphics.newImage("P1_HUD.png")
		self.uiAssets["hudP2"] = love.graphics.newImage("P2_HUD.png")
		self.uiAssets["hudP3"] = love.graphics.newImage("P3_HUD.png")
		self.uiAssets["hudP4"] = love.graphics.newImage("P4_HUD.png")
		self.uiAssets["hudDeadP1"] = love.graphics.newImage("P1_HUD_dead.png")
		self.uiAssets["hudDeadP2"] = love.graphics.newImage("P2_HUD_dead.png")
		self.uiAssets["hudDeadP3"] = love.graphics.newImage("P3_HUD_dead.png")
		self.uiAssets["hudDeadP4"] = love.graphics.newImage("P4_HUD_dead.png")

        instance = setmetatable(self, mt)
        init = true
    end
    return instance
end

function mt:drawAsset(asset, x, y)
	if 0 <= asset and asset < #self.assets then
		if asset == 21 then -- some sand underneath the top of the door
			self:drawAsset(4 + 1, x, y)
		end
		local tex = self.assets[asset + 1]
		love.graphics.draw(tex, x - tex:getWidth() / 2, y - tex:getHeight() / 2)
	end
end

function drawUIAsset(player, asset, x, y)
	local playerStr = ""
	if player ~= nil then
		playerStr = "P" .. player
	end
	local tex = self.uiAssets[asset..playerStr]
	love.graphics.draw(tex, x, y)
end

function drawAsset(asset, x, y)
	getAssetsManager():drawAsset(asset, x, y)
end

function mt:debugAssets()
	for i = 0, 49 do
		self:drawAsset(i, (TILE_SIZE + 5) * i, 0)
	end
end
