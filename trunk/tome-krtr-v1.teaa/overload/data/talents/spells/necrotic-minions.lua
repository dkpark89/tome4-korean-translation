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

newTalent{
	name = "Necrotic Aura", image = "talents/aura_mastery.png",
	kr_display_name = "사령술의 기운",
	type = {"spell/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 10,
	no_unlearn_last = true,
	tactical = { BUFF = 2 },
	die_speach = function(self, t)
		if rng.percent(90) then return end
		self:doEmote(rng.table{
			"안돼----!",
			"주인님, 제발 목숨만은... 주인ㄴ---",
			"으아아아아아아!",
			"저... 잘했나요?",
			"으어? 우와아아아악!",
			"주인님, 대체 왜? 대체 왜----?",
			"나를 좋아한다고 생각했는데! 나를-",
			"주인님의 영광을 위하여!",
			"잘... 가....",
			"당신을 사랑해요, 주인님!",
			"으으으으으아아아아하아아아앜크으으으으흐으!!!!",
			"아파요, 아파요오오오오오!",
			"제발, 안돼요, 안돼--",
			"이 몸뚱아리도 더이상 죽음을 거스르지는 못하는 모양이로군, 내 살점이 흩뿌려질 시간이야.",
			"당신이 내 삶을 다시 줬고, 내 꿈을 다시 줬었죠, 하지만 이젠 꿰멘 곳이 터져나가는군요...",
			"날 기억해줘어어어!",
			"배가 아프네...",
			"왜..?",
			"아하하하하하!",
			"난 터질거야, 빵! 하고 터져버린다고!",
			"무덤행이로군요, 주인님....",
			"빛이 보여요.. 보여, 아.. 한 줄기 빛이....",
			"주인님, 기다려 주세요... 제가 뭔가를 본거 같....주인님? ..",
			"아니야.. 내가 이렇게 사라져버린다니....",
			"제가 100 미터를 단숨에 돌진했다가 돌아올 수 있다고 얘기드렸죠! 제게 금화 10 개를 빚졌....",
		}, 40)
	end,
	getDecay = function(self, t) return math.max(3, 10 - self:getTalentLevelRaw(self.T_AURA_MASTERY)) end,
	getRadius = function(self, t) return 2 + self:getTalentLevelRaw(self.T_AURA_MASTERY) end,
	activate = function(self, t)
		local radius = t.getRadius(self, t)
		local decay = t.getDecay(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			souls = self:attr("necrotic_aura_base_souls") or 0,
			souls_max = 10,
			rad = self:addTemporaryValue("necrotic_aura_radius", radius),
			decay = self:addTemporaryValue("necrotic_aura_decay", decay),
			retch = self:addTemporaryValue("retch_heal", 1),
			particle = self:addParticles(Particles.new("necrotic-aura", 1, {radius=radius})),
		}
		self.necrotic_aura_base_souls = nil
		return ret
	end,
	deactivate = function(self, t, p)
		self.necrotic_aura_base_souls = p.souls
		self:removeParticles(p.particle)
		self:removeTemporaryValue("retch_heal", p.retch)
		self:removeTemporaryValue("necrotic_aura_radius", p.rad)
		self:removeTemporaryValue("necrotic_aura_decay", p.decay)
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local decay = t.getDecay(self, t)
		return ([[사령술의 기운을 뿜어내, 주변 %d 칸 범위 내의 언데드 추종자들을 보호합니다. 범위 밖의 추종자들은 턴 당 %d%% 생명력 피해를 입습니다.
		자신이나 추종자가 이 범위 안에서 적을 죽일 경우, 그 영혼이 속박되어 언데드 추종자로 만들어낼 수 있습니다.
		구울이 뿜어내는 토사물을 통해서 생명력을 회복할 수 있게 되며, 이는 자신의 종족이 언데드가 아니더라도 적용됩니다.]]):
		format(radius, decay)
	end,
}


local minions_list = {
	d_skel_warrior = {
		type = "undead", subtype = "skeleton",
		name = "degenerated skeleton warrior", color=colors.WHITE, image="npc/degenerated_skeleton_warrior.png",
		kr_display_name = "부패한 스켈레톤 전사",
		blood_color = colors.GREY,
		display = "s",
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		poison_immune = 1,
		fear_immune = 1,
		see_invisible = 2,
		undead = 1,
		rarity = 1,

		resolvers.equip{ {type="weapon", subtype="greatsword", autoreq=true} },
		max_life = resolvers.rngavg(40,50),
		combat_armor = 5, combat_def = 1,
	},
	skel_warrior = {
		type = "undead", subtype = "skeleton",
		name = "skeleton warrior", color=colors.SLATE, image="npc/skeleton_warrior.png",
		kr_display_name = "스켈레톤 전사",
		blood_color = colors.GREY,
		display = "s", color=colors.SLATE,
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		see_invisible = 2,
		poison_immune = 1,
		undead = 1,
		rarity = 1,

		max_life = resolvers.rngavg(90,100),
		combat_armor = 5, combat_def = 1,
		resolvers.equip{ {type="weapon", subtype="greatsword", autoreq=true} },
		resolvers.talents{ T_STUNNING_BLOW={base=1, every=7, max=5}, T_WEAPON_COMBAT={base=1, every=7, max=10}, T_WEAPONS_MASTERY={base=1, every=7, max=10}, },
		ai_state = { talent_in=1, },
	},
	a_skel_warrior = {
		type = "undead", subtype = "skeleton",
		name = "armoured skeleton warrior", color=colors.STEEL_BLUE, image="npc/armored_skeleton_warrior.png",
		kr_display_name = "중무장한 스켈레톤 전사",
		blood_color = colors.GREY,
		display = "s", color=colors.STEEL_BLUE,
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		poison_immune = 1,
		see_invisible = 2,
		undead = 1,
		rarity = 1,

		resolvers.inscriptions(1, "rune"),
		resolvers.talents{
			T_WEAPON_COMBAT={base=1, every=7, max=10},
			T_WEAPONS_MASTERY={base=1, every=7, max=10},
			T_ARMOUR_TRAINING={base=2, every=14, max=4},
			T_SHIELD_PUMMEL={base=1, every=7, max=5},
			T_RIPOSTE={base=3, every=7, max=7},
			T_OVERPOWER={base=1, every=7, max=5},
			T_DISARM={base=3, every=7, max=7},
		},
		resolvers.equip{ {type="weapon", subtype="longsword", autoreq=true}, {type="armor", subtype="shield", autoreq=true}, {type="armor", subtype="heavy", autoreq=true} },
		ai_state = { talent_in=1, },
	},
	skel_archer = {
		type = "undead", subtype = "skeleton",
		name = "skeleton archer", color=colors.UMBER, image="npc/skeleton_archer.png",
		kr_display_name = "스켈레톤 궁수",
		blood_color = colors.GREY,
		display = "s",
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		poison_immune = 1,
		see_invisible = 2,
		undead = 1,
		rarity = 1,

		max_life = resolvers.rngavg(70,80),
		combat_armor = 5, combat_def = 1,
		resolvers.talents{ T_BOW_MASTERY={base=1, every=7, max=10}, T_WEAPON_COMBAT={base=1, every=7, max=10}, T_SHOOT=1, },
		ai_state = { talent_in=1, },
		autolevel = "archer",
		resolvers.equip{ {type="weapon", subtype="longbow", autoreq=true}, {type="ammo", subtype="arrow", autoreq=true} },
	},
	skel_m_archer = {
		type = "undead", subtype = "skeleton",
		name = "skeleton master archer", color=colors.LIGHT_UMBER, image="npc/master_skeleton_archer.png",
		kr_display_name = "스켈레톤 명궁수",
		blood_color = colors.GREY,
		display = "s",
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		poison_immune = 1,
		see_invisible = 2,
		undead = 1,
		rarity = 1,

		max_life = resolvers.rngavg(70,80),
		combat_armor = 5, combat_def = 1,
		resolvers.talents{ T_BOW_MASTERY={base=1, every=7, max=10}, T_WEAPON_COMBAT={base=1, every=7, max=10}, T_SHOOT=1, T_PINNING_SHOT=3, T_CRIPPLING_SHOT=3, },
		ai_state = { talent_in=1, },
		rank = 3,
		autolevel = "archer",
		resolvers.equip{ {type="weapon", subtype="longbow", autoreq=true}, {type="ammo", subtype="arrow", autoreq=true} },
	},
	skel_mage = {
		type = "undead", subtype = "skeleton",
		name = "skeleton mage", color=colors.LIGHT_RED, image="npc/skeleton_mage.png",
		kr_display_name = "스켈레톤 마법사",
		blood_color = colors.GREY,
		display = "s",
		combat = { dam=1, atk=1, apr=1 },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		autolevel = "warrior",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=4, },
		stats = { str=14, dex=12, mag=10, con=12 },
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, ["technique/2hweapon-offense"]=0.3, ["technique/2hweapon-cripple"]=0.3 },
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		poison_immune = 1,
		see_invisible = 2,
		undead = 1,
		rarity = 1,

		max_life = resolvers.rngavg(50,60),
		max_mana = resolvers.rngavg(70,80),
		combat_armor = 3, combat_def = 1,
		stats = { str=10, dex=12, cun=14, mag=14, con=10 },
		resolvers.talents{ T_FLAME={base=1, every=7, max=5}, T_MANATHRUST={base=2, every=7, max=5} },
		resolvers.equip{ {type="weapon", subtype="staff", autoreq=true} },
		autolevel = "caster",
		ai_state = { talent_in=1, },
	},
	ghoul = {
		type = "undead", subtype = "ghoul",
		display = "z",
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		autolevel = "ghoul",		
		level_range = {1, nil}, exp_worth = 0,
		ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=14, dex=12, mag=10, con=12 },
		rank = 2,
		size_category = 3,
		infravision = 10,
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, }, 
		open_door = true,
		blind_immune = 1,
		see_invisible = 2,
		undead = 1,
		name = "ghoul", color=colors.TAN,
		kr_display_name = "구울",
		max_life = resolvers.rngavg(90,100),
		combat_armor = 2, combat_def = 7,
		resolvers.talents{
			T_STUN={base=1, every=10, max=5},
			T_BITE_POISON={base=1, every=10, max=5},
			T_ROTTING_DISEASE={base=1, every=10, max=5},
		},
		ai_state = { talent_in=4, },
		combat = { dam=resolvers.levelup(10, 1, 1), atk=resolvers.levelup(5, 1, 1), apr=3, dammod={str=0.6} },
	},
	ghast = {
		type = "undead", subtype = "ghoul",
		display = "z",
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		level_range = {1, nil}, exp_worth = 0,
		autolevel = "ghoul",
		ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=14, dex=12, mag=10, con=12 },
		rank = 2,
		size_category = 3,
		infravision = 10,
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, }, 
		open_door = true,
		blind_immune = 1,
		see_invisible = 2,
		undead = 1,
		name = "ghast", color=colors.UMBER,
		kr_display_name = "가스트",
		max_life = resolvers.rngavg(90,100),
		combat_armor = 2, combat_def = 7,
		resolvers.talents{
			T_STUN={base=1, every=10, max=5},
			T_BITE_POISON={base=1, every=10, max=5},
			T_ROTTING_DISEASE={base=1, every=10, max=5},
		},
		ai_state = { talent_in=4, },
		combat = { dam=resolvers.levelup(10, 1, 1), atk=resolvers.levelup(5, 1, 1), apr=3, dammod={str=0.6} },
	},
	ghoulking = {
		type = "undead", subtype = "ghoul",
		display = "z",
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		level_range = {1, nil}, exp_worth = 0,
		autolevel = "ghoul",
		ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=14, dex=12, mag=10, con=12 },
		rank = 2,
		size_category = 3,
		infravision = 10,
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=0.3, }, 
		open_door = true,
		blind_immune = 1,
		see_invisible = 2,
		undead = 1,
		name = "ghoulking", color={0,0,0},
		kr_display_name = "구울 왕",
		max_life = resolvers.rngavg(90,100),
		combat_armor = 3, combat_def = 10,
		ai_state = { talent_in=2, ai_pause=20 },
		rank = 3,
		combat = { dam=resolvers.levelup(30, 1, 1.2), atk=resolvers.levelup(8, 1, 1), apr=4, dammod={str=0.6} },
		resolvers.talents{
			T_STUN={base=3, every=9, max=7},
			T_BITE_POISON={base=3, every=9, max=7},
			T_ROTTING_DISEASE={base=4, every=9, max=7},
			T_DECREPITUDE_DISEASE={base=3, every=9, max=7},
			T_WEAKNESS_DISEASE={base=3, every=9, max=7},
		},
	},

	-- Advanced minions
	vampire = {
		type = "undead", subtype = "vampire",
		display = "V",
		combat = { dam=resolvers.levelup(resolvers.mbonus(30, 10), 1, 0.8), atk=10, apr=9, damtype=DamageType.DRAINLIFE, dammod={str=1.9} },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		autolevel = "warriormage",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=9, },
		stats = { str=12, dex=12, mag=12, con=12 },
		infravision = 10,
		life_regen = 3,
		size_category = 3,
		rank = 2,
		open_door = true,
		resolvers.inscriptions(1, "rune"),
		resolvers.sustains_at_birth(),
		resists = { [DamageType.COLD] = 80, [DamageType.NATURE] = 80, [DamageType.LIGHT] = -50,  },
		blind_immune = 1,
		confusion_immune = 1,
		see_invisible = 5,
		undead = 1,
		name = "vampire", color=colors.SLATE, image = "npc/vampire.png",
		kr_display_name = "흡혈귀",
		desc=[[사악한 기운이 감도는 인간형 언데드입니다. 날카로운 송곳니가 보입니다.]],
		max_life = resolvers.rngavg(70,80),
		combat_armor = 9, combat_def = 6,
		resolvers.talents{ T_STUN={base=1, every=7, max=5}, T_BLUR_SIGHT={base=1, every=7, max=5}, T_ROTTING_DISEASE={base=1, every=7, max=5}, },
	},
	m_vampire = {
		type = "undead", subtype = "vampire",
		display = "V",
		combat = { dam=resolvers.levelup(resolvers.mbonus(30, 10), 1, 0.8), atk=10, apr=9, damtype=DamageType.DRAINLIFE, dammod={str=1.9} },
		level_range = {1, nil}, exp_worth = 0,
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		autolevel = "warriormage",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=9, },
		stats = { str=12, dex=12, mag=12, con=12 },
		infravision = 10,
		life_regen = 3,
		size_category = 3,
		rank = 2,
		open_door = true,
		resolvers.inscriptions(1, "rune"),
		resolvers.sustains_at_birth(),
		resists = { [DamageType.COLD] = 80, [DamageType.NATURE] = 80, [DamageType.LIGHT] = -50,  },
		blind_immune = 1,
		confusion_immune = 1,
		see_invisible = 5,
		undead = 1,
		name = "master vampire", color=colors.GREEN, image = "npc/master_vampire.png",
		kr_display_name = "상급 흡혈귀",
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/master_vampire.png", display_h=2, display_y=-1}}},
		desc=[[로브를 걸친 인간형 언데드입니다. 몸에서 사악한 기운이 흐르고 있습니다.]],
		max_life = resolvers.rngavg(80,90),
		combat_armor = 10, combat_def = 8,
		ai = "dumb_talented_simple", ai_state = { talent_in=1, },
		resolvers.talents{ T_STUN={base=1, every=7, max=5}, T_BLUR_SIGHT={base=2, every=7, max=5}, T_PHANTASMAL_SHIELD={base=1, every=7, max=5}, T_ROTTING_DISEASE={base=2, every=7, max=5}, },
	},
	g_wight = {
		type = "undead", subtype = "wight",
		display = "W",
		combat = { dam=resolvers.mbonus(30, 10), atk=10, apr=9, damtype=DamageType.DRAINEXP },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		level_range = {1, nil}, exp_worth = 0,
		autolevel = "caster",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=4, },
		stats = { str=11, dex=11, mag=15, con=12 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		open_door = true,
		resolvers.sustains_at_birth(),
		resists = { [DamageType.COLD] = 80, [DamageType.FIRE] = 20, [DamageType.LIGHTNING] = 40, [DamageType.PHYSICAL] = 35, [DamageType.LIGHT] = -50, },
		poison_immune = 1,
		blind_immune = 1,
		see_invisible = 7,
		undead = 1,
		name = "grave wight", color=colors.SLATE, image="npc/grave_wight.png",
		kr_display_name = "묘지 와이트",
		desc=[[눈에 증오의 기운을 품은 유령입니다.]],
		max_life = resolvers.rngavg(70,80),
		combat_armor = 9, combat_def = 6,
		resolvers.talents{ T_FLAMESHOCK={base=2, every=5, max=6}, T_LIGHTNING={base=2, every=5, max=6}, T_GLACIAL_VAPOUR={base=2, every=5, max=6},
			T_MIND_DISRUPTION={base=2, every=5, max=6},
		},
	},
	b_wight = {
		type = "undead", subtype = "wight",
		display = "W",
		combat = { dam=resolvers.mbonus(30, 10), atk=10, apr=9, damtype=DamageType.DRAINEXP },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		level_range = {1, nil}, exp_worth = 0,
		autolevel = "caster",
		ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=4, },
		stats = { str=11, dex=11, mag=15, con=12 },
		infravision = 10,
		rank = 2,
		size_category = 3,
		open_door = true,
		resolvers.sustains_at_birth(),
		resists = { [DamageType.COLD] = 80, [DamageType.FIRE] = 20, [DamageType.LIGHTNING] = 40, [DamageType.PHYSICAL] = 35, [DamageType.LIGHT] = -50, },
		poison_immune = 1,
		blind_immune = 1,
		see_invisible = 7,
		undead = 1,
		name = "barrow wight", color=colors.LIGHT_RED, image="npc/barrow_wight.png",
		kr_display_name = "무덤 와이트",
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/barrow_wight.png", display_h=2, display_y=-1}}},
		desc=[[악몽이 실체화되어 나타난, 끔찍한 언데드입니다.]],
		max_life = resolvers.rngavg(80,90),
		combat_armor = 10, combat_def = 8,
		resolvers.talents{ T_FLAMESHOCK={base=3, every=5, max=7}, T_LIGHTNING={base=3, every=5, max=7}, T_GLACIAL_VAPOUR={base=3, every=5, max=7},
			T_MIND_DISRUPTION={base=3, every=5, max=7},
		},
	},
	dread = {
		type = "undead", subtype = "ghost",
		blood_color = colors.GREY,
		display = "G",
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		autolevel = "warriormage",
		ai = "dumb_talented_simple", ai_state = { talent_in=2, },
		stats = { str=14, dex=18, mag=20, con=12 },
		rank = 2,
		size_category = 3,
		infravision = 10,
		can_pass = {pass_wall=70},
		resists = {all = 35, [DamageType.LIGHT] = -70, [DamageType.DARKNESS] = 65},
		no_breath = 1,
		stone_immune = 1,
		confusion_immune = 1,
		fear_immune = 1,
		teleport_immune = 0.5,
		disease_immune = 1,
		poison_immune = 1,
		stun_immune = 1,
		blind_immune = 1,
		cut_immune = 1,
		see_invisible = 80,
		undead = 1,
		resolvers.sustains_at_birth(),
		name = "dread", color=colors.ORANGE, image="npc/dread.png",
		kr_display_name = "드레드",
		desc = [[보는 것만으로도 비명이 나올 정도의 끔찍한 존재입니다. 죽음의 화신이자, 그 흉물스러운 검은색 육신은 마치 이 세계의 의지에 반하여 존재하는 것 같습니다.]],
		level_range = {1, nil}, exp_worth = 0,
		max_life = resolvers.rngavg(90,100),
		combat_armor = 0, combat_def = resolvers.mbonus(10, 50),
		invisibility = resolvers.mbonus(5, 10),
		ai_state = { talent_in=4, },
		combat = { dam=resolvers.mbonus(45, 45), atk=resolvers.mbonus(25, 45), apr=100, dammod={str=0.5, mag=0.5} },
		resolvers.talents{
			T_BURNING_HEX={base=3, every=5, max=7},
			T_BLUR_SIGHT={base=4, every=6, max=8},
		},
	},
	lich = {
		type = "undead", subtype = "lich",
		display = "L",
		rank = 3, size = 3,
		combat = { dam=resolvers.rngavg(16,27), atk=16, apr=9, damtype=DamageType.DARKSTUN, dammod={mag=0.9} },
		body = { INVEN = 10, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1},
		equipment = resolvers.equip{
			{type="armor", subtype="cloth", ego_chance=75, autoreq=true},
			{type="armor", subtype="head", ego_chance=75, autoreq=true},
			{type="armor", subtype="feet", ego_chance=75, autoreq=true},
			{type="armor", subtype="cloak", ego_chance=75, autoreq=true},
			{type="jewelry", subtype="amulet", ego_chance=100, autoreq=true},
			{type="jewelry", subtype="ring", ego_chance=100, autoreq=true},
			{type="jewelry", subtype="ring", ego_chance=100, autoreq=true},
		},
		autolevel = "caster",
		ai = "tactical", ai_state = { talent_in=1, },
		ai_tactic = resolvers.tactic"ranged",
		stats = { str=8, dex=15, mag=20, wil=18, con=10, cun=18 },
		resists = { [DamageType.NATURE] = 90, [DamageType.FIRE] = 20, [DamageType.MIND] = 100, [DamageType.LIGHT] = -60, [DamageType.DARKNESS] = 95, [DamageType.BLIGHT] = 90 },
		resolvers.inscriptions(3, "rune"),
		instakill_immune = 1,
		stun_immune = 1,
		poison_immune = 1,
		undead = 1,
		blind_immune = 1,
		see_invisible = 100,
		infravision = 10,
		silence_immune = 0.7,
		fear_immune = 1,
		negative_regen = 0.4,	-- make their negative energies slowly increase
		mana_regen = 0.3,
		hate_regen = 2,
		open_door = 1,
		combat_spellpower = resolvers.mbonus(20, 10),
		combat_spellcrit = resolvers.mbonus(5, 5),
		resolvers.sustains_at_birth(),
		name = "lich", color=colors.DARK_BLUE,
		kr_display_name = "리치",
		desc=[[영원한 삶의 방법을 발견하였지만, 그 대가로 삶의 즐거움을 잃어버린 존재입니다. 이제 이들이 찾아다니는 것은 무한한 파괴 뿐입니다.]],
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_lich_lich.png", display_h=2, display_y=-1}}},
		level_range = {1, nil}, exp_worth = 0,
		rarity = 20,
		max_life = resolvers.rngavg(70,80),
		combat_armor = 10, combat_def = 20,
		resolvers.talents{
			T_HYMN_OF_SHADOWS=4,
			T_MOONLIGHT_RAY=5,
			T_SHADOW_BLAST=5,
			T_TWILIGHT_SURGE=3,
			T_STARFALL=3,
			T_FREEZE=3,
			T_MANATHRUST=5,
			T_CONGEAL_TIME=5,
--			T_CREEPING_DARKNESS=4,
			T_DARK_VISION=4,
			T_DARK_TORRENT=4,
--			T_DARK_TENDRILS=4,
			T_BONE_GRAB=4,
			T_BONE_SPEAR=4,
			-- Utility spells
			T_PHASE_DOOR=5,
			T_TELEPORT=5,
			T_STONE_SKIN=5,

			T_CALL_SHADOWS=3,
			T_FOCUS_SHADOWS=3,
			T_SHADOW_MAGES=1,
			T_SHADOW_WARRIORS=1,
		},
	},
}

function getAdvancedMinionChances(self)
	local cl = math.floor(self:getTalentLevel(self.T_MINION_MASTERY))
	if cl <= 1 then
		return { vampire=4, m_vampire=0, g_wight=0, b_wight=0, dread=0, lich=0 }
	elseif cl == 2 then
		return { vampire=4, m_vampire=2, g_wight=0, b_wight=0, dread=2, lich=0 }
	elseif cl == 3 then
		return { vampire=6, m_vampire=2, g_wight=2, b_wight=0, dread=2, lich=0 }
	elseif cl == 4 then
		return { vampire=6, m_vampire=4, g_wight=2, b_wight=2, dread=4, lich=2 }
	elseif cl == 5 then
		return { vampire=6, m_vampire=4, g_wight=4, b_wight=2, dread=4, lich=2 }
	elseif cl >= 6 then
		return { vampire=4, m_vampire=4, g_wight=4, b_wight=4, dread=6, lich=4 }
	end
end

local function getMinionChances(self)
	local cl = math.floor(self:getTalentLevel(self.T_CREATE_MINIONS))
	if cl <= 1 then
		return { d_skel_warrior=55, skel_warrior=10, a_skel_warrior=0, skel_archer=10, skel_m_archer=0, skel_mage=5,   ghoul=20, ghast=0, ghoulking=0 }
	elseif cl == 2 then
		return { d_skel_warrior=31, skel_warrior=15, a_skel_warrior=2, skel_archer=15, skel_m_archer=2, skel_mage=10,  ghoul=20, ghast=5, ghoulking=0 }
	elseif cl == 3 then
		return { d_skel_warrior=24, skel_warrior=15, a_skel_warrior=5, skel_archer=20, skel_m_archer=4, skel_mage=10,  ghoul=15, ghast=5, ghoulking=2 }
	elseif cl == 4 then
		return { d_skel_warrior=9, skel_warrior=20, a_skel_warrior=10, skel_archer=15, skel_m_archer=6, skel_mage=10,  ghoul=15, ghast=10, ghoulking=5 }
	elseif cl == 5 then
		return { d_skel_warrior=9, skel_warrior=20, a_skel_warrior=10, skel_archer=10, skel_m_archer=8, skel_mage=15,  ghoul=10, ghast=10, ghoulking=8 }
	elseif cl >= 6 then
		return { d_skel_warrior=0, skel_warrior=25, a_skel_warrior=15, skel_archer=10, skel_m_archer=10, skel_mage=15, ghoul=5, ghast=10, ghoulking=10 }
	end
end

local function makeMinion(self, lev)
	if self:knowTalent(self.T_MINION_MASTERY) then
		local adv = getAdvancedMinionChances(self)
		local tot = 0
		local list = {}
		for k, e in pairs(adv) do for i = 1, e do list[#list+1] = k end tot = tot + e end
		local sel = list[rng.range(1, 100)]
		if sel then return require("mod.class.NPC").new(minions_list[sel]) end
	end

	local chances = getMinionChances(self)
	local tot = 0
	local list = {}
	for k, e in pairs(chances) do for i = 1, e do list[#list+1] = k end tot = tot + e end

	local m = require("mod.class.NPC").new(minions_list[rng.table(list)])
	return m
end

newTalent{
	name = "Create Minions",
	kr_display_name = "또 다른 추종자",
	type = {"spell/necrotic-minions",1},
	require = spells_req1,
	points = 5,
	mana = 5,
	cooldown = 14,
	tactical = { ATTACK = 10 },
	requires_target = true,
	range = 0,
	on_learn = function(self, t)
		self:learnTalent(self.T_NECROTIC_AURA, true, 1)
	end,
	on_unlearn = function(self, t)
		self:unlearnTalent(self.T_NECROTIC_AURA, 1)
	end,
	radius = function(self, t)
		local aura = self:getTalentFromId(self.T_NECROTIC_AURA)
		return aura.getRadius(self, aura)
	end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	on_pre_use = function(self, t)
		local p = self:isTalentActive(self.T_NECROTIC_AURA)
		if not p then return end
		if p.souls < 1 then return end

		local nb = t.getMax(self, t)
		if math.min(nb, p.souls) < 1 then return end
		return true
	end,
	getMax = function(self, t) return math.floor(self:getTalentLevel(t)) - necroGetNbSummon(self) end,
	getLevel = function(self, t)
		local raw = self:getTalentLevelRaw(t)
		if raw <= 0 then return -8 end
		if raw > 8 then return 8 end
		return ({-6, -4, -2, 0, 2, 4, 6, 8})[raw]
	end,
	action = function(self, t)
		local p = self:isTalentActive(self.T_NECROTIC_AURA)
		local nb = t.getMax(self, t)
		nb = math.min(nb, p.souls)
		local lev = t.getLevel(self, t)

		-- Summon minions in a cone
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local possible_spots = {}
		self:project(tg, x, y, function(px, py)
			if not game.level.map:checkAllEntities(px, py, "block_move") then
				possible_spots[#possible_spots+1] = {x=px, y=py}
			end
		end)
		for i = 1, nb do
			local minion = makeMinion(self, self:getTalentLevel(t))
			local pos = rng.tableRemove(possible_spots)
			if minion and pos then
				p.souls = p.souls - 1
				necroSetupSummon(self, minion, pos.x, pos.y, lev, true)
				if self:knowTalent(self.T_BLIGHTED_SUMMONING) then 
					if minion.subtype == "skeleton" then minion:learnTalent(minion.T_BONE_GRAB, true, 3) end
					if minion.subtype == "giant" then minion:learnTalent(minion.T_BONE_SHIELD, true, 3) end
					if minion.subtype == "ghoul" then minion:learnTalent(minion.T_BLOOD_LOCK, true, 3) end
					if minion.subtype == "vampire" or minion.subtype == "lich" then minion:learnTalent(minion.T_DARKFIRE, true, 3) end
					if minion.subtype == "ghost" or minion.subtype == "wight" then minion:learnTalent(minion.T_BLOOD_BOIL, true, 3) end
				end
			end
		end

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local nb = t.getMax(self, t)
		local lev = t.getLevel(self, t)
		local c = getMinionChances(self)
		return ([[강렬한 언데드의 기운을 불어넣어, 사령술의 기운에 의해 붙잡힌 영혼을 언데드 추종자로 되살려냅니다. (최대 %d 마리 유지 가능)
		언데드 추종자는 사령술의 기운이 깃든 범위 내에서만 일으킬 수 있습니다.
		언데드 추종자의 레벨은 시전자의 %+d 입니다.
		생성될 언데드 추종자의 확률은 다음과 같습니다 :
		부패한 스켈레톤 전사 : %d%%
		스켈레톤 전사 : %d%%
		중무장한 스켈레톤 전사: %d%%
		스켈레톤 궁수 : %d%%
		상급 스켈레톤 궁수 : %d%%
		스켈레톤 마법사 : %d%%
		구울 : %d%%
		가스트 : %d%%
		구울 왕 : %d%%
		]]):
		format(nb, lev, c.d_skel_warrior, c.skel_warrior, c.a_skel_warrior, c.skel_archer, c.skel_m_archer, c.skel_mage, c.ghoul, c.ghast, c.ghoulking)
	end,
}

newTalent{
	name = "Aura Mastery",
	kr_display_name = "사령술의 기운 수련",
	type = {"spell/necrotic-minions",2},
	require = spells_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:forceUseTalent(self.T_NECROTIC_AURA, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
		self:forceUseTalent(self.T_NECROTIC_AURA, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
	end,
	on_unlearn = function(self, t)
		self:forceUseTalent(self.T_NECROTIC_AURA, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
		self:forceUseTalent(self.T_NECROTIC_AURA, {ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
	end,
	info = function(self, t)
		return ([[사령술사가 더 사악해질수록, 사령술의 기운도 더 강력해집니다. 사령술의 기운이 %d 칸 더 넓은 곳까지 퍼지며, 범위 밖에서 언데드 추종자들이 입는 피해가 %d%% 감소합니다.]]):
		format(self:getTalentLevelRaw(t), self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Surge of Undeath",
	kr_display_name = "죽지 못하는 자들의 분노",
	type = {"spell/necrotic-minions",3},
	require = spells_req3,
	points = 5,
	mana = 45,
	cooldown = 20,
	tactical = { ATTACKAREA = 2 },
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 60) end,
	getCrit = function(self, t) return self:combatTalentSpellDamage(t, 6, 25) end,
	getAPR = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	action = function(self, t)
		local apply = function(a)
			a:setEffect(a.EFF_SURGE_OF_UNDEATH, 6, {power=t.getPower(self, t), apr=t.getAPR(self, t), crit=t.getCrit(self, t)})
		end

		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.necrotic_minion then apply(act) end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.necrotic_minion then apply(act) end
			end
		end

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[모든 추종자들을 강화시켜 물리력과 주문력, 그리고 정확도를 %d 올립니다. 또한 방어도 관통력이 %d / 치명타율이 %d 상승합니다.
		이 효과는 6 턴 동안 지속되며, 주문력의 영향을 받아 증가합니다.]]):
		format(t.getPower(self, t), t.getAPR(self, t), t.getCrit(self, t))
	end,
}

newTalent{
	name = "Dark Empathy",
	kr_display_name = "어둠의 공감",
	type = {"spell/necrotic-minions",4},
	require = spells_req4,
	points = 5,
	mode = "passive",
	getPerc = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	info = function(self, t)
		return ([[언데드 추종자에게 힘을 나눠줘서, 추종자들의 모든 내성과 속성 저항력을 %d%% 올립니다.
		그리고 시전자의 공격에 의해 언데드 추종자가 피해를 받을 때, 피해량이 %d%% 감소합니다.
		이 효과는 주문력의 영향을 받아 증가합니다.]]):
		format(t.getPerc(self, t), self:getTalentLevelRaw(t) * 20)
	end,
}
