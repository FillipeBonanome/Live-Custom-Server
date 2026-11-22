-- Phantom Clones (Nightblade): 2 clones with your outfit fight at your side for 12s. They use no summon slot.
function onCastSpell(cid, var)
	return Assassin.clones(cid)
end
