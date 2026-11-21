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

#ifndef __UNIQUES__
#define __UNIQUES__
#include "otsystem.h"

class Item;
class Player;
class Container;

//Unique items, configured in data/XML/uniques.xml: an item with the same id of another one but with its own name,
//attributes, description and bonuses. The definition is copied to the item (custom attributes "unique" and "uniquebonus"
//plus name, attack, defense...), so changing the xml later does not change the unique items that already exist.
class Uniques
{
	public:
		virtual ~Uniques() {}
		static Uniques* getInstance()
		{
			static Uniques instance;
			return &instance;
		}

		bool load();

		//unique name of the item, empty if it is not an unique
		static std::string getName(const Item* item);

		//item id of the unique with that name, 0 if there is none
		uint16_t getItemId(const std::string& name) const;

		//turns the item into the unique; an empty name (or "none") restores the original item
		//returns false (and changes nothing) if the unique does not exist or it is for another item id
		bool setUnique(Item* item, const std::string& name) const;

		//rolls the drop chance of the uniques of the items inside the corpse of the monster
		void onLoot(Container* corpse, Player* killer, const std::string& monsterName) const;

		//"\nunique bonus: ..." (end of the item description), empty if the item is not an unique
		std::string getDescription(const Item* item) const;

		//rolled bonuses that act on the player while the item is equipped ("key:value,key:value")
		static std::string getEquipBonuses(const Item* item);

	private:
		Uniques() {}

		struct IntAttribute
		{
			std::string key;
			int32_t value;
		};

		struct UniqueType
		{
			std::string name, article, description, bonuses;
			uint16_t itemId;
			double chance;
			std::vector<std::string> monsters; //lower case, empty = any
			std::vector<IntAttribute> attributes;
		};

		const UniqueType* getUnique(const std::string& name) const;
		static void clearUnique(Item* item);

		std::vector<UniqueType> uniques;
};

#define g_uniques Uniques::getInstance()
#endif
