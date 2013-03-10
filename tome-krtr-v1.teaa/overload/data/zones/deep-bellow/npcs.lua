-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

require "engine.krtrUtils"

load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/horror-corrupted.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_CORRUPTED_HORROR", define_as = "THE_MOUTH",
	unique = true,
	name = "The Mouth", tint=colors.PURPLE,
	kr_display_name = "그 입",
	color=colors.VIOLET,
	desc = [["울림 속에서, 그것은 모든 것을 삼켜버린다."]],
	killer_message = "그리고 찍찍거리는 박쥐로 되살아났습니다.", --lore 보고 제대로 수정 필요
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_corrupted_the_mouth.png", display_h=2, display_y=-1}}},
	level_range = {7, nil}, exp_worth = 2,
	max_life = 10000, life_rating = 0, fixed_rating = true,
	stats = { str=10, dex=10, cun=12, mag=20, con=10 },
	rank = 4,
	tier1 = true,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	never_move = 1,

	-- Bad idea to melee it
	combat = {dam=100, atk=1000, apr=1000, physcrit=1000},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="TOOTH_MOUTH", random_art_replace={chance=35}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_CALL_OF_AMAKTHEL]=1,
		[Talents.T_DRAIN]=1,
	},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1 },
	ai_tactic = resolvers.tactic"ranged",

	on_takehit = function(self, value)
		if value <= 500 then
			game.logSeen(self, "#CRIMSON#%s 무적이지만, 다른 방법을 이용하면 죽일 수 있을 것 같습니다!", (self.kr_display_name or self.name):capitalize():addJosa("는"))
			return 0
		end
		return value
	end,

	-- Invoke crawlers every few turns
	on_act = function(self)
		if not self.ai_target.actor or self.ai_target.actor.dead then return end
		if not self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y) then return end

		self.last_crawler = self.last_crawler or (game.turn - 100)
		if game.turn - self.last_crawler >= 100 then -- Summon a crawler every 10 turns
			self:forceUseTalent(self.T_GIFT_OF_AMAKTHEL, {no_energy=true})
			self.last_crawler = game.turn
		end
	end,

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("deep-bellow", engine.Quest.COMPLETED)
		game.state:activateBackupGuardian("ABOMINATION", 3, 35, "드워프들 사이에서, '깊은 울림' 속에 혐오생물이 있다는 속삭임을 들은 적이 있어.")
	end,
}

newEntity{ base="BASE_NPC_CORRUPTED_HORROR", define_as = "SLIMY_CRAWLER",
	name = "slimy crawler",
	kr_display_name = "기어다니는, 형체 없는 자",
	color = colors.GREEN,
	desc = [[이 구역질 나는... 어떤 존재는 엄청난 속도로 바닥을 기어다니며 당신에게 접근하고 있습니다.
'그 입' 의 소화 기관에서 나온 것으로 보입니다.]],
	level_range = {4, nil}, exp_worth = 0,
	max_life = 80, life_rating = 10, fixed_rating = true,
	movement_speed = 3,
	size_category = 1,

	combat = { dam=resolvers.mbonus(25, 15), damtype=DamageType.SLIME, dammod={str=1} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=4, ai_move="move_astar" },

	resolvers.talents{
		[Talents.T_KNOCKBACK]=1,
	},

	on_act = function(self)
		local tgts = {}
		for i, actor in ipairs(game.party.m_list) do
			if not actor.dead then tgts[#tgts+1] = actor end
		end
		self:setTarget(rng.table(tgts))

		if self.summoner.dead then
			self:die()
			game.logSeen(self, "#AQUAMARINE#'그 입' 의 죽음으로, '그 입' 에서 나왔던 것들 역시 생명이 다해 땅에 쓰러집니다!")
		end
	end,

	on_die = function(self, who)
		if self.summoner and not self.summoner.dead then
			game.logSeen(self, "#AQUAMARINE#%s 쓰러지자, %s도 고통에 몸부림칩니다!", (self.kr_display_name or self.name):capitalize():addJosa("가"), (self.summoner.kr_display_name or self.summoner.name))
			self.summoner.no_take_hit_achievements = true
			self.summoner:takeHit(1000, who)
			self.summoner.no_take_hit_achievements = nil
		end
	end,
}

newEntity{ base="BASE_NPC_CORRUPTED_HORROR", define_as = "ABOMINATION",
	unique = true,
	allow_infinite_dungeon = true,
	name = "The Abomination",
	kr_display_name = "혐오생물",
	display = "h", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_corrupted_the_abomination.png", display_h=2, display_y=-1}}},
	desc = [[화농이 생긴 살점과 힘줄, 그리고 뼈가 마구 뭉쳐 있는 모양인 이 무시무시한 존재는, 끊임없이 고통에 몸부림치고 있는 것 같습니다. 그의 영역에 침입한 당신을 발견하자, 두 개의 머리가 증오섞인 눈빛으로 당신을 쏘아보기 시작합니다.]],
	level_range = {35, nil}, exp_worth = 3,
	max_life = 350, life_rating = 23, fixed_rating = true,
	life_regen = 30,
	hate_regen = 100,
	negative_regen = 14,
	stats = { str=30, dex=8, cun=10, mag=15, con=20 },
	rank = 4,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,
	blind_immune = 1,
	see_invisible = 30,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET=1 },
	resolvers.equip{
		{type="weapon", subtype="battleaxe", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="boots", defined="WARPED_BOOTS", random_art_replace={chance=75}, forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="massive", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="ADV_LTR_8"} },

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=3,
		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=5},

		[Talents.T_GLOOM]={base=4, every=7, max=6},
		[Talents.T_WEAKNESS]={base=4, every=7, max=6},
		[Talents.T_DISMAY]={base=4, every=7, max=6},

		[Talents.T_HYMN_OF_MOONLIGHT]={base=3, every=7, max=5},
		[Talents.T_STARFALL]={base=3, every=7, max=7},
		[Talents.T_SHADOW_BLAST]={base=3, every=7, max=7},
	},
	resolvers.sustains_at_birth(),

	-- Supposed to drop two notes during the fight, if player has cooldowns to worry about player can snag these then.
	on_takehit = function(self, val)
		if self.life - val < self.max_life * 0.75 and not self.dropped_note6 then
			local n = game.zone:makeEntityByName(game.level, "object", "ADV_LTR_6")
			if n then
				self.dropped_note6 = true
				game.zone:addEntity(game.level, n, "object", self.x, self.y)
				game.logSeen(self, "혐오생물 근처의 바닥에 양피지가 떨어졌습니다.")
			end
		end
		if self.life - val < self.max_life * 0.25 and not self.dropped_note7 then
			local n = game.zone:makeEntityByName(game.level, "object", "ADV_LTR_7")
			if n then
				self.dropped_note7 = true
				game.zone:addEntity(game.level, n, "object", self.x, self.y)
				game.logSeen(self, "혐오생물 근처의 바닥에 양피지가 떨어졌습니다.")
			end
		end
		return val
	end,

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, {}),
}
