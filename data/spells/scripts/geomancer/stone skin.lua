-- Stone Skin: your armor hardens for 20s: +8 armor, +6 defense and 10% less physical damage. With a gem in the ammo slot you also take 25% less
-- damage of the element of the gem (violet energy, yellow holy, green poison, red fire, blue ice).
local config = {armor = 8, defense = 6, physical = 10, element = 25, duration = 20000}

function onCastSpell(cid, var)
	local gem = Geomancer.gem(cid)
	local params = {
		[CONDITION_PARAM_ARMOR] = config.armor, [CONDITION_PARAM_DEFENSE] = config.defense,
		[CONDITION_PARAM_ABSORB_PHYSICAL] = config.physical
	}

	local description = "+" .. config.armor .. " armor, +" .. config.defense .. " defense and " .. config.physical .. "% less physical damage."
	if(gem) then
		params[gem.absorb] = config.element
		description = description .. " " .. config.element .. "% less " .. gem.name:lower() .. " damage."
	end

	Geomancer.statBuff(cid, {
		name = "Stone Skin", subId = Geomancer.skinSubId, duration = config.duration, effect = CONST_ME_STONES,
		description = description, params = params
	})

	if(gem) then
		doSendMagicEffect(getCreaturePosition(cid), gem.area)
	end

	return true
end
