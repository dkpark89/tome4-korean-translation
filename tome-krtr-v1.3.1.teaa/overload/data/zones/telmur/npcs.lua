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

load("/data/general/npcs/skeleton.lua", rarity(0))
load("/data/general/npcs/ghoul.lua", rarity(0))
load("/data/general/npcs/ghost.lua", rarity(4))
load("/data/general/npcs/bone-giant.lua", rarity(3))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "SHADE_OF_TELOS",
	allow_infinite_dungeon = true,
	type = "undead", subtype = "ghost", unique = true,
	name = "The Shade of Telos",
	kr_name = "텔로스의 그림자",
	display = "G", color=colors.VIOLET,
	desc = [[세상 사람들은 텔로스가 이미 죽었으며, 그의 정신은 파괴되었다고 생각합니다. 하지만 그가 오래 머물렀던 이곳에, 그의 힘은 아직도 남아있습니다.]],
	killer_message = "당신은 난폭하게 몸이 찢겨져, 모든 살아있는 것에 대한 그의 분노를 보여주었습니다.",
	level_range = {38, nil}, exp_worth = 3,
	max_life = 250, life_rating = 22, fixed_rating = true,
	rank = 4,
	size_category = 3,
	infravision = 10,
	stats = { str=1, dex=14, cun=34, mag=25, con=10 },

	combat_def = 40, combat_armor = 30,

	undead = 1,
	no_breath = 1,
	stone_immune = 1,
	confusion_immune = 1,
	fear_immune = 1,
	teleport_immune = 0.5,
	disease_immune = 1,
	poison_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	see_invisible = 80,
	move_others=true,

	can_pass = {pass_wall=70},
	resists = {all = 25, [DamageType.COLD] = 100, [DamageType.ACID] = 100},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, },
	resolvers.equip{
		{type="weapon", subtype="staff", defined="TELOS_TOP_HALF", random_art_replace={chance=75}, autoreq=true},
		{type="weapon", subtype="staff", defined="TELOS_BOTTOM_HALF", autoreq=true},
	},
	resolvers.drops{chance=100, nb=4, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_ICE_SHARDS]=5,
		[Talents.T_FREEZE]=5,
		[Talents.T_TIDAL_WAVE]=5,
		[Talents.T_ICE_STORM]=5,
		[Talents.T_UTTERCOLD]=8,
		[Talents.T_FROZEN_GROUND]=5,
		[Talents.T_SHATTER]=5,
		[Talents.T_GLACIAL_VAPOUR]=5,
		[Talents.T_CURSE_OF_IMPOTENCE]=5,
		[Talents.T_VIRULENT_DISEASE]=5,
	},

	autolevel = "caster",
	ai = "tactical", ai_state = { ai_target="target_player", talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(4, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),

	on_die = function(self, who)
		require("engine.ui.Dialog"):simpleLongPopup("다시 또 그 곳에", '그림자가 흩어지자, "확률적 역장의 뒤집힘과 되돌아감" 이라는 제목의 글을 발견했습니다. 당신은 탄넨에게 돌아가기로 했습니다.', 400) 
	end,
}
