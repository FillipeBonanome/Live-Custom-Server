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

#ifndef __AUTOLOOT__
#define __AUTOLOOT__
#include "otsystem.h"

class Player;
class Container;
class Item;

class Autoloot
{
	public:
		virtual ~Autoloot() {}
		static Autoloot* getInstance()
		{
			static Autoloot instance;
			return &instance;
		}

		//config: autoLootEnabled / autoLootMaxItems
		bool isEnabled() const;
		uint32_t getMaxItems() const;

		//handles "!autoloot <add|remove|list|clear> [id or name]"; the answer is sent to the player
		void onCommand(Player* player, const std::string& param) const;

		//moves the corpse items listed by the corpse owner to his inventory; returns the names of the looted items
		std::string onLoot(Player* player, Container* corpse) const;

	private:
		Autoloot() {}

		bool findItem(const std::string& param, uint16_t& id) const;
		std::string getList(const Player* player) const;
		std::string getFilters(const Player* player) const;

		//true if the item must be picked: listed or matching a filter, and not ignored
		bool matches(const Player* player, const Item* item) const;

		//"!autoloot rarity|unique|attribute|ignore|filters ..."
		void onFilterCommand(Player* player, const std::string& action, const std::string& value) const;
};

#define g_autoloot Autoloot::getInstance()
#endif
