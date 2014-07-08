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

require "engine.krtrUtils"

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Penitence",
	flavor_name = "starstaff",
	unided_name = "glowing staff", image = "object/artifact/staff_penitence.png",
	level_range = {10, 18},
	color=colors.VIOLET,
	rarity = 200,
	kr_name = "참회", kr_unided_name = "빛나는 지팡이",
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
		damage_affinity={
			[DamageType.NATURE] = 20,
		},
	},
	max_power = 60, power_regen = 1,
	use_power = { name = "cure diseases and poisons", kr_name = "질병 및 중독 치료",power = 10,
		use = function(self, who)
			local target = who
			local effs = {}
			local known = false

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.disease or e.subtype.poison then
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
			game.logSeen(who, "%s의 질병과 중독이 치료되었습니다!", (who.kr_name or who.name):capitalize())
			return {id=true, used=true}
		end
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Shalore" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","resists"}, { [engine.DamageType.BLIGHT] = 10})
			self:specialWearAdd({"wielder","disease_immune"}, 0.5)
			game.logPlayer(who, "#DARK_GREEN#'참회'가 지닌 정화의 힘이 당신에게 깃드는 것이 느껴집니다.")
		end
	end,
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Lost Staff of Archmage Tarelion", image = "object/artifact/staff_lost_staff_archmage_tarelion.png",
	unided_name = "shining staff",
	flavor_name = "magestaff",
	level_range = {37, 50},
	color=colors.VIOLET,
	rarity = 250,
	kr_name = "마도사 타렐리온의 잃어버린 지팡이", kr_unided_name = "빛나는 지팡이",
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

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Spellblaze Echoes", color = colors.DARK_GREY, image = "object/artifact/amulet_spellblaze_echoes.png",
	unided_name = "deep black amulet",
	kr_name = "마법폭발의 메아리", kr_unided_name = "칠흑같이 새까만 목걸이",
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
	use_power = { name = "unleash a destructive wail", kr_name = "파괴의 통곡 방출", power = 60,
		use = function(self, who)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.DIG, 1)
			who:project({type="ball", range=0, selffire=false, radius=3}, who.x, who.y, engine.DamageType.PHYSICAL, 250 + who:getMag() * 3)
			game.logSeen(who, "%s uses the %s!", who.name:capitalize(), self:getName())
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {technique=true},
	unique = true,
	name = "Daneth's Neckguard", color = colors.STEEL_BLUE, image = "object/artifact/daneths_neckguard.png",
	unided_name = "a thick steel gorget",
	kr_name = "다네스의 목 보호대", kr_unided_name = "두꺼운 강철 목가리개",
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

newEntity{ base = "BASE_LONGBOW",
	power_source = {nature=true},
	name = "Thaloren-Tree Longbow", unided_name = "glowing elven-wood longbow", unique=true, image = "object/artifact/thaloren_tree_longbow.png",
	kr_name = "탈로레 나무 활", kr_unided_name = "빛나는 엘프나무 활",
	desc = [[마법폭발의 여파로 인해, 탈로레는 그들의 숲을 적과 불로부터 보호해야 했습니다. 엘프들은 노력했지만 많은 나무가 죽고 말았습니다. 이제 그들의 나무는 활로 가공되어, 어둠에 맞서기 위한 무기가 되었습니다.]],
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
		inc_damage={ [DamageType.PHYSICAL] = 30, },
		lite = 1,
		inc_stats = { [Stats.STAT_DEX] = 10, [Stats.STAT_WIL] = 10,  },
		ranged_project={[DamageType.LIGHT] = 30},
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Thalore" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","resists"}, { [engine.DamageType.DARKNESS] = 20, [DamageType.NATURE] = 20,} ) --@ 원래 코드가 뒤에만 "engine."이 없음 - 에러나면 추가해야 할 듯
			self:specialWearAdd({"wielder","combat_def"}, 12)
			game.logPlayer(who, "#DARK_GREEN#당신은 자연과 연결되어 있는 이 활로 할 수 있는 것들을 깨닫습니다.")
		end
	end,
}

-- Broken for its tier, Archery has very rarely had broken for its tier, its fine
newEntity{ base = "BASE_LONGBOW",
	power_source = {arcane=true, nature=true},
	name = "Corpsebow", unided_name = "rotting longbow", unique=true, image = "object/artifact/bow_corpsebow.png",
	kr_name = "시체활", kr_unided_name = "썩어가는 활",
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
		ranged_project = {
			[DamageType.ITEM_BLIGHT_DISEASE] = 40,
			[DamageType.BLIGHT] = 20
		}, -- ITEM_BLIGHT_DISEASE doesn't do damage, so this is big
		inc_damage={ [DamageType.BLIGHT] = 40, }, -- Hacky method of scaling the damage on the active because the diseases do no DPS
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_CYST_BURST, level = 5, power = 10 },
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Undead" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"combat","ranged_project"}, {[DamageType.DRAINLIFE]=20})
			game.logPlayer(who, "#DARK_BLUE#당신은 이 활 속에 있는 동족의 영혼을 느낍니다...")
		end
	end,
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Spellblade", image = "object/artifact/weapon_spellblade.png",
	unided_name = "glowing long sword",
	level_range = {40, 45},
	color=colors.AQUAMARINE,
	rarity = 250,
	kr_name = "마법칼날", kr_unided_name = "빛나는 장검",
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

-- 2H advantage:  Ridiculous item vs. Orc
newEntity{ base = "BASE_GREATSWORD",
	power_source = {nature=true, technique=true},
	unique = true,
	name = "Genocide",
	unided_name = "pitch black blade", image = "object/artifact/weapon_sword_genocide.png",
	level_range = {25, 35},
	color=colors.GRAY,
	rarity = 300,
	kr_name = "몰살", kr_unided_name = "칠흑같이 새까만 칼날",
	desc = [[토크놀 왕의 장군 파리안은 마지막 희망에서 벌어진 위대한 전투에서, 토크놀 왕 편에 서서 싸웠습니다. 하지만, 전투가 끝나고 고향으로 돌아온 그는 자신의 고향이 오크에 의해 완전히 불타버린 것을 보게 되었고, 이내 광기가 그를 덮쳤습니다. 복수심에 불타오른 그는 스스로 군대를 뛰쳐나와, 경갑과 검 한 자루만을 든 채 길을 나섰습니다. 많은 사람들이 그를 죽었다고 생각했지만, 그는 오크 야영지를 무너뜨렸다는 보고서 한 장으로 그에 대한 논쟁을 종식시켰습니다. 조사 결과, 그곳에 있던 모든 오크들은 무자비하게 난도질된 시체가 되어 있었습니다. 마즈'에이알에서 오크들이 모두 사라질 때까지, 그의 검은 매일 오크 100 마리의 피를 마셨다고 알려져 있습니다. 마지막 오크를 베고 더 이상 오크를 찾을 수 없게 되자, 파리안은 자신의 가슴에 그 칼날을 꽂아넣었습니다. 그가 죽을 때 그의 몸이 경련을 일으켰다고 알려져 있지만, 그가 웃고 있었는지 울고 있었는지는 알려져 있지 않습니다.]],
	cost = 400,
	require = { stat = { str=40, wil=20 }, },
	material_level = 3,
	combat = {
		dam = 42,
		apr = 4,
		physcrit = 18,
		dammod = {str=1.2},
		inc_damage_type = {["humanoid/orc"]=25},
	},
	wielder = {
		resists_actor_type = {["humanoid/orc"]=15},
		stamina_regen = 1,
		life_regen = 0.5,
		inc_stats = { [Stats.STAT_STR] = 7, [Stats.STAT_DEX] = 7, [Stats.STAT_CON] = 7 },
		esp = {["humanoid/orc"]=1},
	},
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Bolbum's Big Knocker", image = "object/artifact/staff_bolbums_big_knocker.png",
	unided_name = "thick staff",
	level_range = {20, 35},
	color=colors.UMBER,
	rarity = 220,
	kr_name = "볼붐의 큰 두드림", kr_unided_name = "두꺼운 지팡이",
	desc = [[끝부분에 무거운 장식이 달린 두꺼운 지팡이로, 매혹의 시대에 살았던 위대한 연금술사 볼붐이 사용하던 것으로 알려져 있습니다. 볼붐 밑에서 연금술을 연구하던 자들에게 있어, 볼붐은 높은 확률로 제자들에게 치명적인 두뇌 부상을 입히는 공포의 대상이었습니다. 결국 볼붐은 일곱 개의 단검이 등에 꽂혀 죽음을 맞이하였고, 그 이후로 그의 저주받은 지팡이 역시 사라졌다고 알려졌습니다.]],
	cost = 300,
	material_level = 3,

	require = { stat = { mag=38 }, },
	combat = {
		dam = 64,
		apr = 10,
		dammod = {mag=1.4},
		damtype = DamageType.PHYSICAL,
		melee_project={[DamageType.RANDOM_CONFUSION] = 10},
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
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_CHANNEL_STAFF, level = 2, power = 9 },
}

newEntity{ base = "BASE_LITE",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Guidance", image = "object/artifact/guidance.png",
	unided_name = "a softly glowing crystal",
	level_range = {38, 50},
	color = colors.YELLOW,
	encumber = 1,
	rarity = 300,
	kr_name = "길잡이", kr_unided_name = "부드럽게 빛나는 수정",
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

newEntity{ base = "BASE_SLING",
	power_source = {technique=true},
	unique = true,
	name = "Eldoral Last Resort", image = "object/artifact/sling_eldoral_last_resort.png",
	unided_name = "well-made sling",
	kr_name = "엘도랄에서의 마지막 휴양", kr_unided_name = "잘 만들어진 투석구",
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

newEntity{ base = "BASE_KNIFE",
	power_source = {technique=true},
	unique = true,
	name = "Orc Feller", image = "object/artifact/dagger_orc_feller.png",
	unided_name = "shining dagger",
	kr_name = "오크 살해자", kr_unided_name = "빛나는 단검",
	desc = [[엘도랄이 침략당할 때, 하플링 도둑 헤라는 난민들을 보호하기 위해 이 단검으로 백 마리가 넘는 오크를 베었다고 합니다.]],
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
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Stats = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","inc_stats"}, {  [Stats.STAT_CUN] = 6, [Stats.STAT_LCK] = 25, })
			game.logPlayer(who, "#LIGHT_BLUE#헤라의 후계자여, 그녀의 꾀와 운이 당신과 함께 할 것입니다!")
		end
	end,
}

newEntity{ base = "BASE_MACE",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Nature's Vengeance", color = colors.BROWN, image = "object/artifact/mace_natures_vengeance.png",
	unided_name = "thick wooden mace",
	kr_name = "자연의 복수", kr_unided_name = "두꺼운 나무 철퇴",
	desc = [[이 두꺼운 철퇴는, 마법사냥꾼 보를란이 마법폭발로 인해 뽑혀진 고대의 너도밤나무로 만들어 사용하던 것입니다. 많은 마법사와 마녀가 이 무기에 의해 쓰러졌으며, 이 무기는 자연에 범한 범죄를 처단하고 정의를 가져오기 위한 도구로 사용되었습니다.]],
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
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","resists"}, { all = 4 })

			game.logPlayer(who, "#LIGHT_BLUE#자연이 당신을 보호하는 것이 느껴집니다.")
		end
	end,
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {psionic=true, technique=true},
	define_as = "GAUNTLETS_SCORPION",
	unique = true,
	name = "Fists of the Desert Scorpion", color = colors.STEEL_BLUE, image = "object/artifact/scorpion_gauntlets.png",
	unided_name = "viciously spiked gauntlets",
	kr_name = "사막 전갈의 주먹", kr_unided_name = "가시 달린 날카로운 전투장갑",
	desc = [[이 사악한 생김새의 가시가 박힌 전투장갑은 장작더미의 시대에 서쪽 모래지대를 정복하고, 그곳을 기지로 삼아 남쪽의 엘발라로 대공세를 펼치던 오크 장군이 사용한 물건입니다. 전갈이란 별명으로 알려진 그를 전장에서는 아무도 억제할 수 없었습니다. 그는 정신력으로 적들을 근방으로 끌어당긴 뒤, 치명적인 공격으로 적들을 쓰러뜨렸습니다. 이 노랗고 검은 전투장갑의 질풍은 많은 위대한 샬로레 마법사들이 죽기 전에 마지막으로 본 것이 되었습니다.

전갈을 쓰러뜨리기 위해, 샬로레 연금술사 네씰리아가 극악무도한 오크들에게 홀로 대적하러 나왔습니다. 장군은 엘프를 무자비하게 끌어당겼지만, 그가 그녀의 목숨을 앗아가기 전에 그녀는 로브를 찢었고, 그녀의 몸에 묶여 있던 80 개의 소이탄이 드러났습니다. 그녀는 손가락에서 불꽃을 만들어 폭발을 유도했고, 그 폭발은 수 킬로미터 밖에서도 보일 정도로 컸다고 합니다. 사람들을 보호하기 위해 불멸의 삶을 버리고 스스로를 희생한 네씰리아는, 지금도 노래로 남아 사람들에게 기억되고 있습니다.]],
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
		talents_types_mastery = { ["technique/grappling"] = 0.2},
		combat = {
			dam = 24,
			apr = 10,
			physcrit = 10,
			physspeed = 0.15,
			dammod = {dex=0.4, str=-0.6, cun=0.4,},
			damrange = 0.3,
			talent_on_hit = { T_BITE_POISON = {level=3, chance=20}, T_PERFECT_CONTROL = {level=1, chance=5}, T_QUICK_AS_THOUGHT = {level=3, chance=5}, T_IMPLODE = {level=1, chance=5} },
		},
	},
	max_power = 24, power_regen = 1,
	use_talent = { id = Talents.T_MINDHOOK, level = 4, power = 16 },
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Wind's Whisper", image="object/artifact/cloak_winds_whisper.png",
	unided_name = "flowing light cloak",
	kr_name = "바람의 속삭임", kr_unided_name = "하늘거리는 가벼운 망토",
	desc = [[부여술사 라젠이 마법사냥꾼들에게 쫓겨 다이카라 산맥 부근에서 포위당했을 때, 그녀는 가지고 있던 망토를 두르고 좁은 협곡 아래로 도망쳤습니다. 사냥꾼들은 그 뒤에서 화살을 일제히 쏘았지만, 기적같이 모두 빗나갔습니다. 이렇게 라젠은 탈출에 성공했고, 서쪽의 숨겨진 도시로 도망쳤습니다.]],
	level_range = {15, 25},
	rarity = 400,
	cost = 250,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 3, },
		combat_def = 4,
		combat_ranged_def = 12,
		silence_immune = 0.3,
		slow_projectiles = 20,
		projectile_evasion = 25,
	},
	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_EVASION, level = 2, power = 50 },
}

newEntity{ base = "BASE_ROD",
	power_source = {arcane=true},
	unided_name = "glowing rod",
	name = "Gwai's Burninator", color=colors.LIGHT_RED, unique=true, image = "object/artifact/wand_gwais_burninator.png",
	kr_name = "과이의 불태우미", kr_unided_name = "달아오른 장대",
	desc = [[마법사냥 시절에 살았던 화염술사 과이는, 마법사냥꾼 무리에게 쫓기게 되었습니다. 그녀는 숨이 끊기는 그 순간까지 마법사냥꾼들과 싸웠고, 그녀가 쓰러지기 전까지 이 장대를 사용하여 10 명 이상의 목숨을 가져갔다고 알려졌습니다.]],
	cost = 600,
	rarity = 220,
	level_range = {25, 35},
	elec_proof = true,
	add_name = false,

	material_level = 3,

	max_power = 75, power_regen = 1,
	use_power = { name = "shoot a cone of fire", kr_name = "화염을 원뿔 영역으로 발사", power = 50,
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
	unided_name = "viciously sharp battle axe",
	name = "Drake's Bane", image = "object/artifact/axe_drakes_bane.png",
	color = colors.RED,
	kr_name = "용 살해자", kr_unided_name = "굉장히 날카로운 대형도끼",
	desc = [[가장 강력한 용 크롤타르를 죽이는 데에는 일곱 달의 시간과 20,000 명이 넘는 드워프 전사의 생명이 필요했습니다. 마침내 그 짐승이 지쳐 쓰러지자, 동료들의 시체로 쌓은 탑 위에 선 최고의 대장장이 그룩심이 용의 피부를 뚫기위해 만든 이 도끼로 용의 목에 큰 틈을 만들었습니다.]],
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
	kr_name = "핏빛 편지", kr_unided_name = "빙하의 손도끼",
	desc = [[북쪽 황무지의 가장 단단하게 얼어붙은 부분을 깎아 만든 손도끼입니다.]],
	level_range = {25, 35},
	rarity = 235,
	require = { stat = { str=40, dex=24 }, },
	cost = 330,
	metallic = false,
	material_level = 3,
	wielder = {
		combat_armor = 20,
		resists_pen = {
			[DamageType.COLD] = 20,
		},
		iceblock_pierce=25,
	},
	combat = {
		dam = 33,
		apr = 4.5,
		physcrit = 7,
		dammod = {str=1},
		convert_damage = {
			[DamageType.ICE] = 50,
		},
		talent_on_hit = { [Talents.T_ICE_BREATH] = {level=2, chance=15} },
	},
}

newEntity{ base = "BASE_GEM", define_as = "GEM_TELOS",
	power_source = {arcane=true},
	unique = true,
	unided_name = "scintillating white crystal",
	name = "Telos's Staff Crystal", subtype = "multi-hued", image = "object/artifact/telos_staff_crystal.png",
	color = colors.WHITE,
	level_range = {35, 45},
	kr_name = "텔로스 지팡이의 수정", kr_unided_name = "번뜩이는 흰 수정",
	desc = [[이 순수한 흰색 수정을 가까이서 보면, 그 속에서 오만가지 색깔들의 소용돌이와 번뜩임을 발견할 수 있습니다.]],
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
	use_power = { name = "combine with a staff", kr_name = "지팡이와 결합", power = 1, use = function(self, who, gem_inven, gem_item)
		who:showInventory("어느 지팡이와 결합시킵니까?", who:getInven("INVEN"), function(o) return o.type == "weapon" and o.subtype == "staff" and not o.egoed and not o.unique end, function(o, item)
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
				game.logPlayer(who, "수정을 %s에 고정시켜, %s 만들었습니다", oldname, o:getName{do_color=true}:addJosa("를"))
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
	color = colors.VIOLET,
	rarity = false,
	kr_name = "텔로스의 목소리", kr_unided_name = "번뜩이는 흰 지팡이",
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
		damage_affinity = { [DamageType.ARCANE] = 5, [DamageType.BLIGHT] = 5, [DamageType.COLD] = 5, [DamageType.DARKNESS] = 5, [DamageType.ACID] = 5, [DamageType.LIGHT] = 5, [DamageType.LIGHTNING] = 5, [DamageType.FIRE] = 5, },
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1},
	},
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {nature=true},
	unique = true,
	name = "Rope Belt of the Thaloren", image = "object/artifact/rope_belt_of_the_thaloren.png",
	unided_name = "short length of rope",
	kr_name = "탈로레의 밧줄 허리띠", kr_unided_name = "짧은 길이의 밧줄",
	desc = [[네씰라 탄타엘렌이 수 세기에 걸쳐 주민들과 숲을 돌보는 동안 걸치고 있던, 가장 단순한 허리띠입니다. 그녀가 가진 지혜와 힘의 일부가 이것에 스며들어 영구히 자리잡고 있습니다.]],
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
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Thalore" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","resists"}, { [engine.DamageType.MIND] = 20,} )
			self:specialWearAdd({"wielder","combat_mentalresist"}, 15)
			game.logPlayer(who, "#DARK_GREEN#네씰라의 허리띠를 두르자, 이 것이 살아있는 것처럼 느껴집니다.")
		end
	end,
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {arcane=true},
	unique = true,
	name = "Neira's Memory", image = "object/artifact/neira_memory.png",
	unided_name = "crackling belt",
	kr_name = "네이라의 기억", kr_unided_name = "파직거리는 허리띠",
	desc = [[오래 전 리나니일이 어렸던 시절에 착용하던 허리띠로, 마법폭발로 인해 화염의 비가 내릴때 그녀를 보호한 힘이 들어있습니다. 하지만 그녀에게는 자매 네이라까지 보호해줄 능력이 없었습니다...]],
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
	use_power = { name = "generate a personal shield", kr_name = "개인 보호막 발동", power = 20,
		use = function(self, who)
			who:setEffect(who.EFF_DAMAGE_SHIELD, 10, {power=100 + who:getMag(250)})
			game:playSoundNear(who, "talents/arcane")
			game.logSeen(who, "%s 네이라의 기억을 사용했습니다!", (who.kr_name or who.name):capitalize():addJosa("가"))
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Nature's Blessing", image = "object/artifact/armor_natures_blessing.png",
	unided_name = "supple leather armour entwined with willow bark",
	kr_name = "자연의 축복", kr_unided_name = "버드나무 껍질이 감긴 유연한 가죽 갑옷",
	desc = [[인간과 하플링 사이의 마법사 전쟁 동안 조직된 지구르의 첫 번째 수호자, 아르돈이 입던 것입니다. 이 갑옷은 많은 자연의 힘이 깃들어 있어, 파괴적인 마법의 힘에서 착용자를 보호합니다.]],
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
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","combat_spellresist"}, 20)
			game.logPlayer(who, "#DARK_GREEN#당신은 아주 특별한 축복을 느낍니다.")
		end
	end,
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique=true},
	unique = true,
	name = "Plate Armor of the King", image = "object/artifact/plate_armor_of_the_king.png",
	unided_name = "suit of gleaming voratun plate",
	kr_name = "왕의 판갑", kr_unided_name = "어슴푸레하게 빛나는 보라툰 판갑",
	desc = [[토크놀 왕이 마지막 희망을 지키는 모습이 아름답게 새겨진 갑옷입니다. 이 모습은 가장 사악한 악당이라도 절망에 빠뜨리는 힘을 가지고 있습니다.]],
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
		combat_armor = 30,
		stun_immune = 0.3,
		knockback_immune = 0.3,
		combat_mentalresist = 25,
		combat_spellresist = 25,
		combat_physresist = 15,
		lite = 1,
		fatigue = 26,
	},
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {nature=true, antimagic=true},
	unique = true,
	name = "Witch-Bane", color = colors.LIGHT_STEEL_BLUE, image = "object/artifact/sword_witch_bane.png",
	unided_name = "an ivory handled voratun longsword",
	kr_name = "마녀 살해자", kr_unided_name = "상아 손잡이가 달린 보라툰 장검",
	desc = [[얇은 보라툰 칼날에 보라색 천으로 감긴 상아 손잡이가 달린 장검입니다. 무기의 원래 사용자 마르쿠스 둔 만큼이나 전설적인 무기이며, 마법사냥 말기에 마르쿠스가 살해당한 이후 부서졌다고 알려진 무기입니다.
반마법을 추구하는 사람이 이것을 사용하면, 모든 잠재능력을 사용할 수 있을 것 같습니다.]],
	level_range = {38, 50},
	rarity = 250,
	require = { stat = { str=48 }, },
	cost = 650,
	material_level = 5,
	combat = {
		dam = 42,
		apr = 4,
		physcrit = 20,
		dammod = {str=1},
		melee_project = { [DamageType.ITEM_ANTIMAGIC_MANABURN] = 50 },
	},
	wielder = {
		talent_cd_reduction={
			[Talents.T_AURA_OF_SILENCE] = 2,
			[Talents.T_MANA_CLASH] = 2,
		},
		resists = {
			all = 15,
			[DamageType.PHYSICAL] = - 15,
			[DamageType.BLIGHT] = 15,
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

-- Channelers set
-- Note that this staff can not be channeled.  All of it's flavor is arcane, lets leave it arcane
newEntity{ base = "BASE_STAFF", define_as = "SET_STAFF_CHANNELERS",
	power_source = {arcane=true},
	unique = true,
	name = "Staff of Arcane Supremacy",
	unided_name = "silver-runed staff",
	flavor_name = "magestaff",
	level_range = {20, 40},
	color=colors.BLUE, image = "object/artifact/staff_of_arcane_supremacy.png",
	rarity = 300,
	kr_name = "지고의 마법 지팡이", kr_unided_name = "은빛 룬 지팡이",
	desc = [[고대의 용뼈로 만들어졌으며, 밝은 은빛 룬 장식이 표면을 뒤덮고 있는 길고 늘씬한 지팡이입니다.
지팡이 안에 거대한 힘이 갇혀있는 것처럼 희미하게 웅웅거리고 있지만, 이 힘을 사용하려면 무언가가 더 필요할 것 같습니다.]],
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
		game.logSeen(who, "#STEEL_BLUE#마법의 힘이 급격하게 팽창하기 시작합니다.")
	end,
}

newEntity{ base = "BASE_WIZARD_HAT", define_as = "SET_HAT_CHANNELERS",
	power_source = {arcane=true},
	unique = true,
	name = "Hat of Arcane Understanding",
	unided_name = "silver-runed hat",
	kr_name = "마법 이해의 모자", kr_unided_name = "은빛 룬 모자",
	desc = [[전통적인 형태의 뾰족한 마법모자로, 훌륭한 보라색 엘프비단으로 만들었으며 밝은 은빛 룬으로 장식되어 있습니다. 위대한 마법사의 머리 위에서 태어나, 고대로부터 이어져 내려온 모자임을 느낄 수 있습니다.
모자를 만져보면, 모자 안에서 과거 시대의 지식과 힘이 느껴집니다. 아직도 그 힘의 일부가 봉인되어 있지만, 언젠가 모든 힘이 풀려날 때를 기다리고 있는 것 같습니다.]],
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
		game.logPlayer(who, "#STEEL_BLUE#주변에 있던 마법의 힘이 흩어집니다.")
	end,
}

newEntity{ base = "BASE_AMULET", --Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Mirror Shards",
	unided_name = "mirror lined chain", image = "object/artifact/mirror_shards.png",
	kr_name = "거울 파편", kr_unided_name = "연결된 거울 조각",
	desc = [[마법폭발이 일어난 뒤 발생한 마법사냥으로 인해 고향이 파괴되자, 강력한 마법사가 만든 목걸이입니다. 그는 무사히 도망쳤지만 그의 모든 소유물은 부서지고 찌부러지고 불타올랐습니다. 그는 파괴된 고향으로 돌아와, 남아있던 부서진 거울로 이 부적을 만들었다고 합니다.]],
	color = colors.LIGHT_RED,
	level_range = {18, 30},
	rarity = 220,
	cost = 350,
	material_level = 3,
	wielder = {
		inc_damage={
			[DamageType.LIGHT] = 12,
		},
		resists={
			[DamageType.LIGHT] = 25,
		},
		lite=1,
		on_melee_hit = {[DamageType.ITEM_LIGHT_BLIND]=30},
	},
	max_power = 24, power_regen = 1,
	use_power = { name = "create a reflective shield (50% reflection rate)", kr_name = "반사 보호막 생성 (반사율 50%)", power = 24,
		use = function(self, who)
			who:setEffect(who.EFF_DAMAGE_SHIELD, 5, {power=150 + who:getMag(100)*2, reflect=50})
			game:playSoundNear(who, "talents/arcane")
			game.logSeen(who, "%s 반사 보호막을 만들었습니다!", (who.kr_name or who.name):capitalize():addJosa("가"))
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_CLOAK",
	power_source = {nature=true},
	unique = true,
	name = "Destala's Scales", image = "object/artifact/destalas_scales.png",
	unided_name = "green dragon-scale cloak",
	kr_name = "데스탈라의 비늘", kr_unided_name = "녹색 용비늘 망토",
	desc = [[이 망토는 황혼의 시대 말기에 변경 지역을 위협하던 악명높은 산성 드레이크의 비늘로 만들어진 것입니다. 그 드레이크는 케스틴 하이핀과 그의 동료들에 의해 죽었고, 케스틴 하이핀은 개인적인 목적으로 이 망토를 만들었습니다.]],
	level_range = {20, 30},
	rarity = 240,
	cost = 200,
	material_level = 3,
	wielder = {
		combat_def = 10,
		inc_stats = { [Stats.STAT_CUN] = 6,},
		inc_damage = { [DamageType.ACID] = 15 },
		resists_pen = { [DamageType.ACID] = 10 },
		talents_types_mastery = { ["wild-gift/venom-drake"] = 0.2, },
		combat_mindpower=6,
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_DISSOLVE, level = 2, power = 20 },
	talent_on_wild_gift = { {chance=10, talent=Talents.T_ACIDIC_SPRAY, level=2} },
}

newEntity{ base = "BASE_KNIFE", -- Thanks Grayswandir!
	power_source = {arcane=true},
	unique = true,
	name = "Spellblaze Shard", image = "object/artifact/spellblaze_shard.png",
	unided_name = "crystalline dagger",
	kr_name = "마법폭발 파편", kr_unided_name = "수정 단검",
	desc = [[뾰족한 수정 조각으로, 자연적이지 않은 빛을 발하고 있습니다. 수정의 한쪽 끝은 손잡이로 쓰기 위해 천이 감겨있습니다.]],
	level_range = {12, 25},
	rarity = 200,
	require = { stat = { dex=17 }, },
	cost = 250,
	metallic = false,
	material_level = 2,
	combat = {
		dam = 20,
		apr = 10,
		physcrit = 12,
		dammod = {dex=0.45,str=0.45,},
		melee_project={[DamageType.FIREBURN] = 10, [DamageType.BLIGHT] = 10,},
		lifesteal = 6,
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

newEntity{ base = "BASE_KNIFE", --Razakai's idea, slightly modified
	power_source = {psionic=true},
	unique = true,
	name = "Mercy", image = "object/artifact/mercy.png",
	unided_name = "wickedly sharp dagger",
	kr_name = "자비", kr_unided_name = "위험할 정도로 날카로운 단검",
	desc = [[이 단검은 황혼의 시대에 한 이름없는 치료사가 사용하던 것입니다. 그의 마을을 파괴한 전염병은 필멸자가 대응할 능력을 넘어서는 것이었고, 그는 희망조차 잃어버린 환자들을 마주한 채 그의 단검으로 마지막 자비를 베풀 수 밖에 없었습니다. 그의 훌륭한 의도에도 불구하고, 그 행동은 어둠의 힘을 불러와 저주를 일으켰고, 이 단검에는 다친 자를 가볍게 찌르는 것만으로 죽음을 가져오는 힘이 깃들어 버렸습니다.]],
	level_range = {30, 40},
	rarity = 250,
	require = { stat = { dex=42 }, },
	cost = 500,
	material_level = 4,
	combat = {
		dam = 35,
		apr = 9,
		physcrit = 15,
		dammod = {str=0.45, dex=0.55},
		special_on_hit = {desc="대상이 받은 전체 생명력 피해량의 3% 만큼 물리 속성 피해 발생", fct=function(combat, who, target)
			local tg = {type="ball", range=10, radius=0, selffire=false}
			who:project(tg, target.x, target.y, engine.DamageType.PHYSICAL, (target.max_life - target.life)*0.03)
		end},
	},
	wielder = {
		inc_stats = {[Stats.STAT_STR] = 6, [Stats.STAT_DEX] = 6,},
		combat_critical_power = 20,
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR", -- Thanks SageAcrin!
	power_source = {technique = true, nature = true},
	unique = true,
	name = "Thalore-Wood Cuirass", image = "object/artifact/thalore_wood_cuirass.png",
	unided_name = "thick wooden plate armour",
	kr_name = "탈로레 나무 흉갑", kr_unided_name = "두꺼운 나무 판갑",
	desc = [[능숙하게 잘라낸 나무 껍질입니다. 이 나무 갑옷은 가벼우면서도, 아주 훌륭한 방어력을 가지고 있습니다.]],
	color = colors.WHITE,
	level_range = {8, 22},
	rarity = 220,
	require = { stat = { str=24 }, },
	cost = 300,
	material_level = 2,
	moddable_tile = "special/wooden_cuirass",
	moddable_tile_big = true,

	encumber = 12,
	metallic=false,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 3, [Stats.STAT_DEX] = 3, [Stats.STAT_CON] = 3,},
		combat_armor = 12,
		combat_def = 4,
		fatigue = 14,
		resists = {
			[DamageType.DARKNESS] = 18,
			[DamageType.COLD] = 18,
			[DamageType.NATURE] = 18,
		},
		healing_factor = 0.25,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Thalore" then
			local Stats = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","fatigue"}, -14)
			game.logPlayer(who, "#DARK_GREEN#이 갑옷은 그의 관리인들이 편안하도록 만들어 줍니다.")
		end
	end,
}