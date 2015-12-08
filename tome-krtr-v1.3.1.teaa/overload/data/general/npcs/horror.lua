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

-- last updated:  10:46 AM 2/3/2010

require "engine.krtrUtils"

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_HORROR",
	type = "horror", subtype = "eldritch",
	display = "h", color=colors.WHITE,
	blood_color = colors.BLUE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },

	stats = { str=20, dex=20, wil=20, mag=20, con=20, cun=20 },
	combat_armor = 5, combat_def = 10,
	combat = { dam=5, atk=10, apr=5, dammod={str=0.6} },
	infravision = 10,
	max_life = resolvers.rngavg(10,20),
	rank = 2,
	size_category = 3,

	no_breath = 1,
	fear_immune = 1,
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "worm that walks", color=colors.SANDY_BROWN,
	kr_name = "걷는 벌레",
	desc = [[솔기부터 찢어진 불룩한 썩은 로브에서, 수많은 벌레들이 쏟아져 나옵니다. 점액 범벅인 지렁이 모양의 팔이 두 개 달려 있으며, 이 팔로 담즙이 발린 전투도끼의 손잡이를 꽉 쥐고 있습니다.
무기를 휘두를 때마다 썩은 액체가 먼저 튀며, 이 액체는 땅에 떨어지기 전까지 허공에서 꿈틀거리며 뒤틀립니다.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(150,170),
	life_rating = 16,
	rank = 3,
	hate_regen = 10,

	autolevel = "warriormage",
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },
	ai_tactic = resolvers.tactic "melee",

	see_invisible = 100,
	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	disease_immune = 1,

	combat_spellpower = resolvers.levelup(10, 1, 1),


	resists = { [DamageType.PHYSICAL] = 50, [DamageType.ACID] = 100, [DamageType.BLIGHT] = 100, [DamageType.FIRE] = -50},
	inc_damage = { [DamageType.BLIGHT] = 20, },
	damage_affinity = { [DamageType.BLIGHT] = 50 },
	no_auto_resists = true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.equip{
		{type="weapon", subtype="waraxe", ego_chance = 100, autoreq=true},
		{type="weapon", subtype="waraxe", ego_chance = 100, autoreq=true},
		{type="armor", subtype="robe", ego_chance = 100, autoreq=true}
	},

	talent_cd_reduction = {[Talents.T_BLINDSIDE]=4},

	resolvers.inscriptions(1, {"regeneration infusion"}),

	resolvers.talents{
		[Talents.T_DRAIN]={base=5, every=10, max=7},
		[Talents.T_WORM_ROT]={base=4, every=8},
		[Talents.T_EPIDEMIC]={base=4, every=8},
		[Talents.T_REND]={base=2, every=8},
		[Talents.T_ACID_STRIKE]={base=2, every=8},
		[Talents.T_BLOODLUST]={base=2, every=8},
		[Talents.T_RUIN]={base=2, every=8},
		[Talents.T_CORRUPTED_STRENGTH]={base=2, every=8},

		[Talents.T_BLINDSIDE]={base=3, every=12},

		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=6},
		[Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=6},
	},

	resolvers.sustains_at_birth(),

	on_takehit = function(self, value, src)
		if value >= (self.max_life * 0.1) then
			local t = self:getTalentFromId(self.T_WORM_ROT)
			t.spawn_carrion_worm(self, self, t)
			game.logSeen(self, "#LIGHT_RED#썩은 고기를 먹는 벌레 덩어리가 %s의 상처에 알을 낳았습니다!", (self.kr_name or self.name))
		end
		return value
	end,
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "bloated horror", color=colors.WHITE,
	kr_name = "부풀어오른 공포",
	desc ="뚱뚱한 사람을 닮았으며, 대기 중을 떠다니는 존재입니다. 마치 아기처럼, 머리카락이 없는 머리는 몸에 비해 지나치게 커다랗습니다. 불결한 피부에는 붉게 헌 곰보자국이 가득합니다.",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	size_category = 4,
	autolevel = "wildcaster",
	combat_armor = 1, combat_def = 0, combat_def_ranged = resolvers.mbonus(30, 15),
	combat = {dam=resolvers.levelup(resolvers.mbonus(25, 15), 1, 1.1), apr=0, atk=resolvers.mbonus(30, 15), dammod={mag=0.6}},

	never_move = 1,
	levitation = 1,

	resists = {all = 35, [DamageType.LIGHT] = -30},

	resolvers.talents{
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_MIND_DISRUPTION]={base=2, every=6, max=7},
		[Talents.T_MIND_SEAR]={base=2, every=6, max=7},
		[Talents.T_TELEKINETIC_BLAST]={base=2, every=6, max=7},
	},

	resolvers.inscriptions(1, {"shielding rune"}),

	resolvers.sustains_at_birth(),
	ingredient_on_death = "BLOATED_HORROR_HEART",
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "nightmare horror", color=colors.DARK_GREY,
	kr_name = "악몽의 공포",
	desc ="당신의 가장 깊은 곳에 있는 공포를 반영하여, 가장 어두운 밤의 변화하는 형상을 가진 존재입니다.",
	level_range = {35, nil}, exp_worth = 1,
	mana_regen = 10,
	negative_regen = 10,
	hate_regen = 10,
	psi_regen = 10,
	rarity = 8,
	rank = 3,
	max_life = resolvers.rngavg(150,170),
	life_rating = 16,
	autolevel = "spider",
	combat_armor = 1, combat_def = 30,
	combat = { dam=resolvers.levelup(20, 1, 1.1), atk=20, apr=50, dammod={mag=1}, damtype=DamageType.DARKSTUN},

	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",
	ai_state = { ai_target="target_player_radius", sense_radius=10, talent_in=1, },
	dont_pass_target = true,

	can_pass = {pass_wall=20},
	resists = {all = 35, [DamageType.LIGHT] = -50, [DamageType.DARKNESS] = 100},

	negative_status_effect_immune = 1,
	combat_spellpower = resolvers.levelup(30, 1, 2),
	combat_mindpower = resolvers.levelup(30, 1, 2),

	resolvers.talents{
		[Talents.T_STEALTH]={base=5, every=12, max=8},
		[Talents.T_GLOOM]={base=3, every=12, max=8},
		[Talents.T_WEAKNESS]={base=3, every=12, max=8},
		[Talents.T_DISMAY]={base=3, every=12, max=8},
		[Talents.T_DOMINATE]={base=3, every=12, max=8},
		[Talents.T_INVOKE_DARKNESS]={base=5, every=8, max=10},
		[Talents.T_NIGHTMARE]={base=5, every=8, max=10},
		[Talents.T_WAKING_NIGHTMARE]={base=3, every=8, max=10},
		[Talents.T_ABYSSAL_SHROUD]={base=3, every=8, max=8},
		[Talents.T_INNER_DEMONS]={base=3, every=8, max=10},
	},

	resolvers.inscriptions(1, {"shielding rune"}),

	resolvers.sustains_at_birth(),
}


------------------------------------------------------------------------
-- Headless horror and its eyes
------------------------------------------------------------------------
newEntity{ base = "BASE_NPC_HORROR",
	name = "headless horror", color=colors.TAN,
	kr_name = "머리 없는 공포",
	desc ="배가 부풀어오르고 머리가 없는, 호리호리한 사람을 닮은 존재입니다.",
	level_range = {30, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(200,220),
	life_rating = 16,
	autolevel = "warrior",
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	combat = { dam=20, atk=20, apr=10, dammod={str=1} },
	combat = {damtype=DamageType.PHYSICAL},
	no_auto_resists = true,
	move_others=true,
	is_headless_horror = true,

	-- Should get resists based on eyes generated, 30% all per eye and 100% to the eyes element.  Should lose said resists when the eyes die.

	-- Should be blind but see through the eye escorts
	--blind= 1,

	resolvers.talents{
		[Talents.T_MANA_CLASH]={base=4, every=5, max=8},
		[Talents.T_CLINCH]={base=4, every=6, max=8},
		[Talents.T_TAKE_DOWN]={base=4, every=5, max=8},
		[Talents.T_CRUSHING_HOLD]={base=4, every=5, max=8},
	},

	resolvers.inscriptions(1, {"healing infusion"}),
	--resolvers.inscriptions(2, "rune"),

	-- Add eyes
	on_added_to_level = function(self)
		local eyes = {}
		for i = 1, 3 do
			local x, y = util.findFreeGrid(self.x, self.y, 15, true, {[engine.Map.ACTOR]=true})
			if x and y then
				local m = game.zone:makeEntity(game.level, "actor", {properties={"is_eldritch_eye"}, special_rarity="_eldritch_eye_rarity"}, nil, true)
				if m then
					m.summoner = self
					game.zone:addEntity(game.level, m, "actor", x, y)
					eyes[m] = true

					-- Grant resist
					local damtype = next(m.resists)
					self.resists[damtype] = 100
					self.resists.all = (self.resists.all or 0) + 30
				end
			end
		end
		self.eyes = eyes
	end,

	-- Needs an on death affect that kills off any remaining eyes.
	on_die = function(self, src)
		local nb = 0
		for eye, _ in pairs(self.eyes) do
			if not eye.dead then eye:die(src) nb = nb + 1 end
		end
		if nb > 0 then
			game.logSeen(self, "#AQUAMARINE#%s 쓰러지자, 주위에 있던 모든 눈들이 땅에 떨어집니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
		end
	end,
}

newEntity{ base = "BASE_NPC_HORROR", define_as = "BASE_NPC_ELDRICTH_EYE",
	name = "eldritch eye", color=colors.SLATE, is_eldritch_eye=true,
	kr_name = "섬뜩한 눈",
	desc ="둥둥 떠다니는, 충혈된 작은 눈입니다.",
	level_range = {30, nil}, exp_worth = 1,
	life_rating = 7,
	rank = 2,
	size_category = 1,
	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	combat_armor = 1, combat_def = 0,
	levitation = 1,
	no_auto_resists = true,
	talent_cd_reduction = {all=100},

	on_die = function(self, src)
		if not self.summoner or not self.summoner.is_headless_horror then return end
		self:logCombat(self.summoner, "#AQUAMARINE# #Source# 쓰러지자 #Target#도 약해진 것 같습니다!")
		local damtype = next(self.resists)
		self.summoner.resists.all = (self.summoner.resists.all or 0) - 30
		self.summoner.resists[damtype] = nil

		-- Blind the main horror if no more eyes
		local nb = 0
		for eye, _ in pairs(self.summoner.eyes or {}) do
			if not eye.dead then nb = nb + 1 end
		end
		if nb == 0 and self.summoner and self.summoner.is_headless_horror then
			local sx, sy = game.level.map:getTileToScreen(self.summoner.x, self.summoner.y)
			game.flyers:add(sx, sy, 20, (rng.range(0,2)-1) * 0.5, -3, "+실명", {255,100,80})
			self.summoner.blind = 1
			game.logSeen(self.summoner, "%s 모든 눈을 잃어, 실명 상태가 되었습니다.", (self.summoner.kr_name or self.summoner.name):capitalize():addJosa("가"))
		end
	end,
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--fire
	_eldritch_eye_rarity = 1,
	vim_regen = 100,
	resists = {[DamageType.FIRE] = 80},
	resolvers.talents{
		[Talents.T_BURNING_HEX]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--cold
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.COLD] = 80},
	resolvers.talents{
		[Talents.T_ICE_SHARDS]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--earth
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.PHYSICAL] = 80},
	resolvers.talents{
		[Talents.T_STRIKE]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--arcane
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.ARCANE] = 80},
	resolvers.talents{
		[Talents.T_MANATHRUST]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--acid
	_eldritch_eye_rarity = 1,
	equilibrium_regen = -100,
	resists = {[DamageType.ACID] = 80},
	nature_summon_max = -1,
	resolvers.talents{
		[Talents.T_HYDRA]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--dark
	_eldritch_eye_rarity = 1,
	vim_regen = 100,
	resists = {[DamageType.DARKNESS] = 80},
	resolvers.talents{
		[Talents.T_CURSE_OF_DEATH]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--light
	_eldritch_eye_rarity = 1,
	resists = {[DamageType.LIGHT] = 80},
	resolvers.talents{
		[Talents.T_SEARING_LIGHT]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--lightning
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.LIGHTNING] = 80},
	resolvers.talents{
		[Talents.T_LIGHTNING]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--blight
	_eldritch_eye_rarity = 1,
	vim_regen = 100,
	resists = {[DamageType.BLIGHT] = 80},
	talent_cd_reduction = {all=1},
	resolvers.talents{
		[Talents.T_VIRULENT_DISEASE]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--nature
	_eldritch_eye_rarity = 1,
	equilibrium_regen = -100,
	resists = {[DamageType.NATURE] = 80},
	resolvers.talents{
		[Talents.T_SPIT_POISON]=3,
	},
}

newEntity{ base = "BASE_NPC_ELDRICTH_EYE",
	--mind
	_eldritch_eye_rarity = 1,
	mana_regen = 100,
	resists = {[DamageType.MIND] = 80},
	resolvers.talents{
		[Talents.T_MIND_DISRUPTION]=3,
	},
}
-- TODO: Make Luminous and Radiant Horrors cooler
newEntity{ base = "BASE_NPC_HORROR",
	name = "luminous horror", color=colors.YELLOW,
	kr_name = "밤에 빛나는 공포",
	desc ="노란 빛을 내고 있으며, 비쩍 마른 사람의 모습을 한 존재입니다.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 2,
	autolevel = "caster",
	combat_armor = 1, combat_def = 10,
	combat = { dam=5, atk=15, apr=20, dammod={mag=0.6}, damtype=DamageType.LIGHT},
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1.5, },
	lite = 3,

	resists = {all = 35, [DamageType.DARKNESS] = -50, [DamageType.LIGHT] = 100, [DamageType.FIRE] = 100},
	damage_affinity = { [DamageType.LIGHT] = 50,  [DamageType.FIRE] = 50, },

	blind_immune = 1,
	see_invisible = 10,

	resolvers.talents{
		[Talents.T_CHANT_OF_FORTITUDE]={base=3, every=6, max=8},
		[Talents.T_SEARING_LIGHT]={base=3, every=6, max=8},
		[Talents.T_FIREBEAM]={base=3, every=6, max=8},
		[Talents.T_PROVIDENCE]={base=3, every=6, max=8},
		[Talents.T_HEALING_LIGHT]={base=1, every=6, max=8},
		[Talents.T_BARRIER]={base=1, every=6, max=8},
	},

	resolvers.sustains_at_birth(),

	make_escort = {
		{type="horror", subtype="eldritch", name="luminous horror", number=2, no_subescort=true},
	},
	ingredient_on_death = "LUMINOUS_HORROR_DUST",
	power_source = {arcane=true},
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "radiant horror", color=colors.GOLD,
	kr_name = "발광하는 공포",
	desc ="밝은 금빛을 내고 있으며, 팔이 네 개 달린 비쩍 마른 사람의 모습을 한 존재입니다. 그 빛이 너무 밝아 똑바로 쳐다보기가 힘들며, 빛과 함께 열기까지 내뿜고 있습니다.",
	level_range = {35, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	autolevel = "caster",
	max_life = resolvers.rngavg(220,250),
	life_rating = 16,
	combat_armor = 1, combat_def = 10,
	combat = { dam=20, atk=30, apr=40, dammod={mag=1}, damtype=DamageType.LIGHT},
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	lite = 5,

	resists = {all = 40, [DamageType.DARKNESS] = -50, [DamageType.LIGHT] = 100, [DamageType.FIRE] = 100},
	damage_affinity = { [DamageType.LIGHT] = 50,  [DamageType.FIRE] = 50, },

	blind_immune = 1,
	see_invisible = 20,

	resolvers.talents{
		[Talents.T_CHANT_OF_FORTITUDE]={base=10, every=15},
		[Talents.T_CIRCLE_OF_BLAZING_LIGHT]={base=10, every=15},
		[Talents.T_SEARING_LIGHT]={base=10, every=15},
		[Talents.T_FIREBEAM]={base=10, every=15},
		[Talents.T_SUNBURST]={base=10, every=15},
		[Talents.T_SUN_FLARE]={base=10, every=15},
		[Talents.T_PROVIDENCE]={base=10, every=15},
		[Talents.T_HEALING_LIGHT]={base=10, every=15},
		[Talents.T_BARRIER]={base=10, every=15},
	},

	resolvers.sustains_at_birth(),
	power_source = {arcane=true},

	make_escort = {
		{type="horror", subtype="eldritch", name="luminous horror", number=1, no_subescort=true},
	},
}

newEntity{ base = "BASE_NPC_HORROR",
	subtype = "eldritch",
	name = "devourer", color=colors.CRIMSON,
	kr_name = "포식자",
	desc = "뭉툭한 팔다리를 가진, 머리 없이 둥글둥글한 존재입니다. 온몸에 이빨이 달려 있는 것 같습니다.",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	movement_speed = 0.8,
	size_category = 2,
	autolevel = "zerker",
	max_life = resolvers.rngavg(80, 100),
	life_rating = 14,
	life_regen = 4,
	combat_armor = 16, combat_def = 1,
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,40), 1, 0.6), atk=resolvers.rngavg(25,50), apr=25, dammod={str=1.1}, physcrit = 10 },
	ai_state = { talent_in=1.5, },

	resolvers.talents{
		[Talents.T_BLOODBATH]={base=1, every=5, max=7},
		[Talents.T_GNASHING_TEETH]={base=1, every=5, max=7},
		-- talents only usable while frenzied
		[Talents.T_FRENZIED_LEAP]={base=1, every=5, max=7},
		[Talents.T_FRENZIED_BITE]={base=1, every=5, max=7},
	},

	make_escort = {
		{type="horror", subtype="eldritch", name="devourer", number=2, no_subescort=true},
	},
}

--Blade horror, psionic horror surrounded by countless telekinetic blades.
newEntity{ base = "BASE_NPC_HORROR",
	name = "blade horror", color=colors.GREY, define_as="BLADEHORROR",
	kr_name = "칼날의 공포",
	desc = "날씬한 몸을 가진 채 허공에 떠 있는 존재로, 주변에 칼날들이 회전하고 있습니다. 그 주변의 공기는, 접근하는 모든 것들을 찢어버릴 듯 위협적인 힘에 의해 소용돌이 치고 있습니다. 물론 실제로는 바람보다 칼날이 먼저 모든 것을 찢어버리겠지만 말이죠.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_eldritch_blade_horror.png", display_h=2, display_y=-1}}},
	level_range = {15, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	levitate=1,
	max_psi= 300,
	psi_regen= 4,
	size_category = 3,
	autolevel = "wildcaster",
	max_life = resolvers.rngavg(70, 95),
	life_rating = 12,
	life_regen = 0.25,
	combat_armor = 12, combat_def = 24,

	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=2, ally_compassion=0 },

	on_melee_hit = {[DamageType.PHYSICALBLEED]=resolvers.mbonus(14, 2)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(16,22), 1, 1.5), atk=resolvers.levelup(18, 1, 1), apr=4, dammod={wil=0.25, cun=0.1}, damtype=engine.DamageType.PHYSICALBLEED, },
	combat_physspeed = 4, --Crazy fast attack rate

	resists = {[DamageType.PHYSICAL] = 10, [DamageType.MIND] = 40, [DamageType.ARCANE] = -20},

	resolvers.talents{
		[Talents.T_KNIFE_STORM]={base=3, every=6, max=7},
		[Talents.T_IMPLODE]={base=1, every=8, max=4},
		[Talents.T_RAZOR_KNIFE]={base=1, every=6, max=5},
		[Talents.T_PSIONIC_PULL]={base=1, every=6, max=5},
		[Talents.T_KINETIC_AURA]={base=1, every=4, max=7},
		[Talents.T_KINETIC_SHIELD]={base=1, every=3, max=6},
		[Talents.T_KINETIC_LEECH]={base=2, every=5, max=5},
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR",
	subtype = "eldritch",
	name = "oozing horror", color=colors.GREEN,
	kr_name = "점액의 공포",
	desc = "커다란 무정형의 녹색 슬라임 덩어리가 천천히 당신쪽으로 기어오고 있습니다. 그 점액질 안에서 떠다니는 눈으로, 먹잇감을 찾고 있습니다.",
	level_range = {16, nil}, exp_worth = 1,
	rarity = 7,
	rank = 3,
	movement_speed = 0.7,
	size_category = 4,
	autolevel = "wildcaster",
	max_life = resolvers.rngavg(100, 120),
	life_rating = 20,
	life_regen = 3,
	combat_armor = 15, combat_def = 24,

	on_move = function(self)
			local DamageType = require "engine.DamageType"
			local MapEffect = require "engine.MapEffect"
			local duration = 10
			local radius = 0
			local dam = 25
			-- Add a lasting map effect
			game.level.map:addEffect(self,
				self.x, self.y, duration,
				engine.DamageType.SLIME, 25,
				radius,
				5, nil,
				MapEffect.new{color_br=25, color_bg=140, color_bb=40, effect_shader="shader_images/retch_effect.png"},
				function(e, update_shape_only)
					if not update_shape_only then e.radius = e.radius end
					return true
				end,
				false
			)
	end,

	on_melee_hit = {[DamageType.SLIME]=resolvers.mbonus(16, 2), [DamageType.ACID]=resolvers.mbonus(14, 2)},
	combat = {
		dam=resolvers.levelup(resolvers.rngavg(40,50), 1, 0.9),
		atk=resolvers.rngavg(25,50), apr=25,
		dammod={wil=1.1}, physcrit = 10,
		damtype=engine.DamageType.SLIME,
	},

	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },

	resists = {all=15, [DamageType.PHYSICAL] = -10, [DamageType.NATURE] = 100, [DamageType.ARCANE] = 40, [DamageType.BLIGHT] = 24},

	resolvers.talents{
			[Talents.T_RESOLVE]={base=3, every=6, max=8},
			[Talents.T_MANA_CLASH]={base=1, every=6, max=7},
			[Talents.T_OOZE_SPIT]={base=1, every=8, max=4},
			[Talents.T_OOZE_ROOTS]={base=3, every=6, max=7},
			[Talents.T_SLIME_WAVE]={base=2, every=8, max=7},
			[Talents.T_TENTACLE_GRAB]={base=2, every=7, max=6},
	},
}

newEntity{ base = "BASE_NPC_HORROR",
	subtype = "eldritch",
	name = "umbral horror", color=colors.BLACK,
	kr_name = "음영의 공포",
	desc = "그 형체를 자유자재로 바꿀 수 있는 어둠의 존재로, 그림자와 융합되어가며 당신을 추적하고 있습니다.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_eldritch_umbral_horror.png", display_h=2, display_y=-1}}},
	level_range = {16, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	movement_speed = 1.2,
	size_category = 2,
	autolevel = "wildcaster",
	max_life = resolvers.rngavg(100, 120),
	life_rating = 20,
	life_regen = 0.25,
	hate_regen=4,
	combat_armor = 0, combat_def = 24,

	combat = {
		dam=resolvers.levelup(resolvers.rngavg(36,45), 1, 1.2),
		atk=resolvers.rngavg(25,35), apr=20,
		dammod={wil=0.8}, physcrit = 12,
		damtype=engine.DamageType.DARKNESS,
	},
	combat_physspeed = 2,

	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },

	resists = {[DamageType.PHYSICAL] = -10, [DamageType.DARKNESS] = 100, [DamageType.LIGHT] = -60},

	resolvers.talents{
			[Talents.T_CALL_SHADOWS]={base=3, every=6, max=10},
			[Talents.T_STEALTH]={base=4, every=5, max=10},
			[Talents.T_PHASE_DOOR]=1,
			[Talents.T_BLINDSIDE]={base=2, every=8, max=5},
			[Talents.T_DARK_TORRENT]={base=1, every=5, max=8},
			[Talents.T_CREEPING_DARKNESS]={base=2, every=4, max=10},
			[Talents.T_DARK_VISION]=5,
			[Talents.T_FOCUS_SHADOWS]={base=4, every=5, max=10},
			[Talents.T_SHADOW_WARRIORS]={base=1, every=8, max=5},
	},
		resolvers.sustains_at_birth(),
}

-- Dream Horror
newEntity{ base = "BASE_NPC_HORROR",
	name = "dreaming horror", color=colors.ORCHID,
	kr_name = "꿈의 공포",
	desc =[[촉수가 달렸지만 끊임없이 그 형태가 변하는 존재로, 당신이 있다는 것을 염두에 두지 않고 여기서 쉬고 있습니다. 
그 천천히 내뱉는 숨은 주변의 현실을 왜곡시킵니다. 푸른색은 붉게, 녹색은 노랗게 바뀌고, 잔잔하던 대기는 수많은 옅은 형상과 색깔로 몰아칩니다.]],
	resolvers.nice_tile{tall=1},
	shader = "shadow_simulacrum",
	shader_args = { color = {0.5, 0.5, 1.0}, base = 0.8, time_factor= 2000 },
	level_range = {20, nil}, exp_worth = 1,
	rarity = 30,  -- Very rare; should feel almost like uniques though they aren't
	rank = 3,
	max_life = 100,  -- Solipsism will take care of hit points
	life_rating = 4, 
	psi_rating = 6,
	autolevel = "wildcaster",
	combat_armor = 1, combat_def = 15,
	combat = { dam=resolvers.levelup(20, 1, 1.1), atk=20, apr=20, dammod={wil=1}, damtype=DamageType.MIND},

	ai = "tactical", -- ai_tactic = resolvers.tactic"ranged",
	ai_state = { ai_target="target_player_radius", sense_radius=20, talent_in=1 }, -- Huge radius for projections to target
	dont_pass_target = true,
	summon = {{type="horror", subtype="eldritch", name="dream seed", number=5, hasxp=false}, },

	resists = { all = 35 },

	combat_mindpower = resolvers.levelup(30, 1, 2),
	
	body = { INVEN = 10 },
	resolvers.drops{chance=100, nb=5, {ego_chance=100} }, -- Gives good loot to encourage the player to wake it up

	resolvers.talents{
		[Talents.T_DISTORTION_BOLT]={base=4, every=6, max=8},
		[Talents.T_DISTORTION_WAVE]={base=4, every=6, max=8},
		[Talents.T_MAELSTROM]={base=4, every=6, max=8},
		[Talents.T_RAVAGE]={base=4, every=6, max=8},
		
		[Talents.T_BIOFEEDBACK]={base=4, every=6, max=8},
		[Talents.T_RESONANCE_FIELD]={base=4, every=6, max=8},
		[Talents.T_BACKLASH]={base=4, every=6, max=8},
		[Talents.T_AMPLIFICATION]={base=4, every=6, max=8},
		[Talents.T_CONVERSION]={base=4, every=6, max=8},
		
		[Talents.T_MENTAL_SHIELDING]={base=4, every=6, max=8},

		[Talents.T_SOLIPSISM]={base=7, every=15, max=5}, -- High solipsism is a lot like resist all
		[Talents.T_BALANCE]={base=4, every=6, max=8},
		[Talents.T_CLARITY]={base=4, every=6, max=8},
		[Talents.T_DISMISSAL]={base=4, every=6, max=8},

		[Talents.T_LUCID_DREAMER]={base=4, every=12, max=8},
		[Talents.T_DREAM_WALK]={base=4, every=12, max=8},
	--	[Talents.T_SLUMBER]={base=4, every=6, max=8},
		[Talents.T_SLEEP]={base=4, every=6, max=8},
	--	[Talents.T_RESTLESS_NIGHT]={base=4, every=6, max=8},
		[Talents.T_DREAMSCAPE]={base=4, every=5, max=10},
		
		-- Summon Dream Seeds while awake
		[Talents.T_SUMMON]=1,
	},

	resolvers.inscriptions(2, {"regeneration infusion", "phase door rune"}, nil, true),  -- Really has a phase door rune :P
	power_source = {psionic=true},

	resolvers.sustains_at_birth(),

	-- Used to track if he's awake or spawning projections
	dreamer_sleep_state = 1,
	-- And some particles to show that we're asleep
	resolvers.genericlast(function(e)
		if core.shader.active(4) then
			e.sleep_particle = e:addParticles(engine.Particles.new("shader_shield", 1, {img="shield7", size_factor=1.5, y=-0.3}, {type="shield", ellipsoidalFactor=1.5, time_factor=6000, aadjust=7, color={0.6, 1, 0.6}}))
		else
			e.sleep_particle = e:addParticles(engine.Particles.new("generic_shield", 1, {r=0.6, g=1, b=0.6, a=1}))
		end
	end),

	-- Spawn Dream Seeds
	on_act = function(self)
		if self.dreamer_sleep_state and self.ai_target.actor then 
			self.dreamer_sleep_state = math.min(self.dreamer_sleep_state + 1, 31) -- Caps at 31 so a new one doesn't spawn as soon as an old one dies
			self:useEnergy() -- Always use energy when in the sleep state

			if self.dreamer_sleep_state%10 == 0 and self.dreamer_sleep_state <= 30 then
				-- Find Space
				local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[engine.Map.ACTOR]=true})
				if not x then
					return
				end
				
				local seed = {type="horror", subtype="eldritch", name="dream seed"}
				local list = mod.class.NPC:loadList("/data/general/npcs/horror.lua")
				local m = list.DREAM_SEED:clone()
				if not m then return nil end
				
				m.exp_worth = 0
				m.summoner = self			
				m:resolve() m:resolve(nil, true)
				m:forceLevelup(self.level)
				game.zone:addEntity(game.level, m, "actor", x, y)
				
				game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=225, rM=255, gm=225, gM=255, bm=225, bM=255, am=35, aM=90})
				game.logSeen(self, "#LIGHT_BLUE#%s의 잠자는 정신에서 꿈의 씨앗이 탈출했습니다.", (self.kr_name or self.name):capitalize())
			end
		-- Script the AI to encourage opening with dream scape
		elseif self.ai_target.actor and self.ai_target.actor.game_ender and not game.zone.is_dream_scape then
			if not self:isTalentCoolingDown(self.T_SLEEP) then
				self:forceUseTalent(self.T_SLEEP, {})
			elseif not self:isTalentCoolingDown(self.T_DREAMSCAPE) and self.ai_target.actor:attr("sleep") then
				self:forceUseTalent(self.T_DREAMSCAPE, {})
			end
		end
	end,
	on_acquire_target = function(self, who)
		self:useEnergy() -- Use energy as soon as we find a target so we don't move
	end,
	on_takehit = function(self, value, src)
		if value > 0 and self.dreamer_sleep_state then
			self.dreamer_sleep_state = nil
			self.desc = [[촉수가 달렸지만 끊임없이 그 형태가 변하는 존재로, 이것이 숨을 쉴 때마다 현실이 꼬이고 부서져 흩어지는 것이 느껴집니다. 
푸른색은 붉게, 녹색은 노랗게 불타오르며, 대기는 파직거리면서 쉬익대다가 수천 개의 날카롭고 다양한 색깔의 파편으로 폭발합니다.]]
			self:removeParticles(self.sleep_particle)
			game.logSeen(self, "#LIGHT_BLUE#꿈꾸는 이가 움찔하였습니다...")
		end
		return value
	end,
}

newEntity{ base = "BASE_NPC_HORROR", define_as = "DREAM_SEED",
	name = "dream seed", color=colors.PINK, image = "npc/dream_seed.png",
	kr_name = "꿈의 씨앗",
	desc ="떠다니는 분홍색 방울입니다. 세상을 원래와는 다르게, 꿈에서나 볼 수 있는 초현실적인 공간으로 보이게 반사시킵니다.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 30,  -- Very rare; but they do spawn on their own to keep the players on thier toes
	rank = 2,
	max_life = 1, life_rating = 4,  -- Solipsism will take care of hit points
	autolevel = "wildcaster",

	ai = "tactical",
	ai_state = { ai_target="target_player_radius", sense_radius=20, talent_in=3, },
	dont_pass_target = true,
	can_pass = {pass_wall=20},
	levitation = 1,

	combat_armor = 1, combat_def = 5,
	combat = { dam=resolvers.levelup(20, 1, 1.1), atk=10, apr=10, dammod={wil=1}, damtype=engine.DamageType.MIND},

	resolvers.talents{
		[Talents.T_BACKLASH]={base=2, every=6, max=8},
		[Talents.T_DISTORTION_BOLT]={base=2, every=6, max=8},
		[Talents.T_SOLIPSISM]={base=7, every=15, max=5},
		[Talents.T_SLEEP]={base=2, every=6, max=8},
		[Talents.T_LUCID_DREAMER]={base=2, every=6, max=8},
		[Talents.T_DREAM_WALK]=5,
	},

	resolvers.sustains_at_birth(),
	power_source = {psionic=true},

	-- Remove ourselves from the dream seed limit
	on_die = function(self)
		if self.summoner and self.summoner.dreamer_sleep_state then
			self.summoner.dreamer_sleep_state = self.summoner.dreamer_sleep_state - 10
		end
	end,
}
------------------------------------------------------------------------
-- Uniques
------------------------------------------------------------------------

newEntity{ base="BASE_NPC_HORROR",
	name = "Grgglck the Devouring Darkness", unique = true,
	kr_name = "어둠을 삼키는 글그글륵",
	color = colors.DARK_GREY, image = "npc/horror_eldritch_grgglck.png",
	resolvers.nice_tile{tall=1},
	rarity = 50,
	desc = [[대지의 가장 깊은 구덩이에서 나온 공포입니다. 이것은 거대한 촉수 더미처럼 생겼고, 모든 촉수를 당신에게 뻗고 있습니다.
그 속에서, 칼날같이 날카로운 이빨로 둘러싸인 커다란 둥근 입을 발견할 수 있습니다.]],
	level_range = {20, nil}, exp_worth = 2,
	max_life = 300, life_rating = 25, fixed_rating = true,
	equilibrium_regen = -20,
	negative_regen = 20,
	rank = 3.5,
	no_breath = 1,
	size_category = 4,
	movement_speed = 0.8,
	is_grgglck = true,

	stun_immune = 1,
	knockback_immune = 1,

	combat = { dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 1), atk=500, apr=0, dammod={str=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	resists = { all=500 },

	resolvers.talents{
		[Talents.T_STARFALL]={base=4, every=7},
		[Talents.T_MOONLIGHT_RAY]={base=4, every=7},
		[Talents.T_PACIFICATION_HEX]={base=4, every=7},
		[Talents.T_BURNING_HEX]={base=4, every=7},
	},
	resolvers.sustains_at_birth(),

	-- Invoke tentacles every few turns
	on_act = function(self)
		if not self.ai_target.actor or self.ai_target.actor.dead then return end
		if not self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y) then return end

		self.last_tentacle = self.last_tentacle or (game.turn - 60)
		if game.turn - self.last_tentacle >= 60 then -- Summon a tentacle every 6 turns
			self:forceUseTalent(self.T_INVOKE_TENTACLE, {no_energy=true})
			self.last_tentacle = game.turn
		end
	end,

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar" },
}

newEntity{ base="BASE_NPC_HORROR", define_as = "GRGGLCK_TENTACLE",
	name = "Grgglck's Tentacle",
	kr_name = "글그글륵의 촉수",
	color = colors.GREY,
	desc = [[글그글륵의 촉수입니다. 적어도 본체보다는 약해보입니다.]],
	level_range = {20, nil}, exp_worth = 0,
	max_life = 100, life_rating = 3, fixed_rating = true,
	equilibrium_regen = -20,
	rank = 3,
	no_breath = 1,
	size_category = 2,

	stun_immune = 1,
	knockback_immune = 1,
	teleport_immune = 1,

	resists = { all=50, [DamageType.DARKNESS] = 100 },

	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },

	on_act = function(self)
		if self.summoner.dead then
			self:die()
			game.logSeen(self, "#AQUAMARINE#글그글륵이 죽자 그것의 촉수들도 힘없이 땅에 떨어집니다!")
		end
	end,

	on_die = function(self, who)
		if self.summoner and not self.summoner.dead and who then
			self:logCombat(self.summoner, "#AQUAMARINE# #Source# 가 쓰러지자 #Target# 도 고통에 몸부림을 칩니다!")
			if self.summoner.is_grgglck then
				self.summoner:takeHit(self.max_life, who)
			else
				self.summoner:takeHit(self.max_life * 0.66, who)
			end
		end
	end,
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "Ak'Gishil", color=colors.GREY, unique = true,
	kr_name = "악'기실",
	desc = "이 '칼날의 공포'는 강력한 시간 마법의 주입으로 그 힘이 극적으로 상향되었습니다. 그 주변으로 공간의 균열이 끊임없이 열리며, 칼날이 끊임없이 소환됐다가 사라졌다를 반복합니다.",
	resolvers.nice_tile{tall=1},
	level_range = {30, nil}, exp_worth = 2,
	rarity = 45,
	rank = 3.5,
	levitate=1,
	max_psi= 320,
	psi_regen= 5,
	size_category = 4,
	autolevel = "wildcaster",
	max_life = resolvers.rngavg(150, 180),
	life_rating = 32,
	life_regen = 0.25,
	global_speed_base = 1.2,
	combat_armor = 30, combat_def = 18,
	is_akgishil = true,
	can_spawn = 1,
	psionic_shield_override = 1,
	
	resolvers.drops{chance=100, nb=1, {defined="BLADE_RIFT"} },
	
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=2, ally_compassion=0 },
		
	on_melee_hit = {[DamageType.PHYSICALBLEED]=resolvers.mbonus(12, 5)},
	melee_project = {[DamageType.PHYSICALBLEED]=resolvers.mbonus(32, 5)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(20,28), 1, 1.5), physspeed = 0.25,atk=resolvers.levelup(24, 1.2, 1.2), apr=4, dammod={wil=0.3, cun=0.15}, damtype=engine.DamageType.PHYSICALBLEED, },
	--combat_physspeed = 4, --Crazy fast attack rate
	
	resists = {[DamageType.PHYSICAL] = 15, [DamageType.MIND] = 50, [DamageType.TEMPORAL] = 30, [DamageType.ARCANE] = -20},
	
	on_added_to_level = function(self)
		self.blades = 0
	end,

	on_act = function(self)
		if not self:attr("can_spawn") then return end
		if self.blades > 4 or not rng.percent(28/(self.blades+1)) then return end
		self.can_spawn = nil
		self.blades = self.blades + 1
		self:forceUseTalent(self.T_ANIMATE_BLADE, {ignore_cd=true, ignore_energy=true, force_level=1})
		self.can_spawn = 1
	end,
	
	resolvers.talents{
		--Original Blade Horror talents, beefed up
		[Talents.T_KNIFE_STORM]={base=5, every=5, max=8},
		[Talents.T_IMPLODE]={base=2, every=6, max=5},
		[Talents.T_RAZOR_KNIFE]={base=3, every=4, max=7},
		[Talents.T_PSIONIC_PULL]={base=5, every=3, max=7},
		[Talents.T_KINETIC_AURA]={base=4, every=3, max=8},
		[Talents.T_KINETIC_SHIELD]={base=5, every=2, max=9},
		[Talents.T_THERMAL_SHIELD]={base=5, every=2, max=9},
		[Talents.T_CHARGED_SHIELD]={base=5, every=2, max=9},
		[Talents.T_KINETIC_LEECH]={base=3, every=3, max=5},
		--TEMPORAL
		[Talents.T_INDUCE_ANOMALY]={base=1, every=4, max=5},
		[Talents.T_QUANTUM_SPIKE]={base=1, every=4, max=5},
		[Talents.T_WEAPON_FOLDING]={base=1, every=4, max=5},
		[Talents.T_RETHREAD]={base=2, every=4, max=5},
		[Talents.T_DIMENSIONAL_STEP]={base=3, every=4, max=5},
		
		[Talents.T_THROUGH_THE_CROWD]=1,
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base="BASE_NPC_HORROR", define_as = "ANIMATED_BLADE",
	resolvers.nice_tile{tall=1},
	type = "construct", subtype = "weapon", image="object/magical_animated_sword.png",
	name = "Animated Sword",
	kr_name = "살아 움직이는 칼날",
	color = colors.GREY,
	desc = [[이 살아 움직이는 무기 주변의 시간은 구부러지고 왜곡됩니다.]],
	level_range = {30, nil}, exp_worth = 0,
	max_life = 75, life_rating = 4, fixed_rating=true,
	rank = 2,
	no_breath = 1,
	size_category = 2,

	negative_status_effect_immune = 1,
	body = { INVEN = 10, MAINHAND=1 },
	
	resolvers.equip{
		{type="weapon", subtype="longsword", ego_chance = 100, autoreq=true},
	},
	
	resists = {[DamageType.MIND] = 75, [DamageType.TEMPORAL] = 30, all=10},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },
	
	resolvers.talents{
		[Talents.T_SWAP]={base=1, every=4, max=4},
		[Talents.T_WEAPON_COMBAT]={base=1, every=8, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=4, every=4, max=6},
		[Talents.T_DIMENSIONAL_STEP]={base=1, every=4, max=4},
	},
	
	on_added_to_level = function(self)
		self:teleportRandom(self.x, self.y, 7)
		game.logSeen(self, "균열이 열리고, 자유롭게 떠다니는 칼날이 튀어나옵니다!")
		game.level.map:addEffect(self,
			self.x, self.y, 3,
			engine.DamageType.TEMPORAL, 25,
			0,
			5, nil,
			{type="time_prison"},
			nil, false
		)
	end,
	
	on_die = function(self, who)
		if self.summoner and not self.summoner:attr("dead") then
			if self.summoner.is_akgishil then
				self.summoner.blades=self.summoner.blades - 1
			end
		end
	end,

	on_act = function(self)
		if self.summoner and self.summoner:attr("dead") then
			self:die()
			game.logSeen(self, "#AQUAMARINE#공포의 죽음으로 인해, 모든 칼날들이 땅으로 덜컥거리며 떨어집니다!")
		end
	end,
}

newEntity{ base="BASE_NPC_HORROR", define_as = "DISTORTED_BLADE",
	type = "construct", subtype = "weapon", image="object/artifact/distorted_animated_sword.png",
	name = "Distorted Animated Sword", unique=true,
	kr_name = "왜곡된 살아 움직이는 칼날",
	color = colors.GREY,
	desc = [[변형되어 어른거리는, 떠다니는 무기입니다. 이 무기가 움직이는 시공간은 구부러지고 왜곡되며, 언제라도 폭발할 듯이 진동하고 있습니다.]],
	level_range = {30, nil}, exp_worth = 0,
	max_life = 100, life_rating = 10,
	rank = 3.5,
	no_breath = 1,
	size_category = 2,

	negative_status_effect_immune = 1,
	
	body = { INVEN = 10, MAINHAND=1 },
	
	resolvers.equip{
		{type="weapon", subtype="longsword", define_as="RIFT_SWORD", autoreq=true},
	},
	
	resolvers.drops{chance=100, nb=1, {defined="RIFT_SWORD"} },
	
	resists = {[DamageType.MIND] = 75, [DamageType.TEMPORAL] = 40, all=15,},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },
	
	resolvers.talents{
		[Talents.T_SWAP]={base=1, every=4, max=4},
		[Talents.T_WEAPON_COMBAT]={base=3, every=8, max=8},
		[Talents.T_WEAPONS_MASTERY]={base=4, every=4, max=7},
		[Talents.T_DIMENSIONAL_STEP]={base=2, every=4, max=5},
		[Talents.T_WEAPON_FOLDING]={base=2, every=4, max=5},
		[Talents.T_TEMPORAL_WAKE]={base=2, every=4, max=5},
	},
	
	on_added_to_level = function(self)
		self:teleportRandom(self.x, self.y, 10)
		game.logSeen(self, "균열이 열리고, 칼날이 나타납니다. 상당히 특이한 칼날 같습니다.")
		game.level.map:addEffect(self,
			self.x, self.y, 5,
			DamageType.TEMPORAL, 50,
			0,
			5, nil,
			{type="time_prison"},
			nil, false
		)
	end,
	
	on_die = function(self, who)
		if self.summoner and not self.summoner:attr("dead") then
			if self.summoner.is_akgishil then
				self.summoner.blades=self.summoner.blades - 1
			end
		end
	end,

	on_act = function(self)
		self.paradox = self.paradox + 20
		if self.summoner and self.summoner:attr("dead") then
			self:die()
			game.logSeen(self, "#AQUAMARINE#공포의 죽음으로 인해, 모든 왜곡된 칼날들이 땅으로 덜컥거리며 떨어집니다!")
		end
	end,
}
