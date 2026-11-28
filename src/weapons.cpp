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
#include "weapons.h"

#include <libxml/xmlmemory.h>
#include <libxml/parser.h>

#include "game.h"
#include "configmanager.h"
#include "tools.h"

extern Game g_game;
extern ConfigManager g_config;
extern Weapons* g_weapons;

static void applyOnHitElemental(Player* player, Creature* target, int32_t dealt, uint32_t origin)
{
	if(dealt <= 0)
		return;

	static const CombatType_t types[] = {COMBAT_PHYSICALDAMAGE, COMBAT_ENERGYDAMAGE, COMBAT_EARTHDAMAGE,
		COMBAT_FIREDAMAGE, COMBAT_ICEDAMAGE, COMBAT_HOLYDAMAGE, COMBAT_DEATHDAMAGE, COMBAT_DROWNDAMAGE};
	for(int32_t i = ELEMAMP_FIRST; i <= ELEMAMP_LAST; ++i)
	{
		int32_t percent = player->getVarBonus((Bonus_t)(BONUS_ONHIT_PHYSICAL + i));
		if(percent <= 0)
			continue;

		if(target->isRemoved() || target->getHealth() <= 0)
			return;

		CombatParams element;
		element.combatType = types[i];
		element.origin = origin;
		int32_t extra = -(int32_t)std::ceil((double)dealt * percent / 100.);
		Combat::doCombatHealth(player, target, extra, extra, element);
	}
}

//Archer enchantments (data/lib/376-archer.lua keeps the active one in the storage ARCHER_ENCHANT_STORAGE: 1 fire, 2 poison, 3 ice, 4 energy)
//give small amounts of the effects of the elemental arrows to the basic attacks made with a bow, without needing the arrow:
//fire = area, poison = poison condition, ice = paralyze, energy = chain lightning.
static const uint32_t ARCHER_ENCHANT_STORAGE = 54300;
static const int32_t ENCHANT_FIRE = 1, ENCHANT_POISON = 2, ENCHANT_ICE = 3, ENCHANT_ENERGY = 4;

static const int32_t ENCHANT_AREA_SIZE = 2, ENCHANT_AREA_CHANCE = 25, ENCHANT_AREA_DAMAGE = 50; //plus shape, chance%, damage% of the attack
static const int32_t ENCHANT_POISON_DAMAGE = 10, ENCHANT_POISON_CHANCE = 20, ENCHANT_POISON_TIMES = 4; //damage% of the hit per tick
static const int32_t ENCHANT_PARALYZE_AMOUNT = 20, ENCHANT_PARALYZE_CHANCE = 15, ENCHANT_PARALYZE_DURATION = 2000;
static const int32_t ENCHANT_CHAIN_DAMAGE = 30, ENCHANT_CHAIN_CHANCE = 15, ENCHANT_CHAIN_BOUNCES = 2;

//active enchantment of an archer shooting with a bow (0 when none)
static int32_t getEnchant(Player* player, Item* item)
{
	if(item->getWeaponType() != WEAPON_AMMO && item->getWeaponType() != WEAPON_DIST)
		return 0;

	std::string value;
	if(!player->getStorage(ARCHER_ENCHANT_STORAGE, value))
		return 0;

	return std::max(0, std::min(4, atoi(value.c_str())));
}

//"area" attribute of the items (items.xml): the basic attack also hits the creatures around the target.
//1 = only the target, even sizes are a diamond (2 = plus, 4 = radius 2...), odd sizes (>= 3) a square (3 = 3x3, 5 = 5x5...).
static CombatArea* getSplashArea(int32_t size)
{
	static std::map<int32_t, CombatArea*> areas;
	std::map<int32_t, CombatArea*>::iterator it = areas.find(size);
	if(it != areas.end())
		return it->second;

	bool diamond = (size % 2) == 0;
	int32_t radius = diamond ? size / 2 : (size - 1) / 2, side = radius * 2 + 1;

	std::list<uint32_t> matrix;
	for(int32_t y = -radius; y <= radius; ++y)
	{
		for(int32_t x = -radius; x <= radius; ++x)
		{
			if(!x && !y)
				matrix.push_back(3);
			else if(!diamond || std::abs(x) + std::abs(y) <= radius)
				matrix.push_back(1);
			else
				matrix.push_back(0);
		}
	}

	CombatArea* area = new CombatArea();
	area->setupArea(matrix, side);
	areas[size] = area;
	return area;
}

//size of the area of the attack: 1 (only the target) + the area of the equipped items and of the item that was used
static int32_t getSplashSize(Player* player, Item* item)
{
	return player->getArea(item);
}

//damages the creatures around the center (except the caster and the skipped one, that already took the main hit)
//and shows on every tile of the area one of the effects (effectType) of the equipped items
static void doSplash(Player* player, Item* item, const Position& center, Creature* skip, int32_t damage, const CombatParams& params)
{
	int32_t size = getSplashSize(player, item);
	//the enchantment adds to the area of the items; alone it makes a weaker plus
	if(getEnchant(player, item) == ENCHANT_FIRE && random_range(1, 100) <= ENCHANT_AREA_CHANCE)
	{
		if(size <= 1)
		{
			size = ENCHANT_AREA_SIZE;
			damage = (damage * ENCHANT_AREA_DAMAGE) / 100;
		}
		else
			size = std::min((int32_t)10, size + 1);
	}

	if(size <= 1)
		return;

	std::list<Tile*> tiles;
	Combat::getCombatArea(player->getPosition(), center, getSplashArea(size), tiles);

	CombatParams splash = params;
	splash.effects.distance = SHOOT_EFFECT_NONE;

	std::vector<MagicEffect_t> effects = player->getEffectTypes(item);

	std::vector<uint32_t> ids;
	for(std::list<Tile*>::iterator it = tiles.begin(); it != tiles.end(); ++it)
	{
		Tile* tile = *it;
		if(!tile || Combat::canDoCombat(player, tile, params.isAggressive) != RET_NOERROR)
			continue;

		//one effect (drawn at random) on each tile hit by the attack
		if(!effects.empty())
			g_game.addMagicEffect(tile->getPosition(), effects[random_range(0, effects.size() - 1)]);

		if(CreatureVector* creatures = tile->getCreatures())
		{
			for(CreatureVector::iterator cit = creatures->begin(); cit != creatures->end(); ++cit)
			{
				if(*cit != player && *cit != skip)
					ids.push_back((*cit)->getID());
			}
		}
	}

	//ids are used (not pointers): the damage can kill and remove creatures
	for(std::vector<uint32_t>::iterator it = ids.begin(); it != ids.end(); ++it)
	{
		Creature* target = g_game.getCreatureByID(*it);
		if(target && !target->isRemoved() && target->getHealth() > 0)
		{
			player->setLastDamageDealt(0);
			Combat::doCombatHealth(player, target, damage, damage, splash);
			applyOnHitElemental(player, target, player->getLastDamageDealt(), splash.origin);
		}
	}
}

//chainLightning attribute (items.xml): after a hit of the basic attack there is a chance of bouncing to the nearest creatures
//(up to the bounces of the attribute), each bounce doing a percent of the damage of the basic attack. The distance effect
//leaves from the position of the last creature hit (not from the player).
static const ItemType* getChainItem(Player* player, Item* item)
{
	const ItemType* it = &Item::items[item->getID()];
	if(it->chainBounces > 0 && it->chainChance > 0)
		return it;

	if(item->getWeaponType() == WEAPON_AMMO)
	{
		if(Item* bow = player->getWeapon(true))
		{
			it = &Item::items[bow->getID()];
			if(it->chainBounces > 0 && it->chainChance > 0)
				return it;
		}
	}

	return NULL;
}

static const int32_t CHAIN_RANGE = 4;

static const int32_t CHAIN_DELAY = 150;

//one jump of the chain: finds the nearest valid creature around the last one hit, hits it and schedules the next jump
static void doChainJump(uint32_t playerId, Position last, std::set<uint32_t> hit, int32_t bounceDamage, int32_t bouncesLeft, CombatParams params)
{
	Player* player = g_game.getPlayerByID(playerId);
	if(!player || player->isRemoved() || bouncesLeft <= 0)
		return;

	SpectatorVec list;
	g_game.getSpectators(list, last, false, false, CHAIN_RANGE, CHAIN_RANGE, CHAIN_RANGE, CHAIN_RANGE);

	Creature* best = NULL;
	int32_t bestDistance = 0;
	for(SpectatorVec::iterator it = list.begin(); it != list.end(); ++it)
	{
		Creature* creature = *it;
		if(creature == player || creature->isRemoved() || creature->getHealth() <= 0 || hit.find(creature->getID()) != hit.end()
			|| creature->getPosition().z != last.z || (creature->getTile() && creature->getTile()->hasFlag(TILESTATE_PROTECTIONZONE))
			|| Combat::canDoCombat(player, creature) != RET_NOERROR || !g_game.isSightClear(last, creature->getPosition(), true))
			continue;

		const Position& pos = creature->getPosition();
		int32_t distance = std::max(std::abs((int32_t)pos.x - (int32_t)last.x), std::abs((int32_t)pos.y - (int32_t)last.y));
		if(distance > CHAIN_RANGE)
			continue;

		if(!best || distance < bestDistance)
		{
			best = creature;
			bestDistance = distance;
		}
	}

	if(!best)
		return;

	hit.insert(best->getID());
	Position target = best->getPosition();
	Combat::addDistanceEffect(player, last, target, params.effects.distance);

	CombatParams bounce = params;
	bounce.effects.distance = SHOOT_EFFECT_NONE;

	player->setLastDamageDealt(0);
	Combat::doCombatHealth(player, best, bounceDamage, bounceDamage, bounce);
	applyOnHitElemental(player, best, player->getLastDamageDealt(), bounce.origin);

	if(bouncesLeft > 1)
		Scheduler::getInstance().addEvent(createSchedulerTask(CHAIN_DELAY,
			boost::bind(&doChainJump, playerId, target, hit, bounceDamage, bouncesLeft - 1, params)));
}

static void doChainLightning(Player* player, Item* item, Creature* first, int32_t damage, const CombatParams& params)
{
	const ItemType* chain = getChainItem(player, item);
	int32_t chance = 0, percent = 0, bounces = 0;
	if(chain)
	{
		chance = chain->chainChance;
		percent = chain->chainDamage;
		bounces = chain->chainBounces;
	}

	//the enchantment adds to the chain of the items
	if(getEnchant(player, item) == ENCHANT_ENERGY)
	{
		chance = std::min(100, chance + ENCHANT_CHAIN_CHANCE);
		percent += ENCHANT_CHAIN_DAMAGE;
		bounces += ENCHANT_CHAIN_BOUNCES;
	}

	if(bounces <= 0 || damage >= 0 || random_range(1, 100) > chance)
		return;

	int32_t bounceDamage = (damage * percent) / 100;
	if(bounceDamage >= 0)
		return;

	std::set<uint32_t> hit;
	hit.insert(first->getID());
	Scheduler::getInstance().addEvent(createSchedulerTask(CHAIN_DELAY,
		boost::bind(&doChainJump, player->getID(), first->getPosition(), hit, bounceDamage, bounces, params)));
}

//paralyze attribute (items.xml): after a hit of the basic attack there is a chance of slowing the target
static void doParalyze(Player* player, Item* item, Creature* target)
{
	const ItemType* par = &Item::items[item->getID()];
	if(par->paralyzeAmount <= 0 || par->paralyzeChance <= 0 || par->paralyzeDuration <= 0)
	{
		par = NULL;
		if(item->getWeaponType() == WEAPON_AMMO)
		{
			if(Item* bow = player->getWeapon(true))
			{
				par = &Item::items[bow->getID()];
				if(par->paralyzeAmount <= 0 || par->paralyzeChance <= 0 || par->paralyzeDuration <= 0)
					par = NULL;
			}
		}
	}

	int32_t amountPercent = 0, chance = 0, duration = 0;
	if(par)
	{
		amountPercent = par->paralyzeAmount;
		chance = par->paralyzeChance;
		duration = par->paralyzeDuration;
	}

	//the enchantment adds to the paralyze of the items
	if(getEnchant(player, item) == ENCHANT_ICE)
	{
		amountPercent = std::min(100, amountPercent + ENCHANT_PARALYZE_AMOUNT);
		chance = std::min(100, chance + ENCHANT_PARALYZE_CHANCE);
		duration += ENCHANT_PARALYZE_DURATION;
	}

	if(duration <= 0 || target->isRemoved() || target->getHealth() <= 0 || random_range(1, 100) > chance)
		return;

	ConditionSpeed* condition = dynamic_cast<ConditionSpeed*>(Condition::createCondition(
		CONDITIONID_COMBAT, CONDITION_PARALYZE, duration));
	if(!condition)
		return;

	float amount = amountPercent / 100.f;
	condition->setFormulaVars(-amount, 0, -amount, 0);
	if(!target->addCombatCondition(condition))
		delete condition;
}

//damage over time attributes (items.xml: bleed, poison, burn, freeze, shock, curse, dazzle): after a hit of the basic attack there is a chance
//of leaving a condition that hits "times" times, each hit doing damage% of the damage dealt by the attack
static const int32_t DOT_INTERVAL = 1000;

static ConditionType_t getDotCondition(int32_t dot)
{
	switch(dot)
	{
		case DOT_BLEED: return CONDITION_PHYSICAL;
		case DOT_POISON: return CONDITION_POISON;
		case DOT_BURN: return CONDITION_FIRE;
		case DOT_FREEZE: return CONDITION_FREEZING;
		case DOT_SHOCK: return CONDITION_ENERGY;
		case DOT_CURSE: return CONDITION_CURSED;
		case DOT_DAZZLE: return CONDITION_DAZZLED;
		default: break;
	}

	return CONDITION_NONE;
}

//root attribute (items.xml): after a hit of the basic attack there is a chance of stopping the target from walking
static void doRoot(Player* player, Item* item, Creature* target)
{
	const ItemType* root = &Item::items[item->getID()];
	if(root->rootChance <= 0 || root->rootDuration <= 0)
	{
		root = NULL;
		if(item->getWeaponType() == WEAPON_AMMO)
		{
			if(Item* bow = player->getWeapon(true))
			{
				root = &Item::items[bow->getID()];
				if(root->rootChance <= 0 || root->rootDuration <= 0)
					root = NULL;
			}
		}
	}

	if(!root || target->isRemoved() || target->getHealth() <= 0 || random_range(1, 100) > root->rootChance)
		return;

	Condition* condition = Condition::createCondition(CONDITIONID_COMBAT, CONDITION_ROOT, root->rootDuration);
	if(!condition)
		return;

	if(!target->addCombatCondition(condition))
		delete condition;
}

static void doDots(Player* player, Item* item, Creature* target, int32_t dealt)
{
	if(dealt <= 0)
		return;

	Item* bow = NULL;
	if(item->getWeaponType() == WEAPON_AMMO)
		bow = player->getWeapon(true);

	bool poisoned = getEnchant(player, item) == ENCHANT_POISON;

	for(int32_t i = 0; i < DOT_COUNT; ++i)
	{
		//the item that was used first, then the bow when it was an ammunition
		const DotInfo* base = &Item::items[item->getID()].dots[i];
		if(!base->isValid())
			base = bow ? &Item::items[bow->getID()].dots[i] : NULL;

		DotInfo sum;
		if(base && base->isValid())
			sum = *base;

		//the Archer enchantment adds to the poison of the items
		if(i == DOT_POISON && poisoned)
		{
			sum.damage += ENCHANT_POISON_DAMAGE;
			sum.chance = std::min(100, sum.chance + ENCHANT_POISON_CHANCE);
			sum.times += ENCHANT_POISON_TIMES;
		}

		if(!sum.isValid())
			continue;

		const DotInfo* dot = &sum;

		if(target->isRemoved() || target->getHealth() <= 0)
			return;

		if(random_range(1, 100) > dot->chance)
			continue;

		int32_t value = std::max(1, (dealt * dot->damage) / 100);
		ConditionDamage* condition = dynamic_cast<ConditionDamage*>(Condition::createCondition(
			CONDITIONID_COMBAT, getDotCondition(i), 0));
		if(!condition)
			continue;

		condition->setParam(CONDITIONPARAM_OWNER, player->getID());
		condition->setParam(CONDITIONPARAM_DELAYED, 1);
		condition->addDamage(dot->times, DOT_INTERVAL, -value);
		if(!target->addCombatCondition(condition))
			delete condition;
	}
}

//value of a physical attribute (items.xml) of the item that was used plus, when it was an ammunition, the one of the bow.
//sum = true adds both (chances, amounts), false takes the biggest one (damage percent, durations)
static int32_t getAttackAttr(Player* player, Item* item, int32_t ItemType::* attr, bool sum)
{
	int32_t value = Item::items[item->getID()].*attr;
	if(item->getWeaponType() == WEAPON_AMMO)
	{
		if(Item* bow = player->getWeapon(true))
		{
			int32_t other = Item::items[bow->getID()].*attr;
			value = sum ? value + other : std::max(value, other);
		}
	}

	return value;
}

//pierce attribute (items.xml): after a hit of the basic attack there is a chance of the arrow going through the target and
//hitting the creatures behind it, in the same line, each with a percent of the damage of the basic attack
static const int32_t PIERCE_RANGE = 7;

static void doPierce(Player* player, Item* item, Creature* first, int32_t damage, const CombatParams& params)
{
	int32_t targets = getAttackAttr(player, item, &ItemType::pierceTargets, true);
	int32_t chance = std::min((int32_t)100, getAttackAttr(player, item, &ItemType::pierceChance, true));
	int32_t percent = getAttackAttr(player, item, &ItemType::pierceDamage, false);
	if(targets <= 0 || chance <= 0 || damage >= 0 || random_range(1, 100) > chance)
		return;

	int32_t pierceDamage = (damage * percent) / 100;
	if(pierceDamage >= 0)
		return;

	const Position from = player->getPosition(), to = first->getPosition();
	int32_t dx = (int32_t)to.x - (int32_t)from.x, dy = (int32_t)to.y - (int32_t)from.y;
	int32_t steps = std::max(std::abs(dx), std::abs(dy));
	if(!steps || from.z != to.z)
		return;

	//the line from the player through the target, continued behind it
	std::vector<std::pair<uint32_t, Position> > found;
	for(int32_t i = 1; i <= PIERCE_RANGE && (int32_t)found.size() < targets; ++i)
	{
		int32_t x = (int32_t)from.x + (int32_t)std::floor((double)dx * (steps + i) / steps + 0.5);
		int32_t y = (int32_t)from.y + (int32_t)std::floor((double)dy * (steps + i) / steps + 0.5);
		if(x < 0 || y < 0)
			break;

		Tile* tile = g_game.getTile(x, y, from.z);
		if(!tile || !tile->ground || tile->hasProperty(BLOCKPROJECTILE))
			break;

		CreatureVector* creatures = tile->getCreatures();
		if(!creatures)
			continue;

		for(CreatureVector::iterator it = creatures->begin(); it != creatures->end() && (int32_t)found.size() < targets; ++it)
		{
			Creature* creature = *it;
			if(creature != player && creature != first && !tile->hasFlag(TILESTATE_PROTECTIONZONE)
				&& Combat::canDoCombat(player, creature) == RET_NOERROR)
				found.push_back(std::make_pair(creature->getID(), tile->getPosition()));
		}
	}

	Position last = to;
	for(std::vector<std::pair<uint32_t, Position> >::iterator it = found.begin(); it != found.end(); ++it)
	{
		Creature* creature = g_game.getCreatureByID(it->first);
		if(!creature || creature->isRemoved() || creature->getHealth() <= 0)
			continue;

		Combat::addDistanceEffect(player, last, it->second, params.effects.distance);
		last = it->second;

		CombatParams hit = params;
		hit.effects.distance = SHOOT_EFFECT_NONE;

		player->setLastDamageDealt(0);
		Combat::doCombatHealth(player, creature, pierceDamage, pierceDamage, hit);
		applyOnHitElemental(player, creature, player->getLastDamageDealt(), hit.origin);
	}
}

//stun attribute (items.xml): after a hit of the basic attack there is a chance of stopping the target from walking and attacking
static void doStun(Player* player, Item* item, Creature* target)
{
	int32_t duration = getAttackAttr(player, item, &ItemType::stunDuration, false);
	int32_t chance = std::min((int32_t)100, getAttackAttr(player, item, &ItemType::stunChance, true));
	if(duration <= 0 || chance <= 0 || target->isRemoved() || target->getHealth() <= 0 || random_range(1, 100) > chance)
		return;

	//rooted (does not walk) and pacified (does not attack)
	static const ConditionType_t types[] = {CONDITION_ROOT, CONDITION_PACIFIED};
	for(int32_t i = 0; i < 2; ++i)
	{
		Condition* condition = Condition::createCondition(CONDITIONID_COMBAT, types[i], duration);
		if(condition && !target->addCombatCondition(condition))
			delete condition;
	}
}

//knockback attribute (items.xml): after a hit of the basic attack there is a chance of pushing the target away from the attacker
static void doKnockback(Player* player, Item* item, Creature* target)
{
	int32_t distance = getAttackAttr(player, item, &ItemType::knockbackDistance, true);
	int32_t chance = std::min((int32_t)100, getAttackAttr(player, item, &ItemType::knockbackChance, true));
	if(distance <= 0 || chance <= 0 || target->isRemoved() || target->getHealth() <= 0 || random_range(1, 100) > chance)
		return;

	Direction dir = getDirectionTo(player->getPosition(), target->getPosition());

	for(int32_t i = 0; i < distance; ++i)
	{
		if(target->isRemoved() || g_game.internalMoveCreature(target, dir) != RET_NOERROR)
			break;
	}
}

//multishot attribute (items.xml): "shots,chance%" - after the attack there is a chance of shooting between 1 and "shots"
//extra times at the same target. The extra shots are full hits (same damage roll and effects), never miss and do not spend ammunition.
static const int32_t MULTISHOT_DELAY = 200;

static void doExtraShot(uint32_t playerId, uint32_t targetId, uint16_t itemId)
{
	Player* player = g_game.getPlayerByID(playerId);
	Creature* target = g_game.getCreatureByID(targetId);
	if(!player || player->isRemoved() || !target || target->isRemoved() || target->getHealth() <= 0)
		return;

	//the item is looked for again (the stack may have been used up or moved meanwhile)
	Item* item = NULL;
	static const slots_t slots[] = {SLOT_AMMO, SLOT_RIGHT, SLOT_LEFT};
	for(int32_t i = 0; i < 3 && !item; ++i)
	{
		Item* tmp = player->getInventoryItem(slots[i]);
		if(tmp && tmp->getID() == itemId)
			item = tmp;
	}

	if(!item)
		return;

	if(const Weapon* weapon = g_weapons->getWeapon(item))
		weapon->extraShot(player, item, target);
}

static void doMultishot(Player* player, Item* item, Creature* target)
{
	if(item->getWeaponType() != WEAPON_AMMO && item->getWeaponType() != WEAPON_DIST)
		return;

	int32_t shots = getAttackAttr(player, item, &ItemType::multishotCount, true);
	int32_t chance = std::min((int32_t)100, getAttackAttr(player, item, &ItemType::multishotChance, true));
	if(shots <= 0 || chance <= 0 || random_range(1, 100) > chance)
		return;

	shots = random_range(1, shots);
	for(int32_t i = 1; i <= shots; ++i)
		Scheduler::getInstance().addEvent(createSchedulerTask(MULTISHOT_DELAY * i,
			boost::bind(&doExtraShot, player->getID(), target->getID(), item->getID())));
}

Weapons::Weapons():
	m_interface("Weapon Interface")
{
	m_interface.initState();
}

const Weapon* Weapons::getWeapon(const Item* item) const
{
	if(!item)
		return NULL;

	WeaponMap::const_iterator it = weapons.find(item->getID());
	if(it != weapons.end())
		return it->second;

	return NULL;
}

void Weapons::clear()
{
	for(WeaponMap::iterator it = weapons.begin(); it != weapons.end(); ++it)
		delete it->second;

	weapons.clear();
	m_interface.reInitState();
}

bool Weapons::loadDefaults()
{
	for(uint32_t i = 0; i <= Item::items.size(); ++i)
	{
		const ItemType* it = Item::items.getElement(i);
		if(!it || weapons.find(it->id) != weapons.end())
			continue;

		if(it->weaponType != WEAPON_NONE)
		{
			switch(it->weaponType)
			{
				case WEAPON_AXE:
				case WEAPON_SWORD:
				case WEAPON_CLUB:
				case WEAPON_FIST:
				{
					if(WeaponMelee* weapon = new WeaponMelee(&m_interface))
					{
						weapon->configureWeapon(*it);
						weapons[it->id] = weapon;
					}

					break;
				}

				case WEAPON_DIST:
					if(it->ammoType != AMMO_NONE)
						break;

				case WEAPON_AMMO:
				{
					if(WeaponDistance* weapon = new WeaponDistance(&m_interface))
					{
						weapon->configureWeapon(*it);
						weapons[it->id] = weapon;
					}

					break;
				}

				default:
					break;
			}
		}
	}

	return true;
}

Event* Weapons::getEvent(const std::string& nodeName)
{
	std::string tmpNodeName = asLowerCaseString(nodeName);
	if(tmpNodeName == "melee")
		return new WeaponMelee(&m_interface);

	if(tmpNodeName == "distance" || tmpNodeName == "ammunition" || tmpNodeName == "ammo")
		return new WeaponDistance(&m_interface);

	if(tmpNodeName == "wand" || tmpNodeName == "rod")
		return new WeaponWand(&m_interface);

	return NULL;
}

bool Weapons::registerEvent(Event* event, xmlNodePtr, bool override)
{
	Weapon* weapon = dynamic_cast<Weapon*>(event);
	if(!weapon)
		return false;

	WeaponMap::iterator it = weapons.find(weapon->getID());
	if(it == weapons.end())
	{
		weapons[weapon->getID()] = weapon;
		return true;
	}

	if(override)
	{
		delete it->second;
		it->second = weapon;
		return true;
	}

	std::clog << "[Warning - Weapons::registerEvent] Duplicate registered item with id: " << weapon->getID() << std::endl;
	return false;
}

int32_t Weapons::getMaxMeleeDamage(int32_t attackSkill, int32_t attackValue)
{
	return (int32_t)std::ceil((attackSkill * (attackValue * 0.05)) + (attackValue * 0.5));
}

int32_t Weapons::getMaxWeaponDamage(int32_t level, int32_t attackSkill, int32_t attackValue, float attackFactor)
{
	return (int32_t)std::ceil((2 * (attackValue * (attackSkill + 5.8) / 25 + (level - 1) / 10.)) / attackFactor);
}

Weapon::Weapon(LuaInterface* _interface):
	Event(_interface)
{
	id = 0;
	level = 0;
	magLevel = 0;
	mana = 0;
	manaPercent = 0;
	soul = 0;
	exhaustion = 0;
	premium = false;
	enabled = true;
	wieldUnproperly = false;
	swing = true;
	ammoAction = AMMOACTION_NONE;
	params.blockedByArmor = true;
	params.blockedByShield = true;
	params.combatType = COMBAT_PHYSICALDAMAGE;
}

bool Weapon::configureEvent(xmlNodePtr p)
{
	int32_t intValue, wieldInfo = 0;
	std::string strValue;
	if(!readXMLInteger(p, "id", intValue))
	{
		std::clog << "Error: [Weapon::configureEvent] Weapon without id." << std::endl;
		return false;
	}

	id = intValue;
	if(readXMLInteger(p, "lv", intValue) || readXMLInteger(p, "lvl", intValue) || readXMLInteger(p, "level", intValue))
	{
	 	level = intValue;
		if(level > 0)
			wieldInfo |= WIELDINFO_LEVEL;
	}

	if(readXMLInteger(p, "maglv", intValue) || readXMLInteger(p, "maglvl", intValue) || readXMLInteger(p, "maglevel", intValue))
	{
	 	magLevel = intValue;
		if(magLevel > 0)
			wieldInfo |= WIELDINFO_MAGLV;
	}

	if(readXMLInteger(p, "mana", intValue))
	 	mana = intValue;

	if(readXMLInteger(p, "manapercent", intValue))
	 	manaPercent = intValue;

	if(readXMLInteger(p, "soul", intValue))
	 	soul = intValue;

	if(readXMLInteger(p, "exhaust", intValue) || readXMLInteger(p, "exhaustion", intValue))
		exhaustion = intValue;

	if(readXMLString(p, "prem", strValue) || readXMLString(p, "premium", strValue))
	{
		premium = booleanString(strValue);
		if(premium)
			wieldInfo |= WIELDINFO_PREMIUM;
	}

	if(readXMLString(p, "enabled", strValue))
		enabled = booleanString(strValue);

	if(readXMLString(p, "unproperly", strValue))
		wieldUnproperly = booleanString(strValue);

	if(readXMLString(p, "swing", strValue))
		swing = booleanString(strValue);

	if(readXMLString(p, "type", strValue))
		params.combatType = getCombatType(strValue);

	std::string error;
	StringVec vocStringVec;

	xmlNodePtr vocationNode = p->children;
	while(vocationNode)
	{
		if(!parseVocationNode(vocationNode, vocWeaponMap, vocStringVec, error))
			std::clog << "[Warning - Weapon::configureEvent] " << error << std::endl;

		vocationNode = vocationNode->next;
	}

	//itemVocationRestrictions = false (config.lua): any vocation can use any weapon (the <vocation> nodes are only parsed, then dropped)
	if(!g_config.getBool(ConfigManager::ITEM_VOCATION_RESTRICTIONS))
	{
		vocWeaponMap.clear();
		vocStringVec.clear();
	}

	if(!vocWeaponMap.empty())
		wieldInfo |= WIELDINFO_VOCREQ;

	if(wieldInfo)
	{
		ItemType& it = Item::items.getItemType(id);
		it.minReqMagicLevel = getReqMagLv();
		it.minReqLevel = getReqLevel();

		it.wieldInfo = wieldInfo;
		it.vocationString = parseVocationString(vocStringVec);
	}

	return configureWeapon(Item::items[getID()]);
}

bool Weapon::loadFunction(const std::string& functionName)
{
	std::string tmpFunctionName = asLowerCaseString(functionName);
	if(tmpFunctionName == "internalloadweapon" || tmpFunctionName == "default")
	{
		m_scripted = EVENT_SCRIPT_FALSE;
		return configureWeapon(Item::items[getID()]);
	}

	return false;
}

bool Weapon::configureWeapon(const ItemType& it)
{
	id = it.id;
	return true;
}

int32_t Weapon::playerWeaponCheck(Player* player, Creature* target) const
{
	const Position& playerPos = player->getPosition();
	const Position& targetPos = target->getPosition();
	if(playerPos.z != targetPos.z)
		return 0;

	const ItemType& it = Item::items[getID()];
	int32_t range = it.shootRange;
	if(it.weaponType == WEAPON_AMMO)
		range = player->getShootRange();

	if(std::max(std::abs(playerPos.x - targetPos.x), std::abs(playerPos.y - targetPos.y)) > range)
		return 0;

	if(player->hasFlag(PlayerFlag_IgnoreEquipCheck))
		return 100;

	if(!enabled)
		return 0;

	if(player->getMana() < getManaCost(player))
		return 0;

	if(player->getSoul() < soul)
		return 0;

	if(isPremium() && !player->isPremium())
		return 0;

	if(!vocWeaponMap.empty() && vocWeaponMap.find(player->getVocationId()) == vocWeaponMap.end())
		return 0;

	int32_t damageModifier = 100;
	if(player->getLevel() < getReqLevel())
		damageModifier = (isWieldedUnproperly() ? damageModifier / 2 : 0);

	if(player->getMagicLevel() < getReqMagLv())
		damageModifier = (isWieldedUnproperly() ? damageModifier / 2 : 0);

	return damageModifier;
}

bool Weapon::useWeapon(Player* player, Item* item, Creature* target) const
{
	int32_t damageModifier = playerWeaponCheck(player, target);
	if(!damageModifier)
		return false;

	return internalUseWeapon(player, item, target, damageModifier);
}

bool Weapon::useFist(Player* player, Creature* target)
{
	const Position& playerPos = player->getPosition();
	const Position& targetPos = target->getPosition();
	if(!Position::areInRange<1,1>(playerPos, targetPos))
		return false;

	float attackFactor = player->getAttackFactor();
	int32_t attackSkill = player->getSkill(SKILL_FIST, SKILL_LEVEL), attackValue = g_config.getNumber(ConfigManager::FIST_BASE_ATTACK);

	double maxDamage = Weapons::getMaxWeaponDamage(player->getLevel(), attackSkill, attackValue, attackFactor);

	Vocation* vocation = player->getVocation();
	if(vocation && vocation->getMultiplier(MULTIPLIER_MELEE) != 1.0)
		maxDamage *= vocation->getMultiplier(MULTIPLIER_MELEE);

	maxDamage = std::floor(maxDamage);
	int32_t damage = -random_range(0, (int32_t)maxDamage, DISTRO_NORMAL);

	CombatParams fist;
	fist.blockedByArmor = true;
	fist.blockedByShield = true;
	fist.combatType = COMBAT_PHYSICALDAMAGE;
	fist.origin = ORIGIN_MELEE;

	player->setLastDamageDealt(0);
	Combat::doCombatHealth(player, target, damage, damage, fist);
	applyOnHitElemental(player, target, player->getLastDamageDealt(), fist.origin);
	if(!player->hasFlag(PlayerFlag_NotGainSkill) && player->getAddAttackSkill())
		player->addSkillAdvance(SKILL_FIST, 1);

	return true;
}

bool Weapon::internalUseWeapon(Player* player, Item* item, Creature* target, int32_t damageModifier) const
{
	if(isScripted())
	{
		LuaVariant var;
		var.type = VARIANT_NUMBER;
		var.number = target->getID();
		executeUseWeapon(player, var);
	}
	else
	{
		int32_t damage = (getWeaponDamage(player, target, item) * damageModifier) / 100;
		doHit(player, item, target, damage);
		doMultishot(player, item, target);
	}

	onUsedAmmo(player, item, target->getTile());
	onUsedWeapon(player, item, target->getTile());
	return true;
}

//one hit of the basic attack with all the effects of the attributes of the items
void Weapon::doHit(Player* player, Item* item, Creature* target, int32_t damage) const
{
	//armorPierce is read by Creature::blockHit while the damage is made
	player->setAttackArmorPierce(std::min((int32_t)100, getAttackAttr(player, item, &ItemType::armorPierce, true)));

	player->setLastDamageDealt(0);
	Combat::doCombatHealth(player, target, damage, damage, params);
	int32_t dealt = player->getLastDamageDealt();
	applyOnHitElemental(player, target, dealt, params.origin);
	doSplash(player, item, target->getPosition(), target, damage, params);
	doChainLightning(player, item, target, damage, params);
	doParalyze(player, item, target);
	doRoot(player, item, target);
	doDots(player, item, target, dealt);
	doPierce(player, item, target, damage, params);
	doStun(player, item, target);

	player->setAttackArmorPierce(0);
	doKnockback(player, item, target);
}

void Weapon::extraShot(Player* player, Item* item, Creature* target) const
{
	if(isScripted())
		return;

	int32_t damageModifier = playerWeaponCheck(player, target);
	if(!damageModifier)
		return;

	doHit(player, item, target, (getWeaponDamage(player, target, item) * damageModifier) / 100);
}

bool Weapon::internalUseWeapon(Player* player, Item* item, Tile* tile) const
{
	if(isScripted())
	{
		LuaVariant var;
		var.type = VARIANT_TARGETPOSITION;
		var.pos = tile->getPosition();
		executeUseWeapon(player, var);
	}
	else
	{
		Combat::postCombatEffects(player, tile->getPosition(), params);
		g_game.addMagicEffect(tile->getPosition(), MAGIC_EFFECT_POFF);
		if(getSplashSize(player, item) > 1)
			doSplash(player, item, tile->getPosition(), NULL, getWeaponDamage(player, NULL, item), params);
	}

	onUsedAmmo(player, item, tile);
	onUsedWeapon(player, item, tile);
	return true;
}

void Weapon::onUsedWeapon(Player* player, Item* item, Tile*) const
{
	if(!player->hasFlag(PlayerFlag_NotGainSkill))
	{
		skills_t skillType;
		uint32_t skillPoint = 0;
		if(getSkillType(player, item, skillType, skillPoint))
			player->addSkillAdvance(skillType, skillPoint);
	}

	if(!player->hasFlag(PlayerFlag_HasNoExhaustion) && exhaustion > 0)
		player->addExhaust(exhaustion, EXHAUST_COMBAT);

	int32_t manaCost = getManaCost(player);
	if(manaCost > 0)
	{
		player->changeMana(-manaCost);
		if(!player->hasFlag(PlayerFlag_NotGainMana) && (player->getZone() != ZONE_HARDCORE
			|| !g_config.getBool(ConfigManager::PVPZONE_ADDMANASPENT)))
			player->addManaSpent(manaCost);
	}

	if(!player->hasFlag(PlayerFlag_HasInfiniteSoul) && soul > 0)
		player->changeSoul(-soul);
}

//useBackpackAmmunitionFirst (config.lua): the ammunition of the ammo slot is only spent when the backpack has no more of the same
//ammunition, so the player does not need to swap the stack all the time. Returns the item that must pay for the shot.
static Item* getAmmoToSpend(Player* player, Item* item)
{
	if(!g_config.getBool(ConfigManager::BACKPACK_AMMO_FIRST) || item->getWeaponType() != WEAPON_AMMO
		|| player->getInventoryItem(SLOT_AMMO) != item)
		return item;

	Item* backpack = player->getInventoryItem(SLOT_BACKPACK);
	Container* container = backpack ? backpack->getContainer() : NULL;
	if(!container)
		return item;

	for(ContainerIterator it = container->begin(), end = container->end(); it != end; ++it)
	{
		Item* other = *it;
		if(other != item && other->getID() == item->getID() && other->getItemCount() > 0)
			return other;
	}

	return item;
}

void Weapon::onUsedAmmo(Player* player, Item* item, Tile* destTile) const
{
	if(!g_config.getBool(ConfigManager::REMOVE_WEAPON_AMMO))
		return;

	item = getAmmoToSpend(player, item);

	switch(ammoAction)
	{
		case AMMOACTION_REMOVECOUNT:
			g_game.transformItem(item, item->getID(), std::max((int32_t)0, ((int32_t)item->getItemCount()) - 1));
			break;

		case AMMOACTION_REMOVECHARGE:
			g_game.transformItem(item, item->getID(), std::max((int32_t)0, ((int32_t)item->getCharges()) - 1));
			break;

		case AMMOACTION_MOVE:
			g_game.internalMoveItem(player, item->getParent(), destTile, INDEX_WHEREEVER, item, 1, NULL, FLAG_NOLIMIT);
			break;

		case AMMOACTION_MOVEBACK:
			break;

		default:
			if(item->hasCharges())
				g_game.transformItem(item, item->getID(), std::max((int32_t)0, ((int32_t)item->getCharges()) - 1));

			break;
	}
}

int32_t Weapon::getManaCost(const Player* player) const
{
	if(mana)
		return mana;

	return manaPercent ? (player->getMaxMana() * manaPercent) / 100 : 0;
}

bool Weapon::executeUseWeapon(Player* player, const LuaVariant& var) const
{
	//onUseWeapon(cid, var)
	if(m_interface->reserveEnv())
	{
		ScriptEnviroment* env = m_interface->getEnv();
		if(m_scripted == EVENT_SCRIPT_BUFFER)
		{
			env->setRealPos(player->getPosition());
			std::stringstream scriptstream;

			scriptstream << "local cid = " << env->addThing(player) << std::endl;
			env->streamVariant(scriptstream, "var", var);

			scriptstream << m_scriptData;
			bool result = true;
			if(m_interface->loadBuffer(scriptstream.str()))
			{
				lua_State* L = m_interface->getState();
				result = m_interface->getGlobalBool(L, "_result", true);
			}

			m_interface->releaseEnv();
			return result;
		}
		else
		{
			#ifdef __DEBUG_LUASCRIPTS__
			char desc[60];
			sprintf(desc, "onUseWeapon - %s", player->getName().c_str());
			env->setEvent(desc);
			#endif

			env->setScriptId(m_scriptId, m_interface);
			env->setRealPos(player->getPosition());

			lua_State* L = m_interface->getState();
			m_interface->pushFunction(m_scriptId);

			lua_pushnumber(L, env->addThing(player));
			m_interface->pushVariant(L, var);

			bool result = m_interface->callFunction(2);
			m_interface->releaseEnv();
			return result;
		}
	}
	else
	{
		std::clog << "[Error - Weapon::executeUseWeapon] Call stack overflow" << std::endl;
		return false;
	}
}

WeaponMelee::WeaponMelee(LuaInterface* _interface):
	Weapon(_interface)
{
	elementType = COMBAT_NONE;
	elementDamage = 0;
	params.origin = ORIGIN_MELEE;
}

bool WeaponMelee::configureWeapon(const ItemType& it)
{
	elementType = it.abilities.elementType;
	elementDamage = it.abilities.elementDamage;
	return Weapon::configureWeapon(it);
}

bool WeaponMelee::useWeapon(Player* player, Item* item, Creature* target) const
{
	if(!Weapon::useWeapon(player, item, target))
		return false;

	if(elementDamage && elementType != COMBAT_NONE)
	{
		CombatParams element;
		element.combatType = elementType;
		element.origin = params.origin;

		int32_t damage = getElementDamage(player, item);
		Combat::doCombatHealth(player, target, damage, damage, element);
	}

	return true;
}

bool WeaponMelee::getSkillType(const Player* player, const Item* item,
	skills_t& skill, uint32_t& skillpoint) const
{
	skillpoint = 0;
	if(player->getAddAttackSkill())
	{
		switch(player->getLastAttackBlockType())
		{
			case BLOCK_ARMOR:
			case BLOCK_NONE:
				skillpoint = 1;
				break;

			case BLOCK_DEFENSE:
			default:
				skillpoint = 0;
				break;
		}
	}

	switch(item->getWeaponType())
	{
		case WEAPON_SWORD:
		{
			skill = SKILL_SWORD;
			return true;
		}

		case WEAPON_CLUB:
		{
			skill = SKILL_CLUB;
			return true;
		}

		case WEAPON_AXE:
		{
			skill = SKILL_AXE;
			return true;
		}

		case WEAPON_FIST:
		{
			skill = SKILL_FIST;
			return true;
		}

		default:
			break;
	}

	return false;
}

int32_t WeaponMelee::getWeaponDamage(const Player* player, const Creature*, const Item* item, bool maxDamage /*= false*/) const
{
	int32_t attackSkill = player->getWeaponSkill(item), attackValue = player->getDualWieldAttack(item, elementDamage);
	float attackFactor = player->getAttackFactor();

	double maxValue = Weapons::getMaxWeaponDamage(player->getLevel(), attackSkill, attackValue, attackFactor);

	Vocation* vocation = player->getVocation();
	if(vocation && vocation->getMultiplier(MULTIPLIER_MELEE) != 1.0)
		maxValue *= vocation->getMultiplier(MULTIPLIER_MELEE);

	int32_t ret = (int32_t)std::floor(maxValue);
	if(maxDamage)
		return -ret;

	return -random_range(0, ret, DISTRO_NORMAL);
}

int32_t WeaponMelee::getElementDamage(const Player* player, const Item* item) const
{
	int32_t attackSkill = player->getWeaponSkill(item);
	float attackFactor = player->getAttackFactor();

	double maxValue = Weapons::getMaxWeaponDamage(player->getLevel(), attackSkill, elementDamage, attackFactor);

	Vocation* vocation = player->getVocation();
	if(vocation && vocation->getMultiplier(MULTIPLIER_MELEE) != 1.0)
		maxValue *= vocation->getMultiplier(MULTIPLIER_MELEE);

	return -random_range(0, (int32_t)std::floor(maxValue), DISTRO_NORMAL);
}

WeaponDistance::WeaponDistance(LuaInterface* _interface):
	Weapon(_interface)
{
	hitChance = -1;
	maxHitChance = breakChance = ammoAttackValue = 0;
	swing = params.blockedByShield = false;
	params.origin = ORIGIN_RANGED;
}

bool WeaponDistance::configureWeapon(const ItemType& it)
{
	if(it.ammoType != AMMO_NONE) //hit chance on two-handed weapons is limited to 90%
		maxHitChance = 90;
	else //one-handed is set to 75%
		maxHitChance = 75;

	if(it.hitChance > 0)
		hitChance = it.hitChance;

	if(it.maxHitChance > 0)
		maxHitChance = it.maxHitChance;

	if(it.breakChance > 0)
		breakChance = it.breakChance;

	if(it.ammoAction != AMMOACTION_NONE)
		ammoAction = it.ammoAction;

	params.effects.distance = it.shootType;
	ammoAttackValue = it.attack;
	return Weapon::configureWeapon(it);
}

int32_t WeaponDistance::playerWeaponCheck(Player* player, Creature* target) const
{
	const ItemType& it = Item::items[id];
	if(it.weaponType == WEAPON_AMMO)
	{
		if(Item* item = player->getWeapon(true))
		{
			if(const Weapon* weapon = g_weapons->getWeapon(item))
				return weapon->playerWeaponCheck(player, target);
		}
	}

	return Weapon::playerWeaponCheck(player, target);
}

bool WeaponDistance::useWeapon(Player* player, Item* item, Creature* target) const
{
	int32_t damageModifier = playerWeaponCheck(player, target);
	if(!damageModifier)
		return false;

	int32_t chance = hitChance;
	if(chance == -1)
	{
		//hit chance is based on distance to target and distance skill
		const Position& playerPos = player->getPosition();
		const Position& targetPos = target->getPosition();

		uint32_t distance = std::max(std::abs(playerPos.x - targetPos.x), std::abs(
			playerPos.y - targetPos.y)), skill = player->getSkill(SKILL_DIST, SKILL_LEVEL);
		if(maxHitChance == 75)
		{
			//chance for one-handed weapons
			switch(distance)
			{
				case 1:
					chance = (uint32_t)((float)std::min(skill, (uint32_t)74)) + 1;
					break;
				case 2:
					chance = (uint32_t)((float)2.4 * std::min(skill, (uint32_t)28)) + 8;
					break;
				case 3:
					chance = (uint32_t)((float)1.55 * std::min(skill, (uint32_t)45)) + 6;
					break;
				case 4:
					chance = (uint32_t)((float)1.25 * std::min(skill, (uint32_t)58)) + 3;
					break;
				case 5:
					chance = (uint32_t)((float)std::min(skill, (uint32_t)74)) + 1;
					break;
				case 6:
					chance = (uint32_t)((float)0.8 * std::min(skill, (uint32_t)90)) + 3;
					break;
				case 7:
					chance = (uint32_t)((float)0.7 * std::min(skill, (uint32_t)104)) + 2;
					break;
				default:
					chance = hitChance;
					break;
			}
		}
		else if(maxHitChance == 90)
		{
			//formula for two-handed weapons
			switch(distance)
			{
				case 1:
					chance = (uint32_t)((float)1.2 * std::min(skill, (uint32_t)74)) + 1;
					break;
				case 2:
					chance = (uint32_t)((float)3.2 * std::min(skill, (uint32_t)28));
					break;
				case 3:
					chance = (uint32_t)((float)2.0 * std::min(skill, (uint32_t)45));
					break;
				case 4:
					chance = (uint32_t)((float)1.55 * std::min(skill, (uint32_t)58));
					break;
				case 5:
					chance = (uint32_t)((float)1.2 * std::min(skill, (uint32_t)74)) + 1;
					break;
				case 6:
					chance = (uint32_t)((float)1.0 * std::min(skill, (uint32_t)90));
					break;
				case 7:
					chance = (uint32_t)((float)1.0 * std::min(skill, (uint32_t)90));
					break;
				default:
					chance = hitChance;
					break;
			}
		}
		else if(maxHitChance == 100)
		{
			switch(distance)
			{
				case 1:
					chance = (uint32_t)((float)1.35 * std::min(skill, (uint32_t)73)) + 1;
					break;
				case 2:
					chance = (uint32_t)((float)3.2 * std::min(skill, (uint32_t)30)) + 4;
					break;
				case 3:
					chance = (uint32_t)((float)2.05 * std::min(skill, (uint32_t)48)) + 2;
					break;
				case 4:
					chance = (uint32_t)((float)1.5 * std::min(skill, (uint32_t)65)) + 2;
					break;
				case 5:
					chance = (uint32_t)((float)1.35 * std::min(skill, (uint32_t)73)) + 1;
					break;
				case 6:
					chance = (uint32_t)((float)1.2 * std::min(skill, (uint32_t)87)) - 4;
					break;
				case 7:
					chance = (uint32_t)((float)1.1 * std::min(skill, (uint32_t)90)) + 1;
					break;
				default:
					chance = hitChance;
					break;
			}
		}
		else
			chance = maxHitChance;
	}

	if(item->getWeaponType() == WEAPON_AMMO)
	{
		Item* bow = player->getWeapon(true);
		if(bow && bow->getHitChance() != -1)
			chance += bow->getHitChance();
	}

	if(g_config.getBool(ConfigManager::DISTANCE_HIT_CHANCE) && random_range(1, 100) > chance)
	{
		//we failed attack, miss!
		Tile* destTile = target->getTile();
		if(!Position::areInRange<1,1,0>(player->getPosition(), target->getPosition()))
		{
			std::vector<std::pair<int32_t, int32_t> > destList;
			destList.push_back(std::make_pair(-1, -1));
			destList.push_back(std::make_pair(-1, 0));
			destList.push_back(std::make_pair(-1, 1));
			destList.push_back(std::make_pair(0, -1));
			destList.push_back(std::make_pair(0, 0));
			destList.push_back(std::make_pair(0, 1));
			destList.push_back(std::make_pair(1, -1));
			destList.push_back(std::make_pair(1, 0));
			destList.push_back(std::make_pair(1, 1));

			std::random_shuffle(destList.begin(), destList.end());
			Position destPos = target->getPosition();

			Tile* tmpTile = NULL;
			for(std::vector<std::pair<int32_t, int32_t> >::iterator it = destList.begin(); it != destList.end(); ++it)
			{
				if((tmpTile = g_game.getTile(destPos.x + it->first, destPos.y + it->second, destPos.z))
					&& !tmpTile->hasProperty(IMMOVABLEBLOCKSOLID) && tmpTile->ground)
				{
					destTile = tmpTile;
					break;
				}
			}
		}

		Weapon::internalUseWeapon(player, item, destTile);
	}
	else
		Weapon::internalUseWeapon(player, item, target, damageModifier);

	return true;
}

void WeaponDistance::onUsedAmmo(Player* player, Item* item, Tile* destTile) const
{
	if(!g_config.getBool(ConfigManager::REMOVE_WEAPON_AMMO))
		return;

	//ammoSave attribute (items.xml): chance of not spending the ammunition
	if(random_range(1, 100) <= std::min((int32_t)100, getAttackAttr(player, item, &ItemType::ammoSave, true)))
		return;

	item = getAmmoToSpend(player, item);

	if(ammoAction == AMMOACTION_MOVEBACK && breakChance > 0 && random_range(1, 100) < breakChance)
		g_game.transformItem(item, item->getID(), std::max(0, item->getItemCount() - 1));
	else
		Weapon::onUsedAmmo(player, item, destTile);
}

int32_t WeaponDistance::getWeaponDamage(const Player* player, const Creature* target, const Item* item, bool maxDamage /*= false*/) const
{
	int32_t attackValue = ammoAttackValue;
	if(item->getWeaponType() == WEAPON_AMMO)
	{
		if(Item* bow = const_cast<Player*>(player)->getWeapon(true))
			attackValue += bow->getAttack() + bow->getExtraAttack();
	}

	int32_t attackSkill = player->getSkill(SKILL_DIST, SKILL_LEVEL);
	float attackFactor = player->getAttackFactor();

	double maxValue = Weapons::getMaxWeaponDamage(player->getLevel(), attackSkill, attackValue, attackFactor);

	Vocation* vocation = player->getVocation();
	if(vocation && vocation->getMultiplier(MULTIPLIER_DISTANCE) != 1.0)
		maxValue *= vocation->getMultiplier(MULTIPLIER_DISTANCE);

	int32_t ret = (int32_t)std::floor(maxValue);
	if(maxDamage)
		return -ret;

	int32_t minValue = 0;
	if(target)
	{
		if(target->getPlayer())
			minValue = (int32_t)std::ceil(player->getLevel() * 0.1);
		else
			minValue = (int32_t)std::ceil(player->getLevel() * 0.2);
	}

	return -random_range(minValue, ret, DISTRO_NORMAL);
}

bool WeaponDistance::getSkillType(const Player* player, const Item*,
	skills_t& skill, uint32_t& skillpoint) const
{
	skill = SKILL_DIST;
	skillpoint = 0;

	if(player->getAddAttackSkill())
	{
		switch(player->getLastAttackBlockType())
		{
			case BLOCK_NONE:
				skillpoint = 2;
				break;

			case BLOCK_ARMOR:
				skillpoint = 1;
				break;

			case BLOCK_DEFENSE:
			default:
				skillpoint = 0;
				break;
		}
	}
	return true;
}

WeaponWand::WeaponWand(LuaInterface* _interface):
	Weapon(_interface)
{
	params.blockedByArmor = false;
	params.blockedByShield = false;
	params.origin = ORIGIN_WAND;
}

bool WeaponWand::configureWeapon(const ItemType& it)
{
	params.effects.distance = it.shootType;
	return Weapon::configureWeapon(it);
}

//same formula as melee weapons, but (magic level + 10) takes the place of the weapon skill
int32_t WeaponWand::getWeaponDamage(const Player* player, const Creature*, const Item* item, bool maxDamage /* = false*/) const
{
	int32_t attackValue = item ? item->getAttack() : 0;
	double maxValue = Weapons::getMaxWeaponDamage(player->getLevel(), player->getMagicLevel() + 10, attackValue, player->getAttackFactor());

	Vocation* vocation = player->getVocation();
	if(vocation && vocation->getMultiplier(MULTIPLIER_WAND) != 1.0)
		maxValue *= vocation->getMultiplier(MULTIPLIER_WAND);

	int32_t ret = (int32_t)std::floor(maxValue);
	if(maxDamage)
	{
		player->sendCritical();
		return -ret;
	}

	return -random_range(0, ret, DISTRO_NORMAL);
}
