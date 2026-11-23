-- Disengage: jumps up to 3 tiles back (opposite to where you look, needs a free tile in sight) and leaves an effect where you were.
-- fire: explosion of fire 3x3 | poison: toxic cloud 3x3 | ice: chills the enemies around | energy: +30% speed for 3s
local config = {distance = 3, damage = {0.4, 0.6}, haste = 3000}

function onCastSpell(cid, var)
	local from = getCreaturePosition(cid)
	local v = Archer.vector(getCreatureLookDirection(cid))

	local dest
	for i = config.distance, 1, -1 do
		local pos = {x = from.x - v[1] * i, y = from.y - v[2] * i, z = from.z}
		if(isSightClear(from, pos, true) and doTileQueryAdd(cid, pos, 0, false) == RETURNVALUE_NOERROR) then
			dest = pos
			break
		end
	end

	if(not dest) then
		doPlayerSendCancel(cid, "There is no room behind you.")
		doSendMagicEffect(from, CONST_ME_POFF)
		return false
	end

	local element = Archer.element(cid)
	local def = Archer.elements[element]
	doTeleportThing(cid, dest)
	doSendMagicEffect(dest, CONST_ME_POFF)
	doSendMagicEffect(from, def.big)
	Archer.areaHit(cid, from, 1, config.damage[1], config.damage[2], element)

	if(element == "energy") then
		local condition = createConditionObject(CONDITION_HASTE)
		setConditionParam(condition, CONDITION_PARAM_TICKS, config.haste)
		setConditionFormula(condition, 0.3, 0, 0.3, 0)
		doAddCondition(cid, condition)
	end

	return true
end
