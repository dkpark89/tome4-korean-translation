-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

load("/data/general/npcs/faeros.lua", rarity(0))
load("/data/general/npcs/fire_elemental.lua", rarity(0))
load("/data/general/npcs/molten_golem.lua", rarity(0))
load("/data/general/npcs/fire-drake.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SUNWALL_DEFENDER",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.WHITE,
	faction = "sunwall",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 17,
	rank = 2,
	size_category = 3,

	open_door = true,

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },
}

newEntity{ base = "BASE_NPC_SUNWALL_DEFENDER", define_as = "SUN_PALADIN_DEFENDER",
	name = "human sun-paladin", color=colors.GOLD,
	kr_display_name = "태양의 기사",
	desc = [[빛나는 판갑을 입은 인간입니다.]],
	level_range = {70, nil}, exp_worth = 1,
	rank = 3,
	positive_regen = 10,
	life_regen = 5,
	max_life = resolvers.rngavg(140,170),
	resolvers.equip{
		{type="weapon", subtype="mace", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="shield", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="massive", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=3,
		[Talents.T_CHANT_OF_FORTRESS]=5,
		[Talents.T_SEARING_LIGHT]=4,
		[Talents.T_MARTYRDOM]=4,
		[Talents.T_WEAPON_OF_LIGHT]=4,
		[Talents.T_FIREBEAM]=4,
		[Talents.T_WEAPON_COMBAT]=10,
		[Talents.T_HEALING_LIGHT]=4,
	},
	resolvers.inscriptions(1, {}),
	on_added = function(self)
		self.energy.value = game.energy_to_act self:useTalent(self.T_WEAPON_OF_LIGHT)
		self.energy.value = game.energy_to_act self:useTalent(self.T_CHANT_OF_FORTRESS)
	end,
}

newEntity{ base = "BASE_NPC_SUNWALL_DEFENDER", define_as = "SUN_PALADIN_DEFENDER_RODMOUR",
	name = "High Sun-Paladin Rodmour", color=colors.VIOLET,
	kr_display_name = "고위 태양의 기사, 로드모어",
	desc = [[빛나는 판갑을 입은 인간입니다.]],
	level_range = {70, nil}, exp_worth = 1,
	rank = 3,
	positive_regen = 10,
	life_regen = 5,
	max_life = resolvers.rngavg(240,270),
	resolvers.equip{
		{type="weapon", subtype="mace", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="shield", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="massive", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=4,
		[Talents.T_CHANT_OF_FORTRESS]=5,
		[Talents.T_SEARING_LIGHT]=5,
		[Talents.T_MARTYRDOM]=5,
		[Talents.T_WEAPON_OF_LIGHT]=5,
		[Talents.T_FIREBEAM]=5,
		[Talents.T_WEAPON_COMBAT]=10,
		[Talents.T_HEALING_LIGHT]=5,
	},
	resolvers.inscriptions(1, {}),
	on_added = function(self)
		self.energy.value = game.energy_to_act self:useTalent(self.T_WEAPON_OF_LIGHT)
		self.energy.value = game.energy_to_act self:useTalent(self.T_CHANT_OF_FORTRESS)
		self:doEmote("가라, "..game.player.name.."! 이 방어선은 내가 지킨다!", 150)
	end,
}

newEntity{
	define_as = "BASE_NPC_ORC_ATTACKER",
	type = "humanoid", subtype = "orc",
	display = "o", color=colors.UMBER,
	faction = "orc-pride",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	infravision = 10,
	lite = 2,

	life_rating = 11,
	rank = 2,
	size_category = 3,

	open_door = true,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_target="charred_scar_target", talent_in=2, },
	stats = { str=20, dex=8, mag=6, con=16 },
	resolvers.inscriptions(2, {}),
}

newEntity{ base = "BASE_NPC_ORC_ATTACKER", define_as = "ORC_ATTACK",
	name = "orc warrior", color=colors.DARK_RED,
	kr_display_name = "오크 전사",
	desc = [[사나운 오크 병사입니다.]],
	level_range = {42, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(120,140),
	life_rating = 8,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
	},
	combat_armor = 10, combat_def = 10,
	resolvers.talents{
		[Talents.T_SUNDER_ARMOUR]=5,
		[Talents.T_CRUSH]=4,
		[Talents.T_RUSH]=4,
		[Talents.T_WEAPON_COMBAT]=4,
	},
	on_added = function(self)
		game.level.nb_attackers = (game.level.nb_attackers or 0) + 1
	end,
	on_die = function(self)
		game.level.nb_attackers = game.level.nb_attackers - 1
	end,
}


newEntity{
	define_as = "ELANDAR",
	type = "humanoid", subtype = "shalore",
	name = "Elandar",
	kr_display_name = "엘란다르",
	display = "@", color=colors.AQUAMARINE,
	faction = "sorcerers",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_shalore_elandar.png", display_h=2, display_y=-1}}},

	desc = [[앙골웬을 떠난 마법사 중 한 명으로, 이들은 '주술사' 라는 이름을 가진 단체를 동대륙에 세워 서서히 타락을 키워왔습니다. 이제 그들을 멈춰야 합니다.]],
	level_range = {70, nil}, exp_worth = 15,
	max_life = 1000, life_rating = 36, fixed_rating = true,
	max_mana = 10000,
	mana_regen = 10,
	rank = 5,
	size_category = 3,
	stats = { str=40, dex=60, cun=60, mag=30, con=40 },
	inc_damage = {all=-70},
	invulnerable = 1,
	negative_status_effect_immune = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=10, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_FLAME]=5,
		[Talents.T_FREEZE]=5,
		[Talents.T_LIGHTNING]=5,
		[Talents.T_MANATHRUST]=5,
		[Talents.T_INFERNO]=5,
		[Talents.T_FLAMESHOCK]=5,
		[Talents.T_STONE_SKIN]=5,
		[Talents.T_STRIKE]=5,
		[Talents.T_HEAL]=5,
		[Talents.T_REGENERATION]=5,
		[Talents.T_ILLUMINATE]=5,
		[Talents.T_QUICKEN_SPELLS]=5,
		[Talents.T_SPELLCRAFT]=5,
		[Talents.T_ARCANE_POWER]=5,
		[Talents.T_METAFLOW]=5,
		[Talents.T_PHASE_DOOR]=5,
		[Talents.T_ESSENCE_OF_SPEED]=5,
	},
	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar" },

	on_acquire_target = function(self, who)
		self:doEmote("제길, 네놈의 죽음이 잠시 미뤄졌을 뿐이다! 퓔크!", 60)
		game.player:hasQuest("charred-scar"):setStatus(engine.Quest.COMPLETED, "stopped")
		game.player:hasQuest("charred-scar"):start_fyrk()
	end,
}

newEntity{
	define_as = "ARGONIEL",
	type = "humanoid", subtype = "human",
	name = "Argoniel",
	kr_display_name = "아르고니엘",
	display = "@", color=colors.LIGHT_BLUE,
	faction = "sorcerers",
	female = true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_argoniel.png", display_h=2, display_y=-1}}},

	desc = [[앙골웬을 떠난 마법사 중 한 명으로, 이들은 '주술사' 라는 이름을 가진 단체를 동대륙에 세워 서서히 타락을 키워왔습니다. 이제 그들을 멈춰야 합니다.]],
	level_range = {70, nil}, exp_worth = 15,
	max_life = 1000, life_rating = 36, fixed_rating = true,
	max_mana = 10000,
	mana_regen = 10,
	rank = 5,
	size_category = 3,
	stats = { str=40, dex=60, cun=60, mag=30, con=40 },
	inc_damage = {all=-70},
	invulnerable = 1,
	negative_status_effect_immune = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=10, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_FLAME]=5,
		[Talents.T_FREEZE]=5,
		[Talents.T_LIGHTNING]=5,
		[Talents.T_MANATHRUST]=5,
		[Talents.T_INFERNO]=5,
		[Talents.T_FLAMESHOCK]=5,
		[Talents.T_STONE_SKIN]=5,
		[Talents.T_STRIKE]=5,
		[Talents.T_HEAL]=5,
		[Talents.T_REGENERATION]=5,
		[Talents.T_ILLUMINATE]=5,
		[Talents.T_QUICKEN_SPELLS]=5,
		[Talents.T_SPELLCRAFT]=5,
		[Talents.T_ARCANE_POWER]=5,
		[Talents.T_METAFLOW]=5,
		[Talents.T_PHASE_DOOR]=5,
		[Talents.T_ESSENCE_OF_SPEED]=5,
	},
	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar" },
}

newEntity{ base = "BASE_NPC_FAEROS", define_as = "FYRK",
	allow_infinite_dungeon = true,
	name = "Fyrk, Faeros High Guard", color=colors.VIOLET,
	kr_display_name = "고위 패로스 수호자, 퓔크",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/elemental_fire_fyrk__faeros_high_guard.png", display_h=2, display_y=-1}}},
	desc = [[패로스는 높은 지능을 가진 불의 정령으로, 화산 밖에서는 거의 볼 수 없는 정령이기도 합니다. 이 세상의 자연적인 존재는 아닌 것 같습니다.
이 개체는 더 위험해 보이며, 당신을 경멸하는 눈빛으로 쳐다보고 있습니다. 그의 주변에는 불꽃이 소용돌이치고 있습니다.]],
	killer_message = "그리고 숯덩이 조각이 되어, 그의 주인에게 토템의 용도로 쓰이게 되었습니다.",
	level_range = {35, nil}, exp_worth = 2,
	rank = 5,
	max_life = resolvers.rngavg(800,900), life_rating = 20, fixed_rating = true,
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.FIRE] = resolvers.mbonus(30, 10), },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1 },
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(1, {"manasurge rune"}),
	resolvers.inscriptions(3, "rune"),

	resolvers.equip{
		{type="jewelry", subtype="amulet", defined="FIERY_CHOKER", random_art_replace={chance=75}},
	},
	resolvers.drops{chance=20, nb=1, {defined="JEWELER_TOME"} },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_FLAME]={base=4, every=5, max=8},
		[Talents.T_FIERY_HANDS]={base=5, every=5, max=8},
		[Talents.T_FLAMESHOCK]={base=5, every=5, max=8},
		[Talents.T_INFERNO]={base=5, every=5, max=8},
		[Talents.T_KNOCKBACK]={base=5, every=5, max=8},
		[Talents.T_STUN]={base=2, every=5, max=5},
		[Talents.T_WILDFIRE]={base=5, every=5, max=10},
		[Talents.T_BLASTWAVE]={base=4, every=5, max=7},
		[Talents.T_BURNING_WAKE]={base=3, every=5, max=5},
		[Talents.T_CLEANSING_FLAMES]={base=2, every=5, max=5},
		[Talents.T_ELEMENTAL_SURGE]=1,
	},
	resolvers.sustains_at_birth(),

	blind_immune = 1,
	stun_immune = 1,
	diseas_immune = 0.5,
	poison_immune = 0.5,
	instakill_immune = 1,
}
