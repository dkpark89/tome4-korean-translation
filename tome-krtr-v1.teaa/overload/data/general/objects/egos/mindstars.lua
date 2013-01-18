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

-- TODO:  More greater suffix psionic; more lesser suffix and prefix psionic

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

-------------------------------------------------------
--Nature and Antimagic---------------------------------
-------------------------------------------------------
 newEntity{
	power_source = {nature=true},
	name = "blooming ", prefix=true, instant_resolve=true,
	kr_display_name = "번영 ",
	keywords = {blooming=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		heal_on_nature_summon = resolvers.mbonus_material(25, 5),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "gifted ", prefix=true, instant_resolve=true,
	kr_display_name = "천부적 ",
	keywords = {gifted=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 2),
	},
}

newEntity{
	power_source = {nature=true},
	name = "nature's ", prefix=true, instant_resolve=true,
	kr_display_name = "자연 ",
	keywords = {nature=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		inc_damage={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
		disease_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(8, 2),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of balance", suffix=true, instant_resolve=true,
	kr_display_name = "균형의 ",
	keywords = {balance=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_physresist = resolvers.mbonus_material(8, 2),
		combat_spellresist = resolvers.mbonus_material(8, 2),
		combat_mentalresist = resolvers.mbonus_material(8, 2),
		equilibrium_regen_when_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of life", suffix=true, instant_resolve=true,
	kr_display_name = "생명의 ",
	keywords = {life=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		max_life = resolvers.mbonus_material(40, 10),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {antimagic=true},
	name = " of slime", suffix=true, instant_resolve=true,
	kr_display_name = "슬라임의 ",
	keywords = {slime=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={
			[DamageType.SLIME] = resolvers.mbonus_material(8, 2),
		},
		inc_damage={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
	},
}

-------------------------------------------------------
--Psionic----------------------------------------------
-------------------------------------------------------
newEntity{
	power_source = {psionic=true},
	name = "horrifying ", prefix=true, instant_resolve=true,
	kr_display_name = "무시무시한 ",
	keywords = {horrifying=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		on_melee_hit={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
		inc_damage={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = "radiant ", prefix=true, instant_resolve=true,
	kr_display_name = "발광하는 ",
	keywords = {radiant=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	combat = {
		melee_project = { [DamageType.LIGHT] = resolvers.mbonus_material(8, 2), },
	},
	wielder = {
		combat_mindpower = resolvers.mbonus_material(4, 1),
		combat_mindcrit = resolvers.mbonus_material(4, 1),
		lite = resolvers.mbonus_material(1, 1),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of clarity", suffix=true, instant_resolve=true,
	kr_display_name = "명석의 ",
	keywords = {clarity=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(8, 2),
		max_psi = resolvers.mbonus_material(40, 10),
	},
}

 newEntity{
	power_source = {psionic=true},
	name = "hungering ", prefix=true, instant_resolve=true,
	kr_display_name = "갈망하는 ",
	keywords = {hungering=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		talents_types_mastery = {
			["psionic/voracity"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
			["cursed/dark-sustenance"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
		hate_per_kill = resolvers.mbonus_material(4, 1),
		psi_per_kill = resolvers.mbonus_material(4, 1),
	},

	charm_power = resolvers.mbonus_material(80, 20),
	charm_power_def = {add=5, max=10, floor=true},
	resolvers.charm("정신 피해를 주고 염력과 증오심을 얻음", 20,
		function(self, who)
			local tg = {type="hit", range=10,}
			local x, y, target = who:getTarget(tg)
			if not x or not y then return nil end
			if target then
				if target:checkHit(who:combatMindpower(), target:combatMentalResist(), 0, 95, 5) then
					local damage = self:getCharmPower() + (who:combatMindpower() * (1 + self.material_level/5))
					who:project(tg, x, y, engine.DamageType.MIND, {dam=damage, alwaysHit=true}, {type="mind"})
					who:incPsi(damage/10)
					who:incHate(damage/10)
				else
					--@@
					local tn = target.kr_display_name or target.name
					game.logSeen(target, "%s 정신 공격을 저항했습니다!", tn:capitalize():addJosa("가"))
				end
			end
			return {id=true, used=true}
		end
	),
}

 newEntity{
	power_source = {psionic=true},
	name = " of nightfall", suffix=true, instant_resolve=true,
	kr_display_name = "황혼의 ",
	keywords = {nightfall=true},
	level_range = {30, 50},
	rarity = 30,
	cost = 40,
	wielder = {
		inc_damage={
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
		blind_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		talents_types_mastery = {
			["cursed/darkness"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
	},
}

------------------------------------------------
-- Mindstar Sets -------------------------------
------------------------------------------------
-- Wild Cards: Capable of completing other sets
newEntity{
	power_source = {nature=true},
	name = "harmonious ", prefix=true, instant_resolve=true,
	kr_display_name = "조화로운 ",
	keywords = {harmonious=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		equilibrium_regen_when_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
		talents_types_mastery = {
			["wild-gift/harmony"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
		inc_damage={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
	},
	resolvers.charm("마석 조합으로 자연력 보강", 20,
		function(self, who, ms_inven)
			if who:getInven("PSIONIC_FOCUS") and who:getInven("PSIONIC_FOCUS")[1] == self then
				--@@
				local sn = self.kr_display_name or self.name
				game.logPlayer(who, "당신이 %s 염동력으로 잡고 있는 동안 사용할 수 없습니다.", sn:addJosa("를"))
				return
			end		
			who:showEquipment("어느 마석과 조화시키겠습니까?", function(o) return o.subtype == "mindstar" and o.set_list and o ~= self  and o.power_source and o.power_source.nature and not o.set_complete end, function(o)
				-- remove any existing set properties
				self.define_as =nil
				self.set_list = nil
				self.on_set_complete = nil

				-- define the mindstar so it matches the set list of the target mindstar
				self.define_as = o.set_list[1][2]
				-- then set the mindstar's set list as the definition of the target mindstar
				self.set_list = { {"define_as", o.define_as} }
				-- and copies the target mindstar's on set complete
				self.on_set_complete = o.on_set_complete
				-- remove the mindstar and rewear it to trigger set bonuses
				local obj = who:takeoffObject(ms_inven, 1)
				who:wearObject(obj, true)
				return true
			end)
			return {id=true, used=true}
		end
	),
}

 newEntity{
	power_source = {psionic=true},
	name = "resonating ", prefix=true, instant_resolve=true,
	kr_display_name = "공명하는 ",
	keywords = {resonating=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		damage_resonance = resolvers.mbonus_material(20, 5),
		psi_regen_when_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
		inc_damage={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
		},
	},
	resolvers.charm("마석 조합으로 염력 보강", 20,
		function(self, who, ms_inven)
			if who:getInven("PSIONIC_FOCUS") and who:getInven("PSIONIC_FOCUS")[1] == self then
				--@@
				local sn = self.kr_display_name or self.name
				game.logPlayer(who, "당신이 %s 염동력으로 잡고 있는 동안 사용할 수 없습니다.", sn:addJosa("를"))
				return
			end		
			who:showEquipment("어느 마석과 공명시키겠습니까?", function(o) return o.subtype == "mindstar" and o.set_list and o ~= self and o.power_source and o.power_source.psionic and not o.set_complete end, function(o)
				-- remove any existing set properties
				self.define_as =nil
				self.set_list = nil
				self.on_set_complete = nil

				-- define the mindstar so it matches the set list of the target mindstar
				self.define_as = o.set_list[1][2]
				-- then set the mindstar's set list as the definition of the target mindstar
				self.set_list = { {"define_as", o.define_as} }
				-- and copies the target mindstar's on set complete
				self.on_set_complete = o.on_set_complete
				-- remove the mindstar and rewear it to trigger set bonuses
				local obj = who:takeoffObject(ms_inven, 1)
				who:wearObject(obj, true)
				return true
			end)
			return {id=true, used=true}
		end
	),
}

-- Caller's Set: For summoners!
 newEntity{
	power_source = {nature=true},  define_as = "MS_EGO_SET_CALLERS",
	name = "caller's ", prefix=true, instant_resolve=true,
	kr_display_name = "선도자 ",
	keywords = {callers=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
		resists_pen = {
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
			[DamageType.ACID] = resolvers.mbonus_material(8, 2),
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
	},
	set_list = { {"define_as", "MS_EGO_SET_SUMMONERS"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#GREEN#당신의 마석이 자연의 순수함과 공명합니다.")
		self:specialSetAdd({"wielder","nature_summon_regen"}, self.material_level)
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#마석의 연결이 끊어졌습니다.")
	end
}

 newEntity{
	power_source = {nature=true}, define_as = "MS_EGO_SET_SUMMONERS",
	name = "summoner's ", prefix=true, instant_resolve=true,
	kr_display_name = "소환수 ",
	keywords = {summoners=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 2),
		combat_mindcrit = resolvers.mbonus_material(5, 1),
	},
	set_list = { {"define_as", "MS_EGO_SET_CALLERS"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#GREEN#당신의 마석이 자연의 순수함과 공명합니다.")
		self:specialSetAdd({"wielder","nature_summon_max"}, 1)
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#마석의 연결이 끊어졌습니다.")
	end
}

-- Drake sets; these may seem odd but they're designed to keep sets from over writing each other when resolved
-- Basically it allows a set on suffix without a set_list, keeps the drop tables balanced without being bloated, and allows one master item to complete multiple subsets
newEntity{
	power_source = {nature=true}, define_as = "MS_EGO_SET_WYRM",
	name = "wyrm's ", prefix=true, instant_resolve=true,
	kr_display_name = "이무기 ",
	keywords = {wyrms=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 2),
			[DamageType.ACID] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 2),
			[DamageType.ACID] = resolvers.mbonus_material(8, 2),
		},
	},
	set_list = { {"define_as", "MS_EGO_SET_DRAKE_STAR"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#PURPLE#당신의 내부에서 활발한 이무기의 영혼이 느껴집니다!")
		self:specialSetAdd({"wielder","blind_immune"}, self.material_level / 10)
		self:specialSetAdd({"wielder","stun_immune"}, self.material_level / 10)
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#마석의 연결이 끊어졌습니다.")
	end,
	resolvers.charm("엘리멘탈 마석 속의 드레이크 호출 (이것은 다른 조합 보너스를 없앰)", 20,
		function(self, who, ms_inven)
			if who:getInven("PSIONIC_FOCUS") and who:getInven("PSIONIC_FOCUS")[1] == self then
				--@@
				local sn = self.kr_display_name or self.name
				game.logPlayer(who, "당신이 %s 염동력으로 잡고있는 동안 사용할 수 없습니다.", sn:addJosa("를"))
				return
			end		
			who:showEquipment("어느 마석의 드레이크를 호출합니까 (이것은 다른 조합 보너스를 파괴함)?", function(o) return o.subtype == "mindstar" and o.is_drake_star and o ~= self end, function(o)
				-- remove any existing sets from the mindstar
				o.set_list = nil
				o.on_set_complete = nil
				o.on_set_broken = nil
				o.define_as = nil

				-- create the set list
				o.define_as = "MS_EGO_SET_DRAKE_STAR"
				o.set_list = { {"define_as", "MS_EGO_SET_WYRM"} }

				-- define on_set_complete based on keywords
				if o.keywords.flames then
					o.on_set_complete = function(self, who)
						self:specialSetAdd({"wielder","global_speed_add"}, self.material_level / 100)
					end
				elseif o.keywords.frost then
					o.on_set_complete = function(self, who)
						self:specialSetAdd({"wielder","combat_armor"}, self.material_level * 3)
					end
				elseif o.keywords.sand then
					o.on_set_complete = function(self, who)
						self:specialSetAdd({"wielder","combat_physresist"}, self.material_level * 2)
						self:specialSetAdd({"wielder","combat_spellresist"}, self.material_level * 2)
						self:specialSetAdd({"wielder","combat_mentalresist"}, self.material_level * 2)
					end
				elseif o.keywords.storms then
					o.on_set_complete = function(self, who)
						local Stats = require "engine.interface.ActorStats"

						self:specialSetAdd({"wielder","inc_stats"}, {
							[Stats.STAT_STR] = self.material_level,
							[Stats.STAT_DEX] = self.material_level,
							[Stats.STAT_CON] = self.material_level,
							[Stats.STAT_MAG] = self.material_level,
							[Stats.STAT_WIL] = self.material_level,
							[Stats.STAT_CUN] = self.material_level,
						})
					end
				end

				-- rewear the wyrm star to trigger set bonuses
				local obj = who:takeoffObject(ms_inven, 1)
				who:wearObject(obj, true, true)
				return true
			end)
			return {id=true, used=true}
		end
	),
}

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of flames", suffix=true, instant_resolve=true,
	kr_display_name = "불꽃의 ",
	keywords = {flames=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
		},
		inc_damage={
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
		},
	},
}

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of frost", suffix=true, instant_resolve=true,
	kr_display_name = "냉기의 ",
	keywords = {frost=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
		},
		inc_damage={
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
		},
	},
}

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of sand", suffix=true, instant_resolve=true,
	kr_display_name = "모래의 ",
	keywords = {sand=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
		inc_damage={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
	},
}

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of storms", suffix=true, instant_resolve=true,
	kr_display_name = "폭풍의 ",
	keywords = {storms=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 2),
		},
		inc_damage={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 2),
		},
	},
}

-- Mentalist Set: For a yet to be written psi class and/or Mindslayers
 newEntity{
	power_source = {psionic=true},  define_as = "MS_EGO_SET_DREAMERS",
	name = "dreamer's ", prefix=true, instant_resolve=true,
	kr_display_name = "몽상가 ",
	keywords = {dreamers=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(8, 2),
		max_psi = resolvers.mbonus_material(40, 10),
		resists = { [DamageType.MIND] = resolvers.mbonus_material(20, 5), }
	},
	set_list = { {"define_as", "MS_EGO_SET_EPIPHANOUS"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#YELLOW#당신의 마석이 염력과 공명합니다.")
		self:specialSetAdd({"wielder","psi_regen"}, self.material_level / 10)
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#마석의 연결이 끊어졌습니다.")
	end
}

 newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_EPIPHANOUS",
	name = "epiphanous ", prefix=true, instant_resolve=true,
	kr_display_name = "계시 ",
	keywords = {epiphanous=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(5, 1),
		combat_mindcrit = resolvers.mbonus_material(5, 1),
		inc_damage = { [DamageType.MIND] = resolvers.mbonus_material(20, 5), },
	},
	set_list = { {"define_as", "MS_EGO_SET_DREAMERS"} },
	on_set_complete = function(self, who)
		game.logPlayer(who, "#YELLOW#당신의 마석이 염력과 공명합니다.")
		self:specialSetAdd({"wielder","psi_on_crit"}, self.material_level)
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#마석의 연결이 끊어졌습니다.")
	end
}

-- Mitotic Set: Single Mindstar that splits in two
 newEntity{
	power_source = {nature=true},
	name = "mitotic ", prefix=true, instant_resolve=true,
	kr_display_name = "유사분열 ",
	keywords = {mitotic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45, -- Rarity is high because melee based mindstar use is rare and you get two items out of one drop
	cost = 10,  -- cost is very low to discourage players from splitting them to make extra gold..  because that would be tedious and unfun
	combat = {
		physcrit = resolvers.mbonus_material(10, 2),
		melee_project = { [DamageType.ACID_BLIND]= resolvers.mbonus_material(15, 5), [DamageType.SLIME]= resolvers.mbonus_material(15, 5),},
	},
	resolvers.charm("마석을 둘로 나눔", 1,
		function(self, who)
			-- Check for free slot first
			--@@
			local sn = self.kr_display_name or self.name
			if who:getFreeHands() == 0 then
				game.logPlayer(who, "당신이 %s 나누려면 빈손이 필요합니다", sn:addJosa("를"))
			return
			end

			if who:getInven("PSIONIC_FOCUS") and who:getInven("PSIONIC_FOCUS")[1] == self then
				game.logPlayer(who, "당신은 %s 염동력으로 잡고 있는 동안 나눌 수 없습니다.", sn:addJosa("를"))
				return
			end

			local o = self

			-- Remove some properties before cloning
			o.cost = self.cost / 2 -- more don't split for extra gold discouragement
			o.max_power = nil
			o.power_regen = nil
			o.use_power = nil
			local o2 = o:clone()

			-- Build the item set
			o.define_as = "MS_EGO_SET_MITOTIC_ACID"
			o2.define_as = "MS_EGO_SET_MITOTIC_SLIME"
			o.set_list = { {"define_as", "MS_EGO_SET_MITOTIC_SLIME"} }
			o2.set_list = { {"define_as", "MS_EGO_SET_MITOTIC_ACID"} }

			o.on_set_complete = function(self, who)
				self:specialWearAdd({"combat","burst_on_crit"}, { [engine.DamageType.ACID_BLIND] = 10 * self.material_level } )
				game.logPlayer(who, "#GREEN#마석의 맥동이 생명력과 동화됩니다.")
			end
			o.on_set_broken = function(self, who)
				game.logPlayer(who, "#SLATE#마석의 연결이 끊어졌습니다.")
			end

			o2.on_set_complete = function(self, who)
				self:specialWearAdd({"combat","burst_on_crit"}, { [engine.DamageType.SLIME] = 10 * self.material_level } )
			end

			-- Wearing the second mindstar will complete the set and thus update the first mindstar
			who:wearObject(o2, true, true)

			-- Because we're removing the use_power we're not returning that it was used; instead we'll have the actor use energy manually
			who:useEnergy()
		end
	),
}

-- Wrathful Set: Geared towards Afflicted
newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_HATEFUL",
	name = "hateful ", prefix=true, instant_resolve=true,
	kr_display_name = "불쾌한 ",
	keywords = {hateful=true},
	level_range = {30, 50},
	greater_ego =1,
	rarity = 35,
	cost = 35,
	wielder = {
		inc_damage={
			[DamageType.MIND] = resolvers.mbonus_material(20, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(20, 5),
		},
		resists_pen={
			[DamageType.MIND] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		inc_damage_type = {humanoid=resolvers.mbonus_material(20, 5)},
	},
	set_list = { {"define_as", "MS_EGO_SET_WRATHFUL"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","combat_mindpower"}, 2 * self.material_level)
		game.logPlayer(who, "#GREY#당신은 마석으로인해 불쾌함이 커짐을 느낍니다.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#마석의 공명이 희미해집니다.")
	end,
}

 newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_WRATHFUL",
	name = "wrathful ", prefix=true, instant_resolve=true,
	kr_display_name = "격노한 ",
	keywords = {wrath=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		psi_on_crit = resolvers.mbonus_material(5, 1),
		hate_on_crit = resolvers.mbonus_material(5, 1),
		combat_mindcrit = resolvers.mbonus_material(10, 2),
	},
	set_list = { {"define_as", "MS_EGO_SET_HATEFUL"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","max_hate"}, 2 * self.material_level)
		game.logPlayer(who, "#GREY#당신은 마석으로인해 불쾌함이 커짐을 느낍니다.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#SLATE#마석의 공명이 희미해집니다.")
	end,
}