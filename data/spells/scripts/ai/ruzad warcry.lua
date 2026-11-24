-- Warlord Ruzad - Warcry ("Axe Spin"): the tiles around him (circle of radius 3, 4 in berserk) are marked; he spins his axe and everybody
-- still there takes physical damage.
function onCastSpell(cid, var)
	local berserk = MonsterAI.getMemory(cid).berserk
	local radius = berserk and 4 or 3
	local delay = 1600
	local disc = Telegraph.disc(getCreaturePosition(cid), radius)

	-- the axes fly out of him to the border of the area just before the hit
	addEvent(function()
		if(isCreature(cid)) then
			local from = getCreaturePosition(cid)
			doSendMagicEffect(from, CONST_ME_BLOCKHIT)
			-- only the border of the circle: tiles of the disc that are not inside the smaller disc
			local inner = {}
			for _, tile in ipairs(Telegraph.disc(from, radius - 1)) do
				inner[tile.x .. ":" .. tile.y] = true
			end

			for _, tile in ipairs(disc) do
				if(not inner[tile.x .. ":" .. tile.y]) then
					doSendDistanceShoot(from, tile, CONST_ANI_WHIRLWINDAXE)
				end
			end
		end
	end, delay - 350)

	Telegraph.strike{
		caster = cid, tiles = disc, delay = delay, refresh = 1600,
		combat = COMBAT_PHYSICALDAMAGE, min = berserk and 60 or 50, max = berserk and 120 or 100, effect = CONST_ME_HITAREA
	}

	return true
end
