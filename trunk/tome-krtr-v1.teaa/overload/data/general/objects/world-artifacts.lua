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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

--- Load additional artifacts
for def, e in pairs(game.state:getWorldArtifacts()) do
	importEntity(e)
	print("Importing "..e.name.." into world artifacts")
end

-- This file describes artifacts not bound to a special location, they can be found anywhere
newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Staff of Destruction",
	flavor_name = "magestaff",
	unided_name = "darkness infused staff", image = "object/artifact/staff_of_destruction.png",
	kr_display_name = "파괴의 지팡이", kr_unided_name = "어둠이 주입된 지팡이",
	level_range = {20, 25},
	color=colors.VIOLET,
	rarity = 170,
	desc = [[굉장히 특이하게 생긴 지팡이로, 파괴의 룬이 새겨져 있습니다.]],
	cost = 200,
	material_level = 3,

	require = { stat = { mag=24 }, },
	modes = {"fire", "cold", "lightning", "arcane"},
	combat = {
		dam = 20,
		apr = 4,
		dammod = {mag=1.5},
		damtype = DamageType.FIRE,
		is_greater = true,
	},
	wielder = {
		combat_spellpower = 10,
		combat_spellcrit = 15,
		inc_damage={
			[DamageType.FIRE] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.COLD] = 20,
			[DamageType.ARCANE] = 20,
		},
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1},
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Penitence",
	flavor_name = "starstaff",
	unided_name = "glowing staff", image = "object/artifact/staff_penitence.png",
	kr_display_name = "참회", kr_unided_name = "빛나는 지팡이",
	level_range = {10, 18},
	color=colors.VIOLET,
	rarity = 200,
	desc = [[마법폭발에 의해 퍼진 전염병과 맞서 싸우는 자들을 위해, 앙골웬에 있는 샬로레들이 비밀리에 보낸 강력한 지팡이입니다.]],
	cost = 200,
	material_level = 2,

	require = { stat = { mag=24 }, },
	combat = {
		--sentient = "penitent", -- commented out for now...  how many sentient staves do we need?
		dam = 15,
		apr = 4,
		dammod = {mag=1.2},
		damtype = DamageType.NATURE, -- Note this is odd for a staff; it's intentional and it's also why the damage type can't be changed.  Blight on this staff would be sad :(
	},
	wielder = {
		combat_spellpower = 15,
		combat_spellcrit = 10,
		resists = {
			[DamageType.BLIGHT] = 30,
		},
	},
	max_power = 60, power_regen = 1,
	use_power = { name = "질병 치료", power = 10,
		use = function(self, who)
			local target = who
			local effs = {}
			local known = false

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.disease then
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
			game.logSeen(who, "%s의 질병이 치료되었습니다!", (who.kr_display_name or who.name):capitalize())
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Lost Staff of Archmage Tarelion", image = "object/artifact/staff_lost_staff_archmage_tarelion.png",
	unided_name = "shining staff",
	kr_display_name = "마도사 타렐리온의 잃어버린 지팡이", kr_unided_name = "빛나는 지팡이",
	flavor_name = "magestaff",
	level_range = {37, 50},
	color=colors.VIOLET,
	rarity = 250,
	desc = [[마도사 타렐리온이 어렸을 때, 그는 세계를 여행한 적이 있습니다. 하지만 세상은 그에게 있어서 좋은 곳이 아니었고, 그는 빨리 도망쳐야만 했습니다.]],
	cost = 400,
	material_level = 5,

	require = { stat = { mag=48 }, },
	modes = {"fire", "cold", "lightning", "arcane"},
	combat = {
		is_greater = true,
		dam = 30,
		apr = 4,
		dammod = {mag=1.5},
		damtype = DamageType.ARCANE,
	},
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 7, [Stats.STAT_MAG] = 8 },
		max_mana = 40,
		combat_spellpower = 40,
		combat_spellcrit = 25,
		inc_damage = { [DamageType.ARCANE] = 30, [DamageType.FIRE] = 30, [DamageType.COLD] = 30, [DamageType.LIGHTNING] = 30,  },
		silence_immune = 0.4,
		mana_on_crit = 12,
		talent_cd_reduction={
			[Talents.T_ICE_STORM] = 2,
			[Talents.T_FIREFLASH] = 2,
			[Talents.T_CHAIN_LIGHTNING] = 2,
			[Talents.T_ARCANE_VORTEX] = 2,
		},
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1,},
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Bolbum's Big Knocker", image = "object/artifact/staff_bolbums_big_knocker.png",
	unided_name = "thick staff",
	kr_display_name = "볼붐의 큰 두드림", kr_unided_name = "두꺼운 지팡이",
	level_range = {20, 35},
	color=colors.UMBER,
	rarity = 220,
	desc = [[끝부분에 무거운 장식이 달린 두꺼운 지팡이로, 매혹의 시대에 살았던 위대한 연금술사 볼붐이 사용하던 것으로 알려져 있습니다. 볼붐 밑에서 연금술을 연구하던 자들에게 있어, 볼붐은 높은 확률로 제자들에게 치명적인 두뇌 부상을 입히는 공포의 대상이었습니다. 결국 볼붐은 일곱 개의 단검이 등에 꽂혀 죽음을 맞이하였고, 그 이후로 그의 저주받은 지팡이 역시 사라졌다고 알려졌습니다.]],
	cost = 300,
	material_level = 3,

	require = { stat = { mag=38 }, },
	combat = {
		dam = 64,
		apr = 10,
		dammod = {mag=1.4},
		damtype = DamageType.PHYSICAL,
	},
	wielder = {
		combat_atk = 7,
		combat_spellpower = 12,
		combat_spellcrit = 18,
		inc_damage={
			[DamageType.PHYSICAL] = 20,
		},
		talents_types_mastery = {
			["spell/staff-combat"] = 0.2,
		}
	},
}

newEntity{ base = "BASE_RING",
	power_source = {nature=true},
	unique = true,
	name = "Vargh Redemption", color = colors.LIGHT_BLUE, image="object/artifact/ring_vargh_redemption.png",
	unided_name = "sea-blue ring",
	kr_display_name = "바르그의 구원", kr_unided_name = "바닷빛 반지",
	desc = [[이 하늘빛 반지는 언제나 촉촉함을 유지하고 있습니다.]],
	level_range = {10, 20},
	rarity = 150,
	cost = 500,
	material_level = 2,

	max_power = 60, power_regen = 1,
	use_power = { name = "해일 소환", power = 60,
		use = function(self, who)
			local duration = 7
			local radius = 1
			local dam = 20
			-- Add a lasting map effect
			game.level.map:addEffect(who,
				who.x, who.y, duration,
				engine.DamageType.WAVE, {dam=dam, x=who.x, y=who.y},
				radius,
				5, nil,
				engine.Entity.new{alpha=100, display='', color_br=30, color_bg=60, color_bb=200},
				function(e)
					e.radius = e.radius + 0.4
					return true
				end,
				false
			)
			game.logSeen(who, "%s %s 휘두르자, 바다의 힘이 몰아치기 시작합니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), self:getName():addJosa("를"))
			return {id=true, used=true}
		end
	},
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CON] = 6 },
		max_mana = 20,
		max_stamina = 20,
		max_psi = 20,
		max_air = 50,
		resists = {
			[DamageType.COLD] = 25,
			[DamageType.NATURE] = 10,
		},
	},
}

newEntity{ base = "BASE_RING",
	power_source = {nature=true},
	unique = true,
	name = "Ring of the Dead", color = colors.DARK_GREY, image = "object/artifact/jewelry_ring_of_the_dead.png",
	unided_name = "dull black ring",
	kr_display_name = "죽은 자의 반지", kr_unided_name = "칙칙한 검은색 반지",
	desc = [[이 반지에는 무덤 저 너머의 힘이 들어 있습니다. 이 반지의 착용자는, 모든 길이 희미해질 때 새로운 다른 길을 찾을 수 있게 된다고 합니다.]],
	level_range = {35, 42},
	rarity = 250,
	cost = 500,
	material_level = 4,

	wielder = {
		inc_stats = { [Stats.STAT_LCK] = 10, },
	},
	one_shot_life_saving = true,
}

newEntity{ base = "BASE_RING",
	power_source = {arcane=true},
	unique = true,
	name = "Elemental Fury", color = colors.PURPLE, image = "object/artifact/ring_elemental_fury.png",
	unided_name = "multi-hued ring",
	kr_display_name = "원소의 분노", kr_unided_name = "무지개빛 반지",
	desc = [[이 반지는 다양한 색깔로 빛나고 있습니다.]],
	level_range = {15, 30},
	rarity = 200,
	cost = 200,
	material_level = 3,

	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 3,[Stats.STAT_CUN] = 3, },
		inc_damage = {
			[DamageType.ARCANE]    = 12,
			[DamageType.FIRE]      = 12,
			[DamageType.COLD]      = 12,
			[DamageType.ACID]      = 12,
			[DamageType.LIGHTNING] = 12,
		},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Spellblaze Echos", color = colors.DARK_GREY, image = "object/artifact/amulet_spellblaze_echoes.png",
	unided_name = "deep black amulet",
	kr_display_name = "마법폭풍의 메아리", kr_unided_name = "칠흑같이 새까만 목걸이",
	desc = [[이 고대의 부적은 아직도 마법폭발이 일으킨 파괴의 메아리를 담고 있습니다.]],
	level_range = {30, 39},
	rarity = 290,
	cost = 500,
	material_level = 4,

	wielder = {
		combat_armor = 6,
		combat_def = 6,
		combat_spellpower = 8,
		combat_spellcrit = 6,
		spellsurge_on_crit = 15,
	},
	max_power = 60, power_regen = 1,
	use_power = { name = "파괴의 통곡 방출", power = 60,
		use = function(self, who)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.PHYSICAL, 250 + who:getMag() * 3)
			game.logSeen(who, "%s %s 사용했습니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), self:getName():addJosa("를"))
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {technique=true},
	unique = true,
	name = "Feathersteel Amulet", color = colors.WHITE, image = "object/artifact/feathersteel_amulet.png",
	unided_name = "light amulet",
	kr_display_name = "깃털강철 목걸이", kr_unided_name = "가벼운 목걸이",
	desc = [[이 목걸이를 착용하,면 주변에 있는 세상 모든 것들의 무게가 가벼워집니다.]],
	level_range = {5, 15},
	rarity = 200,
	cost = 90,
	material_level = 2,
	wielder = {
		max_encumber = 20,
		fatigue = -20,
		avoid_pressure_traps = 1,
		movement_speed = 0.2,
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {technique=true},
	unique = true,
	name = "Daneth's Neckguard", color = colors.STEEL_BLUE, image = "object/artifact/daneths_neckguard.png",
	unided_name = "a thick steel gorget",
	kr_display_name = "다네스의 목 보호대", kr_unided_name = "두꺼운 강철 목가리개",
	desc = [[치명적인 공격으로부터 착용자의 목을 보호하기 위해 만들어진, 두꺼운 강철 목 보호대입니다. 특히 이 목 보호대는 하플링 장군이었던 다네스 텐더모운이, 장작더미의 시대에 벌어졌던 전쟁에서 사용한 것입니다. 표면에 패인 흔적들을 봤을 때, 장군의 생명을 여러 번 구했던 것 같습니다.]],
	level_range = {20, 30},
	rarity = 300,
	cost = 300,
	encumber = 2,
	material_level = 2,
	wielder = {
		combat_armor = 10,
		fatigue = 2,
		inc_stats = {
			[Stats.STAT_STR] = 6,
			[Stats.STAT_CON] = 6,
		},
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_JUGGERNAUT, level = 2, power = 30 },
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Talents = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["technique/battle-tactics"] = 0.2 })
			self:specialWearAdd({"wielder","combat_armor"}, 5)
			self:specialWearAdd({"wielder","combat_crit_reduction"}, 10)
			game.logPlayer(who, "#LIGHT_BLUE#불굴의 의지가 느껴집니다!")
		end
	end,
}

newEntity{ base = "BASE_AMULET", define_as = "SET_GARKUL_TEETH",
	power_source = {technique=true},
	unique = true,
	name = "Garkul's Teeth", color = colors.YELLOW, image = "object/artifact/amulet_garkuls_teeth.png",
	unided_name = "a necklace made of teeth",
	kr_display_name = "가르쿨의 이빨", kr_unided_name = "이빨로 만들어진 목걸이",
	desc = [[인간과 하플링 수백 명의 이빨을 여러 겹으로 꼬인 가죽끈으로 엮어 만든, 원시적 목걸이입니다. 한 가지 확실한 것은 이 이빨들이 포식자 가르쿨의 것이 아니라, 그가 잡아먹은 것들의 이빨이라는 점입니다.]],
	level_range = {40, 50},
	rarity = 300,
	cost = 1000,
	material_level = 5,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = 10,
			[Stats.STAT_CON] = 6,
		},
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.1,
			["technique/2hweapon-offense"] = 0.1,
			["technique/warcries"] = 0.1,
			["technique/bloodthirst"] = 0.1,
		},
		combat_physresist = 18,
		combat_mentalresist = 18,
		pin_immune = 1,
	},
	max_power = 48, power_regen = 1,
	use_talent = { id = Talents.T_SHATTERING_SHOUT, level = 4, power = 10 },

	set_list = { {"define_as", "HELM_OF_GARKUL"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","die_at"}, -100)
		game.logSeen(who, "#CRIMSON#가르쿨의 두 가지 유물을 동시에 착용하자, 강력한 전사의 영혼이 당신에게 흘러 들어오는 것이 느껴집니다.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#CRIMSON#가르쿨의 영혼이 희미하게 사라집니다.")
	end,
}

newEntity{ base = "BASE_LITE",
	power_source = {nature=true},
	unique = true,
	name = "Summertide Phial", image="object/artifact/summertide_phial.png",
	unided_name = "glowing phial",
	kr_display_name = "밀려오는 여름의 유리병", kr_unided_name = "타오르는 듯한 유리병",
	level_range = {1, 10},
	color=colors.YELLOW,
	encumber = 1,
	rarity = 100,
	desc = [[밀려오는 여름의 달에 햇빛을 모아 담은, 수정으로 만들어진 작은 병입니다.]],
	cost = 200,

	max_power = 15, power_regen = 1,
	use_power = { name = "주변 밝히기", power = 10,
		use = function(self, who)
			who:project({type="ball", range=0, radius=20}, who.x, who.y, engine.DamageType.LITE, 100)
			game.logSeen(who, "%s %s 휘두르자, 주변이 밝게 빛납니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), self:getName():addJosa("를"))
			return {id=true, used=true}
		end
	},
	wielder = {
		lite = 4,
		healing_factor = 0.1,
		inc_damage = {[DamageType.LIGHT]=10},
		resists = {[DamageType.LIGHT]=30},
	},
}

newEntity{ base = "BASE_GEM",
	power_source = {arcane=true},
	unique = true,
	name = "Burning Star", image = "object/artifact/jewel_gem_burning_star.png",
	unided_name = "burning jewel",
	kr_display_name = "타오르는 별", kr_unided_name = "타오르는 보석",
	level_range = {20, 30},
	color=colors.YELLOW,
	encumber = 1,
	identified = false,
	rarity = 250,
	material_level = 3,
	desc = [[매혹의 시대에, 태양빛을 보석에 담는 방법을 발견한 최초의 하플링 마법사가 있었습니다.
이 별은 그중에서도 가장 뛰어난 보석으로, 끊임없이 모양이 변하는 노란 표면에서 빛이 뿜어져 나옵니다.]],
	cost = 400,

	max_power = 30, power_regen = 1,
	use_power = { name = "주변 지형 감지", power = 30,
		use = function(self, who)
			who:magicMap(20)
			game.logSeen(who, "%s %s 휘두르자, 모든 방향으로 빛이 뿜어져 나갑니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), self:getName():addJosa("를"))
			return {id=true, used=true}
		end
	},
	carrier = {
		lite = 1,
	},
}

newEntity{ base = "BASE_LITE",
	power_source = {arcane=true},
	unique = true,
	name = "Dúathedlen Heart",
	unided_name = "a dark, fleshy mass", image = "object/artifact/dark_red_heart.png",
	kr_display_name = "듀아세들렌의 심장", kr_unided_name = "어두운 살점 덩어리",
	level_range = {30, 40},
	color = colors.RED,
	encumber = 1,
	rarity = 300,
	material_level = 4,
	desc = [[이 검붉은 심장은 그 주인으로부터 떨어져 나왔음에도 불구하고, 여전히 뛰고 있습니다. 이것은 주변에 있는 모든 빛을 찾아 소멸시킵니다.]],
	cost = 100,

	wielder = {
		lite = -1000,
		infravision = 6,
		resists_cap = { [DamageType.LIGHT] = 10 },
		resists = { [DamageType.LIGHT] = 30 },
		talents_types_mastery = { ["cunning/stealth"] = 0.1 },
		combat_dam = 7,
	},

	max_power = 15, power_regen = 1,
	use_talent = { id = Talents.T_BLOOD_GRASP, level = 3, power = 10 },
}

newEntity{ base = "BASE_LITE",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Guidance", image = "object/artifact/guidance.png",
	unided_name = "a softly glowing crystal",
	kr_display_name = "길잡이", kr_unided_name = "부드럽게 빛나는 수정",
	level_range = {38, 50},
	color = colors.YELLOW,
	encumber = 1,
	rarity = 300,
	desc = [[심문관 마르쿠스 둔이 마법사냥을 하던 시절에 가지고 있던 것이라 알려져 있는 보석으로, 주먹만한 크기의 이 수정 결정은 부드러운 흰 빛으로 언제나 빛나고 있습니다. 명상이나 정신 집중, 육체적 집중, 또는 영혼으로의 집중에 큰 도움이 되며, 역겨운 마법으로부터는 착용자를 보호해 준다는 소문이 있습니다.
반마법을 추구하는 사람이 이것을 사용하면, 모든 잠재능력을 사용할 수 있을 것 같습니다.]],
	cost = 100,
	material_level = 5,

	wielder = {
		lite = 4,
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 6,},
		combat_physresist = 6,
		combat_mentalresist = 6,
		combat_spellresist = 6,
		talents_types_mastery = { ["wild-gift/call"] = 0.2, ["wild-gift/antimagic"] = 0.1, },
		resists_cap = { [DamageType.BLIGHT] = 10, },
		resists = { [DamageType.BLIGHT] = 20, },
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 6, })
			self:specialWearAdd({"wielder","combat_physresist"}, 6)
			self:specialWearAdd({"wielder","combat_spellresist"}, 6)
			self:specialWearAdd({"wielder","combat_mentalresist"}, 6)
			game.logPlayer(who, "#LIGHT_BLUE#위대한 영웅이 당신의 길을 밝혀주는 것이 느껴집니다!")
		end
	end,
}

newEntity{
	power_source = {nature=true},
	unique = true,
	type = "potion", subtype="potion",
	name = "Blood of Life",
	unided_name = "bloody phial",
	kr_display_name = "생명의 피", kr_unided_name = "핏빛 물약",
	level_range = {1, 50},
	display = '!', color=colors.VIOLET, image="object/artifact/potion_blood_of_life.png",
	encumber = 0.4,
	rarity = 350,
	desc = [[생명의 피입니다! 살아있는 존재가 갑작스럽게 사망할 시, 부활할 수 있게 만들어 줍니다. 하지만 그 기회는 딱 한 번 뿐입니다!]],
	cost = 1000,
	special = true,

	use_simple = { name = "quaff the Blood of Life to grant an extra life", kr_display_name = "생명의 피를 마셔 여분의 생명 획득", use = function(self, who)
		game.logSeen(who, "%s %s 마셨습니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), self:getName():addJosa("를"))
		if not who:attr("undead") then
			who.blood_life = true
			game.logPlayer(who, "#LIGHT_RED#생명의 피가 혈관을 따라 질주하는 것이 느껴집니다.")
		else
			game.logPlayer(who, "생명의 피가 당신에게는 아무런 영향도 주지 않습니다.")
		end
		return {used=true, id=true, destroy=true}
	end},
}

newEntity{ base = "BASE_LONGBOW",
	power_source = {nature=true},
	name = "Thaloren-Tree Longbow", unided_name = "glowing elven-wood longbow", unique=true, image = "object/artifact/thaloren_tree_longbow.png",
	kr_display_name = "탈로레 나무 활", kr_unided_name = "빛나는 엘프나무 활",
	desc = [[마법폭풍의 여파로 인해, 탈로레는 그들의 숲을 적과 불로부터 보호해야 했습니다. 엘프들은 노력했지만, 많은 나무가 죽었습니다. 이제 그들의 나무는 활로 가공되어, 어둠에 맞서기 위한 무기가 되었습니다.]],
	level_range = {40, 50},
	rarity = 200,
	require = { stat = { dex=36 }, },
	cost = 800,
	material_level = 5,
	combat = {
		range = 10,
		physspeed = 0.7,
		apr = 12,
	},
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = 12, },
		lite = 1,
		inc_stats = { [Stats.STAT_DEX] = 5, [Stats.STAT_WIL] = 4,  },
		ranged_project={[DamageType.LIGHT] = 30},
	},
}

newEntity{ base = "BASE_LONGBOW",
	power_source = {arcane=true, nature=true},
	name = "Corpsebow", unided_name = "rotting longbow", unique=true, image = "object/artifact/bow_corpsebow.png",
	kr_display_name = "시체활", kr_unided_name = "썩어가는 활",
	desc = [[황혼의 시대의 잊혀진 유물인 시체활에는, 그 시대에 있었던 끔찍한 전염병의 정수가 들어있습니다. 이 썩어가는 시위에서 쏘아진 화살에 맞으면, 그 대상은 고대의 질병으로 고통받게 됩니다.]],
	level_range = {10, 20},
	rarity = 200,
	require = { stat = { dex=16 }, },
	cost = 50,
	material_level = 2,
	combat = {
		range = 7,
		physspeed = 0.8,
	},
	wielder = {
		disease_immune = 0.5,
		ranged_project = {[DamageType.CORRUPTED_BLOOD] = 15},
		inc_damage={ [DamageType.BLIGHT] = 10, },
		talent_cd_reduction={
			[Talents.T_CYST_BURST] = 2,
		},
	},
}

newEntity{ base = "BASE_SLING",
	power_source = {technique=true},
	unique = true,
	name = "Eldoral Last Resort", image = "object/artifact/sling_eldoral_last_resort.png",
	unided_name = "well-made sling",
	kr_display_name = "엘도랄에서의 마지막 휴양", kr_unided_name = "잘 만들어진 투석구",
	desc = [[손잡이에 다음 문장이 각인된 투석구입니다. '어둠에 맞서 싸우는 자에게, 교활함이 있으라.']],
	level_range = {15, 25},
	rarity = 200,
	require = { stat = { dex=26 }, },
	cost = 350,
	material_level = 3,
	combat = {
		range = 10,
		physspeed = 0.7,
	},
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 4, [Stats.STAT_CUN] = 3,  },
		inc_damage={ [DamageType.PHYSICAL] = 15 },
		talent_cd_reduction={[Talents.T_STEADY_SHOT]=1, [Talents.T_EYE_SHOT]=2},
	},
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Spellblade", image = "object/artifact/weapon_spellblade.png",
	unided_name = "glowing long sword",
	kr_display_name = "마법칼날", kr_unided_name = "빛나는 장검",
	level_range = {40, 45},
	color=colors.AQUAMARINE,
	rarity = 250,
	desc = [[마법사들은 가끔 재미있는 생각을 떠올립니다. 마도사 바릴은 한때 검을 다루는 법을 배워, 지팡이 대신 즐겨 사용했었습니다.]],
	on_id_lore = "spellblade",
	cost = 1000,

	require = { stat = { mag=28, str=28, dex=28 }, },
	material_level = 5,
	combat = {
		dam = 50,
		apr = 2,
		physcrit = 5,
		dammod = {str=1},
	},
	wielder = {
		lite = 1,
		combat_spellpower = 20,
		combat_spellcrit = 9,
		inc_damage={
			[DamageType.PHYSICAL] = 18,
			[DamageType.FIRE] = 18,
			[DamageType.LIGHT] = 18,
		},
		inc_stats = { [Stats.STAT_MAG] = 4, [Stats.STAT_STR] = 4, },
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {nature=true, technique=true},
	unique = true,
	name = "Genocide",
	unided_name = "pitch black blade", image = "object/artifact/weapon_sword_genocide.png",
	kr_display_name = "몰살", kr_unided_name = "칠흑같이 새까만 칼날",
	level_range = {25, 35},
	color=colors.GRAY,
	rarity = 300,
	desc = [[토크놀 왕의 장군 파리안은 마지막 희망에서 벌어진 위대한 전투에서, 토크놀 왕 편에 서서 싸웠습니다. 하지만, 전투가 끝나고 고향으로 돌아온 그는 자신의 고향이 오크에 의해 완전히 불타버린 것을 보게 되었고, 이내 광기가 그를 덮쳤습니다. 복수심에 불타오른 그는 스스로 군대를 뛰쳐나와, 경갑과 검 한 자루만을 든 채 길을 나섰습니다. 많은 사람들이 그를 죽었다고 생각했지만, 그는 오크 야영지를 무너뜨렸다는 보고서 한 장으로 그에 대한 논쟁을 종식시켰습니다. 조사 결과, 그곳에 있던 모든 오크들은 무자비하게 난도질된 시체가 되어 있었습니다. 마즈'에이알에서 오크들이 모두 사라질 때까지, 그의 검은 매일 오크 100 마리의 피를 마셨다고 알려져 있습니다. 마지막 오크를 베고 더 이상 오크를 찾을 수 없게 되자, 파리안은 자신의 가슴에 그 칼날을 꽂아넣었습니다. 그가 죽을 때 그의 몸이 경련을 일으켰다고 알려져 있지만, 그가 웃고 있었는지 울고 있었는지는 알려져 있지 않습니다.]],
	cost = 400,
	require = { stat = { str=40, wil=20 }, },
	material_level = 3,
	combat = {
		dam = 42,
		apr = 4,
		physcrit = 18,
		dammod = {str=1.2},
	},
	wielder = {
		stamina_regen = 1,
		life_regen = 0.5,
		inc_stats = { [Stats.STAT_STR] = 7, [Stats.STAT_DEX] = 7 },
		esp = {["humanoid/orc"]=1},
	},
}

newEntity{ base = "BASE_KNIFE",
	power_source = {arcane=true},
	unique = true,
	name = "Unerring Scalpel", image = "object/artifact/unerring_scalpel.png",
	unided_name = "long sharp scalpel",
	kr_display_name = "정확한 수술용 칼", kr_unided_name = "길고 날카로운 수술용 칼",
	desc = [[황혼의 시대에 살았던 공포의 주술사 코르'풀이 사령술을 배우기 시작할 때 사용했다고 알려진, 수술용 칼입니다. 많은 육체가 그 끔찍한 실험의 본의 아닌 희생자가 되었습니다. 살아 있던 몸이건, 죽어 있던 몸이건 간에 말이죠.]],
	level_range = {1, 12},
	rarity = 200,
	require = { stat = { cun=16 }, },
	cost = 80,
	material_level = 1,
	combat = {
		dam = 15,
		apr = 25,
		physcrit = 0,
		dammod = {dex=0.55, str=0.45},
		phasing = 50,
	},
	wielder = {combat_atk=20},
}

newEntity{ base = "BASE_LEATHER_BOOT",
	power_source = {technique=true},
	unique = true,
	name = "Eden's Guile", image = "object/artifact/boots_edens_guile.png",
	unided_name = "pair of yellow boots",
	kr_display_name = "에덴의 꾀", kr_unided_name = "노란색 신발",
	desc = [[문제를 해결하는 최고의 방법은 도망치는 것이라고 생각했던, 추방된 도둑의 신발입니다.]],
	on_id_lore = "eden-guile",
	color = colors.YELLOW,
	level_range = {1, 20},
	rarity = 300,
	cost = 100,
	material_level = 2,
	wielder = {
		combat_armor = 1,
		combat_def = 2,
		fatigue = 2,
		talents_types_mastery = { ["cunning/survival"] = 0.2 },
		inc_stats = { [Stats.STAT_CUN] = 3, },
	},

	max_power = 50, power_regen = 1,
	use_power = { name = "속도 증가", power = 50,
		use = function(self, who)
			who:setEffect(who.EFF_SPEED, 8, {power=0.20 + who:getCun() / 200})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true, technique=true},
	unique = true,
	name = "Fire Dragon Shield", image = "object/artifact/fire_dragon_shield.png",
	unided_name = "dragon shield",
	kr_display_name = "화염 용 방패", kr_unided_name = "용 방패",
	desc = [[이제는 잊혀진 땅, 타르'에이알에 살던 수많은 화염 용의 비늘로 만들어진 방패입니다.]],
	color = colors.LIGHT_RED,
	metallic = false,
	level_range = {27, 35},
	rarity = 300,
	require = { stat = { str=28 }, },
	cost = 350,
	material_level = 4,
	special_combat = {
		dam = 58,
		block = 220,
		physcrit = 4.5,
		dammod = {str=1},
		damtype = DamageType.FIRE,
	},
	wielder = {
		resists={[DamageType.FIRE] = 35},
		on_melee_hit={[DamageType.FIRE] = 17},
		combat_armor = 9,
		combat_def = 16,
		combat_def_ranged = 15,
		fatigue = 20,
		learn_talent = { [Talents.T_BLOCK] = 5, },
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {technique=true},
	unique = true,
	name = "Titanic", image = "object/artifact/shield_titanic.png",
	unided_name = "huge shield",
	kr_display_name = "타이타닉", kr_unided_name = "거대한 방패",
	desc = [[가장 어두운 스트라라이트로 만들어진 방패로, 거대하고 무겁고 아주 단단합니다.]],
	color = colors.GREY,
	level_range = {20, 30},
	rarity = 270,
	require = { stat = { str=37 }, },
	cost = 300,
	material_level = 3,
	special_combat = {
		dam = 48,
		block = 320,
		physcrit = 4.5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 18,
		combat_def = 20,
		combat_def_ranged = 10,
		fatigue = 30,
		combat_armor_hardiness = 20,
		learn_talent = { [Talents.T_BLOCK] = 4, },
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true},
	unique = true,
	name = "Black Mesh", image = "object/artifact/shield_mesh.png",
	unided_name = "pile of tendrils",
	kr_display_name = "검은 덩굴망", kr_unided_name = "덩굴 덩어리",
	desc = [[검은 덩굴을 엮어 만든 망으로, 방패로 사용할 수 있을 것 같습니다. 건드리면 움직이는 것이 눈에 보일 정도이며, 팔에 들러붙어 따뜻하고 검은 덩굴 안쪽으로 팔을 끌어들이려 합니다.]],
	color = colors.BLACK,
	level_range = {15, 30},
	rarity = 270,
	require = { stat = { str=20 }, }, --make str to 20
	cost = 400,
	material_level = 3,
	metallic = false,
	special_combat = {
		dam = resolvers.rngavg(25,35),
		block = resolvers.rngavg(90, 120),
		physcrit = 5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 2,
		combat_def = 8,
		combat_def_ranged = 8,
		fatigue = 12,
		learn_talent = { [Talents.T_BLOCK] = 3, },
		resists = { [DamageType.BLIGHT] = 15, [DamageType.DARKNESS] = 30, },
		stamina_regen = 2,

	},
	on_block = function(self, who, src, type, dam, eff)
		if rng.percent(30) then
			if not src then return end

			src:pull(who.x, who.y, 15)
			game.logSeen(src, "검은 덩굴이 뻗어나가 %s 당겨옵니다!", (src.kr_display_name or src.name):capitalize():addJosa("를"))
			if core.fov.distance(who.x, who.y, src.x, src.y) <= 1 and src:canBe('pin') then
				src:setEffect(src.EFF_CONSTRICTED, 6, {src=who})
			end
		end
	end,
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Rogue Plight", image = "object/artifact/armor_rogue_plight.png",
	unided_name = "blackened leather armour",
	kr_display_name = "도둑의 맹세", kr_unided_name = "검은 가죽 갑옷",
	desc = [[이 갑옷을 입었던 도둑들은, 그 어느 누구도 무능한 모습을 보이지 않았습니다.]],
	level_range = {25, 40},
	rarity = 270,
	cost = 200,
	require = { stat = { str=22 }, },
	material_level = 3,
	wielder = {
		combat_def = 6,
		combat_armor = 7,
		fatigue = 7,
		stun_immune = 0.3,
		combat_physresist = 35,
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_CON] = 4, },
		resists={[DamageType.BLIGHT] = 35},
	},
}

newEntity{
	power_source = {nature=true},
	unique = true,
	type = "misc", subtype="egg",
	unided_name = "dark egg",
	name = "Mummified Egg-sac of Ungolë", image = "object/artifact/mummified_eggsack.png",
	kr_display_name = "운골뢰의 미이라화된 알주머니", kr_unided_name = "어두운 알",
	level_range = {20, 35},
	rarity = 190,
	display = "*", color=colors.DARK_GREY,
	encumber = 2,
	not_in_stores = true,
	desc = [[건드려보면 푸석푸석하게 말라있는 알주머니입니다. 그 안에는 아직도 생명의 그림자가 들어있는 것 같습니다.]],

	carrier = {
		lite = -2,
	},
	max_power = 100, power_regen = 1,
	use_power = { name = "거미 소환", power = 80, use = function(self, who)
		if not who:canBe("summon") then game.logPlayer(who, "소환 할 수 없습니다. 억압된 상태입니다!") return end

		local NPC = require "mod.class.NPC"
		local list = NPC:loadList("/data/general/npcs/spider.lua")

		for i = 1, 2 do
			-- Find space
			local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			if not x then break end

			local e
			repeat e = rng.tableRemove(list)
			until not e.unique and e.rarity

			local spider = game.zone:finishEntity(game.level, "actor", e)
			spider.make_escort = nil
			spider.silent_levelup = true
			spider.faction = who.faction
			spider.ai = "summoned"
			spider.ai_real = "dumb_talented_simple"
			spider.summoner = who
			spider.summon_time = 10

			local setupSummon = getfenv(who:getTalentFromId(who.T_SPIDER).action).setupSummon
			setupSummon(who, spider, x, y)
			if who:knowTalent(who.T_BLIGHTED_SUMMONING) then spider:learnTalent(spider.T_CORROSIVE_WORM, true, 3) end

			game:playSoundNear(who, "talents/slime")
		end
		return {id=true, used=true}
	end },
}

newEntity{ base = "BASE_HELM",
	power_source = {technique=true},
	unique = true,
	name = "Helm of the Dwarven Emperors", image = "object/artifact/helm_of_the_dwarven_emperors.png",
	unided_name = "shining helm",
	kr_display_name = "드워프 황제의 투구", kr_unided_name = "빛나는 투구",
	desc = [[지하세계의 모든 그림자를 내쫓을 수 있는 다이아몬드가 박힌, 드워프 투구입니다.]],
	level_range = {20, 28},
	rarity = 240,
	cost = 700,
	material_level = 2,
	wielder = {
		lite = 1,
		combat_armor = 6,
		fatigue = 4,
		blind_immune = 0.3,
		confusion_immune = 0.3,
		inc_stats = { [Stats.STAT_WIL] = 3, [Stats.STAT_MAG] = 4, },
		inc_damage={
			[DamageType.LIGHT] = 8,
		},
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_SUN_FLARE, level = 3, power = 30 },
}

newEntity{ base = "BASE_KNIFE",
	power_source = {technique=true},
	unique = true,
	name = "Orc Feller", image = "object/artifact/dagger_orc_feller.png",
	unided_name = "shining dagger",
	kr_display_name = "오크 살해자", kr_unided_name = "빛나는 단검",
	desc = [[엘도랄이 침략당할 때에 하플링 도둑 헤라는 난민들을 보호하면서 백마리가 넘는 오크를 베었다고 알려졌습니다.]],
	level_range = {40, 50},
	rarity = 300,
	require = { stat = { dex=44 }, },
	cost = 550,
	material_level = 5,
	combat = {
		dam = 45,
		apr = 11,
		physcrit = 18,
		dammod = {dex=0.55,str=0.35},
	},
	wielder = {
		lite = 1,
		inc_damage={
			[DamageType.PHYSICAL] = 10,
			[DamageType.LIGHT] = 8,
		},
		pin_immune = 0.5,
		inc_stats = { [Stats.STAT_DEX] = 5, [Stats.STAT_CUN] = 4, },
		esp = {["humanoid/orc"]=1},
	},
}

newEntity{ base = "BASE_KNIFE",
	power_source = {technique=true},
	unique = true,
	name = "Silent Blade", image = "object/artifact/dagger_silent_blade.png",
	unided_name = "shining dagger",
	kr_display_name = "침묵의 칼날", kr_unided_name = "빛나는 단검",
	desc = [[그림자와 하나인것 처럼 얇고 어두운 단검입니다.]],
	level_range = {23, 28},
	rarity = 200,
	require = { stat = { cun=25 }, },
	cost = 250,
	material_level = 2,
	combat = {
		dam = 25,
		apr = 10,
		physcrit = 8,
		dammod = {dex=0.55,str=0.35},
		no_stealth_break = true,
		melee_project={[DamageType.RANDOM_SILENCE] = 10},
	},
	wielder = {combat_atk = 10},
}

newEntity{ base = "BASE_KNIFE", define_as = "ART_PAIR_MOON",
	power_source = {arcane=true},
	unique = true,
	name = "Moon", image = "object/artifact/dagger_moon.png",
	unided_name = "crescent blade",
	kr_display_name = "달", kr_unided_name = "신월도",
	desc = [[달에서 나온 재료로 만들었다는 전설이 있는 섬뜩하게 휜 칼날입니다. 주변의 빛을 삼키면, 투명해집니다.]],
	level_range = {20, 30},
	rarity = 200,
	require = { stat = { dex=24, cun=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 30,
		apr = 30,
		physcrit = 10,
		dammod = {dex=0.45,str=0.45},
		melee_project={[DamageType.DARKNESS] = 20},
	},
	wielder = {
		lite = -1,
		inc_damage={
			[DamageType.DARKNESS] = 10,
		},
	},
	set_list = { {"define_as","ART_PAIR_STAR"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","lite"}, 1)
		self:specialSetAdd({"combat","melee_project"}, {[engine.DamageType.RANDOM_CONFUSION]=10})
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.DARKNESS]=10})
		game.logSeen(who, "#ANTIQUE_WHITE#두자루의 칼이 근접하자 둘 모두 밝게 빛나기 시작합니다.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#ANTIQUE_WHITE#두자루 칼의 빛이 희미해집니다.")
	end,
}

newEntity{ base = "BASE_KNIFE", define_as = "ART_PAIR_STAR",
	power_source = {arcane=true},
	unique = true,
	name = "Star",
	unided_name = "jagged blade", image = "object/artifact/dagger_star.png",
	kr_display_name = "별", kr_unided_name = "톱니칼",
	desc = [[전설에 따르면, 별과 같이 밝게 빛난다고 합니다. 하늘에서 떨어진 것을 연마하여 만들었다고 하며, 빛이 납니다.]],
	level_range = {20, 30},
	rarity = 200,
	require = { stat = { dex=24, cun=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 25,
		apr = 20,
		physcrit = 20,
		dammod = {dex=0.45,str=0.45},
		melee_project={[DamageType.LIGHT] = 20},
	},
	wielder = {
		lite = 1,
		inc_damage={
			[DamageType.LIGHT] = 10,
		},
	},
	set_list = { {"define_as","ART_PAIR_MOON"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","lite"}, 1)
		self:specialSetAdd({"combat","melee_project"}, {[engine.DamageType.RANDOM_BLIND]=10})
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.LIGHT]=10})
	end,

}

newEntity{ base = "BASE_RING",
	power_source = {technique=true},
	unique = true,
	name = "Ring of the War Master", color = colors.DARK_GREY, image = "object/artifact/ring_of_war_master.png",
	unided_name = "blade-edged ring",
	kr_display_name = "전투 명인의 반지", kr_unided_name = "날선 반지",
	desc = [[힘을 내뿜고 날이 서있는 반지입니다. 손가락에 끼면, 마음 속으로 고통과 파괴에 대한 이상한 생각이 밀려옵니다.]],
	level_range = {40, 50},
	rarity = 200,
	cost = 500,
	material_level = 5,

	wielder = {
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_DEX] = 3, [Stats.STAT_CON] = 3, },
		talents_types_mastery = {
			["technique/2hweapon-cripple"] = 0.3,
			["technique/2hweapon-offense"] = 0.3,
			["technique/archery-bow"] = 0.3,
			["technique/archery-sling"] = 0.3,
			["technique/archery-training"] = 0.3,
			["technique/archery-utility"] = 0.3,
			["technique/combat-techniques-active"] = 0.3,
			["technique/combat-techniques-passive"] = 0.3,
			["technique/combat-training"] = 0.3,
			["technique/dualweapon-attack"] = 0.3,
			["technique/dualweapon-training"] = 0.3,
			["technique/shield-defense"] = 0.3,
			["technique/shield-offense"] = 0.3,
			["technique/warcries"] = 0.3,
			["technique/superiority"] = 0.3,
			["technique/thuggery"] = 0.3,
		},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {technique=true, arcane=true},
	unique = true,
	name = "Voratun Hammer of the Deep Bellow", color = colors.LIGHT_RED, image = "object/artifact/voratun_hammer_of_the_deep_bellow.png",
	unided_name = "flame scorched voratun hammer",
	kr_display_name = "깊은 울림의 보라툰 망치", kr_unided_name = "불꽃붙은 보라툰 망치",
	desc = [[드워프 대장장이의 대가가 만든 전설적인 망치입니다. 오랜 세월동안 불타는 열기 속에서 강력한 무기를 만드는데 사용되었고, 마침내 강력한 힘을 가진 물건이 되었습니다.]],
	level_range = {38, 50},
	rarity = 250,
	require = { stat = { str=48 }, },
	cost = 650,
	material_level = 5,
	combat = {
		dam = 82,
		apr = 7,
		physcrit = 4,
		dammod = {str=1.2},
		talent_on_hit = { [Talents.T_FLAMESHOCK] = {level=3, chance=10} },
		melee_project={[DamageType.FIRE] = 30},
	},
	wielder = {
		inc_damage={
			[DamageType.PHYSICAL] = 15,
		},
	},
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {technique=true},
	unique = true,
	name = "Unstoppable Mauler", color = colors.UMBER, image = "object/artifact/unstoppable_mauler.png",
	unided_name = "heavy maul",
	kr_display_name = "멈추지않는 망치질", kr_unided_name = "무거운 대형망치",
	desc = [[놀라운 무게를 가진 거대한 대형망치입니다. 이것을 쥐면, 절대 멈추지 않을 듯한 느낌을 받습니다.]],
	level_range = {23, 30},
	rarity = 270,
	require = { stat = { str=40 }, },
	cost = 250,
	material_level = 3,
	combat = {
		dam = 48,
		apr = 15,
		physcrit = 3,
		dammod = {str=1.2},
		talent_on_hit = { [Talents.T_SUNDER_ARMOUR] = {level=3, chance=15} },
	},
	wielder = {
		combat_atk = 20,
		pin_immune = 1,
		knockback_immune = 1,
	},
}

newEntity{ base = "BASE_MACE",
	power_source = {technique=true},
	unique = true,
	name = "Crooked Club", color = colors.GREEN, image = "object/artifact/weapon_crooked_club.png",
	unided_name = "weird club",
	kr_display_name = "구부정한 곤봉", kr_unided_name = "이상한 곤봉",
	desc = [[육중한 무게가 끝쪽으로 쏠린 기묘하게 비틀린 곤봉입니다.]],
	level_range = {12, 20},
	rarity = 192,
	require = { stat = { str=20 }, },
	cost = 250,
	material_level = 2,
	combat = {
		dam = 25,
		apr = 4,
		physcrit = 10,
		dammod = {str=1},
		melee_project={[DamageType.RANDOM_CONFUSION] = 14},
	},
	wielder = {combat_atk=12,},
}

newEntity{ base = "BASE_MACE",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Nature's Vengeance", color = colors.BROWN, image = "object/artifact/mace_natures_vengeance.png",
	unided_name = "thick wooden mace",
	kr_display_name = "자연의 복수", kr_unided_name = "두꺼운 나무 철퇴",
	desc = [[이 두꺼운 철퇴는 마법사냥꾼 보를란이 마법폭풍으로 뽑혀진 고대의 너도밤나무로 만들어 사용하던 것입니다. 많은 마법사와 마녀가 이 무기에 의해 쓰러졌고, 자연에 범한 범죄를 처단하고 정의를 가져오기 위한 도구로 사용되었습니다.]],
	level_range = {20, 34},
	rarity = 340,
	require = { stat = { str=42 } },
	cost = 350,
	material_level = 3,
	combat = {
		dam = 40,
		apr = 4,
		physcrit = 9,
		dammod = {str=1},
		melee_project={[DamageType.RANDOM_SILENCE] = 10, [DamageType.NATURE] = 18},
	},
	wielder = {combat_atk=6},

	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_RUSH, level = 3, power = 15 },
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {nature=true},
	unique = true,
	name = "Spider-Silk Robe of Spydrë", color = colors.DARK_GREEN, image = "object/artifact/robe_spider_silk_robe_spydre.png",
	unided_name = "spider-silk robe",
	kr_display_name = "거미 비단 로브", kr_unided_name = "거미 비단 로브",
	desc = [[이 로브는 완전히 거미 비단으로만 만들어 졌습니다. 기이한 모습을 가졌고, 어떤 현자는 다른 세계에서 아마도 장거리 관문을 통해 온 것이라 말합니다.]],
	level_range = {20, 30},
	rarity = 190,
	cost = 250,
	material_level = 3,
	wielder = {
		combat_def = 10,
		combat_armor = 15,
		combat_armor_hardiness = 40,
		inc_stats = { [Stats.STAT_CON] = 5, [Stats.STAT_WIL] = 4, },
		combat_mindpower = 10,
		combat_mindcrit = 5,
		combat_spellresist = 10,
		combat_physresist = 10,
		inc_damage={[DamageType.NATURE] = 10, [DamageType.MIND] = 10, [DamageType.ACID] = 10},
		resists={[DamageType.NATURE] = 30},
		on_melee_hit={[DamageType.POISON] = 20, [DamageType.SLIME] = 20},
	},
}

newEntity{ base = "BASE_HELM", define_as = "HELM_KROLTAR",
	power_source = {technique=true},
	unique = true,
	name = "Dragon-helm of Kroltar", image = "object/artifact/dragon_helm_of_kroltar.png",
	unided_name = "dragon-helm",
	kr_display_name = "크롤타르의 용투구", kr_unided_name = "용투구",
	desc = [[도드라진 금 장식이 달린 강철 면갑 투구입니다. 가장 위대한 화염 드레이크 크롤타르의 깃장식이 되어 있습니다.]],
	require = { talent = { {Talents.T_ARMOUR_TRAINING,3} }, stat = { str=35 }, },
	level_range = {37, 45},
	rarity = 280,
	cost = 400,
	material_level = 4,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_CON] = 5, [Stats.STAT_LCK] = -4, },
		combat_def = 5,
		combat_armor = 9,
		fatigue = 10,
	},
	max_power = 45, power_regen = 1,
	use_talent = { id = Talents.T_WARSHOUT, level = 2, power = 45 },
	set_list = { {"define_as","SCALE_MAIL_KROLTAR"} },
	on_set_complete = function(self, who)
		self:specialSetAdd("skullcracker_mult", 1)
		self:specialSetAdd({"wielder","combat_spellresist"}, 15)
		self:specialSetAdd({"wielder","combat_mentalresist"}, 15)
		self:specialSetAdd({"wielder","combat_physresist"}, 15)
		game.logPlayer(who, "#GOLD#크롤타르의 투구외 비늘갑옷이 근접하자, 그것들이 향기와 불꽃을 내뿜기 시작합니다.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#GOLD#향기와 불꽃이 사라집니다.")
	end,
}

newEntity{ base = "BASE_HELM",
	power_source = {technique=true},
	unique = true,
	name = "Crown of Command", image = "object/artifact/crown_of_command.png",
	unided_name = "unblemished silver crown",
	kr_display_name = "명령의 왕관", kr_unided_name = "흠이없는 은제 왕관",
	desc = [[황혼의 시대에 나르골 지역을 지배하던 하플링 왕 로우파르가 쓰던 왕관입니다. 그 때는 암흑기였고, 왕이 엄격하게 명령과 징벌을 시행하던 시기였습니다. 다름이 처벌받았고, 이의는 억압되었으며, 많은 이가 흔적도 없이 수많은 감옥으로 사라졌습니다. 모든 것은 왕관 앞에 충성을 바치거나 끔찍히 처벌되었습니다. 그가 후계자를 남기지 못하고 죽었을때, 왕관은 사라졌고 그의 왕국은 혼돈에 빠졌습니다.]],
	require = { stat = { cun=25 } },
	level_range = {20, 35},
	rarity = 280,
	cost = 300,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 3, [Stats.STAT_WIL] = 10, },
		combat_def = 3,
		combat_armor = 6,
		fatigue = 4,
		resists = { [DamageType.PHYSICAL] = 8},
		talents_types_mastery = { ["technique/superiority"] = 0.2, ["technique/field-control"] = 0.2 },
	},
}

newEntity{ base = "BASE_GLOVES",
	power_source = {technique=true},
	unique = true,
	name = "Gloves of the Firm Hand", image = "object/artifact/gloves_of_the_firm_hand.png",
	unided_name = "heavy gloves",
	kr_display_name = "견고한 손의 장갑", kr_unided_name = "단단한 장갑",
	desc = [[이 장갑은 단단히 안정적인 느낌을 줍니다! 이 마법의 장갑 안쪽에서의 촉감은 정말 부드럽습니다. 바깥쪽에는 마법의 암석질이 끊임없이 변화하는 거친 표면을 만듭니다. 이것을 착용하면, 마법적인 대지의 에너지 광선이 자동으로 뻗어나와 땅에 연결됨으로써 안정성을 높여 줍니다.]],
	level_range = {17, 27},
	rarity = 210,
	cost = 150,
	material_level = 3,
	wielder = {
		talent_cd_reduction={[Talents.T_CLINCH]=2},
		inc_stats = { [Stats.STAT_CON] = 4 },
		combat_armor = 8,
		disarm_immune=0.4,
		knockback_immune=0.3,
		combat = {
			dam = 18,
			apr = 1,
			physcrit = 7,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
		},
	},
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Dakhtun's Gauntlets", color = colors.STEEL_BLUE, image = "object/artifact/dakhtuns_gauntlets.png",
	unided_name = "expertly-crafted dwarven-steel gauntlets",
	kr_display_name = "닥흐툰의 전투장갑", kr_unided_name = "명인이만든 드워프강철 전투장갑",
	desc = [[매혹의 시대에 위대한 대장장이 닥흐툰이 만든 것으로, 이 드워프강철 전투장갑에는 홤금의 마법 룬이 새겨져 있고, 착용자에게 전대미문의 물리적 힘과 마법적 힘을 부여한다고 알려져 있습니다.]],
	level_range = {40, 50},
	rarity = 300,
	cost = 2000,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 6, [Stats.STAT_MAG] = 6 },
		inc_damage = { [DamageType.PHYSICAL] = 10 },
		combat_physcrit = 10,
		combat_spellcrit = 10,
		combat_critical_power = 50,
		combat_armor = 6,
		combat = {
			dam = 35,
			apr = 10,
			physcrit = 10,
			physspeed = 0.2,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={[DamageType.ARCANE] = 20},
			damrange = 0.3,
		},
	},
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {psionic=true, technique=true},
	define_as = "GAUNTLETS_SCORPION",
	unique = true,
	name = "Fists of the Desert Scorpion", color = colors.STEEL_BLUE, image = "object/artifact/scorpion_gauntlets.png",
	unided_name = "viciously spiked gauntlets",
	kr_display_name = "사막 전갈의 주먹", kr_unided_name = "심술궂은 가시돋은 전투장갑",
	desc = [[이 사악하게 가시돋은 전투장갑은 장작더미의 시대에 서쪽 모래밭을 정복하고, 그곳을 기지삼아 남쪽의 엘발라로 대공세를 펼치던 오크 장군이 사용한 물건입니다. 전갈이란 별명으로 알려진 그를 전장에서는 아무도 억제할 수 없었습니다. 그는 지독한 정신력으로 적들을 근방으로 끌어당길 수 있었고, 치명적인 공격으로 그들을 쓰러뜨렸습니다. 이 노랗고 검은 전투장갑의 질풍은 종종 위대한 샬로레 마법사들이 마지막으로 죽기전에 마지막으로 본 것이 되었습니다.

전갈을 쓰러뜨리기 위해, 연금술사 네씰리아가 극악무도한 오크들에게 홀로 대적하러 나왔습니다. 장군은 엘프를 무자비하게 잡아 당겼지만, 그가 육신으로부터 생명을 망가뜨리기 전에 그녀는 스스로 로브를 찢었고, 그 안에 있던 몸에 묶인 80개의 소이탄이 드러났습니다. 그녀는 손가락에서 불꽃을 만들어 폭발을 유도했고, 이 폭발은 수키로 밖에서도 보일정도로 컸다고 합니다. 사람들을 보호하기 위한 네씰리아의 희생은 지금도 노래로 남아 기억되고 있습니다.]],
	level_range = {20, 40},
	rarity = 300,
	cost = 1000,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_WIL] = 3, [Stats.STAT_CUN] = 3, },
		inc_damage = { [DamageType.PHYSICAL] = 8 },
		combat_mindpower=3,
		combat_armor = 4,
		combat_def = 8,
		disarm_immune = 0.4,
		talents_types_mastery = { ["psionic/grip"] = 0.2, ["technique/grappling"] = 0.2},
		combat = {
			dam = 24,
			apr = 10,
			physcrit = 10,
			physspeed = 0.15,
			dammod = {dex=0.4, str=-0.6, cun=0.4,},
			damrange = 0.3,
			talent_on_hit = { [Talents.T_BITE_POISON] = {level=3, chance=20} },
		},
	},
	max_power = 24, power_regen = 1,
	use_talent = { id = Talents.T_MINDHOOK, level = 4, power = 16 },
}

newEntity{ base = "BASE_GLOVES",
	power_source = {nature=true}, define_as = "SET_GIANT_WRAPS",
	unique = true,
	name = "Snow Giant Wraps", color = colors.SANDY_BROWN, image = "object/artifact/snow_giant_arm_wraps.png",
	unided_name = "fur-lined leather wraps",
	kr_display_name = "설원 거인 감싸개", kr_unided_name = "털안감처리된 가죽 감싸개",
	desc = [[두개의 커다란 가죽 뭉치는 손에 팔뚝까지를 칭칭 감싸기 위해 만들어진 것입니다. 이 특별한 감싸개에는 착용자에게 커다란 힘을 주는 기능이 부여되어 있습니다.]],
	level_range = {15, 25},
	rarity = 200,
	cost = 500,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 4, },
		resists = { [DamageType.COLD]= 10, [DamageType.LIGHTNING] = 10, },
		knockback_immune = 0.5,
		combat_armor = 2,
		max_life = 60,
		combat = {
			dam = 16,
			apr = 1,
			physcrit = 4,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={ [DamageType.COLD] = 10, [DamageType.LIGHTNING] = 10, },
		},
	},
	max_power = 6, power_regen = 1,
	use_talent = { id = Talents.T_THROW_BOULDER, level = 2, power = 6 },

	set_list = { {"define_as", "SET_MIGHTY_GIRDLE"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","combat_dam"}, 10)
		self:specialSetAdd({"wielder","combat_physresist"}, 10)
	end,
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {technique=true}, define_as = "SET_MIGHTY_GIRDLE",
	unique = true,
	name = "Mighty Girdle", image = "object/artifact/belt_mighty_girdle.png",
	unided_name = "massive, stained girdle",
	kr_display_name = "강력한 거들", kr_unided_name = "얼룩진 무거운 거들",
	desc = [[이 거들은 뱃살이 찌는 것에 대한 강력한 보호기능이 붙어 있습니다. 이 환상적인 힘의 원천이 무엇이든, 다루기 힘든 짐을 옮기는데 커다란 도움이 됩니다.]],
	color = colors.LIGHT_RED,
	level_range = {1, 25},
	rarity = 170,
	cost = 350,
	material_level = 2,
	wielder = {
		knockback_immune = 0.4,
		max_encumber = 70,
		combat_armor = 4,
	},

	set_list = { {"define_as", "SET_GIANT_WRAPS"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","max_life"}, 100)
		self:specialSetAdd({"wielder","size_category"}, 2)
		game.logPlayer(who, "#GOLD#당신의 크기가 아주 커졌습니다!")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#LIGHT_BLUE#당신이 작아지는 것을 느낍니다...")
	end,
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {arcane=true},
	unique = true,
	name = "Storm Bringer's Gauntlets", color = colors.LIGHT_STEEL_BLUE, image = "object/artifact/storm_bringers_gauntlets.png",
	unided_name = "fine-mesh gauntlets",
	kr_display_name = "폭풍 소환자의 전투장갑", kr_unided_name = "잘 맞물린 전투장갑",
	desc = [[이 잘 맞물린 보라툰 전투장갑은 창공의 에너지를 발하는 힘의 문양으로 덮혀져 있습니다. 이 금속은 유연하고 가벼워 주문을 시전하는데 방해되지 않습니다. 이 전투장갑이 연마된 시기와 장소는 알려지지 않았지만, 마법에 대해 어느 정도 지식이 있는 특이한 장인이 만든 것으로 짐작됩니다.]],
	level_range = {25, 35},
	rarity = 250,
	cost = 1000,
	material_level = 3,
	require = nil,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 4, },
		resists = { [DamageType.LIGHTNING] = 15, },
		inc_damage = { [DamageType.LIGHTNING] = 10 },
		resists_cap = { [DamageType.LIGHTNING] = 5 },
		combat_spellcrit = 5,
		combat_critical_power = 20,
		combat_armor = 3,
		combat = {
			dam = 22,
			apr = 10,
			physcrit = 4,
			physspeed = 0.2,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			melee_project={ [DamageType.LIGHTNING] = 20, },
			talent_on_hit = { [Talents.T_LIGHTNING] = {level=3, chance=10} },
			damrange = 0.3,
		},
	},
	max_power = 16, power_regen = 1,
	use_talent = { id = Talents.T_CHAIN_LIGHTNING, level = 3, power = 16 },
}

newEntity{ base = "BASE_CLOAK",
	power_source = {nature=true},
	unique = true,
	name = "Serpentine Cloak", image = "object/artifact/serpentine_cloak.png",
	unided_name = "tattered cloak",
	kr_display_name = "뱀같은 망토", kr_unided_name = "누더기 망토",
	desc = [[교활함과 원한이 이 망토에서 퍼져 나옵니다.]],
	level_range = {20, 29},
	rarity = 240,
	cost = 200,
	material_level = 3,
	wielder = {
		combat_def = 10,
		inc_stats = { [Stats.STAT_CUN] = 6, [Stats.STAT_CON] = 5, },
		resists_pen = { [DamageType.NATURE] = 15 },
		talents_types_mastery = { ["cunning/stealth"] = 0.1, },
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_PHASE_DOOR, level = 2, power = 30 },
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Wind's Whisper", image="object/artifact/cloak_winds_whisper.png",
	unided_name = "flowing light cloak",
	kr_display_name = "바람의 속삭임", kr_unided_name = "하늘거리는 가벼운 망토",
	desc = [[부여술사 라젠이 마법사냥꾼들에게 쫓겨 다이카라 산맥 부근으로 몰렸을 때, 그녀는 가지고 있던 망토를 두르고 좁은 협곡 아래로 도망쳤습니다. 사냥꾼들은 그 뒤에서 화살을 일제히 쏘았지만, 기적같이 모두 빗나갔습니다. 이렇게 라젠은 탈출에 성공했고, 서쪽의 숨겨진 도시로 도망쳤습니다.]],
	level_range = {15, 25},
	rarity = 400,
	cost = 250,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 3, },
		combat_def = 4,
		combat_ranged_def = 12,
		silence_immune = 0.3,
		projectile_evasion = 25,
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_EVASION, level = 2, power = 50 },
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Vestments of the Conclave", color = colors.DARK_GREY, image = "object/artifact/robe_vestments_of_the_conclave.png",
	unided_name = "tattered robe",
	kr_display_name = "은둔자의 예복", kr_unided_name = "누더기 로브",
	desc = [[매혹의 시대에 살아남은 고대의 로브입니다. 근원적 마법의 힘이 그 속에 들어 있습니다.
인간이 인간을 위해 만든것으로, 인간만이 로브의 진정한 힘을 사용할 수 있습니다.]],
	level_range = {12, 22},
	rarity = 220,
	cost = 150,
	material_level = 2,
	wielder = {
		inc_damage = {[DamageType.ARCANE]=10},
		inc_stats = { [Stats.STAT_MAG] = 6 },
		combat_spellcrit = 15,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Human" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_MAG] = 3, [Stats.STAT_CUN] = 9, })
			self:specialWearAdd({"wielder","inc_damage"}, {[DamageType.ARCANE]=7})
			self:specialWearAdd({"wielder","combat_spellcrit"}, 2)
			game.logPlayer(who, "#LIGHT_BLUE#오래된 인간 은둔자의 예복을 입자 힘이 밀려 들어오는 것을 느낍니다!")
		end
	end,
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Firewalker", color = colors.RED, image = "object/artifact/robe_firewalker.png",
	unided_name = "blazing robe",
	kr_display_name = "불속을 걷는자", kr_unided_name = "불타는 로브",
	desc = [[이 불붙은 로브는 미친 화염술사 할콧이 입던 것입니다. 황혼의 시대 말기에 그는 많은 도시를 위협했고, 마법폭풍으로부터 회복하려 노력하는 마을 사람들을 불태우고 약탈했습니다. 결국 그는 지구르 추종자들에 의해서 잡혀, 먼저 혀를 잘리고, 머리도 잘린다음, 온 몸이 잘기잘기 찢겼습니다. 그 머리는 얼음덩이 속에 넣어, 주변 마을들을 순회하며 지역주민들의 환호 속에서 행진을 벌였습니다. 단지 그 로브만이 할콧의 불꽃을 간직한 채로 남았습니다.]],
	level_range = {20, 30},
	rarity = 300,
	cost = 280,
	material_level = 3,
	wielder = {
		inc_damage = {[DamageType.FIRE]=20},
		combat_def = 8,
		combat_armor = 2,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_CUN] = 6, },
		resists = {[DamageType.FIRE] = 20, [DamageType.COLD] = -10},
		resists_pen = { [DamageType.FIRE] = 20 },
		on_melee_hit = {[DamageType.FIRE] = 18},
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Robe of the Archmage", color = colors.RED, image = "object/artifact/robe_of_the_archmage.png",
	unided_name = "glittering robe",
	kr_display_name = "마도사의 로브", kr_unided_name = "반짝거리는 로브",
	desc = [[평범한 엘프비단 로브입니다. 순수한 힘을 내뿜는 것만 아니면 정말 평범합니다.]],
	level_range = {30, 40},
	rarity = 290,
	cost = 550,
	material_level = 4,
	moddable_tile = "special/robe_of_the_archmage",
	moddable_tile_big = true,
	wielder = {
		lite = 1,
		inc_damage = {all=12},
		blind_immune = 0.4,
		combat_def = 10,
		combat_armor = 10,
		inc_stats = { [Stats.STAT_MAG] = 4, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 4, },
		combat_spellpower = 15,
		combat_spellresist = 18,
		combat_mentalresist = 15,
		resists={[DamageType.FIRE] = 10, [DamageType.COLD] = 10},
		on_melee_hit={[DamageType.ARCANE] = 15},
		mana_regen = 1,
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Temporal Augmentation Robe - Designed In-Style", color = colors.BLACK, image = "object/artifact/robe_temporal_augmentation_robe.png",
	unided_name = "stylish robe with a scarf",
	kr_display_name = "유행하는 모양의 시간증대 로브", kr_unided_name = "스카프 달린 멋진 로브",
	desc = [[조금 기발한 괴리 마법사가 설계한 것으로, 이 로브는 언제나 발견되는 때의 유행하는 모양으로 나타납니다. 많은 모험가들이 괴리 마법사의 제작을 도와 만들어진 이 로브는 시간이란 것이 얼마나 변덕스럽게 제멋대로인지를 이해하는데 커다란 도움이 됩니다. 신기하게도, 그 네번째 소유자가 속한 전쟁이 아주 장기화되자, 이 로브에는 아주 길고 무지개빛을 가진 스카프가 달렸습니다.]],
	level_range = {30, 40},
	rarity = 310,
	cost = 540,
	material_level = 4,
	wielder = {
		combat_spellpower = 23,
		inc_damage = {[DamageType.TEMPORAL]=20},
		combat_def = 9,
		combat_armor = 3,
		inc_stats = { [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 3, },
		resists={[DamageType.TEMPORAL] = 20},
		resists_pen = { [DamageType.TEMPORAL] = 20 },
		on_melee_hit={[DamageType.TEMPORAL] = 10},
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_DAMAGE_SMEARING, level = 3, power = 25 },
}

newEntity{ base = "BASE_GEM", define_as = "GEM_TELOS",
	power_source = {arcane=true},
	unique = true,
	unided_name = "scintillating white crystal",
	name = "Telos's Staff Crystal", subtype = "multi-hued", image = "object/artifact/telos_staff_crystal.png",
	kr_display_name = "텔로스 지팡이의 수정", kr_unided_name = "번뜩이는 흰 수정",
	color = colors.WHITE,
	level_range = {35, 45},
	desc = [[이 순수한 흰색 수정을 가까이서 보면, 그 속에서 오만가지의 색깔들의 소용돌이와 번뜩임을 발견할 수 있습니다.]],
	rarity = 240,
	identified = false,
	cost = 200,
	material_level = 5,
	carrier = {
		lite = 2,
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, [Stats.STAT_CON] = 5, },
		lite = 2,
		confusion_immune = 0.3,
		fear_immune = 0.3,
		resists={[DamageType.MIND] = 30,},
	},
	imbue_powers = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, [Stats.STAT_CON] = 5, },
		lite = 2,
		confusion_immune = 0.3,
		fear_immune = 0.3,
		resists={[DamageType.MIND] = 30,},
	},

	max_power = 1, power_regen = 1,
	use_power = { name = "지팡이와 결합", power = 1, use = function(self, who, gem_inven, gem_item)
		who:showInventory("어느 지팡이에 붙입니까?", who:getInven("INVEN"), function(o) return o.type == "weapon" and o.subtype == "staff" and not o.egoed and not o.unique end, function(o, item)
			local voice = game.zone:makeEntityByName(game.level, "object", "VOICE_TELOS")
			if voice then
				local oldname = o:getName{do_color=true}

				-- Remove the gem
				who:removeObject(gem_inven, gem_item)
				who:sortInven(gem_inven)

				-- Change the staff
				voice.modes = o.modes
				voice.flavor_name = o.flavor_name
				voice.combat = o.combat
				voice.combat.dam = math.floor(voice.combat.dam * 1.4)
				voice.combat.sentient = "telos"
				voice.wielder.inc_damage[voice.combat.damtype] = voice.combat.dam
				voice:identify(true)
				o:replaceWith(voice)
				who:sortInven()

				who.changed = true
				game.logPlayer(who, "수정을 %s에 고정시켜 %s 만들었습니다", oldname, o:getName{do_color=true}:addJosa("를"))
			else
				game.logPlayer(who, "결합이 실패했습니다!")
			end
		end)
		return {id=true, used=true}
	end },
}

-- The staff that goes with the crystal above, it will not be generated randomly it is created by the crystal
newEntity{ base = "BASE_STAFF", define_as = "VOICE_TELOS",
	power_source = {arcane=true},
	unique = true,
	name = "Voice of Telos",
	unided_name = "scintillating white staff", image="object/artifact/staff_voice_of_telos.png",
	kr_display_name = "텔로스의 목소리", kr_unided_name = "번뜩이는 흰 지팡이",
	color = colors.VIOLET,
	rarity = false,
	desc = [[이 순수한 흰색 지팡이를 가까이서 보면, 그 속에서 오만가지의 색깔들의 소용돌이와 번뜩임을 발견할 수 있습니다.]],
	cost = 500,
	material_level = 5,

	require = { stat = { mag=45 }, },
	-- This is replaced by the creation process
	combat = { dam = 1, damtype = DamageType.ARCANE, },
	wielder = {
		combat_spellpower = 30,
		combat_spellcrit = 15,
		max_mana = 100,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 4 },
		lite = 1,
		inc_damage = {},
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1},
	},
}

newEntity{ base = "BASE_ROD",
	power_source = {arcane=true},
	unided_name = "glowing rod",
	name = "Gwai's Burninator", color=colors.LIGHT_RED, unique=true, image = "object/artifact/wand_gwais_burninator.png",
	kr_display_name = "과이의 불태우미", kr_unided_name = "달아오른 장대",
	desc = [[화염술사 과이는 마법사냥 시절에 살았고, 마법사냥꾼 무리에게 쫓겼습니다. 그녀는 싸우기 위해 마지막 숨을 내쉬었고, 그녀가 쓰러지기 전에 이 장대를 사용하여 열 사람이 넘는 목숨을 가져갔다고 알려졌습니다.]],
	cost = 600,
	rarity = 220,
	level_range = {25, 35},
	elec_proof = true,
	add_name = false,

	material_level = 3,

	max_power = 75, power_regen = 1,
	use_power = { name = "화염을 원뿔영역으로 발사", power = 50,
		use = function(self, who)
			local tg = {type="cone", range=0, radius=5}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, engine.DamageType.FIRE, 300 + who:getMag() * 2, {type="flame"})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {technique=true},
	unique = true,
	unided_name = "crude iron battle axe",
	name = "Crude Iron Battle Axe of Kroll", color = colors.GREY, image = "object/artifact/crude_iron_battleaxe_of_kroll.png",
	kr_display_name = "크롤의 조잡한 무쇠 대형도끼", kr_unided_name = "조잡한 무쇠 대형도끼",
	desc = [[드워프가 아름다운 손재주를 배우기 이전의 시절에 만든, 거친 모습의 이 도끼는 거대한 힘을 숨기고 있습니다. 드워프만이 그 진정한 힘을 사용할 수 있습니다.]],
	require = { stat = { str=50 }, },
	level_range = {39, 46},
	rarity = 300,
	material_level = 4,
	combat = {
		dam = 68,
		apr = 7,
		physcrit = 10,
		dammod = {str=1.3},
	},
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 2, [Stats.STAT_DEX] = 2, },
		combat_def = 6, combat_armor = 6,
		inc_damage = { [DamageType.PHYSICAL]=10 },
		stun_immune = 0.3,
		knockback_immune = 0.3,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Dwarf" then
			local Stats = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_CON] = 7, [Stats.STAT_DEX] = 7, })
			self:specialWearAdd({"wielder","stun_immune"}, 0.7)
			self:specialWearAdd({"wielder","knockback_immune"}, 0.7)
			game.logPlayer(who, "#LIGHT_BLUE#도끼를 쥐자 조상으로부터 이어진 힘이 밀려오는 것을 느낍니다!")
		end
	end,
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {technique=true},
	unique = true,
	unided_name = "viciously sharp battle axe",
	name = "Drake's Bane", image = "object/artifact/axe_drakes_bane.png",
	kr_display_name = "드레이크의 파멸", kr_unided_name = "심술궃게 날카로운 대형도끼",
	color = colors.RED,
	desc = [[가장 강력한 용 크롤타르를 죽이는 데에는 일곱달의 시간과 20,000이 넘는 드워프 전사의 생명이 필요했습니다. 마침내 짐승이 피곤을 느끼자, 동료들의 시체로 쌓은 탑위에 선 상급대장장이 그룩심이 용의 껍질을 뚫기위해 만든 이 도끼로 그 목에 틈을 만들 수 있었습니다.]],
	require = { stat = { str=45 }, },
	rarity = 300,
	cost = 400,
	level_range = {20, 35},
	material_level = 3,
	combat = {
		dam = 52,
		apr = 21,
		physcrit = 2,
		dammod = {str=1.2},
		inc_damage_type = {dragon=25},
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 6, },
		stun_immune = 0.2,
		knockback_immune = 0.4,
		combat_physresist = 9,
	},
}

newEntity{ base = "BASE_WARAXE",
	power_source = {technique=true, nature=true},
	unique = true,
	name = "Blood-Letter", image = "object/artifact/weapon_axe_blood_letter.png",
	unided_name = "glacial hatchet",
	kr_display_name = "피의 찍개", kr_unided_name = "빙하의 손도끼",
	desc = [[북쪽 황무지의 얼어붙은 부분을 깍아 만든 손도끼입니다.]],
	level_range = {25, 35},
	rarity = 235,
	require = { stat = { str=40, dex=24 }, },
	cost = 330,
	material_level = 3,
	wielder = {
		combat_armor = 20,
		resists_pen = {
			[DamageType.COLD] = 20,
		},
	},
	combat = {
		dam = 33,
		apr = 4.5,
		physcrit = 7,
		dammod = {str=1},
		convert_damage = {
			[DamageType.ICE] = 50,
		},
	},
	talent_on_hit = { [Talents.T_ICE_BREATH] = {level=2, chance=15} },
}


newEntity{ base = "BASE_WHIP",
	power_source = {nature=true},
	unided_name = "metal whip",
	name = "Scorpion's Tail", color=colors.GREEN, unique = true, image = "object/artifact/whip_scorpions_tail.png",
	kr_display_name = "전갈의 꼬리", kr_unided_name = "금속 채찍",
	desc = [[금속편들이 연결된 기다란 채찍입니다. 그 끝에는 맹독이 새어나오는 심술궂게 날카로운 가시가 달려 있습니다.]],
	require = { stat = { dex=28 }, },
	cost = 150,
	rarity = 340,
	level_range = {20, 30},
	material_level = 3,
	combat = {
		dam = 28,
		apr = 8,
		physcrit = 5,
		dammod = {dex=1},
		melee_project={[DamageType.POISON] = 22, [DamageType.BLEED] = 22},
		talent_on_hit = { T_DISARM = {level=3, chance=10} },
	},
	wielder = {
		combat_atk = 10,
		see_invisible = 9,
		see_stealth = 9,
	},
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {nature=true},
	unique = true,
	name = "Rope Belt of the Thaloren", image = "object/artifact/rope_belt_of_the_thaloren.png",
	unided_name = "short length of rope",
	kr_display_name = "탈로레의 밧줄 허리띠", kr_unided_name = "짧은 길이의 밧줄",
	desc = [[네씰라 탄타엘렌이 여러 세기 동안 주민들과 숲을 돌보면서 걸치고 있던 가장 단순한 허리띠입니다. 그녀가 가진 지혜와 힘의 일부가 이것에 스며들어 영구히 자리잡고 있습니다.]],
	color = colors.LIGHT_RED,
	level_range = {20, 30},
	rarity = 200,
	cost = 450,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 7, [Stats.STAT_WIL] = 8, },
		combat_mindpower = 12,
		talents_types_mastery = { ["wild-gift/harmony"] = 0.2 },
	},
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {arcane=true},
	unique = true,
	name = "Neira's Memory", image = "object/artifact/neira_memory.png",
	unided_name = "crackling belt",
	kr_display_name = "네이라의 기억", kr_unided_name = "파직거리는 허리띠",
	desc = [[오래전에 리나니일이 아직 어릴적에 착용하던 허리띠로, 마법폭풍으로 화염의 비가 내릴때 그녀를 보호한 힘이 들어 있습니다. 하지만 그녀는 자매 네이라에 대해서는 아무것도 할 수가 없었습니다.]],
	color = colors.GOLD,
	level_range = {20, 30},
	rarity = 200,
	cost = 450,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 2, [Stats.STAT_WIL] = 5, },
		confusion_immune = 0.3,
		stun_immune = 0.3,
		mana_on_crit = 3,
	},
	max_power = 20, power_regen = 1,
	use_power = { name = "개인 보호막 발동", power = 20,
		use = function(self, who)
			who:setEffect(who.EFF_DAMAGE_SHIELD, 10, {power=100 + who:getMag(250)})
			game:playSoundNear(who, "talents/arcane")
			game.logSeen(who, "%s 네이라의 기억을 사용했습니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"))
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {nature=true},
	unique = true,
	name = "Girdle of Preservation", image = "object/artifact/belt_girdle_of_preservation.png",
	unided_name = "shimmering, flawless belt",
	kr_display_name = "보존의 거들", kr_unided_name = "어른거리는 흠없는 허리띠",
	desc = [[룬이 박힌 보라툰 죔쇠가 달린 가장 순수한 흰 가죽의 원시시대 허리띠입니다. 시간이나 환경적인 손상이 전혀 없습니다.]],
	color = colors.WHITE,
	level_range = {45, 50},
	rarity = 400,
	cost = 750,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 5, [Stats.STAT_WIL] = 5,  },
		resists = {
			[DamageType.ACID] = 15,
			[DamageType.LIGHTNING] = 15,
			[DamageType.FIRE] = 15,
			[DamageType.COLD] = 15,
			[DamageType.LIGHT] = 15,
			[DamageType.DARKNESS] = 15,
			[DamageType.BLIGHT] = 15,
			[DamageType.TEMPORAL] = 15,
			[DamageType.NATURE] = 15,
			[DamageType.PHYSICAL] = 10,
			[DamageType.ARCANE] = 10,
		},
		confusion_immune = 0.2,
		combat_physresist = 15,
		combat_mentalresist = 15,
		combat_spellresist = 15,
	},
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {nature=true},
	unique = true,
	name = "Girdle of the Calm Waters", image = "object/artifact/girdle_of_the_calm_waters.png",
	unided_name = "golden belt",
	kr_display_name = "차분한 물의 거들", kr_unided_name = "금빛 허리띠",
	desc = [[은둔자 치료사가 사용하던 것이라는 소문이 있는 허리띠입니다.]],
	color = colors.GOLD,
	level_range = {5, 14},
	rarity = 120,
	cost = 75,
	material_level = 1,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 3,  },
		resists = {
			[DamageType.COLD] = 20,
			[DamageType.BLIGHT] = 20,
			[DamageType.NATURE] = 20,
		},
		healing_factor = 0.3,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Behemoth Hide", image = "object/artifact/behemoth_skin.png",
	unided_name = "tough weathered hide",
	kr_display_name = "베헤모스 가죽", kr_unided_name = "거친 풍화된 가죽",
	desc = [[거대한 짐승에게서 떼어낸 거친 가죽입니다. 좀 낡아 보이지만, 아직 쓸만하고 약간은 특별합니다...]],
	color = colors.BROWN,
	level_range = {18, 23},
	rarity = 230,
	require = { stat = { str=22 }, },
	cost = 250,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 2, [Stats.STAT_CON] = 2 },

		combat_armor = 6,
		combat_def = 4,
		combat_def_ranged = 8,

		max_encumber = 20,
		life_regen = 0.7,
		stamina_regen = 0.7,
		fatigue = 10,
		max_stamina = 43,
		max_life = 45,
		knockback_immune = 0.1,
		size_category = 1,
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Skin of Many", image = "object/artifact/robe_skin_of_many.png",
	unided_name = "stitched skin armour",
	kr_display_name = "여러가지의 가죽", kr_unided_name = "꿰맨 가죽 갑옷",
	desc = [[많은 생명체의 가죽을 하나로 꿰매어 만든 것입니다. 몇몇 눈과 입이 그대로 달려 있고, 그 중 일부는 여전히 살아있어 고통의 몸부림으로 비명을 지릅니다.]],
	color = colors.BROWN,
	level_range = {12, 22},
	rarity = 200,
	require = { stat = { str=16 }, },
	cost = 200,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 4 },
		combat_armor = 6,
		combat_def = 12,
		fatigue = 7,
		max_life = 40,
		infravision = 3,
		talents_types_mastery = { ["cunning/stealth"] = -0.2, },
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Nature's Blessing", image = "object/artifact/armor_natures_blessing.png",
	unided_name = "supple leather armour entwined with willow bark",
	kr_display_name = "자연의 축복", kr_unided_name = "버드나무 껍질이 감긴 유연한 가죽 갑옷",
	desc = [[인간과 하플링 사이의 마법사 전쟁 동안 조직된 지구르 추종자의 첫 수호자 아르돈이 입던 것입니다. 이 갑옷은 많은 자연의 힘이 들어있고, 파괴적인 마법의 힘에 맞서 착용자를 보호합니다.]],
	color = colors.BROWN,
	level_range = {15, 30},
	rarity = 350,
	require = { stat = { str=20 }, {wil=20} },
	cost = 350,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 3, [Stats.STAT_CON] = 4 },

		combat_armor = 6,
		combat_def = 8,
		combat_def_ranged = 4,

		life_regen = 1,
		fatigue = 8,
		stun_immune = 0.25,
		healing_factor = 0.2,
		combat_spellresist = 18,

		resists = {
			[DamageType.NATURE] = 20,
			[DamageType.ARCANE] = 25,
		},

		talents_types_mastery = { ["wild-gift/antimagic"] = 0.2},
	},
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Iron Mail of Bloodletting", image = "object/artifact/iron_mail_of_bloodletting.png",
	unided_name = "gore-encrusted suit of iron mail",
	kr_display_name = "피흘리는 무쇠 갑옷", kr_unided_name = "유혈로 덮힌 무쇠 갑옷",
	desc = [[이 무서운 무쇠 갑옷에서는 끊임없이 피가 흐르고, 어둠의 마법이 그 주변을 휘젓고 있는 것이 뚜렷하게 보입니다. 이것의 착용자에게 맞서는 이에게는 피의 파멸이 다가갑니다.]],
	color = colors.RED,
	level_range = {15, 25},
	rarity = 190,
	require = { stat = { str=14 }, },
	cost = 200,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 2, [Stats.STAT_STR] = 2 },
		resists = {
			[DamageType.ACID] = 10,
			[DamageType.DARKNESS] = 10,
			[DamageType.FIRE] = 10,
			[DamageType.BLIGHT] = 10,
		},
		talents_types_mastery = { ["technique/bloodthirst"] = 0.1 },
		life_regen = 0.5,
		healing_factor = 0.3,
		combat_def = 2,
		combat_armor = 4,
		fatigue = 12,
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_BLOODCASTING, level = 2, power = 60 },
}


newEntity{ base = "BASE_HEAVY_ARMOR", define_as = "SCALE_MAIL_KROLTAR",
	power_source = {technique=true, nature=true},
	unique = true,
	name = "Scale Mail of Kroltar", image = "object/artifact/scale_mail_of_kroltar.png",
	unided_name = "perfectly-wrought suit of dragon scales",
	kr_display_name = "크롤타르의 비늘 갑옷", kr_unided_name = "완벽히 다뤄진 용 비늘 갑옷",
	desc = [[크롤타르가 남긴 비늘로 만든 열겹의 방패같이 훌륭한 방어력을 가진 무거운 비늘 갑옷입니다.]],
	color = colors.LIGHT_RED,
	metallic = false,
	level_range = {38, 45},
	rarity = 300,
	require = { stat = { str=38 }, },
	cost = 500,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 4, [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 3 },
		resists = {
			[DamageType.ACID] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.FIRE] = 20,
			[DamageType.BLIGHT] = 20,
			[DamageType.NATURE] = 20,
		},
		max_life=120,
		combat_def = 10,
		combat_armor = 14,
		fatigue = 16,
	},
	max_power = 80, power_regen = 1,
	use_talent = { id = Talents.T_INFERNO, level = 3, power = 50 },
	set_list = { {"define_as","HELM_KROLTAR"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","max_life"}, 120)
		self:specialSetAdd({"wielder","fatigue"}, -8)
		self:specialSetAdd({"wielder","combat_def"}, 10)
	end,
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Plate Armor of the King", image = "object/artifact/plate_armor_of_the_king.png",
	unided_name = "suit of gleaming voratun plate",
	kr_display_name = "왕의 판갑", kr_unided_name = "미광의 보라툰 판갑",
	desc = [[토크놀 왕이 마지막 희망을 지키는 모습이 아름답게 새겨져 있습니다. 그 것을 보면 가장 어두운 악당이라 할지라도 절망에 빠지게 됩니다.]],
	color = colors.WHITE,
	level_range = {45, 50},
	rarity = 390,
	require = { stat = { str=48 }, },
	cost = 800,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 9, },
		resists = {
			[DamageType.ACID] = 25,
			[DamageType.ARCANE] = 10,
			[DamageType.FIRE] = 25,
			[DamageType.BLIGHT] = 25,
			[DamageType.DARKNESS] = 25,
		},
		max_stamina = 60,
		combat_def = 15,
		combat_armor = 20,
		stun_immune = 0.3,
		knockback_immune = 0.3,
		combat_mentalresist = 25,
		combat_spellresist = 25,
		combat_physresist = 15,
		lite = 1,
		fatigue = 26,
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Cuirass of the Thronesmen", image = "object/artifact/armor_cuirass_of_the_thronesmen.png",
	unided_name = "heavy dwarven-steel armour",
	kr_display_name = "왕좌의 이들을 위한 흉갑", kr_unided_name = "무거운 드워프강철 갑옷",
	desc = [[이 무거운 드워프강철 갑옷은 철의 왕좌에서도 가장 깊은 다장간에서 만든 것입니다. 비할데 없는 방어력을 보여주지만, 그만큼 강력한 힘을 요구합니다.]],
	color = colors.WHITE,
	level_range = {35, 40},
	rarity = 320,
	require = { stat = { str=44 }, },
	cost = 500,
	material_level = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 6, },
		resists = {
			[DamageType.FIRE] = 25,
		},
		combat_def = 20,
		combat_armor = 29,
		stun_immune = 0.4,
		knockback_immune = 0.4,
		combat_physresist = 40,
		healing_factor = -0.4,
		fatigue = 15,
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {psionic=true},
	unique = true,
	name = "Golden Three-Edged Sword 'The Truth'", image = "object/artifact/golden_3_edged_sword.png",
	unided_name = "three-edged sword",
	kr_display_name = "황금 세날검 '진실'", kr_unided_name = "세날검",
	desc = [[현명한 자가 진실은 세날달린 검과 같다고 말했습니다. 그리고 가끔씩 진실은 아픔을 줍니다.]],
	level_range = {25, 32},
	require = { stat = { str=18, wil=18, cun=18 }, },
	color = colors.GOLD,
	encumber = 12,
	cost = 350,
	rarity = 240,
	material_level = 3,
	moddable_tile = "special/golden_sword_right",
	moddable_tile_big = true,
	combat = {
		dam = 40,
		apr = 1,
		physcrit = 7,
		dammod = {str=1.2},
		special_on_hit = {desc="9% 확률로 목표에게 기절이나 혼란 효과 부여", fct=function(combat, who, target)
			if not rng.percent(9) then return end
			local eff = rng.table{"stun", "confusion"}
			if not target:canBe(eff) then return end
			if not target:checkHit(who:combatAttack(combat), target:combatPhysicalResist(), 15) then return end
			if eff == "stun" then target:setEffect(target.EFF_STUNNED, 3, {})
			elseif eff == "confusion" then target:setEffect(target.EFF_CONFUSED, 3, {power=75})
			end
		end},
		melee_project={[DamageType.LIGHT] = 40, [DamageType.DARKNESS] = 40},
	},
}

newEntity{ base = "BASE_MACE",
	power_source = {nature=true},
	name = "Ureslak's Femur", define_as = "URESLAK_FEMUR", image="object/artifact/club_ureslaks_femur.png",
	unided_name = "a strangely colored bone", unique = true,
	kr_display_name = "우레슬락의 대퇴골", kr_unided_name = "이상한 색깔의 뼈",
	desc = [[강력한 무지개빛 용의 짧게만든 대퇴골로, 이 괴상한 곤봉은 우레슬락의 변덕스런 자연력으로 아직도 맥동하고 있습니다.]],
	level_range = {42, 50},
	require = { stat = { str=45, dex=30 }, },
	rarity = 400,
	cost = 300,
	material_level = 5,
	combat = {
		dam = 52,
		apr = 5,
		physcrit = 2.5,
		dammod = {str=1},
		special_on_hit = {desc="10% 확률로 다른 색깔과 힘을 얻기", fct=function(combat, who, target)
			if not rng.percent(10) then return end
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "URESLAK_FEMUR")
			if not o or not who:getInven(inven_id).worn then return end

			who:onTakeoff(o, true)
			local b = rng.table(o.ureslak_bonuses)
			o.kr_display_name = "우레슬락의 "..(b.kr_display_name or b.name).." 대퇴골"
			o.name = "Ureslak's "..b.name.." Femur"
			o.combat.damtype = b.damtype
			o.wielder = b.wielder
			who:onWear(o, true)
			game.logSeen(who, "#GOLD#우레슬락의 대퇴골이 어른거리면서 빛납니다!")
		end },
	},
	ureslak_bonuses = {
		{ name = "Flaming", kr_display_name = "불타는", damtype = DamageType.FIREBURN, wielder = {
			global_speed_add = 0.3,
			resists = { [DamageType.FIRE] = 45 },
			resists_pen = { [DamageType.FIRE] = 30 },
			inc_damage = { [DamageType.FIRE] = 30 },
		} },
		{ name = "Frozen", kr_display_name = "얼어붙은", damtype = DamageType.ICE, wielder = {
			combat_armor = 15,
			resists = { [DamageType.COLD] = 45 },
			resists_pen = { [DamageType.COLD] = 30 },
			inc_damage = { [DamageType.COLD] = 30 },
		} },
		{ name = "Crackling", kr_display_name = "파직거리는", damtype = DamageType.LIGHTNING_DAZE, wielder = {
			inc_stats = { [Stats.STAT_STR] = 6, [Stats.STAT_DEX] = 6, [Stats.STAT_CON] = 6, [Stats.STAT_CUN] = 6, [Stats.STAT_WIL] = 6, [Stats.STAT_MAG] = 6, },
			resists = { [DamageType.LIGHTNING] = 45 },
			resists_pen = { [DamageType.LIGHTNING] = 30 },
			inc_damage = { [DamageType.LIGHTNING] = 30 },
		} },
		{ name = "Venomous", kr_display_name = "유독성", damtype = DamageType.POISON, wielder = {
			resists = { all = 15, [DamageType.NATURE] = 45 },
			resists_pen = { [DamageType.NATURE] = 30 },
			inc_damage = { [DamageType.NATURE] = 30 },
		} },
		{ name = "Starry", kr_display_name = "별빛의", damtype = DamageType.DARKNESS_BLIND, wielder = {
			combat_spellresist = 15, combat_mentalresist = 15, combat_physresist = 15,
			resists = { [DamageType.DARKNESS] = 45 },
			resists_pen = { [DamageType.DARKNESS] = 30 },
			inc_damage = { [DamageType.DARKNESS] = 30 },
		} },
		{ name = "Eldritch", kr_display_name = "섬뜩한", damtype = DamageType.ARCANE, wielder = {
			resists = { [DamageType.ARCANE] = 45 },
			resists_pen = { [DamageType.ARCANE] = 30 },
			inc_damage = { all = 12, [DamageType.ARCANE] = 30 },
		} },
	},
}

newEntity{ base = "BASE_WARAXE",
	power_source = {psionic=true},
	unique = true,
	rarity = false, unided_name = "razor sharp war axe",
	name = "Razorblade, the Cursed Waraxe", color = colors.LIGHT_BLUE, image = "object/artifact/razorblade_the_cursed_waraxe.png",
	kr_display_name = "저주받은 전투도끼 면도날", kr_unided_name = "면도날처럼 생긴 전투도끼",
	desc = [[이 강력한 도끼는 날카로운 칼처럼 갑옷을 찢을 수도 있고, 무거운 곤봉같은 충격을 줄 수도 있습니다.
이것을 쥔 사람은 천천히 미쳐간다고 알려져 있습니다. 어쨋든 그 소문은 밝혀지지 않았고, 사실을 말해줄 이 물건의 사용자였던 사람은 존재하지 않는것 같습니다.]],
	require = { stat = { str=42 }, },
	level_range = {40, 50},
	rarity = 250,
	material_level = 5,
	combat = {
		dam = 58,
		apr = 16,
		physcrit = 7,
		dammod = {str=1},
		damrange = 1.4,
		damtype = DamageType.PHYSICALBLEED,
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 4, [Stats.STAT_DEX] = 4, },
		see_invisible = 5,
		inc_damage = { [DamageType.PHYSICAL]=10 },
	},
}

newEntity{ base = "BASE_LONGSWORD", define_as = "ART_PAIR_TWSWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Sword of Potential Futures", image = "object/artifact/sword_of_potential_futures.png",
	unided_name = "under-wrought blade",
	kr_display_name = "잠재적 미래의 검", kr_unided_name = "미완성의 칼",
	desc = [[전설에 따르면, 이 검은 짝이 있다고 합니다. 두 쌍둥이 검은 감시자의 날들 초기에 만들어진 것입니다. 훈련되지 않은 착용자에게는 완벽하지 않지만, 감시자에게는 이용되지 않은 잠재적인 시간까지 보여줍니다.]],
	level_range = {20, 30},
	rarity = 250,
	require = { stat = { str=24, mag=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 28,
		apr = 10,
		physcrit = 8,
		dammod = {str=0.8,mag=0.2},
		melee_project={[DamageType.TEMPORAL] = 5},
	},
	wielder = {
		inc_damage={
			[DamageType.TEMPORAL] = 5, [DamageType.PHYSICAL] = -5,
		},
		resist_all_on_teleport = 5,
		defense_on_teleport = 10,
		effect_reduction_on_teleport = 15,
	},
	set_list = { {"define_as","ART_PAIR_TWDAG"} },
	on_set_complete = function(self, who)
		self.combat.special_on_hit = {desc="10% 확률로 목표의 전체 피해 저항 감소", fct=function(combat, who, target)
			if not rng.percent(10) then return end
			target:setEffect(target.EFF_FLAWED_DESIGN, 3, {power=20})
		end}
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.TEMPORAL]=5, [engine.DamageType.PHYSICAL]=10,})
		game.logSeen(who, "#CRIMSON#두 칼이 다시 뭉치자 시간의 메아리가 다시 한번 울려 퍼집니다.")
	end,
	on_set_broken = function(self, who)
		self.combat.special_on_hit = nil
		game.logPlayer(who, "#CRIMSON#두 칼이 분리되자 느껴지는 시간의 완성도가 떨어져 보입니다.")
	end,
}

newEntity{ base = "BASE_KNIFE", define_as = "ART_PAIR_TWDAG",
	power_source = {arcane=true},
	unique = true,
	name = "Dagger of the Past", image = "object/artifact/dagger_of_the_past.png",
	unided_name = "rusted blade",
	kr_display_name = "과거의 단검", kr_unided_name = "녹슨 칼",
	desc = [[전설에 따르면, 이 검은 짝이 있다고 합니다. 두 쌍둥이 검은 감시자의 날들 초기에 만들어진 것입니다. 훈련되지 않은 참용자에게는 완벽하지 않지만, 감시자에게는 과거의 실수들로부터 배움의 기회를 얻을 수 있게 만들어 줍니다.]],
	level_range = {20, 30},
	rarity = 250,
	require = { stat = { dex=24, mag=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 25,
		apr = 20,
		physcrit = 20,
		dammod = {dex=0.5,mag=0.5},
		melee_project={[DamageType.TEMPORAL] = 5},
	},
	wielder = {
		inc_damage={
			[DamageType.TEMPORAL] = 5, [DamageType.PHYSICAL] = -10,
		},
		resist_all_on_teleport = 5,
		defense_on_teleport = 10,
		effect_reduction_on_teleport = 15,
	},
	set_list = { {"define_as","ART_PAIR_TWSWORD"} },
	on_set_complete = function(self, who)
		self.combat.special_on_hit = {desc="10% 확률로 목표를 젊게 만듦", fct=function(combat, who, target)
			if not rng.percent(10) then return end
			target:setEffect(target.EFF_TURN_BACK_THE_CLOCK, 3, {power=10})
		end}
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.TEMPORAL]=5, [engine.DamageType.PHYSICAL]=10,})
		self:specialSetAdd({"wielder","resists_pen"}, {[engine.DamageType.TEMPORAL]=15,})
	end,
	on_set_broken = function(self, who)
		self.combat.special_on_hit = nil
	end,
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Witch-Bane", color = colors.LIGHT_STEEL_BLUE, image = "object/artifact/sword_witch_bane.png",
	unided_name = "an ivory handled voratun longsword",
	kr_display_name = "마녀의 파멸", kr_unided_name = "상아 손잡이가 달린 보라툰 장검",
	desc = [[얇은 보라툰 칼날에 보라색 천으로 감긴 상아 손잡이가 달려 있습니다. 이 무기는 이전 사용자 마르쿠스 둔만큼 전설적이고, 마법사냥 말기에 마르쿠스가 살해당한 이후 부서졌다고 생각되고 있습니다.
반마법에 익숙한 이는 이것의 잠재적 능력을 모두 사용할 수 있을것 같습니다.]],
	level_range = {38, 50},
	rarity = 250,
	require = { stat = { str=48 }, },
	cost = 650,
	material_level = 5,
	combat = {
		dam = 42,
		apr = 4,
		physcrit = 10,
		dammod = {str=1},
		melee_project = { [DamageType.MANABURN] = 50 },
	},
	wielder = {
		talent_cd_reduction={
			[Talents.T_AURA_OF_SILENCE] = 2,
			[Talents.T_MANA_CLASH] = 2,
		},
		resists = {
			all = 10,
			[DamageType.PHYSICAL] = - 10,
		},
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"
			local Talents = require "engine.interface.ActorTalents"

			self:specialWearAdd({"combat", "talent_on_hit"}, { [Talents.T_MANA_CLASH] = {level=1, chance=25}  })
			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 6, })
			game.logPlayer(who, "#LIGHT_BLUE#위대한 영웅의 보살핌이 느껴집니다!")
		end
	end,
}


newEntity{ base = "BASE_GAUNTLETS",
	power_source = {arcane=true},
	unique = true,
	name = "Stone Gauntlets of Harkor'Zun",
	unided_name = "dark stone gauntlets",
	kr_display_name = "하코르'준의 암석 전투장갑", kr_unided_name = "어두운 암석 전투장갑",
	desc = [[고대의 시간에 하코르'준의 광신도가 만든 물건입니다. 이 무거운 화강암 전투장갑은 그들이 신봉하는 어둠의 지배자의 분노로부터 착용자를 보호하기 위해 설계되었습니다.]],
	level_range = {26, 31},
	rarity = 210,
	encumber = 7,
	metallic = false,
	cost = 150,
	material_level = 3,
	wielder = {
		talent_cd_reduction={
			[Talents.T_CLINCH]=2,
		},
		fatigue = 10,
		combat_armor = 7,
		inc_damage = { [DamageType.PHYSICAL]=5, [DamageType.ACID]=10, },
		resists = {[DamageType.ACID] = 20, [DamageType.PHYSICAL] = 10, },
		resists_cap = {[DamageType.ACID] = 10, [DamageType.PHYSICAL] = 5, },
		resists_pen = {[DamageType.ACID] = 15, [DamageType.PHYSICAL] = 15, },
		combat = {
			dam = 26,
			apr = 15,
			physcrit = 5,
			dammod = {dex=0.3, str=-0.4, cun=0.3 },
			melee_project={[DamageType.ACID] = 10},
			damrange = 0.3,
			physspeed = 0.2,
		},
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true, psionic=true},
	unique = true,
	name = "Unflinching Eye", color = colors.WHITE, image = "object/artifact/amulet_unflinching_eye.png",
	unided_name = "a bloodshot eye",
	kr_display_name = "단호한 눈", kr_unided_name = "충혈된 눈",
	desc = [[어떤이가 짙은 검정 노끈을 이 크고 충혈된 눈알에 엮어, 목에 걸수 있도록 만든 것입니다. 사용할 것인지는 당신의 선택입니다.]],
	level_range = {30, 40},
	rarity = 300,
	cost = 300,
	material_level = 4,
	metallic = false,
	wielder = {
		infravision = 3,
		resists = { [DamageType.LIGHT] = -25 },
		resists_cap = { [DamageType.LIGHT] = -25 },
		blind_immune = 1,
		confusion_immune = 0.5,
		esp = { horror = 1 }, esp_range = 10,
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_ARCANE_EYE, level = 2, power = 60 },
}

newEntity{ base = "BASE_CLOAK",
	power_source = {nature=true},
	unique = true,
	name = "Ureslak's Molted Scales", image = "object/artifact/ureslaks_molted_scales.png",
	unided_name = "scaley multi-hued cloak",
	kr_display_name = "우레슬락의 녹은 비늘", kr_unided_name = "무지개빛 비늘 망토",
	desc = [[이 망토는 커다란 파충류의 비늘로 만들어진 것입니다. 이것은 무지개의 모든 색깔을 반사하고 있습니다.]],
	level_range = {40, 50},
	rarity = 400,
	cost = 300,
	material_level = 5,
	wielder = {
		resists_cap = {
			[DamageType.FIRE] = 5,
			[DamageType.COLD] = 5,
			[DamageType.LIGHTNING] = 5,
			[DamageType.NATURE] = 5,
			[DamageType.DARKNESS] = 5,
			[DamageType.ARCANE] = -30,
		},
		resists = {
			[DamageType.FIRE] = 20,
			[DamageType.COLD] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.NATURE] = 20,
			[DamageType.DARKNESS] = 20,
			[DamageType.ARCANE] = -30,
		},
	},
}

newEntity{ base = "BASE_DIGGER",
	power_source = {technique=true},
	unique = true,
	name = "Pick of Dwarven Emperors", color = colors.GREY, image = "object/artifact/pick_of_dwarven_emperors.png",
	unided_name = "crude iron pickaxe",
	kr_display_name = "드워프 황제의 곡괭이", kr_unided_name = "조잡한 무쇠 곡괭이",
	desc = [[이 고대의 곡괭이는 한 세대에서 다음 세대로 이어져 내려온 드워프의 전설입니다. 머리와 자루에는 빼곡히 룬이 덮혀있고, 그 내용은 드워프들의 역사를 열거하고 있습니다.]],
	level_range = {40, 50},
	rarity = 290,
	cost = 150,
	material_level = 5,
	digspeed = 12,
	wielder = {
		resists_pen = { [DamageType.PHYSICAL] = 10, },
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_CON] = 3, },
		combat_mentalresist = 7,
		combat_physresist = 7,
		combat_spellresist = 7,
		max_life = 50,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Dwarf" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_STR] = 5, [Stats.STAT_CON] = 5, })
			self:specialWearAdd({"wielder","inc_damage"}, { [DamageType.PHYSICAL] = 10 })
			self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["race/dwarf"] = 0.2 })

			game.logPlayer(who, "#LIGHT_BLUE#이 곡괭이를 쥐자, 조상들의 속삭임이 느껴집니다!")
		end
	end,
}

-- Channelers set
-- Note that this staff can not be channeled.  All of it's flavor is arcane, lets leave it arcane
newEntity{ base = "BASE_STAFF", define_as = "SET_STAFF_CHANNELERS",
	power_source = {arcane=true},
	unique = true,
	name = "Staff of Arcane Supremacy",
	unided_name = "silver-runed staff",
	kr_display_name = "지고의 마법 지팡이", kr_unided_name = "은빛 룬 지팡이",
	flavor_name = "magestaff",
	level_range = {20, 40},
	color=colors.BLUE, image = "object/artifact/staff_of_arcane_supremacy.png",
	rarity = 300,
	desc = [[길고 늘씬한 지팡이로, 고대의 용뼈로 만들어졌고 밝은 은빛 룬 장식이 표면을 뒤덮고 있습니다.
그 속에 갖혀진 거대한 힘이 있는 것 처럼 희미하게 웅웅거리는데, 뭔가 부족한 것 같습니다.]],
	cost = 200,
	material_level = 3,
	require = { stat = { mag=24 }, },
	combat = {
		dam = 20,
		apr = 4,
		dammod = {mag=1.5},
		damtype = DamageType.ARCANE,
	},
	wielder = {
		combat_spellpower = 20,
		inc_damage={
			[DamageType.ARCANE] = 20,
		},
		talent_cd_reduction = {
			[Talents.T_MANATHRUST] = 1,
		},
		talents_types_mastery = {
			["spell/arcane"]=0.2,
		},
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_ARCANE_SUPREMACY, level = 3, power = 20 },
	set_list = { {"define_as", "SET_HAT_CHANNELERS"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","max_mana"}, 100)
		game.logSeen(who, "#STEEL_BLUE#마법 에너지가 팽창하는 것이 느껴집니다.")
	end,
}

newEntity{ base = "BASE_WIZARD_HAT", define_as = "SET_HAT_CHANNELERS",
	power_source = {arcane=true},
	unique = true,
	name = "Hat of Arcane Understanding",
	unided_name = "silver-runed hat",
	kr_display_name = "마법 이해의 모자", kr_unided_name = "은빛 룬 모자",
	desc = [[전통적인 뾰족한 마법모자로, 훌륭한 보라색 엘프비단으로 만들었고 밝은 은빛 룬으로 장식되어 있습니다. 위대한 마법사의 머리 위에서 태어내 고대로부터 이어져 내려온 것임을 느낄 수 있습니다.
건드려보면 과거 시대의 지식과 힘이 느껴집니다. 아직 그 일부가 봉인되어 있지만, 모든 힘을 낼 날을 기다리고 있는 것 같습니다.]],
	color = colors.BLUE, image = "object/artifact/wizard_hat_of_arcane_understanding.png",
	level_range = {20, 40},
	rarity = 300,
	cost = 100,
	material_level = 3,
	wielder = {
		combat_def = 2,
		mana_regen = 2,
		resists = {
			[DamageType.ARCANE] = 20,
		},
		talent_cd_reduction = {
			[Talents.T_DISRUPTION_SHIELD] = 10,
		},
		talents_types_mastery = {
			["spell/meta"]=0.2,
		},
	},
	max_power = 40, power_regen = 1,
	set_list = { {"define_as", "SET_STAFF_CHANNELERS"} },
	on_set_complete = function(self, who)
		local Talents = require "engine.interface.ActorTalents"
		self.use_talent = { id = Talents.T_METAFLOW, level = 3, power = 40 }
		game.party:learnLore("channelers-set")
	end,
	on_set_broken = function(self, who)
		self.use_talent = nil
		game.logPlayer(who, "#STEEL_BLUE#주변의 마법 에너지가 흩어집니다.")
	end,
}

newEntity{ base = "BASE_ARROW",
	power_source = {arcane=true},
	unique = true,
	name = "Quiver of the Sun",
	unided_name = "bright quiver",
	kr_display_name = "태양의 전통", kr_unided_name = "밝은 전통",
	desc = [[이 이상한 주황색 전통은 놋쇠로 만들어졌고, 빛을 쬐면 반짝거리고 달아오른 많은 밝은 빨간색 룬이 새겨져 있습니다. 태양빛과 같이 폭발할 듯한 뜨거운 빛을 내는 단단한 화살대가 훌륭히 연마되어 단단함을 보여줍니다.]],
	color = colors.BLUE, image = "object/artifact/quiver_of_the_sun.png",
	level_range = {20, 40},
	rarity = 300,
	cost = 100,
	material_level = 4,
	require = { stat = { dex=24 }, },
	combat = {
		capacity = 4,
		tg_type = "beam",
		travel_speed = 3,
		dam = 34,
		apr = 10,
		physcrit = 2,
		dammod = {dex=0.7, str=0.5},
		damtype = DamageType.LITE_LIGHT,
	},
}

newEntity{ base = "BASE_ARROW",
	power_source = {psionic=true},
	unique = true,
	name = "Quiver of Domination",
	unided_name = "grey quiver",
	kr_display_name = "지배의 전통", kr_unided_name = "회색 전통",
	desc = [[이 전통의 화살에서는 강력한 정신 감응적 힘이 발산됩니다. 촉은 둔해 보이지만, 건드리면 강렬한 고통을 발생시킵니다.]],
	color = colors.GREY, image = "object/artifact/quiver_of_domination.png",
	level_range = {20, 40},
	rarity = 300,
	cost = 100,
	material_level = 4,
	require = { stat = { dex=24 }, },
	combat = {
		capacity = 8,
		dam = 24,
		apr = 8,
		physcrit = 2,
		dammod = {dex=0.6, str=0.5, wil=0.2},
		damtype = DamageType.MIND,
		special_on_crit = {desc="40% 확률로 목표를 지배", fct=function(combat, who, target)
			if not target or target == self then return end
			if not rng.percent(40)  then return end
			if target:canBe("instakill") then
				target:setEffect(target.EFF_DOMINATE_ENTHRALL, 3, {src=who, apply_power=who:combatMindpower()})
			end
		end},
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Blightstopper",
	unided_name = "vine coated shield",
	kr_display_name = "황폐차단기", kr_unided_name = "덩굴 감긴 방패",
	desc = [[이 보라툰 방패는 두꺼운 덩굴로 덮혀 있습니다. 그 덩굴에는 예전에 하플링 장군 알마다르 리울이 자연의 힘이 집어넣었습니다. 이 장군은 장작더미의 전투 당시 오크 타락자들의 마법과 질병을 막기 위해 이 방패를 사용했습니다.]],
	color = colors.LIGHT_GREEN, image = "object/artifact/blightstopper.png",
	level_range = {36, 45},
	rarity = 300,
	require = { stat = { str=35 }, },
	cost = 375,
	material_level = 5,
	special_combat = {
		dam = 52,
		block = 240,
		physcrit = 4.5,
		dammod = {str=1},
		damtype = DamageType.PHYSICAL,
		convert_damage = {
			[DamageType.NATURE] = 30,
			[DamageType.MANABURN] = 10,
		},
	},
	wielder = {
		resists={[DamageType.BLIGHT] = 35, [DamageType.NATURE] = 15},
		on_melee_hit={[DamageType.NATURE] = 15},
		combat_armor = 12,
		combat_def = 18,
		combat_def_ranged = 12,
		combat_spellresist = 24,
		talents_types_mastery = { ["wild-gift/antimagic"] = 0.2, },
		fatigue = 22,
		learn_talent = { [Talents.T_BLOCK] = 5,},
		disease_immune = 0.6,
	},
	max_power = 40, power_regen = 1,
	use_power = { name = "질병 정화 및 면역력 상승", power = 24,
	use = function(self, who)
		local target = who
		local effs = {}
		local known = false

		who:setEffect(who.EFF_PURGE_BLIGHT, 5, {power=20})

			-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.disease then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, 3 + math.floor(who:getWil() / 10) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end
		game.logSeen(who, "%s의 질병이 정화되었습니다!", (who.kr_display_name or who.name):capitalize())
		return {id=true, used=true}
	end,
	},
}

newEntity{ base = "BASE_SHOT",
	power_source = {arcane=true},
	unique = true,
	name = "Star Shot",
	unided_name = "blazing shot",
	kr_display_name = "별 탄환", kr_unided_name = "불꽃 탄환",
	desc = [[이 강력한 탄환에서는 강렬한 열기가 발산되고 있습니다.]],
	color = colors.RED, image = "object/artifact/star_shot.png",
	level_range = {25, 40},
	rarity = 300,
	cost = 110,
	material_level = 4,
	require = { stat = { dex=28 }, },
	combat = {
		capacity = 4,
		dam = 32,
		apr = 15,
		physcrit = 10,
		dammod = {dex=0.7, cun=0.5},
		damtype = DamageType.FIRE,
		special_on_hit = {desc="강력한 폭발 점화", fct=function(combat, who, target)
			local tg = {type="ball", range=0, radius=3, selffire=false}
			local grids = who:project(tg, target.x, target.y, DamageType.FIREKNOCKBACK, {dist=3, dam=40 + who:getMag()*0.6 + who:getCun()*0.6})
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "ball_fire", {radius=tg.radius})
		end},
	},
}

--[[ For now
newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic=true},
	unique = true,
	name = "Withered Force", define_as = "WITHERED_STAR",
	unided_name = "dark mindstar",
	level_range = {28, 38},
	color=colors.AQUAMARINE,
	rarity = 250,
	desc = [=[A hazy aura emanates from this ancient gem, coated with withering, thorny vines.]=],
	cost = 98,
	require = { stat = { wil=24 }, },
	material_level = 4,
	combat = {
		dam = 16,
		apr = 28,
		physcrit = 5,
		dammod = {wil=0.45, cun=0.25},
		damtype = DamageType.MIND,
		convert_damage = {
			[DamageType.DARKNESS] = 30,
		},
		talents_types_mastery = {
			["cursed/gloom"] = 0.2,
			["cursed/darkness"] = 0.2,
		}
	},
	ms_combat = {},
	wielder = {
		combat_mindpower = 14,
		combat_mindcrit = 7,
		inc_damage={
			[DamageType.DARKNESS] 	= 10,
			[DamageType.PHYSICAL]	= 10,
		},
		inc_stats = { [Stats.STAT_WIL] = 4,},
		hate_per_kill = 3,
	},
	max_power = 40, power_regen = 1,
	use_power = { name = "switch the weapon between an axe and a mindstar", power = 40,
		use = function(self, who)
		if self.subtype == "mindstar" then
			ms_combat = table.clone(self.combat)
			--self.name	= "Withered Axe"
			if self:isTalentActive (who.T_PSIBLADES) then
				self:forceUseTalent(who.T_PSIBLADES, {ignore_energy=true})
				game.logSeen(who, "%s rejects the inferior psionic blade!", self.name:capitalize())
			end
			self.desc	= [=[A hazy aura emanates from this dark axe, withering, thorny vines twisting around the handle.]=]
			self.subtype = "waraxe"
			self.image = self.resolvers.image_material("axe", "metal")
			self.moddable_tile = self.resolvers.moddable_tile("axe")
					self:removeAllMOs()
			--Set moddable tile here
			self.combat = nil
			self.combat = {
				talented = "axe", damrange = 1.4, physspeed = 1, sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2},
				no_offhand_penalty = true,
				dam = 34,
				apr = 8,
				physcrit = 7,
				dammod = {str=0.85, wil=0.2},
				damtype = DamageType.PHYSICAL,
				convert_damage = {
					[DamageType.DARKNESS] = 25,
					[DamageType.MIND] = 15,
				},
			}
		else
			--self.name	= "Withered Star"
			self.image = self.resolvers.image_material("mindstar", "nature")
			self.moddable_tile = self.resolvers.moddable_tile("mindstar")
					self:removeAllMOs()
			--Set moddable tile here
			self.desc	= [=[A hazy aura emanates from this ancient gem, coated with withering, thorny vines."]=]
			self.subtype = "mindstar"
			self.combat = nil
			self.combat = table.clone(ms_combat)
		end
		return {id=true, used=true}
		end
	},
}
]]

newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic=true},
	unique = true,
	name = "Nexus of the Way",
	unided_name = "brilliant green mindstar",
	kr_display_name = "'한길' 연합", kr_unided_name = "눈부신 녹색 마석",
	level_range = {38, 50},
	color=colors.AQUAMARINE, image = "object/artifact/nexus_of_the_way.png",
	rarity = 350,
	desc = [['한길'의 막대한 염동력이 이 원석에서 울려퍼집니다. 건드려보면, 압도적인 힘을 느낄수 있고, 수많은 생각이 들립니다.]],
	cost = 280,
	require = { stat = { wil=48 }, },
	material_level = 5,
	combat = {
		dam = 22,
		apr = 40,
		physcrit = 5,
		dammod = {wil=0.6, cun=0.2},
		damtype = DamageType.MIND,
	},
	wielder = {
		combat_mindpower = 20,
		combat_mindcrit = 9,
		confusion_immune=0.3,
		inc_damage={
			[DamageType.MIND] 	= 20,
		},
		resists={
			[DamageType.MIND] 	= 20,
		},
		resists_pen={
			[DamageType.MIND] 	= 20,
		},
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 3, },
	},
	max_power = 75, power_regen = 1,
	use_talent = { id = Talents.T_WAYIST, level = 1, power = 75 },
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Yeek" then
			local Talents = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["race/yeek"] = 0.2 })
			self:specialWearAdd({"wielder","combat_mindpower"}, 5)
			self:specialWearAdd({"wielder","combat_mentalresist"}, 15)
			game.logPlayer(who, "#LIGHT_BLUE#당신이 소속된 '한길'의 힘이 느껴집니다!")
		end
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Talents = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder","resists"}, {[engine.DamageType.MIND] = -25,})
			self:specialWearAdd({"wielder","combat_mentalresist"}, -20)
			game.logPlayer(who, "#RED#'한길'이 과거의 포획자들을 거부합니다!")
		end
	end,
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic=true},
	unique = true,
	name = "Amethyst of Sanctuary",
	unided_name = "deep purple gem",
	kr_display_name = "성역의 자수정", kr_unided_name = "짙은 보랏빛 보석",
	level_range = {30, 38},
	color=colors.AQUAMARINE, image = "object/artifact/amethyst_of_sanctuary.png",
	rarity = 250,
	desc = [[이 밝은 보라색 보석에서는 차분하고 집중된 힘이 스며나옵니다. 손에 쥐면, 외부의 힘에 대항하여 보호됨을 느낍니다.]],
	cost = 85,
	require = { stat = { wil=28 }, },
	material_level = 4,
	combat = {
		dam = 15,
		apr = 26,
		physcrit = 6,
		dammod = {wil=0.45, cun=0.22},
		damtype = DamageType.MIND,
	},
	wielder = {
		combat_mindpower = 14,
		combat_mindcrit = 8,
		combat_mentalresist = 25,
		max_psi = 20,
		talents_types_mastery = {
			["psionic/focus"] = 0.1,
			["psionic/absorption"] = 0.2,
		},
		resists={
			[DamageType.MIND] 	= 15,
		},
		inc_stats = { [Stats.STAT_WIL] = 8,},
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Sceptre of the Archlich",
	flavor_name = "vilestaff",
	unided_name = "bone carved sceptre",
	kr_display_name = "고위리치의 홀", kr_unided_name = "뼈 홀",
	level_range = {30, 38},
	color=colors.VIOLET, image = "object/artifact/sceptre_of_the_archlich.png",
	rarity = 320,
	desc = [[검은 고대의 뼈를 깍아 만든 이 홀에는 짙은 흑요석이 박혀있습니다. 그 속에서 어둠의 힘이 느껴지고, 들여다보면 꺼낼 수 있을 것 같습니다.]],
	cost = 285,
	material_level = 4,

	require = { stat = { mag=40 }, },
	combat = {
		dam = 40,
		apr = 12,
		dammod = {mag=1.3},
		damtype = DamageType.DARKNESS,
	},
	wielder = {
		combat_spellpower = 28,
		combat_spellcrit = 14,
		inc_damage={
			[DamageType.DARKNESS] = 26,
		},
		talents_types_mastery = {
			["celestial/star-fury"] = 0.2,
			["spell/necrotic-minions"] = 0.2,
			["spell/advanced-necrotic-minions"] = 0.1,
		}
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Lich" then
			local Talents = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["spell/nightfall"] = 0.2 })
			self:specialWearAdd({"wielder","combat_spellpower"}, 12)
			self:specialWearAdd({"wielder","combat_spellresist"}, 10)
			self:specialWearAdd({"wielder","combat_mentalresist"}, 10)
			self:specialWearAdd({"wielder","max_mana"}, 50)
			self:specialWearAdd({"wielder","mana_regen"}, 0.5)
			game.logPlayer(who, "#LIGHT_BLUE#홀의 힘이 언데드의 형상으로 흘러들어오는 것이 느껴집니다!")
		end
	end,
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Oozing Heart",
	unided_name = "slimy mindstar",
	kr_display_name = "진흙 덩어리 심장", kr_unided_name = "찐득한 마석",
	level_range = {27, 34},
	color=colors.GREEN, image = "object/artifact/oozing_heart.png",
	rarity = 250,
	desc = [[이 마석에서는 진하고 끈적이는 액체가 스며나옵니다. 그 주변의 마법이 사라짐을 느낍니다.]],
	cost = 85,
	require = { stat = { wil=36 }, },
	material_level = 4,
	combat = {
		dam = 17,
		apr = 25,
		physcrit = 7,
		dammod = {wil=0.5, cun=0.2},
		damtype = DamageType.SLIME,
	},
	wielder = {
		combat_mindpower = 12,
		combat_mindcrit = 8,
		combat_spellresist=15,
		inc_damage={
			[DamageType.NATURE] = 18,
		},
		resists={
			[DamageType.ARCANE] = 12,
			[DamageType.BLIGHT] = 12,
		},
		inc_stats = { [Stats.STAT_WIL] = 7, [Stats.STAT_CUN] = 2, },
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_OOZE_SPIT, level = 2, power = 20 },
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {nature=true},
	unique = true,
	name = "Bloomsoul",
	unided_name = "flower covered mindstar",
	kr_display_name = "꽃피운 영혼", kr_unided_name = "꽃으로 덮힌 마석",
	level_range = {10, 20},
	color=colors.GREEN, image = "object/artifact/bloomsoul.png",
	rarity = 180,
	desc = [[이 마석의 표면은 원시적인 꽃들로 덮혀 있습니다. 건드리면 차분해지면서 상쾌해집니다.]],
	cost = 40,
	require = { stat = { wil=18 }, },
	material_level = 2,
	combat = {
		dam = 8,
		apr = 13,
		physcrit = 7,
		dammod = {wil=0.25, cun=0.1},
		damtype = DamageType.NATURE,
	},
	wielder = {
		combat_mindpower = 12,
		combat_mindcrit = 8,
		life_regen = 0.5,
		healing_factor = 0.1,
		talents_types_mastery = { ["wild-gift/fungus"] = 0.2,},
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_BLOOM_HEAL, level = 1, power = 60 },
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Gravitational Staff",
	flavor_name = "starstaff",
	unided_name = "heavy staff",
	kr_display_name = "중력의 지팡이", kr_unided_name = "무거운 지팡이",
	level_range = {25, 33},
	color=colors.VIOLET, image = "object/artifact/gravitational_staff.png",
	rarity = 240,
	desc = [[이 지팡이의 끝부분 주변의 시공간이 구부러지고 왜곡됩니다.]],
	cost = 215,
	material_level = 3,
	require = { stat = { mag=35 }, },
	combat = {
		dam = 30,
		apr = 8,
		dammod = {mag=1.3},
		damtype = DamageType.GRAVITYPIN,
	},
	wielder = {
		combat_spellpower = 25,
		combat_spellcrit = 7,
		inc_damage={
			[DamageType.PHYSICAL] 	= 18,
			[DamageType.TEMPORAL] 	= 10,
		},
		resists={
			[DamageType.PHYSICAL] 	= 14,
		},
		talents_types_mastery = {
			["chronomancy/gravity"] = 0.2,
			["chronomancy/matter"] = 0.1,
			["spell/earth"] = 0.1,
		}
	},
	max_power = 14, power_regen = 1,
	use_talent = { id = Talents.T_GRAVITY_SPIKE, level = 3, power = 14 },
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {nature=true},
	name = "Eye of the Wyrm", define_as = "EYE_WYRM",
	unided_name = "multi-colored mindstar", unique = true,
	kr_display_name = "용의 눈", kr_unided_name = "무지개빛 마석",
	desc = [[이 마석의 중심부에는 검은 홍채가 박혀있고, 그것은 무수히 많은 색깔들로 변화합니다. 그것은 뭔가를 찾기 위해 주변으로 돌진합니다.]],
	color = colors.BLUE, image = "object/artifact/eye_of_the_wyrm.png",
	level_range = {30, 40},
	require = { stat = { wil=45, }, },
	rarity = 280,
	cost = 300,
	material_level = 4,
	sentient=true,
	combat = {
		dam = 16,
		apr = 24,
		physcrit = 2.5,
		dammod = {wil=0.4, cun=0.1, str=0.2},
		damtype=DamageType.PHYSICAL,
		convert_damage = {
			[DamageType.COLD] = 18,
			[DamageType.FIRE] = 18,
			[DamageType.ACID] = 18,
			[DamageType.LIGHTNING] = 18,
		},
	},
	wielder = {
		combat_mindpower = 9,
		combat_mindcrit = 7,
		inc_damage={
			[DamageType.PHYSICAL] 	= 8,
			[DamageType.FIRE] 	= 8,
			[DamageType.COLD] 	= 8,
			[DamageType.LIGHTNING] 	= 8,
			[DamageType.ACID] 	= 8,
		},
		resists={
			[DamageType.PHYSICAL] 	= 8,
			[DamageType.FIRE] 	= 8,
			[DamageType.COLD] 	= 8,
			[DamageType.ACID] 	= 8,
			[DamageType.LIGHTNING] 	= 8,
		},
		talents_types_mastery = {
			["wild-gift/sand-drake"] = 0.1,
			["wild-gift/fire-drake"] = 0.1,
			["wild-gift/cold-drake"] = 0.1,
			["wild-gift/storm-drake"] = 0.1,
			["wild-gift/venom-drake"] = 0.1,
		}
	},
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		if self.power < self.max_power then
			self.power=self.power + 1
		end
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		if not rng.percent(25)  then return end
		self.use_talent.id=rng.table{ "T_FIRE_BREATH", "T_ICE_BREATH", "T_LIGHTNING_BREATH", "T_SAND_BREATH", "T_CORROSIVE_BREATH" }
--		game.logSeen(self.worn_by, "#GOLD#The %s shifts colour!", self.name:capitalize())
	end,
	max_power = 30, power_regen = 1,
	--[[use_power = { name = "release a random breath", power = 40,
	use = function(self, who)
			local Talents = require "engine.interface.ActorTalents"
			local breathe = rng.table{
				{Talents.T_FIRE_BREATH},
				{Talents.T_ICE_BREATH},
				{Talents.T_LIGHTNING_BREATH},
				{Talents.T_SAND_BREATH},
			}

			who:forceUseTalent(breathe[1], {ignore_cd=true, ignore_energy=true, force_level=4, ignore_ressources=true})
			return {id=true, used=true}
		end
	},]]
	use_talent = { id = rng.table{ Talents.T_FIRE_BREATH, Talents.T_ICE_BREATH, Talents.T_LIGHTNING_BREATH, Talents.T_SAND_BREATH, Talents.T_CORROSIVE_BREATH }, level = 4, power = 30 }
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {nature=true},
	name = "Great Caller",
	unided_name = "humming mindstar", unique = true, image = "object",
	kr_display_name = "위대한 호출자", kr_unided_name = "허밍 마석",
	desc = [[이 마석은 끊임없이 낮은 소리를 내고 있습니다. 생명력이 그 쪽으로 당겨지는 것 같습니다.]],
	color = colors.GREEN,  image = "object/artifact/great_caller.png",
	level_range = {20, 32},
	require = { stat = { wil=34, }, },
	rarity = 250,
	cost = 220,
	material_level = 3,
	combat = {
		dam = 10,
		apr = 18,
		physcrit = 2.5,
		dammod = {wil=0.35, cun=0.5},
		damtype=DamageType.NATURE,
	},
	wielder = {
		combat_mindpower = 9,
		combat_mindcrit = 6,
		inc_damage={
			[DamageType.PHYSICAL] 	= 8,
			[DamageType.FIRE] 	= 8,
			[DamageType.COLD] 	= 8,
		},
		talents_types_mastery = {
			["wild-gift/summon-melee"] = 0.1,
			["wild-gift/summon-distance"] = 0.1,
			["wild-gift/summon-augmentation"] = 0.1,
			["wild-gift/summon-utility"] = 0.1,
			["wild-gift/summon-advanced"] = 0.1,
		},
		heal_on_nature_summon = 30,
		nature_summon_max = 2,
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 4 },
	},
	max_power = 24, power_regen = 1,
	use_talent = { id = Talents.T_RAGE, level = 4, power = 20 },
}

newEntity{ base = "BASE_HELM",
	power_source = {arcane=true},
	unique = true,
	name = "Corrupted Gaze", image = "object/artifact/corrupted_gaze.png",
	unided_name = "dark visored helm",
	kr_display_name = "타락한 시선", kr_unided_name = "어두운 면갑 투구",
	desc = [[이 투구는 어둠의 힘을 내뿜습니다. 면갑은 착용자의 시야를 비틀고 타락시키는 것 같습니다. 너무 오래쓰고 있는 것이 아닌지 걱정될 정도로, 시야는 정신에 영향을 끼치고 있습니다.]],
	require = { stat = { mag=16 } },
	level_range = {28, 40},
	rarity = 300,
	cost = 300,
	material_level = 4,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 4, [Stats.STAT_WIL] = 3, [Stats.STAT_CUN] = 4,},
		combat_def = 2,
		combat_armor = 5,
		fatigue = 3,
		resists = { [DamageType.BLIGHT] = 10},
		inc_damage = { [DamageType.BLIGHT] = 10},
		resists_pen = { [DamageType.BLIGHT] = 10},
		disease_immune=0.3,
		talents_types_mastery = { ["corruption/vim"] = 0.1, },
		combat_atk = 8,
		see_invisible = 12,
		see_stealth = 12,
	},
	max_power = 32, power_regen = 1,
	use_talent = { id = Talents.T_VIMSENSE, level = 3, power = 25 },
}

newEntity{ base = "BASE_KNIFE",
	power_source = {arcane=true},
	unique = true,
	name = "Umbral Razor", image = "object/artifact/dagger_silent_blade.png",
	unided_name = "shadowy dagger",
	kr_display_name = "음영의 면도날", kr_unided_name = "그림자 단검",
	desc = [[이 단검은 순수한 그림자로 이루어진 것 같고, 이상한 독기가 주변으로 퍼집니다.]],
	level_range = {12, 25},
	rarity = 200,
	require = { stat = { dex=32 }, },
	cost = 250,
	material_level = 2,
	combat = {
		dam = 20,
		apr = 10,
		physcrit = 8,
		dammod = {dex=0.45,str=0.35, mag=0.15},
		convert_damage = {
			[DamageType.DARKNESS] = 50,
		},
	},
	wielder = {
		inc_stealth=8,
		inc_stats = {[Stats.STAT_MAG] = 3,},
		resists = {[DamageType.DARKNESS] = 10,},
		inc_damage = {[DamageType.DARKNESS] = 5,},
	},
	max_power = 10, power_regen = 1,
	use_talent = { id = Talents.T_INVOKE_DARKNESS, level = 2, power = 8 },
}


newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {technique=true},
	unique = true,
	name = "Emblem of Evasion", color = colors.GOLD,
	unided_name = "gold coated emblem", image = "object/artifact/emblem_of_evasion.png",
	kr_display_name = "회피의 문장", kr_unided_name = "금도금된 문장",
	desc = [[공격 회피의 명수가 가지고 있던 것이라 알려진 이 금박 강철 문장은 그 기술의 상징입니다.]],
	level_range = {8, 18},
	rarity = 200,
	cost = 50,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_LCK] = 2, [Stats.STAT_DEX] = 5, [Stats.STAT_CUN] = 3,},
		slow_projectiles = 15,
		combat_def_ranged = 8,
	},
	max_power = 40, power_regen = 1,
	use_talent = { id = Talents.T_EVASION, level = 2, power = 40 },
}

newEntity{ base = "BASE_LONGBOW",
	power_source = {technique=true},
	name = "Surefire", unided_name = "high-quality bow", unique=true, image = "object/artifact/surefire.png",
	kr_display_name = "확실한 발사", kr_unided_name = "고품질 활",
	desc = [[이 팽팽한 시위는 신뢰할만한 기술을 가진 자가 만든 것이라는 것을 보여줍니다. 시위를 당기면, 그 속에 담긴 강력한 힘이 느껴집니다.]],
	level_range = {5, 15},
	rarity = 200,
	require = { stat = { dex=18 }, },
	cost = 20,
	use_no_energy = true,
	material_level = 1,
	combat = {
		range = 9,
		physspeed = 0.75,
	},
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = 5, },
		inc_stats = { [Stats.STAT_DEX] = 3},
		combat_atk=12,
		combat_physcrit=5,
		apr = 10,
	},
	max_power = 8, power_regen = 1,
	use_talent = { id = Talents.T_STEADY_SHOT, level = 2, power = 8 },
}

newEntity{ base = "BASE_SHOT",
	power_source = {arcane=true},
	unique = true,
	name = "Frozen Shards", image = "object/artifact/frozen_shards.png",
	unided_name = "pouch of crystallized ice",
	kr_display_name = "얼어붙은 파편", kr_unided_name = "얼음 결정 뭉치",
	desc = [[이 검푸른 주머니에는 여러개의 작은 얼음구가 들어 있습니다. 신비한 수증기가 그 주변을 감싸고있고, 건드리면 뼛속까지 시립니다.]],
	color = colors.BLUE,
	level_range = {25, 40},
	rarity = 300,
	cost = 110,
	material_level = 4,
	require = { stat = { dex=28 }, },
	combat = {
		capacity = 6,
		dam = 32,
		apr = 15,
		physcrit = 10,
		dammod = {dex=0.7, cun=0.5},
		damtype = DamageType.ICE,
		special_on_hit = {desc="얼음 구름 발사",on_kill=1, fct=function(combat, who, target)
			local duration = 4
			local radius = 1
			local dam = (10 + who:getMag()/5 + who:getDex()/3)
			game.level.map:particleEmitter(target.x, target.y, radius, "iceflash", {radius=radius})
			-- Add a lasting map effect
			game.level.map:addEffect(who,
				target.x, target.y, duration,
				engine.DamageType.ICE, dam,
				radius,
				5, nil,
				{type="ice_vapour"},
				function(e)
					e.radius = e.radius
					return true
				end,
				false
			)
		end},
	},
}

newEntity{ base = "BASE_WHIP",
	power_source = {arcane=true},
	unided_name = "electrified whip",
	name = "Stormlash", color=colors.BLUE, unique = true, image = "object/artifact/stormlash.png",
	kr_display_name = "폭풍채찍", kr_unided_name = "전기 채찍",
	desc = [[이 강철편 채찍에는 강렬한 전기가 흐르고 있습니다. 제어할 수 없는 폭발적이고 강력한 힘입니다.]],
	require = { stat = { dex=15 }, },
	cost = 90,
	rarity = 250,
	level_range = {6, 15},
	material_level = 1,
	combat = {
		dam = 15,
		apr = 7,
		physcrit = 5,
		dammod = {dex=1},
		convert_damage = {[DamageType.LIGHTNING] = 50,},
	},
	wielder = {
		combat_atk = 7,
	},
	max_power = 10, power_regen = 1,
	use_power = { name = "3칸 안 쪽의 적 공격 및 전기 폭발", power = 10,
		use = function(self, who)
			local dam = 20 + who:getMag()/2 + who:getDex()/3
			local tg = {type="bolt", range=3}
			local blast = {type="ball", range=0, radius=1, selffire=false}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			local _ _, x, y = who:canProject(tg, x, y)
			local target = game.level.map(x, y, engine.Map.ACTOR)
			if not target then return end
			who:attackTarget(target, engine.DamageType.LIGHTNING, 1, true)
			local _ _, x, y = who:canProject(tg, x, y)
			game.level.map:particleEmitter(who.x, who.y, math.max(math.abs(x-who.x), math.abs(y-who.y)), "lightning", {tx=x-who.x, ty=y-who.y})
			who:project(blast, x, y, engine.DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
			game.level.map:particleEmitter(x, y, radius, "ball_lightning", {radius=blast.radius})
			game:playSoundNear(self, "talents/lightning")
			game.logSeen(who, "%s 전기 뭉치를 보내 %s 공격했습니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), (target.kr_display_name or target.name):addJosa("를"))
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_WHIP",
	power_source = {psionic=true},
	unided_name = "gemmed whip handle",
	name = "Focus Whip", color=colors.YELLOW, unique = true, image = "object/artifact/focus_whip.png",
	kr_display_name = "집중의 채찍", kr_unided_name = "보석박힌 채찍 손잡이",
	desc = [[손잡이의 끝부분에 작은 마석이 박혀있습니다. 건드려보면 의지에 따라 움직이는 반투명한 끈이 나타납니다.]],
	require = { stat = { dex=15 }, },
	cost = 90,
	rarity = 250,
	level_range = {18, 28},
	material_level = 3,
	combat = {
		is_psionic_focus=true,
		dam = 19,
		apr = 7,
		physcrit = 5,
		dammod = {dex=0.7, wil=0.2, cun=0.1},
		wil_attack = true,
		damtype=DamageType.MIND,
	},
	wielder = {
		combat_mindpower = 8,
		combat_mindcrit = 3,
	},
	max_power = 10, power_regen = 1,
	use_power = { name = "직선상의 모든 목표 공격", power = 10,
		use = function(self, who)
			local tg = {type="beam", range=4}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				who:attackTarget(target, engine.DamageType.MIND, 1, true)
			end)
			local _ _, x, y = who:canProject(tg, x, y)
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "matter_beam", {tx=x-who.x, ty=y-who.y})
			game:playSoundNear(self, "talents/lightning")
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Latafayn",
	unided_name = "flame covered greatsword", image = "object/artifact/latafayn.png",
	kr_display_name = "라타파인", kr_unided_name = "불꽃덮힌 대검",
	level_range = {32, 40},
	color=colors.DARKRED,
	rarity = 300,
	desc = [[이 거대한 불꽃덮힌 대검은 아주 옛날에 영웅 케스틴 하이핀이 강력한 악마로부터 훔친 것입니다. 이것은 끊임없이 생명력을 빼앗고 불태울 대상을 찾고 있습니다.]],
	cost = 400,
	require = { stat = { str=40 }, },
	material_level = 4,
	combat = {
		dam = 44,
		apr = 5,
		physcrit = 10,
		dammod = {str=1.2},
		convert_damage={[DamageType.FIREBURN] = 50,},
		melee_project={[DamageType.DRAINLIFE] = 25},
	},
	wielder = {
		resists = {
			[DamageType.FIRE] = 15,
		},
		inc_damage = {
			[DamageType.FIRE] = 15,
			[DamageType.DARKNESS] = 10,
		},
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_CUN] = 3 },
	},
	max_power = 25, power_regen = 1,
	use_power = {name="불타기 촉진 및 모든 지속화염 피해의 125%만큼 즉시 피해유발", power = 25, --wherein Pure copies Catalepsy
	use=function(combat, who, target)
		local tg = {type="ball", range=5, radius=1, selffire=false}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end

		local source = nil
		who:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			-- List all diseases, I mean, burns
			local burns = {}
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.fire and p.power and e.status == "detrimental" then
					burns[#burns+1] = {id=eff_id, params=p}
				end
			end
			-- Make them EXPLODE !!!
			for i, d in ipairs(burns) do
				target:removeEffect(d.id)
				engine.DamageType:get(engine.DamageType.FIRE).projector(who, px, py, engine.DamageType.FIRE, d.params.power * d.params.dur * 1.25)
			end
			game.level.map:particleEmitter(target.x, target.y, 1, "ball_fire", {radius=1})
		end)
		game:playSoundNear(who, "talents/fireflash")
		return {id=true, used=true}
	end},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {psionic=true},
	unique = true,
	name = "Robe of Force", color = colors.YELLOW, image = "object/artifact/robe_of_force.png",
	unided_name = "rippling cloth robe",
	kr_display_name = "기세의 로브", kr_unided_name = "물결치는 로브",
	desc = [[이 얇은 로브는 진동하는 염동력의 덮개로 싸여있습니다.]],
	level_range = {20, 28},
	rarity = 190,
	cost = 250,
	material_level = 2,
	wielder = {
		combat_def = 12,
		combat_armor = 8,
		inc_stats = { [Stats.STAT_CUN] = 3, [Stats.STAT_WIL] = 4, },
		combat_mindpower = 8,
		combat_mindcrit = 4,
		combat_physresist = 10,
		inc_damage={[DamageType.PHYSICAL] = 5, [DamageType.MIND] = 5,},
		resists_pen={[DamageType.PHYSICAL] = 10, [DamageType.MIND] = 10,},
		resists={[DamageType.PHYSICAL] = 12, [DamageType.ACID] = 15,},
	},
	max_power = 10, power_regen = 1,
	use_power = { name = "동역학적 에너지 빔 발사", power = 10,
		use = function(self, who)
			local dam = 15 + who:getWil()/3 + who:getCun()/3
			local tg = {type="beam", range=5}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, engine.DamageType.MINDKNOCKBACK, who:mindCrit(rng.avg(0.8*dam, dam)))
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "matter_beam", {tx=x-who.x, ty=y-who.y})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {nature=true},
	unique = true,
	name = "Serpent's Glare", image = "object/artifact/serpents_glare.png",
	unided_name = "venomous gemstone",
	kr_display_name = "뱀의 노려보기", kr_unided_name = "유독성 원석",
	level_range = {1, 10},
	color=colors.GREEN,
	rarity = 180,
	desc = [[이 마석에서는 짙은 독액이 흐릅니다.]],
	cost = 40,
	require = { stat = { wil=12 }, },
	material_level = 1,
	combat = {
		dam = 7,
		apr = 15,
		physcrit = 7,
		dammod = {wil=0.30, cun=0.1},
		damtype = DamageType.NATURE,
		convert_damage={[DamageType.POISON] = 30,}
	},
	wielder = {
		combat_mindpower = 5,
		combat_mindcrit = 5,
		poison_immune = 0.5,
		resists = {
			[DamageType.NATURE] = 10,
		}
	},
	max_power = 8, power_regen = 1,
	use_talent = { id = Talents.T_SPIT_POISON, level = 2, power = 8 },
}

--[=[ seems to generate more bugs than it's worth
newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {psionic=true},
	unique = true,
	name = "The Inner Eye", image = "object/artifact/the_inner_eye.png",
	unided_name = "engraved marble eye",
	kr_display_name = "내부의 눈", kr_unided_name = "조각된 대리석 눈",
	level_range = {24, 32},
	color=colors.WHITE,
	encumber = 1,
	rarity = 140,
	desc = [[이 대리석 눈이 박힌 두꺼운 안대는 시야를 차단하는 대신 착용자가 주변을 감지할 수 있도록 만들어 준다고 합니다.
그 효과로부터 회복되는데 시간이 필요한 것이 좀 의심스럽습니다.]],
	cost = 200,
	material_level=3,
	wielder = {
		combat_def=3,
		esp_range=-3,
		esp_all=1,
		blind=1,
		combat_mindpower=6,
		combat_mindcrit=4,
		blind_immune=1,
		blind_sight=1, -- So we can see walls, objects, and what not nearby and not break auto-explore.
		combat_mentalresist = 12,
		resists = {[DamageType.LIGHT] = 10,},
		resists_cap = {[DamageType.LIGHT] = 10,},
		resists_pen = {all=5, [DamageType.MIND] = 10,}
	},
	on_wear = function(self, who)
		game.logPlayer(who, "#CRIMSON#시야가 흐려집니다!")
		who:resetCanSeeCache()
		if who.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
	end,
}
]=]

newEntity{ base = "BASE_LONGSWORD", define_as="CORPUS",
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Corpathus", image = "object/artifact/corpus.png",
	unided_name = "bound sword",
	kr_display_name = "코르파투스", kr_unided_name = "구속된 검",
	desc = [[이 칼날은 두꺼운 가죽끈으로 감겨 있습니다. 칼등 부분은 이빨같은 톱니 모양으로 생겼습니다. 가죽끈을 벗어나기 위해 노력하지만, 그 힘이 모자란 것 같습니다.]],
	level_range = {20, 30},
	rarity = 250,
	require = { stat = { str=40, }, },
	cost = 300,
	material_level = 4,
	combat = {
		dam = 40,
		apr = 12,
		physcrit = 4,
		dammod = {str=1,},
		melee_project={[DamageType.DRAINLIFE] = 18},
		special_on_kill = {desc="극적인 힘의 성장", fct=function(combat, who, target)
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "CORPUS")
			if not o or not who:getInven(inven_id).worn then return end
			who:onTakeoff(o, true)
			o.combat.physcrit = (o.combat.physcrit or 0) + 2
			o.wielder.combat_critical_power = (o.wielder.combat_critical_power or 0) + 4
			who:onWear(o, true)
			if not rng.percent(o.combat.physcrit*0.8) or o.combat.physcrit < 30 then return end
			o.summon(o, who)
		end},
		special_on_crit = {desc="힘의 성장", fct=function(combat, who, target)
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "CORPUS")
			if not o or not who:getInven(inven_id).worn then return end
			who:onTakeoff(o, true)
			o.combat.physcrit = (o.combat.physcrit or 0) + 1
			o.wielder.combat_critical_power = (o.wielder.combat_critical_power or 0) + 2
			who:onWear(o, true)
			if not rng.percent(o.combat.physcrit*0.8) or o.combat.physcrit < 30 then return end
			o.summon(o, who)
		end},
	},
	summon=function(o, who)
		o.cut=nil
		o.combat.physcrit=6
		o.wielder.combat_critical_power = 0
		game.logSeen(who, "몸체가 폭발하며 열리고, 무서운 덩어리가 풀려납니다!")
		local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "horror", subtype = "eldritch",
				display = "h",
				name = "Vilespawn", color=colors.GREEN,
				kr_display_name = "역겨운 덩어리",
				image="npc/horror_eldritch_oozing_horror.png",
				desc = "부패한 슬라임 덩어리가 몸체로부터 분출되었고, 그것은 당신을 죽이려 하는 것 같습니다.",
				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, },
				rank = 2,
				life_rating = 8, exp_worth = 0,
				max_vim=200,
				max_life = resolvers.rngavg(50,90),
				infravision = 20,
				autolevel = "dexmage",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=2, ally_compassion=0},
				stats = { str=15, dex=18, mag=18, wil=15, con=10, cun=18 },
				level_range = {10, nil}, exp_worth = 0,
				silent_levelup = true,
				combat_armor = 0, combat_def = 24,
				combat = { dam=resolvers.rngavg(10,13), atk=15, apr=15, dammod={mag=0.5, dex=0.5}, damtype=engine.DamageType.BLIGHT, },

				resists = { [engine.DamageType.BLIGHT] = 100, [engine.DamageType.NATURE] = -100, },

				on_melee_hit = {[engine.DamageType.DRAINLIFE]=resolvers.mbonus(10, 30)},
				melee_project = {[engine.DamageType.DRAINLIFE]=resolvers.mbonus(10, 30)},

				resolvers.talents{
					[who.T_DRAIN]={base=1, every=7, max = 10},
					[who.T_SPIT_BLIGHT]={base=1, every=6, max = 9},
					[who.T_VIRULENT_DISEASE]={base=1, every=9, max = 7},
					[who.T_BLOOD_FURY]={base=1, every=8, max = 6},
				},
				resolvers.sustains_at_birth(),
				faction = "enemies",
			}

			m:resolve()

			game.zone:addEntity(game.level, m, "actor", x, y)
	end,
	wielder = {
		inc_damage={[DamageType.BLIGHT] = 5,},
		combat_critical_power = 0,
		cut_immune=-0.25,
		max_vim=20,
	},

}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true, psionic=true},
	unique = true,
	name = "Anmalice", image = "object/artifact/anima.png", define_as = "ANIMA",
	unided_name = "twisted blade",
	kr_display_name = "적의없음", kr_unided_name = "뒤틀린 칼날",
	desc = [[이 칼날의 손잡이에 달린 눈이 당신을 영혼과 정신까지 꿰뚫어 노려보고 있는 것 같습니다. 손잡이에서 촉수가 뻗어나와 당신의 손을 붙잡고 떨어지지 않습니다.]],
	level_range = {30, 40},
	rarity = 250,
	require = { stat = { str=32, wil=20, }, },
	cost = 300,
	material_level = 4,
	combat = {
		dam = 38,
		apr = 20,
		physcrit = 7,
		dammod = {str=0.8,wil=0.2},
		damage_convert = {[DamageType.MIND]=20,},
		special_on_hit = {desc="여러가지 정신 효과로 목표를 괴롭히기", fct=function(combat, who, target)
			if not who:checkHit(who:combatMindpower(), target:combatMentalResist()*0.9) then return end
			target:setEffect(target.EFF_WEAKENED_MIND, 2, {power=18})
			if not rng.percent(40) then return end
			local eff = rng.table{"stun", "malign", "agony", "confusion", "silence",}
			if not target:canBe(eff) then return end
			if not who:checkHit(who:combatMindpower(), target:combatMentalResist()) then return end
			if eff == "stun" then target:setEffect(target.EFF_MADNESS_STUNNED, 3, {})
			elseif eff == "malign" then target:setEffect(target.EFF_MALIGNED, 3, {resistAllChange=10})
			elseif eff == "agony" then target:setEffect(target.EFF_AGONY, 5, { source=who, damage=40, mindpower=40, range=10, minPercent=10, duration=5})
			elseif eff == "confusion" then target:setEffect(target.EFF_CONFUSED, 3, {power=60})
			elseif eff == "silence" then target:setEffect(target.EFF_SILENCED, 3, {})
			end
		end},
		special_on_kill = {desc="정신내성 손실 감소", fct=function(combat, who, target)
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "ANIMA")
			if not o or not who:getInven(inven_id).worn then return end
			if o.wielder.combat_mentalresist >= 0 then return end
			o.skipfunct=1
			who:onTakeoff(o, true)
			o.wielder.combat_mentalresist = (o.wielder.combat_mentalresist or 0) + 2
			who:onWear(o, true)
			o.skipfunct=nil
		end},
	},
	wielder = {
		combat_mindpower=8,
		combat_mentalresist=-30,
		inc_damage={
			[DamageType.MIND] = 8,
		},
	},
	sentient=true,
	act = function(self)
		self:useEnergy()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by=nil return end
		if self.worn_by:attr("dead") then return end
		local who = self.worn_by
			local blast = {type="ball", range=0, radius=2, selffire=false}
			who:project(blast, who.x, who.y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				if not rng.percent(20) then return end
				if not who:checkHit(who:combatMindpower(), target:combatMentalResist()) then return end
				target:setEffect(target.EFF_WEAKENED_MIND, 2, {power=5})
				game.logSeen(who, "칼날의 눈이 %s의 정신까지 꿰뚫고 그를 노려봅니다!", (target.kr_display_name or target.name):capitalize())
			end)
	end,
	on_takeoff = function(self, who)
		if self.skipfunct then return end
		self.worn_by=nil
		who:removeParticles(self.particle)
		if self.wielder.combat_mentalresist == 0 then
			game.logPlayer(who, "#CRIMSON#촉수가 만족하면서 팔에서 풀려납니다.")
		else
			game.logPlayer(who, "#CRIMSON#팔에서 촉수를 찢어내자, 정신 속으로 끔찍한 모습이 떠오릅니다!")
			who:setEffect(who.EFF_WEAKENED_MIND, 15, {power=25})
			who:setEffect(who.EFF_AGONY, 5, { source=who, damage=15, mindpower=40, range=10, minPercent=10, duration=5})
		end
		self.wielder.combat_mentalresist = -30
	end,
	on_wear = function(self, who)
		if self.skipfunct then return end
		self.particle = who:addParticles(engine.Particles.new("gloom", 1))
		self.worn_by = who
		game.logPlayer(who, "#CRIMSON#이 검을 쥐자, 촉수가 손잡이에서 나와 팔을 감쌉니다. 검의 의지가 당신의 정신에 침범하는 것을 느낍니다!")
	end,
}

newEntity{ base = "BASE_WHIP", define_as = "HYDRA_BITE",
	slot_forbid = "OFFHAND",
	offslot = false,
	twohanded=true,
	power_source = {technique=true, nature=true},
	unique = true,
	name = "Hydra's Bite", color = colors.LIGHT_RED, image = "object/artifact/hydras_bite.png",
	unided_name = "triple headed flail",
	kr_display_name = "히드라의 물기", kr_unided_name = "머리 세개달린 도리깨",
	desc = [[이 머리 세개달린 스트라라이트 도리깨는 히드라의 힘을 담아 공격합니다. 한번 후려치면, 주변의 모두를 공격합니다.]],
	level_range = {32, 40},
	rarity = 250,
	require = { stat = { str=40 }, },
	cost = 650,
	material_level = 4,
	running = 0, --For the on hit
	combat = {
		dam = 56,
		apr = 7,
		physcrit = 14,
		dammod = {str=1.1},
		convert_damage = {[DamageType.NATURE]=25,[DamageType.ACID]=25,[DamageType.LIGHTNING]=25},
		special_on_hit = {desc="인접한 두 적을 공격",on_kill=1, fct=function(combat, who, target)
				local o, item, inven_id = who:findInAllInventoriesBy("define_as", "HYDRA_BITE")
				if not o or not who:getInven(inven_id).worn then return end
				local tgts = {}
				local twohits=1
				for _, c in pairs(util.adjacentCoords(who.x, who.y)) do
				local targ = game.level.map(c[1], c[2], engine.Map.ACTOR)
				if targ and targ ~= target and who:reactionToward(target) < 0 then tgts[#tgts+1] = targ end
				end
				if #tgts == 0 then return end
					local target1 = rng.table(tgts)
					local target2 = rng.table(tgts)
					local tries = 0
				while target1 == target2 and tries < 100 do
					local target2 = rng.table(tgts)
					tries = tries + 1
				end
				if o.running == 1 then return end
				o.running = 1
				if tries >= 100 or #tgts==1 then twohits=nil end
				if twohits then
					game.logSeen(who, "%s의 머리 세개달린 도리깨가 %s %s 후려칩니다!", (who.kr_display_name or who.name):capitalize(), (target1.kr_display_name or target1.name):capitalize():addJosa("와"),(target2.kr_display_name or target2.name):capitalize():addJosa("를"))
				else
					game.logSeen(who, "%s의 머리 세개달린 도리깨가 %s 후려칩니다!", (who.kr_display_name or who.name):capitalize(), (target1.kr_display_name or target1.name):capitalize():addJosa("를"))
				end
				who:attackTarget(target1, engine.DamageType.PHYSICAL, 0.4,  true)
				if twohits then who:attackTarget(target2, engine.DamageType.PHYSICAL, 0.4,  true) end
				o.running=0
		end},
	},
	wielder = {
		inc_damage={[DamageType.NATURE]=8,[DamageType.ACID]=8,[DamageType.LIGHTNING]=8,},

	},
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {technique=true, antimagic=true},
	define_as = "GAUNTLETS_SPELLHUNT",
	unique = true,
	name = "Spellhunt Remnants", color = colors.GREY, image = "object/artifact/spellhunt_remnants.png",
	unided_name = "rusted voratun gauntlets",
	kr_display_name = "마법사냥의 유물", kr_unided_name = "녹슨 보라툰 전투장갑",
	desc = [[한때는 빛나는 보라툰 전투장갑이었지만 이제는 많이 노화되었습니다. 원래는 마법사냥에 사용되던 것으로, 마법걸린 아트팩트를 부수어 세상에 그들이 끼친 영향을 치유하는데에도 자주 사용되었습니다.]],
	level_range = {1, 25}, --Relevent at all levels, though of course mat level 1 limits it to early game.
	rarity = 450, -- But rare to make it not ALWAYS appear.
	cost = 1000,
	material_level = 1,
	wielder = {
		combat_mindpower=4,
		combat_mindcrit=1,
		combat_spellresist=4,
		combat_def=1,
		combat_armor=2,
		combat = {
			dam = 12,
			apr = 4,
			physcrit = 3,
			physspeed = 0.2,
			dammod = {dex=0.4, str=-0.6, cun=0.4,},
			damrange = 0.3,
			melee_project={[DamageType.RANDOM_SILENCE] = 10},
			talent_on_hit = { [Talents.T_DESTROY_MAGIC] = {level=1, chance=100} },
		},
	},
	power_up= function(self, who, level)
		local Stats = require "engine.interface.ActorStats"
		local Talents = require "engine.interface.ActorTalents"
		local DamageType = require "engine.DamageType"
		who:onTakeoff(self, true)
		self.wielder=nil
		if level==2 then -- LEVEL 2
		self.desc = [[한때는 빛나는 보라툰 전투장갑이었지만 이제는 노화되었습니다. 원래는 마법사냥에 사용되던 것으로, 마법걸린 아트팩트를 부수어 세상에 그들이 끼친 영향을 치유하는데에도 자주 사용되었습니다.]]
		self.wielder={
			combat_mindpower=6,
			combat_mindcrit=2,
			combat_spellresist=6,
			combat_def=2,
			combat_armor=3,
			combat = {
				dam = 17,
				apr = 8,
				physcrit = 6,
				physspeed = 0.2,
				dammod = {dex=0.4, str=-0.6, cun=0.4,},
				damrange = 0.3,
				melee_project={[DamageType.RANDOM_SILENCE] = 12},
				talent_on_hit = { [Talents.T_DESTROY_MAGIC] = {level=2, chance=100} },
			},
		}
		elseif  level==3 then -- LEVEL 3
		self.desc = [[이 보라툰 전투장갑은 많은 고생으로 손상되었습니다. 원래는 마법사냥에 사용되던 것으로, 마법걸린 아트팩트를 부수어 세상에 그들이 끼친 영향을 치유하는데에도 자주 사용되었습니다.]]
		self.wielder={
			combat_mindpower=8,
			combat_mindcrit=3,
			combat_spellresist=8,
			combat_def=3,
			combat_armor=4,
			combat = {
				dam = 22,
				apr = 12,
				physcrit = 8,
				physspeed = 0.2,
				dammod = {dex=0.4, str=-0.6, cun=0.4,},
				damrange = 0.3,
				melee_project={[DamageType.RANDOM_SILENCE] = 15, [DamageType.MANABURN] = 20,},
				talent_on_hit = { [Talents.T_DESTROY_MAGIC] = {level=3, chance=100} },
			},
		}
		elseif  level==4 then -- LEVEL 4
		self.desc = [[이 보라툰 전투장갑은 착용하면 그 속에서 밝게 빛나는 층이 발생합니다. 원래는 마법사냥에 사용되던 것으로, 마법걸린 아트팩트를 부수어 세상에 그들이 끼친 영향을 치유하는데에도 자주 사용되었습니다.]]
		self.wielder={
			combat_mindpower=10,
			combat_mindcrit=4,
			combat_spellresist=10,
			combat_def=4,
			combat_armor=5,
			combat = {
				dam = 27,
				apr = 15,
				physcrit = 10,
				physspeed = 0.2,
				dammod = {dex=0.4, str=-0.6, cun=0.4,},
				damrange = 0.3,
				melee_project={[DamageType.RANDOM_SILENCE] = 17, [DamageType.MANABURN] = 35,},
				talent_on_hit = { [Talents.T_DESTROY_MAGIC] = {level=4, chance=100} },
			},
		}
		elseif  level==5 then -- LEVEL 5
		self.desc = [[이 빛나는 보라툰 전투장갑은 다른세상의 것 같은 빛을 발하고 있습니다. 원래는 마법사냥에 사용되던 것으로, 마법걸린 아트팩트를 부수어 세상에 그들이 끼친 영향을 치유하는데에도 자주 사용되었습니다. 당신은 이 고대의 임무를 수행한 것에 자부심을 가집니다.]]
		self.wielder={
			combat_mindpower=12,
			combat_mindcrit=5,
			combat_spellresist=15,
			combat_def=6,
			combat_armor=8,
			lite=1,
			combat = {
				dam = 33,
				apr = 18,
				physcrit = 12,
				physspeed = 0.2,
				dammod = {dex=0.4, str=-0.6, cun=0.4,},
				damrange = 0.3,
				melee_project={[DamageType.RANDOM_SILENCE] = 20, [DamageType.MANABURN] = 50,},
				talent_on_hit = { [Talents.T_DESTROY_MAGIC] = {level=5, chance=100} },
			},
		}
		self.use_power.name = "5칸 이내 원뿔영역의 마법 파괴"
		self.use_power.power = 100
		self.use_power.use= function(self,who)
			local tg = {type="cone", range=0, radius=5}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_SPELL_DISRUPTION, 10, {src=who, power = 50, max = 75, apply_power=who:combatMindpower()})
				for i = 1, 2 do
					local effs = {}
					-- Go through all spell effects
					for eff_id, p in pairs(target.tmp) do
						local e = target.tempeffect_def[eff_id]
						if e.type == "magical" then
							effs[#effs+1] = {"effect", eff_id}
						end
					end
					-- Go through all sustained spells
					for tid, act in pairs(target.sustain_talents) do
						if act then
							local talent = target:getTalentFromId(tid)
							if talent.is_spell then effs[#effs+1] = {"talent", tid} end
						end
					end
					local eff = rng.tableRemove(effs)
					if eff then
						if eff[1] == "effect" then
						target:removeEffect(eff[2])
						else
							target:forceUseTalent(eff[2], {ignore_energy=true})
						end
					end
				end
				if target.undead or target.construct then
					who:project({type="hit"}, target.x, target.y, engine.DamageType.ARCANE,100+who:combatMindpower())
					if target:canBe("stun") then target:setEffect(target.EFF_STUNNED, 10, {apply_power=who:combatMindpower()}) end
					game.logSeen(who, "%s에게 생명을 불어넣은 마법이 힘의 폭발로 방해받습니다!", (who.kr_display_name or who.name):capitalize())
				end
			end, nil, {type="slime"})
			game:playSoundNear(who, "talents/breath")
			return {id=true, used=true}
		end
		end

		who:onWear(self, true)
	end,
	max_power = 150, power_regen = 1,
	use_power = { name = "(전투장갑보다 높은 단계의) 마법적 물건 파괴", power = 1, use = function(self, who, obj_inven, obj_item)
		local d = who:showInventory("어느 물건을 부숩니까?", who:getInven("INVEN"), function(o) return o.unique and o.power_source and o.power_source.arcane and o.power_source.arcane and o.power_source.arcane == true and o.material_level and o.material_level > self.material_level end, function(o, item, inven)
			if o.material_level <= self.material_level then return end
			self.material_level=o.material_level
			game.logPlayer(who, "당신이 %s 부수자, 발생한 빛이 장갑 속으로 흡수됩니다!", o:getName{do_color=true}:addJosa("를"))

			if not o then return end
			who:removeObject(who:getInven("INVEN"), item)
			who:sortInven(who:getInven("INVEN"))

			self.power_up(self, who, self.material_level)

			who.changed=true
		end)
	end },
}

newEntity{ base = "BASE_LONGBOW",
	power_source = {arcane=true},
	name = "Merkul's Second Eye", unided_name = "sleek stringed bow", unique=true, image = "object/artifact/merkuls_second_eye.png",
	kr_display_name = "메르쿨의 두번째 눈", kr_unided_name = "윤기나는 시위걸린 활",
	desc = [[이 활은 악명높은 드워프 첩자의 도구로 알려져 있습니다. 소문에 따르면, 이것은 그 적의 눈을 훔칠 수 있게 만들어 준다고 합니다. Adversaries struck were left alive, only to unknowingly divulge their secrets to his unwavering sight.]], --@@ 번역 필요
	level_range = {20, 38},
	rarity = 250,
	require = { stat = { dex=24 }, },
	cost = 200,
	material_level = 3,
	combat = {
		range = 9,
		physspeed = 0.8,
		travel_speed = 4,
		talent_on_hit = { [Talents.T_ARCANE_EYE] = {level=4, chance=100} },
	},
	wielder = {
		lite = 2,
		ranged_project = {[DamageType.ARCANE] = 25},
	},
}

newEntity{ base = "BASE_AMULET", --Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Mirror Shards",
	unided_name = "mirror lined chain", image = "object/artifact/mirror_shards.png",
	kr_display_name = "거울 파편", kr_unided_name = "거울을 늘어놓은 사슬",
	desc = [[강력한 마법사가 마법폭풍에 따른 폭도로 고향이 파괴되자 만든 것으로 알려져 있습니다. 그는 도망쳤지만, 그의 소유물은 부서지고 찌부러지고 불타올랐습니다. 그가 폐허로 돌아왔을 때, 그는 남아있던 부서진 거울로 이 부적을 만들었다고 합니다.]],
	color = colors.LIGHT_RED,
	level_range = {18, 30},
	rarity = 220,
	cost = 350,
	material_level = 3,
	wielder = {
		inc_damage={
			[DamageType.LIGHT] = 10,
		},
		resists={
			[DamageType.LIGHT] = 20,
		},
		lite=1,
		on_melee_hit = {[DamageType.RANDOM_BLIND]=10},
	},
	max_power = 24, power_regen = 1,
	use_power = { name = "반사 보호막 생성 (반사율 50%)", power = 24,
		use = function(self, who)
			who:setEffect(who.EFF_DAMAGE_SHIELD, 5, {power=50 + who:getMag(100), reflect=50})
			game:playSoundNear(who, "talents/arcane")
			game.logSeen(who, "%s 반사 보호막을 만들었습니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"))
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_SHIELD",
	power_source = {nature=true},
	unique = true,
	name = "Summertide",
	unided_name = "shining gold shield", image = "object/artifact/summertide.png",
	kr_display_name = "밀려오는 여름", kr_unided_name = "빛나는 황금 방패",
	level_range = {38, 50},
	color=colors.GOLD,
	rarity = 350,
	desc = [[이 방패의 중심에서 밝은 빛이 빛나고 있습니다. 이 방패를 쥐면 정신이 맑아집니다.]],
	cost = 280,
	require = { stat = { wil=28, str=20, }, },
	material_level = 5,
	special_combat = {
		dam = 52,
		block = 260,
		physcrit = 4.5,
		dammod = {str=1},
		damtype = DamageType.LIGHT,
		special_on_hit = {desc="빛뭉치 발사", fct=function(combat, who, target)
			local tg = {type="ball", range=0, radius=1, selffire=false}
			local grids = who:project(tg, target.x, target.y, engine.DamageType.LITE_LIGHT, 30 + who:getWil()*0.5)
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "ball_light", {radius=tg.radius})
		end},
		melee_project = {[DamageType.RANDOM_BLIND]=20},
	},
	wielder = {
		combat_armor = 5,
		combat_def = 17,
		combat_def_ranged = 17,
		fatigue = 12,
		combat_mindpower = 8,
		combat_mentalresist=18,
		blind_immune=1,
		confusion_immune=0.25,
		lite=3,
		max_psi=20,
		inc_damage={
			[DamageType.MIND] 	= 15,
			[DamageType.LIGHT] 	= 15,
			[DamageType.FIRE] 	= 10,
		},
		resists={
			[DamageType.LIGHT] 		= 20,
			[DamageType.DARKNESS] 	= 15,
			[DamageType.MIND] 		= 12,
			[DamageType.FIRE] 		= 10,
		},
		resists_pen={
			[DamageType.LIGHT] 	= 10,
			[DamageType.MIND] 	= 10,
			[DamageType.FIRE] 	= 10,
		},
		learn_talent = { [Talents.T_BLOCK] = 5, },
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 3, },
	},
	max_power = 30, power_regen = 1,
	use_power = { name = "빛줄기 발사", power = 12,
		use = function(self, who)
			local dam = 20 + who:getWil()/3 + who:getCun()/3
			local tg = {type="beam", range=7}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			
			who:project(tg, x, y, engine.DamageType.LITE_LIGHT, who:mindCrit(rng.avg(0.8*dam, dam)))
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "light_beam", {tx=x-who.x, ty=y-who.y})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LEATHER_BOOT", 
	power_source = {psionic=true},
	unique = true,
	name = "Wanderer's Rest", image = "object/artifact/wanderers_rest.png",--Thanks Grayswandir! (just for the name this time!)
	unided_name = "weightless boots",
	kr_display_name = "방랑자의 휴식처", kr_unided_name = "가벼운 신발",
	desc = [[이 신발은 거의 무게가 느껴지지 않습니다. 건드려보면, 굉장히 무거운 짐도 들수 있을것 같은 느낌이 듭니다.]],
	encumber=0,
	color = colors.YELLOW,
	level_range = {17, 28},
	rarity = 200,
	cost = 100,
	material_level = 3,
	wielder = {
		combat_def = 4,
		fatigue = -10,
		mindpower=4,
		inc_stats = { [Stats.STAT_DEX] = 3, },
		movement_speed=0.25,
		pin_immune=1,
		resists={
			[DamageType.PHYSICAL] = 5,
		},
	},
	max_power = 18, power_regen = 1,
	use_talent = { id = Talents.T_TELEKINETIC_LEAP, level = 4, power = 15 },
}

newEntity{ base = "BASE_CLOTH_ARMOR", --Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Silk Current", color = colors.BLUE, image = "object/artifact/silk_current.png",
	unided_name = "flowing robe",
	kr_display_name = "비단 해류", kr_unided_name = "흐르는 로브",
	desc = [[이 짙은 푸른색 로브는 보이지 않는 조류가 미는 것처럼 흔들거리고 물결치고 있습니다.]],
	level_range = {1, 15},
	rarity = 220,
	cost = 250,
	material_level = 1,
	wielder = {
		combat_def = 12,
		combat_spellpower = 4,
		
		inc_damage={[DamageType.COLD] = 10},
		resists={[DamageType.COLD] = 15},
		resists_pen={[DamageType.COLD] = 8},
		on_melee_hit={[DamageType.COLD] = 10,},
		
		movement_speed=0.15,
		talents_types_mastery = {
 			["spell/water"] = 0.1,
 		},
	},
}

newEntity{ base = "BASE_WHIP", --Thanks Grayswandir!
	power_source = {arcane=true},
	unided_name = "bone-link chain",
	name = "Skeletal Claw", color=colors.GREEN, unique = true, image = "object/artifact/skeletal_claw.png",
	kr_display_name = "골격 발톱", kr_unided_name = "뼈라 이어진 사슬",
	desc = [[이 채찍은 인간의 척추로 만들어진 것처럼 보입니다. 한쪽 끝에는 손잡이가 달려있고, 다른 쪽에는 날카롭게 갈려진 발톱이 달려있습니다.]],
	require = { stat = { dex=14 }, },
	cost = 150,
	rarity = 325,
	level_range = {4, 12},
	material_level = 1,
	combat = {
		dam = 13,
		apr = 8,
		physcrit = 5,
		dammod = {dex=1},
		melee_project={[DamageType.BLEED] = 15},
		burst_on_crit = {
			[DamageType.BLEED] = 20,
		},
	},
	max_power = 24, power_regen = 1,
	use_talent = { id = Talents.T_BONE_GRAB, level = 2, power = 24 },
	talent_on_spell = { {chance=10, talent=Talents.T_BONE_GRAB, level=1} },
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic=true},
	unique = true,
	name = "Core of the Forge", image = "object/artifact/core_of_the_forge.png",
	unided_name = "fiery mindstar",
	kr_display_name = "대장간의 핵심", kr_unided_name = "불같은 마석",
	level_range = {38, 50},
	color=colors.RED, image = "object/artifact/nexus_of_the_way.png",
	rarity = 350,
	desc = [[이 불타는 뜨거운 마석은 율동적으로 고동치며, 부딪힐 때마다 뜨거운 폭발이 발생합니다.]],
	cost = 280,
	require = { stat = { wil=40 }, },
	material_level = 5,
	combat = {
		dam = 24,
		apr = 40,
		physcrit = 5,
		dammod = {wil=0.6, cun=0.2},
		damtype = DamageType.DREAMFORGE,
	},
	wielder = {
		combat_mindpower = 14,
		combat_mindcrit = 8,
		combat_atk=10,
		combat_dam=10,
		inc_damage={
			[DamageType.MIND] 		= 10,
			[DamageType.PHYSICAL] 	= 10,
			[DamageType.FIRE] 		= 10,
		},
		resists={
			[DamageType.MIND] 		= 5,
			[DamageType.PHYSICAL] 	= 5,
			[DamageType.FIRE] 		= 15,
		},
		resists_pen={
			[DamageType.MIND] 		= 10,
			[DamageType.PHYSICAL] 	= 10,
		},
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 3, },
		talents_types_mastery = {
			["psionic/dream-forge"] = 0.2,
			["psionic/dream-smith"] = 0.2,
		},
		melee_project={[DamageType.DREAMFORGE] = 30,},
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_FORGE_BELLOWS, level = 3, power = 24 },
}

newEntity{ base = "BASE_LEATHER_BOOT", --Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Aetherwalk", image = "object/artifact/aether_walk.png",
	unided_name = "ethereal boots",
	kr_display_name = "에테르 걸음", kr_unided_name = "천상의 신발",
	desc = [[성긴 보라빛 오러가 이 검고 투명한 신발 주변을 감쌉니다.]],
	color = colors.PURPLE,
	level_range = {30, 40},
	rarity = 200,
	cost = 100,
	material_level = 4,
	wielder = {
		combat_def = 4,
		fatigue = 1,
		spellpower=4,
		inc_stats = { [Stats.STAT_MAG] = 5, },
		resists={
			[DamageType.ARCANE] = 10,
		},
		resists_cap={
			[DamageType.ARCANE] = 5,
		},
	},
	max_power = 24, power_regen = 1,
	use_power = { name = "근거리 순간이동 (거리6, 반경2)", power = 24,
		use = function(self, who)
			local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=6, radius=2, requires_knowledge=false}
			x, y = who:getTarget(tg)
			if not x then return nil end
			-- Target code does not restrict the target coordinates to the range, it lets the project function do it
			-- but we cant ...
			local _ _, x, y = who:canProject(tg, x, y)

			-- Check LOS
			local rad = 2
			if not who:hasLOS(x, y) and rng.percent(35 + (game.level.map.attrs(who.x, who.y, "control_teleport_fizzle") or 0)) then
				game.logPlayer(who, "근거리 순간이동의 문이 파직거리며 누더기가 되고, 임의의 위치로 동작합니다!")
				x, y = who.x, who.y
				rad = tg.range
			end

			game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
			who:teleportRandom(x, y, rad)
			game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
			
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_GREATSWORD", -- Thanks Alex!
	power_source = {arcane=true},
	unique = true,
	name = "Colaryem",
	unided_name = "floating sword", image = "object/artifact/colaryem.png",
	kr_display_name = "콜라리엠", kr_unided_name = "떠있는 검",
	level_range = {16, 36},
	color=colors.BLUE,
	rarity = 300,
	desc = [[이 이상한 검은 터무니없이 길고 폭은 몸만큼 넓지만, 그 크기와는 모순적으로 무게가 가벼운 정도가 아니라 쥐면 날아 다닐 수 있을 듯한 기분이 듭니다. 이 검을 땅으로 내리기 위해서는 아주 힘이 강하거나 아주 덩치가 커야 합니다.]],
	cost = 400,
	require = { stat = { str=10 }, },
	sentient=true,
	material_level = 3,
	combat = {
		dam = 45,
		apr = 5,
		physcrit = 10,
		dammod = {str=1.2},
		physspeed=2,
	},
	wielder = {
		resists = { [DamageType.LIGHTNING] = 7 },
		inc_damage = { [DamageType.LIGHTNING] = 7, },
		movement_speed = 0.07,
		inc_stats = { [Stats.STAT_DEX] = 5 },
		max_encumber = 40,
		fatigue = -12,
		avoid_pressure_traps = 1,
	},
	act = function(self)
		self:useEnergy()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by=nil return end
		if self.worn_by:attr("dead") then return end
		
		local size = self.worn_by.size_category-3
		local str = self.worn_by:getStr()
		self.combat.physspeed=util.bound(2-(str-10)*0.02-size*0.1, 0.8, 2)
	end,
	on_wear = function(self, who)
		self.worn_by = who
		
		local size = self.worn_by.size_category-3
		local str = self.worn_by:getStr()
		self.combat.physspeed=util.bound(2-(str-10)*0.02-size*0.1, 0.8, 2)
	end,
	on_takeoff = function(self, who)
		self.worn_by = nil
		self.combat.physspeed=2
	end,
}

newEntity{ base = "BASE_ARROW", --Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Void Quiver",
	unided_name = "etheral quiver",
	kr_display_name = "공허의 전통", kr_unided_name = "천상의 전통",
	desc = [[이 짙은 검정 전통에서는 끝없이 화살이 나옵니다. 그 표면에 작은 빛나는 흰 점이 박혀 있습니다.]],
	color = colors.BLUE, image = "object/artifact/void_quiver.png",
	level_range = {35, 50},
	rarity = 300,
	cost = 100,
	material_level = 5,
	infinite=true,
	require = { stat = { dex=32 }, },
	combat = {
		capacity = 0,
		dam = 45,
		apr = 10,
		physcrit = 3,
		dammod = {dex=0.7, str=0.5},
		damtype = DamageType.VOID,
	},
}

newEntity{ base = "BASE_ARROW", --Thanks Grayswandir!
	power_source = {nature=true},
	unique = true,
	name = "Hornet Stingers", image = "object/artifact/hornet_stingers.png",
	unided_name = "sting tipped arrows",
	kr_display_name = "말벌의 독침", kr_unided_name = "독침이 촉으로 박힌 화살",
	desc = [[이 화살의 촉에서는 지독한 독액이 흐릅니다.]],
	color = colors.BLUE,
	level_range = {10, 20},
	rarity = 200,
	cost = 100,
	material_level = 2,
	require = { stat = { dex=18 }, },
	combat = {
		capacity = 8,
		dam = 20,
		apr = 10,
		physcrit = 5,
		dammod = {dex=0.7, str=0.5},
		ranged_project={
			[DamageType.CRIPPLING_POISON] = 10,
		},
	},
}

newEntity{ base = "BASE_LITE", --Thanks Frumple!
	power_source = {psionic=true},
	unique = true,
	name = "Umbraphage", image="object/artifact/umbraphage.png",
	unided_name = "deep black lantern",
	kr_display_name = "움브라페이즈", kr_unided_name = "짙은 검정 랜턴",
	level_range = {20, 30},
	color=colors.BLACK,
	rarity = 240,
	desc = [[이 창백한 흰 수정 랜턴은 빛을 내뿜는 어둠의 구체가 고정되어 있습니다. 모든 곳이 빛나고, 어둠은 완전히 사라집니다.]],
	cost = 320,
	material_level=3,
	sentient=true,
	charge = 0,
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self, who)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		if self.power < self.max_power then -- Charge up activate event
			self.power=self.power + 1
		end
		
		local who=self.worn_by --Make sure you can actually act!
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		
		
		who:project({type="ball", range=0, radius=self.wielder.lite}, who.x, who.y, function(px, py) -- The main event!
			local is_lit = game.level.map.lites(px, py)
			if is_lit then return end
			
			if not self.max_charge then
			
				self.charge = self.charge + 1
				
				if self.charge == 200 then
					self.max_charge=true
					game.logPlayer(who, "움브라페이즈가 완전히 충전되었습니다!")
				end
			
			end
		end)
		who:project({type="ball", range=0, radius=self.wielder.lite}, who.x, who.y, engine.DamageType.LITE, 100) -- Light the space!
		if (5 + math.floor(self.charge/20)) > self.wielder.lite and self.wielder.lite < 10 then
			who:onTakeoff(self, true)
			self.wielder.lite = math.min(10, 5+math.floor(self.charge/20))
			who:onWear(self, true)
		end
	end,
	wielder = {
		lite = 5,
		combat_mindpower=10,
		combat_mentalresist=10,
		
		inc_damage = {[DamageType.LIGHT]=15, [DamageType.DARKNESS]=15},
		resists = {[DamageType.DARKNESS]=20},
		resists_pen = {[DamageType.DARKNESS]=10},
		damage_affinity={
			[DamageType.DARKNESS] = 20,
		},
		talents_types_mastery = {
			["cursed/shadows"] = 0.2,
		}
	},
	max_power = 10, power_regen = 1,
	use_power = { name = "흡수된 어둠 방출", power = 10,
		use = function(self, who)
			if self.max_charge then self.charge=300 end -- Power boost if you fully charged :)
			local dam = (15 + who:combatMindpower()*0.8) * 0.5+math.floor(self.charge/50) -- Damage is based on charge
			local tg = {type="cone", range=0, radius=self.wielder.lite} -- Radius of Cone is based on lite radius of the artifact
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			
			who:project(tg, x, y, engine.DamageType.DARKNESS, who:mindCrit(dam)) -- FIRE!
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "breath_dark", {radius=tg.radius, tx=x-who.x, ty=y-who.y})
			self.max_charge=nil -- Reset charge.
			self.charge=0
			
			who:onTakeoff(self, true)
			self.wielder.lite = 5
			who:onWear(self, true)
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_KNIFE", -- Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Spellblaze Shard", image = "object/artifact/spellblaze_shard.png",
	unided_name = "crystalline dagger",
	kr_display_name = "마법폭발 파편", kr_unided_name = "수정 단검",
	desc = [[이 톱니 모양의 수정은 자연적이지 않은 빛을 냅니다. 한쪽 끝은 손잡이로 쓰기위해 천으로 감겨있습니다.]],
	level_range = {12, 25},
	rarity = 200,
	require = { stat = { dex=17 }, },
	cost = 250,
	material_level = 2,
	combat = {
		dam = 20,
		apr = 10,
		physcrit = 12,
		dammod = {dex=0.45,str=0.45,},
		melee_project={[DamageType.FIREBURN] = 10, [DamageType.DRAINLIFE] = 10,},
		burst_on_crit = {
			[DamageType.CORRUPTED_BLOOD] = 20,
			[DamageType.FIRE] = 20,
		},
	},
	wielder = {
		inc_stats = {[Stats.STAT_MAG] = 5,},
		resists = {[DamageType.BLIGHT] = 10, [DamageType.FIRE] = 10},
	},
}

newEntity{ base = "BASE_LITE", --Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Spectral Cage", image="object/artifact/spectral_cage.png",
	unided_name = "ethereal blue lantern",
	kr_display_name = "유령의 우리", kr_unided_name = "천상의 푸른 랜턴",
	level_range = {20, 30},
	color=colors.BLUE,
	rarity = 240,
	desc = [[이 고대의 풍화된 랜턴은 창백한 푸른 빛을 냅니다. 건드려보면 둘러진 금속은 얼음같이 차갑습니다.]],
	cost = 320,
	material_level=3,
	wielder = {
		lite = 4,
		combat_spellpower=8,
		
		inc_damage = {[DamageType.COLD]=15},
		resists = {[DamageType.COLD]=20},
		resists_pen = {[DamageType.COLD]=10},
		
		talent_cd_reduction = {
			[Talents.T_CHILL_OF_THE_TOMB] = 2,
		},
	},
	max_power = 20, power_regen = 1,
	use_power = { name = "윌 오 위습 방출", power = 20,
		use = function(self, who)
			local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			local NPC = require "mod.class.NPC"
			local Talents = require "engine.interface.ActorTalents"
			local m = NPC.new{
				name = "will o' the wisp",
				kr_display_name = "윌 오 위습",
				type = "undead", subtype = "ghost",
				blood_color = colors.GREY,
				display = "G", color=colors.WHITE,
				combat = { dam=1, atk=1, apr=1 },
				autolevel = "warriormage",
				ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
				dont_pass_target = true,
				movement_speed = 2,
				stats = { str=14, dex=18, mag=20, con=12 },
				rank = 2,
				size_category = 1,
				infravision = 10,
				can_pass = {pass_wall=70},
				resists = {all = 35, [engine.DamageType.LIGHT] = -70, [engine.DamageType.COLD] = 65, [engine.DamageType.DARKNESS] = 65},
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
				will_o_wisp_dam = 100,
				resolvers.talents{[Talents.T_WILL_O__THE_WISP_EXPLODE] = 1,},
				
				faction = who.faction,
				summoner = who, summoner_gain_exp=true,
				summon_time = 20,
			}

			m:resolve()
			game.zone:addEntity(game.level, m, "actor", x, y)
			m.remove_from_party_on_death = true,
			game.party:addMember(m, {
				control=false,
				type="summon",
				title="Summon",
				orders = {target=true, leash=true, anchor=true, talents=true},
			})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {nature = true, antimagic=true},
	unique=true, rarity=240,
	type = "charm", subtype="totem",
	name = "The Guardian's Totem", image = "object/artifact/the_guardians_totem.png",
	unided_name = "cracked stone totem",
	kr_display_name = "수호자의 토템", kr_unided_name = "금이간 암석 토템",
	color = colors.GREEN,
	level_range = {40, 50},
	desc = [[이 고대의 암석 토템의 무수한 틈으로부터 짙은 점액이 스며나옵니다. 그럼에도 불구하고, 그 속에서 강력한 힘이 느껴집니다.]],
	cost = 320,
	material_level = 5,
	wielder = {
		resists={[DamageType.BLIGHT] = 20, [DamageType.ARCANE] = 20},
		on_melee_hit={[DamageType.SLIME] = 18},
		combat_spellresist = 20,
		talents_types_mastery = { ["wild-gift/antimagic"] = 0.1, ["wild-gift/fungus"] = 0.1},
		inc_stats = {[Stats.STAT_WIL] = 10,},
		combat_mindpower=8,
	},
		max_power = 35, power_regen = 1,
	use_power = { name = "반마법 기둥 소환", power = 35,
		use = function(self, who)
			local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "소환할 공간이 없습니다!")
				return
			end
			local Talents = require "engine.interface.ActorTalents"
			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				resolvers.nice_tile{image="invis.png", add_mos = {{image="terrain/darkgreen_moonstone_01.png", display_h=2, display_y=-1}}},
				name = "Stone Guardian",
				kr_display_name = "암석 수호자",
				type = "totem", subtype = "antimagic",
				desc = "이 거대한 암석 기둥에서는 끈끈한 점액이 흘러내립니다. 그것을 통해 자연의 힘이 흘러나오고, 주변의 모든 마법을 없앱니다..",
				rank = 3,
				blood_color = colors.GREEN,
				display = "T", color=colors.GREEN,
				life_rating=18,
				combat = {
					dam=resolvers.rngavg(50,60),
					atk=resolvers.rngavg(50,75), apr=25,
					dammod={wil=1.1}, physcrit = 10,
					damtype=engine.DamageType.SLIME,
				},
				level_range = {1, nil}, exp_worth = 0,
				silent_levelup = true,
				combat_armor=50,
				combat_armor_hardiness=70,
				autolevel = "wildcaster",
				ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
				never_move=true,
				stats = { str=14, dex=18, mag=10, con=12, wil=20, cun=20, },
				size_category = 5,
				blind=1,
				esp_all=1,
				resists={[engine.DamageType.BLIGHT] = 40, [engine.DamageType.ARCANE] = 40, [engine.DamageType.NATURE] = 70},
				no_breath = 1,
				cant_be_moved = 1,
				stone_immune = 1,
				confusion_immune = 1,
				fear_immune = 1,
				teleport_immune = 1,
				disease_immune = 1,
				poison_immune = 1,
				stun_immune = 1,
				blind_immune = 1,
				cut_immune = 1,
				knockback_resist,
				combat_mentalresist=50,
				combat_spellresist=100,
				on_act = function(self) self:project({type="ball", range=0, radius=5, selffire=false}, self.x, self.y, engine.DamageType.SILENCE, {dur=2, power_check=self:combatMindpower()}) end,
				resolvers.talents{
					[Talents.T_RESOLVE]={base=3, every=6},
					[Talents.T_MANA_CLASH]={base=3, every=5},
					[Talents.T_STUN]={base=3, every=4},
					[Talents.T_OOZE_SPIT]={base=5, every=4},
					[Talents.T_TENTACLE_GRAB]={base=1, every=6,},
				},
				
				faction = who.faction,
				summoner = who, summoner_gain_exp=true,
				summon_time=15,
			}

			m:resolve()
			game.zone:addEntity(game.level, m, "actor", x, y)
			m.remove_from_party_on_death = true,
			game.party:addMember(m, {
				control=false,
				type="summon",
				title="Summon",
				orders = {target=true, leash=true, anchor=true, talents=true},
			})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_CLOAK",
	power_source = {psionic=true},
	unique = true,
	name = "Cloth of Dreams", image = "object/artifact/cloth_of_dreams.png",
	unided_name = "tattered cloak",
	kr_display_name = "꿈의 의복", kr_unided_name = "누더기 망토",
	desc = [[이 초자연적인 직물로 만들어진 망토를 건드리면 졸림과 완전한 의식이 동시에 느껴집니다.]],
	level_range = {30, 40},
	rarity = 240,
	cost = 200,
	material_level = 4,
	wielder = {
		combat_def = 10,
		combat_mindpower = 6,
		combat_physresist = 10,
		combat_mentalresist = 10,
		combat_spellresist = 10,
		inc_stats = { [Stats.STAT_CUN] = 6, [Stats.STAT_WIL] = 5, },
		resists = { [DamageType.MIND] = 15 },
		lucid_dreamer=1,
		sleep=1,
		talents_types_mastery = { ["psionic/dreaming"] = 0.1, ["psionic/slumber"] = 0.1,},
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_SLUMBER, level = 3, power = 10 },
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {arcane=true},
	unique=true, rarity=240,
	type = "charm", subtype="wand",
	name = "Void Shard", image = "object/artifact/void_shard.png",
	unided_name = "strange jagged shape",
	kr_display_name = "공허의 파편", kr_unided_name = "이상한 톱니모양 조각",
	color = colors.GREY,
	level_range = {40, 50},
	desc = [[이 톱니모양의 조각은 공간의 구멍같아 보입니다. 아직은 단단하고 가볍습니다.]],
	cost = 320,
	material_level = 5,
	wielder = {
		resists={[DamageType.DARKNESS] = 10, [DamageType.TEMPORAL] = 10},
		inc_damage={[DamageType.DARKNESS] = 10, [DamageType.TEMPORAL] = 10},
		on_melee_hit={[DamageType.VOID] = 10},
		combat_spellresist = 12,
		inc_stats = {[Stats.STAT_MAG] = 7,},
		combat_spellpower=3,
	},
	max_power = 40, power_regen = 1,
	use_power = { name = "공허의 에너지탄 발사", power = 20,
		use = function(self, who)
			local tg = {type="ball", range=5, radius=2}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, engine.DamageType.VOID, 200 + who:getMag() * 2)
			game.level.map:particleEmitter(x, y, tg.radius, "shadow_flash", {radius=tg.radius, tx=x, ty=y})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR", -- Thanks SageAcrin!
	power_source = {technique = true, nature = true},
	unique = true,
	name = "Thalore-Wood Cuirass", image = "object/artifact/thalore_wood_cuirass.png",
	unided_name = "thick wooden plate armour",
	kr_display_name = "탈로레 나무 흉갑", kr_unided_name = "두꺼운 나무 판갑",
	desc = [[능숙하게 잘라낸 나무 껍질입니다. 이 나무 갑옷은 가볍지만 아주 훌륭한 방어력을 가지고 있습니다.]],
	color = colors.WHITE,
	level_range = {8, 22},
	rarity = 220,
	require = { stat = { str=24 }, },
	cost = 300,
	material_level = 2,
	encumber = 12,
	metallic=false,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 3, [Stats.STAT_DEX] = 3,},
		combat_armor = 10,
		combat_def = 4,
		fatigue = 14,
		resists = {
			[DamageType.DARKNESS] = 18,
			[DamageType.COLD] = 18,
			[DamageType.NATURE] = 18,
		},
		healing_factor = 0.25,
	},
}

newEntity{ base = "BASE_SHIELD", --Thanks SageAcrin!
	power_source = {nature=true},
	unided_name = "thick coral plate",
	name = "Coral Spray", unique=true, image = "object/artifact/coral_spray.png",
	kr_display_name = "산호 물보라", kr_unided_name = "두꺼운 산호 판",
	desc = [[톱니 모양의 산호 덩어리로, 대양에서 캐낸 것입니다.]],
	require = { stat = { str=16 }, },
	level_range = {1, 15},
	rarity = 200,
	cost = 60,
	material_level = 1,
	metallic = false,
	special_combat = {
		dam = 18,
		block = 48,
		physcrit = 2,
		dammod = {str=1.4},
		damrange = 1.4,
		melee_project = { [DamageType.COLD] = 10, },
	},
	wielder = {
		combat_armor = 8,
		combat_def = 8,
		fatigue = 12,
		resists = {
			[DamageType.COLD] = 15,
			[DamageType.FIRE] = 10,
		},
		learn_talent = { [Talents.T_BLOCK] = 2, },
		max_air = 20,
	},
	on_block = function(self, who, target, type, dam, eff)
		if rng.percent(30) then
			if not target or target:attr("dead") or not target.x or not target.y then return end

			local burst = {type="cone", range=0, radius=4, force_target=target, selffire=false,}
		
			who:project(burst, target.x, target.y, engine.DamageType.COLD, 30)
			game.level.map:particleEmitter(target.x, target.y, burst.radius, "breath_cold", {radius=burst.radius, tx=target.x-who.x, ty=target.y-who.y})
			game.logSeen(who, "%s의 방패에서 %s에게로 차가운 물줄기가 분출됩니다!", (who.kr_display_name or who.name):capitalize(), (target.kr_display_name or target.name):capitalize())
		end
	end,
}


newEntity{ base = "BASE_AMULET", --Thanks Grayswandir!
	power_source = {psionic=true},
	unique = true,
	name = "Shard of Insanity", color = colors.DARK_GREY, image = "object/artifact/shard_of_insanity.png",
	unided_name = "cracked black amulet",
	kr_display_name = "광기의 파편", kr_unided_name = "금간 검은 부적",
	desc = [[이 손상된 부적의 검은 돌로부터 짙은 빨간 빛이 나옵니다. 건드려보면, 정신속으로 속삭이는 목소리가 들립니다.]],
	level_range = {20, 32},
	rarity = 290,
	cost = 500,
	material_level = 3,
	wielder = {
		combat_mindpower = 6,
		combat_mentalresist = 32,
		confusion_immune=-1,
		inc_damage={
			[DamageType.MIND] 	= 20,
		},
		resists={
			[DamageType.MIND] 	= -10,
		},
		resists_pen={
			[DamageType.MIND] 	= 20,
		},
		on_melee_hit={[DamageType.RANDOM_CONFUSION] = 5},
	},
	max_power = 40, power_regen = 1,
	use_talent = { id = Talents.T_INNER_DEMONS, level = 2, power = 40 },
}


newEntity{ base = "BASE_SHOT", --Thanks Grayswandir!
	power_source = {psionic=true},
	unique = true,
	name = "Pouch of the Subconscious", image = "object/artifact/pouch_of_the_subconscious.png",
	unided_name = "familiar pouch",
	kr_display_name = "잠재의식의 투석뭉치", kr_unided_name = "친숙한 주머니",
	desc = [[이 이상한 투석뭉치를 사용하여 끊임없이 싸우고자하는 충동이 발생합니다.]],
	color = colors.RED, image = "object/artifact/star_shot.png",
	level_range = {25, 40},
	rarity = 300,
	cost = 110,
	material_level = 4,
	require = { stat = { dex=28 }, },
	combat = {
		capacity = 10,
		dam = 36,
		apr = 15,
		physcrit = 10,
		dammod = {dex=0.7, cun=0.5},
		ranged_project={
			[DamageType.MIND] = 20,
		},
		talent_on_hit = { [Talents.T_RELOAD] = {level=1, chance=50} },
	},
}

newEntity{ base = "BASE_SHOT", --Thanks Grayswandir!
	power_source = {nature=true},
	unique = true,
	name = "Wind Worn Shot", image = "object/artifact/wind_worn_shot.png",
	unided_name = "perfectly smooth shot",
	kr_display_name = "바람이 실린 투석", kr_unided_name = "완전히 부드러운 투석",
	desc = [[이 완전히 흰 구체는 강한 바람에 오랫동안 노출되어 닳은 것 같습니다.]],
	color = colors.RED, image = "object/artifact/star_shot.png",
	level_range = {25, 40},
	rarity = 300,
	cost = 110,
	material_level = 4,
	require = { stat = { dex=28 }, },
	combat = {
		capacity = 12,
		dam = 39,
		apr = 15,
		physcrit = 10,
		travel_speed = 1,
		dammod = {dex=0.7, cun=0.5},
		ranged_project={
			[DamageType.LIGHTNING] = 20,
		},
		talent_on_hit = { [Talents.T_TORNADO] = {level=2, chance=8} },
	},
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {nature=true, antimagic=true},
	name = "Spellcrusher", color = colors.GREEN, image = "object/artifact/spellcrusher.png",
	unided_name = "vine coated hammer", unique = true,
	kr_display_name = "마법분쇄기", kr_unided_name = "덩굴 감긴 망치",
	desc = [[이 커다란 강철 대형망치는 두꺼운 당쿨이 손잡이를 감고 있습니다.]],
	level_range = {10, 20},
	rarity = 300,
	require = { stat = { str=20 }, },
	cost = 650,
	material_level = 2,
	combat = {
		dam = 28,
		apr = 4,
		physcrit = 4,
		dammod = {str=1.2},
		melee_project={[DamageType.NATURE] = 20},
		special_on_hit = {desc="20% 확률로 마법 보호막 부수기", fct=function(combat, who, target)
			if not rng.percent(20) then return end
			if not target then return end

			-- List all diseases, I mean, burns, I mean, shields.
			local shields = {}
			for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
				if e.subtype.shield and p.power and e.type == "magical" then
					shields[#shields+1] = {id=eff_id, params=p}
				end
			end
			local is_shield = false
			-- Make them EXPLODE !!!, I mean, remove them.
			for i, d in ipairs(shields) do
				target:removeEffect(d.id)
				is_shield=true
			end
			
			if target:attr("disruption_shield") then
				target:forceUseTalent(target.T_DISRUPTION_SHIELD, {ignore_energy=true})
				is_shield = true
			end
			if is_shield == true then
				game.logSeen(target, "%s의 마법 보호막이 부서졌습니다!", (target.kr_display_name or target.name):capitalize())
			end
		end},
	},
	wielder = {
		inc_damage= {[DamageType.NATURE] = 10},
		combat_spellresist=10,
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"combat","melee_project"}, {[DamageType.MANABURN]=20})
			self:specialWearAdd({"wielder","resists"}, {[DamageType.ARCANE] = 10, [DamageType.BLIGHT] = 10})
			game.logPlayer(who, "#DARK_GREEN#내부에서 엄청난 힘이 솟아오르는 것이 느껴집니다!")
		end
	end,
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {psionic=true},
	unique=true, rarity=240,
	type = "charm", subtype="torque",
	name = "Telekinetic Core", image = "object/artifact/telekinetic_core.png",
	unided_name = "heavy torque",
	kr_display_name = "염력 응어리", kr_unided_name = "무거운 주술고리",
	color = colors.BLUE,
	level_range = {5, 20},
	desc = [[이 무거운 주술고리는 주변의 물질을 당기는 힘을 가지고 있습니다.]],
	cost = 320,
	material_level = 2,
	wielder = {
		resists={[DamageType.PHYSICAL] = 5,},
		inc_damage={[DamageType.PHYSICAL] = 6,},
		combat_physresist = 12,
		inc_stats = {[Stats.STAT_WIL] = 5,},
		combat_mindpower=3,
		combat_dam=3,
	},
	max_power = 35, power_regen = 1,
	use_talent = { id = Talents.T_PSIONIC_PULL, level = 2, power = 18 }, --Before you ask, DG, this is a blade horror talent.
}

newEntity{ base = "BASE_GREATSWORD", --Thanks Grayswandir!
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Spectral Blade", image = "object/artifact/spectral_blade.png",
	unided_name = "immaterial sword",
	kr_display_name = "유령의 칼날", kr_unided_name = "비물질 검",
	level_range = {10, 20},
	color=colors.GRAY,
	rarity = 300,
	desc = [[이 검은 무게가 없고 거의 투명합니다.]],
	cost = 400,
	require = { stat = { str=24, }, },
	material_level = 2,
	combat = {
		dam = 23,
		physspeed=0.9,
		apr = 4,
		physcrit = 3,
		dammod = {str=1.2},
		melee_project={[DamageType.ARCANE] = 10,},
	},
	wielder = {
		blind_fight = 1,
		see_invisible=10,
	},
}

newEntity{ base = "BASE_GLOVES", --Thanks SageAcrin /AND/ Edge2054!
	power_source = {technique=true, arcane=true},
	unique = true,
	name = "Crystle's Astral Bindings", --Yes, CRYSTLE. It's a name.
	unided_name = "crystalline gloves", image = "object/artifact/crystles_astral_bindings.png",
	kr_display_name = "수정의 별의 붕대", kr_unided_name = "수정 장갑",
	desc = [[잊혀진 아노리실이 가지고 있던 것으로, 이 다른세계의 붕대 표면에는 수많은 별이 나타납니다.]],
	level_range = {8, 20},
	rarity = 225,
	cost = 340,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 3 },
		combat_spellpower = 2,
		combat_spellcrit = 3,
		spellsurge_on_crit = 4,
		resists={[DamageType.DARKNESS] = 8, [DamageType.TEMPORAL] = 8},
		inc_damage={[DamageType.DARKNESS] = 8, [DamageType.TEMPORAL] = 8},
		negative_regen=0.2,
		combat = {
			dam = 12,
			apr = 3,
			physcrit = 6,
			dammod = {dex=0.4, str=-0.6, cun=0.4, mag=0.2 },
			convert_damage = {[DamageType.VOID] = 100,},
			talent_on_hit = { [Talents.T_SHADOW_SIMULACRUM] = {level=1, chance=8} },
		},
	},
	talent_on_spell = { {chance=10, talent=Talents.T_DESTABILIZE, level=1} },
}

newEntity{ base = "BASE_GEM", --Thanks SageAcrin and Graziel!
	power_source = {arcane=true},
	unique = true,
	unided_name = "cracked golem eye",
	name = "Prothotipe's Prismatic Eye", subtype = "multi-hued",
	kr_display_name = "프로쏘티페의 무지개빛 눈", kr_unided_name = "부서진 골렘 눈",
	color = colors.WHITE, image = "object/artifact/prothotipes_prismatic_eye.png",
	level_range = {18, 30},
	desc = [[이 부서진 원석은 오래되어 희미해졌습니다. 한때는 골렘의 눈으로 사용되던 것으로 보입니다.]],
	rarity = 240,
	cost = 200,
	identified = false,
	material_level = 3,
	wielder = {
		inc_stats = {[Stats.STAT_MAG] = 5, [Stats.STAT_CON] = 5, },
		inc_damage = {[DamageType.FIRE] = 10, [DamageType.COLD] = 10, [DamageType.LIGHTNING] = 10,  },
		talents_types_mastery = {
			["golem/arcane"] = 0.2,
		},
	},
	imbue_powers = {
		inc_stats = {[Stats.STAT_MAG] = 5, [Stats.STAT_CON] = 5, },
		inc_damage = {[DamageType.FIRE] = 10, [DamageType.COLD] = 10, [DamageType.LIGHTNING] = 10,  },
		talents_types_mastery = {
			["golem/arcane"] = 0.2,
		},
	},
	talent_on_spell = { {chance=10, talent=Talents.T_GOLEM_BEAM, level=2} },
}

newEntity{ base = "BASE_MASSIVE_ARMOR", --Thanks SageAcrin!
	power_source = {psionic=true},
	unique = true,
	name = "Plate of the Blackened Mind", image = "object/artifact/plate_of_the_blackened_mind.png",
	unided_name = "solid black breastplate",
	kr_display_name = "더러워진 정신의 판갑", kr_unided_name = "단단한 검은 흉갑",
	desc = [[이 짙은 검정 갑옷은 닿는 모든 빛을 흡수합니다. 그 속에는 근원적인 어두운 힘이 잠들어 있고, 아직 의식이 남아있습니다. 판갑을 건드리면, 정신 속으로 어둠이 기어들어오는 것이 느껴집니다.]],
	color = colors.BLACK,
	level_range = {40, 50},
	rarity = 390,
	require = { stat = { str=48 }, },
	cost = 800,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 4, [Stats.STAT_CON] = 3,},
		resists = {
			[DamageType.ACID] = 15,
			[DamageType.LIGHT] = 15,
			[DamageType.MIND] = 25,
			[DamageType.BLIGHT] = 20,
			[DamageType.DARKNESS] = 20,
		},
		combat_def = 15,
		combat_armor = 20,
		confusion_immune = 1,
		fear_immune = 1,
		combat_mentalresist = 25,
		combat_physresist = 15,
		combat_mindpower=10,
		lite = -2,
		infravision=4,
		fatigue = 17,
		talents_types_mastery = {
			["cursed/gloom"] = 0.2,
		},
		on_melee_hit={[DamageType.RANDOM_GLOOM] = 14}, --Thanks Edge2054!
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_DOMINATE, level = 2, power = 15 },
}

newEntity{ base = "BASE_TOOL_MISC", --Sorta Thanks Donkatsu!
	power_source = {nature = true},
	unique=true, rarity=220,
	type = "charm", subtype="totem",
	name = "Tree of Life", image = "object/artifact/tree_of_life.png",
	unided_name = "tree shaped totem",
	kr_display_name = "나무의 생명", kr_unided_name = "나무 모양의 토템",
	color = colors.GREEN,
	level_range = {40, 50},
	desc = [[이 작은 나무 모양의 토템에는 강력한 치유 에너지가 주입되어 있습니다.]],
	cost = 320,
	material_level = 4,
	sentient=true,
	wielder = {
		resists={[DamageType.BLIGHT] = 10, [DamageType.NATURE] = 10},
		inc_damage={[DamageType.NATURE] = 10},
		on_melee_hit={[DamageType.NATURE] = 10},
		talents_types_mastery = { ["wild-gift/call"] = 0.1, ["wild-gift/harmony"] = 0.1, },
		inc_stats = {[Stats.STAT_WIL] = 7, [Stats.STAT_CON] = 6,},
		combat_mindpower=7,
	},
	on_takeoff = function(self, who)
		self.worn_by=nil
		who:removeParticles(self.particle)
	end,
	on_wear = function(self, who)
		self.worn_by=who
		if core.shader.active(4) then
			self.particle = who:addParticles(engine.Particles.new("shader_ring_rotating", 1, {rotation=0, radius=4}, {type="flames", aam=0.5, zoom=3, npow=4, time_factor=4000, color1={0.2,0.7,0,1}, color2={0,1,0.3,1}, hide_center=0}))
		else
			self.particle = who:addParticles(engine.Particles.new("ultrashield", 1, {rm=0, rM=0, gm=180, gM=220, bm=10, bM=80, am=80, aM=150, radius=2, density=30, life=14, instop=17}))
		end
		game.logPlayer(who, "#CRIMSON#%s 착용하자, 강력한 치유의 오러가 주변을 감쌉니다.", self:getName():capitalize():addJosa("를"))
	end,
	act = function(self)
		self:useEnergy()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by=nil return end
		if self.worn_by:attr("dead") then return end
		local who = self.worn_by
		local blast = {type="ball", range=0, radius=2, selffire=true}
		who:project(blast, who.x, who.y, engine.DamageType.HEALING_NATURE, 3)
	end,
}

newEntity{ base = "BASE_RING",
	power_source = {technique=true, nature=true},
	name = "Ring of Growth", unique=true, image = "object/artifact/ring_of_growth.png",
	desc = [[이 작은 나무 반지는 하나의 녹색 줄기가 감겨있습니다. 가는 나뭇잎이 그 속으로부터 아직도 피어오르고 있습니다.]],
	unided_name = "vine encircled ring",
	kr_display_name = "성장의 반지", kr_unided_name = "덩쿨이 둘러진 반지",
	level_range = {6, 20},
	rarity = 250,
	cost = 500,
	material_level = 2,
	wielder = {
		combat_physresist = 8,
		inc_stats = {[Stats.STAT_WIL] = 4, [Stats.STAT_STR] = 4,},
		inc_damage={ [DamageType.PHYSICAL] = 4, [DamageType.NATURE] = 6,},
		resists={[DamageType.NATURE] = 10,},
		life_regen=0.15,
		healing_factor=0.2,
	},
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Wrap of Stone", image = "object/artifact/wrap_of_stone.png",
	unided_name = "solid stone cloak",
	kr_display_name = "암석 덮개", kr_unided_name = "단단한 암석 망토",
	desc = [[이 두꺼운 망토는 놀랄만큼 단단하지만 쉽게 구부러지고 흔들거립니다.]],
	level_range = {8, 20},
	rarity = 400,
	cost = 250,
	material_level = 2,
	wielder = {
		combat_spellpower=6,
		combat_armor=10,
		combat_armor_hardiness=20,
		talents_types_mastery = {
			["spell/earth"] = 0.2,
			["spell/stone"] = 0.1,
		},
		inc_damage={ [DamageType.PHYSICAL] = 5,},
		resists={ [DamageType.PHYSICAL] = 5,},
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_STONE_WALL, level = 1, power = 50 },
}

newEntity{ base = "BASE_LIGHT_ARMOR", --Thanks SageAcrin!
	power_source = {arcane=true},
	unided_name = "black leather armor",
	name = "Death's Embrace", unique=true, image = "object/artifact/deaths_embrace.png",
	kr_display_name = "죽음의 포옹", kr_unided_name = "검은 가죽 갑옷",
	desc = [[이 짙은 검은 가죽 갑옷은 두꺼운 비단으로 감싸져 있고, 건드리면 얼음같이 차갑습니다.]],
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level=5,
	wielder = {
		combat_spellpower = 10,
		combat_critical_power = 20,
		combat_def = 18,
		combat_armor = 18,
		combat_armor_hardiness=10,
		healing_factor=-0.1,
		melee_project={[DamageType.DARKNESS]=8, [DamageType.COLD]=8},
		on_melee_hit = {[DamageType.DARKNESS]=8, [DamageType.COLD]=8},
		inc_stealth=10,
 		inc_damage={
			[DamageType.DARKNESS] = 20,
			[DamageType.COLD] = 20,
 		},
 		resists={
			[DamageType.TEMPORAL] = 30,
			[DamageType.DARKNESS] = 30,
			[DamageType.COLD] = 30,
 		},
 		talents_types_mastery = {
 			["spell/phantasm"] = 0.1,
 			["spell/shades"] = 0.1,
			["cunning/stealth"] = 0.1,
 		},
	},
	max_power = 50, power_regen = 1,
	use_power = { name = "10턴간 투명화", power = 50,
		use = function(self, who)
			who:setEffect(who.EFF_INVISIBILITY, 10, {power=10+who:getCun()/6, penalty=0.5, regen=true})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR", --Thanks SageAcrin!
	power_source = {nature=true, antimagic=true},
	unided_name = "gauzy green armor",
	name = "Breath of Eyal", unique=true, image = "object/artifact/breath_of_eyal.png",
	kr_display_name = "에이알의 숨결", kr_unided_name = "얇은 녹색 갑옷",
	desc = [[이 가벼운 갑옷은 무수히 많은 새싹을 엮어 만든 것으로, 아직 성장하고 있습니다. 손으로 들면 아주 가볍지만, 착용하면 어깨에 세상의 무게가 느껴집니다.]],
	level_range = {40, 50},
	rarity = 250,
	cost = 300,
	material_level=5,
	wielder = {
		combat_spellresist = 20,
		combat_mindpower = 10,
		combat_def = 10,
		combat_armor = 10,
		fatigue = 20,
		resists = {
			[DamageType.ACID] = 20,
			[DamageType.LIGHTNING] = 20,
			[DamageType.FIRE] = 20,
			[DamageType.COLD] = 20,
			[DamageType.LIGHT] = 20,
			[DamageType.DARKNESS] = 20,
			[DamageType.BLIGHT] = 20,
			[DamageType.TEMPORAL] = 20,
			[DamageType.NATURE] = 20,
			[DamageType.ARCANE] = 15,
		},
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","resists"}, {all = 10})
			game.logPlayer(who, "#DARK_GREEN#남겨진 전 세계의 무게가 느껴집니다!")
		end
	end,
}

newEntity{ base = "BASE_TOOL_MISC", --Thanks Alex!
	power_source = {arcane=true},
	unique = true,
	name = "Eternity's Counter", color = colors.WHITE,
	unided_name = "crystalline hourglass", image="object/artifact/eternities_counter.png",
	kr_display_name = "영원의 시계", kr_unided_name = "수정 모래시계",
	desc = [[이 초자연적 수정의 모래시계 속에는 모래대신 셀수없이 많은 작은 원석으로 채워져 있습니다. 그것이 흐르면, 주변의 시가이 변하는 것을 느낄수 있습니다.]],
	level_range = {35, 40},
	rarity = 300,
	cost = 200,
	material_level = 5,
	direction=1,
	finished=false,
	sentient=true,
	metallic = false,
	wielder = {
		inc_damage = { [DamageType.TEMPORAL]= 15},
		resists = { [DamageType.TEMPORAL] = 15, all = 0, },
		movement_speed=0,
		combat_physspeed=0,
		combat_spellspeed=0,
		combat_mindspeed=0,
	},
	max_power = 20, power_regen = 1,
	use_power = { name = "모래시계 뒤집기", power = 20,
		use = function(self, who)
			self.direction = self.direction * -1
			self.finished = false
			who:onTakeoff(self, true)
			self.wielder.inc_damage.all = 0
			self.wielder.combat_def = 0
			who:onWear(self, true)
			game.logPlayer(who, "#GOLD#모래가 반대방향으로 천천히 떨어지기 시작합니다.")
		end
	},
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		if self.power < self.max_power then
			self.power=self.power + 1
		end
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by=nil return end
		if self.worn_by:attr("dead") then return end
		local who = self.worn_by
		local direction=self.direction
		if self.finished == true then return end
		who:onTakeoff(self, true)
		
		self.wielder.resists.all = self.wielder.resists.all + direction
		self.wielder.movement_speed = self.wielder.movement_speed + direction * 0.04
		self.wielder.combat_physspeed = self.wielder.combat_physspeed - direction * 0.04
		self.wielder.combat_spellspeed = self.wielder.combat_spellspeed - direction * 0.04
		self.wielder.combat_mindspeed = self.wielder.combat_mindspeed - direction * 0.04
		
		if self.wielder.resists.all == -5 then 
			self.wielder.inc_damage.all = 5
			game.logPlayer(who, "#GOLD#마지막 모래알이 떨어지자, 힘이 몰려오는 것을 느낍니다.")
			self.finished=true
		end
		if self.wielder.resists.all == 5 then 
			self.wielder.combat_def = 15
			game.logPlayer(who, "#GOLD#마지막 모래알이 떨어지자, 갑자기 안전해지는 것을 느낍니다.")
			self.finished=true
		end
		
		who:onWear(self, true)
	end,
}

newEntity{ base = "BASE_WIZARD_HAT", --Thanks SageAcrin!
	power_source = {arcane=true, psionic=true},
	unique = true,
	name = "Malslek the Accursed's Hat",
	unided_name = "black charred hat",
	kr_display_name = "저주받은 말슬렉의 모자", kr_unided_name = "검게 탄 모자",
	desc = [[이 검은 모자는 황혼의 시대에 다른 차원의 존재와 거래하는 법을 알고 있었던 강력한 마법사 말슬렉이 가지고 있던 것입니다. 특히, 그는 여러 강력한 악마들과 거래를 했었습니다. 하지만 그 중 하나가 지루함을 느끼고는 배신하고 그의 힘을 훔쳐갔습니다. 이에 분노한 말슬렉은 자신의 탑에 불을 질러 그 악마를 죽이려 했습니다. 이 불탄 모자는 그 폐허에 유일하게 남아있던 것입니다.]],
	color = colors.BLUE, image = "object/artifact/malslek_the_accursed_hat.png",
	level_range = {30, 40},
	rarity = 300,
	cost = 100,
	material_level = 4,
	wielder = {
		combat_def = 2,
		combat_mentalresist = -10,
		healing_factor=-0.1,
		combat_mindpower = 10,
		combat_spellpower = 10,
		combat_mindcrit=10,
		hate_on_crit = 2,
		hate_per_kill = 2,
		max_hate = 20,
		resists = { [DamageType.FIRE] = 15 },
		talents_types_mastery = {
			["cursed/punishments"]=0.2,
		},
		melee_project={[DamageType.RANDOM_GLOOM] = 10},
		inc_damage={
			[DamageType.DARKNESS] 	= 10,
			[DamageType.PHYSICAL]	= 10,
		},
	},
	talent_on_spell = { {chance=10, talent=Talents.T_AGONY, level=2} },
	talent_on_mind  = { {chance=10, talent=Talents.T_HATEFUL_WHISPER, level=2} },
}

newEntity{ base = "BASE_TOOL_MISC", --And finally, Thank you, Darkgod, for making such a wonderful game!
	power_source = {technique=true},
	unique=true, rarity=240,
	name = "Fortune's Eye", image = "object/artifact/fortunes_eye.png",
	unided_name = "golden telescope",
	kr_display_name = "행운의 눈", kr_unided_name = "황금 망원경",
	color = colors.GOLD,
	level_range = {28, 40},
	desc = [[이 잘 만들어진 망원경은 탐험가이자 모험가인 케스틴 하이핀이 가지고 있던 것입니다. 이 도구를 사용하여 그는 마즈'에이알의 보물들을 찾아 여행을 하였고, 죽기전까지 그는 놀랄만큼 막대한 보물을 모았다고 합니다. 그는 자주 이 망원경을 행운으로 여겼고, 그가 이것을 가진 동안 위험성에 상관없이 어떤 상황에서도 탈출 할 수 있도록 만들었다고 말했습니다. 그는 도둑맞은 검에 대한 복수를 위해 찾아온 악마와 마추쳐 죽었다고 알려져 있습니다. 

그의 마지막 유언은 다음과 같습니다 "어쨋든 이것이 마지막인 것처럼 느껴지지만, 아직도 찾을건 많이 남아있다는 걸 알고 있지."]],
	cost = 350,
	material_level = 4,
	wielder = {
		resists={[DamageType.PHYSICAL] = 4,},
		inc_damage={[DamageType.PHYSICAL] = 3,},
		
		inc_stats = {[Stats.STAT_LCK] = 5, [Stats.STAT_CUN] = 5,},
		combat_atk=12,
		combat_physresist = 10,
		combat_spellresist = 10,
		combat_mentalresist = 10,
		combat_def = 12,
		see_invisible = 12,
		see_stealth = 12,
	},
	max_power = 35, power_regen = 1,
	use_talent = { id = Talents.T_TRACK, level = 2, power = 18 },
}

--[=[
newEntity{
	unique = true,
	type = "jewelry", subtype="ankh",
	unided_name = "glowing ankh",
	name = "Anchoring Ankh",
	kr_display_name = "고정된 성물", kr_unided_name = "빛나는 성물",
	desc = [[성물을 집어들자, 안정가이 느껴집니다. 주변의 세상이 안정되게 느껴집니다.]],
	level_range = {15, 50},
	rarity = 400,
	display = "*", color=colors.YELLOW, image = "object/fireopal.png",
	encumber = 2,

	carrier = {

	},
}
]=]
