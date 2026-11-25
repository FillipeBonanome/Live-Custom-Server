-- Death Tornado (ultimate): a full disc of death with 5 SQM of radius around the Necromancer (no hole), swept tile by tile in one turn
-- of 1.3s (RingAttack, data/lib/069-ringattack.lua). Damage P x 1.2 to 2.0 per tile (a single hit per tile). It does not hold the enemies.
-- The animation of each tile is picked at random from `effects` (sent from onTile, so the damage hit itself draws nothing).
-- Glyphs (data/lib/403-glyphs.lua):
--   glyph.turns = n, glyph.share = x      the disc sweeps n times in a row, each turn with x of the damage (2 x 0.7 = 140%)
--   glyph.slow  = {percent, duration}     every monster the disc passes over is slowed
local KEY = "necromancer/death tornado"
local SWEEP = 1300
local effects = {CONST_ME_MORTAREA, CONST_ME_YALAHARIGHOST}

-- one turn of the disc, around where the necromancer is when it starts (the damage is read again at each turn)
local function sweep(cid, share, slow)
	if(not isCreature(cid) or getCreatureHealth(cid) <= 0) then
		return
	end

	local min, max = Necro.values(cid, 1.2, 2.0)
	RingAttack.execute(cid, {
		holeRadius = 0, ringThickness = 5, sweepDuration = SWEEP,
		elements = {{combatType = COMBAT_DEATHDAMAGE, effect = CONST_ME_NONE}},
		damageMin = math.floor(min * share), damageMax = math.floor(max * share),
		onTile = function(position)
			doSendMagicEffect(position, effects[math.random(#effects)])
			if(slow and isCreature(cid)) then
				local thing = getThingFromPos({x = position.x, y = position.y, z = position.z, stackpos = STACKPOS_TOP_CREATURE})
				if(thing and thing.uid and thing.uid > 0 and isCreature(thing.uid) and isMonster(thing.uid) and not getCreatureMaster(thing.uid)) then
					Glyphs.paralyze(cid, thing.uid, slow.percent, slow.duration)
				end
			end
		end
	})
end

function onCastSpell(cid, var)
	local glyph = Glyphs.get(cid, KEY)
	local turns = glyph and glyph.turns or 1
	local share = glyph and glyph.share or 1
	for turn = 0, turns - 1 do
		if(turn == 0) then
			sweep(cid, share, glyph and glyph.slow)
		else
			addEvent(sweep, turn * SWEEP, cid, share, glyph and glyph.slow)
		end
	end

	return true
end
