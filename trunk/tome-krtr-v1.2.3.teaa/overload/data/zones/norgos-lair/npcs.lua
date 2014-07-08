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

local Talents = require("engine.interface.ActorTalents")

if not currentZone.is_invaded then
	load("/data/general/npcs/bear.lua", rarity(0))
	load("/data/general/npcs/vermin.lua", rarity(3))
	load("/data/general/npcs/canine.lua", rarity(1))
	load("/data/general/npcs/snake.lua", rarity(0))
	load("/data/general/npcs/plant.lua", rarity(0))

	load("/data/general/npcs/all.lua", rarity(4, 35))
else
	load("/data/general/npcs/bear.lua", rarity(0))
	load("/data/general/npcs/vermin.lua", rarity(3))
	load("/data/general/npcs/canine.lua", rarity(1))
	load("/data/general/npcs/snake.lua", rarity(0))
	load("/data/general/npcs/shivgoroth.lua", function(e)
		if e.rarity and e.level_range then
			e.level_range[1] = e.level_range[1] - 9
			e.start_level = e.start_level - 9
			e.inc_damage = e.inc_damage or {}
			e.inc_damage.all = (e.inc_damage.all or 0) - 40
			e.healing_factor = 0.4
			e.combat_def = math.max(0, (e.combat_def or 0) - 12)
		end
	end)

	load("/data/general/npcs/all.lua", rarity(4, 35))

	newEntity{ base="BASE_NPC_BEAR", define_as = "FROZEN_NORGOS",
		allow_infinite_dungeon = true,
		unique = true,
		name = "Norgos, the Frozen",
		kr_name = "얼어붙은 노르고스",
		display = "q", color=colors.VIOLET,
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/animal_bear_norgos_the_frozen.png", display_h=2, display_y=-1}}},
		desc = [[이 고대의 곰은 숲의 서쪽 지역을 오랫동안 지켜왔었습니다. 하지만 그가 미쳐버린 이후, 이제는 탈로레까지도 공격하고 있습니다.
게다가 이 곰은 이 지역을 침입한 쉬브고로스의 먹이가 된 것 같습니다. 얼어붙은 채 움직이는 이 시체는, 마치 정령에 의해 움직이는 석상인 것 같습니다.]],
		killer_message = "당신은 얼어붙어 고드름이 되었습니다.",
		level_range = {7, nil}, exp_worth = 2,
		max_life = 200, life_rating = 17, fixed_rating = true, life_regen = 0,
		max_stamina = 85,
		max_mana = 1000, mana_regen = 10,
		stats = { str=15, dex=15, cun=8, mag=20, wil=20, con=20 },
		tier1 = true,
		rank = 4,
		size_category = 5,
		infravision = 10,
		instakill_immune = 1,
		move_others=true,
		never_move = 1,

		combat = { dam=resolvers.levelup(17, 1, 0.8), atk=10, apr=9, dammod={str=1.2} },

		resists = { [DamageType.COLD] = 20 },

		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },
		resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

		resolvers.talents{
			[Talents.T_FROST_GRAB]={base=1, every=6, max=6},
			[Talents.T_ICE_STORM]={base=1, every=6, max=6},
		},

		autolevel = "caster",
		ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },

		on_die = function(self, who)
			game.player:resolveSource():setQuestStatus("start-thaloren", engine.Quest.COMPLETED, "norgos")
			game.player:resolveSource():setQuestStatus("start-thaloren", engine.Quest.COMPLETED, "norgos-invaded")
		end,
	}
end

newEntity{ base="BASE_NPC_BEAR", define_as = "NORGOS",
	allow_infinite_dungeon = true,
	unique = true,
	name = "Norgos, the Guardian",
	kr_name = "수호자, 노르고스",
	display = "q", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/animal_bear_norgos_the_guardian.png", display_h=2, display_y=-1}}},
	desc = [[이 고대의 곰은 숲의 서쪽 지역을 오랫동안 지켜왔었습니다. 하지만 그가 미쳐버린 이후, 이제는 탈로레까지도 공격하고 있습니다.]],
	killer_message = "당신은 늑대들의 먹잇감이 되었습니다.",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 200, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=15, cun=8, mag=10, wil=20, con=20 },
	tier1 = true,
	rank = 4,
	size_category = 5,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	combat = { dam=resolvers.levelup(17, 1, 0.8), atk=10, apr=9, dammod={str=1.2} },

	resists = { [DamageType.COLD] = 20 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_STUN]={base=1, every=6, max=6},
	},

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "infusion"),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-thaloren", engine.Quest.COMPLETED, "norgos")
	end,
}
