-- Stone Skin: your armor hardens for 20s: +8 armor, +6 defense and 10% less physical damage. With a gem in the ammo slot you also take 25% less
-- damage of the element of the gem (violet energy, yellow holy, green poison, red fire, blue ice).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.bastion = {armor, defense, physical, element}   defense: stronger numbers for the same 20s
--   glyph.living  = {percent}                             sustain: you recover `percent`% of your maximum health every second while it lasts
local config = {armor = 8, defense = 6, physical = 10, element = 25, duration = 20000}

function onCastSpell(cid, var)
	local glyph = Geomancer.glyph(cid, "stone skin")
	local armor, defense, physical, element = config.armor, config.defense, config.physical, config.element
	if(glyph and glyph.bastion) then
		armor, defense, physical, element = glyph.bastion.armor, glyph.bastion.defense, glyph.bastion.physical, glyph.bastion.element
	end

	local gem = Geomancer.gem(cid)
	local params = {
		[CONDITION_PARAM_ARMOR] = armor, [CONDITION_PARAM_DEFENSE] = defense,
		[CONDITION_PARAM_ABSORB_PHYSICAL] = physical
	}

	local description = "+" .. armor .. " armor, +" .. defense .. " defense and " .. physical .. "% less physical damage."
	if(gem) then
		params[gem.absorb] = element
		description = description .. " " .. element .. "% less " .. gem.name:lower() .. " damage."
	end

	Geomancer.statBuff(cid, {
		name = "Stone Skin", subId = Geomancer.skinSubId, duration = config.duration, effect = CONST_ME_STONES,
		description = description, params = params
	})

	if(glyph and glyph.living) then
		Glyphs.regen(cid, glyph.living.percent, config.duration / 1000, 1000)
	end

	if(gem) then
		doSendMagicEffect(getCreaturePosition(cid), gem.area)
	end

	return true
end
