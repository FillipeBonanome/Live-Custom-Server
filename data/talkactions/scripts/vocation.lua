-- !vocation <name>
-- Shows the information of a vocation in a text dialog.
-- Without a name, shows the vocation of the player.
local descriptions = {
	[0] = "Starting character without a vocation.",
	[1] = "Glass cannon mage. Masters fire, energy and death magic and deals heavy ranged damage, but has low health.",
	[2] = "Nature mage. Uses ice and earth magic for damage and has the strongest healing spells for himself and allies.",
	[3] = "Ranged fighter. Shoots from a distance with high precision and also uses holy magic.",
	[4] = "Frontline warrior. Very resistant, with the most health and the strongest melee attacks, but almost no mana.",
	[5] = "Promoted Sorcerer. More regeneration and less loss on death, with the same destructive magic.",
	[6] = "Promoted Druid. More regeneration and less loss on death, with stronger healing and nature magic.",
	[7] = "Promoted Paladin. Deadlier at range and more resistant, with less loss on death.",
	[8] = "Promoted Knight. Even tougher in melee and with less loss on death.",
	[9] = "Holy support mage. Heals and buffs the group while hurting enemies with medium damage and medium range.",
	[10] = "Promoted Cleric. More regeneration, less loss on death and exclusive holy spells.",
	[11] = "Summoner mage. Raises undead minions from corpses and souls and fights alongside them with death and poison magic.",
	[12] = "Promoted Necromancer. More regeneration, less loss on death and exclusive spells: Soul Siphon, Bone Abomination, Corpse Explosion and Army of the Dead."
}

local function findVocation(name)
	name = name:lower()
	local partial
	for id = 0, 30 do
		local info = getVocationInfo(id)
		if(info) then
			local vname = info.name:lower()
			if(vname == name) then
				return info
			end

			if(not partial and vname:find(name, 1, true)) then
				partial = info
			end
		end
	end

	return partial
end

function onSay(cid, words, param, channel)
	local info
	if(param == "") then
		info = getVocationInfo(getPlayerVocation(cid))
	else
		info = findVocation(param)
		if(not info) then
			doPlayerSendCancel(cid, "Vocation not found.")
			return true
		end
	end

	local lines = {
		"Vocation: " .. info.name,
		"Premium needed: " .. (info.needPremium and "yes" or "no"),
		"",
		descriptions[info.id] or info.description,
		"",
		"Per level:",
		"  Health: +" .. info.healthGain,
		"  Mana: +" .. info.manaGain,
		"  Capacity: +" .. info.capacity,
		"",
		"Regeneration:",
		"  Health: " .. info.healthGainAmount .. " every " .. info.healthGainTicks .. "s",
		"  Mana: " .. info.manaGainAmount .. " every " .. info.manaGainTicks .. "s",
		"",
		"Experience multiplier: " .. info.experienceMultiplier,
		"Death loss reduction: " .. info.lessLoss .. "%",
		"Attack speed: " .. info.attackSpeed .. "ms"
	}

	doShowTextDialog(cid, 2160, table.concat(lines, "\n"))
	return true
end
