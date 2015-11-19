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

load("/data/general/npcs/orc.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC", define_as = "UKRUK",
	unique = true,
	name = "Ukruk the Fierce",
	kr_name = "난폭한 자, 우크룩",
	faction = "orc-pride",
	color=colors.VIOLET,
	desc = [[아주 비열하고 사악해보이는, 못생긴 오크입니다. 아무리 봐도 그는 무언가 찾고 있는 것 같으며, 그의 방패에는 처음 보는 문양이 그려져 있습니다.]],
	level_range = {30, nil}, exp_worth = 2,
	max_life = 1500, life_rating = 18, fixed_rating = true,
	rank = 4,
	size_category = 3,
	infravision = 10,
	move_others=true,

	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	combat_spellresist = 70,
	combat_mentalresist = 70,
	combat_physresist = 70,
	see_invisible = 38,

	resolvers.equip{
		{type="weapon", subtype="longsword", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="shield", force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drop_randart{},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="UKRUK_NOTE"} },

	resolvers.talents{
		[Talents.T_WEAPONS_MASTERY]=5, [Talents.T_ASSAULT]=5, [Talents.T_OVERPOWER]=5, [Talents.T_RUSH]=5,
	},
	combat_atk = 1000,

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(6, {}),

	on_die = function(self, who)
		world:gainAchievement("KILL_UKRUK", game.player)
		local q = game.player:resolveSource():hasQuest("staff-absorption")
		if q then q:killed_ukruk(game.player:resolveSource()) end
	end,
}
