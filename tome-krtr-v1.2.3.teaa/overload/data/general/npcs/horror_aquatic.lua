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

-- last updated:  10:46 AM 2/3/2010

require "engine.krtrUtils"

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_HORROR_AQUATIC",
	type = "horror", subtype = "aquatic",
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

	no_breath = 1,
	fear_immune = 1,

	on_die = function(self)
		local g = game.zone.grid_list.WATER_FLOOR_BUBBLE
		if not g then return end
		for i = self.x-1, self.x+1 do for j = self.y-1, self.y+1 do
			if rng.percent(65) and game.level.map:isBound(i, j) then
				local og = game.level.map(i, j, engine.Map.TERRAIN)
				if og and not og.special and not og.change_level and og.type == "floor" and og.subtype == "underwater" then
					local ng = g:clone()
					ng:resolve() ng:resolve(nil, true)
					game.zone:addEntity(game.level, ng, "terrain", i, j)
				end
			end
		end end
		game.logSeen(self, "#LIGHT_BLUE#%s 거대한 공기 방울로 폭발하였습니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
	end,
}

newEntity{ base = "BASE_NPC_HORROR_AQUATIC",
	name = "entrenched horror", color=colors.DARK_GREY,
	kr_name = "견고한 공포",
	desc ="돌로 이루어진 거대한 구조물로, 맥박하며 그 형체를 조금씩 바꾸고 있습니다. 길고 가는 수많은 촉수가 근처의 물가에서 먹이를 찾고 있습니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_aquatic_entrenched_horror.png", display_h=2, display_y=-1}}},
	level_range = {15, nil}, exp_worth = 1,
	rarity = 3,
	rank = 3,
	size_category = 4,
	autolevel = "caster",
	combat_armor = 40, combat_def = 15,
	mana_regen=1,
	max_life=400,
	combat = {dam=resolvers.levelup(resolvers.mbonus(25, 15), 1, 1.1), apr=0, atk=resolvers.mbonus(30, 15), dammod={mag=0.6}},

	never_move = 1,

	resists = {all = 20,},

	resolvers.talents{
		[Talents.T_DIG]={base=2, every=6, max=7},
		[Talents.T_EARTHEN_MISSILES]={base=2, every=6, max=7},
		[Talents.T_EARTHQUAKE]={base=2, every=6, max=7},
	},
	
	talent_cd_reduction = {all=1},
	
	resolvers.drops{chance=100, nb=1, {type="gem"} },
}

newEntity{ base = "BASE_NPC_HORROR_AQUATIC",
	name = "swarming horror", color=colors.GREY,
	kr_name = "군집의 공포",
	desc ="물고기를 닮은 작은 존재로, 변덕스럽게 움직이고 있습니다. 언제나 같은 종류들끼리 뭉쳐다닙니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_aquatic_swarming_horror.png", display_h=2, display_y=-1}}},
	level_range = {10, nil}, exp_worth = 1,
	rarity = 2,
	hive_swarm_rarity = 1,
	rank=1,
	autolevel = "zerker",
	combat_armor = 10, combat_def = 10,
	life_rating=6,
	combat = { dam=5, atk=15, apr=20, dammod={str=0.6}, damtype=DamageType.PHYSICAL},
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex",},
	
	resolvers.talents{
		[Talents.T_BLINDSIDE]={base=1, every=6, max=8},
	},

	make_escort = {
		{type="horror", subtype="aquatic", name="swarming horror", number=6, no_subescort=true},
	},
}

newEntity{ base = "BASE_NPC_HORROR_AQUATIC",
	name = "ravenous horror", color=colors.GREY,
	kr_name = "굶주림의 공포",
	desc ="위협적인 액체가 이빨에서 흘러내리는, 날렵한 괴물입니다. 물 위를 미끄러지듯 움직이며 당신에게 다가오고 있으며, 회전하는 지느러미가 물 밖에 돌출된 상태입니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_aquatic_ravenous_horror.png", display_h=2, display_y=-1}}},
	level_range = {10, nil}, exp_worth = 1,
	rarity = 2,
	autolevel = "warriormage",
	combat_armor = 10, combat_def = 10,
	life_rating=12,
	combat = { dam=24, atk=15, apr=20, dammod={str=0.8}, damtype=DamageType.DRAINLIFE},
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex",},
	
	resolvers.talents{
		[Talents.T_BLOOD_LOCK]={base=3, every=6, max=8},
		[Talents.T_BLOOD_GRASP]={base=3, every=6, max=8},
		[Talents.T_DRAIN]={base=3, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_HORROR_AQUATIC",
	name = "boiling horror", color=colors.BLUE,
	kr_name = "끓는 물의 공포",
	desc ="강렬한 열에 의해, 그 주변에 물거품이 일어나고 있습니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_aquatic_boiling_horror.png", display_h=2, display_y=-1}}},
	level_range = {14, nil}, exp_worth = 1,
	rarity = 4,
	autolevel = "caster",
	combat_armor = 4, combat_def = 24,
	combat = { dam=5, atk=15, apr=20, dammod={mag=0.6}, damtype=DamageType.FIRE},
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1.5, },
	lite = 1,

	resists = {[DamageType.COLD] = 30, [DamageType.FIRE] = 30},

	resolvers.talents{
		[Talents.T_FIREFLASH]={base=1, every=6, max=8},
		[Talents.T_FLAME]={base=3, every=6, max=10},
		[Talents.T_THERMAL_AURA]={base=3, every=6, max=8},
		
		[Talents.T_WATER_BOLT]={base=5, every=6, max=11},
		[Talents.T_BLASTWAVE]={base=2, every=6, max=7},
		
		[Talents.T_BURNING_WAKE]={base=3, every=6, max=10},
	},

	resolvers.sustains_at_birth(),

}

newEntity{ base = "BASE_NPC_HORROR_AQUATIC",
	name = "swarm hive", color=colors.BLACK,
	kr_name = "군집체",
	desc ="맥박하는 거대한 살덩어리로, 그 구멍에서는 작은 괴물들이 부글거리며 튀어나오고 있습니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_aquatic_swarm_hive.png", display_h=2, display_y=-1}}},
	level_range = {15, nil}, exp_worth = 1,
	rarity = 6,
	rank = 3,
	size_category = 5,
	autolevel = "wildcaster",
	combat_armor = 40, combat_def = 15,
	hate_regen=1,
	max_life=320,
	combat = {dam=resolvers.levelup(resolvers.mbonus(25, 15), 1, 1.1), apr=0, atk=resolvers.mbonus(30, 15), dammod={mag=1}},
	ai = "tactical",

	never_move = 1,

	resists = {all = 20,},
	
	summon = {{type="horror", subtype="aquatic", name="swarming horror", number=3, special_rarity="hive_swarm_rarity", hasxp=false}, },

	resolvers.talents{
		[Talents.T_SUMMON]=1,
	
		[Talents.T_WILLFUL_STRIKE]={base=2, every=6, max=8},
		[Talents.T_MINDLASH]={base=3, every=5, max=9},
		[Talents.T_BLAST]={base=1, every=7, max=7},
	},	
}

newEntity{ base = "BASE_NPC_HORROR_AQUATIC",
	name = "abyssal horror", color=colors.BLACK,
	kr_name = "심해의 공포",
	desc = "이 심연의 존재는 어둠에 의해 가려진 상태입니다. 당신이 볼 수 있는 것은 수많은 촉수 뒤에 숨겨진 붉은 눈 한 쌍 뿐입니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_aquatic_abyssal_horror.png", display_h=2, display_y=-1}}},
	level_range = {16, nil}, exp_worth = 1,
	rarity = 12, --Scary but rare
	rank = 3,
	size_category = 2,
	autolevel = "caster",
	max_life = resolvers.rngavg(100, 120),
	life_rating = 22,
	hate_regen=4,
	combat_armor = 0, combat_def = 24,

	combat = {
		dam=resolvers.levelup(resolvers.rngavg(40,52), 1, 1.4),
		atk=resolvers.rngavg(25,35), apr=24,
		dammod={mag=0.8, wil=0.2}, physcrit = 12,
		damtype=engine.DamageType.DARKNESS,
	},

	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },

	resists = {[DamageType.DARKNESS] = 50, [DamageType.LIGHT] = -30},

	resolvers.talents{
			[Talents.T_DARK_TORRENT]={base=1, every=5, max=8},
			[Talents.T_CREEPING_DARKNESS]={base=2, every=4, max=10},
			[Talents.T_DARK_VISION]=5,
			[Talents.T_DARK_TENDRILS]={base=3, every=5, max=8},
			
			[Talents.T_ABYSSAL_SHROUD]={base=2, every=8, max=7},
			
			[Talents.T_TENTACLE_GRAB]={base=1, every=5, max=6},
	},
	resolvers.sustains_at_birth(),
}