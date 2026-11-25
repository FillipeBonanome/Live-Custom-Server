-- Bone Shell: consumes your weakest summon (never the Dragon Skeleton): +14 armor and +10 defense for 15s and gives back 3 soul.
-- Glyphs (data/lib/403-glyphs.lua): glyph.buff = another version of the buff in Necro.buffs (Reinforced Shell: +24/+18; Shell Burst: explodes in
-- death when it ends).
local KEY = "necromancer/bone shell"

function onCastSpell(cid, var)
	if(not Necro.sacrifice(cid)) then
		return false
	end

	local glyph = Glyphs.get(cid, KEY)
	return Necro.addBuff(cid, glyph and glyph.buff or "bone_shell")
end
