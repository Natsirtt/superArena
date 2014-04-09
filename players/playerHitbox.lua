
HITBOX = {}

-- right
HITBOX[25] = newQuad(20, -10, 30, 0, 45, -15, 35, -25)
HITBOX[26] = newQuad(30, 0, 20, 10, 35, 25, 45, 15)
HITBOX[27] = newQuad(30, 0, 20, 10, 35, 25, 45, 15)

-- left
HITBOX[30] = newQuad(-25, 0, -18, -8, -35, -22, -17, -14)
HITBOX[31] = newQuad(-29, 0, -19, 10, -35, 25, -45, 15)
HITBOX[32] = newQuad(-29, 0, -19, 10, -35, 25, -45, 15)

-- up
HITBOX[35] = newQuad(4, -7, -4, -12, 17, -33, 25, -38)
HITBOX[36] = newQuad(-20, -9, 4, -12, 10, -32, -14, -29)
HITBOX[37] = newQuad(-20, -9, -8, -11, -10, -33, -22,-31)

-- down
HITBOX[40] = newQuad(-4, 7, 4, 12, -17, 33, -25, 38)
HITBOX[41] = newQuad(20, 9, -4, 12, -10, 32, 14, 29)
HITBOX[42] = newQuad(20, 9, 8, 11, 10, 33, 22, 31)

function getHitbox(frameIndex)
	if (HITBOX[frameIndex]) then
		return HITBOX[frameIndex]
	end
	print("Hitbox inconnue "..frameIndex)
	return newQuad(0, 0, 0, 0, 0, 0, 0, 0)
end