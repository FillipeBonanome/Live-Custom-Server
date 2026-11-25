-- Overcharge Shot: charges for 1.2s and shoots a single huge arrow in the target (range 7), power x 2.2 to 3.2.
-- fire: explodes (5x5), 60% of the damage on the others | poison: 5 stacks of venom at once | ice: freezes for 2s
-- energy: goes through the target and hits the one behind it for 70%
-- If the target dies, goes away or leaves your sight during the charge the shot is lost (the mana is spent).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.steady = {percent}     while charging you take `percent`% less damage from every element and cannot be paralyzed (buff "Steady Charge", subId 8713)
--   glyph.quick  = {charge}      the charge takes `charge` ms
local config = {damage = {2.2, 3.2}, range = 7, charge = 1200, explosion = 2, others = 0.6, behind = 0.7}

local function sign(n)
	return n > 0 and 1 or (n < 0 and -1 or 0)
end

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local glyph = Archer.glyph(cid, "overcharge shot")
	local charge = (glyph and glyph.quick and glyph.quick.charge) or config.charge
	local element = Archer.element(cid)
	Archer.fx("archer_charge", target, {element = element})

	if(glyph and glyph.steady) then
		Archer.guard(cid, "Steady Charge", 8713, glyph.steady.percent, charge + 100)
		Glyphs.paralysisImmunity(cid, charge)
	end

	addEvent(function()
		if(not isCreature(cid) or not Archer.valid(cid, target)) then
			return
		end

		local from, pos = getCreaturePosition(cid), getCreaturePosition(target)
		if(from.z ~= pos.z or getDistanceBetween(from, pos) > config.range + 1 or not isSightClear(from, pos, true)) then
			doSendMagicEffect(from, CONST_ME_POFF)
			return
		end

		Archer.fx("archer_shot", target, {from = from, element = element})
		local options = {}
		if(element == "poison") then
			options.intensity = Archer.maxPoison
		end

		Archer.hit(cid, target, config.damage[1], config.damage[2], element, nil, options)

		if(element == "fire") then
			doSendMagicEffect(pos, CONST_ME_EXPLOSIONAREA)
			for _, tid in ipairs(Archer.enemies(cid, pos, config.explosion, target)) do
				if(tid ~= target) then
					Archer.hit(cid, tid, config.damage[1], config.damage[2], "fire", config.others, {plain = true})
				end
			end
		elseif(element == "ice") then
			if(isCreature(target) and getCreatureHealth(target) > 0) then
				Archer.freeze(target, 2000)
			end
		elseif(element == "energy") then
			local dx, dy = sign(pos.x - from.x), sign(pos.y - from.y)
			local tiles = {{x = pos.x + dx, y = pos.y + dy, z = pos.z}, {x = pos.x + dx * 2, y = pos.y + dy * 2, z = pos.z}}
			for _, tid in ipairs(Archer.enemiesOn(cid, tiles, pos, 3)) do
				doSendDistanceShoot(pos, getCreaturePosition(tid), Archer.elements.energy.ani)
				Archer.hit(cid, tid, config.damage[1], config.damage[2], "energy", config.behind)
				break
			end
		end
	end, charge)

	return true
end
