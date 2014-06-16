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

local Object = require "engine.Object"
local Dialog = require "engine.ui.Dialog"

local curses_detrimental
local curses_beneficial
local curses_weapon

newTalent{
	name = "Defiling Touch",
	kr_name = "더럽혀진 손길",
	type = {"cursed/cursed-aura", 1},
	require = cursed_lev_req1,
	points = 5,
	cooldown = 0,
	no_energy = true,
	no_npc_use = true,
	--no_unlearn_last = true,
	-- list of all curses
	getCurses = function(self, t)
		return { self.EFF_CURSE_OF_CORPSES, self.EFF_CURSE_OF_MADNESS, self.EFF_CURSE_OF_MISFORTUNE, self.EFF_CURSE_OF_NIGHTMARES, self.EFF_CURSE_OF_SHROUDS }
	end,
	cursePenalty = function(self, t)
		return self:combatTalentLimit(math.max(1, self:getTalentLevel(t)-4), 0, 1, 0.64)
	end,
	-- tests whether or not an item can be cursed (takes into account current talent level unless ignoreLevel = true)
	canCurseItem = function(self, t, item, level)
		if not item:wornInven() then return false end

		-- Godslayers are far too powerful to be affected
		if item.godslayer then return false end
		if item.no_curses then return false end

		-- possible slots:
		-- body, head, feet, hands, cloak, belt (armor)
		-- mainhand (weapon), offhand (weapon/armor;shield), psionic (weapon)
		-- finger (X2), neck (jewelry)
		-- lite (lite), tool (tool), quiver (ammo), gem (alchemist-gem)
		level = level or self:getTalentLevel(t)
		if level >= 1 and item.type == "weapon" then return true end
		if level >= 2 and item.type == "armor" and (item.slot == "BODY" or item.slot == "CLOAK")  then return true end
		if level >= 3 and item.type == "armor" and (item.slot == "HEAD" or item.slot == "OFFHAND")  then return true end
		if level >= 4 and item.type == "armor" and (item.slot == "HANDS" or item.slot == "FEET" or item.slot == "BELT")  then return true end
		if level >=6 and item.type == "jewelry" and item.slot == "FINGER" then return true end
		if level >=7 and item.type == "jewelry" and item.slot == "NECK" then return true end
		if level >=8 and item.type == "lite" and item.slot == "LITE" then return true end
		if level >=9 and (item.type == "charm" or item.type == "tool") and item.slot == "TOOL" then return true end
		if level >=10 and item.slot == "QUIVER" and (item.type == "alchemist-gem" or item.type == "ammo")  then return true end

		return false
	end,
	-- curses an item
	curseItem = function(self, t, item)
		if item.curse then return end
		if not t.canCurseItem(self, t, item) then return end

		-- apply the curse
		if item.define_as == "CLOAK_DECEPTION" then
			-- cloak of deception is always Corpses..
			item.curse = self.EFF_CURSE_OF_CORPSES
		else
			local curses = t.getCurses(self, t)
			item.curse = rng.table(curses)
		end

		local def = self.tempeffect_def[item.curse]
		item.special = true
		item.add_name = (item.add_name or "").." ("..(def.kr_short_desc or def.short_desc)..")"
	end,
	-- curses all items on the floor
	curseFloor = function(self, t, x, y)
		local i = 1
		local item = game.level.map:getObject(x, y, i)
		while item do
			t.curseItem(self, t, item)

			i = i + 1
			item = game.level.map:getObject(x, y, i)
		end
	end,
	-- curses all items in inventory
	curseInventory = function(self, t)
		for id, inven in pairs(self.inven) do
			for i, item in ipairs(inven) do
				t.curseItem(self, t, item)
			end
		end
	end,
	-- sets a cursed aura (+2 curse bonus)
	setCursedAura = function(self, t, curse)
		self.cursed_aura = curse
		t.updateCurses(self, t)
	end,
	-- gets the name of the currently set cursed aura
	getCursedAuraName = function(self, t)
		if not self.cursed_aura then
			return "없음"
		else
			return (self.tempeffect_def[self.cursed_aura].kr_name or self.tempeffect_def[self.cursed_aura].desc) 
		end
	end,
	on_onWear = function(self, t, o)
		t.updateCurses(self, t)
	end,
	on_onTakeOff = function(self, t, o)
		t.updateCurses(self, t)
	end,

	-- chooses whether the player accepts the cursed aura tree when a cursable item is found. only offered once for Afflicted classes
	chooseCursedAuraTree = function(self, t)
		local choose = false
		local x, y, i = self.x, self.y, 1
		local item = game.level.map:getObject(x, y, i)
		while item and not choose do
			if t.canCurseItem(self, t, item, 1) then
				choose = true
			else
				i = i + 1
				item = game.level.map:getObject(x, y, i)
			end
		end

		if choose then
			game.player:runStop()
			game.player:restStop()

			-- don't bother the player when there is an enemy near
			local grids = core.fov.circle_grids(self.x, self.y, 10, true)
			for x, yy in pairs(grids) do
				for y, _ in pairs(grids[x]) do
					local actor = game.level.map(x, y, Map.ACTOR)
					if actor and self:reactionToward(actor) < 0 and self:hasLOS(actor.x, actor.y) then
						choose = false
					end
				end
			end

			if choose then
				self.chooseCursedAuraTree = nil
				Dialog:yesnoLongPopup(
					"저주받은 자의 저주받은 운명",
					("근처에 놓여있는 %s에 눈이 갔다. 하지만, 그 장비에 딱히 관심이 있었던 것은 아니다. 자신의 내면에서 갑자기 타오르는 무언가를 느꼈기 때문이다. 평소와 같이, 당신은 이 느낌을 무시하였다. 이 느낌 자체는 그다지 새로운 것이 아니었지만, 이 느낌과 함께 찾아온 힘만은 자신을 압도할 듯 흘러나왔다. 당신은 무의식적으로 그 장비를 저주하고, 오염시키기 위해 손을 뻗었다. 그러자, 그 장비가 변화하기 시작하였다. 장비가 원래 지니고 있던 색은 옅어지고, 끝없는 증오의 색으로 물들기 시작하였다. 잠시 동안, 당신은 주춤하였다. 이 저주의 징후를 견뎌내고 다시는 저주가 발현하지 못하게 만들 것인지, 아니면 더 깊은 광기로 빠져들 것인지. 선택할 시간이 다가온 것 같다."):format((item.kr_name or item.name)),
					300,
					function(ret)
						if ret then
							Dialog:simpleLongPopup("저주받은 자의 저주받은 운명", ("%s의 본래 색깔은 완전히 사라지고, 오염되었다. 갑자기 증오의 기운이 자신의 주변을 감싸고 있는 것을 느꼈으며, 이제 자신은 진정으로 저주받았다는 것을 느꼈다. 저주받은 기운 기술 계열을 얻었으며 더럽혀진 손길 기술을 1 레벨 얻었지만, 의지 능력치가 2 감소하였다."):format((item.kr_name or item.name)), 300)
							self:learnTalentType("cursed/cursed-aura", true)
							self:learnTalent(self.T_DEFILING_TOUCH, true, 1, {no_unlearn=true})
							self.inc_stats[self.STAT_WIL] = self.inc_stats[self.STAT_WIL] - 2
							self:onStatChange(self.STAT_WIL, -2)
							t.curseItem(self, t, item)
							t.curseInventory(self, t)
							t.curseFloor(self, t, self.x, self.y)
							t.updateCurses(self, t, false)
						else
							Dialog:simplePopup("저주받은 자의 저주받은 운명", ("%s의 색깔이 정상으로 돌아왔으며, 들끓던 증오심도 사라졌다."):format((item.kr_name or item.name)))
						end
					end,
					"장비에 자신의 증오를 풀어놓는다",
					"이 고통과 증오를 억누른다")
			end
		end
	end,
	-- updates the state of all curse effects
	updateCurses = function(self, t, forceUpdateEffects)
		local curses = t.getCurses(self, t)
		local itemCounts = {}
		local armorCount = 0

		-- count curses in worn items, but only if we can still curse that type of item
		for id, inven in pairs(self.inven) do
			if self.inven_def[id].is_worn then
				for i, item in ipairs(inven) do
					if item.curse and t.canCurseItem(self, t, item) then
						if item.type == "armor" then armorCount = armorCount + 1 end

						itemCounts[item.curse] = (itemCounts[item.curse] or 0) + 1
					end
				end
			end
		end

		-- add cursed aura
		if self.cursed_aura then
			itemCounts[self.cursed_aura] = (itemCounts[self.cursed_aura] or 0) + 2
		end

		-- update cursed effect levels
		local tDarkGifts = self:getTalentFromId(self.T_DARK_GIFTS)
		for i, curse in ipairs(curses) do
			local eff = self:hasEffect(curse)
			local level = itemCounts[curse] and (itemCounts[curse] + self:callTalent(self.T_DARK_GIFTS, "curseBonusLevel")) or 0
			local penalty = t.cursePenalty(self, t)
			local currentLevel = eff and eff.level or 0
			local currentPenalty = eff and eff.Penalty or 1
			--print("* curse:", self.tempeffect_def[curse].desc, currentLevel, "->", level, eff)
			if currentLevel ~= level or currentPenalty ~= penalty or forceUpdateEffects then
				if eff then
					self:removeEffect(curse, false, true)
				end

				-- preserve the old eff values when re-starting the effect
				if level > 0 then
					if not eff then
						eff = { def = self.tempeffect_def[curse] }
					end
					eff.level = level
					eff.Penalty = penalty
					eff.BonusPower = BonusPower
					eff.unlockLevel = math.min(5, tDarkGifts and self:getTalentLevelRaw(tDarkGifts) or 0)
					self:setEffect(curse, 1, eff)
				end

				self.changed = true
			end
		end
	end,
	passives = function(self, t, p) -- force update on talent mastery changes
	end,
	on_learn = function(self, t)
		t.curseInventory(self, t)
		t.curseFloor(self, t, self.x, self.y)
		t.updateCurses(self, t)
	end,
	on_unlearn = function(self, t)
		-- turn off cursed aura (which gets disabled, but does not turn off)
		t.setCursedAura(self, t, nil)
	end,
	on_pre_use = function(self, t, silent)
		return self:getTalentLevelRaw(t) >= 5
	end,
	-- selects a new cursed aura (+2 curse bonus)
	action = function(self, t)
		local cursedAuraSelect = require("mod.dialogs.CursedAuraSelect").new(self)
		game:registerDialog(cursedAuraSelect)
	end,
	info = function(self, t)
		return ([[더럽혀진 자신의 손길은 주변의 모든 것들을 오염시킵니다. 저주받은 장비를 장착하면 저주의 효과를 받게 되며, 같은 저주에 걸린 장비를 다수 착용하면 저주의 레벨이 증가합니다. 최초의 저주는 해롭지만, 저주가 중첩되면 강력한 강화 효과를 얻을 수 있습니다.
		어둠의 선물 기술을 통해 더 높은 레벨의 저주 효과를 받을 수 있게 됩니다.
		저주의 기운은 장비에 스며드며, 실질 기술 레벨이 높아지면 더 다양한 장비를 오염시킬 수 있게 됩니다.
		실질 기술 레벨 1  -- 무기
		실질 기술 레벨 2  -- 옷, 망토
		실질 기술 레벨 3  -- 방패, 모자
		실질 기술 레벨 4  -- 장갑, 신발, 허리띠
		실질 기술 레벨 6  -- 반지
		실질 기술 레벨 7  -- 부적/목걸이
		실질 기술 레벨 8  -- 조명
		실질 기술 레벨 9  -- 도구/토템/주술고리/마법봉
		실질 기술 레벨 10 -- 탄환
		기술 레벨이 5 이상일 경우, 자신의 주변에 저주의 기운을 둘러 선택한 저주의 레벨을 2 올릴 수 있게 됩니다. (현재 : %s)
		또한 실질 기술 레벨이 5 이상일 경우, 저주의 부정적인 효과를 감소시킬 수 있게 됩니다. (현재 감소율 : %d%%)]]): 
		format(t.getCursedAuraName(self, t), (1-t.cursePenalty(self, t))*100)
	end,
}

newTalent{
	name = "Dark Gifts",
	kr_name = "어둠의 선물",
	type = {"cursed/cursed-aura", 2},
	mode = "passive",
	require = cursed_lev_req2,
	no_unlearn_last = true,
	points = 5,
	curseBonusLevel = function(self, t)
		return self:combatTalentScale(math.max(0,self:getTalentLevel(t)-5), 1, 2.5) 
	end,
	on_learn = function(self, t)
		local tDefilingTouch = self:getTalentFromId(self.T_DEFILING_TOUCH)
		tDefilingTouch.updateCurses(self, tDefilingTouch, true)
	end,
	on_unlearn = function(self, t)
		local tDefilingTouch = self:getTalentFromId(self.T_DEFILING_TOUCH)
		tDefilingTouch.updateCurses(self, tDefilingTouch, true)
	end,
	info = function(self, t)
		local level = math.min(4, self:getTalentLevelRaw(t))
		local xs = t.curseBonusLevel(self,t)
		return ([[저주가 어둠의 선물을 가져다줍니다. 최대 %d 레벨의 저주 효과를 볼 수 있게 되며, 기술 레벨이 5 이상일 경우 저주에 의한 행운 감소량이 1 로 줄어듭니다.
		또한 실질 기술 레벨이 5 이상일 경우, 저주의 레벨을 강화시킬 수 있게 됩니다. (현재 강화 수준 : %0.1f)]]): 
		format(level, xs)
	end,
}

newTalent{
	name = "Ruined Earth",
	kr_name = "망가진 대지",
	type = {"cursed/cursed-aura", 3},
	require = cursed_lev_req3,
	points = 5,
	cooldown = 30,
	range = function(self, t)
		return math.min(8, 2 + math.floor(self:getTalentLevel(t)))
	end,
	random_ego = "defensive",
	tactical = { DEFEND = 2 },
	getDuration = function(self, t)
		return math.min(8, 3 + math.floor(self:getTalentLevel(t)))
	end,
	getIncDamage = function(self, t)
		return math.floor(math.min(60, 22 + (math.sqrt(self:getTalentLevel(t)) - 1) * 23))
	end,
	getPowerPercent = function(self, t)
		return math.floor((math.sqrt(self:getTalentLevel(t)) - 1) * 20)
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		local incDamage = t.getIncDamage(self, t)

		-- project first to immediately start the effect
		local tg = {type="ball", radius=range}
		self:project(tg, self.x, self.y, DamageType.WEAKNESS, { incDamage=incDamage, dur=3 })

		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.WEAKNESS, { incDamage=incDamage, dur=3 },
			range,
			5, nil,
			engine.MapEffect.new{alpha=100, color_br=120, color_bg=120, color_bb=120, effect_shader="shader_images/darkness_effect.png"}
		)

		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		local incDamage = t.getIncDamage(self, t)

		return ([[%d 턴 동안 자신의 주변 %d 칸 반경의 땅에 저주를 내립니다. 저주받은 땅 위에 선 자들은 약화되어, 피해량이 %d%% 감소하게 됩니다. 시전자도 이 기술의 영향을 받습니다.]]):format(duration, range, incDamage) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Cursed Sentry",
	kr_name = "저주받은 파수꾼",
	type = {"cursed/cursed-aura", 4},
	require = cursed_lev_req4,
	points = 5,
	cooldown = 40,
	range = 5,
	no_npc_use = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 8, 16))	end,
	getAttackSpeed = function(self, t) return self:combatTalentScale(t, 0.6, 1.4) end,
	action = function(self, t)
		local inven = self:getInven("INVEN")
		local found = false
		for i, obj in pairs(inven) do
			if type(obj) == "table" and obj.type == "weapon" then
				found = true
				break
			end
		end
		if not found then
			game.logPlayer(self, "소지 중인 무기가 없으면, %s의 사용은 불가능합니다!", (t.kr_name or t.name))
			return false
		end

		-- select the location
		local range = self:getTalentRange(t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, x, y = self:canProject(tg, tx, ty)
		if game.level.map(x, y, Map.ACTOR) or game.level.map:checkEntity(x, y, game.level.map.TERRAIN, "block_move") then return nil end

		-- select the item
		local d = self:showInventory("어떤 무기를 파수꾼으로 만듭니까?", inven,
			function(o)
				return o.type == "weapon"
			end, nil)
				d.action = function(o, item)
				d.used_talent = true
				d.selected_object = o
				d.selected_item = item

				return false
			end

		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent, self.selected_object, d.selected_item) end
		local used_talent, o, item = coroutine.yield()
		if not used_talent then return nil end

		local result = self:removeObject(inven, item)

		local NPC = require "mod.class.NPC"
		local sentry = NPC.new {
			type = "construct", subtype = "weapon",
			display = o.display, color=o.color, image = o.image, blood_color = colors.GREY,
			name = "살아 움직이는  "..o:getName(), -- bug fix --@ 이유는 모르겠지만, kr_name을 추가하면 오류가 발생하여 그냥 name을 한글화 했음
			faction = self.faction,
			desc = "살아 움직이는 저주에 걸린 무기입니다. 다음 희생자를 찾고 있는 것 같습니다.",
			faction = self.faction,
			body = { INVEN = 10, MAINHAND=1, QUIVER=1 },
			rank = 2,
			size_category = 1,

			autolevel = o.combat.wil_attack and "summoner" or "warrior",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, },

			max_life = 50 + self.max_life*self:combatTalentLimit(t, 1, 0.04, 0.17),  -- Add % of summoner's life < 100%
			life_rating = 3,
			stats = o.combat.wil_attack and {wil= 20, cun = 20, mag=10, con=10} or {str=20, dex=20, mag=10, con=10},
			combat = { dam=1, atk=1, apr=1 },
			combat_armor = math.max(100,50 + self.level),
			combat_armor_hardiness = math.min(70,5*self:getTalentLevel(t)),
			combat_def = math.max(50,self.level),
			inc_damage = table.clone(self.inc_damage or {}, true),
			resists_pen = table.clone(self.resists_pen or {}, true),
			
			combat_physspeed = t.getAttackSpeed(self, t),
			infravision = 10,

			resists = { all = self:combatTalentLimit(t, 100, 71, 75), },
			cut_immune = 1,
			blind_immune = 1,
			fear_immune = 1,
			poison_immune = 1,
			disease_immune = 1,
			stone_immune = 1,
			see_invisible = 30,
			no_breath = 1,
			disarm_immune = 1,
			never_move = 1,
			--no_drops = true, -- remove to drop the weapon

			resolvers.talents{
				[Talents.T_WEAPON_COMBAT]={base=1, every=10},
				[Talents.T_WEAPONS_MASTERY]={base=1, every=10},
				[Talents.T_KNIFE_MASTERY]={base=1, every=10},
				[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=1, every=10},
				[Talents.T_STAFF_MASTERY]={base=1, every=10},
				[Talents.T_BOW_MASTERY]={base=1, every=10},
				[Talents.T_SLING_MASTERY]={base=1, every=10},
				[Talents.T_PSIBLADES]=o.combat.wil_attack and {base=1, every=10},
				[Talents.T_SHOOT]=1,
			},
			o.combat.wil_attack and resolvers.sustains_at_birth(),
			summoner = self,
			summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			summon_quiet = true,

			on_die = function(self, who)
				game.logSeen(self, "#F53CBE#%s 재가 되어 사라집니다.", (self.kr_name or self.name):capitalize():addJosa("가"))
			end,
		}

		sentry:resolve()
		sentry:resolve(nil, true)
		sentry:forceLevelup(self.level)

		-- Auto alloc some stats to be able to wear it
		if rawget(o, "require") and rawget(o, "require").stat then
			for s, v in pairs(rawget(o, "require").stat) do
				if sentry:getStat(s) < v then
					sentry.unused_stats = sentry.unused_stats - (v - sentry:getStat(s))
					sentry:incStat(s, v - sentry:getStat(s))
				end
			end
		end

		result = sentry:wearObject(o, true, false)
		if o.archery then
			local qo = nil
			if o.archery == "bow" then qo = game.zone:makeEntity(game.level, "object", {type="ammo", subtype="arrow"}, nil, true)
			elseif o.archery == "sling" then qo = game.zone:makeEntity(game.level, "object", {type="ammo", subtype="shot"}, nil, true)
			end
			if qo then sentry:wearObject(qo, true, false) end
		end


		game.zone:addEntity(game.level, sentry, "actor", x, y)

		sentry.no_party_ai = true
		sentry.unused_stats = 0
		sentry.unused_talents = 0
		sentry.unused_generics = 0
		sentry.unused_talents_types = 0
		sentry.no_points_on_levelup = true
		if game.party:hasMember(self) then
			sentry.remove_from_party_on_death = true
			game.party:addMember(sentry, { control="no", type="summon", title="Summon", kr_title="소환수"})
		end

		game:playSoundNear(self, "talents/spell_generic")

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local attackSpeed = 100/t.getAttackSpeed(self, t)

		return ([[소지하고 있는 무기 하나에 살아 움직이는 저주를 걸어, 근처에 둡니다. 이 무적에 가까운 무기 파수꾼은 %d 턴 동안 근처의 모든 적들을 공격합니다. 저주가 끝나면, 무기는 그 자리에 떨어집니다. 
		무기의 공격 속도 : %d%% (1 턴에 1 번 공격할 경우를 100%% 로 보며, %% 수치가 작아질수록 공격 속도는 빨라집니다)]]):format(duration, attackSpeed)
	end,
}
