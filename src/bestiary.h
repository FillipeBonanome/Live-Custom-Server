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

#ifndef __BESTIARY__
#define __BESTIARY__
#include "otsystem.h"

class MonsterType;
class Player;

class Bestiary
{
	public:
		virtual ~Bestiary() {}
		static Bestiary* getInstance()
		{
			static Bestiary instance;
			return &instance;
		}

		//(re)builds the id registry from the loaded monsters and reads the config values
		bool load();

		//parses "10, 100, 500" (',' or ';' separated) into a sorted list without duplicates or invalid values
		static void parseKillsList(const std::string& str, std::vector<uint32_t>& out);

		//parses "1, 2, 2, 5" (',' or ';' separated) keeping the order and the repeated values (points of each level)
		static void parsePointsList(const std::string& str, std::vector<uint32_t>& out);

		uint32_t getLastId() const {return lastId;}
		MonsterType* getMonsterType(uint32_t id) const;

		const std::vector<uint32_t>& getKillsPerLevel(const MonsterType* mType) const;
		uint32_t getMaxLevel(const MonsterType* mType) const {return getKillsPerLevel(mType).size();}
		uint32_t getLevel(const MonsterType* mType, uint32_t kills) const;
		//points (spent on spell glyphs) given by one knowledge level (1 = first) of a monster
		uint32_t getLevelPoints(const MonsterType* mType, uint32_t level) const;
		//points given by all the levels from 1 up to the given one
		uint32_t getPointsUpToLevel(const MonsterType* mType, uint32_t level) const;
		//points the player has earned so far / the sum of every level of every monster
		uint32_t getPoints(const Player* player) const;
		uint32_t getTotalPoints() const;

		double getExperienceMultiplier(const Player* player, const MonsterType* mType) const;

		//called once for every player that took part in the death of a monster
		void onKill(Player* player, const MonsterType* mType) const;

		std::string getDescription(const Player* player, const MonsterType* mType) const;
		std::string getHelp() const;

	private:
		Bestiary(): lastId(0) {}

		std::string getProgress(const MonsterType* mType, uint32_t kills) const;

		typedef std::map<uint32_t, MonsterType*> BestiaryMap;
		BestiaryMap monsters;

		std::vector<uint32_t> defaultKillsPerLevel, defaultPointsPerLevel;
		std::vector<std::pair<uint64_t, double> > pointsByExperience; //(minimum experience, multiplier), ascending
		uint32_t lastId;
};

#define g_bestiary Bestiary::getInstance()
#endif
