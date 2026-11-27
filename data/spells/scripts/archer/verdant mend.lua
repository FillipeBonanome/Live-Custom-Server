-- Verdant Mend: the archer binds the wounds with herbs and feathers. Heals level/5 + P x 1.0 to 1.5 (P = distance skill + attack of the bow + arrow, no bow needed).
-- The enchantment adds a rider: fire = the heal is 25% bigger | poison = removes every harmful condition | ice = 10% less damage from every element for 4s
-- (buff "Frost Mantle", subId 8720) | energy = +30% speed for 3s | no enchantment = only the heal.
local config = {heal = {1.0, 1.5}, fireBonus = 1.25, iceGuard = {percent = 10, duration = 4000}, haste = 3000}

function onCastSpell(cid, var)
	local element = Archer.element(cid)
	local def = element and Archer.elements[element]
	local min, max = Archer.values(cid, config.heal[1], config.heal[2])
	local amount = math.max(1, math.random(math.min(min, max), math.max(min, max)))
	if(element == "fire") then
		amount = math.floor(amount * config.fireBonus)
	end

	doCreatureAddHealth(cid, amount)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	if(def) then
		doSendMagicEffect(getCreaturePosition(cid), def.effect)
	end

	if(element == "poison") then
		Glyphs.cleanse(cid)
	elseif(element == "ice") then
		Archer.guard(cid, "Frost Mantle", 8720, config.iceGuard.percent, config.iceGuard.duration)
	elseif(element == "energy") then
		Glyphs.haste(cid, config.haste)
	end

	return true
end
