local mt = {}
mt.__index = mt

local XHudDist = 20
local YHudDist = 20

function mt:drawAsset(asset, x, y)
	getAssetsManager():drawUIAsset(self.player, asset, x, y)
end

function mt:getDistances(x, y)
	if self.playerNo = 1 then
		return x, y
	end
	if self.playerNo = 2 then
		local res = 
end

function newUI(player, playerNo)
	local self = {}

	self.player = player
	self.playerNo = playerNo

	setmetatable(self, mt)
end

function mt:draw()
	-- hud

end
