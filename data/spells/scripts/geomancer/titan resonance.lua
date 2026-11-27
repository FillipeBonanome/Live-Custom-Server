-- Titan's Resonance (Colossus): for 15s you become the Colossus. You take 15% less damage from every element (40% from the element of the gem in
-- the ammo slot) and every hit of your spells sends a bolt of stone from the target to up to 2 enemies close to it (Attacks.chainLightning), each
-- one taking 35% of the damage of that hit, falling 30% per jump (with a gem the bolt has its element). One bolt every half second at most.
-- The buff shows in !buffs; the bolts are in Geomancer.titanChain (data/lib/378-geomancer.lua), which also reads the glyphs:
--   glyph.storm = {bounces, share}    damage: the bolt reaches `bounces` enemies (instead of 2) with `share` of the damage (instead of 0.35)
--   glyph.ward  = {percent, heal}     defense: `percent` more resistance to every element and every bolt heals you `heal`% of your maximum health
local config = {duration = 15000, absorb = 15, gemAbsorb = 25}

function onCastSpell(cid, var)
	local glyph = Geomancer.glyph(cid, "titan resonance")
	local gem = Geomancer.gem(cid)
	local absorb = config.absorb + (glyph and glyph.ward and glyph.ward.percent or 0)

	local params = Geomancer.absorbAll(absorb)
	local description = absorb .. "% less damage from every element and your hits send a bolt of stone to nearby enemies."
	if(gem) then
		params[gem.absorb] = absorb + config.gemAbsorb
		description = description .. " " .. (absorb + config.gemAbsorb) .. "% less " .. gem.name:lower() .. " damage."
	end

	Geomancer.statBuff(cid, {
		name = "Titan's Resonance", subId = Geomancer.titanSubId, duration = config.duration, effect = CONST_ME_GROUNDSHAKER,
		description = description, params = params
	})

	doSendMagicEffect(getCreaturePosition(cid), gem and gem.area or CONST_ME_STONES)
	return true
end
