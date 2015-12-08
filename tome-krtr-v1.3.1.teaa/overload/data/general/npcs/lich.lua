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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_LICH",
	type = "undead", subtype = "lich",
	desc = [[가장 강력한 사령술사만이 역생의 과정을 통해 리치로 되살아날 수 있습니다. 이들은 영원히 세상을 떠돌 수밖에 없는 운명이며, 이들의 영역을 침범하는 모든 숨 쉬는 것들에 대해 혐오감을 가지고 있습니다. 불행하지만 당신도 여기에 속합니다.]],
	display = "L", color=colors.WHITE,
	rank = 3, size = 3,

	combat = { dam=resolvers.rngavg(16,27), atk=16, apr=9, damtype=DamageType.DARKSTUN, dammod={mag=0.9} },

	body = { INVEN = 10, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1},
	equipment = resolvers.equip{
		{type="armor", subtype="cloth", ego_chance=75, forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="head", ego_chance=75, forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="feet", ego_chance=75, forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloak", ego_chance=75, forbid_power_source={antimagic=true}, autoreq=true},
		{type="jewelry", subtype="amulet", ego_chance=100, forbid_power_source={antimagic=true}, autoreq=true},
		{type="jewelry", subtype="ring", ego_chance=100, forbid_power_source={antimagic=true}, autoreq=true},
		{type="jewelry", subtype="ring", ego_chance=100, forbid_power_source={antimagic=true}, autoreq=true},
	},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, },
	ai_tactic = resolvers.tactic"ranged",
	stats = { str=8, dex=15, mag=20, wil=18, con=10, cun=18 },

	resists = { [DamageType.NATURE] = 90, [DamageType.FIRE] = 20, [DamageType.MIND] = 100, [DamageType.LIGHT] = -60, [DamageType.DARKNESS] = 95, [DamageType.BLIGHT] = 90 },

	resolvers.inscriptions(3, "rune"),

	instakill_immune = 1,
	stun_immune = 1,
	poison_immune = 1,
	undead = 1,
	blind_immune = 1,
	cut_immune = 1,
	see_invisible = 100,
	infravision = 10,
	silence_immune = 0.7,
	fear_immune = 1,
	negative_regen = 0.4,	-- make their negative energies slowly increase
	mana_regen = 0.3,
	hate_regen = 2,
	open_door = 1,
	combat_spellpower = resolvers.mbonus(20, 10),
	combat_spellcrit = resolvers.mbonus(5, 5),

	resolvers.sustains_at_birth(),
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_LICH",
	name = "lich", color=colors.DARK_BLUE,
	kr_name = "리치",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_lich_lich.png", display_h=2, display_y=-1}}},
	desc=[[영원한 삶의 방법을 발견하였지만, 그 대가로 삶의 즐거움을 잃어버린 존재입니다. 이제 이들이 찾아다니는 것은 무한한 파괴 뿐입니다.]],
	level_range = {35, nil}, exp_worth = 1,
	rarity = 20,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 10, combat_def = 20,

	resolvers.talents{
		[Talents.T_HYMN_OF_SHADOWS]=4,
		[Talents.T_MOONLIGHT_RAY]=5,
		[Talents.T_SHADOW_BLAST]=5,
		[Talents.T_TWILIGHT_SURGE]=3,
		[Talents.T_STARFALL]=3,
		[Talents.T_FREEZE]=3,
		[Talents.T_MANATHRUST]=5,
		[Talents.T_CONGEAL_TIME]=5,
		[Talents.T_CREEPING_DARKNESS]=4,
		[Talents.T_DARK_VISION]=4,
		[Talents.T_DARK_TORRENT]=4,
		[Talents.T_DARK_TENDRILS]=4,
-- Utility spells
		[Talents.T_PHASE_DOOR]=5,
		[Talents.T_TELEPORT]=5,
		[Talents.T_STONE_SKIN]=5,

		[Talents.T_CALL_SHADOWS]=3,
		[Talents.T_FOCUS_SHADOWS]=3,
		[Talents.T_SHADOW_MAGES]=1,
		[Talents.T_SHADOW_WARRIORS]=1,
	},
}

newEntity{ base = "BASE_NPC_LICH",
	name = "ancient lich", color=colors.DARK_RED,
	kr_name = "고대의 리치",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_lich_ancient_lich.png", display_h=2, display_y=-1}}},
	desc=[[나이조차 잊어버린 고대 리치입니다. 살아있는 존재에 대한 증오심과 분노가 가득하며, 자신이 가지지 못한 보물... 생명을 다른 모든 것으로부터 빼앗으려 합니다.]],
	level_range = {40, nil}, exp_worth = 1,
	rarity = 25,
	max_life = resolvers.rngavg(80,90),
	combat_armor = 12, combat_def = 22,

	resolvers.talents{
		[Talents.T_HYMN_OF_SHADOWS]=5,
		[Talents.T_MOONLIGHT_RAY]=5,
		[Talents.T_SHADOW_BLAST]=5,
		[Talents.T_TWILIGHT_SURGE]=5,
		[Talents.T_STARFALL]=5,
		[Talents.T_FREEZE]=5,
		[Talents.T_MANATHRUST]=5,
		[Talents.T_CONGEAL_TIME]=5,
		[Talents.T_CREEPING_DARKNESS]=6,
		[Talents.T_DARK_VISION]=6,
		[Talents.T_DARK_TORRENT]=6,
		[Talents.T_DARK_TENDRILS]=6,
-- Utility spells
		[Talents.T_PHASE_DOOR]=7,
		[Talents.T_TELEPORT]=7,
		[Talents.T_STONE_SKIN]=7,

		[Talents.T_CALL_SHADOWS]=5,
		[Talents.T_FOCUS_SHADOWS]=5,
		[Talents.T_SHADOW_MAGES]=3,
		[Talents.T_SHADOW_WARRIORS]=3,
	},
}

newEntity{ base = "BASE_NPC_LICH",
	name = "archlich", color=colors.SLATE,
	kr_name = "고위 리치",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_lich_archlich.png", display_h=2, display_y=-1}}},
	desc=[[깊은 어둠보다 검은, 어둠과 한몸이나 다름없는 차갑고 잔인한 존재입니다. 오래 전에 스스로의 필멸성을 벗어났지만, 그것을 가능하게 해준 힘을 잊지는 않았습니다. 그 힘은 이 언데드가 모든 살아있는 존재를 파괴하기 위해 사용하는 힘, 악의와 증오심입니다.]],
	level_range = {45, nil}, exp_worth = 1,
	rarity = 30,
	max_life = resolvers.rngavg(100,150),
	combat_armor = 15, combat_def = 25,

	self_resurrect = 1,

	resolvers.talents{
		[Talents.T_HYMN_OF_SHADOWS]=6,
		[Talents.T_MOONLIGHT_RAY]=6,
		[Talents.T_SHADOW_BLAST]=6,
		[Talents.T_TWILIGHT_SURGE]=6,
		[Talents.T_STARFALL]=6,
		[Talents.T_FREEZE]=6,
		[Talents.T_MANATHRUST]=6,
		[Talents.T_CONGEAL_TIME]=6,
		[Talents.T_CREEPING_DARKNESS]=10,
		[Talents.T_DARK_VISION]=10,
		[Talents.T_DARK_TORRENT]=10,
		[Talents.T_DARK_TENDRILS]=10,
-- Utility spells
		[Talents.T_PHASE_DOOR]=10,
		[Talents.T_TELEPORT]=10,
		[Talents.T_STONE_SKIN]=10,

		[Talents.T_CALL_SHADOWS]=8,
		[Talents.T_FOCUS_SHADOWS]=5,
		[Talents.T_SHADOW_MAGES]=5,
		[Talents.T_SHADOW_WARRIORS]=5,
	},
}

newEntity{ base = "BASE_NPC_LICH",
	name = "blood lich", color=colors.LIGHT_RED,
	kr_name = "피의 리치",
	desc=[[끔찍할 정도로 강력한 사령술사가 끓어오르고, 요동치며, 육체에서 벗어난 피로 만들어낸 리치입니다. 이 리치를 공격하는 것은, 공포의 영역에 있는 강에서 스스로 목욕하는 것이나 다름 없을 것입니다.]],
	level_range = {45, nil}, exp_worth = 1,
	rarity = 30,
	max_life = resolvers.rngavg(100,150),
	combat_armor = 0, combat_def = 45,
	on_melee_hit = {[DamageType.BLIGHT]=resolvers.mbonus(25, 30)},

	mana_regen = 100,

	resolvers.talents{
		[Talents.T_FREEZE]={base=5, every=10, max=10},
		[Talents.T_TIDAL_WAVE]={base=3, every=10, max=5},
		[Talents.T_ARCANE_POWER]={base=4, every=5, max = 8},
		[Talents.T_MANATHRUST]={base=4, every=5, max = 10},
		[Talents.T_MANAFLOW]={base=5, every=5, max = 10},
		[Talents.T_GLOOM]={base=4, every=5, max = 12},
		[Talents.T_WEAKNESS]={base=4, every=5, max = 10},
		[Talents.T_DISMAY]={base=5, every=5, max = 10},
		[Talents.T_WILLFUL_STRIKE]={base=5, every=5, max = 10},
		[Talents.T_UNSEEN_FORCE]={base=5, every=5, max = 10},
		[Talents.T_BLOOD_SPRAY]={base=5, every=5, max = 10},
		[Talents.T_BLOOD_GRASP]={base=5, every=5, max = 10},
		[Talents.T_BLOOD_BOIL]={base=5, every=5, max = 10},
		[Talents.T_BLOOD_FURY]={base=5, every=5, max = 10},
-- Utility spells
		[Talents.T_PHASE_DOOR]=10,
		[Talents.T_CALL_SHADOWS]=8,
		[Talents.T_FOCUS_SHADOWS]=5,
		[Talents.T_SHADOW_MAGES]=5,
		[Talents.T_SHADOW_WARRIORS]=5,
	},
}
