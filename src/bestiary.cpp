////////////////////////////////////////////////////////////////////////
// OpenTibia - an opensource roleplaying game
////////////////////////////////////////////////////////////////////////
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////
#include "otpch.h"
#include "bestiary.h"

#include <iomanip>

#include "player.h"
#include "monsters.h"
#include "items.h"
#include "tools.h"
#include "configmanager.h"

extern ConfigManager g_config;
extern Monsters g_monsters;

//knowledge level needed to reveal each piece of information (clamped to the last level)
enum BestiaryReveal_t
{
	BESTIARY_REVEAL_BASIC = 1, //hitpoints, experience
	BESTIARY_REVEAL_DEFENSE = 2, //armor, defense, speed
	BESTIARY_REVEAL_ELEMENTS = 3, //resistances, immunities and loot
	BESTIARY_REVEAL_FULL = 4 //loot chances
};

typedef std::vector<std::pair<std::string, uint32_t> > BestiaryLoot;

static void collectLoot(const LootItems& list, BestiaryLoot& out)
{
	for(LootItems::const_iterator it = list.begin(); it != list.end(); ++it)
	{
		//containers (backpacks, bags...) are not interesting, only what is inside of them
		if(!it->childLoot.empty())
		{
			collectLoot(it->childLoot, out);
			continue;
		}

		if(it->ids.empty())
			continue;

		const std::string& name = Item::items[it->ids[0]].name;
		if(!name.empty())
			out.push_back(std::make_pair(name, it->chance));
	}
}

void Bestiary::parseKillsList(const std::string& str, std::vector<uint32_t>& out)
{
	out.clear();
	std::string normalized = str;
	std::replace(normalized.begin(), normalized.end(), ';', ',');

	StringVec parts = explodeString(normalized, ",");
	for(StringVec::iterator it = parts.begin(); it != parts.end(); ++it)
	{
		int32_t value = atoi(trimString(*it).c_str());
		if(value > 0)
			out.push_back((uint32_t)value);
	}

	std::sort(out.begin(), out.end());
	out.erase(std::unique(out.begin(), out.end()), out.end());
}

void Bestiary::parsePointsList(const std::string& str, std::vector<uint32_t>& out)
{
	out.clear();
	std::string normalized = str;
	std::replace(normalized.begin(), normalized.end(), ';', ',');

	StringVec parts = explodeString(normalized, ",");
	for(StringVec::iterator it = parts.begin(); it != parts.end(); ++it)
	{
		int32_t value = atoi(trimString(*it).c_str());
		if(value > 0)
			out.push_back((uint32_t)value);
	}
}

bool Bestiary::load()
{
	parseKillsList(g_config.getString(ConfigManager::BESTIARY_KILLS_PER_LEVEL), defaultKillsPerLevel);
	if(defaultKillsPerLevel.empty())
	{
		std::clog << "[Warning - Bestiary::load] Invalid bestiaryKillsPerLevel, using default values." << std::endl;
		defaultKillsPerLevel.push_back(10);
		defaultKillsPerLevel.push_back(100);
		defaultKillsPerLevel.push_back(500);
		defaultKillsPerLevel.push_back(1000);
	}

	parsePointsList(g_config.getString(ConfigManager::BESTIARY_POINTS_PER_LEVEL), defaultPointsPerLevel);
	if(defaultPointsPerLevel.empty())
	{
		std::clog << "[Warning - Bestiary::load] Invalid bestiaryPointsPerLevel, using default values." << std::endl;
		defaultPointsPerLevel.push_back(1);
		defaultPointsPerLevel.push_back(2);
		defaultPointsPerLevel.push_back(3);
		defaultPointsPerLevel.push_back(5);
	}

	//"minExperience:multiplier, ..."
	pointsByExperience.clear();
	StringVec brackets = explodeString(g_config.getString(ConfigManager::BESTIARY_POINTS_BY_EXPERIENCE), ",");
	for(StringVec::iterator it = brackets.begin(); it != brackets.end(); ++it)
	{
		StringVec pair = explodeString(trimString(*it), ":");
		if(pair.size() != 2)
			continue;

		double multiplier = atof(trimString(pair[1]).c_str());
		int64_t minExperience = atoll(trimString(pair[0]).c_str());
		if(multiplier > 0 && minExperience >= 0)
			pointsByExperience.push_back(std::make_pair((uint64_t)minExperience, multiplier));
	}

	std::sort(pointsByExperience.begin(), pointsByExperience.end());

	monsters.clear();
	lastId = 0;

	StringVec missing;
	const Monsters::MonsterMap& all = g_monsters.getMonsters();
	for(Monsters::MonsterMap::const_iterator it = all.begin(); it != all.end(); ++it)
	{
		MonsterType* mType = it->second;
		if(!mType->bestiaryId)
		{
			missing.push_back(mType->name);
			continue;
		}

		//monsters registered under several names share the same file (and so the same id), that is fine
		BestiaryMap::const_iterator mit = monsters.find(mType->bestiaryId);
		if(mit == monsters.end())
			monsters[mType->bestiaryId] = mType;
		else if(asLowerCaseString(mit->second->name) != asLowerCaseString(mType->name))
		{
			std::clog << "[Warning - Bestiary::load] Duplicated monster id " << mType->bestiaryId << " ("
				<< mit->second->name << " and " << mType->name << ")." << std::endl;
		}

		lastId = std::max(lastId, mType->bestiaryId);
	}

	if(!missing.empty())
	{
		std::clog << "[Warning - Bestiary::load] " << missing.size() << " monster(s) without monsterId, they will not be counted: ";
		for(uint32_t i = 0; i < missing.size() && i < 10; ++i)
			std::clog << (i ? ", " : "") << missing[i];

		if(missing.size() > 10)
			std::clog << "...";

		std::clog << std::endl;
	}

	std::clog << "> Last registered bestiary monster id: " << lastId << " (next free id: " << (lastId + 1) << ")" << std::endl;
	return true;
}

MonsterType* Bestiary::getMonsterType(uint32_t id) const
{
	BestiaryMap::const_iterator it = monsters.find(id);
	if(it != monsters.end())
		return it->second;

	return NULL;
}

const std::vector<uint32_t>& Bestiary::getKillsPerLevel(const MonsterType* mType) const
{
	if(mType && !mType->bestiaryKills.empty())
		return mType->bestiaryKills;

	return defaultKillsPerLevel;
}

uint32_t Bestiary::getLevel(const MonsterType* mType, uint32_t kills) const
{
	const std::vector<uint32_t>& levels = getKillsPerLevel(mType);
	uint32_t level = 0;
	while(level < levels.size() && kills >= levels[level])
		++level;

	return level;
}

uint32_t Bestiary::getLevelPoints(const MonsterType* mType, uint32_t level) const
{
	if(!mType || !level)
		return 0;

	//the xml can set the exact points of each level (the last value is used for the levels after it)
	if(!mType->bestiaryPoints.empty())
		return mType->bestiaryPoints[std::min<uint32_t>(level, mType->bestiaryPoints.size()) - 1];

	double multiplier = 1.;
	for(std::vector<std::pair<uint64_t, double> >::const_iterator it = pointsByExperience.begin(); it != pointsByExperience.end(); ++it)
	{
		if(mType->experience < it->first)
			break;

		multiplier = it->second;
	}

	uint32_t base = defaultPointsPerLevel[std::min<uint32_t>(level, defaultPointsPerLevel.size()) - 1];
	return std::max<uint32_t>(1, (uint32_t)(base * multiplier + 0.5));
}

uint32_t Bestiary::getPointsUpToLevel(const MonsterType* mType, uint32_t level) const
{
	uint32_t points = 0;
	for(uint32_t i = 1; i <= level; ++i)
		points += getLevelPoints(mType, i);

	return points;
}

uint32_t Bestiary::getPoints(const Player* player) const
{
	uint32_t points = 0;
	const BestiaryKillMap& kills = player->getBestiaryKills();
	for(BestiaryKillMap::const_iterator it = kills.begin(); it != kills.end(); ++it)
	{
		const MonsterType* mType = getMonsterType(it->first);
		if(mType)
			points += getPointsUpToLevel(mType, getLevel(mType, it->second));
	}

	return points;
}

uint32_t Bestiary::getTotalPoints() const
{
	uint32_t points = 0;
	for(BestiaryMap::const_iterator it = monsters.begin(); it != monsters.end(); ++it)
		points += getPointsUpToLevel(it->second, getMaxLevel(it->second));

	return points;
}

double Bestiary::getExperienceMultiplier(const Player* player, const MonsterType* mType) const
{
	if(!mType->bestiaryId)
		return 1.;

	uint32_t level = getLevel(mType, player->getBestiaryKills(mType->bestiaryId));
	return 1. + level * g_config.getDouble(ConfigManager::BESTIARY_EXP_PER_LEVEL) / 100.;
}

std::string Bestiary::getProgress(const MonsterType* mType, uint32_t kills) const
{
	const std::vector<uint32_t>& levels = getKillsPerLevel(mType);
	uint32_t level = getLevel(mType, kills);

	std::stringstream ss;
	ss << mType->name << " [" << kills << "/";
	if(level < levels.size())
		ss << levels[level];
	else
		ss << "MAX";

	ss << "]";
	return ss.str();
}

void Bestiary::onKill(Player* player, const MonsterType* mType) const
{
	if(!mType->bestiaryId)
		return;

	uint32_t oldLevel = getLevel(mType, player->getBestiaryKills(mType->bestiaryId)),
		kills = player->addBestiaryKill(mType->bestiaryId), level = getLevel(mType, kills);
	if(level > oldLevel)
	{
		std::stringstream ss;
		ss << "Bestiary: your knowledge about " << mType->name << " is now level " << level << "/" << getMaxLevel(mType)
			<< " (+" << (level * g_config.getDouble(ConfigManager::BESTIARY_EXP_PER_LEVEL)) << "% experience from this creature, +" << getLevelPoints(mType, level) << " bestiary point(s)).";
		player->sendTextMessage(MSG_STATUS_CONSOLE_ORANGE, ss.str());
	}

	if(player->isBestiaryTracking())
		player->sendTextMessage(MSG_STATUS_CONSOLE_ORANGE, getProgress(mType, kills));
}

std::string Bestiary::getDescription(const Player* player, const MonsterType* mType) const
{
	const std::vector<uint32_t>& levels = getKillsPerLevel(mType);
	uint32_t kills = player->getBestiaryKills(mType->bestiaryId), level = getLevel(mType, kills), maxLevel = levels.size();
	double bonus = level * g_config.getDouble(ConfigManager::BESTIARY_EXP_PER_LEVEL);

	std::stringstream ss;
	ss << "Bestiary - " << mType->name << " (ID " << mType->bestiaryId << ")\n\n";
	ss << "Kills: " << getProgress(mType, kills) << "\n";
	ss << "Knowledge level: " << level << "/" << maxLevel << "\n";
	ss << "Experience bonus: +" << bonus << "%\n";
	ss << "Bestiary points: " << getPointsUpToLevel(mType, level) << "/" << getPointsUpToLevel(mType, maxLevel) << "\n";
	ss << "Kills needed per level: ";
	for(uint32_t i = 0; i < levels.size(); ++i)
		ss << (i ? ", " : "") << levels[i];

	ss << "\n\n";
	if(!level)
	{
		ss << "You know nothing about this creature yet. Defeat " << levels[0] << " of them to start learning.";
		return ss.str();
	}

	#define BESTIARY_KNOWS(reveal) (level >= std::min<uint32_t>(reveal, maxLevel))
	ss << "Hitpoints: " << mType->healthMax << "\n";
	ss << "Experience: " << mType->experience << "\n";
	if(BESTIARY_KNOWS(BESTIARY_REVEAL_DEFENSE))
	{
		ss << "Armor: " << mType->armor << "\n";
		ss << "Defense: " << mType->defense << "\n";
		ss << "Speed: " << mType->baseSpeed << "\n";
	}
	else
		ss << "Armor / Defense / Speed: ???\n";

	if(BESTIARY_KNOWS(BESTIARY_REVEAL_ELEMENTS))
	{
		std::stringstream elements;
		for(ElementMap::const_iterator it = mType->elementMap.begin(); it != mType->elementMap.end(); ++it)
		{
			if(!it->second)
				continue;

			elements << "  " << getCombatName(it->first) << ": ";
			if(it->second >= 100)
				elements << "immune";
			else if(it->second > 0)
				elements << it->second << "% resistant";
			else
				elements << -it->second << "% weak";

			elements << "\n";
		}

		static const struct {CombatType_t type; const char* name;} immunities[] = {
			{COMBAT_PHYSICALDAMAGE, "physical"}, {COMBAT_ENERGYDAMAGE, "energy"}, {COMBAT_EARTHDAMAGE, "earth"},
			{COMBAT_FIREDAMAGE, "fire"}, {COMBAT_ICEDAMAGE, "ice"}, {COMBAT_HOLYDAMAGE, "holy"},
			{COMBAT_DEATHDAMAGE, "death"}, {COMBAT_DROWNDAMAGE, "drown"}, {COMBAT_LIFEDRAIN, "life drain"},
			{COMBAT_MANADRAIN, "mana drain"}
		};
		for(uint32_t i = 0; i < sizeof(immunities) / sizeof(immunities[0]); ++i)
		{
			if(mType->damageImmunities & (uint32_t)immunities[i].type)
				elements << "  " << immunities[i].name << ": immune\n";
		}

		ss << "\nElemental properties:\n" << (elements.str().empty() ? "  none\n" : elements.str());

		BestiaryLoot loot;
		collectLoot(mType->lootItems, loot);

		ss << "\nLoot:\n";
		if(loot.empty())
			ss << "  none\n";

		bool chances = BESTIARY_KNOWS(BESTIARY_REVEAL_FULL);
		for(BestiaryLoot::const_iterator it = loot.begin(); it != loot.end(); ++it)
		{
			ss << "  " << it->first;
			if(chances)
				ss << " (" << std::fixed << std::setprecision(2) << (it->second * 100. / MAX_LOOTCHANCE) << "%)" << std::setprecision(6);

			ss << "\n";
		}
	}
	else
		ss << "\nElemental properties and loot: ???\n";

	if(level < maxLevel)
		ss << "\nNext level in " << (levels[level] - kills) << " kill(s).";
	else
		ss << "\nYou know everything about this creature.";

	#undef BESTIARY_KNOWS
	return ss.str();
}

std::string Bestiary::getHelp() const
{
	std::stringstream ss;
	ss << "Bestiary\n\n"
		<< "Every creature you defeat is registered in your bestiary. The more you kill, the more you learn about it "
		<< "(hitpoints, experience, armor, defense, resistances and loot) and the more experience you get from it.\n\n"
		<< "Default kills needed per level: ";
	for(uint32_t i = 0; i < defaultKillsPerLevel.size(); ++i)
		ss << (i ? ", " : "") << defaultKillsPerLevel[i];

	ss << "\nExperience bonus per completed level: +" << g_config.getDouble(ConfigManager::BESTIARY_EXP_PER_LEVEL) << "%\n\n"
		<< "Every completed level also gives bestiary points, spent on spell glyphs (!glyphs).\n\n"
		<< "Commands:\n"
		<< "  !bestiary <monster name> - shows what you know about a creature\n"
		<< "  !trackbestiary on/off - shows your kills progress (e.g. Rotworm [766/1000]) every time you kill a creature";
	return ss.str();
}
