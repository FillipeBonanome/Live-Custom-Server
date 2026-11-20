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
#include "itemsets.h"

#include "player.h"
#include "items.h"
#include "movement.h"
#include "rarity.h"
#include "tools.h"

extern MoveEvents* g_moveEvents;

bool ItemSets::load()
{
	sets.clear();
	itemSet.clear();

	xmlDocPtr doc = xmlParseFile(getFilePath(FILE_TYPE_XML, "itemsets.xml").c_str());
	if(!doc)
	{
		std::clog << "[Warning - ItemSets::load] Cannot load itemsets.xml." << std::endl;
		std::clog << getLastXMLError() << std::endl;
		return false;
	}

	xmlNodePtr root = xmlDocGetRootElement(doc);
	if(xmlStrcmp(root->name, (const xmlChar*)"sets"))
	{
		std::clog << "[Error - ItemSets::load] Malformed itemsets.xml." << std::endl;
		xmlFreeDoc(doc);
		return false;
	}

	std::string strValue;
	int32_t intValue;
	for(xmlNodePtr p = root->children; p; p = p->next)
	{
		if(xmlStrcmp(p->name, (const xmlChar*)"set"))
			continue;

		Set set;
		if(!readXMLString(p, "name", set.name) || set.name.empty())
		{
			std::clog << "[Warning - ItemSets::load] Set without name." << std::endl;
			continue;
		}

		for(xmlNodePtr q = p->children; q; q = q->next)
		{
			if(!xmlStrcmp(q->name, (const xmlChar*)"item"))
			{
				if(!readXMLInteger(q, "id", intValue) || intValue <= 0 || intValue > 0xFFFF)
				{
					std::clog << "[Warning - ItemSets::load] Set \"" << set.name << "\": invalid item id." << std::endl;
					continue;
				}

				if(itemSet.find((uint16_t)intValue) != itemSet.end() || std::find(set.items.begin(), set.items.end(), (uint16_t)intValue) != set.items.end())
				{
					std::clog << "[Warning - ItemSets::load] Set \"" << set.name << "\": item " << intValue << " already belongs to a set." << std::endl;
					continue;
				}

				set.items.push_back((uint16_t)intValue);
			}
			else if(!xmlStrcmp(q->name, (const xmlChar*)"bonus"))
			{
				SetBonus bonus;
				if(!readXMLInteger(q, "pieces", intValue) || intValue < 1)
				{
					std::clog << "[Warning - ItemSets::load] Set \"" << set.name << "\": bonus without valid pieces." << std::endl;
					continue;
				}

				bonus.pieces = intValue;
				for(xmlNodePtr r = q->children; r; r = r->next)
				{
					if(xmlStrcmp(r->name, (const xmlChar*)"attribute"))
						continue;

					int32_t value;
					if(!readXMLString(r, "name", strValue) || !readXMLInteger(r, "value", value) || !value)
						continue;

					strValue = asLowerCaseString(strValue);
					if(!Rarity::isEquipAttribute(strValue))
					{
						std::clog << "[Warning - ItemSets::load] Set \"" << set.name << "\": invalid attribute \"" << strValue << "\"." << std::endl;
						continue;
					}

					std::stringstream ss;
					ss << strValue << ":" << value;
					if(!bonus.attributes.empty())
						bonus.attributes += ",";

					bonus.attributes += ss.str();
				}

				if(!bonus.attributes.empty())
					set.bonuses.push_back(bonus);
			}
		}

		if(set.items.empty() || set.bonuses.empty())
		{
			std::clog << "[Warning - ItemSets::load] Set \"" << set.name << "\" needs items and bonuses." << std::endl;
			continue;
		}

		std::sort(set.bonuses.begin(), set.bonuses.end(), BonusLess());
		for(std::vector<uint16_t>::const_iterator it = set.items.begin(); it != set.items.end(); ++it)
			itemSet[*it] = (int32_t)sets.size();

		sets.push_back(set);
	}

	xmlFreeDoc(doc);
	return true;
}

int32_t ItemSets::getSetIndex(uint16_t itemId) const
{
	std::map<uint16_t, int32_t>::const_iterator it = itemSet.find(itemId);
	return it != itemSet.end() ? it->second : -1;
}

uint32_t ItemSets::countEquipped(const Player* player, const Set& set) const
{
	//different pieces only: wearing two equal items does not count twice
	std::set<uint16_t> pieces;
	for(int32_t slot = SLOT_FIRST; slot <= SLOT_AMMO; ++slot)
	{
		Item* item = player->getInventoryItem((slots_t)slot);
		if(!item || std::find(set.items.begin(), set.items.end(), item->getID()) == set.items.end())
			continue;

		//same rule of the item abilities: the requirements of the equip event must be met
		if(g_moveEvents->hasEquipEvent(item) && !player->isItemAbilityEnabled((slots_t)slot))
			continue;

		pieces.insert(item->getID());
	}

	return pieces.size();
}

std::string ItemSets::getBonuses(const Player* player) const
{
	if(sets.empty())
		return "";

	std::map<std::string, int32_t> total;
	for(std::vector<Set>::const_iterator sit = sets.begin(); sit != sets.end(); ++sit)
	{
		uint32_t equipped = countEquipped(player, *sit);
		for(std::vector<SetBonus>::const_iterator bit = sit->bonuses.begin(); bit != sit->bonuses.end(); ++bit)
		{
			if(bit->pieces > equipped)
				break;

			StringVec parts = explodeString(bit->attributes, ",");
			for(StringVec::const_iterator it = parts.begin(); it != parts.end(); ++it)
			{
				size_t pos = it->find(':');
				if(pos != std::string::npos)
					total[it->substr(0, pos)] += atoi(it->substr(pos + 1).c_str());
			}
		}
	}

	std::string ret;
	for(std::map<std::string, int32_t>::const_iterator it = total.begin(); it != total.end(); ++it)
	{
		if(!it->second)
			continue;

		std::stringstream ss;
		ss << it->first << ":" << it->second;
		if(!ret.empty())
			ret += ",";

		ret += ss.str();
	}

	return ret;
}

std::string ItemSets::getDescription(const Item* item) const
{
	if(!item || sets.empty())
		return "";

	int32_t index = getSetIndex(item->getID());
	if(index < 0)
		return "";

	const Set& set = sets[index];
	uint32_t equipped = 0;
	if(const Player* player = item->getHoldingPlayer())
		equipped = countEquipped(player, set);

	std::stringstream s;
	s << "\nset: " << set.name << " (" << equipped << "/" << set.items.size() << " pieces)";
	for(std::vector<SetBonus>::const_iterator it = set.bonuses.begin(); it != set.bonuses.end(); ++it)
		s << "\n(" << it->pieces << ") " << Rarity::formatBonuses(it->attributes);

	return s.str();
}
