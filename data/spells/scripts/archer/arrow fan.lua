-- Arrow Fan: fan of arrows in a cone 3 wide and 5 long in front of you (stops at walls), power x 0.6 to 1.0.
-- fire: burning | poison: 2 stacks on each one | ice: +1 stack of frost on each one | energy: every hit has a guaranteed jump to another enemy
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.wide    = {length, halfWidth}     a bigger cone (6 long and 5 wide: halfWidth 2)
--   glyph.scatter = {chance}                every creature hit is pushed 1 sqm away from you (data/lib/404-push.lua)
local config = {damage = {0.6, 1.0}, length = 5, halfWidth = 1}

function onCastSpell(cid, var)
	local glyph = Archer.glyph(cid, "arrow fan")
	local length = (glyph and glyph.wide and glyph.wide.length) or config.length
	local halfWidth = (glyph and glyph.wide and glyph.wide.halfWidth) or config.halfWidth

	local from = getCreaturePosition(cid)
	local v = Archer.vector(getCreatureLookDirection(cid))
	local side = {-v[2], v[1]}

	local tiles = {}
	for i = 1, length do
		local width = i == 1 and 0 or halfWidth
		for offset = -width, width do
			local pos = {x = from.x + v[1] * i + side[1] * offset, y = from.y + v[2] * i + side[2] * offset, z = from.z}
			if(isSightClear(from, pos, true) and type(getTileInfo(pos)) == "table") then
				table.insert(tiles, pos)
			end
		end
	end

	if(#tiles == 0) then
		doPlayerSendCancel(cid, "There is no room to shoot.")
		doSendMagicEffect(from, CONST_ME_POFF)
		return false
	end

	local element = Archer.element(cid)
	local def = Archer.elements[element]
	local options = {}
	if(element == "poison") then
		options.intensity = 2
	elseif(element == "energy") then
		options.shockChance = 100
	end

	for _, pos in ipairs(tiles) do
		doSendDistanceShoot(from, pos, def.ani)
		doSendMagicEffect(pos, def.area)
	end

	local hit = Archer.enemiesOn(cid, tiles, from, length + 1)
	for _, tid in ipairs(hit) do
		Archer.hit(cid, tid, config.damage[1], config.damage[2], element, nil, options)
	end

	if(glyph and glyph.scatter) then
		Glyphs.pushAll(cid, hit, glyph.scatter.chance)
	end

	return true
end
