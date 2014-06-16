-- ToME - Tales of Middle-Earth
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

require "engine.krtrUtils"

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- This file describes artifacts associated with a boss of the game, they have a high chance of dropping their respective ones, but they can still be found elsewhere

newEntity{ base = "BASE_KNIFE", define_as = "LIFE_DRINKER",
	power_source = {arcane=true},
	unique = true,
	name = "Life Drinker", image = "object/artifact/dagger_life_drinker.png",
	unided_name = "blood coated dagger",
	kr_name = "피를 마시는 자", kr_unided_name = "피에 절은 단검",
	desc = [[사악한 행위를 위한 검은 피, 이 단검은 악을 섬긴다.]],
	level_range = {40, 50},
	rarity = 300,
	require = { stat = { mag=44 }, },
	cost = 450,
	material_level = 5,
	combat = {
		dam = 42,
		apr = 11,
		physcrit = 18,
		dammod = {mag=0.55,str=0.35},
	},
	wielder = {
		inc_damage={
			[DamageType.BLIGHT] = 15,
			[DamageType.DARKNESS] = 15,
			[DamageType.ACID] = 15,
		},
		combat_spellpower = 12,
		combat_spellcrit = 10,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_CUN] = 6, },
		infravision = 2,
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_WORM_ROT, level = 2, power = 40 },
	talent_on_spell = {
		{chance=15, talent=Talents.T_BLOOD_GRASP, level=2},
	},
}

newEntity{ base = "BASE_TRIDENT",
	power_source = {nature=true},
	define_as = "TRIDENT_TIDES",
	unided_name = "ever-dripping trident",
	kr_name = "해일의 삼지창", kr_unided_name = "항상 물방울이 흐르는 삼지창",
	name = "Trident of the Tides", unique=true, image = "object/artifact/trident_of_the_tides.png",
	desc = [[밀려오는 해일의 힘이 이 삼지창에 들어있습니다.
삼지창을 제대로 쓰려면 이형 무기 수련 기술이 필요합니다.]],
	require = { stat = { str=35 }, },
	level_range = {30, 40},
	rarity = 230,
	cost = 300,
	material_level = 4,
	combat = {
		dam = 80,
		apr = 20,
		physcrit = 15,
		dammod = {str=1.4},
		damrange = 1.4,
		melee_project={
			[DamageType.COLD] = 15,
			[DamageType.NATURE] = 20,
		},
		talent_on_hit = { T_WATER_BOLT = {level=3, chance=40} }
	},

	wielder = {
		combat_atk = 10,
		combat_spellresist = 18,
		see_invisible = 2,
		resists={[DamageType.COLD] = 25},
		inc_damage = { [DamageType.COLD] = 20 },
	},

	talent_on_spell = { {chance=20, talent="T_WATER_BOLT", level=3} },

	max_power = 150, power_regen = 1,
	use_talent = { id = Talents.T_FREEZE, level=3, power = 60 },
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	define_as = "FIERY_CHOKER", 
	unided_name = "flame-wrought amulet",
	name = "Fiery Choker", unique=true, image="object/artifact/fiery_choker.png",
	kr_name = "불타는 목고리", kr_unided_name = "불꽃으로 장식된 목걸이", --@ choker의 어감을 위해 목고리라 번역
	desc = [[순수한 불꽃으로 만들어진 목걸이로, '목걸이' 라기보다는 목에 꽉 끼는 '목고리' 입니다. 착용자의 목에 둘러진 채 끊임없이 그 무늬가 변하고 있지만, 그 불길이 착용자에게 해를 끼치지는 않는 것 같습니다.]],
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

newEntity{ base = "BASE_HEAVY_ARMOR",
	power_source = {nature=true},
	define_as = "CHROMATIC_HARNESS", image = "object/artifact/armor_chromatic_harness.png",
	name = "Chromatic Harness", unique=true,
	unided_name = "multi-hued scale-mail armour", color=colors.VIOLET,
	kr_name = "무지개빛 작업복", kr_unided_name = "여러색의 비늘 갑옷",
	desc = [[여러가지 색깔로 반짝이고 있는 작업복입니다, 빠르게 색깔들이 변화하고 있어, 원래 색이 무엇이었는지 분간이 되지 않습니다.]],
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

-- Randart rings are REALLY good, these need to be brought up to par
newEntity{ base = "BASE_RING",
	power_source = {technique=true},
	define_as = "PRIDE_GLORY",
	name = "Glory of the Pride", unique=true, image="object/artifact/glory_of_the_pride.png",
	kr_name = "부족의 영광", kr_unided_name = "짙은 검은색 반지",
	desc = [[오크 긍지의 전장을 지배한 자, 그루쉬낙이 가장 귀중하게 여기는 보물입니다. 이 금빛 반지에는 이제는 잊혀진 오크의 언어가 새겨져 있습니다.]],
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
		combat_armor_hardiness = 20,
		fatigue = -15,
		talent_cd_reduction={
			[Talents.T_RUSH]=6,
		},
		inc_damage={ [DamageType.PHYSICAL] = 8, },
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	define_as = "BLACK_ROBE",
	name = "Black Robe", unique=true,
	unided_name = "black robe", color=colors.DARK_GREY, image = "object/artifact/robe_black_robe.png",
	kr_name = "검은 로브", kr_unided_name = "검은 로브",
	desc = [[어두운 밤하늘보다 더 어두운 비단 로브로, 알 수 없는 힘을 발산하고 있습니다.]],
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

newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {arcane=true},
	define_as = "CROWN_ELEMENTS", 
	name = "Crown of the Elements", unique=true, image = "object/artifact/crown_of_the_elements.png",
	unided_name = "jeweled crown", color=colors.DARK_GREY,
	kr_name = "원소의 왕관", kr_unided_name = "보석으로 장식된 왕관",
	desc = [[보석으로 장식된 왕관으로, 다양한 색으로 빛나고 있습니다.]],
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
		inc_damage = {
			[DamageType.FIRE] = 8,
			[DamageType.COLD] = 8,
			[DamageType.ACID] = 8,
			[DamageType.LIGHTNING] = 8,
		},
		see_invisible = 15,
		combat_armor = 5,
		fatigue = 5,
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {technique=true},
	define_as = "MURDERBLADE",
	name = "Warmaster Gnarg's Murderblade", unique=true, image="object/artifact/warmaster_gnargs_murderblade.png",
	unided_name = "blood-etched greatsword", color=colors.CRIMSON,
	kr_name = "전투의 대가 나르그의 살해검", kr_unided_name = "피로 물든 대검",
	desc = [[피로 물든 대검입니다. 이 검은 지금까지 많은 적을 보아왔습니다. 아니, 많은 적의 장기와 살점을 보아왔습니다.]],
	require = { stat = { str=35 }, },
	level_range = {32, 45},
	rarity = 230,
	cost = 300,
	material_level = 4,
	combat = {
		dam = 60,
		apr = 19,
		physcrit = 10,
		dammod = {str=1.2},
		special_on_hit = {desc="10% 확률로 사용자에게 살해의 광란 상태 부여", on_kill=1, fct=function(combat, who)
			if not rng.percent(10) then return end
			who:setEffect(who.EFF_FRENZY, 3, {crit=12, power=0.3, dieat=0.25})
		end},
		inc_damage_type = {living=20},
	},
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 15, [Stats.STAT_STR] = 15, [Stats.STAT_DEX] = 5, },
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.2,
			["technique/2hweapon-offense"] = 0.2,
			["technique/2hweapon-assault"] = 0.2,
		},
		resists_actor_type = {living=20},
	},
}

newEntity{ base = "BASE_WHIP",
	power_source = {arcane=true},
	define_as = "WHIP_URH_ROK",
	unided_name = "fiery whip",
	name = "Whip of Urh'Rok", color=colors.PURPLE, unique = true, image = "object/artifact/whip_of_urh_rok.png",
	kr_name = "울흐'록의 채찍", kr_unided_name = "불타는 채찍",
	desc = [[전투에서 절대 패하지 않는다는 강력한 악마 울흐'록의 채찍으로, 극도로 밝은 불꽃이 타오르고 있습니다.]],
	require = { stat = { dex=48 }, },
	level_range = {40, 50},
	rarity = 390,
	cost = 250,
	material_level = 5,
	combat = {
		dam = 55,
		apr = 0,
		physcrit = 9,
		dammod = {dex=1},
		damtype = DamageType.FIREKNOCKBACK,
		talent_on_hit = { [Talents.T_BONE_NOVA] = {level=4, chance=20}, [Talents.T_BLOOD_BOIL] = {level=3, chance=15} },
	},
	wielder = {
		esp = {["demon/minor"]=1, ["demon/major"]=1},
		see_invisible = 2,
		combat_spellpower = 15,
		inc_damage={
			[DamageType.FIRE] = 20,
			[DamageType.BLIGHT] = 20,
	},
	},
	carrier = {
		inc_damage={
			[DamageType.BLIGHT] = 8,
		},
	},
}

--Storm fury, lightning infused bow that automatically attacks nearby enemies with bolts of lightning.
newEntity{ base = "BASE_LONGBOW",
	power_source = {arcane=true},
	define_as = "STORM_FURY",
	name = "Storm Fury", unique=true,
	unided_name = "crackling longbow", color=colors.BLUE,
	kr_name = "폭풍의 분노", kr_unided_name = "파직거리는 활",
	desc = [[이 용뼈 활은 강렬한 뇌전을 띄고 있는 강철 끈으로 강화되었습니다. 당신의 의지와는 무관하게, 전기가 시위를 따라 위아래로 흐르고 있습니다.]],
	require = { stat = { dex=30, mag=30 }, },
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	sentient = true,
	special_desc = function(self) return "자동으로 근방에 있는 적들에게 뇌전의 화살을 쏩니다. 이 공격으로 적을 혼절시킬 수도 있습니다." end,
	combat = {
		range=10,
		physspeed = 0.7,
	},
	wielder = {
		combat_spellpower=20,
		inc_stats = { [Stats.STAT_MAG] = 7, [Stats.STAT_DEX] = 5},
		combat_def_ranged = 15,
		ranged_project = {[DamageType.LIGHTNING] = 75},
		talents_types_mastery = {
			["spell/air"] = 0.2,
			["spell/storm"] = 0.1,
		},
		inc_damage={
			[DamageType.LIGHTNING] = 20,
		},
		resists={
			[DamageType.LIGHTNING] = 20,
		},
		talent_on_hit = { T_CHAIN_LIGHTNING = {level=3, chance=12},},
		movement_speed=0.1,
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
			who:logCombat(a, "#GOLD#뇌전의 화살이 #Source#의 활에서 발사되어, #Target3# 맞춥니다!")
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
	kr_name = "얼어붙은 장막", kr_unided_name = "차가운 망토",
	desc = [[이 망토 하나가, 빙하의 부대가 남긴 전부입니다. 망토를 건드리는 것들을 모두 얼려버리는, 얼음같이 차가운 증기가 망토에서 흘러나오고 있습니다.]],
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
	use_power = { name = "release a blast of ice", kr_name = "얼음구 발사", power = 30,
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
				engine.MapEffect.new{color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/ice_effect.png"},
				function(e)
					e.radius = e.radius
					return true
				end,
				false
			)
			game.logSeen(who, "%s 망토 안에서 차가운 얼음 덩어리를 발사합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName())
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
	kr_name = "황폐한 망치", kr_unided_name = "썩은 암석 다리",
	desc = [[썩은 타이탄의 거대한 암석 다리로, 암석과 썩은 살점이 섞여있습니다. 들 수는 있지만, 엄청나게 무겁습니다.]],
	level_range = {40, 50},
	rarity = 250,
	require = { stat = { str=60 }, },
	cost = 300,
	metallic = false,
	encumber = 12,
	material_level = 5,
	combat = {
		dam = 96,
		apr = 22,
		physcrit = 10,
		physspeed=1.2,
		dammod = {str=1.4},
		convert_damage = {[DamageType.BLIGHT] = 20},
		melee_project={[DamageType.ITEM_BLIGHT_DISEASE] = 50},
		special_on_hit = {desc="Damages enemies in radius 1 around your target (based on Strength).", on_kill=1, fct=function(combat, who, target) --@@ 한글화 필요
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "ROTTING_MAUL")
			local dam = rng.avg(1,3) * (70+ who:getStr())
			game.logSeen(who, "%s의 충돌로 인해, 대지가 흔들립니다!", o:getName():capitalize())
			local tg = {type="ball", range=10, selffire=false, force_target=target, radius=1, no_restrict=true}
			who:project(tg, target.x, target.y, engine.DamageType.PHYSICAL, dam)
		end},
	},
	wielder = {
		inc_damage={[DamageType.PHYSICAL] = 12,},
		knockback_immune=0.3,
		combat_critical_power = 40,
	},
	max_power = 50, power_regen = 1,
	use_power = { name = "knock away nearby foes", kr_name = "주변의 적 밀어내기", power = 50,
		use = function(self, who)
			local dam = rng.avg(1,2) * (125+ who:getStr() * 3)
			local tg = {type="ball", range=0, selffire=false, radius=4, no_restrict=true}
			who:project(tg, who.x, who.y, engine.DamageType.PHYSKNOCKBACK, {dam=dam, dist=4})
			game.logSeen(who, "%s %s 땅을 내려치자, 충격파가 발생합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName():addJosa("로"))
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
	kr_name = "용해된 뼈갑옷", kr_unided_name = "용해된 갑옷",
	desc = [[육중한 파수꾼의 뼈를 녹여 만든 덩어리러. 강렬한 힘을 뿜어내고 있습니다. 파수꾼의 중심부에서 나오는 열기에 의해 아직도 붉게 빛나고 있지만, 당신에게는 아무런 해도 끼치지 않는 것 같습니다.]],
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level=5,
	moddable_tile = "special/molten_skin",
	moddable_tile_big = true,

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
	kr_name = "공허의 오브", kr_unided_name = "에테르 반지",
	desc = [[검은 오브로 장식된, 가늘고 얇은 회색 반지입니다. 작은 흰색 점이 오브 속에서 천천히 소용돌이치고 있으며, 그 중심에서는 희미한 보라색 빛이 나고 있습니다.]],
	unided_name = "ethereal ring",
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level = 5,
	wielder = {
		max_mana = 35,
		combat_spellresist = 10,
		combat_spellpower = 10,
		combat_spellcrit=5,
		silence_immune = 0.3,
		talent_cd_reduction={
			[Talents.T_AETHER_AVATAR]=4,
		},
		inc_damage={ [DamageType.ARCANE] = 15, [DamageType.PHYSICAL] = 4, [DamageType.FIRE] = 4, [DamageType.COLD] = 4, [DamageType.LIGHTNING] = 4, all=5},
		resists={ [DamageType.ARCANE] = 15,},
		resists_pen={ [DamageType.ARCANE] = 10,},
		melee_project={ [DamageType.ARCANE] = 15,},
		talents_types_mastery = {
 			["spell/arcane"] = 0.1,
 			["spell/aether"] = 0.1,
 		},
	},
	talent_on_spell = { {chance=10, talent="T_ARCANE_VORTEX", level = 2} },
	max_power = 6, power_regen = 1,
	use_talent = { id = Talents.T_MANATHRUST, level = 4, power = 6 },
}
