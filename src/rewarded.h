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

#ifndef __REWARDED__
#define __REWARDED__
#include "otsystem.h"

//Rewarded creatures: monsters picked (by data/globalevents/scripts/rewardedmonsters.lua, every time the server
//starts) that give a bonus of experience or loot. The script fills this class, the bonuses are applied by the source.
enum RewardedCategory_t
{
	REWARDED_EXPERIENCE = 0,
	REWARDED_LOOT = 1,
	REWARDED_LAST = REWARDED_LOOT
};

class Rewarded
{
	public:
		static Rewarded* getInstance()
		{
			static Rewarded instance;
			return &instance;
		}

		//replaces the list of a category (names are case insensitive) and its bonus in percent
		void set(RewardedCategory_t category, int32_t bonus, const std::vector<std::string>& names);

		int32_t getBonus(RewardedCategory_t category) const {return m_bonus[category];}
		const std::set<std::string>& getNames(RewardedCategory_t category) const {return m_names[category];}

		//bonus in percent that applies to a monster (0 when it is not rewarded in the category)
		int32_t getMonsterBonus(RewardedCategory_t category, const std::string& monsterName) const;

		static bool parseCategory(const std::string& str, RewardedCategory_t& category);

	private:
		Rewarded() {m_bonus[0] = m_bonus[1] = 0;}

		int32_t m_bonus[REWARDED_LAST + 1];
		std::set<std::string> m_names[REWARDED_LAST + 1];
};

#define g_rewarded Rewarded::getInstance()
#endif
