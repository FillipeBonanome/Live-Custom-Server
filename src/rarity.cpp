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
#include "rarity.h"

#include "player.h"
#include "container.h"
#include "items.h"
#include "tools.h"
#include "uniques.h"
#include "enchants.h"
#include "game.h"
#include "configmanager.h"

extern ConfigManager g_config;
extern Game g_game;

enum RarityAttributeKind_t
{
	RATTR_BONUS, //Player::varBonus
	RATTR_SKILL, //Player::varSkills
	RATTR_STAT, //Player::varStats
	RATTR_SPEED, //creature speed
	RATTR_ITEM //added to the item itself (attack, defense, armor)
};

enum RarityItemStat_t
{
	RITEM_ATTACK = 0,
	RITEM_DEFENSE,
	RITEM_ARMOR
};

struct RarityAttribute
{
	const char* key;
	const char* label;
	RarityAttributeKind_t kind;
	int32_t index;
};

//keys are the same used in items.xml
static const RarityAttribute attributeTable[] =
{
	{"attack", "attack", RATTR_ITEM, RITEM_ATTACK},
	{"defense", "defense", RATTR_ITEM, RITEM_DEFENSE},
	{"armor", "armor", RATTR_ITEM, RITEM_ARMOR},
	{"bonusarmor", "armor bonus", RATTR_BONUS, BONUS_ARMOR},
	{"bonusarmorpercent", "armor bonus %", RATTR_BONUS, BONUS_ARMOR_PERCENT},
	{"bonusdefense", "defense bonus", RATTR_BONUS, BONUS_DEFENSE},
	{"bonusdefensepercent", "defense bonus %", RATTR_BONUS, BONUS_DEFENSE_PERCENT},
	{"cooldownreduction", "cooldown reduction", RATTR_BONUS, BONUS_COOLDOWN_REDUCTION},
	{"lifeleech", "life leech", RATTR_BONUS, BONUS_LIFE_LEECH},
	{"manaleech", "mana leech", RATTR_BONUS, BONUS_MANA_LEECH},
	{"bonusexperience", "experience", RATTR_BONUS, BONUS_EXPERIENCE},
	{"bonusloot", "loot", RATTR_BONUS, BONUS_LOOT},
	{"dodge", "dodge", RATTR_BONUS, BONUS_DODGE},
	{"criticalchance", "critical chance", RATTR_BONUS, BONUS_CRITICAL_CHANCE},
	{"criticaldamage", "critical damage", RATTR_BONUS, BONUS_CRITICAL_DAMAGE},
	{"blockcount", "block count", RATTR_BONUS, BONUS_BLOCK_COUNT},
	{"criticalhealing", "critical healing", RATTR_BONUS, BONUS_CRITICAL_HEALING},
	{"elementalpenetrationphysical", "physical penetration", RATTR_BONUS, BONUS_PENETRATION_PHYSICAL},
	{"elementalpenetrationenergy", "energy penetration", RATTR_BONUS, BONUS_PENETRATION_ENERGY},
	{"elementalpenetrationearth", "earth penetration", RATTR_BONUS, BONUS_PENETRATION_EARTH},
	{"elementalpenetrationfire", "fire penetration", RATTR_BONUS, BONUS_PENETRATION_FIRE},
	{"elementalpenetrationice", "ice penetration", RATTR_BONUS, BONUS_PENETRATION_ICE},
	{"elementalpenetrationholy", "holy penetration", RATTR_BONUS, BONUS_PENETRATION_HOLY},
	{"elementalpenetrationdeath", "death penetration", RATTR_BONUS, BONUS_PENETRATION_DEATH},
	{"elementalpenetrationdrown", "drown penetration", RATTR_BONUS, BONUS_PENETRATION_DROWN},
	{"onhitelementalphysical", "physical on hit", RATTR_BONUS, BONUS_ONHIT_PHYSICAL},
	{"onhitelementalenergy", "energy on hit", RATTR_BONUS, BONUS_ONHIT_ENERGY},
	{"onhitelementalearth", "earth on hit", RATTR_BONUS, BONUS_ONHIT_EARTH},
	{"onhitelementalfire", "fire on hit", RATTR_BONUS, BONUS_ONHIT_FIRE},
	{"onhitelementalice", "ice on hit", RATTR_BONUS, BONUS_ONHIT_ICE},
	{"onhitelementalholy", "holy on hit", RATTR_BONUS, BONUS_ONHIT_HOLY},
	{"onhitelementaldeath", "death on hit", RATTR_BONUS, BONUS_ONHIT_DEATH},
	{"onhitelementaldrown", "drown on hit", RATTR_BONUS, BONUS_ONHIT_DROWN},
	{"skillfist", "fist fighting", RATTR_SKILL, SKILL_FIST},
	{"skillclub", "club fighting", RATTR_SKILL, SKILL_CLUB},
	{"skillsword", "sword fighting", RATTR_SKILL, SKILL_SWORD},
	{"skillaxe", "axe fighting", RATTR_SKILL, SKILL_AXE},
	{"skilldist", "distance fighting", RATTR_SKILL, SKILL_DIST},
	{"skillshield", "shielding", RATTR_SKILL, SKILL_SHIELD},
	{"skillfish", "fishing", RATTR_SKILL, SKILL_FISH},
	{"maxhealthpoints", "max health", RATTR_STAT, STAT_MAXHEALTH},
	{"maxmanapoints", "max mana", RATTR_STAT, STAT_MAXMANA},
	{"magiclevelpoints", "magic level", RATTR_STAT, STAT_MAGICLEVEL},
	{"speed", "speed", RATTR_SPEED, 0}
};

static const size_t attributeCount = sizeof(attributeTable) / sizeof(attributeTable[0]);

static const char* RARITY_ATTR = "rarity";
static const char* RARITY_BONUS_ATTR = "raritybonus";

const RarityAttribute* Rarity::getAttribute(const std::string& key)
{
	for(size_t i = 0; i < attributeCount; ++i)
	{
		if(key == attributeTable[i].key)
			return &attributeTable[i];
	}

	return NULL;
}

bool Rarity::isEnabled() const
{
	return g_config.getBool(ConfigManager::RARITY_ENABLED);
}

bool Rarity::load()
{
	rarities.clear();
	archetypes.clear();
	lootOrder.clear();

	std::map<std::string, int32_t> bases;
	bool ret = loadAttributes(bases);
	if(!loadArchetypes(bases))
		ret = false;

	if(!loadRarities())
		ret = false;

	//rolled from the rarest to the most common one
	for(std::vector<RarityType>::const_iterator it = rarities.begin(); it != rarities.end(); ++it)
	{
		if(it->chance > 0)
			lootOrder.push_back(&(*it));
	}

	std::sort(lootOrder.begin(), lootOrder.end(), RarityChanceLess());
	return ret;
}

bool Rarity::loadAttributes(std::map<std::string, int32_t>& bases)
{
	xmlDocPtr doc = xmlParseFile(getFilePath(FILE_TYPE_XML, "rarity_attributes.xml").c_str());
	if(!doc)
	{
		std::clog << "[Warning - Rarity::loadAttributes] Cannot load rarity_attributes.xml." << std::endl;
		std::clog << getLastXMLError() << std::endl;
		return false;
	}

	xmlNodePtr root = xmlDocGetRootElement(doc);
	if(xmlStrcmp(root->name, (const xmlChar*)"attributes"))
	{
		std::clog << "[Error - Rarity::loadAttributes] Malformed rarity_attributes.xml." << std::endl;
		xmlFreeDoc(doc);
		return false;
	}

	std::string strValue;
	int32_t intValue;
	for(xmlNodePtr p = root->children; p; p = p->next)
	{
		if(xmlStrcmp(p->name, (const xmlChar*)"attribute"))
			continue;

		if(!readXMLString(p, "name", strValue))
		{
			std::clog << "[Warning - Rarity::loadAttributes] Attribute without name." << std::endl;
			continue;
		}

		strValue = asLowerCaseString(strValue);
		if(!getAttribute(strValue))
		{
			std::clog << "[Warning - Rarity::loadAttributes] Unknown attribute \"" << strValue << "\"." << std::endl;
			continue;
		}

		if(!readXMLInteger(p, "base", intValue) || intValue < 1)
		{
			std::clog << "[Warning - Rarity::loadAttributes] Attribute \"" << strValue << "\" without a valid base (>= 1)." << std::endl;
			continue;
		}

		bases[strValue] = intValue;
	}

	xmlFreeDoc(doc);
	return true;
}

bool Rarity::loadArchetypes(const std::map<std::string, int32_t>& bases)
{
	xmlDocPtr doc = xmlParseFile(getFilePath(FILE_TYPE_XML, "rarity_archetypes.xml").c_str());
	if(!doc)
	{
		std::clog << "[Warning - Rarity::loadArchetypes] Cannot load rarity_archetypes.xml." << std::endl;
		std::clog << getLastXMLError() << std::endl;
		return false;
	}

	xmlNodePtr root = xmlDocGetRootElement(doc);
	if(xmlStrcmp(root->name, (const xmlChar*)"archetypes"))
	{
		std::clog << "[Error - Rarity::loadArchetypes] Malformed rarity_archetypes.xml." << std::endl;
		xmlFreeDoc(doc);
		return false;
	}

	std::string strValue;
	int32_t intValue;
	for(xmlNodePtr p = root->children; p; p = p->next)
	{
		if(xmlStrcmp(p->name, (const xmlChar*)"archetype"))
			continue;

		Archetype archetype;
		archetype.weaponType = -1;
		archetype.slots = 0;
		if(!readXMLString(p, "name", archetype.name))
			archetype.name = "unnamed";

		if(readXMLString(p, "weapontype", strValue))
		{
			strValue = asLowerCaseString(strValue);
			if(strValue == "sword")
				archetype.weaponType = WEAPON_SWORD;
			else if(strValue == "club")
				archetype.weaponType = WEAPON_CLUB;
			else if(strValue == "axe")
				archetype.weaponType = WEAPON_AXE;
			else if(strValue == "distance" || strValue == "dist")
				archetype.weaponType = WEAPON_DIST;
			else if(strValue == "shield")
				archetype.weaponType = WEAPON_SHIELD;
			else if(strValue == "fist")
				archetype.weaponType = WEAPON_FIST;
			else if(strValue == "wand" || strValue == "rod")
				archetype.weaponType = WEAPON_WAND;
			else if(strValue == "ammunition" || strValue == "ammo")
				archetype.weaponType = WEAPON_AMMO;
			else
			{
				std::clog << "[Warning - Rarity::loadArchetypes] Archetype \"" << archetype.name << "\": unknown weapontype \"" << strValue << "\"." << std::endl;
				continue;
			}
		}

		if(readXMLString(p, "slottype", strValue))
		{
			strValue = asLowerCaseString(strValue);
			if(strValue == "head")
				archetype.slots = SLOTP_HEAD;
			else if(strValue == "armor" || strValue == "body")
				archetype.slots = SLOTP_ARMOR;
			else if(strValue == "legs")
				archetype.slots = SLOTP_LEGS;
			else if(strValue == "feet")
				archetype.slots = SLOTP_FEET;
			else if(strValue == "necklace")
				archetype.slots = SLOTP_NECKLACE;
			else if(strValue == "ring")
				archetype.slots = SLOTP_RING;
			else if(strValue == "ammo")
				archetype.slots = SLOTP_AMMO;
			else if(strValue == "backpack")
				archetype.slots = SLOTP_BACKPACK;
			else
			{
				std::clog << "[Warning - Rarity::loadArchetypes] Archetype \"" << archetype.name << "\": unknown slottype \"" << strValue << "\"." << std::endl;
				continue;
			}
		}

		if(archetype.weaponType == -1 && !archetype.slots)
		{
			std::clog << "[Warning - Rarity::loadArchetypes] Archetype \"" << archetype.name << "\" needs a weapontype or a slottype." << std::endl;
			continue;
		}

		for(xmlNodePtr q = p->children; q; q = q->next)
		{
			if(xmlStrcmp(q->name, (const xmlChar*)"attribute"))
				continue;

			if(!readXMLString(q, "name", strValue))
				continue;

			strValue = asLowerCaseString(strValue);
			ArchetypeAttribute attribute;
			if(!(attribute.info = getAttribute(strValue)))
			{
				std::clog << "[Warning - Rarity::loadArchetypes] Archetype \"" << archetype.name << "\": unknown attribute \"" << strValue << "\"." << std::endl;
				continue;
			}

			if(readXMLInteger(q, "base", intValue) && intValue > 0)
				attribute.base = intValue;
			else
			{
				std::map<std::string, int32_t>::const_iterator it = bases.find(strValue);
				if(it == bases.end())
				{
					std::clog << "[Warning - Rarity::loadArchetypes] Archetype \"" << archetype.name << "\": attribute \"" << strValue << "\" has no base in rarity_attributes.xml." << std::endl;
					continue;
				}

				attribute.base = it->second;
			}

			archetype.attributes.push_back(attribute);
		}

		if(archetype.attributes.empty())
		{
			std::clog << "[Warning - Rarity::loadArchetypes] Archetype \"" << archetype.name << "\" has no valid attributes." << std::endl;
			continue;
		}

		archetypes.push_back(archetype);
	}

	xmlFreeDoc(doc);
	return true;
}

bool Rarity::loadRarities()
{
	xmlDocPtr doc = xmlParseFile(getFilePath(FILE_TYPE_XML, "rarities.xml").c_str());
	if(!doc)
	{
		std::clog << "[Warning - Rarity::loadRarities] Cannot load rarities.xml." << std::endl;
		std::clog << getLastXMLError() << std::endl;
		return false;
	}

	xmlNodePtr root = xmlDocGetRootElement(doc);
	if(xmlStrcmp(root->name, (const xmlChar*)"rarities"))
	{
		std::clog << "[Error - Rarity::loadRarities] Malformed rarities.xml." << std::endl;
		xmlFreeDoc(doc);
		return false;
	}

	std::string strValue;
	int32_t intValue;
	for(xmlNodePtr p = root->children; p; p = p->next)
	{
		if(xmlStrcmp(p->name, (const xmlChar*)"rarity"))
			continue;

		RarityType rarity;
		if(!readXMLString(p, "name", rarity.name) || rarity.name.empty())
		{
			std::clog << "[Warning - Rarity::loadRarities] Rarity without name." << std::endl;
			continue;
		}

		if(getRarity(rarity.name))
		{
			std::clog << "[Warning - Rarity::loadRarities] Duplicated rarity \"" << rarity.name << "\"." << std::endl;
			continue;
		}

		rarity.multiplier = 1.;
		if(readXMLString(p, "multiplier", strValue))
			rarity.multiplier = std::max(0., atof(strValue.c_str()));

		rarity.attributes = 1;
		if(readXMLInteger(p, "attributes", intValue))
			rarity.attributes = std::max((int32_t)0, intValue);

		rarity.effect = MAGIC_EFFECT_WRAPS_GREEN;
		if(readXMLInteger(p, "effect", intValue))
			rarity.effect = (uint8_t)intValue;

		rarity.color = COLOR_ORANGE;
		if(readXMLInteger(p, "color", intValue))
			rarity.color = (uint8_t)intValue;

		//the drop chances are in config.lua
		std::string lower = asLowerCaseString(rarity.name);
		if(lower == "uncommon")
			rarity.chance = g_config.getDouble(ConfigManager::RARITY_CHANCE_UNCOMMON);
		else if(lower == "rare")
			rarity.chance = g_config.getDouble(ConfigManager::RARITY_CHANCE_RARE);
		else if(lower == "epic")
			rarity.chance = g_config.getDouble(ConfigManager::RARITY_CHANCE_EPIC);
		else if(lower == "legendary")
			rarity.chance = g_config.getDouble(ConfigManager::RARITY_CHANCE_LEGENDARY);
		else
			rarity.chance = 0.;

		rarities.push_back(rarity);
	}

	xmlFreeDoc(doc);
	return true;
}

const Rarity::RarityType* Rarity::getRarity(const std::string& name) const
{
	for(std::vector<RarityType>::const_iterator it = rarities.begin(); it != rarities.end(); ++it)
	{
		if(!strcasecmp(it->name.c_str(), name.c_str()))
			return &(*it);
	}

	return NULL;
}

const Rarity::Archetype* Rarity::getArchetype(const Item* item) const
{
	if(!item)
		return NULL;

	const ItemType& it = Item::items[item->getID()];
	if(it.stackable || it.isContainer())
		return NULL;

	for(std::vector<Archetype>::const_iterator ait = archetypes.begin(); ait != archetypes.end(); ++ait)
	{
		if(ait->weaponType != -1 && (int32_t)it.weaponType != ait->weaponType)
			continue;

		if(ait->slots && !(it.slotPosition & ait->slots))
			continue;

		return &(*ait);
	}

	return NULL;
}

std::string Rarity::getName(const Item* item)
{
	if(!item)
		return "";

	const std::string* name = item->getStringAttribute(RARITY_ATTR);
	return name ? *name : "";
}

bool Rarity::canHaveRarity(const Item* item) const
{
	return getArchetype(item) != NULL;
}

void Rarity::parseBonuses(const std::string& data, std::vector<std::pair<std::string, int32_t> >& out)
{
	StringVec parts = explodeString(data, ",");
	for(StringVec::const_iterator it = parts.begin(); it != parts.end(); ++it)
	{
		size_t pos = it->find(':');
		if(pos == std::string::npos)
			continue;

		out.push_back(std::make_pair(it->substr(0, pos), atoi(it->substr(pos + 1).c_str())));
	}
}

void Rarity::clearRarity(Item* item)
{
	if(const std::string* data = item->getStringAttribute(RARITY_BONUS_ATTR))
	{
		std::vector<std::pair<std::string, int32_t> > bonuses;
		parseBonuses(*data, bonuses);
		for(std::vector<std::pair<std::string, int32_t> >::const_iterator it = bonuses.begin(); it != bonuses.end(); ++it)
		{
			const RarityAttribute* info = getAttribute(it->first);
			if(!info || info->kind != RATTR_ITEM)
				continue;

			switch(info->index)
			{
				case RITEM_ATTACK:
					item->setAttribute("attack", item->getAttack() - it->second);
					break;
				case RITEM_DEFENSE:
					item->setAttribute("defense", item->getDefense() - it->second);
					break;
				case RITEM_ARMOR:
					item->setAttribute("armor", item->getArmor() - it->second);
					break;
				default:
					break;
			}
		}
	}

	item->eraseAttribute(RARITY_ATTR);
	item->eraseAttribute(RARITY_BONUS_ATTR);
}

bool Rarity::setRarity(Item* item, const std::string& name) const
{
	if(!item)
		return false;

	std::string lower = name;
	trimString(lower);
	lower = asLowerCaseString(lower);
	if(lower.empty() || lower == "none")
	{
		clearRarity(item);
		return true;
	}

	const RarityType* rarity = getRarity(lower);
	const Archetype* archetype = getArchetype(item);
	if(!rarity || !archetype)
		return false;

	clearRarity(item);

	//pick distinct attributes of the archetype
	std::vector<const ArchetypeAttribute*> pool;
	for(std::vector<ArchetypeAttribute>::const_iterator it = archetype->attributes.begin(); it != archetype->attributes.end(); ++it)
		pool.push_back(&(*it));

	std::stringstream bonuses;
	uint32_t amount = std::min((uint32_t)pool.size(), rarity->attributes);
	for(uint32_t i = 0; i < amount; ++i)
	{
		size_t pick = i + (size_t)random_range(0, (int32_t)(pool.size() - i - 1));
		std::swap(pool[i], pool[pick]);

		const ArchetypeAttribute* attribute = pool[i];
		int32_t value = std::max((int32_t)1, (int32_t)std::floor((double)attribute->base * rarity->multiplier + 0.5));
		if(i)
			bonuses << ",";

		bonuses << attribute->info->key << ":" << value;
		if(attribute->info->kind != RATTR_ITEM)
			continue;

		switch(attribute->info->index)
		{
			case RITEM_ATTACK:
				item->setAttribute("attack", item->getAttack() + value);
				break;
			case RITEM_DEFENSE:
				item->setAttribute("defense", item->getDefense() + value);
				break;
			case RITEM_ARMOR:
				item->setAttribute("armor", item->getArmor() + value);
				break;
			default:
				break;
		}
	}

	item->setAttribute(RARITY_ATTR, rarity->name);
	if(amount)
		item->setAttribute(RARITY_BONUS_ATTR, bonuses.str());

	return true;
}

const Rarity::RarityType* Rarity::rollLootRarity() const
{
	if(lootOrder.empty())
		return NULL;

	double roll = (double)random_range(0, 1000000) / 10000.;
	double sum = 0.;
	for(std::vector<const RarityType*>::const_iterator it = lootOrder.begin(); it != lootOrder.end(); ++it)
	{
		sum += (*it)->chance;
		if(roll < sum)
			return *it;
	}

	return NULL;
}

void Rarity::onLoot(Container* corpse, Player* killer) const
{
	if(!corpse || !isEnabled() || lootOrder.empty())
		return;

	std::vector<std::pair<Item*, const RarityType*> > dropped;
	for(ContainerIterator it = corpse->begin(), end = corpse->end(); it != end; ++it)
	{
		Item* item = *it;
		if(!item || !getName(item).empty() || item->hasStringAttribute("unique") || !canHaveRarity(item))
			continue;

		const RarityType* rarity = rollLootRarity();
		if(rarity && setRarity(item, rarity->name))
			dropped.push_back(std::make_pair(item, rarity));
	}

	if(dropped.empty())
		return;

	const Position& pos = corpse->getPosition();
	std::set<uint8_t> effects;
	for(std::vector<std::pair<Item*, const RarityType*> >::const_iterator it = dropped.begin(); it != dropped.end(); ++it)
	{
		g_game.addAnimatedText(pos, it->second->color, it->second->name);
		if(effects.insert(it->second->effect).second)
			g_game.addMagicEffect(pos, it->second->effect);

		if(killer)
		{
			std::stringstream ss;
			ss << "Your kill dropped an item with rarity: " << it->first->getName() << " (" << it->second->name << ").";
			killer->sendTextMessage(MSG_STATUS_CONSOLE_ORANGE, ss.str());
		}
	}
}

bool Rarity::addItemAttribute(Item* item, const std::string& key, int32_t value)
{
	const RarityAttribute* info = getAttribute(key);
	if(!item || !info || info->kind != RATTR_ITEM)
		return false;

	switch(info->index)
	{
		case RITEM_ATTACK:
			item->setAttribute("attack", item->getAttack() + value);
			break;
		case RITEM_DEFENSE:
			item->setAttribute("defense", item->getDefense() + value);
			break;
		case RITEM_ARMOR:
			item->setAttribute("armor", item->getArmor() + value);
			break;
		default:
			return false;
	}

	return true;
}

bool Rarity::isEquipAttribute(const std::string& key)
{
	const RarityAttribute* info = getAttribute(key);
	return info && info->kind != RATTR_ITEM;
}

std::string Rarity::formatBonuses(const std::string& data)
{
	std::vector<std::pair<std::string, int32_t> > bonuses;
	parseBonuses(data, bonuses);

	std::stringstream s;
	bool begin = true;
	for(std::vector<std::pair<std::string, int32_t> >::const_iterator it = bonuses.begin(); it != bonuses.end(); ++it)
	{
		const RarityAttribute* info = getAttribute(it->first);
		if(!info)
			continue;

		if(!begin)
			s << ", ";

		begin = false;

		//the speed shown by the client is half of the real one
		int32_t value = (info->kind == RATTR_SPEED ? it->second / 2 : it->second);
		s << info->label << " " << std::showpos << value << std::noshowpos;
	}

	return s.str();
}

std::string Rarity::getDescription(const Item* item) const
{
	std::string name = getName(item);
	if(name.empty())
		return "";

	std::stringstream s;
	if(const std::string* data = item->getStringAttribute(RARITY_BONUS_ATTR))
	{
		std::string bonuses = formatBonuses(*data);
		if(!bonuses.empty())
			s << "\nrarity bonus: " << bonuses;
	}

	s << "\nrarity: " << name;
	return s.str();
}

std::string Rarity::getEquipBonuses(const Item* item)
{
	if(!item)
		return "";

	std::vector<std::pair<std::string, int32_t> > bonuses;
	if(const std::string* data = item->getStringAttribute(RARITY_BONUS_ATTR))
		parseBonuses(*data, bonuses);

	std::stringstream s;
	bool begin = true;
	for(std::vector<std::pair<std::string, int32_t> >::const_iterator it = bonuses.begin(); it != bonuses.end(); ++it)
	{
		const RarityAttribute* info = getAttribute(it->first);
		if(!info || info->kind == RATTR_ITEM)
			continue;

		if(!begin)
			s << ",";

		begin = false;
		s << it->first << ":" << it->second;
	}

	//bonuses of an unique item and of the enchantments add up with the rarity ones
	std::string result = s.str();
	std::string extra = Uniques::getEquipBonuses(item);
	if(!extra.empty())
		result += (result.empty() ? "" : ",") + extra;

	extra = g_enchants->getEquipBonuses(item);
	if(!extra.empty())
		result += (result.empty() ? "" : ",") + extra;

	return result;
}

void Rarity::applyEquipBonuses(Player* player, const std::string& data, bool add)
{
	if(!player || data.empty())
		return;

	std::vector<std::pair<std::string, int32_t> > bonuses;
	parseBonuses(data, bonuses);

	bool updateSkills = false, updateStats = false;
	for(std::vector<std::pair<std::string, int32_t> >::const_iterator it = bonuses.begin(); it != bonuses.end(); ++it)
	{
		const RarityAttribute* info = getAttribute(it->first);
		if(!info)
			continue;

		int32_t value = (add ? it->second : -it->second);
		switch(info->kind)
		{
			case RATTR_BONUS:
				player->setVarBonus((Bonus_t)info->index, value);
				break;
			case RATTR_SKILL:
				player->setVarSkill((skills_t)info->index, value);
				updateSkills = true;
				break;
			case RATTR_STAT:
				player->setVarStats((stats_t)info->index, value);
				updateStats = true;
				break;
			case RATTR_SPEED:
				g_game.changeSpeed(player, value);
				break;
			default:
				break;
		}
	}

	if(updateSkills)
		player->sendSkills();

	if(updateStats)
		player->sendStats();
}
