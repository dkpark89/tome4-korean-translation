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

load("/data/general/npcs/gwelgoroth.lua", function(e) if e.rarity then e.derth_rarity, e.rarity = e.rarity, nil end end)

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_DERTH_TOWN",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.WHITE,
	faction = "allied-kingdoms",
	anger_emote = "@himher@ 잡아라!",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.inscriptions(1, "infusion"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },

	emote_random = resolvers.emote_random{allow_backup_guardian=true},

	on_die = function(self)
		game.zone.unclean_derth_savior = true
	end,
}

newEntity{ base = "BASE_NPC_DERTH_TOWN",
	name = "derth guard", color=colors.LIGHT_UMBER,
	kr_name = "데르스 경비",
	desc = [[엄격해 보이는 경비입니다. 이 경비는 당신이 마을을 어지럽히는 것을 용납하지 않을 것입니다.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_RUSH]=1, [Talents.T_PERFECT_STRIKE]=1, },
}

newEntity{ base = "BASE_NPC_DERTH_TOWN",
	name = "halfling slinger", color=colors.UMBER,
	kr_name = "하플링 투석 전사",
	subtype = "halfling",
	desc = [[이 하플링은 투석구를 가지고 있습니다. 조심하는 편이 좋을 것 같습니다.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	resolvers.talents{ [Talents.T_SHOOT]=1, },
	ai_state = { talent_in=2, },
	autolevel = "slinger",
	resolvers.equip{ {type="weapon", subtype="sling", autoreq=true}, {type="ammo", subtype="shot", autoreq=true} },
}

newEntity{ base = "BASE_NPC_DERTH_TOWN",
	name = "human farmer", color=colors.WHITE,
	kr_name = "인간 농부",
	desc = [[비바람에 익숙한, 인간 농부입니다.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(30,40),
	combat_armor = 2, combat_def = 0,
}

newEntity{ base = "BASE_NPC_DERTH_TOWN",
	name = "halfling gardener", color=colors.WHITE,
	kr_name = "하플링 정원사",
	subtype = "halfling",
	desc = [[이 하플링은 식물을 돌보고 있는 것 같습니다.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(30,40),
}

newEntity{ base = "BASE_NPC_DERTH_TOWN",
	define_as ="ARENA_AGENT",
	name = "Shady cornac man", color=colors.DARK_BLUE, unique = true,
	kr_name = "수상한 코르낙 남자",
	level_range = {1, nil}, exp_worth = 1,
	can_talk = "arena-unlock",
	can_quest = true,
	never_move = 1,
	rarity = false,
	max_life = resolvers.rngavg(70,80),
	seen_by = function(self, who)
		if not game.party:hasMember(who) then return end
		self.seen_by = nil
		self:doEmote("이봐 거기. 잠깐 이리로 와보게나.", 60)
	end,
	on_die = false,
}
