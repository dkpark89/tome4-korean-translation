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

load("/data/general/npcs/orc.lua", rarity(0))
load("/data/general/npcs/troll.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

-- The boss of Reknor, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "GOLBUG",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "orc", unique = true,
	faction = "orc-pride",
	name = "Golbug the Destroyer",
	kr_name = "파괴자, 골부그",
	display = "o", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_golbug_the_destroyer.png", display_h=2, display_y=-1}}},
	desc = [[그 혈통이 궁금해질 정도로, 크고 근육질인 오크입니다. 그는 위협적이면서, 또한 교활해 보입니다.]],
	level_range = {28, nil}, exp_worth = 2,
	max_life = 350, life_rating = 16, fixed_rating = true,
	max_stamina = 245,
	rank = 5,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,
	stats = { str=22, dex=19, cun=34, mag=10, con=16 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, HEAD=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="mace", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="shield", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", autoreq=true},
		{type="armor", subtype="massive", force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {type="jewelry", subtype="orb", defined="ORB_MANY_WAYS"} },

	stun_immune = 1,
	see_invisible = 5,

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=4, every=6, max=8},
		[Talents.T_WEAPON_COMBAT]={base=3, every=10, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=3, every=10, max=5},
		[Talents.T_SHIELD_PUMMEL]={base=4, every=5, max=6},
		[Talents.T_RUSH]={base=4, every=5, max=6},
		[Talents.T_RIPOSTE]={base=4, every=5, max=6},
		[Talents.T_BLINDING_SPEED]={base=4, every=5, max=6},
		[Talents.T_OVERPOWER]={base=3, every=5, max=5},
		[Talents.T_ASSAULT]={base=3, every=5, max=5},
		[Talents.T_SHIELD_WALL]={base=3, every=5, max=5},
		[Talents.T_SHIELD_EXPERTISE]={base=2, every=5, max=5},

		[Talents.T_BELLOWING_ROAR]={base=3, every=5, max=5},
		[Talents.T_WING_BUFFET]={base=2, every=5, max=5},
		[Talents.T_FIRE_BREATH]={base=4, every=5, max=7},

		[Talents.T_ICE_CLAW]={base=3, every=5, max=5},
		[Talents.T_ICY_SKIN]={base=4, every=5, max=7},
		[Talents.T_ICE_BREATH]={base=4, every=5, max=7},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(3, "infusion"),

	on_acquire_target = function(self, who)
		-- Doesn't matter who, just assume the player is there
		if not self.has_chatted then
			self.has_chatted = true
			local Chat = require("engine.Chat")
			local chat = Chat.new("golbug-explains", self, game.player)
			chat:invoke()
		end
	end,

	on_die = function(self, who)
		game.state:activateBackupGuardian("LITHFENGEL", 4, 35, "레크놀의 오크들이 아직도 살아있다는 말 들었어? 그들이 레크놀에서 강력한 악마를 찾아냈다고 하던데...", function(gen)
			if gen then require("engine.ui.Dialog"):simpleLongPopup("위험...", "마지막으로 이곳을 봤을 때, 이 동굴은 당신이 죽인 오크의 시체로 어지럽혀져 있었습니다. 하지만 지금은, 훨씬 더 많은 시체가 바닥을 완전히 덮고 있으며 이 까맣게 탄 시체에서는 유황 냄새가 납니다. 동쪽으로 연결된 동굴의 저쪽 끝에서, 뭔가가 희미하게 주황색 빛을 내고 있습니다.", 400) end
		end)

		world:gainAchievement("DESTROYER_BANE", game.player:resolveSource())
		game.player:setQuestStatus("orc-hunt", engine.Quest.DONE)
		game.player:grantQuest("wild-wild-east")

		-- Add the herald, at the end of tick because we might have changed levels (like with a Demon Plane spell)
		game:onTickEnd(function()
			local harno = game.zone:makeEntityByName(game.level, "actor", "HARNO")
			if harno then game.zone:addEntity(game.level, harno, "actor", 0, 13) end
		end)
	end,
}

-- The messenger sent by last-hope
newEntity{ define_as = "HARNO",
	type = "humanoid", subtype = "human", unique = true,
	faction = "allied-kingdoms",
	name = "Harno, Herald of Last Hope",
	kr_name = "마지막 희망의 전령, 하르노",
	display = "@", color=colors.LIGHT_BLUE,
	desc = [[마지막 희망에서 온 전령입니다. 당신을 찾아온 것 같습니다.]],
	global_speed_base = 2,
	level_range = {40, 40}, exp_worth = 0,
	max_life = 150, life_rating = 12,
	rank = 3,
	infravision = 10,
	stats = { str=10, dex=29, cun=43, mag=10, con=10 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, HEAD=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="knife", autoreq=true},
		{type="weapon", subtype="knife", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {type="scroll", subtype="scroll", defined="NOTE_FROM_LAST_HOPE"} },

	stun_immune = 1,
	see_invisible = 100,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_target="target_player", ai_move="move_astar", },
	resolvers.inscriptions(2, {"speed rune", "speed rune"}),

	can_talk = "message-last-hope",
	can_talk_only_once = true,

	on_die = function(self, who)
		game.logPlayer(game.player, "#LIGHT_RED#누군가의 단말마를 들었습니다. '%s, 건네줄 전언이 있소... 으악!'", (game.player.kr_name or game.player.name):capitalize())
		game.player:setQuestStatus("orc-hunt", engine.Quest.DONE, "herald-died")
	end,
}

newEntity{ define_as = "LITHFENGEL", -- Lord of Ash; backup guardian
	allow_infinite_dungeon = true,
	type = "demon", subtype = "major", unique = true,
	name = "Lithfengel",
	kr_name = "리스펜젤",
	display = "U", color=colors.VIOLET,
	desc = [[부패와 쇠퇴를 상징하는 끔찍한 악마로, 장거리 관문의 힘을 흡수하고 있습니다. 황폐의 짐승입니다!]],
	level_range = {35, nil}, exp_worth = 3,
	max_life = 400, life_rating = 25, fixed_rating = true,
	rank = 4,
	size_category = 5,
	infravision = 30,
	-- The artifact he wields drains life a little, so to compensate:
	life_regen = 0.3,
	stats = { str=20, dex=15, cun=25, mag=25, con=20 },
	poison_immune = 1,
	fear_immune = 1,
	instakill_immune = 1,
	no_breath = 1,
	move_others=true,
	demon = 1,

	on_melee_hit = { [DamageType.BLIGHT] = 45, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="waraxe", defined="MALEDICTION", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=4, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="ATHAME_WEST"} },
	resolvers.drops{chance=100, nb=1, {defined="RESONATING_DIAMOND_WEST"} },

	resolvers.talents{
		[Talents.T_ROTTING_DISEASE]={base=5, every=6, max=8},
		[Talents.T_DECREPITUDE_DISEASE]={base=5, every=6, max=8},
		[Talents.T_WEAKNESS_DISEASE]={base=5, every=6, max=8},
		[Talents.T_CATALEPSY]={base=5, every=6, max=8},
		[Talents.T_RUSH]={base=5, every=6, max=8},
		[Talents.T_MORTAL_TERROR]={base=5, every=6, max=8},
		[Talents.T_WEAPON_COMBAT]=5,
		[Talents.T_WEAPONS_MASTERY]={base=3, every=10, max=5},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(3, {}),

	on_die = function(self, who)
		if who.resolveSource and who:resolveSource().player and who:resolveSource():hasQuest("east-portal") then
			require("engine.ui.Dialog"):simpleLongPopup("다시 또 그 곳에", "악마의 몸을 조심스럽게 살펴본 결과, 피의 룬 제례단검과 공명하는 다이아몬드를 발견했습니다. 둘 다 그을음과 피가 묻어있지만, 다른 이상한 점은 없는 것 같습니다.", 400)
		end
	end,
}
