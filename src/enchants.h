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

#ifndef __ENCHANTS__
#define __ENCHANTS__
#include "otsystem.h"
#include "position.h"

class Item;
class Player;

//Item enchantments (Diablo style). The enchantments are configured in data/XML/enchantments.xml (each one is applied by
//using its item, a rune, on the item to be enchanted) and the slots of each rarity in config.lua (enchantSlots*).
//An enchanted item has the custom attribute "enchants": the names of its enchantments separated by ";".
class Enchants
{
	public:
		virtual ~Enchants() {}
		static Enchants* getInstance()
		{
			static Enchants instance;
			return &instance;
		}

		bool load();

		bool isEnabled() const;

		//true if the item id is the item that applies some enchantment
		bool isEnchantItem(uint16_t itemId) const {return enchantItem.find(itemId) != enchantItem.end();}

		//action of the enchantment items (use it on the item to be enchanted)
		static bool onUse(Player* player, Item* enchantItem, const PositionEx& toPos, bool extendedUse);

		//amount of enchantment slots of the item (0 if it can not be enchanted)
		uint32_t getSlots(const Item* item) const;

		//applies the enchantment (by name) to the item ignoring the slots, the item type and the duplicates check
		//returns false if the enchantment does not exist
		bool enchant(Item* item, const std::string& name) const;

		//"\nenchantments: Name (bonuses), [empty slot]" or empty (end of the item description)
		std::string getDescription(const Item* item) const;

		//end of the description of the item that applies an enchantment
		std::string getItemDescription(uint16_t itemId) const;

		//"key:value,key:value" of the enchantments of the item that act on the player while it is equipped
		std::string getEquipBonuses(const Item* item) const;

		//refreshes the bonuses of the player if the item is equipped
		static void refreshEquip(Item* item);

	private:
		Enchants() {}

		struct Enchantment
		{
			std::string name, types, attributes; //attributes: "key:value,key:value"
			uint16_t itemId;
			uint8_t effect;
			bool anyType;
			std::vector<int32_t> weaponTypes;
			uint32_t slots;
		};

		const Enchantment* getEnchantment(const std::string& name) const;
		const Enchantment* getByItem(uint16_t itemId) const;
		bool accepts(const Enchantment& enchantment, const Item* item) const;
		static std::vector<std::string> getNames(const Item* item);

		std::vector<Enchantment> enchantments;
		std::map<uint16_t, size_t> enchantItem;
};

#define g_enchants Enchants::getInstance()
#endif
