local mt = {}
mt.__index = mt

local XHudDist = 10
local YHudDist = 25

function mt:drawAsset(asset, x, y)
	local x2, y2 = self:getDistances(x, y)
	local xOffset = (x2 ~= x)
	local yOffset = (y2 ~= y)
	getAssetsManager():drawUIAsset(self.player, asset, x2, y2, false, xOffset, yOffset)
end

function mt:getDistances(x, y)
	if self.playerNo == 1 then
		return x, y
	end
	if self.playerNo == 2 then
		return love.window.getWidth() - x, y
	end
	if self.playerNo == 3 then
		return x, love.window.getHeight() - y
	end
	if self.playerNo == 4 then
		return love.window.getWidth() - x, love.window.getHeight() -y
	end
	return -100000000, -100000000
end

function newUI(player, playerNo)
	local self = {}

	self.player = player
	self.playerNo = playerNo

	return setmetatable(self, mt)
end

function mt:draw()
	-- hud
	if self.player:isDead() then
		self:drawAsset("hudDead", XHudDist, YHudDist)
	else
		self:drawAsset("hud", XHudDist, YHudDist)

	end
end
