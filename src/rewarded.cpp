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
#include "rewarded.h"
#include "tools.h"

void Rewarded::set(RewardedCategory_t category, int32_t bonus, const std::vector<std::string>& names)
{
	m_bonus[category] = std::max<int32_t>(0, bonus);
	m_names[category].clear();
	for(std::vector<std::string>::const_iterator it = names.begin(); it != names.end(); ++it)
		m_names[category].insert(asLowerCaseString(*it));
}

int32_t Rewarded::getMonsterBonus(RewardedCategory_t category, const std::string& monsterName) const
{
	if(m_names[category].empty() || m_names[category].find(asLowerCaseString(monsterName)) == m_names[category].end())
		return 0;

	return m_bonus[category];
}

bool Rewarded::parseCategory(const std::string& str, RewardedCategory_t& category)
{
	std::string tmp = asLowerCaseString(str);
	if(tmp == "experience")
		category = REWARDED_EXPERIENCE;
	else if(tmp == "loot")
		category = REWARDED_LOOT;
	else
		return false;

	return true;
}
