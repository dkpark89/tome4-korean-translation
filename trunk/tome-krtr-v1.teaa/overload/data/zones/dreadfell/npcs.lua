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

load("/data/general/npcs/skeleton.lua", rarity(0))
load("/data/general/npcs/ghoul.lua", rarity(1))
load("/data/general/npcs/wight.lua", rarity(3))
load("/data/general/npcs/vampire.lua", rarity(3))
load("/data/general/npcs/ghost.lua", rarity(3))

load("/data/general/npcs/all.lua", rarity(4, 35))

-- Not normally appearing, used for the Pale Drake summons
load("/data/general/npcs/bone-giant.lua", function(e) if e.rarity then e.bonegiant_rarity = e.rarity; e.rarity = nil end end)

local Talents = require("engine.interface.ActorTalents")

-- The boss of Dreadfell, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "THE_MASTER",
	allow_infinite_dungeon = true,
	faction = "dreadfell",
	type = "undead", subtype = "vampire", unique = true, image = "npc/the_master.png",
	name = "The Master",
	kr_display_name = "지배자",
	display = "V", color=colors.VIOLET,
	desc = [[흐드러진 로브와 강렬한 공포의 오러의 힘을 가진 무서운 흡혈 생물입니다. 그 차갑고 건장한 피부는 탐욕과 악의로 이 세상에 매달려 있게 하고, 그 눈은 정신의 힘을 폭로하는 듯 합니다. 주위의 모든 존재는 그의 의지에 완전히 굴종하여, 그가 초연히 서서 한심하게 간섭하는 부하가 필요없음을 말하여도 그의 적과 싸워 도와주려 합니다. 당신의 이목은 그의 손에 들린 주변의 대기에서 생명력을 빨아들이는 어두운 지팡이에 쏠립니다. 고대의 존재이며 위험하고 무서우며, 그 시선은 당신을 강렬한 욕망으로 채웁니다.]],
	killer_message = "and raised as his tortured undead thrall",
	level_range = {23, nil}, exp_worth = 2,
	max_life = 350, life_rating = 19, fixed_rating = true,
	max_mana = 165,
	max_stamina = 145,
	rank = 5,
	size_category = 3,
	infravision = 10,
	stats = { str=19, dex=19, cun=34, mag=25, con=16 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="greatsword", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="heavy", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
		{type="jewelry", subtype="amulet", defined="AMULET_DREAD", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{check=function() return game.zone.is_dreadfell end, chance=100, nb=1, {type="weapon", subtype="staff", defined="STAFF_ABSORPTION"} },

	summon = {
		{type="undead", number=2, hasxp=true},
	},

	instakill_immune = 1,
	blind_immune = 1,
	stun_immune = 0.7,
	see_invisible = 20,
	undead = 1,
	self_resurrect = 1,
	open_door = 1,
	necrotic_aura_base_souls = 10,

	resolvers.talents{
		[Talents.T_HIDDEN_RESOURCES] = 1,

		[Talents.T_AURA_MASTERY] = 6,
		[Talents.T_CREATE_MINIONS]={base=4, every=5, max=7},
		[Talents.T_RIGOR_MORTIS]={base=3, every=5, max=5},
		[Talents.T_CIRCLE_OF_DEATH]={base=3, every=5, max=5},
		[Talents.T_SURGE_OF_UNDEATH]={base=3, every=5, max=5},
		[Talents.T_WILL_O__THE_WISP]={base=3, every=5, max=5},
		[Talents.T_VAMPIRIC_GIFT]={base=2, every=7, max=5},

		[Talents.T_CONGEAL_TIME]={base=2, every=5, max=5},
		[Talents.T_MANATHRUST]={base=4, every=5, max=8},
		[Talents.T_FREEZE]={base=4, every=5, max=8},
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_STRIKE]={base=3, every=5, max=7},

		[Talents.T_ARMOUR_TRAINING]={base=2, every=8, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=2, every=8, max=5},
		[Talents.T_STUNNING_BLOW]={base=1, every=5, max=5},
		[Talents.T_RUSH]={base=4, every=5, max=8},
		[Talents.T_SPELL_SHIELD]={base=4, every=5, max=8},
		[Talents.T_BLINDING_SPEED]={base=4, every=5, max=8},
		[Talents.T_PERFECT_STRIKE]={base=3, every=5, max=7},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(3, {"shielding rune", "shielding rune", "invisibility rune", "speed rune"}),
	resolvers.inscriptions(1, {"manasurge rune"}),

	on_act = function(self)
		if rng.percent(10) and self:isTalentActive(self.T_NECROTIC_AURA) then
			local p = self:isTalentActive(self.T_NECROTIC_AURA)
			p.souls = util.bound(p.souls + 1, 0, p.souls_max)
		end
	end,

	on_die = function(self, who)
		game.state:activateBackupGuardian("PALE_DRAKE", 1, 40, "It has been months since the hero cleansed the Dreadfell, yet rumours are growing: evil is back.")

		world:gainAchievement("VAMPIRE_CRUSHER", game.player:resolveSource())
		game.player:resolveSource():grantQuest("dreadfell")
		game.player:resolveSource():setQuestStatus("dreadfell", engine.Quest.COMPLETED)

		local ud = {}
		if not profile.mod.allow_build.undead_skeleton then ud[#ud+1] = "undead_skeleton" end
		if not profile.mod.allow_build.undead_ghoul then ud[#ud+1] = "undead_ghoul" end
		if #ud == 0 then return end
		game:setAllowedBuild("undead")
		game:setAllowedBuild(rng.table(ud), true)
	end,
}

-- The boss of Dreadfell, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "PALE_DRAKE",
	allow_infinite_dungeon = true,
	faction = "dreadfell",
	type = "undead", subtype = "skeleton", unique = true,
	name = "Pale Drake",
	kr_display_name = "창백한 드레이크",
	display = "s", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_skeleton_pale_drake.png", display_h=2, display_y=-1}}},
	desc = [[지배자의 소멸 이후 '불안의 영역'의 제어권을 가진 사악한 해골 마도사입니다.]],
	level_range = {40, nil}, exp_worth = 3,
	max_life = 450, life_rating = 21, fixed_rating = true,
	rank = 4,
	size_category = 3,
	infravision = 10,
	stats = { str=19, dex=19, cun=44, mag=25, con=16 },
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, NECK=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="RUNED_SKULL", random_art_replace={chance=75}} },

	summon = {
		{type="undead", subtype="bone giant", special_rarity="bonegiant_rarity", number=2, hasxp=true},
	},

	instakill_immune = 1,
	blind_immune = 1,
	stun_immune = 0.7,
	see_invisible = 100,
	undead = 1,
	self_resurrect = 1,
	open_door = 1,

	resists = { [DamageType.FIRE] = 100, },

	resolvers.talents{
		[Talents.T_SUMMON]=1,

		[Talents.T_WILDFIRE]={base=5, every=5, max=8},

		[Talents.T_FLAME]={base=5, every=5, max=8},
		[Talents.T_FLAMESHOCK]={base=5, every=5, max=8},
		[Talents.T_INFERNO]={base=5, every=5, max=8},
		[Talents.T_MANATHRUST]={base=5, every=5, max=8},

		[Talents.T_CURSE_OF_DEATH]={base=5, every=5, max=8},
		[Talents.T_CURSE_OF_VULNERABILITY]={base=5, every=5, max=8},
		[Talents.T_BONE_SPEAR]={base=5, every=5, max=8},
		[Talents.T_DRAIN]={base=5, every=5, max=8},

		[Talents.T_PHASE_DOOR]=2,

		[Talents.T_ELEMENTAL_SURGE] = 1,
	},
	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(4, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),
}

-- Dreadfell uniques
newEntity{ define_as = "BORFAST",
	allow_infinite_dungeon = true,
	faction = "dreadfell",
	type = "undead", subtype = "ghoul", unique = true,
	name = "Borfast the Broken",
	kr_display_name = "망가진 보르파스트",
	display = "g", color=colors.VIOLET,
	desc = [[이 키작고 느릿느릿한 형상에게는 두꺼운 피부가 느슨하게 매달려 있습니다. 턱에서 뻗어나온 수염다발이 한때는 웅장한 드워프 수염이었다는 증거로 남아있습니다. 얼굴 반쪽은 산에 녹아 눌어붙었고, 살점은 뼈대로부터 녹아 떨어져 나갔으며, 눈알이 빠져나와 매달려 있습니다. 그 눈에는 고유한 슬픔이 보이고, 그 걸음걸이는 체념에 빠져있습니다.
유명한 자랑스러운 영웅을 이렇게 무서운 운명으로 빠뜨린 것은 무엇일까요?]],
	killer_message = "and offered to his dark Master",
	level_range = {20, nil}, exp_worth = 2,
	max_life = 350, life_rating = 19, fixed_rating = true,
	max_stamina = 200,
	rank = 3.5,
	rarity = 50,
	size_category = 3,
	infravision = 10,
	stats = { str=30, dex=20, con=30 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, HANDS=1, FEET=1, },
	equipment = resolvers.equip{
		{type="weapon", subtype="mace", ego_chance=100, autoreq=true, forbid_power_source={antimagic=true}, force_drop=true,},
		{type="armor", subtype="shield", ego_chance=100, autoreq=true, forbid_power_source={antimagic=true}, force_drop=true,},
		{type="armor", subtype="massive", defined="BORFAST_CAGE", random_art_replace={chance=75}, autoreq=true, tome_drops="boss"},
		{type="armor", subtype="head", ego_chance=75, forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="hands", ego_chance=75, forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="feet", ego_chance=75, forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="BORFAST_LETTER"} },

	instakill_immune = 1,
	undead = 1,
	poison_immune = 0.8,
	cut_immune = 1,
	stun_immune = 0.5,
	fear_immune = 1,
	global_speed_base = 0.8,

	resolvers.talents{
		[Talents.T_SHIELD_PUMMEL]={base=5, every=5, max=6},
		[Talents.T_ASSAULT]={base=1, every=5, max=6},
		[Talents.T_RUSH]={base=1, every=5, max=6},
		[Talents.T_SPELL_SHIELD]={base=3, every=5, max=6},
		[Talents.T_PERFECT_STRIKE]={base=3, every=5, max=6},

		[Talents.T_SHIELD_WALL]=6,
		[Talents.T_SHIELD_EXPERTISE]=6,

		[Talents.T_THICK_SKIN]={base=3, every=5, max=5},
		[Talents.T_ARMOUR_TRAINING]={base=2, every=8, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=5},
		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=5},

		[Talents.T_VITALITY]={base=4, every=5, max=6},
		[Talents.T_UNFLINCHING_RESOLVE]=6,
		[Talents.T_DAUNTING_PRESENCE]={base=3, every=5, max=5},

		[Talents.T_GHOULISH_LEAP]={base=1, every=5, max=5},
		[Talents.T_RETCH]=5,
		[Talents.T_GNAW]=1,
	},
	resolvers.sustains_at_birth(),

	autolevel = "tank",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"tank",
	resolvers.inscriptions(1, {"shielding rune",}),

}

newEntity{ define_as = "ALETTA",
	allow_infinite_dungeon = true,
	faction = "dreadfell",
	type = "undead", subtype = "ghost", unique = true,
	name = "Aletta Soultorn", female=1,
	kr_display_name = "알레타의 영혼조각",
	display = "G", color=colors.VIOLET,
	desc = [[무엇이 한때 황홀하게 아름다웠던 하이어 여성을 이제는 절망으로 가득찬 유령의 모습오르 만들었을까요. 그녀의 날씬하고 우아한 모습은 허공으로 사라져버리고, 넝마같은 로브만이 아직도 이상하게 남아있습니다. 유령의 얼굴은 신경질적이고 고통에 차 보이며, 빛나는 눈을 빠르게 앞뒤로 움직이고 있습니다.
가끔씩 그녀는 무언가를 보려하는 것 같습니다. 턱이 당겨지면, 얼굴 전체가 쪼개지면서 고통과 고뇌로 가득찬 부정한 울음섞인 비명을 지릅니다.]],
	killer_message = "and offered to her dark Master",
	level_range = {20, nil}, exp_worth = 2,
	max_life = 150, life_rating = 10, fixed_rating = true,
	hate_regen = 1,
	rank = 3.5,
	rarity = 50,
	size_category = 3,
	infravision = 10,
	stats = { str=14, dex=18, mag=20, wil=20, cun=20, con=12 },

	instakill_immune = 1,
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

	combat_armor = 0, combat_def = 10,
	stealth = 20,

	combat = { dam=5, atk=5, apr=100, dammod={str=0.5, mag=0.5} },

	can_pass = {pass_wall=70},
	dont_pass_target = true,
	resists = {all = 35, [DamageType.LIGHT] = -70, [DamageType.DARKNESS] = 65},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, NECK=1, FINGER = 2, BODY=1, HEAD=1, },
	equipment = resolvers.equip{
		{type="armor", subtype="cloth", ego_chance=75, forbid_power_source={antimagic=true}, autoreq=true,},
		{type="armor", subtype="head", defined="ALETTA_DIADEM", random_art_replace={chance=75}, autoreq=true, tome_drops="boss"},
		{type="jewelry", subtype="amulet", ego_chance=100, autoreq=true, forbid_power_source={antimagic=true}, force_drop=true},
		{type="jewelry", subtype="ring", ego_chance=100, autoreq=true, forbid_power_source={antimagic=true}, force_drop=true},
		{type="jewelry", subtype="ring", ego_chance=75, forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="ALETTA_LETTER"} },

	resolvers.talents{
		[Talents.T_SHRIEK]=4,
		[Talents.T_SILENCE]={base=2, every=10, max=5},
		[Talents.T_MIND_DISRUPTION]={base=3, every=7, max=6},

		[Talents.T_RUINED_EARTH]={base=3, every=7, max=5},
		[Talents.T_GLOOM]={base=3, every=7, max=5},
		[Talents.T_WEAKNESS]={base=3, every=7, max=5},
		[Talents.T_SANCTUARY]=5,

		[Talents.T_INSTILL_FEAR]=5,
		[Talents.T_HEIGHTEN_FEAR]=5,
		[Talents.T_TYRANT]=5,
	--	[Talents.T_PANIC]=5, -- Doesn't work on players so commented out for now

	},
	resolvers.sustains_at_birth(),

	autolevel = "wildcaster",
	ai = "tactical", ai_state = { ai_target="target_player_radius", ai_move="move_complex", sense_radius=40, talent_in=1, },
	ai_tactic = resolvers.tactic"ranged",
}

newEntity{ define_as = "FILIO",
	allow_infinite_dungeon = true,
	faction = "dreadfell",
	type = "undead", subtype = "skeleton", unique = true,
	name = "Filio Flightfond",
	kr_display_name = "비행 필리오",
	display = "s", color=colors.VIOLET,
	desc = [[발 밑에 완충제를 붙인 작고 은밀한 모습의 해골입니다. 재빠르고 조용히 움직이고, 쉽게 그림자와 동화됩니다. 한손에는 투석구를, 다른 손에는 단검을 쥐고 있습니다.
그 텅힌 두개골에는 교활한 공기로 가득차있고, 그 텅빈 눈동자는 그가 계획히는 속임수와 전술을 드러내지 않습니다.]],
	killer_message = "and offered to his dark Master",
	level_range = {20, nil}, exp_worth = 2,
	max_life = 250, life_rating = 15, fixed_rating = true,
	max_stamina = 200,
	rank = 3.5,
	rarity = 50,
	size_category = 3,
	infravision = 10,
	stats = { str=20, dex=20, cun=10, wil=40 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, QUIVER=1  },
	equipment = resolvers.equip{
		{type="weapon", subtype="sling", defined="HARESKIN_SLING", random_art_replace={chance=0}, autoreq=true, tome_drops="boss"},
		{type="weapon", subtype="dagger", ego_chance=100, autoreq=true, forbid_power_source={antimagic=true}, force_drop=true},
		{type="ammo", subtype="shot", ego_chance=100, autoreq=true, forbid_power_source={antimagic=true}, force_drop=true},
	},
	resolvers.drops{chance=100, nb=1, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="FILIO_LETTER"} },

	open_door = 1,
	instakill_immune = 1,
	cut_immune = 1,
	blind_immune = 1,
	fear_immune = 1,
	poison_immune = 1,
	undead = 1,

	resolvers.talents{
		[Talents.T_SHOOT]=1,
		[Talents.T_INERTIAL_SHOT]=3,

		[Talents.T_STEALTH]={base=5, every=6, max=7},
		[Talents.T_SHADOWSTRIKE]={base=1, every=6, max=7},
		[Talents.T_HIDE_IN_PLAIN_SIGHT]={base=1, every=6, max=7},

		[Talents.T_SMOKE_BOMB]={base=2, every=6, max=7},
		[Talents.T_DISENGAGE]={base=3, every=6, max=7},
		[Talents.T_EVASION]={base=5, every=6, max=7},
		[Talents.T_PIERCING_SIGHT]={base=3, every=6, max=7},

		[Talents.T_DUAL_STRIKE]={base=2, every=6, max=7},
		[Talents.T_DUAL_WEAPON_DEFENSE]={base=5, every=6, max=7},
		[Talents.T_LETHALITY]={base=1, every=6, max=5},
		[Talents.T_WILLFUL_COMBAT]={base=5, every=6, max=6},

		[Talents.T_KNIFE_MASTERY]={base=2, every=10, max=5},
		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=5},

		[Talents.T_BONE_ARMOUR]={base=3, every=5, max=5},
		[Talents.T_RESILIENT_BONES]={base=3, every=5, max=5},
		[Talents.T_SKELETON_REASSEMBLE]={base=3, every=5, max=5},
	},
	resolvers.sustains_at_birth(),

	autolevel = "slinger",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"survivor",
	resolvers.inscriptions(1, {"invisibility rune",}),

	on_move = function(self, x, y, self, force)
		if not force and rng.percent(10) then
			local traps = { self.T_BEAR_TRAP, self.T_CATAPULT_TRAP }
			self:forceUseTalent(rng.table(traps), {ignore_energy=true, ignore_resources=true, ignore_cd=true, force_target=self})
		end
	end,
}
