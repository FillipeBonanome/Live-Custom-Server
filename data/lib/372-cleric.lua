-- Cleric helpers shared by the Cleric spells (data/spells/scripts/*: holy ray, holy nova, pillar of light etc.).
--
-- Cleric.values(cid, minl, maxl, minm, maxm [, minc, maxc])  same formula as setAttackFormula(LEVELMAGIC):
--                                                              min = level/minl + magic*minm + minc (max the same with maxl/maxm/maxc)
-- Cleric.isAlly(cid, tid)            true for the caster and for the members of the caster's party
-- Cleric.allies(cid, pos, radius)    players (caster + party) at most `radius` tiles from pos
-- Cleric.heal(targets, min, max, effect)   heals each creature in the list for a random value between min and max
-- Cleric.zone{...}                   repeats damage / heal pulses (see the function), used by Rain of Light and Final Prayer

Cleric = {
	-- heal that Shield of Faith gives when it ends: [player cid] = {min, max}
	shieldHeal = {}
}

function Cleric.values(cid, minl, maxl, minm, maxm, minc, maxc)
	local level, magic = getPlayerLevel(cid), getPlayerMagLevel(cid)
	return math.floor(level / minl + magic * minm + (minc or 0)), math.floor(level / maxl + magic * maxm + (maxc or 0))
end

function Cleric.isAlly(cid, tid)
	if(cid == tid) then
		return true
	end

	local members = getPartyMembers(cid)
	return type(members) == 'table' and isInArray(members, tid)
end

function Cleric.allies(cid, pos, radius)
	local list = {}
	local spectators = getSpectators(pos, radius, radius, false)
	if(type(spectators) ~= 'table') then
		spectators = {}
	end

	-- the caster always counts, even when getSpectators does not return the center tile
	if(not isInArray(spectators, cid)) then
		table.insert(spectators, cid)
	end

	for _, tid in ipairs(spectators) do
		if(isPlayer(tid) and Cleric.isAlly(cid, tid) and getCreatureHealth(tid) > 0 and getDistanceBetween(getCreaturePosition(tid), pos) <= radius) then
			table.insert(list, tid)
		end
	end

	return list
end

function Cleric.heal(targets, min, max, effect)
	for _, tid in ipairs(targets) do
		doCreatureAddHealth(tid, math.random(min, max))
		if(effect) then
			doSendMagicEffect(getCreaturePosition(tid), effect)
		end
	end
end

-- Holy pulses. params:
--   cid      caster (the zone stops when the caster leaves the game)
--   pos      center (fixed) -- or follow = true to use the caster position at each pulse
--   area     area id (createCombatArea) for the damage        damage = {min, max}  (optional)
--   radius   heal radius (caster + party)                     heal   = {min, max}  (optional)
--   effect   magic effect shown on each damaged tile          ticks, interval (ms)
function Cleric.zone(params)
	local function pulse(left)
		local cid = params.cid
		if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
			return
		end

		local pos = params.follow and getCreaturePosition(cid) or params.pos
		if(params.damage) then
			doAreaCombatHealth(cid, COMBAT_HOLYDAMAGE, pos, params.area, -params.damage[1], -params.damage[2], params.effect)
		end

		if(params.heal) then
			Cleric.heal(Cleric.allies(cid, pos, params.radius), params.heal[1], params.heal[2], CONST_ME_MAGIC_BLUE)
		end

		if(left > 1) then
			addEvent(pulse, params.interval, left - 1)
		end
	end

	pulse(params.ticks)
end
