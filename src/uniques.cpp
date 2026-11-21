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
#include "uniques.h"

#include "player.h"
#include "container.h"
#include "items.h"
#include "rarity.h"
#include "game.h"
#include "tools.h"

extern Game g_game;

static const char* UNIQUE_ATTR = "unique";
static const char* UNIQUE_BONUS_ATTR = "uniquebonus";

//item attributes an unique may replace (xml attribute = custom item attribute)
static const char* intAttributes[] = {"attack", "extraattack", "defense", "extradefense", "armor", "attackspeed", "hitchance", "shootrange"};
static const size_t intAttributeCount = sizeof(intAttributes) / sizeof(intAttributes[0]);

bool Uniques::load()
{
	uniques.clear();

	xmlDocPtr doc = xmlParseFile(getFilePath(FILE_TYPE_XML, "uniques.xml").c_str());
	if(!doc)
	{
		std::clog << "[Warning - Uniques::load] Cannot load uniques.xml." << std::endl;
		std::clog << getLastXMLError() << std::endl;
		return false;
	}

	xmlNodePtr root = xmlDocGetRootElement(doc);
	if(xmlStrcmp(root->name, (const xmlChar*)"uniques"))
	{
		std::clog << "[Error - Uniques::load] Malformed uniques.xml." << std::endl;
		xmlFreeDoc(doc);
		return false;
	}

	std::string strValue;
	int32_t intValue;
	for(xmlNodePtr p = root->children; p; p = p->next)
	{
		if(xmlStrcmp(p->name, (const xmlChar*)"unique"))
			continue;

		UniqueType unique;
		if(!readXMLString(p, "name", unique.name) || unique.name.empty())
		{
			std::clog << "[Warning - Uniques::load] Unique without name." << std::endl;
			continue;
		}

		if(getUnique(unique.name))
		{
			std::clog << "[Warning - Uniques::load] Duplicated unique \"" << unique.name << "\"." << std::endl;
			continue;
		}

		if(!readXMLInteger(p, "id", intValue) || intValue <= 0 || intValue > 0xFFFF || Item::items[intValue].name.empty())
		{
			std::clog << "[Warning - Uniques::load] Unique \"" << unique.name << "\" without a valid item id." << std::endl;
			continue;
		}

		unique.itemId = intValue;
		if(Item::items[unique.itemId].stackable || Item::items[unique.itemId].isContainer())
		{
			std::clog << "[Warning - Uniques::load] Unique \"" << unique.name << "\": stackable items and containers can not be unique." << std::endl;
			continue;
		}

		readXMLString(p, "article", unique.article);
		readXMLString(p, "description", unique.description);

		unique.chance = 0.;
		if(readXMLString(p, "chance", strValue))
			unique.chance = std::max(0., atof(strValue.c_str()));

		if(readXMLString(p, "monsters", strValue))
		{
			StringVec parts = explodeString(asLowerCaseString(strValue), ",");
			for(StringVec::iterator it = parts.begin(); it != parts.end(); ++it)
			{
				trimString(*it);
				if(!it->empty())
					unique.monsters.push_back(*it);
			}
		}

		for(size_t i = 0; i < intAttributeCount; ++i)
		{
			if(readXMLInteger(p, intAttributes[i], intValue))
			{
				IntAttribute attribute;
				attribute.key = intAttributes[i];
				attribute.value = intValue;
				unique.attributes.push_back(attribute);
			}
		}

		for(xmlNodePtr q = p->children; q; q = q->next)
		{
			if(xmlStrcmp(q->name, (const xmlChar*)"attribute"))
				continue;

			int32_t value;
			if(!readXMLString(q, "name", strValue) || !readXMLInteger(q, "value", value) || !value)
				continue;

			strValue = asLowerCaseString(strValue);
			if(!Rarity::isEquipAttribute(strValue))
			{
				std::clog << "[Warning - Uniques::load] Unique \"" << unique.name << "\": invalid attribute \"" << strValue << "\"." << std::endl;
				continue;
			}

			std::stringstream ss;
			ss << strValue << ":" << value;
			if(!unique.bonuses.empty())
				unique.bonuses += ",";

			unique.bonuses += ss.str();
		}

		uniques.push_back(unique);
	}

	xmlFreeDoc(doc);
	return true;
}

const Uniques::UniqueType* Uniques::getUnique(const std::string& name) const
{
	for(std::vector<UniqueType>::const_iterator it = uniques.begin(); it != uniques.end(); ++it)
	{
		if(!strcasecmp(it->name.c_str(), name.c_str()))
			return &(*it);
	}

	return NULL;
}

uint16_t Uniques::getItemId(const std::string& name) const
{
	const UniqueType* unique = getUnique(name);
	return unique ? unique->itemId : 0;
}

std::string Uniques::getName(const Item* item)
{
	if(!item)
		return "";

	const std::string* name = item->getStringAttribute(UNIQUE_ATTR);
	return name ? *name : "";
}

void Uniques::clearUnique(Item* item)
{
	if(getName(item).empty())
		return;

	item->eraseAttribute(UNIQUE_ATTR);
	item->eraseAttribute(UNIQUE_BONUS_ATTR);
	item->eraseAttribute("name");
	item->eraseAttribute("article");
	item->eraseAttribute("description");
	for(size_t i = 0; i < intAttributeCount; ++i)
		item->eraseAttribute(intAttributes[i]);
}

bool Uniques::setUnique(Item* item, const std::string& name) const
{
	if(!item)
		return false;

	std::string lower = name;
	trimString(lower);
	lower = asLowerCaseString(lower);

	const UniqueType* unique = NULL;
	if(!lower.empty() && lower != "none")
	{
		unique = getUnique(lower);
		if(!unique || unique->itemId != item->getID())
			return false;
	}

	//the rarity changes attack/defense/armor, so it is removed first and rolled again after the unique is applied
	std::string rarity = Rarity::getName(item);
	if(!rarity.empty())
		g_rarity->setRarity(item, "none");

	clearUnique(item);
	if(unique)
	{
		item->setAttribute(UNIQUE_ATTR, unique->name);
		item->setAttribute("name", unique->name);
		if(!unique->article.empty())
			item->setAttribute("article", unique->article);

		if(!unique->description.empty())
			item->setAttribute("description", unique->description);

		for(std::vector<IntAttribute>::const_iterator it = unique->attributes.begin(); it != unique->attributes.end(); ++it)
			item->setAttribute(it->key, it->value);

		if(!unique->bonuses.empty())
			item->setAttribute(UNIQUE_BONUS_ATTR, unique->bonuses);
	}

	if(!rarity.empty())
		g_rarity->setRarity(item, rarity);

	return true;
}

void Uniques::onLoot(Container* corpse, Player* killer, const std::string& monsterName) const
{
	if(!corpse || uniques.empty())
		return;

	std::string monster = asLowerCaseString(monsterName);
	std::vector<Item*> dropped;
	for(ContainerIterator it = corpse->begin(), end = corpse->end(); it != end; ++it)
	{
		Item* item = *it;
		if(!item || !getName(item).empty())
			continue;

		for(std::vector<UniqueType>::const_iterator uit = uniques.begin(); uit != uniques.end(); ++uit)
		{
			if(uit->itemId != item->getID() || uit->chance <= 0.)
				continue;

			if(!uit->monsters.empty() && std::find(uit->monsters.begin(), uit->monsters.end(), monster) == uit->monsters.end())
				continue;

			if((double)random_range(0, 1000000) / 10000. < uit->chance && setUnique(item, uit->name))
			{
				dropped.push_back(item);
				break;
			}
		}
	}

	if(dropped.empty())
		return;

	const Position& pos = corpse->getPosition();
	g_game.addAnimatedText(pos, COLOR_ORANGE, "Unique!");
	g_game.addMagicEffect(pos, MAGIC_EFFECT_FIREWORK_YELLOW);
	if(!killer)
		return;

	for(std::vector<Item*>::const_iterator it = dropped.begin(); it != dropped.end(); ++it)
		killer->sendTextMessage(MSG_STATUS_CONSOLE_ORANGE, "Your kill dropped an unique item: " + (*it)->getName() + ".");
}

std::string Uniques::getDescription(const Item* item) const
{
	if(getName(item).empty())
		return "";

	std::string result = "\nunique item";
	if(const std::string* data = item->getStringAttribute(UNIQUE_BONUS_ATTR))
	{
		std::string bonuses = Rarity::formatBonuses(*data);
		if(!bonuses.empty())
			result += "\nunique bonus: " + bonuses;
	}

	return result;
}

std::string Uniques::getEquipBonuses(const Item* item)
{
	if(!item)
		return "";

	const std::string* data = item->getStringAttribute(UNIQUE_BONUS_ATTR);
	return data ? *data : "";
}
