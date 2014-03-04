
ANIMATIONS = {}
	-- up
ANIMATIONS[0] = {
	idle = "idleUp",
	walk = "walkUp",
	attack = "attackUp",
	shield = "shieldUp",
	shieldPos = {newPoint(12, -13), newPoint(-12, -13)}
}
	-- up left
ANIMATIONS[45] = ANIMATIONS[0]
	-- up right
ANIMATIONS[-45] = ANIMATIONS[0]
	-- left
ANIMATIONS[90] = {
	idle = "idleLeft",
	walk = "walkLeft",
	attack = "attackLeft",
	shield = "shieldLeft",
	shieldPos = {newPoint(-13, -13), newPoint(-13, 13)}
}
	-- right
ANIMATIONS[-90] = {
	idle = "idleRight",
	walk = "walkRight",
	attack = "attackRight",
	shield = "shieldRight",
	shieldPos = {newPoint(13, 13), newPoint(13, -13)}
}
	-- down
ANIMATIONS[180] = {
	idle = "idleDown",
	walk = "walkDown",
	attack = "attackDown",
	shield = "shieldDown",
	shieldPos = {newPoint(-12, 13), newPoint(12, 13)}
}
ANIMATIONS[-180] = ANIMATIONS[180]
	-- down left
ANIMATIONS[135] = ANIMATIONS[180]
	-- down right
ANIMATIONS[-135] = ANIMATIONS[180]
