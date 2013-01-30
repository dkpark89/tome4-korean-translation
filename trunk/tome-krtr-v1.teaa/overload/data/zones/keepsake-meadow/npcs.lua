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

load("/data/general/npcs/canine.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")
local DamageType = require "engine.DamageType"

newEntity{
	define_as = "BASE_CARAVANEER",
	type = "humanoid", subtype = "human", image="npc/humanoid_human_spectator02.png",
	display = "p", color=colors.DARK_KHAKI,
	faction = "merchant-caravan",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	infravision = 10,
	lite = 1,

	life_rating = 15,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=2, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
	
	emote_random = {chance=10, "무장을!", "괴물이다!", "죽어!", "우릴 죽일순 없을걸!", "우리가 끝을 내겠어!"},
	
	on_die = function(self, who)
		-- wait for all caravanners to die
		for uid, e in pairs(game.level.entities) do
			if not e.dead and e.faction == "merchant-caravan" then return end
		end
		
		game.player:hasQuest("keepsake"):on_caravan_destroyed(who, self)
	end,
}

newEntity{ base = "BASE_CARAVANEER", define_as = "CARAVAN_MERCHANT",
	name = "caravan merchant", color=colors.KHAKI, image="npc/humanoid_human_spectator02.png",
	kr_display_name = "대상 행렬 상인",
	subtype = "human",
	desc = [[대상 형렬의 상인입니다.]],
	level_range = {1, 10}, exp_worth = 1,
	max_life = resolvers.rngavg(40,50), life_rating = 7,
	combat_armor = 0, combat_def = 6,

	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
	},
}

newEntity{ base = "BASE_CARAVANEER", define_as = "CARAVAN_GUARD",
	name = "caravan guard", color=colors.KHAKI, image="npc/humanoid_human_spectator.png",
	kr_display_name = "대상 행렬 경비",
	subtype = "human",
	desc = [[대상 행렬의 경비입니다.]],
	level_range = {1, 15}, exp_worth = 1,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	combat_armor = 0, combat_def = 6,

	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true},
	},
	resolvers.talents{ [Talents.T_SHIELD_PUMMEL]={base=2, every=10, max=6}, },
}

newEntity{ base = "BASE_CARAVANEER", define_as = "CARAVAN_PORTER",
	name = "caravan porter", color=colors.KHAKI, image="npc/humanoid_human_spectator03.png",
	kr_display_name = "대상 행렬 짐꾼",
	subtype = "human",
	desc = [[대상 행렬의 짐꾼입니다.]],
	level_range = {1, 8}, exp_worth = 1,
	max_life = resolvers.rngavg(60,70), life_rating = 8,
	combat_armor = 0, combat_def = 6,

	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
	},
}

newEntity{ base = "BASE_NPC_CANINE", define_as = "WAR_DOG",
	name = "war dog", color=colors.KHAKI, image="npc/canine_dw.png",
	kr_display_name = "전투견",
	desc = [[이 커다란 개는 전투를 위해 키워졌고 훈련받았습니다.]],
	level_range = {15, 30}, exp_worth = 1,
	max_life = resolvers.rngavg(60,100), life_rating = 10,
	combat_armor = 4, combat_def = 7,
	combat = { dam=resolvers.levelup(30, 1, 1), atk=resolvers.levelup(25, 1, 1), apr=15 },
	resolvers.talents{
		[Talents.T_RUSH]=2,
		[Talents.T_GRAPPLING_STANCE]=2,
		[Talents.T_CLINCH]=2,
	},
}

newEntity{ base = "BASE_NPC_CANINE", define_as = "CORRUPTED_WAR_DOG",
	name = "corrupted war dog", color=colors.BLACK, image="npc/canine_dw.png",
	kr_display_name = "타락한 전투견",
	desc = [[이 커다란 개는 전투를 위해 키워졌고 훈련받았습니다. 무언가의 이유로 정상적이지 않은 움직임을 보이고 있습니다.]],
	level_range = {15, 30}, exp_worth = 1,
	rarity = 5, cave_rarity = 5,
	max_life = resolvers.rngavg(60,100),
	combat_armor = 5, combat_def = 7,
	combat = { dam=resolvers.levelup(30, 1, 1), atk=resolvers.levelup(25, 1, 1), apr=15 },
	resolvers.talents{ [Talents.T_RUSH]=2, },
	resolvers.talents{ [Talents.T_GRAPPLING_STANCE]=2, },
	resolvers.talents{ [Talents.T_CLINCH]=2, },
}

newEntity{
	define_as = "BASE_SHADOW",
	type = "undead", subtype = "shadow", image="npc/humanoid_human_spectator02.png",
	display = 'b', color=colors.BLACK,
	faction = "enemies",

	level_range = {15, 30}, exp_worth = 1,
	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	infravision = 10,
	lite = 1,

	life_rating = 15,
	rank = 2,
	size_category = 2,

	open_door = true,

	undead = 1,
	no_breath = 1,
	stone_immune = 1,
	confusion_immune = 1,
	fear_immune = 1,
	teleport_immune = 1,
	disease_immune = 1,
	poison_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	see_invisible = 80,
	resists = { [DamageType.LIGHT] = -100, [DamageType.DARKNESS] = 100 },
	resists_pen = { all=25 },
	
	resolvers.racial(),
	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=2, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
}

newEntity{ base = "BASE_SHADOW", define_as = "SHADOW_CLAW",
	name = "shadow claw", image="npc/shadow-claw.png",
	kr_display_name = "할퀴는 그림자",
	desc = [[거의 사람과 비슷한 모습의 그림자입니다. 허공에 떠올라 헤엄쳐오고 있고, 긴 날카로운 손톱이 뻗어나와 있습니다.]],
	rarity = 5, cave_rarity = 5, vault_rarity = 5,
	
	max_life = resolvers.rngavg(80,100), life_rating = 8,
	stats = { str=15, dex=20, con=8, wil=14, cun=14 },
	combat_armor = 0, combat_def = 10,
	combat = {
		dam=resolvers.levelup(45, 1, 1.2),
		atk=resolvers.levelup(45, 1, 1),
		apr=40,
		dammod={str=0.5,dex=0.5},
	},
	combat_physcrit = 40,
	resolvers.talents{
		[Talents.T_KEEPSAKE_PHASE_DOOR]={base=1, every=10, max=5},
		[Talents.T_KEEPSAKE_BLINDSIDE]={base=1, every=10, max=5},
		[Talents.T_DOMINATE]={base=1, every=10, max=5},
	},
}

newEntity{ base = "BASE_SHADOW", define_as = "SHADOW_STALKER",
	name = "shadow stalker", image="npc/shadow-stalker.png",
	kr_display_name = "괴롭히는 그림자",
	desc = [[거의 사람과 비슷한 모습의 그림자입니다. 교활하게도 조심스레 움직이고, 재빨리 공격합니다.]],
	rarity = 5, cave_rarity = 5, vault_rarity = 5,
	
	max_life = resolvers.rngavg(30,50), life_rating = 5,
	stats = { str=10, dex=20, con=6, wil=14, cun=20 },
	combat_armor = 0, combat_def = 12,
	combat = {
		dam=resolvers.levelup(75, 1, 4),
		atk=resolvers.levelup(75, 1, 1),
		apr=40,
		dammod={str=0.5,dex=0.5},
		damtype=DamageType.POISON
	},
	resolvers.talents{
		[Talents.T_KEEPSAKE_PHASE_DOOR]={base=1, every=10, max=5},
		[Talents.T_KEEPSAKE_BLINDSIDE]={base=1, every=10, max=5},
		[Talents.T_KEEPSAKE_FADE]={base=1, every=10, max=5},
	},
	onTakeHit = function(self, value, src)
		if self:knowTalent(self.T_KEEPSAKE_FADE) and not self:isTalentCoolingDown(self.T_KEEPSAKE_FADE) then
			self:forceUseTalent(self.T_KEEPSAKE_FADE, {ignore_energy=true})
		end
		
		if src and src.x and src.y and math.floor(core.fov.distance(self.x, self.y, src.x, src.y)) <= 1 and self:knowTalent(self.T_KEEPSAKE_PHASEDOOR) and not self:isTalentCoolingDown(self.T_KEEPSAKE_PHASEDOOR) then
			self:forceUseTalent(self.T_KEEPSAKE_PHASEDOOR, {ignore_energy=true})
		end

		return mod.class.Actor.onTakeHit(self, value, src)
	end,
}

newEntity{ base = "BASE_SHADOW", define_as = "SHADOW_CASTER",
	name = "shadow claw", image="npc/shadow-caster.png",
	kr_display_name = "할퀴는 그림자",
	desc = [[거의 사람과 비슷한 모습의 그림자입니다. 의지의 힘에 의해 시간이 흘러 실존하지 않는 형상이 되었습니다.]],
	rarity = 5, cave_rarity = 5, vault_rarity = 5,
	
	max_life = resolvers.rngavg(50,60), life_rating = 6,
	hate = 100, psi = 60,
	stats = { str=10, dex=20, con=6, wil=20, cun=16 },
	combat_armor = 0, combat_def = 10,
	combat = {
		dam=resolvers.levelup(30, 1, 1.2),
		atk=resolvers.levelup(30, 1, 1),
		apr=40,
		dammod={str=0.5,dex=0.5},
	},
	resolvers.talents{
		[Talents.T_KEEPSAKE_PHASE_DOOR]={base=1, every=10, max=5},
		[Talents.T_WILLFUL_STRIKE]={base=1, every=10, max=5},
		[Talents.T_REPROACH]={base=1, every=10, max=5},
		[Talents.T_MIND_SEAR]={base=1, every=10, max=5},
	},
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
}

newEntity{
	define_as = "BASE_BERETHH_COMPANION",
	type = "humanoid", subtype = "thalore",
	color=colors.DARK_GREEN, display = "p", image = "player/thalore_male.png",
	faction = "enemies",
	level_range = {15, 30}, exp_worth = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 1,

	life_rating = 14,
	rank = 2,
	size_category = 3,

	open_door = true,

	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	power_source = {technique=true},
}

newEntity{ base = "BASE_BERETHH_COMPANION", define_as = "BERETHH_WARRIOR",
	name = "Companion Warrior",
	kr_display_name = "동료 전사",
	color=colors.DARK_GREEN, image="npc/humanoid_elenulach_thief.png",
	desc = [[이 엘프는 베레쓰의 동료입니다. 경갑을 입고 장검을 쥐고 있습니다.]],
	
	autolevel = "warrior",
	stats = { str=22, dex=16, mag=6, con=16 },
	max_life = resolvers.rngavg(90,100),
	combat_armor = 3, combat_def = 7,
	
	resolvers.talents{
		[Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5},
		[Talents.T_ASSAULT]={base=3, every=7, max=7},
	},
	ai_state = { talent_in=1, },
	resolvers.inscriptions(1, "infusion"),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="light", autoreq=true}
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_BERETHH_COMPANION", define_as = "BERETHH_ARCHER",
	name = "Companion Archer",
	kr_display_name = "동료 궁수",
	color=colors.GREEN, image="npc/humanoid_elf_elven_archer.png",
	desc = [[이 엘프는 베레쓰의 동료입니다. 경갑을 입고 활을 쥐고 있습니다.]],
	
	autolevel = "archer",
	stats = { str=16, dex=22, mag=6, con=14, cun=14 },
	max_life = resolvers.rngavg(60,70),
	combat_armor = 3, combat_def = 15,
	
	resolvers.talents{
		[Talents.T_BOW_MASTERY]={base=1, every=7, max=5},
		[Talents.T_SHOOT]=1,
	},
	ai_state = { talent_in=1, },
	resolvers.inscriptions(1, "infusion"),
	resolvers.equip{
		{type="weapon", subtype="longbow", autoreq=true},
		{type="ammo", subtype="arrow", autoreq=true},
		{type="armor", subtype="light", autoreq=true}
	},
	resolvers.racial(),
}

newEntity{ define_as="KYLESS",
	name = "Kyless",
	kr_display_name = "킬레스",
	type = "humanoid", subtype = "human",
	color=colors.VIOLET, display = "p", image = "player/cornac_male.png",
	desc = "당신의 옛 친구인 킬레스입니다. 기억보다 많이 더러워진 듯 하고, 훨씬 더 위험해졌습니다.",
	killer_message = "and fed to his corrupted dogs",
	
	stats = { str=10, dex=20, wil=40, cun=30, con=15 },
	autolevel = "wildcaster",
	level_range = {20, 35}, exp_worth = 2,
	rank = 4,
	max_life = 100, life_rating = 12,
	combat_armor = 0, combat_def = 15,
	open_door = 1,

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1, FINGER=1 },

	see_invisible = 20,
	hate = 100,
	hate_regen = 4,

	resolvers.equip{
		{type="weapon", subtype="mindstar", autoreq=true, force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss"},
		{type="weapon", subtype="mindstar", autoreq=true, force_drop=true, forbid_power_source={antimagic=true}, tome_drops="boss"},
	},
	resolvers.drops{chance=100, nb=2, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_WILLFUL_STRIKE]={base=2, every=5, max=6},
		[Talents.T_DEFLECTION]={base=2, every=8, max=6},
		[Talents.T_BLAST]={base=2, every=8, max=6},
		[Talents.T_UNSEEN_FORCE]={base=1, every=8, max=6},
		[Talents.T_FEED]={base=3, every=8, max=6},
		[Talents.T_DEVOUR_LIFE]={base=4, every=10, max=6},
		[Talents.T_FEED_POWER]={base=1, every=8, max=5},
		[Talents.T_FEED_STRENGTHS]={base=1, every=8, max=5},
		[Talents.T_CREEPING_DARKNESS]={base=1, every=5, max=6},
		[Talents.T_DARK_VISION]=3,
		[Talents.T_DARK_TENDRILS]={base=1, every=5, max=6},
	},
	resolvers.inscriptions(1, {"shielding rune"}),
	resolvers.inscriptions(3, {"regeneration infusion"}),

	resolvers.sustains_at_birth(),

	never_act = true,
	seen_by = function(self, who)
		-- when player sees kyless, show some lore and activate him
		if not game.party:hasMember(who) then return end
		self.seen_by = nil
		self.never_act = nil
		
		local p = game.party:findMember{main=true}
		p:hasQuest("keepsake"):on_kyless_encounter(p, self)

		self:setTarget(who)
		self:doEmote(p.name, 60)
	end,

	on_die = function(self, who)
		local p = game.party:findMember{main=true}
		p:hasQuest("keepsake"):on_kyless_death(p, kyless)
	end,
}

newEntity{ define_as="BERETHH",
	name = "Berethh",
	kr_display_name = "베레쓰",
	type = "humanoid", subtype = "thalore",
	color=colors.LIGHT_GREEN, display = "p", image = "player/thalore_male.png",
	desc = "당신의 옛 친구인 베레쓰입니다. 몸에 밴 가죽옷을 입고 기술적으로 활을 쥐고 있습니다. 그가 가는 길은 뭔가 숭고해 보이지만, 아무런 감정도 내비치지 않습니다.",
	killer_message = "and quickly burned in a pyre",
	level_range = {20, 35}, exp_worth = 2,
	rank = 4,
	autolevel = "archer",
	stats = { str=25, dex=35, wil=35, con=25 },
	max_life = 120, life_rating = 14,
	combat_armor = 0, combat_def = 20,
	open_door = 1,
	movement_speed=1.4,

	ai = "tactical", ai_state = { talent_in=3, },
	ai_tactic = resolvers.tactic"ranged",

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1, FINGER=1 },

	see_invisible = 20,

	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]={base=2, every=7, max=10},
		[Talents.T_BOW_MASTERY]={base=5, every=7, max=10},
		[Talents.T_SHOOT]=1,
		[Talents.T_PINNING_SHOT]={base=2, every=8, max=4},
		[Talents.T_CRIPPLING_SHOT]={base=3, every=8, max=6},
		[Talents.T_DUAL_ARROWS]={base=3, every=8, max=6},
		[Talents.T_DISENGAGE] = 5
	},
	resolvers.inscriptions(1, {"regeneration infusion"}),

	resolvers.equip{
		{type="weapon", subtype="longbow", autoreq=true, force_drop=true, tome_drops="boss"},
		{type="ammo", subtype="arrow", autoreq=true},
		{type="armor", subtype="light", autoreq=true, force_drop=true, tome_drops="boss"},
		{type="armor", subtype="hands", autoreq=true, force_drop=true, tome_drops="boss"},
		{type="armor", subtype="feet", autoreq=true, force_drop=true, tome_drops="boss"},
	},
	resolvers.drops{chance=100, nb=1, {tome_drops="boss"} },

	resolvers.sustains_at_birth(),

	never_act = true,
	seen_by = function(self, who)
		-- when player sees kyless, show some lore and activate him
		if not game.party:hasMember(who) then return end
		
		self.seen_by = nil
		self.never_act = nil
		
		local p = game.party:findMember{main=true}
		p:hasQuest("keepsake"):on_berethh_encounter(p, self)

		self:setTarget(who)
	end,

	on_die = function(self, who)
		local p = game.party:findMember{main=true}
		p:hasQuest("keepsake"):on_berethh_death(p, berethh)
	end,
}