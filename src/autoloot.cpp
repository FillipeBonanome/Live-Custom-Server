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

	return ss.str();
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
		"Items of the list are moved from the corpses of the monsters you kill straight to your inventory.");
}

std::string Autoloot::onLoot(Player* player, Container* corpse) const
{
	if(!isEnabled() || !player || !corpse || player->getAutoloot().empty())
		return "";

	//collect first, moving items would invalidate the iterator
	std::vector<Item*> items;
	for(ContainerIterator it = corpse->begin(); it != corpse->end(); ++it)
	{
		if(player->hasAutoloot((*it)->getID()))
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
