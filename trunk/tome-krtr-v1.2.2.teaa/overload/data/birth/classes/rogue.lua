-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

newBirthDescriptor{
	type = "class",
	name = "Rogue",
	kr_name = "도적 (Rogue)",
	desc = {
		"도적은 속임수의 달인입니다. 적을 암습하거나 치명적인 함정으로 유인하며 싸웁니다.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Rogue = "allow",
			Shadowblade = "allow",
			Marauder = "allow",
			Skirmisher = "allow",
		},
	},
	copy = {
		max_life = 100,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Rogue",
	kr_name = "도적 (Rogue)",
	desc = {
		"도적은 속임수의 달인입니다. 적이 눈치채지 못하게 접근한 뒤, 기습을 가하여 엄청난 피해를 입힐 수 있습니다.",
		"단검을 이용한 쌍수 무장을 선호하며, 함정을 놓거나 탐지하고 해체하는 전문가가 될 수도 있습니다.",
		"가장 중요한 능력치는 민첩과 교활함입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+1, 민첩+3, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+0, 교활함+5",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +0",
	},
	power_source = {technique=true},
	stats = { dex=3, str=1, cun=5, },
	talents_types = {
		["technique/dualweapon-attack"]={true, 0.3},
		["technique/dualweapon-training"]={true, 0.3},
		["technique/combat-techniques-active"]={false, 0.3},
		["technique/combat-techniques-passive"]={false, 0.3},
		["technique/combat-training"]={true, 0.3},
		["technique/field-control"]={false, 0},
		["technique/acrobatics"]={true, 0.3},
		["cunning/stealth"]={true, 0.3},
		["cunning/trapping"]={true, 0.3},
		["cunning/dirty"]={true, 0.3},
		["cunning/lethality"]={true, 0.3},
		["cunning/survival"]={true, 0.3},
		["cunning/scoundrel"]={true, 0.3},
	},
	unlockable_talents_types = {
		["cunning/poisons"]={false, 0.3, "rogue_poisons"},
	},
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_STEALTH] = 1,
		[ActorTalents.T_TRAP_MASTERY] = 1,
		[ActorTalents.T_LETHALITY] = 1,
		[ActorTalents.T_DUAL_STRIKE] = 1,
		[ActorTalents.T_KNIFE_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		equipment = resolvers.equipbirth{ id=true,
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
		resolvers.inventorybirth{ id=true, inven="QS_MAINHAND",
			{type="weapon", subtype="sling", name="rough leather sling", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventorybirth{ id=true, inven="QS_QUIVER",
			{type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Shadowblade",
	kr_name = "그림자 칼잡이 (Shadowblade)",
	desc = {
		"그림자 칼잡이는 강화 주문을 사용하며, 몸을 숨긴 채 적을 단검으로 찔러 죽일 수 있는, 마법에 재능이 있는 도적입니다.",
		"그들의 마법능력은 습득한 것이 아닌 선천적인 능력이기 때문에, 자연적으로 마나를 재생할 수 없으며 회복을 위해서는 다른 수단을 써야 합니다.",
		"환각, 시간 제어, 예지, 전이 마법 학파 등의 주문을 사용하며 능력을 향상시킬 수 있습니다.",
		"가장 중요한 능력치는 민첩, 교활함, 그리고 마법입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+0, 민첩+3, 체격+0",
		"#LIGHT_BLUE# * 마법+3, 의지+0, 교활함+3",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +0",
	},
	power_source = {technique=true, arcane=true},
	stats = { dex=3, mag=3, cun=3, },
	talents_types = {
		["spell/phantasm"]={true, 0},
		["spell/temporal"]={false, 0},
		["spell/divination"]={false, 0},
		["spell/conveyance"]={true, 0},
		["technique/dualweapon-attack"]={true, 0.2},
		["technique/dualweapon-training"]={true, 0.2},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={false, 0.3},
		["technique/combat-training"]={true, 0.2},
		["cunning/stealth"]={false, 0.3},
		["cunning/survival"]={true, 0.1},
		["cunning/lethality"]={true, 0.3},
		["cunning/dirty"]={true, 0.3},
		["cunning/shadow-magic"]={true, 0.3},
		["cunning/ambush"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_DUAL_STRIKE] = 1,
		[ActorTalents.T_SHADOW_COMBAT] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
		[ActorTalents.T_LETHALITY] = 1,
		[ActorTalents.T_KNIFE_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=25, dur=10, mana=620}),
		equipment = resolvers.equipbirth{ id=true,
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Marauder",
	kr_name = "약탈자 (Marauder)",
	locked = function() return profile.mod.allow_build.rogue_marauder end,
	locked_desc = "숨지도 않고, 도망치지도 않겠다. 와서 함께 칼춤을 춰보면 어느 쪽이 약한지 알게 되겠지. 뼈가 부서지고 두개골이 쪼개지는 소리야말로 삶을 충만케 하는 전장의 소리다!",
	desc = {
		"마즈'에이알의 황야는 안전하지 않습니다. 길들여지지 않은 야수와 어슬렁거리는 드레이크도 위험하지만, 정말 위험한 것은 두발로 걷는 존재들입니다. 도둑과 강도, 암살자, 빈틈을 노리는 모험가, 미친 마법사와 마법을 혐오하는 광신도 등, 모두가 안전한 도시를 떠나 여행하는 사람들에게는 위협요소가 됩니다.",
		"이런 혼돈의 도가니 가운데, 속임수보다 힘을 중시하는 도적의 한 부류가 있습니다. 이들은 단련된 기술과 빠른 발, 그리고 완력을 이용해, 적을 찾아내어 가장 빠른 방법으로 없앱니다. 이들은 쌍수 무기를 사용하며, 불리하다면 비열한 전술을 사용하는 것도 주저하지 않습니다.",
		"가장 중요한 능력치는 힘과 민첩, 그리고 교활함입니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+4, 민첩+4, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+0, 교활함+1",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# +0",
	},
	stats = { dex=4, str=4, cun=1, },
	talents_types = {
		["technique/dualweapon-attack"]={true, 0.2},
		["technique/dualweapon-training"]={true, 0.2},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={true, 0.0},
		["technique/combat-training"]={true, 0.3},
		["technique/field-control"]={true, 0.3},
		["technique/battle-tactics"]={false, 0.2},
		["technique/mobility"]={true, 0.3},
		["technique/thuggery"]={true, 0.3},
		["technique/conditioning"]={true, 0.3},
		["technique/bloodthirst"]={false, 0.1},
		["cunning/dirty"]={true, 0.3},
		["cunning/tactical"]={false, 0.2},
		["cunning/survival"]={true, 0.3},
	},
	unlockable_talents_types = {
		["cunning/poisons"]={false, -0.1, "rogue_poisons"},
	},
	talents = {
		[ActorTalents.T_DIRTY_FIGHTING] = 1,
		[ActorTalents.T_SKULLCRACKER] = 1,
		[ActorTalents.T_HACK_N_BACK] = 1,
		[ActorTalents.T_DUAL_STRIKE] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
	},
	copy = {
		equipment = resolvers.equipbirth{ id=true,
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="head", name="iron helm", autoreq=true, ego_chance=-1000},
		},
	},
}

newBirthDescriptor{ --@@ 한글화 필요 #208~217 : locked_desc와 desc 번역
	type = "subclass",
	name = "Skirmisher",
	kr_name = "척후병 (Skirmisher)",
	locked = function() return profile.mod.allow_build.rogue_skirmisher end,
	locked_desc = "Fleet of foot and strong of throw, overwhelming every foe, from afar we counter, strike and thud, in the chaos'd skirmish spilling blood.",
	desc = {
		"While able to take maximum advantage of their sling by using deft movements to avoid and confuse enemies that try to get close, the Skirmisher truly excels when fighting other ranged users.",
		"They have mastered the use of their shield as well as their sling and are nearly impossible to defeat in a standoff.",
		"Their most important stats are: Dexterity and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +4 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +1 Willpower, +4 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	power_source = {technique=true},
	stats = {dex = 4, cun = 4, wil = 1},
	talents_types = {
		-- class
		["technique/skirmisher-slings"]={true, 0.3},
		["technique/buckler-training"]={true, 0.3},
		["cunning/called-shots"]={true, 0.3},
		["technique/tireless-combatant"]={true, 0.3},
		["cunning/trapping"]={false, 0.1},

		-- generic
		["technique/acrobatics"]={true, 0.3},
		["cunning/survival"]={true, 0.3},
		["technique/combat-training"]={true, 0.3},
		["technique/field-control"]={false, 0.1},
	},
	unlockable_talents_types = {
		["cunning/poisons"]={false, 0.2, "rogue_poisons"},
	},
	talents = {
		[ActorTalents.T_SKIRMISHER_VAULT] = 1,
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_SKIRMISHER_KNEECAPPER] = 1,
		[ActorTalents.T_SKIRMISHER_SLING_SUPREMACY] = 1,
		[ActorTalents.T_SKIRMISHER_BUCKLER_EXPERTISE] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		resolvers.equipbirth{
			id=true,
			{type="armor", subtype="light", name="rough leather armour", autoreq=true,ego_chance=-1000},
			{type="weapon", subtype="sling", name="rough leather sling", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=false, ego_chance=-1000, ego_chance=-1000},
			{type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
		},
		resolvers.generic(function(e)
			e.auto_shoot_talent = e.T_SHOOT
		end),
	},
	copy_add = {
		life_rating = 0,
	},
}
