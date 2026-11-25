-- Twin Shot: two arrows in a row (0.3s) in 1 target (range 7), power x 0.5 to 0.8 each.
-- fire: the 2nd arrow explodes in 3x3 | poison: the 2nd arrow gives 2 stacks | ice: the 2nd arrow freezes if there are 2 stacks of frost
-- energy: the 2nd arrow goes to another enemy near the target
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.triple = {damage}     a third arrow 0.3s after the second; `damage` = multiplier of EACH arrow (3 arrows of 1.3 * 2 / 3 = 130% of the original in total)
--   glyph.leech  = {percent}    `percent`% of the maximum health back for each arrow that hits
local config = {damage = {0.5, 0.8}, range = 7, delay = 300}

function onCastSpell(cid, var)
	local target = Archer.target(cid, config.range)
	if(not target) then
		return false
	end

	local glyph = Archer.glyph(cid, "twin shot")
	local multiplier = (glyph and glyph.triple and glyph.triple.damage) or 1
	local element = Archer.element(cid)
	local from = getCreaturePosition(cid)

	local function leech()
		if(glyph and glyph.leech and isCreature(cid) and getCreatureHealth(cid) > 0) then
			doCreatureAddHealth(cid, math.max(1, math.floor(getCreatureMaxHealth(cid) * glyph.leech.percent / 100)))
			doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
		end
	end

	Archer.fx("archer_shot", target, {from = from, element = element})
	if(Archer.hit(cid, target, config.damage[1], config.damage[2], element, multiplier)) then
		leech()
	end

	addEvent(function()
		if(not isCreature(cid) or not Archer.valid(cid, target)) then
			return
		end

		local pos = getCreaturePosition(target)
		local victim, options = target, {}
		if(element == "poison") then
			options.intensity = 2
		elseif(element == "ice") then
			local state = Archer.state[target]
			if(state and state.chill >= 2) then
				options.intensity = 3 - state.chill + 1
			end
		elseif(element == "energy") then
			for _, tid in ipairs(Archer.enemies(cid, pos, 3)) do
				if(tid ~= target) then
					victim = tid
					break
				end
			end
		end

		local to = getCreaturePosition(victim)
		doSendDistanceShoot(getCreaturePosition(cid), to, Archer.elements[element].ani)
		if(Archer.hit(cid, victim, config.damage[1], config.damage[2], element, multiplier, options)) then
			leech()
		end

		if(element == "fire") then
			Archer.areaHit(cid, pos, 1, config.damage[1] * 0.5, config.damage[2] * 0.5, "fire", {plain = true})
			doSendMagicEffect(pos, CONST_ME_EXPLOSIONAREA)
		end
	end, config.delay)

	if(glyph and glyph.triple) then
		addEvent(function()
			if(not isCreature(cid) or not Archer.valid(cid, target)) then
				return
			end

			Archer.fx("archer_shot", target, {from = getCreaturePosition(cid), element = element})
			if(Archer.hit(cid, target, config.damage[1], config.damage[2], element, multiplier)) then
				leech()
			end
		end, config.delay * 2)
	end

	return true
end
