-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

load("/data/general/npcs/construct.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "ATAMATHON", base = "BASE_NPC_CONSTRUCT",
	allow_infinite_dungeon = true,
	unique = true,
	name = "Atamathon the Giant Golem", image = "npc/atamathon.png",
	kr_name = "거대 골렘, 아타마쏜",
	color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/construct_golem_athamathon_the_giant_golem.png", display_h=2, display_y=-1}}},
	desc = [[이 거대 골렘은 장작더미의 시대에 하플링이 오크에 대항하기 위한 무기로 만들었지만, 포식자 가르쿨에 의해 파괴되었다고 알려져 있습니다. 어떤 어리석은 이가 골렘을 다시 작동시키는 것에 성공했지만, 골렘을 통제하는 것에는 실패하였습니다. 이제 골렘은 오래 전에 이미 죽어버린, 원제작자에게 자신의 분노를 쏟아내려 합니다. 대리석으로 만들어진 몸에 단단한 보라툰으로 관절부위가 연결되었으며, 가장 순수한 루비가 눈으로 사용되었습니다. 12미터가 넘는 높이에서, 격노에 차 빛나는 핏빛 보석이 보입니다.]],
	level_range = {70, nil}, exp_worth = 2,
	max_life = 350, life_rating = 40, fixed_rating = true,
	life_regen = 0,
	stats = { str=35, dex=10, cun=8, mag=30, con=30 },
	rank = 5,
	size_category = 5,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, GEM=4 },
	resolvers.equip{
		{type="weapon", subtype="greatmaul", tome_drops="boss", tome_mod="uvault", forbid_power_source={antimagic=true}, autoreq=true },
		{type="armour", subtype="massive", tome_drops="boss", tome_mod="uvault", forbid_power_source={antimagic=true}, autoreq=true },
	},
	combat_armor = 50,
	combat_def = 30,
	resolvers.drops{chance=100, nb=7, {type="gem"} },
	resolvers.drops{chance=100, nb=2, {name="voratun amulet", ego_chance=-1000} },
	resolvers.drops{chance=100, nb=4, {name="voratun ring", ego_chance=-1000} },
	resolvers.inventory{ inven="GEM",
		{defined="ATAMATHON_RUBY_EYE"},
		{defined="GEM_DIAMOND"},
		{defined="GEM_BLOODSTONE"},
		{defined="GEM_AMETHYST"},
	},

	inc_damage = {all=360},

	no_auto_resists = true,
	resists = {
		all = 80,
	},
	combat_spellresist = 140,
	combat_mentalresist = 180,
	combat_physresist = 140,

	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]={base=6, every=6},
		[Talents.T_WEAPONS_MASTERY]={base=7, every=6},
		[Talents.T_GOLEM_BEAM]={base=8, every=3},
		[Talents.T_GOLEM_ARCANE_PULL]={base=8, every=3},
		[Talents.T_GOLEM_REFLECTIVE_SKIN]={base=8, every=3},
		[Talents.T_GOLEM_MOLTEN_SKIN]={base=8, every=3},
		[Talents.T_GOLEM_KNOCKBACK]={base=8, every=3},
		[Talents.T_GOLEM_CRUSH]={base=8, every=3},
		[Talents.T_GOLEM_POUND]={base=8, every=3},
		[Talents.T_RUSH]={base=8, every=6},
		[Talents.T_IRRESISTIBLE_SUN]=1,
		[Talents.T_GIANT_LEAP]=1,
	},
	resolvers.inscriptions(5, "rune"),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },

	on_die = function()
		world:gainAchievement("ATAMATHON", game.player)
	end
}
