-- Queen Silkara - Toxic Nova (frenzy): everything within 5 tiles of her is marked EXCEPT the 3x3 right next to her: whoever stays
-- glued to her (or runs out of the circle) is safe; the rest takes earth damage when the venom bursts.
function onCastSpell(cid, var)
	local from = getCreaturePosition(cid)
	local safe = {}
	for _, tile in ipairs(Telegraph.square(from, 1)) do
		safe[tile.x .. ":" .. tile.y] = true
	end

	local tiles = {}
	for _, tile in ipairs(Telegraph.disc(from, 5)) do
		if(not safe[tile.x .. ":" .. tile.y]) then
			table.insert(tiles, tile)
		end
	end

	Telegraph.strike{
		caster = cid, tiles = tiles, delay = 1900, refresh = 1900,
		combat = COMBAT_EARTHDAMAGE, min = 70, max = 130, effect = CONST_ME_POISONAREA,
		onLand = function()
			if(isCreature(cid)) then
				doSendMagicEffect(getCreaturePosition(cid), CONST_ME_POISONAREA)
			end
		end
	}

	return true
end
