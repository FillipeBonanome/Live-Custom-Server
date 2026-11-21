local spells = {"Berserk", "Fierce Berserk", "Groundshaker"}

function onSay(cid, words, param, channel)
	doCreatureCastSpell(cid, spells[math.random(#spells)], true)
	return true
end
