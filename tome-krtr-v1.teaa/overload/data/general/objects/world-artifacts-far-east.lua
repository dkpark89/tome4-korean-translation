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

require "engine.krtrUtils" --@@

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- This one starts a quest it has a level and rarity so it can drop randomly, but there are places where it is more likely to appear
newEntity{ base = "BASE_SCROLL", define_as = "JEWELER_TOME", subtype="tome", no_unique_lore=true,
	unique = true, quest=true,
	unided_name = "ancient tome",
	name = "Ancient Tome titled 'Gems and their uses'", image = "object/artifact/ancient_tome_gems_and_their_uses.png",
	kr_display_name = "고대 서적 '보석과 그 사용처'", kr_unided_name = "고대 서적",
	level_range = {30, 40}, rarity = 120,
	color = colors.VIOLET,
	fire_proof = true,
	not_in_stores = true,

	on_pickup = function(self, who)
		if who == game.player then
			self:identify(true)
			who:grantQuest("master-jeweler")
		end
	end,
}

-- Not a random drop, used by the quest started above
newEntity{ base = "BASE_SCROLL", define_as = "JEWELER_SUMMON", subtype="tome", no_unique_lore=true,
	power_source = {unknown=true},
	unique = true, quest=true, identified=true,
	name = "Scroll of Summoning (Limmir the Jeweler)",
	kr_display_name = "소환의 두루마리 (귀금속상인 리미르)",
	color = colors.VIOLET,
	fire_proof = true,

	max_power = 1, power_regen = 1,
	use_power = { name = "달의 호수 중심으로 귀금속상인 리미르를 소환", power = 1,
		use = function(self, who) who:hasQuest("master-jeweler"):summon_limmir(who) return {id=true, used=true} end
	},
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Pendent of the Sun and Moons", color = colors.LIGHT_SLATE, image = "object/artifact/amulet_pendant_of_sun_and_the_moon.png",
	unided_name = "a gray and gold pendent",
	kr_display_name = "태양과 달의 펜던트", kr_unided_name = "회색 황금 펜던트",
	desc = [[이 조그만 펜던트는 적철의 달이 황금 태양을 가리는 식을 묘사하고 있습니다. 전설에 따르면 이 것은 태양의 장벽의 발견자 중 한명이 사용하던 것이라 합니다.]],
	level_range = {35, 45},
	rarity = 300,
	cost = 200,
	material_level = 4,
	wielder = {
		combat_spellpower = 8,
		combat_spellcrit = 5,
		inc_damage = { [DamageType.LIGHT]= 8,[DamageType.DARKNESS]= 8 },
		resists = { [DamageType.LIGHT]= 10, [DamageType.DARKNESS]= 10 },
		resists_cap = { [DamageType.LIGHT]= 5, [DamageType.DARKNESS]= 5 },
		resists_pen = { [DamageType.LIGHT]= 15, [DamageType.DARKNESS]= 15 },
	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_CIRCLE_OF_SANCTITY, level = 3, power = 30 },
}

newEntity{ base = "BASE_SHIELD",
	power_source = {arcane=true},
	unique = true,
	unided_name = "shimmering gold shield",
	name = "Unsetting Sun", image = "object/artifact/shield_unsetting_sun.png",
	kr_display_name = "지지않는 태양", kr_unided_name = "어른거리는 황금 방패",
	desc = [[전초부대 대장 엘미오 파나손이 난파한 선원들을 위한 피난처를 처음 찾고 있을때, 그의 방패가 지고있는 태양의 마지막 빛을 반사시켰습니다. 그 빛이 닿는 곳에서 그들은 휴식을 취했고, 그 곳을 개척하여 만든 것이 태양의 장벽입니다. 그리하여, 어둠 날들에 이 방패를 앞세우는 것은 더 좋은 미래를 향한 희망의 상징이 되었습니다.]],
	color = colors.YELLOW,
	rarity = 300,
	level_range = {35, 45},
	require = { stat = { str=40 }, },
	cost = 400,
	material_level = 5,
	special_combat = {
		dam = 50,
		block = 280,
		physcrit = 4.5,
		dammod = {str=1},
		damtype = DamageType.LIGHT,
	},
	wielder = {
		lite = 2,
		combat_armor = 9,
		combat_def = 16,
		combat_def_ranged = 17,
		fatigue = 14,
		combat_spellresist = 19,
		resists = {[DamageType.BLIGHT] = 30, [DamageType.DARKNESS] = 30},
		learn_talent = { [Talents.T_BLOCK] = 5, },
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS",
	power_source = {arcane=true},
	unique = true,
	name = "Scorched Boots", image = "object/artifact/scorched_boots.png",
	unided_name = "pair of blackened boots",
	kr_display_name = "불탄 신발", kr_unided_name = "시커먼 신발",
	desc = [[상위 피의 마법사 루'칸은 장작더미의 시대에 쉐르'툴 장거리포탈의 힘을 실험한 첫번째 오크였습니다. 그러나 첫번째 실험은 부분적으로 성공하지 못했고, 그 힘이 폭발한 다음 루'칸은 불탄 신발을 발견했습니다.]],
	color = colors.DARK_GRAY,
	level_range = {30, 40},
	rarity = 250,
	cost = 200,
	material_level = 5,
	wielder = {
		combat_armor = 4,
		combat_def = 4,
		fatigue = 8,
		combat_spellpower = 13,
		inc_damage = { [DamageType.BLIGHT] = 15 },
	},
}

newEntity{ base = "BASE_GEM",
	power_source = {arcane=true},
	unique = true,
	unided_name = "unearthly black stone",
	name = "Goedalath Rock", subtype = "black", image = "object/artifact/goedalath_rock.png",
	kr_display_name = "괴달라스의 돌", kr_unided_name = "초자연적인 검은 돌",
	color = colors.PURPLE,
	level_range = {42, 50},
	desc = [[이 세상의 것이 아닌 것 같아 보이는, 난폭한 에너지를 내며 진동하는 작은 돌멩이입니다. 이것은 정상이 아니고 끔찍하며 사악하게 느껴지지만... 정말 강력하네요.]],
	rarity = 300,
	cost = 300,
	material_level = 5,
	identified = false,
	carrier = {
		on_melee_hit = {[DamageType.HEAL] = 34},
		life_regen = -2,
		lite = -2,
		combat_mentalresist = -18,
		healing_factor = -0.5,
	},
	imbue_powers = {
		combat_dam = 12,
		combat_spellpower = 16,
		see_invisible = 14,
		infravision = 3,
		inc_damage = {all = 9},
		inc_damage_type = {demon = 20},
		esp = {["demon/major"]=1, ["demon/minor"]=1},
		on_melee_hit = {[DamageType.DARKNESS] = 34},
		healing_factor = 0.5,
	},
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true}, define_as = "THREADS_FATE",
	unique = true,
	name = "Threads of Fate", image = "object/artifact/cloak_threads_of_fate.png",
	unided_name = "a shimmering white cloak",
	kr_display_name = "숙명의 누빔", kr_unided_name = "어른거리는 흰 망토",
	desc = [[시간의 침식의 영향을 받지않는 이 훌륭한 흰 망토는 빛을 바꾸고 어른거리게 만드는 다른 세상의 물질로 만들어진 것입니다.]],
	level_range = {45, 50},
	color = colors.WHITE,
	rarity = 500,
	cost = 300,
	material_level = 5,

	wielder = {
		combat_def = 10,
		combat_spellpower = 8,
		confusion_immune = 0.4,
		inc_stats = { [Stats.STAT_MAG] = 6, [Stats.STAT_WIL] = 6, [Stats.STAT_LCK] = 10, },

		inc_damage = { [DamageType.TEMPORAL]= 10 },
		resists_cap = { [DamageType.TEMPORAL] = 10, },
		resists = { [DamageType.TEMPORAL] = 20, },
		combat_physresist = 20,
		combat_mentalresist = 20,
		combat_spellresist = 20,

		talents_types_mastery = {
			["chronomancy/timeline-threading"] = 0.1,
			["chronomancy/chronomancy"] = 0.1,
			["spell/divination"] = 0.1,
		},
	},

	max_power = 50, power_regen = 1,
	use_talent = { id = Talents.T_SEE_THE_THREADS, level = 1, power = 50 },
}

newEntity{ base = "BASE_LONGSWORD", define_as = "BLOODEDGE",
	power_source = {arcane=true},
	unique = true,
	name = "Blood-Edge", image = "object/artifact/sword_blood_edge.png",
	unided_name = "red crystalline sword",
	kr_display_name = "피의 칼날", kr_unided_name = "붉은 수정 장검",
	level_range = {35, 42},
	color=colors.RED,
	rarity = 270,
	desc = [[이 짙은 붉은 장검은 계속 피를 흘립니다. 이 것은 오크 타락자 후릭의 연구실에서 태어났습니다. 후릭은 그가 죽은 후 그의 영혼의 안식처로 사용하기 위한 수정을 만드려 했으나, 그 계획은 태양의 기사들이 처들어옴으로써 엉망이 되었습니다. 후릭을 보호하던 드레드 추종자들이 대부분 죽거나 정화되었지만, 기사 대장인 라술은 칼을 들고 계속 싸우기로 결정합니다. 양측은 칼날과 피의 마법으로 전투를 벌였고, 결국 양쪽 모두 깊은 상처를 받고 땅에 쓰러졌습니다. 후릭은 구원을 바라며 그의 마지막 힘을 짜내 그가 만든 유품쪽으로 기어갔지만, 라술이 그것을 보고 빛에 쌓인 칼로 수정을 내리쳤습니다. 그러자 충격을 받은 에너지로 인해 강철과 수정 그리고 핏물이 하나로 합쳐졌습니다.
그리고 라술의 부서진 영혼의 조각이 이 끔찍한 아티팩트에 잡혀버렸고, 그의 정신은 수십년간의 감금으로 온전하지 못하게 왜곡되어 버렸습니다. 그의 힘은 피를 맛보기 위해서만 나타나고, 그의 영혼은 다시 물리적 육체를 가지기 위해 다른 이들의 생명력을 훔치며, 생명체를 보면 공격하고 울부짖습니다.]],
	cost = 1000,
	require = { stat = { mag=20, str=32,}, },
	material_level = 5,
	wielder = {
		esp = {["undead/blood"]=1,},
		combat_spellpower = 12,
		combat_spellcrit = 4,
		inc_damage={
			[DamageType.PHYSICAL] = 12,
			[DamageType.BLIGHT] = 12,
		},
		max_vim = 20,
	},

	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_BLEEDING_EDGE, level = 4, power = 30 },
	combat = {
		dam = 38,
		apr = 4,
		physcrit = 5,
		dammod = {str=0.5, mag=0.5},
		convert_damage = {[DamageType.BLIGHT] = 50},

		special_on_hit = {desc="15% 확률로 적에게 출혈효과", fct=function(combat, who, target)
			if not rng.percent(15) then return end
			local cut = false

			-- Go through all timed effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.cut then
					cut = true
				end
			end

			if not (cut) then return end

			local tg = {type="hit", range=1}
			who:project(tg, target.x, target.y, engine.DamageType.DRAIN_VIM, 80)

			local x, y = util.findFreeGrid(target.x, target.y, 5, true, {[engine.Map.ACTOR]=true})
			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "undead", subtype = "blood",
				display = "L",
				name = "animated blood", color=colors.RED,
				kr_display_name = "살아 움직이는 핏물",
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_lich_blood_lich.png", display_h=1, display_y=0}}},
				desc = "대기중에 흔들리고 맥동하는 핏물의 안개로, 왜곡되고 상처입은 영혼이 들어있습니다. 때때로 지나칠때마다 비명을 지르거나 고통에 울부짖고, 무심한 괴로운 경험을 얘기합니다.",
				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, },
				rank = 3,
				life_rating = 10, exp_worth = 0,
				max_vim=200,
				max_life = resolvers.rngavg(50,90),
				infravision = 20,
				autolevel = "dexmage",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=2, ally_compassion=10},
				stats = { str=15, dex=18, mag=18, wil=15, con=10, cun=18 },
				level_range = {1, nil}, exp_worth = 0,
				silent_levelup = true,
				combat_armor = 0, combat_def = 24,
				combat = { dam=resolvers.rngavg(10,13), atk=15, apr=15, dammod={mag=0.5, dex=0.5}, damtype=engine.DamageType.BLIGHT, },

				resists = { [engine.DamageType.BLIGHT] = 100, [engine.DamageType.NATURE] = -100, },

				negative_status_effect_immune = 1,

				on_melee_hit = {[engine.DamageType.DRAINLIFE]=resolvers.mbonus(10, 30)},
				melee_project = {[engine.DamageType.DRAINLIFE]=resolvers.mbonus(10, 30)},

				resolvers.talents{
					[who.T_WEAPON_COMBAT]={base=1, every=7, max=10},
					[who.T_EVASION]={base=3, every=8, max=7},

					[who.T_BLOOD_SPRAY]={base=1, every=6, max = 10},
					[who.T_BLOOD_GRASP]={base=1, every=5, max = 9},
					[who.T_BLOOD_BOIL]={base=1, every=7, max = 7},
					[who.T_BLOOD_FURY]={base=1, every=8, max = 6},
				},
				resolvers.sustains_at_birth(),
				faction = who.faction,
				summoner = who, summoner_gain_exp=true,
				summon_time = 7,
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

			game.logSeen(who, "#GOLD#칼날이 닿자 %s의 피가 분출하고, 일어서서, 살아 움직입니다!", (target.kr_display_name or target.name):capitalize())
			if who:knowTalent(who.T_VIM_POOL) then
				game.logSeen(who, "#GOLD#%s 분출된 피로부터 힘을 뽑아갑니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"))
			end

		end},
	},
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Dawn's Blade",
	unided_name = "shining longsword",
	kr_display_name = "여명의 검", kr_unided_name = "빛나는 장검",
	level_range = {35, 42},
	color=colors.YELLOW, image = "object/artifact/dawn_blade.png",
	rarity = 260,
	desc = [[태양의 장벽이 생긴 초기시절에 만들어졌다고 알려졌습니다. 이 장검은 동틀 녘의 빛을 발하고, 모든 그림자를 쫒아 버릴수 있습니다]],
	cost = 1000,
	require = { stat = { mag=18, str=35,}, },
	material_level = 5,
	wielder = {
		combat_spellpower = 10,
		combat_spellcrit = 4,
		inc_damage={
			[DamageType.LIGHT] = 18,
		},
		resists_pen={
			[DamageType.LIGHT] = 20,
		},
		talents_types_mastery = {
			["celestial/sun"] = 0.2,
			["celestial/light"] = 0.1,
		},
		talent_cd_reduction= {
			[Talents.T_HEALING_LIGHT] = 2,
			[Talents.T_BARRIER] = 2,
			[Talents.T_SUN_FLARE] = 2,
			[Talents.T_PROVIDENCE] = 4,
		},
		lite=2,
	},
	max_power = 35, power_regen = 1,
	use_power = { name = "여명을 기원", power = 35,
		use = function(self, who)
			local radius = 4
			local dam = (75 + who:getMag()*2)
			local blast = {type="ball", range=0, radius=5, selffire=false}
			who:project(blast, who.x, who.y, engine.DamageType.LIGHT, dam)
			game.level.map:particleEmitter(who.x, who.y, blast.radius, "sunburst", {radius=blast.radius})
			who:project({type="ball", range=0, radius=10}, who.x, who.y, engine.DamageType.LITE, 100)
			game:playSoundNear(self, "talents/fireflash")
			game.logSeen(who, "%s %s 들어올리자 사방으로 빛줄기가 퍼져나갑니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), self:getName():addJosa("를"))
			return {id=true, used=true}
		end
	},
	combat = {
		dam = 42,
		apr = 4,
		physcrit = 5,
		dammod = {str=0.75, mag=0.25},
		convert_damage = {[DamageType.LIGHT] = 30},
		inc_damage_type={
			undead=25,
			demon=25,
		},
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subclass == "Sun Paladin" then
			self:specialWearAdd({"wielder", "positive_regen"}, 0.2)
			self:specialWearAdd({"wielder", "positive_regen_ref"}, 0.2)
			game.logPlayer(who, "#GOLD#당신은 양기가 늘어남을 느낍니다!")
		end
	end,
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "Zemekkys' Broken Hourglass", color = colors.WHITE,
	unided_name = "a broken hourglass", image="object/artifact/amulet_zemekkys_broken_hourglass.png",
	kr_display_name = "제메키스의 부서진 모래시계", kr_unided_name = "부서진 모래시계",
	desc = [[이 작은 부서진 모래시계는 황금 사슬에 걸려있었습니다. 유리에는 금이가 있고, 모래는 모두 흘러나간지 오래되었습니다.]],
	level_range = {30, 40},
	rarity = 300,
	cost = 200,
	material_level = 4,
	metallic = false,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, },
		inc_damage = { [DamageType.TEMPORAL]= 10 },
		resists = { [DamageType.TEMPORAL] = 20 },
		resists_cap = { [DamageType.TEMPORAL] = 5 },
		spell_cooldown_reduction = 0.1,
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_WORMHOLE, level = 4, power = 20 },
}

newEntity{ base = "BASE_KNIFE", define_as = "MANDIBLE_UNGOLMOR",
	power_source = {nature=true},
	unique = true,
	name = "Mandible of Ungolmor", image = "object/artifact/mandible_of_ungolmor.png",
	unided_name = "curved, serrated black dagger",
	kr_display_name = "운골모르의 아랫턱뼈", kr_unided_name = "굽어있는 검은 톱니 단검",
	desc = [[운골모르의 치명적인 송곳니가 박혀있는 굽은 모양의 흑요석 검입니다. 이것은 주변 세상의 빛을 흡수하는것 같습니다.]],
	level_range = {40, 50},
	rarity = 270,
	require = { stat = { cun=38 }, },
	cost = 650,
	material_level = 5,
	combat = {
		dam = 40,
		apr = 12,
		physcrit = 22,
		dammod = {cun=0.30, str=0.35, dex=0.35},
		convert_damage ={[DamageType.DARKNESS] = 30},
		special_on_crit = {desc="대상에게 속박형 거미독 주입", fct=function(combat, who, target)
			if target:canBe("poison") then
				local tg = {type="hit", range=1}
				who:project(tg, target.x, target.y, engine.DamageType.SPYDRIC_POISON, {src=who, dam=30, dur=3})
			end
		end},
	},
	wielder = {
		inc_damage={[DamageType.NATURE] = 30, [DamageType.DARKNESS] = 20,},
		inc_stats = {[Stats.STAT_CUN] = 8, [Stats.STAT_DEX] = 4,},
		combat_armor = 5,
		combat_armor_hardiness = 5,
		lite = -2,
	},
	max_power = 40, power_regen = 1,
	use_talent = { id = Talents.T_CREEPING_DARKNESS, level = 3, power = 25 },
}

newEntity{ base = "BASE_KNIFE", define_as = "KINETIC_SPIKE",
	power_source = {psionic=true},
	unique = true,
	name = "Kinetic Spike", image = "object/artifact/kinetic_spike.png",
	unided_name = "bladeless hilt",
	kr_display_name = "동역학 가시", kr_unided_name = "칼날없는 칼자루",
	desc = [[단순하고 조잡하게 만들어진 석제 칼자루로, 이 물체를 잡으면 열기의 아지랑이 같이 거의 보이지않는 흔들거리는 칼날이 나타납니다. 단순해 보이는 생김새에도 불구하고, 이것을 제대로 사용할 줄 아는 꿋꿋한 정신을 가진 이의 손에 들어간다면 단단한 화강암도 자를수 있습니다.]],
	level_range = {42, 50},
	rarity = 310,
	require = { stat = { wil=42 }, },
	cost = 450,
	material_level = 5,
	combat = {
		dam = 38,
		apr = 40, -- Hard to imagine much being harder to stop with armor.
		physcrit = 10,
		dammod = {wil=0.30, str=0.30, dex=0.40},
	},
	wielder = {
		combat_atk = 8,
		combat_dam = 15,
		resists_pen = {[DamageType.PHYSICAL] = 30},
	},
	max_power = 10, power_regen = 1,
	use_power = { name = "무기의 150% 피해를 주는 동역학 기운 줄기 발사", power = 10,
		use = function(self, who)
			local tg = {type="bolt", range=8}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			local _ _, x, y = who:canProject(tg, x, y)
			local target = game.level.map(x, y, engine.Map.ACTOR)
			if target then
				who:attackTarget(target, engine.DamageType.PHYSICAL, 1.5, true)
			game.logSeen(who, "%s 동역학 기운의 줄기를 발사했습니다!", self:getName():capitalize():addJosa("가"))
			else
				return
			end
			return {id=true, used=true}
		end
	},
}
