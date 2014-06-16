﻿-- ToME - Tales of Maj'Eyal
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

load("/data/general/npcs/bone-giant.lua", rarity(0))
load("/data/general/npcs/ghoul.lua", rarity(5))
load("/data/general/npcs/ghost.lua", rarity(5))
load("/data/general/npcs/skeleton.lua", rarity(5))
load("/data/general/npcs/orc.lua", rarity(3))
load("/data/general/npcs/horror-undead.lua", rarity(1))
load("/data/general/npcs/orc-rak-shor.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC_RAK_SHOR", define_as = "RAK_SHOR",
	allow_infinite_dungeon = true,
	name = "Rak'shor, Grand Necromancer of the Pride", color=colors.VIOLET, unique = true,
	kr_name = "오크 긍지의 위대한 사령술사, 락'쇼르",
	desc = [[검은 로브를 입은, 늙은 오크입니다. 당신을 파괴하기 위해 그의 언데드 군대에게 명령을 내리고 있습니다.]],
	killer_message = "당신은 흉하게 일그러진 언데드 노예로 부활했습니다.",
	level_range = {35, nil}, exp_worth = 1,
	rank = 5,
	max_life = 150, life_rating = 19, fixed_rating = true,
	infravision = 10,
	stats = { str=15, dex=10, cun=12, mag=16, con=14 },
	move_others=true,
	mana_rating = 15,
	soul_regen = 1,

	instakill_immune = 1,
	disease_immune = 1,
	confusion_immune = 1,
	combat_armor = 10, combat_def = 10,

	open_door = true,

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(4, "rune"),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", defined="BLACK_ROBE", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=20, nb=1, {defined="JEWELER_TOME"} },
	resolvers.drops{chance=100, nb=1, {defined="ORB_UNDEATH"} },
	resolvers.drops{chance=100, nb=1, {defined="NOTE_LORE"} },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	summon = {
		{type="undead", number=2, hasxp=false},
	},
	make_escort = {
		{type="undead", no_subescort=true, number=resolvers.mbonus(4, 4)},
	},

	inc_damage = { [DamageType.BLIGHT] = 30 },
	talent_cd_reduction={[Talents.T_SOUL_ROT]=1, [Talents.T_BLOOD_GRASP]=3, },

	resolvers.talents{
		[Talents.T_SUMMON]=1,

		[Talents.T_AURA_MASTERY]=5,
		[Talents.T_CREATE_MINIONS]=3,

		[Talents.T_SOUL_ROT]={base=5, every=6, max=8},
		[Talents.T_BLOOD_GRASP]={base=5, every=6, max=8},
		[Talents.T_CURSE_OF_VULNERABILITY]={base=5, every=6, max=8},
		[Talents.T_BONE_SHIELD]={base=8, every=8, max=11},
		[Talents.T_BLOOD_SPRAY]={base=5, every=6, max=8},
		[Talents.T_BLIGHTED_SUMMONING]=1,
		[Talents.T_ENDLESS_WOES]=1,
	},
	resolvers.sustains_at_birth(),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("orc-pride", engine.Quest.COMPLETED, "rak-shor")
		if not game.player:hasQuest("pre-charred-scar") then
			game.player:grantQuest("pre-charred-scar")
		end
	end,
}

-- Super Undead Uniques!!
-- Sorry Pure, but thinking long term here ;)

--Rotting Titan, undead mass of flesh and stone. Regenerates quickly, moves slow, and hits hard.
newEntity{ base = "BASE_NPC_GHOUL", define_as = "ROTTING_TITAN",
	allow_infinite_dungeon = true,
	name = "Rotting Titan", color={128,64,0}, unique=true,
	kr_name = "썩은 타이탄",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_ghoul_rotting_titan.png", display_h=2, display_y=-1}}},
	desc = [[이 거대한 살점과 암석이 섞인 덩어리는, 비록 그 움직임은 느리지만 걸음을 옮길 때마다 대지가 울려 퍼집니다. 그 몸은 끊임없이 떨리면서 개량되고 있으며, 손발의 끝 부분에 달린 대형 암석은 대형 둔기와 같은 효과를 낼 것 같습니다.]],
	level_range = {45, nil}, exp_worth = 2,
	rarity = 25,
	max_life = resolvers.rngavg(150,200), life_rating = 40,
	combat_armor = 40, combat_def = 10,
	ai_state = { talent_in=2 },
	movement_speed = 0.8,
	size_category=5,

	rank = 3.5,
	life_regen=5,
	max_stamina=1000,
	stamina_regen=20,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",
	autolevel="warriormage",

	on_added_to_level = function(self)
		self.can_pass = {pass_wall=70} --Added after birth so it doesn't spawn inside a wall.
	end,

	stats = { str=40, dex=20, mag=24, con=25 },
	resists = {all = 25, [DamageType.PHYSICAL]=15, [DamageType.ARCANE]=-50, [DamageType.FIRE]=-20},

	resolvers.equip{ {type="weapon", subtype="greatmaul", defined="ROTTING_MAUL", random_art_replace={chance=50}, autoreq=true, force_drop=true}, },

	combat = { dam=resolvers.levelup(80, 1, 2), atk=resolvers.levelup(70, 1, 1), apr=20, dammod={str=1.3}, damtype=engine.DamageType.PHYSICAL, },

	combat_atk=40,
	combat_spellpower=25,
	
	inc_damage = { [DamageType.PHYSICAL] = 15 },
	
	disarm_immune=1, --Since disarming him would be, well, DISARMING him.

	on_move = function(self)
		if rng.percent(35) then
			game.logSeen(self, "%s의 걸음으로 대지가 흔들립니다!", (self.kr_name or self.name):capitalize())
			local tg = {type="ball", range=0, selffire=false, radius=4, no_restrict=true}
			local DamageType = require "engine.DamageType"
			--self:project(tg, self.x, self.y, DamageType.PHYSKNOCKBACK, {dam=24, dist=5})
			self:doQuake(tg, self.x, self.y)
		end
		self:project({type="ball", range=0, selffire=false, radius=1}, self.x, self.y, engine.DamageType.DIG, 1)
	end,
	knockback_immune=1,

	resolvers.talents{
		[Talents.T_STUN]={base=5, every=9, max=7},
		[Talents.T_BITE_POISON]={base=5, every=9, max=7},
		[Talents.T_SKELETON_REASSEMBLE]=4,
		[Talents.T_ROTTING_DISEASE]={base=6, every=9, max=9},
		[Talents.T_DECREPITUDE_DISEASE]={base=3, every=9, max=9},
		[Talents.T_WEAKNESS_DISEASE]={base=3, every=9, max=9},
		[Talents.T_KNOCKBACK]={base=5, every=9, max=9},
		[Talents.T_STRIKE]={base=6, every=5, max = 12},
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max = 6},
		[Talents.T_INNER_POWER]={base=7, every=5, max = 10},
		[Talents.T_EARTHEN_MISSILES]={base=7, every=5, max = 10},
		[Talents.T_CRYSTALLINE_FOCUS]={base=3, every=7, max = 6},
		[Talents.T_EARTHQUAKE]={base=4, every=5, max = 6},
		[Talents.T_ONSLAUGHT]={base=3, every=5, max = 6},
		[Talents.T_BATTLE_CALL]={base=4, every=5, max = 6},
	},
	resolvers.sustains_at_birth(),
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
}

--Glacial Legion, icy fused soul. Leaves trails that freeze any who try to pass over them.
newEntity{ base = "BASE_NPC_GHOST", define_as = "GLACIAL_LEGION",
	allow_infinite_dungeon = true,
	name = "Glacial Legion", color=colors.BLUE, unique=true,
	kr_name = "빙하의 군단",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_ghost_glacial_legion.png", display_h=2, display_y=-1}}},
	desc = [[얼어붙은 피의 오브 주변에서 부유하고 있으며, 그 형체가 계속 변하고 있는 거대한 에테르 덩어리입니다. 그 아래에 있는 바닥의 물 웅덩이가 얼어붙고 있습니다.]],
	level_range = {45, nil}, exp_worth = 2,
	rarity = 25,
	size_category=5,
	rank = 3.5,
	max_life = resolvers.rngavg(90,100), life_rating = 18,
	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, },
	ai_tactic = resolvers.tactic"ranged",
	stats = { str=13, dex=15, mag=45, con=14 },
	combat_spellpower = 100,

	resists = {all = -10, [DamageType.FIRE] = -100, [DamageType.LIGHT] = 30, [DamageType.COLD] = 100},
	combat_armor = 0, combat_def = resolvers.mbonus(10, 10),
	--stealth = resolvers.mbonus(40, 10),

	combat = { dam=50, atk=90, apr=100, dammod={mag=1.1} },
	melee_project = {[DamageType.COLD]=resolvers.mbonus(15, 25)},
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	
	inc_damage = { [DamageType.COLD] = 25 },

	on_move = function(self)
		local DamageType = require "engine.DamageType"
		local duration = 9
		local radius = 0
		local dam = 100
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			engine.DamageType.ICE, dam,
			radius,
			5, nil,
			engine.MapEffect.new{color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/ice_effect.png"},
			function(e)
				e.radius = e.radius 
				return true
			end,
			false
		)
	end,

	resolvers.talents{
		[Talents.T_PHASE_DOOR]=5,
		[Talents.T_FREEZE]={base=5, every=4, max=10},
		[Talents.T_ICE_STORM]={base=4, every=6, max=8},
		[Talents.T_ICE_SHARDS]={base=5, every=5, max=9},
		[Talents.T_SHATTER]={base=3, every=6, max=8},
		[Talents.T_UTTERCOLD]={base=3, every=7, max = 5},
		[Talents.T_FROZEN_GROUND]={base=4, every=6, max = 6},
		[Talents.T_CHILL_OF_THE_TOMB]={base=5, every=5, max=10},
		[Talents.T_SPELLCRAFT]={base=3, every=7, max=8},
		--[Talents.T_MANAFLOW]={base=5, every=4, max = 12},
		[Talents.T_FROST_HANDS]={base=3, every=7, max=8},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="GLACIAL_CLOAK", random_art_replace={chance=50}} },
}

--Heavy Sentinel, flaming bone giant.
newEntity{ base = "BASE_NPC_BONE_GIANT", define_as = "HEAVY_SENTINEL",
	allow_infinite_dungeon = true,
	name = "Heavy Sentinel", color=colors.ORANGE, unique=true,
	kr_name = "육중한 파수꾼",
	desc = [[셀 수 없을 많큼 많은 존재들의 뼈로 만들어진, 아주 거대한 언데드입니다. 흉부 안쪽에서부터 불꽃의 기운이 명렬히 피어오르고 있습니다.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_giant_heavy_sentinel.png", display_h=2, display_y=-1}}},
	level_range = {45, nil}, exp_worth = 2,
	rarity = 25,
	rank = 3.5,
	ai = "tactical",
	size=5,
	max_life = resolvers.rngavg(110,125),
	combat_armor = 20, combat_def = 35,
	life_rating = 28,
	
	combat_atk = 60,
	combat_spellpower=35,
	
	stats = { str=28, dex=60, mag=20, con=20 },
	
	combat = { dam=resolvers.levelup(60, 1, 2), atk=resolvers.levelup(110, 1, 1), apr=20, dammod={str=1.2}, damtype=engine.DamageType.FIRE, convert_damage={[engine.DamageType.PHYSICAL]=50}},
	
	melee_project = {[DamageType.FIRE]=resolvers.mbonus(15, 25)},
	on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(15, 5)},
	autolevel = "warriormage",
	resists = {all = 10, [DamageType.FIRE]=100, [DamageType.COLD]=-75},
	resolvers.talents{
		[Talents.T_BONE_ARMOUR]={base=5, every=10, max=7},
		[Talents.T_STUN]={base=3, every=10, max=5},
		[Talents.T_SKELETON_REASSEMBLE]=5,
		[Talents.T_ARCANE_POWER]={base=3, every=3, max = 6},
		[Talents.T_FLAME]={base=3, every=4, max = 8},
		[Talents.T_FLAMESHOCK]={base=3, every=6, max = 7},
		[Talents.T_INFERNO]={base=2, every=5, max = 6},
		[Talents.T_BURNING_WAKE]={base=1, every=4, max = 5},
		[Talents.T_WILDFIRE]={base=3, every=7, max=5},
		[Talents.T_CLEANSING_FLAMES]={base=2, every=6, max = 5},
		[Talents.T_ARCANE_COMBAT]=3,
		[Talents.T_SPELLCRAFT]={base=3, every=7, max=7},
		[Talents.T_FIERY_HANDS]={base=3, every=7, max=7},
	},
	resolvers.sustains_at_birth(),
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="ARMOR_MOLTEN", random_art_replace={chance=50}} },
}

-- Arch Zephyr, Vampiric Storm Lord. Wields a bow and lightning magic with equal effectiveness, and moves quickly.
newEntity{ base = "BASE_NPC_VAMPIRE", unique=true, define_as="ARCH_ZEPHYR",
	allow_infinite_dungeon = true,
	name = "Arch Zephyr", color=colors.BLUE,
	kr_name = "우두머리 제피르",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_vampire_arch_zephyr.png", display_h=2, display_y=-1}}},
	desc=[[이 고대 흡혈귀의 로브 아래로는 강렬한 바람이 굽이치고 있으며, 번개의 화살이 그를 언제나 따라다닙니다. 손에는 전기가 흐르는 활을 쥐고 있습니다.]],
	level_range = {45, nil}, exp_worth = 1,
	rarity = 25,
	autolevel="warriormage",
	stats = { str=24, dex=40, mag=24, con=20 },
	max_life = resolvers.rngavg(100,120), life_rating=25,
	combat_armor = 15, combat_def = 15,
	rank = 3.5,
	mana_regen = 20, --Maintain Thunderstorm
	
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },

	movement_speed=1.75,
	
	combat_atk = 120,
	combat_spellpower = 60,
	
	ranged_project = {[DamageType.LIGHTNING] = resolvers.mbonus(30, 30)},

	ai = "tactical", ai_state = { talent_in=3, },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.equip{ {type="weapon", subtype="longbow", defined="STORM_FURY", random_art_replace={chance=50}, autoreq=true, force_drop=true}, {type="ammo", subtype="arrow", autoreq=true} },

	resists = { [DamageType.LIGHTNING] = 100, [DamageType.PHYSICAL] = -20, [DamageType.LIGHT] = 30,  },
	resolvers.talents{
		[Talents.T_LIGHTNING]={base=4, every=4, max=10},
		[Talents.T_CHAIN_LIGHTNING]={base=3, every=5, max=7},
		[Talents.T_BLUR_SIGHT]=8,
		[Talents.T_PHANTASMAL_SHIELD]=8,
		[Talents.T_FEATHER_WIND]={base=3, every=4, max=10},
		[Talents.T_THUNDERSTORM]={base=3, every=6, max=8},
		[Talents.T_NOVA]={base=3, every=6, max=8},
		[Talents.T_SHOCK]={base=3, every=6, max=8},
		[Talents.T_TEMPEST]={base=3, every=7, max=6},
		[Talents.T_HURRICANE]={base=2, every=7, max=4},

		[Talents.T_SHOOT]=1, -- If possible, add talent that lets it temporarily fire lightning instead of arrows.
		[Talents.T_RELOAD]=1,
		[Talents.T_BOW_MASTERY]={base=4, every=10},
		[Talents.T_DUAL_ARROWS]={base=3, every=6, max=8},
		[Talents.T_PINNING_SHOT]={base=2, every=6, max=4},
		[Talents.T_CRIPPLING_SHOT]={base=2, every=6, max=7},
		[Talents.T_STEADY_SHOT]={base=4, every=5, max=10},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
}

-- The Void Spectre, the Aether Wight. Minor talents in all elements, but arcane through and through.
newEntity{ base = "BASE_NPC_WIGHT",
	allow_infinite_dungeon = true,
	name = "Void Spectre", color=colors.RED, unique=true,
	kr_name = "공허의 유령",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_wight_void_spectre.png", display_h=2, display_y=-1}}},
	desc=[[이 에테르 형상 주변의 대기에서, 강렬한 마법 에너지가 소용돌이 칩니다.]],
	level_range = {45, nil}, exp_worth = 2,
	life_rating=16,
	rarity = 25,
	rank = 3.5,
	max_life = resolvers.rngavg(200,300),
	max_mana = resolvers.rngavg(800,1200),
	mana_regen = 100, --RAW ARCANE POWER
	combat_armor = 12, combat_def = 30, combat_atk=30,
	combat_spellpower = resolvers.mbonus(90, 30),
	
	arcane_cooldown_divide = 4, --Aether Avatar ++
	inc_damage = { [DamageType.ARCANE] = 30 },
	
	combat = { dam=resolvers.mbonus(40, 20), atk=20, apr=15, damtype=DamageType.ARCANE },
	
	resists = { [DamageType.COLD] = 30, [DamageType.FIRE] = 30, [DamageType.LIGHTNING] = 30, [DamageType.PHYSICAL] = 0, [DamageType.LIGHT] = 0, [DamageType.ARCANE] = 100},

	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",
	resolvers.talents{ [Talents.T_FLAMESHOCK]={base=3, every=5, max=7}, [Talents.T_LIGHTNING]={base=4, every=5, max=8}, [Talents.T_GLACIAL_VAPOUR]={base=3, every=5, max=7}, [Talents.T_STRIKE]={base=3, every=5, max=7},
		[Talents.T_ARCANE_POWER]={base=6, every=2, max=12},
		[Talents.T_MANATHRUST]={base=6, every=4, max=10},
		[Talents.T_ARCANE_VORTEX]={base=4, every=4, max=7},
		[Talents.T_SPELLCRAFT]=5,
		[Talents.T_AETHER_BEAM]={base=6, every=7, max=9},
		[Talents.T_AETHER_BREACH]={base=4, every=6, max=8},
		[Talents.T_HEAL]={base=3, every=6, max=6},
		[Talents.T_SHIELDING]={base=3, every=6, max=6},
		[Talents.T_ARCANE_SHIELD]={base=3, every=5, max=5},
		[Talents.T_PURE_AETHER]={base=3, every=7, max=5},
		[Talents.T_PHASE_DOOR]=10,
	},
	resolvers.sustains_at_birth(),
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="AETHER_RING", random_art_replace={chance=50}} },
}
