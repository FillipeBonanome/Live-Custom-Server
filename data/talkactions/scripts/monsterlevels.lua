-- /monsterlevels (staff): lists the monsters that are not in the hardcoded table (MonsterLevels, data/lib/302-monsterlevels.lua) with their
-- calculated level, as lines ready to paste into the table.
-- /monsterlevels <name>: shows the hardcoded and the calculated level of a monster, and the data used by the formula.
function onSay(cid, words, param, channel)
	local list = getMonsterList()
	if(type(list) ~= 'table') then
		doPlayerSendCancel(cid, "getMonsterList() is not available.")
		return true
	end

	param = param:trim():lower()
	if(param ~= "") then
		for _, monster in ipairs(list) do
			if(monster.name:lower() == param) then
				local calculated, details = MonsterLevel.calculate(monster)
				local hardcoded = MonsterLevels[param]
				doPlayerPopupFYI(cid, monster.name .. "\n\nLevel in use: " .. MonsterLevel.get(monster.name, monster) ..
					"\nHardcoded (MonsterLevels): " .. (hardcoded and tostring(hardcoded) or "none") ..
					"\nCalculated by the formula: " .. calculated .. " (" .. details.source .. ")" ..
					"\n\nHealth: " .. monster.healthMax .. "\nExperience: " .. monster.experience ..
					"\nDamage per second: " .. string.format("%.1f", monster.damagePerSecond) ..
					"\nHighest hit: " .. math.floor(monster.maxHit) .. "\nBurst: " .. math.floor(monster.burst) ..
					"\nAttacks: " .. monster.attackCount .. " (" .. monster.unknownAttacks .. " without damage)")
				return true
			end
		end

		doPlayerSendCancel(cid, "Monster not found: " .. param)
		return true
	end

	local lines, seen = {}, {}
	for _, monster in ipairs(list) do
		local key = monster.name:lower()
		if(not MonsterLevels[key] and not seen[key]) then
			seen[key] = true
			table.insert(lines, {level = (MonsterLevel.calculate(monster)), text = '["' .. key .. '"] = ' .. (MonsterLevel.calculate(monster)) .. ', -- ' .. monster.name})
		end
	end

	table.sort(lines, function(a, b)
		if(a.level ~= b.level) then
			return a.level < b.level
		end

		return a.text < b.text
	end)

	local text = {}
	for _, line in ipairs(lines) do
		table.insert(text, line.text)
	end

	doPlayerPopupFYI(cid, (#lines == 0) and "All the monsters are in MonsterLevels." or ("Monsters missing in MonsterLevels: " .. #lines .. "\n\n" .. table.concat(text, "\n")))
	return true
end
