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
	define_as = "BASE_NPC_HORROR_UNDEAD",
	type = "undead", subtype = "horror",
	display = "h", color=colors.WHITE,
	blood_color = colors.BLUE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },

	stats = { str=20, dex=20, wil=20, mag=20, con=20, cun=20 },
	combat_armor = 5, combat_def = 10,
	combat = { dam=5, atk=10, apr=5, dammod={str=0.6} },
	infravision = 10,
	max_life = resolvers.rngavg(10,20),
	rank = 2,
	size_category = 3,

	blind_immune = 1,
	fear_immune = 1,
	see_invisible = 2,
	undead = 1,
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "necrotic mass", color=colors.DARK_GREY,
	kr_name = "사령의 살덩어리",
	desc ="썩은내를 풍기며 형체가 조금씩 바뀌고 있는 부패한 살덩어리로, 지성이나 이동성은 없는 것 같습니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_horror_necrotic_mass.png", display_h=2, display_y=-1}}},
	level_range = {15, nil}, exp_worth = 1,
	rarity = 4,
	rank = 1,
	size_category = 2, life_rating = 7,
	combat_armor = 0, combat_def = 0,
	max_life=100,
	combat = {dam=resolvers.levelup(resolvers.mbonus(25, 15), 1, 1.1), apr=0, atk=resolvers.mbonus(30, 15), dammod={str=0.6}},

	never_move = 1,
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "necrotic abomination", color=colors.DARK_GREEN,
	kr_name = "사령의 혐오체",
	desc ="썩은내를 풍기는 괴생명체입니다. 찢겨진 살점과 조각난 뼈를 질질 끌면서, 그리고 피와 내장을 흩뿌리면서 당신에게 다가오고 있습니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_horror_necrotic_abomination.png", display_h=2, display_y=-1}}},
	level_range = {30, nil}, exp_worth = 1,
	rarity = 7,
	rank = 3,
	size_category = 4,
	combat_armor = 0, combat_def = 40,
	max_life=400, life_rating=11,
	disease_immune = 1,
	
	combat = {
		dam=resolvers.levelup(resolvers.rngavg(40,45), 1, 1.2),
		atk=resolvers.rngavg(60,80), apr=20,
		dammod={mag=1.3}, physcrit = 10,
		damtype=engine.DamageType.BLIGHT,
	},
	
	autolevel = "caster",
	
	summon = {
		{type="undead", number=4, hasxp=false},
	},
	
	resolvers.talents{
		[Talents.T_VIRULENT_DISEASE]={base=4, every=8, max=6},
		[Talents.T_EPIDEMIC]={base=4, every=8},
		[Talents.T_SOUL_ROT]={base=5, every=10, max=8},
		[Talents.T_CORROSIVE_WORM]={base=5, every=10, max=8},
		[Talents.T_BLIGHTZONE]={base=3, every=10, max=6},
		
		[Talents.T_SPIT_BLIGHT]={base=3, every=10, max=8},
	},
	
	on_die = function(self, who)
		game.logSeen(self, "#VIOLET#사령의 혐오체가 파괴되자, 남아있던 뼈와 살들이 합쳐져 새로운 적이 만들어집니다!")
		self:forceUseTalent(self.T_SUMMON, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true, force_level=1})
	end,
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "bone horror", color=colors.WHITE,
	kr_name = "뼈의 공포",
	desc ="거대한 흉곽의 형태를 한 존재로, 그 중앙에서는 무언가 부서지는 소리가 크게 들리고 있습니다. 다른 부분들이 안에서부터 부서지고 조각나는 동안, 뼈로 이루어진 수많은 손들은 앞으로 뻗은 채, 휘감긴 채, 융합된 채 긴 뼈로 이루어진 기관을 만들어 그 자신을 지탱하고 있습니다. 이 와중에도, 이 존재는 어떻게든 당신을 붙잡으려 하고 있습니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_horror_bone_horror.png", display_h=2, display_y=-1}}},
	level_range = {30, nil}, exp_worth = 1,
	rarity = 7,
	rank = 3,
	size_category = 4,
	combat_armor = 30, combat_def = 0,
	max_life=400, life_rating = 12,
	disease_immune = 1,
	cut_immune = 1,
	
	combat = {
		dam=resolvers.levelup(resolvers.rngavg(60,70), 1, 1.2),
		atk=resolvers.rngavg(60,80), apr=40,
		dammod={mag=1, str=0.5}, physcrit = 12,
		damtype=engine.DamageType.PHYSICALBLEED,
	},
	
	autolevel = "warriormage",
	
	summon = {
		{type="undead", subtype = "skeleton", number=5, hasxp=false},
	},
	
	resolvers.talents{
		[Talents.T_BONE_GRAB]={base=4, every=8, max=10},
		[Talents.T_BONE_NOVA]={base=2, every=8, max=8},
		[Talents.T_BONE_SPEAR]={base=5, every=5, max=12},
		
		[Talents.T_SKULLCRACKER]={base=7, every=15, max=10},
		[Talents.T_THROW_BONES]={base=4, every=10, max=8},
		
		[Talents.T_BONE_SHIELD]={base=6, every=30, max=11},
	},
	
	on_die = function(self, who)
		game.logSeen(self, "#VIOLET#뼈의 공포가 파괴되자, 남아있던 뼛조각들이 합쳐져 새로운 적이 만들어집니다!")
		self:forceUseTalent(self.T_SUMMON, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true, force_level=1})
	end,
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "sanguine horror", color=colors.RED,
	kr_name = "피의 공포",
	desc ="이 맥박하며 형체가 바뀌는 존재는 짙은 핏빛을 띄고 있으며, 그 몸은 맹독성의 진한 피로 이루어져 있는 것 같습니다. 그 표면에서는 불규칙적으로 파동이 일어나, 몸의 어딘가에서 여전히 심장이 뛰고 있음을 보여줍니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_horror_sanguine_horror.png", display_h=2, display_y=-1}}},
	level_range = {30, nil}, exp_worth = 1,
	rarity = 7,
	rank = 3, life_rating = 13,
	size_category = 4,
	combat_armor = 30, combat_def = 0,
	max_life=400,
	stats = { con=50, },
	
	lifesteal=15,
	
	combat = {
		dam=resolvers.levelup(resolvers.rngavg(50,60), 1, 1.2),
		atk=resolvers.rngavg(60,80), apr=20,
		dammod={mag=1.1}, physcrit = 12,
		damtype=engine.DamageType.CORRUPTED_BLOOD,
	},
	
	autolevel = "caster",
	
	summon = {
		{type="undead", subtype = "blood", number=2, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		
		[Talents.T_BLOOD_SPRAY]={base=4, every=6, max = 10},
		[Talents.T_BLOOD_GRASP]={base=3, every=5, max = 9},
		[Talents.T_BLOOD_BOIL]={base=2, every=7, max = 7},
		[Talents.T_BLOOD_FURY]={base=5, every=8, max = 6},
		
		[Talents.T_BLOOD_LOCK]={base=4, every=10, max=8},
		
		[Talents.T_BLOODSPRING]=1, --And to make things interesting...
	},
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_UNDEAD",
	name = "animated blood", color=colors.RED, subtype = "blood",
	kr_name = "움직이는 핏덩어리",
	desc ="이 핏빛 형체는 쉴 새 없이 피를 흘리며, 주변의 땅에 피를 튀기고 있습니다. 스스로 의지를 가진 채 움직이는 것 같습니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_horror_animated_blood.png", display_h=2, display_y=-1}}},
	level_range = {15, nil}, exp_worth = 1,
	rarity = 20, -- Appear alone but rarely.
	rank = 1,
	size_category = 2, life_rating = 7,
	combat_armor = 0, combat_def = 0,
	max_life=100,
	combat = {dam=resolvers.levelup(resolvers.mbonus(25, 15), 1, 1.1), apr=0, atk=resolvers.mbonus(30, 15), dammod={str=0.6}, damtype=engine.DamageType.DRAINLIFE,},
}