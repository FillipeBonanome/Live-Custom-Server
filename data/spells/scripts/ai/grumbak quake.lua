-- Chief Grumbak - Quake: the tiles around him (circle of radius 3, 4 in the rage) are marked; he slams the ground and whoever is
-- still there takes physical damage.
function onCastSpell(cid, var)
	local rage = MonsterAI.getMemory(cid).rage
	local radius = rage and 4 or 3
	local delay = 1600
	local disc = Telegraph.disc(getCreaturePosition(cid), radius)

	-- rocks fly out of the ground just before the hit
	addEvent(function()
		if(isCreature(cid)) then
			local from = getCreaturePosition(cid)
			doSendMagicEffect(from, CONST_ME_GROUNDSHAKER)
			local inner = {}
			for _, tile in ipairs(Telegraph.disc(from, radius - 1)) do
				inner[tile.x .. ":" .. tile.y] = true
			end

			for _, tile in ipairs(disc) do
				if(not inner[tile.x .. ":" .. tile.y]) then
					doSendDistanceShoot(from, tile, CONST_ANI_SMALLSTONE)
				end
			end
		end
	end, delay - 350)

	Telegraph.strike{
		caster = cid, tiles = disc, delay = delay, refresh = 1600,
		combat = COMBAT_PHYSICALDAMAGE, min = rage and 60 or 50, max = rage and 120 or 100, effect = CONST_ME_GROUNDSHAKER
	}

	return true
end
