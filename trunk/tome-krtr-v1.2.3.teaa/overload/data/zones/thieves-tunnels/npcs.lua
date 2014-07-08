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

load("/data/general/npcs/thieve.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "ASSASSIN_LORD",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.VIOLET,
	name = "Assassin Lord",
	kr_name = "암살단 단장",
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	cant_be_moved = true,

	resolvers.drops{chance=20, nb=1, {} },
	resolvers.equip{
		{type="weapon", subtype="dagger", autoreq=true, force_drop=true, tome_drops="boss"},
		{type="weapon", subtype="dagger", autoreq=true, force_drop=true, tome_drops="boss"},
		{type="armor", subtype="light", autoreq=true, force_drop=true, tome_drops="boss"}
	},
	resolvers.drops{chance=100, nb=2, {type="money"} },

	rank = 4,
	size_category = 3,

	open_door = true,

	autolevel = "rogue",
	ai = "dumb_talented_simple", ai_state = { talent_in=5, },
	stats = { str=8, dex=15, mag=6, cun=15, con=7 },

	resolvers.tmasteries{ ["cunning/stealth"]=1.3, },

	desc = [[이 도둑 무리의 지도자 같습니다. 그의 보이지 않는 수하들을 조심해야 합니다.]],
	level_range = {8, 50}, exp_worth = 1,
	combat_armor = 5, combat_def = 7,
	max_life = resolvers.rngavg(90,100), life_rating = 14,
	resolvers.talents{
		[engine.interface.ActorTalents.T_LETHALITY]={base=3, every=4, max=10},
		[engine.interface.ActorTalents.T_STEALTH]={base=4, every=4, max=10},
		[engine.interface.ActorTalents.T_VILE_POISONS]={base=3, every=4, max=10},
		[engine.interface.ActorTalents.T_VENOMOUS_STRIKE]={base=3, every=4, max=10},
		[engine.interface.ActorTalents.T_SHADOWSTEP]={base=3, every=4, max=10},
		[engine.interface.ActorTalents.T_SHADOW_VEIL]={base=3, every=4, max=10},
		[engine.interface.ActorTalents.T_AMBUSCADE]={base=3, every=4, max=10},
		[engine.interface.ActorTalents.T_EMPOWER_POISONS]={base=3, every=4, max=10},
		[engine.interface.ActorTalents.T_HIDE_IN_PLAIN_SIGHT]={base=3, every=4, max=10},
		[engine.interface.ActorTalents.T_DIRTY_FIGHTING]={base=3, every=4, max=10},
	},
	stamina_regen = 5,
	mana_regen = 6,

	can_talk = "assassin-lord",

	on_die = function(self, who)
		local oe = game.level.map(self.x, self.y, game.level.map.TERRAIN)
		local g = game.zone.grid_list.UP_WILDERNESS
		if oe and oe:attr("temporary") and oe.old_feat then 
			oe.old_feat = g
		else
			game.level.map(self.x, self.y, game.level.map.TERRAIN, g)
		end
		game.logSeen(who, "암살자가 죽자, 마법의 장막이 사라지고 계단이 나타납니다.")
		for uid, e in pairs(game.level.entities) do
			if e.is_merchant and not e.dead then
				e.can_talk = "lost-merchant"
				break
			end
		end
	end,

	is_assassin_lord = true,
}

newEntity{ define_as = "MERCHANT",
	type = "humanoid", subtype = "human",
	display = "@", color=colors.UMBER,
	name = "Lost Merchant",
	kr_name = "길 잃은 상인",
	size_category = 3,
	ai = "simple",
	faction = "victim",
	can_talk = "lost-merchant",
	is_merchant = true,
	cant_be_moved = true,
}
