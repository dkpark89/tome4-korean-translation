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

if not currentZone.is_flooded then
	load("/data/general/npcs/rodent.lua", rarity(5))
	load("/data/general/npcs/vermin.lua", rarity(2))
	load("/data/general/npcs/canine.lua", rarity(0))
	load("/data/general/npcs/troll.lua", rarity(0))
	load("/data/general/npcs/snake.lua", rarity(3))
	load("/data/general/npcs/plant.lua", rarity(0))
	load("/data/general/npcs/swarm.lua", rarity(3))
	load("/data/general/npcs/bear.lua", rarity(2))

	load("/data/general/npcs/all.lua", rarity(4, 35))
else
	load("/data/general/npcs/vermin.lua", rarity(2))
	load("/data/general/npcs/troll.lua", rarity(0))
	load("/data/general/npcs/snake.lua", rarity(3))
	load("/data/general/npcs/plant.lua", rarity(0))
	load("/data/general/npcs/swarm.lua", rarity(3))
	load("/data/general/npcs/bear.lua", rarity(5))
	-- Aquatics but not squids
	load("/data/general/npcs/aquatic_critter.lua", function(e) if e.rarity and e.name and e.name:find("squid") then e.rarity=nil end end)

	load("/data/general/npcs/all.lua", rarity(4, 35))
end

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "TROLL_PROX",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "troll", unique = true,
	name = "Prox the Mighty",
	kr_name = "강력한 자, 프록스",
	display = "T", color=colors.VIOLET, image="npc/giant_troll_prox_the_mighty.png",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_troll_prox_the_mighty.png", display_h=2, display_y=-1}}},
	desc = [[거대한 트롤로, 천천히 움직임에도 불구하고 굉장히 위협적입니다.]],
	killer_message = "당신은 산 채로 먹혔습니다.",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	max_stamina = 85,
	stats = { str=20, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	tier1 = true,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, TOOL=1 },
	resolvers.equip{ {type="weapon", subtype="greatmaul", autoreq=true}, },
	resolvers.equip{ {type="tool", subtype="misc", defined="LUCKY_FOOT", random_art_replace={chance=70}, autoreq=true}, },
	resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_KNOCKBACK]=1,
	},
	resolvers.inscriptions(1, {"movement infusion"}),
	inc_damage = { all = -40 },

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=3, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	-- Drop the note when near death (but before death, so that Kill bill achievement is possible)
	on_takehit = function(self, val)
		if self.life - val < self.max_life * 0.4 then
			local n = game.zone:makeEntityByName(game.level, "object", "PROX_NOTE")
			if n then
				self.on_takehit = nil
				game.zone:addEntity(game.level, n, "object", self.x, self.y)
				game.logSeen(self, "프록스가 잠시 비틀거립니다. 그의 발밑으로 작은 쪽지가 떨어집니다.")
			end
		end
		return val
	end,

	on_die = function(self, who)
		--force the note to drop if it hasn't dropped already (such as if he died via drowning)
		if self.on_takehit then
			local n = game.zone:makeEntityByName(game.level, "object", "PROX_NOTE")
			if n then
				self.on_takehit = nil
				game.zone:addEntity(game.level, n, "object", self.x, self.y)
			end
		end
		game.state:activateBackupGuardian("ALUIN", 2, 35, "...트롤 늪이 더 안전해진 것 같습니다!")
		game.player:resolveSource():setQuestStatus("start-allied", engine.Quest.COMPLETED, "trollmire")
	end,
}

newEntity{ define_as = "TROLL_SHAX",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "troll", unique = true,
	name = "Shax the Slimy",
	kr_name = "끈적이는 샥스",
	display = "T", color=colors.VIOLET, image="npc/giant_troll_prox_the_mighty.png",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_troll_shax_the_slimy.png", display_h=2, display_y=-1}}},
	desc = [[거대한 트롤로, 물 속 생활에 익숙한 것 같습니다.]],
	killer_message = "당신은 산 채로 먹혔습니다.",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	max_stamina = 85,
	stats = { str=20, dex=10, cun=8, mag=25, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	tier1 = true,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, TOOL=1 },
	resolvers.equip{ {type="weapon", subtype="greatmaul", autoreq=true}, },
	resolvers.equip{ {type="tool", subtype="misc", defined="LUCKY_FOOT", random_art_replace={chance=70}, autoreq=true}, },
	resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_WATER_BOLT]=3,
	},
	resolvers.inscriptions(1, {"movement infusion"}),
	inc_damage = { all = -40 },

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=3, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	-- Drop the note when near death (but before death, so that Kill bill achievement is possible)
	on_takehit = function(self, val)
		if self.life - val < self.max_life * 0.4 then
			local n = game.zone:makeEntityByName(game.level, "object", "PROX_NOTE")
			if n then
				self.on_takehit = nil
				game.zone:addEntity(game.level, n, "object", self.x, self.y)
				game.logSeen(self, "샥스가 잠시 비틀거립니다. 그의 발밑으로 작은 쪽지가 떨어집니다.")
			end
		end
		return val
	end,

	on_die = function(self, who)
		--force the note to drop if it hasn't dropped already (such as if he died via drowning)
		if self.on_takehit then
			local n = game.zone:makeEntityByName(game.level, "object", "PROX_NOTE")
			if n then
				self.on_takehit = nil
				game.zone:addEntity(game.level, n, "object", self.x, self.y)
			end
		end
		game.state:activateBackupGuardian("ALUIN", 2, 35, "...트롤 늪이 더 안전해진 것 같습니다!")
		game.player:resolveSource():setQuestStatus("start-allied", engine.Quest.COMPLETED, "trollmire")
		game.player:resolveSource():setQuestStatus("start-allied", engine.Quest.COMPLETED, "trollmire-flooded")
	end,
}

newEntity{ define_as = "TROLL_BILL",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "troll", unique = true,
	name = "Bill the Stone Troll",
	kr_name = "암석 트롤, 빌",
	display = "T", color=colors.VIOLET, image="npc/troll_bill.png",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/troll_bill.png", display_h=2, display_y=-1}}},
	desc = [[갈색의 크고 강하며 하플링 먹는 것을 좋아하는 트롤입니다.
작은 나무를 통째로 꺾어 든 채, 당신을 겨누고 있습니다.
확실히, 이 트롤이 종이에 적혀있던 바로 그 트롤인 것 같습니다.]],
	killer_message = "당신은 음식 재료로 사용되었습니다.",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 250, life_rating = 18, fixed_rating = true,
	max_stamina = 85,
	stats = { str=25, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{ {type="weapon", subtype="greatmaul", defined="GREATMAUL_BILL_TRUNK", random_art_replace={chance=75}, autoreq=true}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="TRANSMO_CHEST"} },

	resolvers.talents{
		[Talents.T_RUSH]=4,
		[Talents.T_KNOCKBACK]=3,
	},
	resolvers.inscriptions(1, {"wild infusion", "heroism infusion"}),

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=3, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("trollmire-treasure", engine.Quest.COMPLETED)
		if who and game:getPlayer(true).level == 1 then
			world:gainAchievement("KILL_BILL", game.player)
		end
	end,
}

newEntity{ define_as = "ALUIN",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "human", unique = true,
	name = "Aluin the Fallen",
	kr_name = "타락한 알루인",
	display = "p", color=colors.VIOLET,
	desc = [[한때 빛나던 그의 갑옷은 무뎌졌으며, 피에 절었습니다. 이 태양의 기사는 절망에 빠져 있습니다.]],
	level_range = {35, nil}, exp_worth = 3,
	max_life = 350, life_rating = 23, fixed_rating = true,
	hate_regen = 100,
	stats = { str=25, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,
	blind_immune = 1,
	see_invisible = 30,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="waraxe", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="shield", defined="SANGUINE_SHIELD", random_art_replace={chance=65}, autoreq=true},
		{type="armor", subtype="massive", force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=5,
		[Talents.T_WEAPON_COMBAT]={base=3, every=10, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=3, every=10, max=5},
		[Talents.T_RUSH]={base=4, every=7, max=6},

		[Talents.T_BLINDSIDE]={base=4, every=7, max=6},
		[Talents.T_GLOOM]={base=4, every=7, max=6},
		[Talents.T_WEAKNESS]={base=4, every=7, max=6},
		[Talents.T_DISMAY]={base=4, every=7, max=6},
		[Talents.T_SANCTUARY]={base=4, every=7, max=6},

		[Talents.T_CHANT_OF_LIGHT]={base=5, every=7, max=7},
		[Talents.T_SEARING_LIGHT]={base=5, every=7, max=7},
		[Talents.T_MARTYRDOM]={base=5, every=7, max=7},
		[Talents.T_BARRIER]={base=5, every=7, max=7},
		[Talents.T_WEAPON_OF_LIGHT]={base=5, every=7, max=7},
		[Talents.T_CRUSADE]={base=8, every=7, max=10},
		[Talents.T_FIREBEAM]={base=7, every=7, max=9},

		[Talents.T_ARCANE_MIGHT] = 1,
		[Talents.T_IRRESISTIBLE_SUN] = 1,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, {}),
}
