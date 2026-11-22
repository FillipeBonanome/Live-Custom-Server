-- Vanish: invisible for 5s; for 4s every hit is a critical (buff "Vanish"). Gives 1 Momentum.
local config = {invisible = 5000}

function onCastSpell(cid, var)
	Assassin.fx("assassin_vanish", cid)
	Assassin.invisible(cid, config.invisible)
	Assassin.addBuff(cid, "vanish")
	Assassin.momentum(cid)
	return true
end
