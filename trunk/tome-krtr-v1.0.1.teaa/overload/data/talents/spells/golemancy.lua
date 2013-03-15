-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

local Chat = require "engine.Chat"

function getGolem(self)
	if game.level:hasEntity(self.alchemy_golem) then
		return self.alchemy_golem, self.alchemy_golem
	elseif self:hasEffect(self.EFF_GOLEM_MOUNT) then
		return self, self.alchemy_golem
	end
end

local function makeGolem(self)
	self:attr("summoned_times", 100)
	local g = require("mod.class.NPC").new{
		type = "construct", subtype = "golem",
		display = 'g', color=colors.WHITE, image = "npc/alchemist_golem.png",
		moddable_tile = "runic_golem",
		moddable_tile_nude = true,
		moddable_tile_base = resolvers.generic(function() return "base_0"..rng.range(1, 5)..".png" end),
		level_range = {1, 50}, exp_worth=0,
		life_rating = 13,
		never_anger = true,
		save_hotkeys = true,

		combat = { dam=10, atk=10, apr=0, dammod={str=1} },

		body = { INVEN = 1000, QS_MAINHAND = 1, QS_OFFHAND = 1, MAINHAND = 1, OFFHAND = 1, BODY=1, GEM=2 },
		equipdoll = "alchemist_golem",
		infravision = 10,
		rank = 3,
		size_category = 4,

		resolvers.talents{
			[Talents.T_ARMOUR_TRAINING]=3,
			[Talents.T_GOLEM_ARMOUR]=1,
			[Talents.T_WEAPON_COMBAT]=1,
			[Talents.T_MANA_POOL]=1,
			[Talents.T_STAMINA_POOL]=1,
			[Talents.T_GOLEM_KNOCKBACK]=1,
			[Talents.T_GOLEM_DESTRUCT]=1,
		},

		resolvers.equip{
			{type="weapon", subtype="battleaxe", autoreq=true, id=true, ego_chance=-1000},
			{type="armor", subtype="heavy", autoreq=true, id=true, ego_chance=-1000}
		},

		talents_types = {
			["golem/fighting"] = true,
			["golem/arcane"] = true,
		},
		talents_types_mastery = {
			["technique/combat-training"] = 0.3,
			["golem/fighting"] = 0.3,
			["golem/arcane"] = 0.3,
		},
		forbid_nature = 1,
		inscription_restrictions = { ["inscriptions/runes"] = true, },
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=100}),

		hotkey = {},
		hotkey_page = 1,
		move_others = true,

		ai = "tactical",
		ai_state = { talent_in=1, ai_move="move_astar", ally_compassion=10 },
		ai_tactic = resolvers.tactic"tank",
		stats = { str=14, dex=12, mag=12, con=12 },

		-- No natural exp gain
		gainExp = function() end,
		forceLevelup = function(self) if self.summoner then return mod.class.Actor.forceLevelup(self, self.summoner.level) end end,

		-- Break control when losing LOS
		on_act = function(self)
			if game.player ~= self then return end
			if not self.summoner.dead and not self:hasLOS(self.summoner.x, self.summoner.y) then
				if not self:hasEffect(self.EFF_GOLEM_OFS) then
					self:setEffect(self.EFF_GOLEM_OFS, 8, {})
				end
			else
				if self:hasEffect(self.EFF_GOLEM_OFS) then
					self:removeEffect(self.EFF_GOLEM_OFS)
				end
			end
		end,

		on_can_control = function(self, vocal)
			if not self:hasLOS(self.summoner.x, self.summoner.y) then
				if vocal then game.logPlayer(game.player, "골렘이 시야 밖에 있어, 직접 제어가 불가능합니다.") end
				return false
			end
			return true
		end,

		unused_stats = 0,
		unused_talents = 0,
		unused_generics = 0,
		unused_talents_types = 0,

		no_points_on_levelup = function(self)
			self.unused_stats = self.unused_stats + 2
			if self.level >= 2 and self.level % 3 == 0 then self.unused_talents = self.unused_talents + 1 end
		end,

		keep_inven_on_death = true,
--		no_auto_resists = true,
		open_door = true,
		cut_immune = 1,
		blind_immune = 1,
		fear_immune = 1,
		poison_immune = 1,
		disease_immune = 1,
		stone_immune = 1,
		see_invisible = 30,
		no_breath = 1,
		can_change_level = true,
	}

	if self.no_points_on_levelup then
		g.max_level = nil
		g.no_points_on_levelup = self.no_points_on_levelup
	end

	return g
end

newTalent{
	name = "Refit Golem",
	kr_name = "골렘 정비",
	type = {"spell/golemancy-base", 1},
	require = spells_req1,
	points = 1,
	cooldown = 20,
	mana = 10,
	no_npc_use = true,
	no_unlearn_last = true,
	getHeal = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		return 50 + self:combatTalentSpellDamage(self.T_GOLEM_POWER, 15, 550, ((ammo and ammo.alchemist_power or 0) + self:combatSpellpower()) / 2)
	end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 and not self.innate_alchemy_golem then
			t.invoke_golem(self, t)
		end
	end,
	on_unlearn = function(self, t)
		if self:getTalentLevelRaw(t) == 0 and self.alchemy_golem and not self.innate_alchemy_golem then
			if game.party:hasMember(self) and game.party:hasMember(self.alchemy_golem) then game.party:removeMember(self.alchemy_golem) end
			self.alchemy_golem:disappear()
			self.alchemy_golem = nil
		end
	end,
	invoke_golem = function(self, t)
		self.alchemy_golem = game.zone:finishEntity(game.level, "actor", makeGolem(self))
		if game.party:hasMember(self) then
			game.party:addMember(self.alchemy_golem, {
				control="full", type="golem", title="Golem", important=true,
				orders = {target=true, leash=true, anchor=true, talents=true, behavior=true},
			})
		end
		if not self.alchemy_golem then return end
		self.alchemy_golem.faction = self.faction
		self.alchemy_golem.kr_name = "골렘 ("..(self.kr_name or self.name).."의 부하)"
		self.alchemy_golem.name = "golem (servant of "..self.name..")"
		self.alchemy_golem.summoner = self
		self.alchemy_golem.summoner_gain_exp = true

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "골렘이 있을 자리가 없습니다!")
			return
		end
		game.zone:addEntity(game.level, self.alchemy_golem, "actor", x, y)
	end,
	action = function(self, t)
		if not self.alchemy_golem then
			t.invoke_golem(self, t)
			return
		end

		local wait = function()
			local co = coroutine.running()
			local ok = false
			self:restInit(20, "refitting", "refitted", function(cnt, max)
				if cnt > max then ok = true end
				coroutine.resume(co)
			end)
			coroutine.yield()
			if not ok then
				game.logPlayer(self, "방해를 받았습니다!")
				return false
			end
			return true
		end

		local ammo = self:hasAlchemistWeapon()

		-- talk to the golem
		if game.level:hasEntity(self.alchemy_golem) and self.alchemy_golem.life >= self.alchemy_golem.max_life then
			local chat = Chat.new("alchemist-golem", self.alchemy_golem, self, {golem=self.alchemy_golem, player=self})
			chat:invoke()

		-- heal the golem
		elseif (game.level:hasEntity(self.alchemy_golem) or self:hasEffect(self.EFF_GOLEM_MOUNT)) and self.alchemy_golem.life < self.alchemy_golem.max_life then
			if not ammo or ammo:getNumber() < 2 then
				game.logPlayer(self, "골렘을 수리하려면 2 개의 연금술용 보석을 손에 들고있어야 합니다.")
				return
			end
			for i = 1, 2 do self:removeObject(self:getInven("QUIVER"), 1) end
			self.alchemy_golem:attr("allow_on_heal", 1)
			self.alchemy_golem:heal(t.getHeal(self, t))
			self.alchemy_golem:attr("allow_on_heal", -1)

		-- resurrect the golem
		elseif not self:hasEffect(self.EFF_GOLEM_MOUNT) then
			if not ammo or ammo:getNumber() < 15 then
				game.logPlayer(self, "골렘을 다시 만들어내려면 15 개의 연금술용 보석을 손에 들고있어야 합니다.")
				return
			end
			if not wait() then return end
			for i = 1, 15 do self:removeObject(self:getInven("QUIVER"), 1) end

			self.alchemy_golem.dead = nil
			if self.alchemy_golem.life < 0 then self.alchemy_golem.life = self.alchemy_golem.max_life / 3 end

			-- Find space
			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "골렘이 있을 자리가 없습니다!")
				return
			end
			game.zone:addEntity(game.level, self.alchemy_golem, "actor", x, y)
			self.alchemy_golem:setTarget(nil)
			self.alchemy_golem.ai_state.tactic_leash_anchor = self
			self.alchemy_golem:removeAllEffects()
		end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[자신만의 골렘, 이제 스스로 조립해보세요!
		- 골렘이 완전히 파괴되었다면, 시간을 들여 골렘을 다시 만들어냅니다. (연금술용 보석 15 개가 소모됩니다!)
		- 골렘이 손상되었다면, 골렘을 수리하여 생명력을 %d 회복시킵니다. (연금술용 보석 2 개가 소모됩니다) 
		생명력 회복량은 주문력, 사용한 연금술용 보석, '골렘의 힘' 기술 레벨의 영향을 받아 증가합니다.
		- 골렘이 파괴도 손상도 되지 않았다면, 골렘의 이름을 다시 지어주거나 골렘의 장비, 보석을 바꿔줄 수 있습니다.]]):
		format(heal)
	end,
}

newTalent{
	name = "Golem Power",
	kr_name = "골렘의 힘",
	type = {"spell/golemancy", 1},
	mode = "passive",
	require = spells_req1,
	points = 5,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 and not self.innate_alchemy_golem then
			self:learnTalent(self.T_REFIT_GOLEM, true)
		end

		self.alchemy_golem:learnTalent(Talents.T_WEAPON_COMBAT, true, nil, {no_unlearn=true})
		self.alchemy_golem:learnTalent(Talents.T_WEAPONS_MASTERY, true, nil, {no_unlearn=true})
	end,
	on_unlearn = function(self, t)
		self.alchemy_golem:unlearnTalent(Talents.T_WEAPON_COMBAT, nil, nil, {no_unlearn=true})
		self.alchemy_golem:unlearnTalent(Talents.T_WEAPONS_MASTERY, nil, nil, {no_unlearn=true})

		if self:getTalentLevelRaw(t) == 0 and not self.innate_alchemy_golem then
			self:unlearnTalent(self.T_REFIT_GOLEM)
		end
	end,
	info = function(self, t)
		if not self.alchemy_golem then return "골렘의 무기 수련도가 오릅니다." end
		local rawlev = self:getTalentLevelRaw(t)
		local olda, oldd = self.alchemy_golem.talents[Talents.T_WEAPON_COMBAT], self.alchemy_golem.talents[Talents.T_WEAPONS_MASTERY]
		self.alchemy_golem.talents[Talents.T_WEAPON_COMBAT], self.alchemy_golem.talents[Talents.T_WEAPONS_MASTERY] = 1 + rawlev, rawlev
		local ta, td = self:getTalentFromId(Talents.T_WEAPON_COMBAT), self:getTalentFromId(Talents.T_WEAPONS_MASTERY)
		local attack = ta.getAttack(self.alchemy_golem, ta)
		local power = td.getDamage(self.alchemy_golem, td)
		local damage = td.getPercentInc(self.alchemy_golem, td)
		self.alchemy_golem.talents[Talents.T_WEAPON_COMBAT], self.alchemy_golem.talents[Talents.T_WEAPONS_MASTERY] = olda, oldd
		return ([[골렘의 무기 수련도가 올라, 무기의 정확도가 %d / 물리력이 %d / 피해량이 %d%% 상승합니다.]]):
		format(attack, power, 100 * damage)
	end,
}

newTalent{
	name = "Golem Resilience",
	kr_name = "골렘의 활력",
	type = {"spell/golemancy", 2},
	mode = "passive",
	require = spells_req2,
	points = 5,
	on_learn = function(self, t)
		self.alchemy_golem:learnTalent(Talents.T_THICK_SKIN, true, nil, {no_unlearn=true})
		self.alchemy_golem:learnTalent(Talents.T_GOLEM_ARMOUR, true, nil, {no_unlearn=true})
		self.alchemy_golem.healing_factor = (self.alchemy_golem.healing_factor or 1) + 0.1
	end,
	on_unlearn = function(self, t)
		self.alchemy_golem:unlearnTalent(Talents.T_THICK_SKIN, nil, nil, {no_unlearn=true})
		self.alchemy_golem:unlearnTalent(Talents.T_GOLEM_ARMOUR, nil, nil, {no_unlearn=true})
		self.alchemy_golem.healing_factor = (self.alchemy_golem.healing_factor or 1) - 0.1
	end,
	info = function(self, t)
		if not self.alchemy_golem then return "골렘의 갑옷 수련도와 저항력이 오릅니다." end
		local rawlev = self:getTalentLevelRaw(t)
		local oldh, olda = self.alchemy_golem.talents[Talents.T_THICK_SKIN], self.alchemy_golem.talents[Talents.T_GOLEM_ARMOUR]
		self.alchemy_golem.talents[Talents.T_THICK_SKIN], self.alchemy_golem.talents[Talents.T_GOLEM_ARMOUR] = rawlev, 1 + rawlev
		local th, ta, ga = self:getTalentFromId(Talents.T_THICK_SKIN), self:getTalentFromId(Talents.T_ARMOUR_TRAINING), self:getTalentFromId(Talents.T_GOLEM_ARMOUR)
		local res = th.getRes(self.alchemy_golem, th)
		local heavyarmor = ta.getArmor(self.alchemy_golem, ta) + ga.getArmor(self.alchemy_golem, ga)
		local hardiness = ta.getArmorHardiness(self.alchemy_golem, ta) + ga.getArmorHardiness(self.alchemy_golem, ga)
		local crit = ta.getCriticalChanceReduction(self.alchemy_golem, ta) + ga.getCriticalChanceReduction(self.alchemy_golem, ga)
		self.alchemy_golem.talents[Talents.T_THICK_SKIN], self.alchemy_golem.talents[Talents.T_GOLEM_ARMOUR] = oldh, olda

		return ([[골렘의 갑옷 수련도와 저항력을 올려, 모든 속성 저항력이 %d%% 상승합니다.
		중갑이나 판갑을 입으면 추가적으로 방어도가 %d / 방어 효율이 %d%% 상승하며, 적에게 치명타를 맞을 확률이 %d%% 감소합니다.
		골렘의 치유 효율이 %d%% 상승하는 효과도 있으며, 골렘은 아무 제한 없이 판갑까지 착용할 수 있습니다.]]):
		format(res, heavyarmor, hardiness, crit, rawlev * 10)
	end,
}

newTalent{
	name = "Invoke Golem",
	kr_name = "골렘 호출",
	type = {"spell/golemancy",3},
	require = spells_req3,
	points = 5,
	mana = 10,
	cooldown = 20,
	no_npc_use = true,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 15, 50) end,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "골렘이 활성화되지 않았습니다.")
			return
		end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "골렘이 있을 자리가 없습니다!")
			return
		end

		golem:setEffect(golem.EFF_MIGHTY_BLOWS, 5, {power=t.getPower(self, t)})
		if golem == mover then
			golem:move(x, y, true)
		end
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local power=t.getPower(self, t)
		return ([[골렘을 호출하여 근처에 위치시키고, 5 턴 동안 골렘의 근접 공격력을 %d 상승시킵니다.]]):
		format(power)
	end,
}

newTalent{
	name = "Golem Portal",
	kr_name = "골렘 관문",
	type = {"spell/golemancy",4},
	require = spells_req4,
	points = 5,
	mana = 40,
	cooldown = function(self, t) return 15 - self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "골렘이 활성화되지 않았습니다.")
			return
		end

		local chance = self:getTalentLevelRaw(t) * 15 + 25
		local px, py = self.x, self.y
		local gx, gy = golem.x, golem.y

		self:move(gx, gy, true)
		golem:move(px, py, true)
		self:move(gx, gy, true)
		golem:move(px, py, true)
		game.level.map:particleEmitter(px, py, 1, "teleport")
		game.level.map:particleEmitter(gx, gy, 1, "teleport")

		for uid, e in pairs(game.level.entities) do
			if e.getTarget then
				local _, _, tgt = e:getTarget()
				if e:reactionToward(self) < 0 and tgt == self and rng.percent(chance) then
					e:setTarget(golem)
					game.logSeen(e, "%s 이제 %s에게 집중하기 시작했습니다.", (e.kr_name or e.name):capitalize():addJosa("가"), (golem.kr_name or golem.name))
				end
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[자신과 골렘의 위치를 서로 바꿉니다. 적들은 혼란 상태가 되며, 자신을 공격하던 적은 %d%% 확률로 골렘을 공격하게 됩니다.]]):
		format(self:getTalentLevelRaw(t) * 15 + 25)
	end,
}
