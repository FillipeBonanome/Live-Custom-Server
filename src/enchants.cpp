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
#include "enchants.h"

#include "player.h"
#include "items.h"
#include "tools.h"
#include "rarity.h"
#include "uniques.h"
#include "game.h"
#include "configmanager.h"

extern ConfigManager g_config;
extern Game g_game;

static const char* ENCHANTS_ATTR = "enchants";

bool Enchants::isEnabled() const
{
	return g_config.getBool(ConfigManager::ENCHANT_ENABLED);
}

bool Enchants::load()
{
	enchantments.clear();
	enchantItem.clear();

	xmlDocPtr doc = xmlParseFile(getFilePath(FILE_TYPE_XML, "enchantments.xml").c_str());
	if(!doc)
	{
		std::clog << "[Warning - Enchants::load] Cannot load enchantments.xml." << std::endl;
		std::clog << getLastXMLError() << std::endl;
		return false;
	}

	xmlNodePtr root = xmlDocGetRootElement(doc);
	if(xmlStrcmp(root->name, (const xmlChar*)"enchantments"))
	{
		std::clog << "[Error - Enchants::load] Malformed enchantments.xml." << std::endl;
		xmlFreeDoc(doc);
		return false;
	}

	std::string strValue;
	int32_t intValue;
	for(xmlNodePtr p = root->children; p; p = p->next)
	{
		if(xmlStrcmp(p->name, (const xmlChar*)"enchantment"))
			continue;

		Enchantment enchantment;
		enchantment.anyType = false;
		enchantment.slots = 0;
		if(!readXMLString(p, "name", enchantment.name) || enchantment.name.empty())
		{
			std::clog << "[Warning - Enchants::load] Enchantment without name." << std::endl;
			continue;
		}

		//the names are separated by ";" inside the item
		replaceString(enchantment.name, ";", "");
		if(getEnchantment(enchantment.name))
		{
			std::clog << "[Warning - Enchants::load] Duplicated enchantment \"" << enchantment.name << "\"." << std::endl;
			continue;
		}

		if(!readXMLInteger(p, "item", intValue) || intValue <= 0)
		{
			std::clog << "[Warning - Enchants::load] Enchantment \"" << enchantment.name << "\" without item id." << std::endl;
			continue;
		}

		enchantment.itemId = intValue;
		if(isEnchantItem(enchantment.itemId))
		{
			std::clog << "[Warning - Enchants::load] Enchantment \"" << enchantment.name << "\": item " << intValue << " already applies another enchantment." << std::endl;
			continue;
		}

		enchantment.effect = MAGIC_EFFECT_WRAPS_GREEN;
		if(readXMLInteger(p, "effect", intValue))
			enchantment.effect = (uint8_t)intValue;

		if(!readXMLString(p, "types", enchantment.types) || enchantment.types.empty())
			enchantment.types = "all";

		bool valid = true;
		StringVec types = explodeString(enchantment.types, ",");
		for(StringVec::iterator it = types.begin(); valid && it != types.end(); ++it)
		{
			trimString(*it);
			strValue = asLowerCaseString(*it);
			if(strValue == "all")
				enchantment.anyType = true;
			else if(strValue == "weapon")
			{
				enchantment.weaponTypes.push_back(WEAPON_SWORD);
				enchantment.weaponTypes.push_back(WEAPON_CLUB);
				enchantment.weaponTypes.push_back(WEAPON_AXE);
				enchantment.weaponTypes.push_back(WEAPON_DIST);
				enchantment.weaponTypes.push_back(WEAPON_WAND);
				enchantment.weaponTypes.push_back(WEAPON_FIST);
			}
			else if(strValue == "sword")
				enchantment.weaponTypes.push_back(WEAPON_SWORD);
			else if(strValue == "club")
				enchantment.weaponTypes.push_back(WEAPON_CLUB);
			else if(strValue == "axe")
				enchantment.weaponTypes.push_back(WEAPON_AXE);
			else if(strValue == "distance" || strValue == "dist")
				enchantment.weaponTypes.push_back(WEAPON_DIST);
			else if(strValue == "shield")
				enchantment.weaponTypes.push_back(WEAPON_SHIELD);
			else if(strValue == "fist")
				enchantment.weaponTypes.push_back(WEAPON_FIST);
			else if(strValue == "wand" || strValue == "rod")
				enchantment.weaponTypes.push_back(WEAPON_WAND);
			else if(strValue == "head")
				enchantment.slots |= SLOTP_HEAD;
			else if(strValue == "armor" || strValue == "body")
				enchantment.slots |= SLOTP_ARMOR;
			else if(strValue == "legs")
				enchantment.slots |= SLOTP_LEGS;
			else if(strValue == "feet")
				enchantment.slots |= SLOTP_FEET;
			else if(strValue == "necklace")
				enchantment.slots |= SLOTP_NECKLACE;
			else if(strValue == "ring")
				enchantment.slots |= SLOTP_RING;
			else if(strValue == "ammo")
				enchantment.slots |= SLOTP_AMMO;
			else if(strValue == "backpack")
				enchantment.slots |= SLOTP_BACKPACK;
			else
			{
				std::clog << "[Warning - Enchants::load] Enchantment \"" << enchantment.name << "\": unknown type \"" << *it << "\"." << std::endl;
				valid = false;
			}
		}

		if(!valid)
			continue;

		std::stringstream attributes;
		for(xmlNodePtr q = p->children; q; q = q->next)
		{
			if(xmlStrcmp(q->name, (const xmlChar*)"attribute"))
				continue;

			if(!readXMLString(q, "name", strValue))
				continue;

			strValue = asLowerCaseString(strValue);
			if(!Rarity::isAttribute(strValue))
			{
				std::clog << "[Warning - Enchants::load] Enchantment \"" << enchantment.name << "\": unknown attribute \"" << strValue << "\"." << std::endl;
				continue;
			}

			if(!readXMLInteger(q, "value", intValue) || !intValue)
			{
				std::clog << "[Warning - Enchants::load] Enchantment \"" << enchantment.name << "\": attribute \"" << strValue << "\" without a valid value." << std::endl;
				continue;
			}

			if(!attributes.str().empty())
				attributes << ",";

			attributes << strValue << ":" << intValue;
		}

		enchantment.attributes = attributes.str();
		if(enchantment.attributes.empty())
		{
			std::clog << "[Warning - Enchants::load] Enchantment \"" << enchantment.name << "\" has no valid attributes." << std::endl;
			continue;
		}

		enchantItem[enchantment.itemId] = enchantments.size();
		enchantments.push_back(enchantment);
	}

	xmlFreeDoc(doc);
	return true;
}

const Enchants::Enchantment* Enchants::getEnchantment(const std::string& name) const
{
	for(std::vector<Enchantment>::const_iterator it = enchantments.begin(); it != enchantments.end(); ++it)
	{
		if(!strcasecmp(it->name.c_str(), name.c_str()))
			return &(*it);
	}

	return NULL;
}

const Enchants::Enchantment* Enchants::getByItem(uint16_t itemId) const
{
	std::map<uint16_t, size_t>::const_iterator it = enchantItem.find(itemId);
	return it != enchantItem.end() ? &enchantments[it->second] : NULL;
}

bool Enchants::accepts(const Enchantment& enchantment, const Item* item) const
{
	if(enchantment.anyType)
		return true;

	const ItemType& it = Item::items[item->getID()];
	if(it.weaponType != WEAPON_NONE && std::find(enchantment.weaponTypes.begin(), enchantment.weaponTypes.end(),
		(int32_t)it.weaponType) != enchantment.weaponTypes.end())
		return true;

	return (it.slotPosition & enchantment.slots) != 0;
}

std::vector<std::string> Enchants::getNames(const Item* item)
{
	std::vector<std::string> names;
	if(const std::string* data = item->getStringAttribute(ENCHANTS_ATTR))
	{
		StringVec parts = explodeString(*data, ";");
		for(StringVec::const_iterator it = parts.begin(); it != parts.end(); ++it)
		{
			if(!it->empty())
				names.push_back(*it);
		}
	}

	return names;
}

uint32_t Enchants::getSlots(const Item* item) const
{
	if(!item || !isEnabled() || !g_rarity->canHaveRarity(item))
		return 0;

	uint32_t slots;
	std::string rarity = asLowerCaseString(Rarity::getName(item));
	if(rarity == "uncommon")
		slots = g_config.getNumber(ConfigManager::ENCHANT_SLOTS_UNCOMMON);
	else if(rarity == "rare")
		slots = g_config.getNumber(ConfigManager::ENCHANT_SLOTS_RARE);
	else if(rarity == "epic")
		slots = g_config.getNumber(ConfigManager::ENCHANT_SLOTS_EPIC);
	else if(rarity == "legendary")
		slots = g_config.getNumber(ConfigManager::ENCHANT_SLOTS_LEGENDARY);
	else
		slots = g_config.getNumber(ConfigManager::ENCHANT_SLOTS_NONE);

	if(!Uniques::getName(item).empty())
		slots += g_config.getNumber(ConfigManager::ENCHANT_SLOTS_UNIQUE);

	return slots;
}

bool Enchants::enchant(Item* item, const std::string& name) const
{
	const Enchantment* enchantment = getEnchantment(name);
	if(!item || !enchantment)
		return false;

	std::vector<std::string> names = getNames(item);
	names.push_back(enchantment->name);

	std::stringstream s;
	for(size_t i = 0; i < names.size(); ++i)
	{
		if(i)
			s << ";";

		s << names[i];
	}

	item->setAttribute(ENCHANTS_ATTR, s.str());

	//attack, defense and armor are added to the item itself (permanently)
	StringVec parts = explodeString(enchantment->attributes, ",");
	for(StringVec::const_iterator it = parts.begin(); it != parts.end(); ++it)
	{
		size_t pos = it->find(':');
		if(pos != std::string::npos)
			Rarity::addItemAttribute(item, it->substr(0, pos), atoi(it->substr(pos + 1).c_str()));
	}

	return true;
}

void Enchants::refreshEquip(Item* item)
{
	Player* player = item->getHoldingPlayer();
	if(!player)
		return;

	for(int32_t slot = SLOT_FIRST; slot <= SLOT_AMMO; ++slot)
	{
		if(player->getInventoryItem((slots_t)slot) == item)
			player->updateRarity((slots_t)slot);
	}
}

bool Enchants::onUse(Player* player, Item* enchantItem, const PositionEx& toPos, bool extendedUse)
{
	if(!player || !enchantItem)
		return false;

	const Enchantment* enchantment = g_enchants->getByItem(enchantItem->getID());
	if(!enchantment || !g_enchants->isEnabled())
	{
		player->sendCancel("Enchantments are disabled.");
		return true;
	}

	Item* target = NULL;
	if(extendedUse)
	{
		if(Thing* thing = g_game.internalGetThing(player, toPos, toPos.stackpos))
			target = thing->getItem();
	}

	if(!target || target == enchantItem)
	{
		player->sendCancel("Use it on the item you want to enchant (" + enchantment->name + ").");
		return true;
	}

	if(target->getHoldingPlayer() != player)
	{
		player->sendCancel("The item must be in your inventory.");
		return true;
	}

	uint32_t slots = g_enchants->getSlots(target);
	if(!slots || !g_enchants->accepts(*enchantment, target))
	{
		player->sendCancel(!slots ? "This item cannot be enchanted." : "This enchantment cannot be applied to this kind of item.");
		return true;
	}

	std::vector<std::string> names = getNames(target);
	if(names.size() >= slots)
	{
		player->sendCancel("This item has no empty enchantment slot.");
		return true;
	}

	for(std::vector<std::string>::const_iterator it = names.begin(); it != names.end(); ++it)
	{
		if(!strcasecmp(it->c_str(), enchantment->name.c_str()))
		{
			player->sendCancel("This item already has this enchantment.");
			return true;
		}
	}

	g_enchants->enchant(target, enchantment->name);
	refreshEquip(target);

	g_game.addMagicEffect(player->getPosition(), enchantment->effect);
	player->sendTextMessage(MSG_INFO_DESCR, "You enchanted your " + target->getName() + " with " + enchantment->name + ".");

	//the enchantment item is consumed
	g_game.transformItem(enchantItem, enchantItem->getID(), std::max((int32_t)0, (int32_t)enchantItem->getItemCount() - 1));
	return true;
}

std::string Enchants::getDescription(const Item* item) const
{
	uint32_t slots = getSlots(item);
	std::vector<std::string> names = getNames(item);
	if(!slots && names.empty())
		return "";

	std::stringstream s;
	s << "\nenchantments: ";
	for(size_t i = 0; i < std::max((size_t)slots, names.size()); ++i)
	{
		if(i)
			s << ", ";

		if(i >= names.size())
		{
			s << "[empty slot]";
			continue;
		}

		s << names[i];
		if(const Enchantment* enchantment = getEnchantment(names[i]))
			s << " (" << Rarity::formatBonuses(enchantment->attributes) << ")";
	}

	return s.str();
}

std::string Enchants::getItemDescription(uint16_t itemId) const
{
	const Enchantment* enchantment = getByItem(itemId);
	if(!enchantment)
		return "";

	std::stringstream s;
	s << "\nenchantment: " << enchantment->name << " (" << Rarity::formatBonuses(enchantment->attributes) << ")";
	s << "\nuse it on an item with a free enchantment slot to enchant it";
	if(!enchantment->anyType)
		s << " (" << enchantment->types << ")";

	return s.str();
}

std::string Enchants::getEquipBonuses(const Item* item) const
{
	std::stringstream s;
	bool begin = true;
	std::vector<std::string> names = getNames(item);
	for(std::vector<std::string>::const_iterator it = names.begin(); it != names.end(); ++it)
	{
		const Enchantment* enchantment = getEnchantment(*it);
		if(!enchantment)
			continue;

		StringVec parts = explodeString(enchantment->attributes, ",");
		for(StringVec::const_iterator pit = parts.begin(); pit != parts.end(); ++pit)
		{
			size_t pos = pit->find(':');
			if(pos == std::string::npos || !Rarity::isEquipAttribute(pit->substr(0, pos)))
				continue;

			if(!begin)
				s << ",";

			begin = false;
			s << *pit;
		}
	}

	return s.str();
}
