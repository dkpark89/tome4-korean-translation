-- ToME - Tales of Middle-Earth
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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- This file describes artifacts associated with a boss of the game, they have a high chance of dropping their respective ones, but they can still be found elsewhere

newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true}, --How is this nature based?
	define_as = "LONGSWORD_WINTERTIDE", rarity=false, unided_name = "glittering longsword", image="object/artifact/wintertide.png",
	name = "Wintertide", unique=true,
	kr_display_name = "밀려오는 겨울", kr_unided_name = "반짝거리는 장검",
	desc = [[이 검의 칼날 주변의 공기가 얼어붙으면서, 주변의 모든 열기를 흡수하고 있습니다.
제 1차 매혹의 전투가 있던 암흑의 시기에 콘클라베에서 그들의 전투지휘자를 위해 만들었다고 알려져 있습니다.]],
	require = { stat = { str=35 }, },
	level_range = {35, 45},
	rarity = 280,
	cost = 2000,
	material_level = 5,
	combat = {
		dam = 45,
		apr = 10,
		physcrit = 10,
		dammod = {str=1},
		damrange = 1.4,
		melee_project={[DamageType.ICE] = 45},
	},
	wielder = {
		lite = 1,
		see_invisible = 2,
		resists={[DamageType.COLD] = 25},
		inc_damage = { [DamageType.COLD] = 20 },
	},
	max_power = 18, power_regen = 1,
	use_power = { name = "얼음 폭발 생성", power = 8,
		use = function(self, who)
			local tg = {type="ball", range=0, radius=4, selffire=false}
			who:project(tg, who.x, who.y, engine.DamageType.ICE, 40 + (who:getMag() + who:getWil()), {type="freeze"})
			game:playSoundNear(who, "talents/ice")
			game.logSeen(who, "%s %s의 힘을 불러옵니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), (self.kr_display_name or self.name))
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LITE", define_as = "WINTERTIDE_PHIAL",
	power_source = {arcane=true},
	unided_name = "phial filled with darkness", unique = true, image="object/artifact/wintertide_phial.png",
	name = "Wintertide Phial", color=colors.DARK_GREY,
	kr_display_name = "밀려오는 겨울의 물약", kr_unided_name = "어둠으로 가득찬 약병",
	desc = [[이 약병은 어둠으로 가득차 있고, 사용자의 생각을 깨끗하게 만듭니다.]],
	level_range = {1, 10},
	rarity = 200,
	encumber = 2,
	cost = 50,
	material_level = 1,

	wielder = {
		lite = 1,
		infravision = 6,
	},

	max_power = 60, power_regen = 1,
	use_power = { name = "정신의 정화 (몇가지 나쁜 정신 효과 제거)", power = 40,
		use = function(self, who)
			local target = who
			local effs = {}
			local known = false

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "mental" and e.status == "detrimental" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			for i = 1, 3 + math.floor(who:getMag() / 10) do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
					known = true
				end
			end
			game.logSeen(who, "%s의 정신이 깨끗해졌습니다!", (who.kr_display_name or who.name):capitalize())
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	define_as = "FIERY_CHOKER", rarity=false,
	unided_name = "flame-wrought amulet",
	name = "Fiery Choker", unique=true, image="object/artifact/fiery_choker.png",
	kr_display_name = "불타는 목고리", kr_unided_name = "불꽃으로 장식된 목걸이", --@@ choker의 어감을 위해 일부러 목고리라 번역했습니다.
	desc = [[순수한 불꽃으로 만들어진 목고리로, 착용자의 목에 둘러진채 계속 무늬가 변합니다. 그 불길이 착용자에게 해를 끼치지는 않는 듯 합니다.]],
	level_range = {32, 42},
	rarity = 220,
	cost = 190,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 3 },
		combat_spellpower = 7,
		combat_spellcrit = 8,
		resists = {
			[DamageType.FIRE] = 20,
			[DamageType.COLD] = -20,
		},
		inc_damage={
			[DamageType.FIRE] = 10,
			[DamageType.COLD] = -5,
		},
		damage_affinity={
			[DamageType.FIRE] = 30,
		},
		blind_immune = 0.4,
	},
	talent_on_spell = { {chance=10, talent=Talents.T_VOLCANO, level=3} },
}

-- Artifact, dropped by Rantha
newEntity{ base = "BASE_LEATHER_BOOT",
	power_source = {nature=true},
	define_as = "FROST_TREADS",
	unided_name = "ice-covered boots",
	name = "Frost Treads", unique=true, image="object/artifact/frost_treads.png",
	kr_display_name = "서리 발자국", kr_unided_name = "얼음덮힌 신발",
	desc = [[가죽 신발입니다. 건드리면 차갑고, 차가운 푸른 빛이 납니다.]],
	require = { stat = { dex=16 }, },
	level_range = {10, 18},
	material_level = 2,
	rarity = 220,
	cost = 40,

	wielder = {
		lite = 1,
		combat_armor = 4,
		combat_def = 1,
		fatigue = 7,
		inc_damage = {
			[DamageType.COLD] = 15,
		},
		resists = {
			[DamageType.COLD] = 20,
			[DamageType.NATURE] = 10,
		},
		inc_stats = { [Stats.STAT_STR] = 4, [Stats.STAT_DEX] = 4, [Stats.STAT_CUN] = 4, },
	},
}

newEntity{ base = "BASE_HELM",
	power_source = {technique=true},
	define_as = "DRAGON_SKULL",
	name = "Dragonskull Helm", unique=true, unided_name="skull helm", image = "object/artifact/dragonskull_helmet.png",
	kr_display_name = "용뼈 투구", kr_unided_name = "두개골 투구",
	desc = [[이 금이 가있고 표백된 두개골에는 용의 능력이 아직 어느 정도 남아있습니다.]],
	require = { stat = { wil=24 }, },
	level_range = {45, 50},
	material_level = 5,
	rarity = 280,
	cost = 200,

	wielder = {
		resists = {
			[DamageType.FIRE] = 15,
			[DamageType.COLD] = 15,
			[DamageType.LIGHTNING] = 15,
		},
		esp = {dragon=1},
		combat_armor = 2,
		fatigue = 12,
		combat_physresist = 12,
		combat_mentalresist = 12,
		combat_spellresist = 12,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {nature=true},
	define_as = "EEL_SKIN", rarity=false, image = "object/artifact/eel_skin_armor.png",
	name = "Eel-skin armour", unique=true,
	unided_name = "slippery armour", color=colors.VIOLET,
	kr_display_name = "뱀장어 가죽 갑옷", kr_unided_name = "미끈거리는 갑옷",
	desc = [[이 갑옷은 많은 뱀장어의 가죽 조각을 이어 붙여 만든 것입니다. 우엑.]],
	level_range = {5, 12},
	rarity = 200,
	cost = 500,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 2, [Stats.STAT_CUN] = 3,  },
		poison_immune = 0.3,
		combat_armor = 1,
		combat_def = 10,
		fatigue = 2,
	},

	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_CALL_LIGHTNING, level=2, power = 18 },
	talent_on_wild_gift = { {chance=10, talent=Talents.T_CALL_LIGHTNING, level=2} },
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	power_source = {nature=true},
	define_as = "CHROMATIC_HARNESS", rarity=false, image = "object/artifact/armor_chromatic_harness.png",
	name = "Chromatic Harness", unique=true,
	unided_name = "multi-hued scale-mail armour", color=colors.VIOLET,
	kr_display_name = "무지개빛 작업복", kr_unided_name = "여러색의 비늘 갑옷",
	desc = [[이 용 비늘 작업복은 여러가지 색깔로 반짝이고, 겉보기에는 무질서해보이는 방식으로 빠르게 색이 변합니다.]],
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	material_level = 5,
	wielder = {
		talent_cd_reduction={[Talents.T_ICE_BREATH]=3, [Talents.T_FIRE_BREATH]=3, [Talents.T_SAND_BREATH]=3, [Talents.T_LIGHTNING_BREATH]=3, [Talents.T_CORROSIVE_BREATH]=3,},
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 4, [Stats.STAT_STR] = 6, [Stats.STAT_LCK] = 10, },
		blind_immune = 0.5,
		stun_immune = 0.25,
		knockback_immune = 0.5,
		esp = { dragon = 1 },
		combat_def = 10,
		combat_armor = 14,
		fatigue = 16,
		resists = {
			[DamageType.COLD] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.FIRE] = 20,
			[DamageType.ACID] = 20,
			[DamageType.PHYSICAL] = 20,
		},
	},
}

newEntity{ base = "BASE_RING",
	power_source = {technique=true},
	define_as = "PRIDE_GLORY", rarity=false,
	name = "Glory of the Pride", unique=true, image="object/artifact/glory_of_the_pride.png",
	kr_display_name = "부족의 영광", kr_unided_name = "짙은 검정 반지",
	desc = [[오크 무리의 전장의 지배자 '그루쉬낙'이 가장 귀중하게 여기는 보물입니다. 이 황금 반지는 이제는 잊혀진 오크 말이 새겨져 있습니다.]],
	unided_name = "deep black ring",
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	material_level = 5,
	wielder = {
		max_mana = -40,
		max_stamina = 40,
		combat_physresist = 45,
		confusion_immune = 0.5,
		combat_atk = 10,
		combat_dam = 10,
		combat_def = 5,
		combat_armor = 10,
		fatigue = -15,
		talent_cd_reduction={
			[Talents.T_RUSH]=6,
		},
		inc_damage={ [DamageType.PHYSICAL] = 8, },
	},
}

newEntity{ base = "BASE_RING",
	power_source = {psionic=true},
	define_as = "NIGHT_SONG", rarity=false,
	name = "Nightsong", unique=true, image = "object/artifact/ring_nightsong.png",
	kr_display_name = "밤의 노래", kr_unided_name = "흑요석 반지",
	desc = [[장식이 없는 경사진 검은 반지입니다. 그 위로 어둠의 덩쿨손이 기어나옷 것 같이 느껴집니다.]],
	unided_name = "obsidian ring",
	level_range = {15, 23},
	rarity = 250,
	cost = 500,
	material_level = 2,
	wielder = {
		max_stamina = 25,
		combat_def = 6,
		fatigue = -7,
		inc_stats = { [Stats.STAT_CUN] = 6 },
		combat_mentalresist = 13,
		talent_cd_reduction={
			[Talents.T_SHADOWSTEP]=1,
		},
		inc_damage={ [DamageType.PHYSICAL] = 5, },
	},

	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_DARK_TENDRILS, level=2, power = 40 },
}

newEntity{ base = "BASE_HELM",
	power_source = {nature=true},
	define_as = "HELM_OF_GARKUL",
	unided_name = "tribal helm",
	name = "Steel Helm of Garkul", unique=true, image="object/artifact/helm_of_garkul.png",
	kr_display_name = "가르쿨의 강철 투구", kr_unided_name = "인디언 투구",
	desc = [[가장 훌륭한 삶을 보낸 오크 중 하나인 포식자 가르쿨이 사용하던 거대한 투구입니다.]],
	require = { stat = { str=16 }, },
	level_range = {12, 22},
	rarity = 200,
	cost = 500,
	material_level = 2,
	skullcracker_mult = 5,

	wielder = {
		combat_armor = 6,
		fatigue = 8,
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_CON] = 5, [Stats.STAT_WIL] = 4 },
		inc_damage={ [DamageType.PHYSICAL] = 10, },
		combat_physresist = 12,
		combat_mentalresist = 12,
		combat_spellresist = 12,
		talents_types_mastery = {["technique/thuggery"]=0.2},
	},

	set_list = { {"define_as","SET_GARKUL_TEETH"} },
	on_set_complete = function(self, who)
		self:specialSetAdd("skullcracker_mult", 1)
		self:specialSetAdd({"wielder","melee_project"}, {[engine.DamageType.GARKUL_INVOKE]=5})
	end,
}

newEntity{ base = "BASE_SHIELD",
	power_source = {arcane=true},
	define_as = "LUNAR_SHIELD",
	unique = true,
	name = "Lunar Shield", image = "object/artifact/shield_lunar_shield.png",
	unided_name = "chitinous shield",
	kr_display_name = "달의 방패", kr_unided_name = "키틴질 방패",
	desc = [[니미실에게서 떼어낸 큰 조각입니다. 지속적으로 이상한 흰 빛을 뿜어내고 있습니다.]],
	color = colors.YELLOW,
	metallic = false,
	require = { stat = { str=35 }, },
	level_range = {40, 50},
	rarity = 280,
	cost = 350,
	material_level = 5,
	special_combat = {
		dam = 45,
		block = 250,
		physcrit = 10,
		dammod = {str=1},
		damrange = 1.4,
		damtype = DamageType.ARCANE,
	},
	wielder = {
		resists={[DamageType.DARKNESS] = 25},
		inc_damage={[DamageType.DARKNESS] = 15},

		combat_armor = 7,
		combat_def = 12,
		combat_def_ranged = 5,
		combat_spellpower = 10,
		fatigue = 2,

		lite = 1,
		talents_types_mastery = {["celestial/star-fury"]=0.2,["celestial/twilight"]=0.1,},
		learn_talent = { [Talents.T_BLOCK] = 5, },
	},
	talent_on_spell = { {chance=10, talent=Talents.T_MOONLIGHT_RAY, level=2} },
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true},
	define_as = "WRATHROOT_SHIELD",
	unided_name = "large chunk of wood",
	name = "Wrathroot's Barkwood", unique=true, image="object/artifact/shield_wrathroots_barkwood.png",
	kr_display_name = "왈쓰룻의 나무껍질", kr_unided_name = "커다란 나무 덩어리",
	desc = [[왈쓰룻의 나무껍질로 둥글게 만든 방패입니다.]],
	require = { stat = { str=25 }, },
	level_range = {12, 22},
	rarity = 200,
	cost = 20,
	material_level = 2,
	rarity = false,
	metallic = false,

	special_combat = {
		dam = resolvers.rngavg(20,30),
		block = 60,
		physcrit = 2,
		dammod = {str=1.5},
		damrange = 1.4,
	},
	wielder = {
		combat_armor = 10,
		combat_def = 9,
		fatigue = 14,
		resists = {
			[DamageType.DARKNESS] = 20,
			[DamageType.COLD] = 20,
			[DamageType.NATURE] = 20,
		},
		learn_talent = { [Talents.T_BLOCK] = 3, },
	},
}

newEntity{ base = "BASE_GEM",
	power_source = {nature=true},
	unique = true, define_as = "PETRIFIED_WOOD",
	unided_name = "burned piece of wood",
	name = "Petrified Wood", subtype = "black",
	kr_display_name = "화석 나무", kr_unided_name = "탄 나무 조각",
	color = colors.WHITE, image = "object/artifact/petrified_wood.png",
	level_range = {35, 45},
	rarity = 280,
	identified = false,
	desc = [[스냅뿌리의 잔존물로 그을린 나무 조각입니다.]],
	rarity = false,
	cost = 100,
	material_level = 4,
	imbue_powers = {
		resists = { [DamageType.NATURE] = 25, [DamageType.DARKNESS] = 10, [DamageType.COLD] = 10 },
		inc_stats = { [Stats.STAT_CON] = 25, },
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	define_as = "BLACK_ROBE", rarity=false,
	name = "Black Robe", unique=true,
	unided_name = "black robe", color=colors.DARK_GREY, image = "object/artifact/robe_black_robe.png",
	kr_display_name = "검은 로브", kr_unided_name = "검은 로브",
	desc = [[어두운 밤 하늘보다 더 어두운 비단 로브로, 힘을 발산하고 있습니다.]],
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 3 },
		see_invisible = 10,
		blind_immune = 0.5,
		combat_spellpower = 30,
		combat_spellresist = 25,
		combat_dam = 10,
		combat_def = 6,
	},
	talent_on_spell = {
		{chance=5, talent=Talents.T_SOUL_ROT, level=3},
		{chance=5, talent=Talents.T_BLOOD_GRASP, level=3},
		{chance=5, talent=Talents.T_BONE_SPEAR, level=3},
	},
}

newEntity{ base = "BASE_WARAXE",
	power_source = {arcane=true},
	define_as = "MALEDICTION", rarity=false,
	unided_name = "pestilent waraxe",
	name = "Malediction", unique=true, image = "object/artifact/axe_malediction.png",
	kr_display_name = "저주", kr_unided_name = "치명적 전투도끼",
	desc = [[이 저주받은 도끼가 가는 곳마다 시들고 허물어집니다.]],
	require = { stat = { str=55 }, },
	level_range = {35, 45},
	rarity = 290,
	cost = 375,
	material_level = 4,
	combat = {
		dam = 55,
		apr = 15,
		physcrit = 10,
		dammod = {str=1},
		damrange = 1.2,
		melee_project={[DamageType.BLIGHT] = 20},
	},
	wielder = {
		life_regen = -0.3,
		inc_damage = { [DamageType.BLIGHT] = 20 },
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	define_as = "STAFF_KOR", rarity=false, image = "object/artifact/staff_kors_fall.png",
	unided_name = "dark staff",
	flavor_name = "vilestaff",
	name = "Kor's Fall", unique=true,
	kr_display_name = "코르의 추락", kr_unided_name = "비열한 지팡이",
	desc = [[많은 생물의 뼈로 만들어진 이 지팡이는 힘이 넘쳐나고 있습니다. 거리를 두어도 그 사악함이 느껴집니다.]],
	require = { stat = { mag=25 }, },
	level_range = {1, 10},
	rarity = 200,
	cost = 60,
	material_level = 1,
	modes = {"darkness", "fire", "blight", "acid"},
	combat = {
		is_greater = true,
		dam = 10,
		apr = 0,
		physcrit = 1.5,
		dammod = {mag=1.1},
		damtype = DamageType.DARKNESS,
	},
	wielder = {
		see_invisible = 2,
		combat_spellpower = 7,
		combat_spellcrit = 8,
		inc_damage={
			[DamageType.ACID] = 10,
			[DamageType.DARKNESS] = 10,
			[DamageType.FIRE] = 10,
			[DamageType.BLIGHT] = 10,
		},
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	define_as = "VOX", rarity=false,
	name = "Vox", unique=true,
	unided_name = "ringing amulet", color=colors.BLUE, image="object/artifact/jewelry_amulet_vox.png",
	kr_display_name = "소리", kr_unided_name = "고리 목걸이",
	desc = [[이 목걸이의 착용자를 침묵시킬 힘은 찾기 힘듭니다.]],
	level_range = {40, 50},
	rarity = 220,
	cost = 3000,
	material_level = 5,
	wielder = {
		see_invisible = 20,
		silence_immune = 0.8,
		combat_spellpower = 9,
		combat_spellcrit = 4,
		max_mana = 50,
		max_vim = 50,
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	define_as = "TELOS_TOP_HALF", rarity=false, image = "object/artifact/staff_broken_top_telos.png",
	slot_forbid = false,
	twohanded = false,
	unided_name = "broken staff", flavor_name = "magestaff",
	name = "Telos's Staff (Top Half)", unique=true,
	kr_display_name = "텔로스 지팡이 (상단)", kr_unided_name = "부서진 지팡이",
	desc = [[부서진 텔로스 지팡이의 상단부입니다.]],
	require = { stat = { mag=35 }, },
	level_range = {40, 50},
	rarity = 210,
	encumber = 2.5,
	material_level = 5,
	modes = {"fire", "cold", "lightning", "arcane"},
	cost = 500,
	combat = {
		dam = 35,
		apr = 0,
		physcrit = 1.5,
		dammod = {mag=1.0},
		damtype = DamageType.ARCANE,
	},
	wielder = {
		combat_spellpower = 30,
		combat_spellcrit = 15,
		combat_mentalresist = 8,
		inc_stats = { [Stats.STAT_WIL] = 5, },
		inc_damage = {[DamageType.ARCANE] = 35 },
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1 },
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	define_as = "AMULET_DREAD", rarity=false,
	name = "Choker of Dread", unique=true, image = "object/artifact/amulet_choker_of_dread.png",
	unided_name = "dark amulet", color=colors.LIGHT_DARK,
	kr_display_name = "드레드의 목고리", kr_unided_name = "어두운 목걸이", --@@ choker 어감을 위해 목고리로 번역
	desc = [[역생의 사악함이 이 목걸이로부터 뿜어져 나옵니다.]],
	level_range = {20, 28},
	rarity = 220,
	cost = 5000,
	material_level = 3,
	wielder = {
		see_invisible = 10,
		blind_immune = 1,
		combat_spellpower = 5,
		combat_dam = 5,
	},
	max_power = 60, power_regen = 1,
	use_power = { name = "동료 흡혈귀 장로 소환", power = 60, use = function(self, who)
		if not who:canBe("summon") then game.logPlayer(who, "소환할 수 없습니다. 당신은 억제되었습니다!") return end

		-- Find space
		local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
		if not x then
			game.logPlayer(who, "흡혈귀를 소환할 공간이 부족합니다!")
			return
		end
		print("Invoking guardian on", x, y)

		local NPC = require "mod.class.NPC"
		local vampire = NPC.new{
			type = "undead", subtype = "vampire",
			display = "V", image = "npc/elder_vampire.png",
			name = "elder vampire", color=colors.RED,
			kr_display_name = "흡혈귀 장로",
			desc=[[로브를 입은 끔찍한 언데드로, 다른 생명체의 생명력을 빼앗음으로써 수세기를 역생하여 존재하고 있습니다. 이것은 희생자들의 다양한 그림자를 묘지에서 불러 노예로 부릴수 있습니다.]],

			combat = { dam=resolvers.rngavg(9,13), atk=10, apr=9, damtype=engine.DamageType.DRAINLIFE, dammod={str=1.9} },

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

			autolevel = "warriormage",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=3, },
			stats = { str=12, dex=12, mag=12, con=12 },
			life_regen = 3,
			size_category = 3,
			rank = 3,
			infravision = 10,

			inc_damage = table.clone(who.inc_damage, true),

			resists = { [engine.DamageType.COLD] = 80, [engine.DamageType.NATURE] = 80, [engine.DamageType.LIGHT] = -50,  },
			blind_immune = 1,
			confusion_immune = 1,
			see_invisible = 5,
			undead = 1,

			level_range = {who.level, who.level}, exp_worth = 0,
			max_life = resolvers.rngavg(90,100),
			combat_armor = 12, combat_def = 10,
			resolvers.talents{ [who.T_STUN]=2, [who.T_BLUR_SIGHT]=3, [who.T_PHANTASMAL_SHIELD]=2, [who.T_ROTTING_DISEASE]=3, },

			faction = who.faction,
			summoner = who,
			summon_time = 15,
		}

		vampire:resolve()
		game.zone:addEntity(game.level, vampire, "actor", x, y)
		vampire:forceUseTalent(vampire.T_TAUNT, {})
		if who:knowTalent(who.T_BLIGHTED_SUMMONING) then vampire:learnTalent(vampire.T_DARKFIRE, true, 3) end

		game:playSoundNear(who, "talents/spell_generic")
		return {id=true, used=true}
	end },
}

newEntity{ define_as = "RUNED_SKULL",
	power_source = {arcane=true},
	unique = true,
	type = "gem", subtype="red", image = "object/artifact/bone_runed_skull.png",
	unided_name = "human skull",
	name = "Runed Skull",
	kr_display_name = "룬 두개골", kr_unided_name = "사람 두개골",
	display = "*", color=colors.RED,
	level_range = {40, 50},
	rarity = 390,
	cost = 150,
	encumber = 3,
	material_level = 5,
	desc = [[이 더럽혀진 두개골에는 둔탁하고 붉은 룬이 온통 뒤덮혀 새겨져 있습니다.]],

	carrier = {
		combat_spellpower = 7,
		on_melee_hit = {[DamageType.FIRE]=25},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {technique=true},
	define_as = "GREATMAUL_BILL_TRUNK",
	unided_name = "tree trunk", image = "object/artifact/bill_treestump.png",
	name = "Bill's Tree Trunk", unique=true,
	kr_display_name = "빌의 나무 줄기", kr_unided_name = "나무 줄기",
	desc = [[이것은 트롤 빌이 무기로 사용하던 크고 더러워 보이는 나무 줄기입니다. 당신이 이것을 쥘수 있을만큼 힘이 세다면, 이것은 아직 그 목적을 위해 사용할 수 있습니다!]],
	require = { stat = { str=25 }, },
	level_range = {1, 10},
	material_level = 1,
	rarity = 200,
	metallic = false,
	cost = 70,
	combat = {
		dam = 30,
		apr = 7,
		physcrit = 1.5,
		dammod = {str=1.3},
		damrange = 1.7,
	},

	wielder = {
	},
}


newEntity{ base = "BASE_SHIELD",
	power_source = {technique=true},
	define_as = "SANGUINE_SHIELD",
	unided_name = "bloody shield",
	name = "Sanguine Shield", unique=true, image = "object/artifact/sanguine_shield.png",
	kr_display_name = "핏빛의 방패", kr_unided_name = "피로 물든 방패",
	desc = [[피가 튀어있고 변색되었지만, 이 방패는 아직 태양의 문장을 통해 빛을 뿜고 있습니다.]],
	require = { stat = { str=39 }, },
	level_range = {35, 45},
	material_level = 4,
	rarity = 240,
	cost = 120,

	special_combat = {
		dam = 40,
		block = 220,
		physcrit = 9,
		dammod = {str=1.2},
	},
	wielder = {
		combat_armor = 4,
		combat_def = 14,
		combat_def_ranged = 14,
		inc_stats = { [Stats.STAT_CON] = 5, },
		fatigue = 19,
		resists = { [DamageType.BLIGHT] = 25, },
		life_regen = 5,
		learn_talent = { [Talents.T_BLOCK] = 5, },
	},
}

newEntity{ base = "BASE_WHIP",
	power_source = {arcane=true},
	define_as = "WHIP_URH_ROK",
	unided_name = "fiery whip",
	name = "Whip of Urh'Rok", color=colors.PURPLE, unique = true, image = "object/artifact/whip_of_urh_rok.png",
	kr_display_name = "울흐'록의 채찍", kr_unided_name = "불타는 채찍",
	desc = [[이 극도로 밝은 불꽃의 채찍과 함께, 상위 악마 울흐'록은 전투에서 절대 패하지 않는 것으로 유명합니다.]],
	require = { stat = { dex=48 }, },
	level_range = {40, 50},
	rarity = 390,
	cost = 250,
	material_level = 5,
	combat = {
		dam = resolvers.rngavg(40,45),
		apr = 0,
		physcrit = 9,
		dammod = {dex=1},
		damtype = DamageType.FIREKNOCKBACK,
	},
	wielder = {
		esp = {["demon/minor"]=1, ["demon/major"]=1},
		see_invisible = 2,
	},
	carrier = {
		inc_damage={
			[DamageType.BLIGHT] = 8,
		},
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {technique=true},
	define_as = "MURDERBLADE", rarity=false,
	name = "Warmaster Gnarg's Murderblade", unique=true, image="object/artifact/warmaster_gnargs_murderblade.png",
	unided_name = "blood-etched greatsword", color=colors.CRIMSON,
	kr_display_name = "전투의 대가 그날그의 살해검", kr_unided_name = "비로 새겨진 대검",
	desc = [[피로 새겨진 대검입니다. 이것은 많은 적들에게 꽂혀진 모습으로 잘 알려져 있습니다.]],
	require = { stat = { str=35 }, },
	level_range = {35, 45},
	rarity = 230,
	cost = 300,
	material_level = 5,
	combat = {
		dam = 60,
		apr = 19,
		physcrit = 4.5,
		dammod = {str=1.2},
		special_on_hit = {desc="10% 확률로 사용자에게 살해의 광란 상태 부여", fct=function(combat, who)
			if not rng.percent(10) then return end
			who:setEffect(who.EFF_FRENZY, 3, {crit=10, power=0.3, dieat=0.2})
		end},
	},
	wielder = {
		see_invisible = 25,
		inc_stats = { [Stats.STAT_CON] = 5, [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, },
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.2,
			["technique/2hweapon-offense"] = 0.2,
		},
	},
}

newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {arcane=true},
	define_as = "CROWN_ELEMENTS", rarity=false,
	name = "Crown of the Elements", unique=true, image = "object/artifact/crown_of_the_elements.png",
	unided_name = "jeweled crown", color=colors.DARK_GREY,
	kr_display_name = "원소의 관", kr_unided_name = "보석박힌 관",
	desc = [[이 보석박힌 관은 다양한 색으로 빛납니다.]],
	level_range = {40, 50},
	rarity = 280,
	cost = 500,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 5, [Stats.STAT_WIL] = 3, },
		resists={
			[DamageType.FIRE] = 15,
			[DamageType.COLD] = 15,
			[DamageType.ACID] = 15,
			[DamageType.LIGHTNING] = 15,
		},
		melee_project={
			[DamageType.FIRE] = 10,
			[DamageType.COLD] = 10,
			[DamageType.ACID] = 10,
			[DamageType.LIGHTNING] = 10,
		},
		see_invisible = 15,
		combat_armor = 5,
		fatigue = 5,
	},
}

newEntity{ base = "BASE_GLOVES", define_as = "FLAMEWROUGHT",
	power_source = {nature=true},
	unique = true,
	name = "Flamewrought", color = colors.RED, image = "object/artifact/gloves_flamewrought.png",
	unided_name = "chitinous gloves",
	kr_display_name = "불꽃장갑", kr_unided_name = "키틴질 장갑",
	desc = [[이 장갑은 릿치의 외골격으로 만들어진 것으로 보입니다. 건드리면 뜨겁습니다.]],
	level_range = {5, 12},
	rarity = 180,
	cost = 50,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 3, },
		resists = { [DamageType.FIRE]= 10, },
		inc_damage = { [DamageType.FIRE]= 5, },
		combat_armor = 2,
		combat = {
			dam = 5,
			apr = 7,
			physcrit = 1,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={[DamageType.FIRE] = 10},
			convert_damage = { [DamageType.FIRE] = 100,},
		},
	},
	max_power = 24, power_regen = 1,
	use_talent = { id = Talents.T_RITCH_FLAMESPITTER_BOLT, level = 2, power = 6 },
}

-- The crystal set
newEntity{ base = "BASE_GEM", define_as = "CRYSTAL_FOCUS",
	power_source = {arcane=true},
	unique = true,
	unided_name = "scintillating crystal",
	name = "Crystal Focus", subtype = "multi-hued",
	kr_display_name = "수정의 핵", kr_unided_name = "번득이는 수정",
	color = colors.WHITE, image = "object/artifact/crystal_focus.png",
	level_range = {5, 12},
	desc = [[스펠블레이즈 그 자체의 힘을 내뿜는 수정입니다.]],
	rarity = 200,
	identified = false,
	cost = 50,
	material_level = 2,

	max_power = 1, power_regen = 1,
	use_power = { name = "무기와 결합", power = 1, use = function(self, who, gem_inven, gem_item)
		who:showInventory("어느 무기에 붙입니까?", who:getInven("INVEN"), function(o) return (o.type == "weapon" or o.subtype == "hands") and o.subtype ~= "mindstar" and not o.egoed and not o.unique and not o.rare and not o.archery end, function(o, item)
			local oldname = o:getName{do_color=true}

			-- Remove the gem
			who:removeObject(gem_inven, gem_item)
			who:sortInven(gem_inven)

			-- Change the weapon
			o.kr_display_name = "수정으로된 "..(o.kr_display_name or o.name):capitalize()
			o.name = "Crystalline "..o.name:capitalize()
			o.unique = o.name
			o.no_unique_lore = true
			if o.combat and o.combat.dam then
				o.combat.dam = o.combat.dam * 1.25
				o.combat.damtype = engine.DamageType.ARCANE
			elseif o.wielder.combat and o.wielder.combat.dam then
				o.wielder.combat.dam = o.wielder.combat.dam * 1.25
				o.wielder.combat.convert_damage = o.wielder.combat.convert_damage or {}
				o.wielder.combat.convert_damage[engine.DamageType.ARCANE] = 100
			end
			o.is_crystalline_weapon = true
			o.power_source = o.power_source or {}
			o.power_source.arcane = true
			o.wielder = o.wielder or {}
			o.wielder.combat_spellpower = (o.wielder.combat_spellpower or 0) + 12
			o.wielder.combat_dam = (o.wielder.combat_dam or 0) + 12
			o.wielder.inc_stats = o.wielder.inc_stats or {}
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_WIL] = 3
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_CON] = 3
			o.wielder.inc_damage = o.wielder.inc_damage or {}
			o.wielder.inc_damage[engine.DamageType.ARCANE] = 10
			if o.wielder.learn_talent then o.wielder.learn_talent[who.T_COMMAND_STAFF] = nil end

			o.set_list = { {"is_crystalline_armor", true} }
			o.on_set_complete = function(self, who)
				self.talent_on_spell = { {chance=10, talent="T_MANATHRUST", level=3} }
				if(self.combat) then self.combat.talent_on_hit = { T_MANATHRUST = {level=3, chance=10} }
				else self.wielder.combat.talent_on_hit = { T_MANATHRUST = {level=3, chance=10} }
				end
				self:specialSetAdd({"wielder","combat_spellcrit"}, 10)
				self:specialSetAdd({"wielder","combat_physcrit"}, 10)
				self:specialSetAdd({"wielder","resists_pen"}, {[engine.DamageType.ARCANE]=20, [engine.DamageType.PHYSICAL]=15})
				game.logPlayer(who, "#GOLD#수정으로된 무기와 갑옷을 같이 착용하면, 그것들이 지속적인 공명음을 내기 시작합니다.")
			end
			o.on_set_broken = function(self, who)
				self.talent_on_spell = nil
				if (self.combat) then self.combat.talent_on_hit = nil
				else self.wielder.combat.talent_on_hit = nil
				end
				game.logPlayer(who, "#GOLD#수정으로된 아티팩트에서 나온 공명음이 흩어지면서 사라집니다.")
			end

			who:sortInven()
			who.changed = true

			game.logPlayer(who, "당신은 수정을 %s에 사용하여, %s 만들었습니다.", oldname, o:getName{do_color=true}:addJosa("를"))
		end)
	end },
}

newEntity{ base = "BASE_GEM", define_as = "CRYSTAL_HEART",
	power_source = {arcane=true},
	unique = true,
	unided_name = "coruscating crystal",
	name = "Crystal Heart", subtype = "multi-hued",
	kr_display_name = "수정의 심장", kr_unided_name = "반짝이는 수정",
	color = colors.RED, image = "object/artifact/crystal_heart.png",
	level_range = {35, 42},
	desc = [[이 수정은 머리크기 정도로 커다랗습니다. 이것은 자연적으로 밝게 번쩍입니다.]],
	rarity = 250,
	identified = false,
	cost = 200,
	material_level = 5,

	max_power = 1, power_regen = 1,
	use_power = { name = "갑옷과 결합", power = 1, use = function(self, who, gem_inven, gem_item)
		-- Body armour only, can be cloth, light, heavy, or massive though. No clue if o.slot works for this.
		who:showInventory("어느 갑옷에 붙입니까?", who:getInven("INVEN"), function(o) return o.type == "armor" and o.slot == "BODY" and not o.egoed and not o.unique and not o.rare end, function(o, item)
			local oldname = o:getName{do_color=true}

			-- Remove the gem
			who:removeObject(gem_inven, gem_item)
			who:sortInven(gem_inven)

			-- Change the weapon... err, armour. No, I'm not copy/pasting here, honest!
			o.kr_display_name = "수정으로된 "..(o.kr_display_name or o.name):capitalize()
			o.name = "Crystalline "..o.name:capitalize()
			o.unique = o.name
			o.no_unique_lore = true
			o.is_crystalline_armor = true
			o.power_source = o.power_source or {}
			o.power_source.arcane = true

			o.wielder = o.wielder or {}
			-- This is supposed to add 1 def for crap cloth robes if for some reason you choose it instead of better robes, and then multiply by 1.25.
			o.wielder.combat_def = ((o.wielder.combat_def or 0) + 2) * 1.7
			-- Same for armour. Yay crap cloth!
			o.wielder.combat_armor = ((o.wielder.combat_armor or 0) + 3) * 1.7
			o.wielder.combat_spellresist = 35
			o.wielder.combat_physresist = 25
			o.wielder.inc_stats = o.wielder.inc_stats or {}
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_MAG] = 8
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_CON] = 8
			o.wielder.inc_stats[engine.interface.ActorStats.STAT_LCK] = 12
			o.wielder.resists = o.wielder.resists or {}
			o.wielder.resists = { [engine.DamageType.ARCANE] = 35, [engine.DamageType.PHYSICAL] = 15 }
			o.wielder.poison_immune = 0.6
			o.wielder.disease_immune = 0.6

			o.set_list = { {"is_crystalline_weapon", true} }
			o.on_set_complete = function(self, who)
				self:specialSetAdd({"wielder","stun_immune"}, 0.5)
				self:specialSetAdd({"wielder","blind_immune"}, 0.5)
			end
			who:sortInven()
			who.changed = true

			game.logPlayer(who, "당신은 수정을 %s에 사용하여, %s 만들었습니다.", oldname, o:getName{do_color=true}:addJosa("를"))
		end)
	end },
}

newEntity{ base = "BASE_ROD", define_as = "ROD_OF_ANNULMENT",
	power_source = {arcane=true},
	unided_name = "dark rod",
	name = "Rod of Annulment", color=colors.LIGHT_BLUE, unique=true, image = "object/artifact/rod_of_annulment.png",
	kr_display_name = "폐기의 장대", kr_unided_name = "암흑 장대",
	desc = [[이 장대 주변의 마법이 사라지는 것이 느껴집니다. 자연적인 권능도 영향을 받는 것 같습니다.]],
	cost = 50,
	rarity = 380,
	level_range = {5, 12},
	elec_proof = true,
	add_name = false,

	material_level = 2,

	max_power = 30, power_regen = 1,
	use_power = { name = "적의 주입이나 룬 또는 기술 몇가지를 재사용 대기상태로 만듦", power = 30,
		use = function(self, who)
			local tg = {type="bolt", range=5}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end

				local tids = {}
				for tid, lev in pairs(target.talents) do
					local t = target:getTalentFromId(tid)
					if not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
				end
				for i = 1, 3 do
					local t = rng.tableRemove(tids)
					if not t then break end
					target.talents_cd[t.id] = rng.range(3, 5)
					game.logSeen(target, "%s의 %s 중단되었습니다!", (target.kr_display_name or target.name):capitalize(), (t.kr_display_name or t.name):addJosa("가"))
				end
				target.changed = true
			end, nil, {type="flame"})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_WARAXE",
	power_source = {arcane=true},
	define_as = "SKULLCLEAVER",
	unided_name = "crimson waraxe",
	name = "Skullcleaver", unique=true, image = "object/artifact/axe_skullcleaver.png",
	kr_display_name = "두개골 절단기", kr_unided_name = "피비린내 나는 전투도끼",
	desc = [[다듬어진 뼈 손잡이가 달린 작지만 날카로운 도끼입니다. 그 날은 많은 두개골을 갈라놓았고, 짙은 피비린내로 얼룩져 있습니다.]],
	require = { stat = { str=18 }, },
	level_range = {5, 12},
	material_level = 1,
	rarity = 220,
	cost = 50,
	combat = {
		dam = 16,
		apr = 3,
		physcrit = 12,
		dammod = {str=1},
		talent_on_hit = { [Talents.T_GREATER_WEAPON_FOCUS] = {level=2, chance=10} },
		melee_project={[DamageType.DRAINLIFE] = 10},
	},
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = 8 },
	},
}

newEntity{ base = "BASE_DIGGER",
	power_source = {unknown=true},
	define_as = "TOOTH_MOUTH",
	unided_name = "a tooth", unique = true,
	name = "Tooth of the Mouth", image = "object/artifact/tooth_of_the_mouth.png",
	kr_display_name = "'그 입'의 이빨", kr_unided_name = "이빨",
	desc = [[깊은 울림의 '그 입'에게서 뽑아낸 커다란 이빨입니다.]],
	level_range = {5, 12},
	cost = 50,
	material_level = 1,
	digspeed = 12,
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = 4 },
		on_melee_hit = {[DamageType.BLIGHT] = 15},
		combat_apr = 5,
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	define_as = "WARPED_BOOTS",
	power_source = {unknown=true},
	unique = true,
	name = "The Warped Boots", image = "object/artifact/the_warped_boots.png",
	unided_name = "pair of painful-looking boots",
	kr_display_name = "구부러진 신발", kr_unided_name = "불쾌해 보이는 신발",
	desc = [[이 더러운 신발은 옛날의 영광스러웠던 모든 흔적이 지워져 있습니다. 지금은, 그 힘으로 인해 깊은 어둠이 타락한 증거가 되었습니다.]],
	color = colors.DARK_GREEN,
	level_range = {35, 45},
	rarity = 250,
	cost = 200,
	material_level = 5,
	wielder = {
		combat_armor = 4,
		combat_def = 2,
		combat_dam = 10,
		fatigue = 8,
		combat_spellpower = 10,
		combat_spellcrit = 9,
		life_regen = -0.20,
		inc_damage = { [DamageType.BLIGHT] = 15 },
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_SPIT_BLIGHT, level=3, power = 10 },
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {nature=true, antimagic=true},
	define_as = "GAPING_MAW",
	name = "The Gaping Maw", color = colors.SLATE, image = "object/artifact/battleaxe_the_gaping_maw.png",
	unided_name = "huge granite battleaxe", unique = true,
	kr_display_name = "벌어진 입", kr_unided_name = "커다란 화강암 대형도끼",
	desc = [[이 커다란 화강암 대형도끼는 도끼이지만 거의 둔기 같습니다. 검게된 나무의 둘레에 드레이크 가죽을 꽁꽁 동여맨 자루에, 찐득한 녹색 액체가 발린 날카로운 화강암 머리가 번쩍입니다.]],
	level_range = {38, 50},
	rarity = 300,
	require = { stat = { str=60 }, },
	cost = 650,
	material_level = 5,
	combat = {
		dam = 72,
		apr = 4,
		physcrit = 8,
		dammod = {str=1.2},
		melee_project={[DamageType.SLIME] = 50, [DamageType.ACID] = 50},
	},
	wielder = {
		talent_cd_reduction= {
			[Talents.T_SWALLOW] = 2,
			[Talents.T_MANA_CLASH] = 2,
			[Talents.T_ICE_CLAW] = 1,
		},
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","inc_damage"}, {[DamageType.NATURE]=15})
			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_STR] = 6, [Stats.STAT_WIL] = 6, })
			game.logPlayer(who, "#DARK_GREEN#당신은 구체화된 자연의 분노를 느낍니다!")
		end
	end,
}

newEntity{ base = "BASE_AMULET",
	power_source = {psionic=true},
	define_as = "WITHERING_ORBS",
	unique = true,
	name = "Withering Orbs", color = colors.WHITE, image = "object/artifact/artifact_jewelry_withering_orbs.png",
	unided_name = "shadow-strung orbs",
	kr_display_name = "시듦의 오브", kr_unided_name = "그림자 줄무늬 오브",
	desc = [[이 유백광의 오브들은 치명적인 지식으로 당신의 혀영심과 자만을 깨우쳐주며 당신을 응시하고 있습니다. 그것들은 당신이 상상할 수도 없는 무서운자에 의해 생명을 얻고 또한 죽었으며, 이제는 검은 현의 무늬에 누워 보이는 모든 그림자를 낚아채고 있습니다.
잠시 눈을 감으면, 그들이 보는 공포를 대부분 상상할 수 있을 것입니다...]],
	level_range = {5, 12},
	rarity = 200,
	cost = 100,
	material_level = 1,
	metallic = false,
	wielder = {
		blind_fight = 1,
		see_invisible = 10,
		see_stealth = 10,
		combat_mindpower = 5,
		melee_project = {
			[DamageType.MIND] = 5,
		},
		ranged_project = {
			[DamageType.MIND] = 5,
		},
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique=true},
	define_as = "BORFAST_CAGE",
	unique = true,
	name = "Borfast's Cage",
	unided_name = "a suit of pitted and pocked plate-mail",
	kr_display_name = "보르파스트의 우리", kr_unided_name = "곰보자국 판갑",
	desc = [[일 인치 두께의 스트라라이트 판으로 엮여있고, 관절은 보라툰으로 만들어졌습니다. 겉보기엔 절대 뚫리지 않을것처럼 보이지만, 관리를 엉망으로 하여 커다랗게 움푹패인 자국과 보기 흉한 뒤틀림 그리고 부식한 틈으로 뚫린 구멍 등을 드러내고 있습니다.
확실히 강력한 작품이지만, 과거에는 더욱 어마어마했음이 분명합니다.]],
	color = colors.WHITE, image = "object/artifact/armor_plate_borfasts_cage.png",
	level_range = {20, 28},
	rarity = 200,
	require = { stat = { str=35 }, },
	cost = 500,
	material_level = 3,
	wielder = {
		combat_def = 10,
		combat_armor = 15,
		fatigue = 24,

		inc_stats = { [Stats.STAT_CON] = 5, },
		resists = {
			[DamageType.ACID] = - 15,
			[DamageType.PHYSICAL] = 15,
		},

		max_life = 50,
		life_regen = 2,

		knockback_immune = 0.3,

		combat_physresist = 15,
		combat_crit_reduction = 20,
	},
}

newEntity{ base = "BASE_LEATHER_CAP", -- No armor training requirement
	power_source = {psionic=true},
	define_as = "ALETTA_DIADEM",
	name = "Aletta's Diadem", unique=true, unided_name="jeweled diadem", image = "object/artifact/diadem_alettas_diadem.png",
	kr_display_name = "알레타의 왕관", kr_unided_name = "보석박힌 왕관",
	desc = [[많은 작은 보석이 박힌 은선 세공이 된 이 왕관은 천상의 물건같이 빛나고 있습니다. 하지만 건드리면 피부가 얼고, 정신이 난폭해 집니다. 버리거나 던지려하면, 당신의 마음 속에서 이것을 가지고자 하는 마음이 저항할 수 없도록 다가옵니다.
이 약한 유혹은 당신의 일부분일까요 아니면 이 물건에서 뻗어나온 세뇌일까요...?]],
	require = { stat = { wil=24 }, },
	level_range = {20, 28},
	rarity = 200,
	cost = 1000,
	material_level = 3,
	metallic = true,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 4, },
		combat_mindpower = 12,
		combat_mindcrit = 5,
		on_melee_hit={ [DamageType.MIND] = 12, },
		inc_damage={ [DamageType.MIND] = 10, },
	},
	max_power = 10, power_regen = 1,
	use_talent = { id = Talents.T_PSYCHIC_LOBOTOMY, level=3, power = 8 },
}

newEntity{ base = "BASE_SLING",
	power_source = {nature=true},
	define_as = "HARESKIN_SLING",
	name = "Hare-Skin Sling", unique=true, unided_name = "hare-skin sling", image = "object/artifact/sling_hareskin_sling.png",
	kr_display_name = "산토끼 가죽 투석구", kr_unided_name = "산토끼 가죽 투석구",
	desc = [[길이 잘 들여진 이 투석구는 커다란 산토끼의 가죽과 힘줄로 만들어진 것입니다. 부드럽고, 아직 매우 튼튼합니다. 산토끼 가죽이 행운을 가져온다고 믿는 사람도 있습니다.
이 물건의 전주인들이 그랬는지는 알기 힘들지만, 이 가죽이 매우 강하고 믿을만 한 것은 확실합니다..]],
	level_range = {20, 28},
	rarity = 200,
	require = { stat = { dex=35 }, },
	cost = 50,
	material_level = 3,
	use_no_energy = true,
	combat = {
		range = 10,
		physspeed = 0.8,
	},
	wielder = {
		movement_speed = 0.2,
		inc_stats = { [Stats.STAT_LCK] = 10, },
		combat_physcrit = 5,
		combat_def = 10,
		talents_types_mastery = { ["cunning/survival"] = 0.2, },
	},
	max_power = 8, power_regen = 1,
	use_talent = { id = Talents.T_INERTIAL_SHOT, level=3, power = 8 },
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {arcane=true},
	define_as = "LUCKY_FOOT",
	unique = true,
	name = "Prox's Lucky Halfling Foot", color = colors.WHITE,
	unided_name = "a mummified halfling foot", image = "object/artifact/proxs_lucky_halfling_foot.png",
	kr_display_name = "프록스의 행운을 주는 하플링 발", kr_unided_name = "미이라 하플링의 발",
	desc = [[하플링의 것임이 확실한 털이난 커다란 발로, 두꺼운 꼬인 끈에 매달려 있습니다. 그 부패 상태로 봐서 만들어진지 얼마나 오래된 것인지 말하기 힘들고, 발목 근처의 이빨 자국으로 볼때 그 주인이 자진해서 준것은 아니라는 인상을 받습니다.
그 원한에도 불구하고 소금과 진흙에 닿은 채로 오랜 시간을 지내와서, 자연은 이것을 죽은 시체가 겪는 일들을 시작하도록 만들었습니다. 어떤 이는 하플링의 발을 가진 사람은 행운을 얻는다고 말하지만, 지금 당신이 알 수 있는 것은 여기서 악취가 난다는 것 뿐입니다.]],
	level_range = {5, 12},
	rarity = 200,
	cost = 10,
	material_level = 1,
	metallic = false,
	sentient = true,
	wielder = {
		inc_stats = { [Stats.STAT_LCK] = 5, },
		combat_def = 5,
		disarm_bonus = 5,
	},
	act = function(self)
		self:useEnergy()
		if self.worn_by then
			local actor = self.worn_by
			local grids = core.fov.circle_grids(actor.x, actor.y, 1, true)
			local Map = require "engine.Map"
			local is_trap = false

			for x, yy in pairs(grids) do for y, _ in pairs(yy) do
				local trap = game.level.map(x, y, Map.TRAP)
				if trap and not (trap:knownBy(self) or trap:knownBy(actor)) then
					is_trap = true
					-- Set the artifact as knowing the trap, not the wearer
					trap:setKnown(self, true)
				end
			end end
			-- only one twitch per action
			if is_trap then
				game.logSeen(actor, "#CRIMSON#%s 낚아채며 %s의 주변에 함정이 있다고 경고합니다.", self:getName():addJosa("가"), (actor.kr_display_name or actor.name):capitalize())
				if actor == game.player then
					game.player:runStop()
				end
			end
		end
	end,
	on_wear = function(self, who)
		self.worn_by = who
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Stats = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_LCK] = -10}) -- Overcomes the +5 Bonus and adds a -5 penalty
			self:specialWearAdd({"wielder","combat_physicalsave"}, -5)
			self:specialWearAdd({"wielder","combat_mentalsave"}, -5)
			self:specialWearAdd({"wielder","combat_spellsave"}, -5)
			game.logPlayer(who, "#LIGHT_RED#당신은 %s 착용하고 다니는 것에 불안함을 느낍니다.", self:getName():addJosa("를"))
		end
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
}

--Storm fury, lightning infused bow that automatically attacks nearby enemies with bolts of lightning.
newEntity{ base = "BASE_LONGBOW",
	power_source = {arcane=true},
	define_as = "STORM_FURY",
	name = "Storm Fury", unique=true, --THESE
	unided_name = "crackling longbow", color=colors.BLUE,
	kr_display_name = "폭풍의 분노", kr_unided_name = "파직거리는 활",
	desc = [[이 용뼈 활은 강철 띠로 강화되었고, 강렬한 뇌전을 띄고 있습니다. 당신도 모르게 뇌전의 화살이 시위를 따라 위 아래로 움직이고 있습니다.]],
	require = { stat = { dex=60 }, },
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	sentient = true,
	combat = {
		range=10,
		physspeed = 0.7,
	},
	wielder = {
		combat_spellpower=8,
		ranged_project = {[DamageType.LIGHTNING] = 50},
		talents_types_mastery = {
			["spell/air"] = 0.2,
			["spell/storm"] = 0.1,
		},
		inc_damage={
			[DamageType.LIGHTNING] = 15,
		},
	},
	act = function(self)
		self:useEnergy()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		self.zap = self.zap + 5
		if not rng.percent(self.zap)  then return end
		local who = self.worn_by
		local Map = require "engine.Map"
		--local project = require "engine.DamageType"
		local tgts = {}
		local DamageType = require "engine.DamageType"
		--local project = "engine.ActorProject"
		local grids = core.fov.circle_grids(who.x, who.y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and who:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		local tg = {type="hit", range=5,}
		for i = 1, 1 do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self.zap = 0
			who:project(tg, a.x, a.y, engine.DamageType.LIGHTNING_DAZE, {daze=40, dam = rng.avg(1,3) * (40+ who:getMag() * 1.5)} )
			game.level.map:particleEmitter(who.x, who.y, math.max(math.abs(a.x-who.x), math.abs(a.y-who.y)), "lightning", {tx=a.x-who.x, ty=a.y-who.y})
			game:playSoundNear(self, "talents/lightning")
			game.logSeen(who, "#GOLD#뇌전의 화살이 %s의 활에서 발사되어, %s 맞춥니다!", (who.kr_display_name or who.name):capitalize(), (a.kr_display_name or a.name):capitalize():addJosa("를"))
		end
	end,
	on_wear = function(self, who)
		self.worn_by = who
		self.zap = 0
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
}
--Ice Cloak that can release massive freezing AOE, dropped by Glacial Legion.
newEntity{ base = "BASE_CLOAK", define_as="GLACIAL_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Frozen Shroud", 
	unided_name = "chilling cloak", image = "object/artifact/frozen_shroud.png",
	kr_display_name = "얼어붙은 장막", kr_unided_name = "차가운 망토",
	desc = [[빙하의 부대가 남긴 것은 이게 전부입니다. 이 망토에서는 건드리는 모든 것을 얼리는 얼음같이 차가운 증기가 스며나옵니다.]],
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	wielder = {
		resists= {[DamageType.FIRE] = -15,[DamageType.COLD] = 25, all=8},
		inc_stats = { [Stats.STAT_MAG] = 7,},
		combat_def = 12,
		on_melee_hit = {[DamageType.ICE]=60},
	},
	max_power = 30, power_regen = 1,
	use_power = { name = "얼음구 발사", power = 30,
		use = function(self, who)
			local duration = 10
			local radius = 4
			local dam = (25 + who:getMag())
			local blast = {type="ball", range=0, radius=radius, selffire=false, display={particle="bolt_ice", trail="icetrail"}}
			who:project(blast, who.x, who.y, engine.DamageType.COLD, dam*3)
			who:project(blast, who.x, who.y, engine.DamageType.FREEZE, {dur=6, hp=80+dam})
			game.level.map:particleEmitter(who.x, who.y, blast.radius, "iceflash", {radius=blast.radius})
			-- Add a lasting map effect
			game.level.map:addEffect(who,
				who.x, who.y, duration,
				engine.DamageType.ICE, dam,
				radius,
				5, nil,
				engine.Entity.new{alpha=100, display='', color_br=30, color_bg=60, color_bb=200},
				function(e)
					e.radius = e.radius
					return true
				end,
				false
			)
			game.logSeen(who, "%s 그 망토에서 얼어붙은 차가운 덩어리를 발사합니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), self:getName())
			return {id=true, used=true}
		end
	},
}
--Blight+Phys Greatmaul that inflicts disease, dropped by Rotting Titan.
newEntity{ base = "BASE_GREATMAUL", define_as="ROTTING_MAUL",
	power_source = {arcane=true},
	unique = true,
	name = "Blighted Maul", color = colors.LIGHT_RED,  image = "object/artifact/blighted_maul.png",
	unided_name = "rotten stone limb",
	kr_display_name = "황폐화된 망치", kr_unided_name = "썩은 암석 다리",
	desc = [[이 썩안 타이탄의 커다란 암석 다리는, 암석과 썩은 살점으로 이루어져 있습니다. 들 수 있을 거라 생각하겠지만, 사실 이건 매우 무겁습니다]],
	level_range = {40, 50},
	rarity = 250,
	require = { stat = { str=60 }, },
	cost = 300,
	encumber = 12,
	material_level = 5,
	combat = {
		dam = 96,
		apr = 22,
		physcrit = 10,
		physspeed=1.2,
		dammod = {str=1.4},
		convert_damage = {[DamageType.BLIGHT] = 20},
		melee_project={[DamageType.CORRUPTED_BLOOD] = 30},
		special_on_hit = {desc="25% 확률로 주변 생물체에게 피해 전달", on_kill=true, fct=function(combat, who, target)
			if rng.percent(25) then
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "ROTTING_MAUL")
				local dam = rng.avg(1,2) * (70+ who:getStr() * 1.8)
				game.logSeen(who, "%s의 충돌로 대지가 흔들립니다!", o:getName():capitalize())
				local tg = {type="ball", range=0, selffire=false, radius=2, no_restrict=true}
				who:project(tg, target.x, target.y, engine.DamageType.PHYSICAL, dam)
			end
		end},
	},
	wielder = {
		inc_damage={[DamageType.PHYSICAL] = 12,},
		knockback_immune=0.3,
		combat_critical_power = 40,
	},
	max_power = 50, power_regen = 1,
	use_power = { name = "주변의 적 밀어내기", power = 50,
		use = function(self, who)
			local dam = rng.avg(1,2) * (125+ who:getStr() * 3)
			local tg = {type="ball", range=0, selffire=false, radius=4, no_restrict=true}
			who:project(tg, who.x, who.y, engine.DamageType.PHYSKNOCKBACK, {dam=dam, dist=4})
			game.logSeen(who, "%s %s 땅을 내려치자, 충격파가 발생합니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), self:getName():addJosa("로"))
			return {id=true, used=true}
		end
	},
}
--Molten Skin, dropped by Heavy Sentinel.
newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {arcane=true},
	define_as = "ARMOR_MOLTEN",
	unided_name = "melting bony armour",
	name = "Molten Skin", unique=true, image = "object/artifact/molten_skin.png",
	kr_display_name = "용해된 외판", kr_unided_name = "용해된 갑옷",
	desc = [[이 무거운 파수꾼의 뼈를 녹여 만든 덩어리는 강렬한 힘을 뿜고 있습니다. 파수꾼의 중심에서 나온 열기에 의해 이것은 아직도 붉게 빛나고 있지만, 당신에게는 아무런 해도 끼치지 않는것 같습니다.]],
--	require = { stat = { mag=60 }, },
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level=5,
	wielder = {
		combat_spellpower = 15,
		combat_spellcrit = 10,
		combat_physcrit = 8,
		combat_damage = 10,
		combat_critical_power = 20,
		combat_def = 15,
		combat_armor = 12,
		inc_stats = { [Stats.STAT_MAG] = 6,[Stats.STAT_CUN] = 6,},
		melee_project={[DamageType.FIRE] = 30,[DamageType.LIGHT] = 15,},
		ranged_project={[DamageType.FIRE] = 30,[DamageType.LIGHT] = 15,},
		on_melee_hit = {[DamageType.FIRE]=30},
 		inc_damage={
			[DamageType.FIRE] = 20,
			[DamageType.LIGHT] = 5,
			all=10,
 		},
 		resists={
			[DamageType.FIRE] = 20,
			[DamageType.LIGHT] = 12,
			[DamageType.COLD] = -5,
 		},
 		resists_pen={
			[DamageType.FIRE] = 15,
			[DamageType.LIGHT] = 10,
 		},
 		talents_types_mastery = {
 			["spell/fire"] = 0.1,
 			["spell/wildfire"] = 0.1,
			["celestial/sun"] = 0.1,
 		},
	},
	max_power = 16, power_regen = 1,
	use_talent = { id = Talents.T_BLASTWAVE, level = 4, power = 12 },
}

newEntity{ base = "BASE_RING",
	power_source = {arcane=true},
	define_as = "AETHER_RING",
	name = "Void Orb", unique=true, image = "object/artifact/void_orbs.png",
	kr_display_name = "공허의 오브", kr_unided_name = "천상의 반지",
	desc = [[이 가는 회색 반지는 짙은 검은 오브로 장식되어 있습니다. 작은 흰 점이 그 속에서 천천히 소용돌이치고 있고, 그 중심에서 희미한 보라색 빛이나고 있습니다.]],
	unided_name = "ethereal ring",
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	wielder = {
		max_mana = 35,
		combat_spellresist = 18,
		combat_spellpower = 5,
		silence_immune = 0.3,
		talent_cd_reduction={
			[Talents.T_AETHER_AVATAR]=4,
		},
		inc_damage={ [DamageType.ARCANE] = 15, [DamageType.PHYSICAL] = 7, [DamageType.FIRE] = 7, [DamageType.COLD] = 7, [DamageType.LIGHTNING] = 7},
		resists={ [DamageType.ARCANE] = 15,},
		resists_pen={ [DamageType.ARCANE] = 10,},
		melee_project={ [DamageType.ARCANE] = 15,},
		talents_types_mastery = {
 			["spell/arcane"] = 0.1,
 			["spell/aether"] = 0.1,
 		},
	},
	max_power = 6, power_regen = 1,
	use_talent = { id = Talents.T_MANATHRUST, level = 4, power = 6 },
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {arcane=true},
	define_as = "KHULMANAR_WRATH",
	name = "Khulmanar's Wrath", color = colors.DARK_RED, image = "object/artifact/hellfire.png",
	unided_name = "firey blackened battleaxe", unique = true,
	kr_display_name = "크훌마나르의 분노", kr_unided_name = "불타는 검은 대형도끼",
	desc = [[그을음으로 검은 빛을 띄고 가시로 덮힌, 이 대형도끼는 공포의 영역의 불꽃으로 울부짖고 있습니다. 울흐'록이 그의 장군에게 수여한 이 강력한 무기는 가장 활기한 적이라 할지라도 태워버릴 수 있습니다.]],
	level_range = {37, 50},
	rarity = 300,
	require = { stat = { str=52 }, },
	cost = 600,
	material_level = 5,
	combat = {
		dam = 70,
		apr = 8,
		physcrit = 8,
		dammod = {str=1.2},
		convert_damage = {[DamageType.FIRE] = 20},
		melee_project={[DamageType.FIRE] = 50,}
	},
	wielder = {
		demon=1,
		inc_damage={
			[DamageType.FIRE] = 20,
		},
		resists={
			[DamageType.FIRE] = 20,
		},
		resists_pen={
			[DamageType.FIRE] = 25,
		},
	},
	max_power = 35, power_regen = 1,
	use_talent = { id = Talents.T_INFERNAL_BREATH, level = 3, power = 35 },
}

newEntity{ base = "BASE_TOOL_MISC", image="object/temporal_instability.png",
	power_source = {arcane=true, psionic=true},
	define_as = "BLADE_RIFT",
	unique = true,
	name = "The Bladed Rift", color = colors.BLUE, image = "object/artifact/bladed_rift.png",
	unided_name = "hole in space",
	kr_display_name = "균열의 칼날", kr_unided_name = "공간의 구멍",
	desc = [[패해한 악'기실은 작은 균열로 붕괴하였습니다. 어떻게 그것이 안정화 되었는지는 알 수 없습니다. 이것에 집중하면, 그 안에서 칼날을 밖으로 불러낼 수 있을 것 같습니다.]],
	level_range = {30, 50},
	rarity = 500,
	cost = 500,
	material_level = 4,
	metallic = false,
	wielder = {
		combat_spellpower=5,
		combat_mindpower=5,
		on_melee_hit = {[DamageType.PHYSICALBLEED]=25},
		resists={
			[DamageType.TEMPORAL] 	= 15,
		},
		inc_damage={
			[DamageType.TEMPORAL] 	= 10,
			[DamageType.PHYSICAL] 	= 5,
		},
	},
	max_power = 40, power_regen = 1,
	use_talent = { id = Talents.T_ANIMATE_BLADE, level = 1, power = 40 },
}

newEntity{ base = "BASE_LONGSWORD", define_as = "RIFT_SWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Blade of Distorted Time", image = "object/artifact/blade_of_distorted_time.png",
	unided_name = "time-warped sword",
	kr_display_name = "왜곡된 시간의 칼날", kr_unided_name = "시간 왜곡의 장검",
	desc = [[상처입은 시간의 흐름의 유품으로, 이 칼날은 임의로 모양이 변하고 사라지기도 합니다.]],
	level_range = {30, 50},
	rarity = nil, --Not random!
	require = { stat = { str=44 }, },
	cost = 300,
	material_level = 4,
	combat = {
		dam = 40,
		apr = 10,
		physcrit = 8,
		dammod = {str=0.8,mag=0.2},
		convert_damage={[DamageType.TEMPORAL] = 20},
		special_on_hit = {desc="20% 확률로 대상을 감속", fct=function(combat, who, target)
			if not rng.percent(20) then return end
			local dam = (20 + who:getMag()/2)
			local slow = (10 + who:getMag()/5)/100
			who:project({type="hit", range=1}, target.x, target.y, engine.DamageType.CHRONOSLOW, {dam=dam, slow=slow})
		end},
	},
	wielder = {
		inc_damage={
			[DamageType.TEMPORAL] = 12,
			[DamageType.PHYSICAL] = 10,
		},
	},
	max_power = 8, power_regen = 1,
	use_talent = { id = Talents.T_RETHREAD, level = 2, power = 8 },
}

newEntity{ base = "BASE_RUNE", define_as = "RUNE_REFLECT",
	name = "Rune of Reflection", unique=true, image = "object/artifact/rune_of_reflection.png",
	desc = [[이 은빛 룬의 표면으로 복제된 당신의 허상을 볼 수 있습니다.]],
	unided_name = "shiny rune",
	kr_display_name = "반사의 룬", kr_unided_name = "빛나는 룬",
	level_range = {5, 15},
	rarity = 240,
	cost = 100,
	material_level = 3,

	inscription_kind = "protect",
	inscription_data = {
		cooldown = 15,
	},
	inscription_talent = "RUNE:_REFLECTION_SHIELD",
}

newEntity{ base = "BASE_MINDSTAR", define_as = "PSIONIC_FURY",
	power_source = {psionic=true},
	unique = true,
	name = "Psionic Fury",
	unided_name = "vibrating mindstar",
	kr_display_name = "염동적 분노", kr_unided_name = "진동하는 마석",
	level_range = {24, 32},
	color=colors.AQUAMARINE, image = "object/artifact/psionic_fury.png",
	rarity = 250,
	desc = [[이 마석은 그 속에서 강력한 힘이 필사적으로 탈출하려는 듯 끝없이 흔들리고 떨립니다.]],
	cost = 85,
	require = { stat = { wil=24 }, },
	material_level = 3,
	combat = {
		dam = 12,
		apr = 25,
		physcrit = 5,
		dammod = {wil=0.4, cun=0.2},
		damtype = DamageType.MIND,
	},
	wielder = {
		combat_mindpower = 10,
		combat_mindcrit = 8,
		inc_damage={
			[DamageType.MIND] 		= 15,
			[DamageType.PHYSICAL]	= 5,
		},
		resists={
			[DamageType.MIND] 		= 10,
		},
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 4, },
	},
	max_power = 40, power_regen = 1,
	use_power = { name = "염동력 파동 분출", power = 40,
	use = function(self, who)
		local radius = 4
		local dam = (50 + who:getWil()*1.8)
		local blast = {type="ball", range=0, radius=5, selffire=false}
		who:project(blast, who.x, who.y, engine.DamageType.MIND, dam)
		game.level.map:particleEmitter(who.x, who.y, blast.radius, "force_blast", {radius=blast.radius})
		game.logSeen(who, "%s 염동적 에너지탄을 발사했습니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), self:getName())
		return {id=true, used=true}
		end
	},
}
