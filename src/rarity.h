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

#ifndef __RARITY__
#define __RARITY__
#include "otsystem.h"
#include "const.h"

struct RarityAttribute;
class Item;
class Player;
class Container;

//Item rarity (Diablo style). Everything is configured in data/XML/rarities.xml, rarity_archetypes.xml and
//rarity_attributes.xml (plus the drop chances in config.lua).
//An item with rarity has two custom attributes: "rarity" (name) and "raritybonus" ("key:value,key:value" of the rolled attributes).
class Rarity
{
	public:
		virtual ~Rarity() {}
		static Rarity* getInstance()
		{
			static Rarity instance;
			return &instance;
		}

		//(re)loads the three xml files and the drop chances from the config
		bool load();

		bool isEnabled() const;

		//name of the rarity of the item, empty if it has none
		static std::string getName(const Item* item);

		//position of the rarity in the ascending order of multipliers (0 = weakest), -1 if it does not exist
		int32_t getRank(const std::string& name) const;

		//names of all rarities, weakest first ("Uncommon, Rare, ...")
		std::string getNames() const;

		//true if the item has the rarity attribute (see rarity_attributes.xml) between its rolled bonuses
		static bool hasBonus(const Item* item, const std::string& key);

		//true if the item belongs to some archetype (so it is able to have a rarity)
		bool canHaveRarity(const Item* item) const;

		//gives (rolling the attributes again) the rarity to the item; an empty name (or "none") removes it
		//returns false (and changes nothing) if the rarity does not exist or the item has no archetype
		bool setRarity(Item* item, const std::string& name) const;

		//rolls the drop chance of every eligible item inside the corpse and announces the ones that got a rarity
		void onLoot(Container* corpse, Player* killer) const;

		//"\nrarity bonus: ...\nrarity: Name" or empty (end of the item description)
		std::string getDescription(const Item* item) const;

		//rolled attributes that act on the player while the item is equipped (the "raritybonus" without attack/defense/armor)
		static std::string getEquipBonuses(const Item* item);

		//true if the key is an attribute that acts on the player while equipped (everything but attack/defense/armor)
		static bool isEquipAttribute(const std::string& key);

		//true if the key is a known attribute (see rarity_attributes.xml)
		static bool isAttribute(const std::string& key) {return getAttribute(key) != NULL;}

		//adds the value to attack/defense/armor of the item (the attributes that are part of the item itself)
		//returns false (and changes nothing) for the other attributes
		static bool addItemAttribute(Item* item, const std::string& key, int32_t value);

		//"dodge +5, critical chance +2" of a "key:value,key:value" string
		static std::string formatBonuses(const std::string& data);

		//adds (or removes) the attributes of an getEquipBonuses() string to the player
		static void applyEquipBonuses(Player* player, const std::string& bonuses, bool add);

	private:
		Rarity() {}

		struct RarityType
		{
			std::string name;
			double multiplier, chance;
			uint32_t attributes;
			uint8_t effect, color;
		};

		struct RarityChanceLess
		{
			bool operator()(const RarityType* a, const RarityType* b) const {return a->chance < b->chance;}
		};

		struct ArchetypeAttribute
		{
			const RarityAttribute* info;
			int32_t base;
		};

		struct Archetype
		{
			std::string name;
			int32_t weaponType; //-1 = any
			uint32_t slots; //0 = any
			std::vector<ArchetypeAttribute> attributes;
		};

		bool loadAttributes(std::map<std::string, int32_t>& bases);
		bool loadArchetypes(const std::map<std::string, int32_t>& bases);
		bool loadRarities();

		const RarityType* getRarity(const std::string& name) const;
		const Archetype* getArchetype(const Item* item) const;
		const RarityType* rollLootRarity() const;

		static void clearRarity(Item* item);
		static const RarityAttribute* getAttribute(const std::string& key);
		static void parseBonuses(const std::string& data, std::vector<std::pair<std::string, int32_t> >& out);

		std::vector<RarityType> rarities;
		std::vector<Archetype> archetypes;
		std::vector<const RarityType*> lootOrder;
};

#define g_rarity Rarity::getInstance()
#endif
