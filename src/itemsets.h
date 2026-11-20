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

#ifndef __ITEMSETS__
#define __ITEMSETS__
#include "otsystem.h"

class Item;
class Player;

//Item sets, configured in data/XML/itemsets.xml. The bonuses of a set depend on how many different pieces
//of it are equipped (the bonuses of the lower piece counts stay active).
class ItemSets
{
	public:
		virtual ~ItemSets() {}
		static ItemSets* getInstance()
		{
			static ItemSets instance;
			return &instance;
		}

		bool load();

		//"key:value,key:value" with the bonuses of all the sets the player has equipped (empty if none)
		std::string getBonuses(const Player* player) const;

		//end of the item description: set name, pieces and bonuses; empty if the item is not part of a set
		std::string getDescription(const Item* item) const;

	private:
		ItemSets() {}

		struct SetBonus
		{
			uint32_t pieces;
			std::string attributes; //"key:value,key:value"
		};

		struct BonusLess
		{
			bool operator()(const SetBonus& a, const SetBonus& b) const {return a.pieces < b.pieces;}
		};

		struct Set
		{
			std::string name;
			std::vector<uint16_t> items;
			std::vector<SetBonus> bonuses;
		};

		int32_t getSetIndex(uint16_t itemId) const;
		uint32_t countEquipped(const Player* player, const Set& set) const;

		std::vector<Set> sets;
		std::map<uint16_t, int32_t> itemSet;
};

#define g_itemsets ItemSets::getInstance()
#endif
