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
#include "autoloot.h"

#include "player.h"
#include "container.h"
#include "item.h"
#include "items.h"
#include "game.h"
#include "tools.h"
#include "configmanager.h"
#include "rarity.h"
#include "uniques.h"

extern Game g_game;
extern ConfigManager g_config;

bool Autoloot::isEnabled() const
{
	return g_config.getBool(ConfigManager::AUTOLOOT_ENABLED);
}

uint32_t Autoloot::getMaxItems() const
{
	int32_t max = g_config.getNumber(ConfigManager::AUTOLOOT_MAX_ITEMS);
	return max > 0 ? (uint32_t)max : 0;
}

bool Autoloot::findItem(const std::string& param, uint16_t& id) const
{
	if(param.empty())
		return false;

	int32_t found = -1;
	if(isNumbers(param))
		found = atoi(param.c_str());
	else
		found = Item::items.getItemIdByName(param);

	if(found < 100 || found > 0xFFFF)
		return false;

	const ItemType* it = Item::items.getElement(found);
	if(!it || it->name.empty())
		return false;

	id = (uint16_t)found;
	return true;
}

std::string Autoloot::getList(const Player* player) const
{
	const AutolootList& list = player->getAutoloot();
	std::stringstream ss;
	ss << "Autoloot (" << list.size() << "/" << getMaxItems() << "):";
	if(list.empty())
		ss << "\nNo items.";

	for(AutolootList::const_iterator it = list.begin(); it != list.end(); ++it)
		ss << "\n- " << Item::items[*it].name << " [" << *it << "]";

	ss << "\n\n" << getFilters(player);
	return ss.str();
}

std::string Autoloot::getFilters(const Player* player) const
{
	const AutolootFilters& filters = player->getAutolootFilters();
	std::stringstream ss;
	ss << "Filters:";
	ss << "\n- rarity: ";
	if(filters.rarity.empty())
		ss << "off";
	else
		ss << filters.rarity << " or better";

	ss << "\n- unique: " << (filters.unique ? "on" : "off");
	ss << "\n- attributes: ";
	if(filters.attributes.empty())
		ss << "none";

	for(std::set<std::string>::const_iterator it = filters.attributes.begin(); it != filters.attributes.end(); ++it)
		ss << (it != filters.attributes.begin() ? ", " : "") << *it;

	ss << "\n- ignored items: ";
	if(filters.ignore.empty())
		ss << "none";

	for(AutolootList::const_iterator it = filters.ignore.begin(); it != filters.ignore.end(); ++it)
		ss << (it != filters.ignore.begin() ? ", " : "") << Item::items[*it].name << " [" << *it << "]";

	return ss.str();
}

bool Autoloot::matches(const Player* player, const Item* item) const
{
	const AutolootFilters& filters = player->getAutolootFilters();
	if(filters.ignore.find(item->getID()) != filters.ignore.end())
		return false;

	if(player->hasAutoloot(item->getID()))
		return true;

	if(!filters.rarity.empty())
	{
		int32_t rank = g_rarity->getRank(Rarity::getName(item));
		if(rank >= 0 && rank >= g_rarity->getRank(filters.rarity))
			return true;
	}

	if(filters.unique && !Uniques::getName(item).empty())
		return true;

	for(std::set<std::string>::const_iterator it = filters.attributes.begin(); it != filters.attributes.end(); ++it)
	{
		if(Rarity::hasBonus(item, *it))
			return true;
	}

	return false;
}

void Autoloot::onFilterCommand(Player* player, const std::string& action, const std::string& rawValue) const
{
	AutolootFilters& filters = player->getAutolootFilters();
	std::string value = rawValue, sub;
	size_t pos = value.find_first_of(" \t");
	if(pos != std::string::npos)
	{
		sub = asLowerCaseString(value.substr(0, pos));
		value = value.substr(pos + 1);
		trimString(value);
	}
	else
		sub = asLowerCaseString(value);

	if(action == "filters")
	{
		if(sub == "clear")
		{
			filters = AutolootFilters();
			player->sendTextMessage(MSG_INFO_DESCR, "Your autoloot filters have been cleared.");
		}
		else
			player->sendFYIBox(getFilters(player));

		return;
	}

	std::stringstream ss;
	if(action == "rarity")
	{
		if(sub == "off" || sub == "none")
		{
			filters.rarity.clear();
			ss << "Autoloot rarity filter disabled.";
		}
		else if(g_rarity->getRank(rawValue) < 0)
		{
			ss << "Unknown rarity. Available: " << g_rarity->getNames() << " (or off).";
			player->sendCancel(ss.str());
			return;
		}
		else
		{
			//keeps the name written in rarities.xml
			std::string name = rawValue;
			StringVec list = explodeString(g_rarity->getNames(), ", ");
			for(StringVec::const_iterator it = list.begin(); it != list.end(); ++it)
			{
				if(!strcasecmp(it->c_str(), rawValue.c_str()))
					name = *it;
			}

			filters.rarity = name;
			ss << "Autoloot now picks items with rarity " << name << " or better.";
		}
	}
	else if(action == "unique")
	{
		if(sub == "on")
			filters.unique = true;
		else if(sub == "off")
			filters.unique = false;
		else
		{
			player->sendCancel("Use: !autoloot unique on|off");
			return;
		}

		ss << "Autoloot of unique items " << (filters.unique ? "enabled." : "disabled.");
	}
	else if(action == "attribute" || action == "ignore")
	{
		if(sub != "add" && sub != "remove")
		{
			ss << "Use: !autoloot " << action << " add|remove <" << (action == "ignore" ? "item id or name" : "attribute") << ">";
			player->sendCancel(ss.str());
			return;
		}

		bool add = sub == "add";
		if(action == "attribute")
		{
			std::string key = asLowerCaseString(value);
			if(!Rarity::isAttribute(key))
			{
				player->sendCancel("Unknown attribute (e.g. dodge, critical, leech).");
				return;
			}

			if(add)
			{
				if(filters.attributes.size() >= 20)
				{
					player->sendCancel("You cannot have more than 20 attribute filters.");
					return;
				}

				filters.attributes.insert(key);
			}
			else if(!filters.attributes.erase(key))
			{
				player->sendCancel("This attribute is not in your filters.");
				return;
			}

			ss << "Attribute " << key << (add ? " added to" : " removed from") << " your autoloot filters.";
		}
		else
		{
			uint16_t id = 0;
			if(!findItem(value, id))
			{
				player->sendCancel("There is no item with this id or name.");
				return;
			}

			if(add)
			{
				if(filters.ignore.size() >= getMaxItems())
				{
					player->sendCancel("Your ignore list is full.");
					return;
				}

				filters.ignore.insert(id);
			}
			else if(!filters.ignore.erase(id))
			{
				player->sendCancel("This item is not in your ignore list.");
				return;
			}

			ss << Item::items[id].name << " [" << id << "]" << (add ? " added to" : " removed from") << " your autoloot ignore list.";
		}
	}

	player->sendTextMessage(MSG_INFO_DESCR, ss.str());
}

void Autoloot::onCommand(Player* player, const std::string& rawParam) const
{
	if(!isEnabled())
	{
		player->sendCancel("The autoloot system is disabled.");
		return;
	}

	std::string param = rawParam;
	trimString(param);

	std::string action = param, value;
	size_t pos = param.find_first_of(" \t");
	if(pos != std::string::npos)
	{
		action = param.substr(0, pos);
		value = param.substr(pos + 1);
		trimString(value);
	}

	action = asLowerCaseString(action);
	if(action == "rarity" || action == "unique" || action == "attribute" || action == "ignore" || action == "filters")
	{
		onFilterCommand(player, action, value);
		return;
	}

	if(action == "list")
	{
		player->sendFYIBox(getList(player));
		return;
	}

	if(action == "clear")
	{
		player->clearAutoloot();
		player->sendTextMessage(MSG_INFO_DESCR, "Your autoloot list has been cleared.");
		return;
	}

	if(action == "add" || action == "remove")
	{
		uint16_t id = 0;
		if(!findItem(value, id))
		{
			player->sendCancel("There is no item with this id or name.");
			return;
		}

		std::stringstream ss;
		if(action == "add")
		{
			if(player->hasAutoloot(id))
			{
				player->sendCancel("This item is already in your autoloot list.");
				return;
			}

			if(player->getAutoloot().size() >= getMaxItems())
			{
				ss << "Your autoloot list is full (max. " << getMaxItems() << " items).";
				player->sendCancel(ss.str());
				return;
			}

			player->addAutoloot(id);
			ss << Item::items[id].name << " [" << id << "] added to your autoloot list.";
		}
		else
		{
			if(!player->removeAutoloot(id))
			{
				player->sendCancel("This item is not in your autoloot list.");
				return;
			}

			ss << Item::items[id].name << " [" << id << "] removed from your autoloot list.";
		}

		player->sendTextMessage(MSG_INFO_DESCR, ss.str());
		return;
	}

	player->sendFYIBox("Autoloot commands:\n"
		"!autoloot add <id or name> - adds an item to the list\n"
		"!autoloot remove <id or name> - removes an item from the list\n"
		"!autoloot list - shows all items of the list\n"
		"!autoloot clear - removes all items from the list\n\n"
		"Filters (items that match any filter are picked even if they are not in the list):\n"
		"!autoloot rarity <name or off> - picks items with this rarity or better\n"
		"!autoloot unique <on or off> - picks every unique item\n"
		"!autoloot attribute <add or remove> <attribute> - picks items that rolled this attribute (e.g. dodge)\n"
		"!autoloot ignore <add or remove> <id or name> - never picks this item\n"
		"!autoloot filters - shows your filters (!autoloot filters clear resets them)\n\n"
		"Items are moved from the corpses of the monsters you kill straight to your inventory.");
}

std::string Autoloot::onLoot(Player* player, Container* corpse) const
{
	if(!isEnabled() || !player || !corpse || (player->getAutoloot().empty() && player->getAutolootFilters().empty()))
		return "";

	//collect first, moving items would invalidate the iterator
	std::vector<Item*> items;
	for(ContainerIterator it = corpse->begin(); it != corpse->end(); ++it)
	{
		if(matches(player, *it))
			items.push_back(*it);
	}

	std::stringstream ss;
	bool begin = true;
	for(std::vector<Item*>::iterator it = items.begin(); it != items.end(); ++it)
	{
		Item* item = *it;
		Cylinder* parent = item->getParent();
		if(!parent)
			continue;

		std::string description = item->getNameDescription();
		if(player->isPortuguese())
			description = toPortugueseArticle(description);

		if(g_game.internalMoveItem(NULL, parent, player, INDEX_WHEREEVER, item, item->getItemCount(), NULL) != RET_NOERROR)
			continue; //no room or capacity, the item stays in the corpse

		if(!begin)
			ss << ", ";
		else
			begin = false;

		ss << description;
	}

	return ss.str();
}
